import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'http_service.dart';
import 'message_service.dart';
import 'utilities.dart';

const acsDebug = false;
const Duration debounceDuration = Duration(milliseconds: 500);

/// Normalizes a GenericSuite `resultset` into a list of row maps.
/// Listing endpoints often send a JSON string (see CrudEditor._loadItems);
/// FDA-style endpoints send an already-decoded list.
List<Map<String, dynamic>> suggestionRowsFromResultset(dynamic resultset) {
  dynamic raw = resultset;
  if (raw == null) {
    return <Map<String, dynamic>>[];
  }
  if (raw is String) {
    if (raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    try {
      raw = jsonDecode(raw);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }
  if (raw is Map) {
    final dynamic nested = raw['resultset'] ?? raw['rows'] ?? raw['items'];
    if (nested != null && !identical(nested, raw)) {
      return suggestionRowsFromResultset(nested);
    }
    return <Map<String, dynamic>>[];
  }
  if (raw is! List) {
    return <Map<String, dynamic>>[];
  }
  return raw
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

/// Autocomplete labels from [rows] using [descField]. Skips null/empty.
List<String> suggestionOptionLabels(
  Iterable<Map<String, dynamic>> rows,
  String? descField,
) {
  if (descField == null || descField.isEmpty) {
    return <String>[];
  }
  final List<String> labels = <String>[];
  for (final row in rows) {
    final dynamic value = row[descField];
    if (value == null) {
      continue;
    }
    final String label = value.toString();
    if (label.isEmpty) {
      continue;
    }
    labels.add(label);
  }
  return labels;
}

/// Writes a manually typed suggestion-dropdown value into [selectedItem].
void applySuggestionTypedValue(
  Map<String, dynamic> selectedItem,
  String fieldName,
  String? value,
) {
  selectedItem[fieldName] = value ?? '';
}

/// Applies a picked suggestion the same way genericsuite-fe does: writes
/// the form field's own [fieldName] and only the keys listed in
/// `autocomplete_fields`. Related-table columns such as `_id` / `name`
/// are not copied onto the row.
void applySuggestionSelectedValue({
  required Map<String, dynamic> selectedItem,
  required Map<String, dynamic> config,
  required String fieldName,
  required String encodedValue,
}) {
  final Map<String, dynamic> valueMap = Map<String, dynamic>.from(
    jsonDecode(encodedValue),
  );
  if (valueMap.isEmpty) {
    return;
  }
  final dynamic description = valueMap[config['suggestion_desc_fieldname']];
  if (description == null || description.toString().isEmpty) {
    return;
  }
  final dynamic autocompleteFields = config['autocomplete_fields'];
  if (autocompleteFields is Map) {
    autocompleteFields.forEach((field, attrName) {
      selectedItem[field.toString()] = valueMap[attrName] ?? '';
    });
  }
  final String nameKey =
      (config['suggestion_name_fieldname'] as String?)?.isNotEmpty == true
      ? config['suggestion_name_fieldname'] as String
      : config['suggestion_desc_fieldname'] as String;
  selectedItem[fieldName] = valueMap[nameKey] ?? description;
}

class AsyncAutocomplete extends StatefulWidget {
  final Map<String, dynamic> config;
  final String value;
  final Function(String) onSelected;
  final Function(String)? onChanged;
  final Function(String)? onSaved;
  final Function(String, String, int) setError;

  const AsyncAutocomplete({
    required this.config,
    required this.value,
    required this.onSelected,
    required this.setError,
    this.onChanged,
    this.onSaved,
    super.key,
  });

  @override
  State<AsyncAutocomplete> createState() => AsyncAutocompleteState();
}

class AsyncAutocompleteState extends State<AsyncAutocomplete> {
  // The query currently being searched for. If null, there is no pending
  // request.
  String? _currentQuery;

  // Options received from the API with all the data needed to send back to the
  // app.
  late Map<String, dynamic> optionsData = {};

  // The most recent options received from the API.
  late Iterable<String> _lastOptions = <String>[];

  late final _Debounceable<Iterable<String>?, String> _debouncedSearch;

  // Calls the "remote" API to search with the given query. Returns null when
  // the call has been made obsolete.
  Future<Iterable<String>?> _search(String query) async {
    _currentQuery = query;

    Iterable<Map<String, dynamic>> optionsRetrieved = {};
    try {
      optionsRetrieved = await _ApiCall(
        widget.config,
        widget.setError,
      ).search(_currentQuery!);
    } catch (e) {
      if (acsDebug) {
        widget.setError(e.toString(), 'SDD-AC-E011', severityHigh);
        logDebug('Autocomplete | _search | error: $e');
      }
    }

    // If another search happened after this one, throw away these options.
    // Use the previous options instead and wait for the newer request to
    // finish.
    if (_currentQuery != query) {
      return null;
    }
    _currentQuery = null;

    final String? descField = widget.config['suggestion_desc_fieldname']
        ?.toString();
    final List<String> options = suggestionOptionLabels(
      optionsRetrieved,
      descField,
    );

    // Store the options data for later use
    for (final item in optionsRetrieved) {
      final String? key = item[descField]?.toString();
      if (key != null && key.isNotEmpty) {
        optionsData[key] = item;
      }
    }

    return options;
  }

  @override
  void initState() {
    super.initState();
    _debouncedSearch = _debounce<Iterable<String>?, String>(_search);
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: widget.value),
      optionsBuilder: (TextEditingValue textEditingValue) async {
        final Iterable<String>? options = await _debouncedSearch(
          textEditingValue.text,
        );
        if (options == null) {
          return _lastOptions;
        }
        _lastOptions = options;
        return options;
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: (value) => widget.onChanged?.call(value),
              onSaved: (value) => widget.onSaved?.call(value ?? ''),
              onFieldSubmitted: (_) => onFieldSubmitted(),
            );
          },
      onSelected: (String selection) {
        widget.onSelected(json.encode(optionsData[selection]));
        debugPrint(
          'You just selected $selection and returned: ${json.encode(optionsData[selection])}',
        );
      },
    );
  }
}

// Remote API
class _ApiCall {
  Map<String, dynamic> widgetConfig;
  Function(String, String, int) setError;

  _ApiCall(this.widgetConfig, this.setError);

  // Searches the options, but injects a fake "network" delay.
  Future<Iterable<Map<String, dynamic>>> search(String query) async {
    if (acsDebug) {
      logDebug(
        'Autocomplete | _runApiCall | query: $query | widgetConfig: $widgetConfig',
      );
    }

    if (query == '') {
      return const Iterable<Map<String, dynamic>>.empty();
    }

    // * filter_api_url: Ex. "fda_food_query"
    // * filter_api_request_method: Ex. "POST"
    // * filter_search_param_name: Ex. "food_name"
    // * filter_search_other_param: Ex. {"autocomplete": "1"}
    // * suggestion_id_fieldname: Ex. "id"
    // * suggestion_desc_fieldname: Ex. "description"
    // * suggestion_name_fieldname: Ex. "description"
    // * autocomplete_fields: Ex. {}

    final localApiResp = await _runApiCall(
      urlSuffix: widgetConfig['filter_api_url'],
      requestMethod: widgetConfig['filter_api_request_method'],
      bodyParams: {
        widgetConfig['filter_search_param_name']: query,
        ...widgetConfig['filter_search_other_param'],
      },
      getParams: {},
    );
    if (acsDebug) {
      logDebug('Autocomplete | _runApiCall | localApiResp: $localApiResp');
    }
    final List<Map<String, dynamic>> rows = suggestionRowsFromResultset(
      localApiResp['resultset'],
    );
    if (rows.isEmpty &&
        localApiResp['error_message'] != null &&
        localApiResp['error_message'].toString().isNotEmpty) {
      int severity = localApiResp['status_code'] == 500
          ? severityHigh
          : localApiResp['status_code'] == 400
          ? severityLow
          : severityMedium;
      setError(localApiResp['error_message'], 'SDD-AC-E010', severity);
      return const Iterable<Map<String, dynamic>>.empty();
    }
    if (acsDebug) {
      logDebug(
        'Autocomplete | _runApiCall | localApiResp: ${localApiResp.toString()}',
      );
    }
    List<Map<String, dynamic>> resultset = [];
    for (var item in rows) {
      Map<String, dynamic> newItem = {
        widgetConfig['suggestion_id_fieldname']:
            item[widgetConfig['suggestion_id_fieldname']],
        widgetConfig['suggestion_desc_fieldname']:
            item[widgetConfig['suggestion_desc_fieldname']],
        widgetConfig['suggestion_name_fieldname']:
            item[widgetConfig['suggestion_name_fieldname']],
      };
      for (var field in widgetConfig['autocomplete_fields'].keys) {
        newItem[field] = item[field];
      }
      resultset.add(newItem);
    }
    return resultset;
  }

  Future<Map<String, dynamic>> _runApiCall({
    required String urlSuffix,
    required String requestMethod,
    dynamic bodyParams,
    Map<String, dynamic> getParams = const {},
  }) async {
    HttpUtilities api = HttpUtilities();
    Map<String, dynamic> body = bodyParams.cast<String, dynamic>();
    if (acsDebug) {
      logDebug(
        'Autocomplete | _runApiCall | urlSuffix: $urlSuffix | requestMethod: $requestMethod | body: $body | getParams: $getParams',
      );
    }
    final localApiResp = await api.httpsCall(
      requestMethod,
      urlSuffix,
      {},
      body,
      getParams,
    );
    if (acsDebug) {
      logDebug('Autocomplete | _runApiCall | localApiResp: $localApiResp');
    }
    return localApiResp;
  }
}

class SuggestionDropdown extends StatefulWidget {
  final Map<String, dynamic> config;
  final String value;
  final Function(String) onSelected;
  final Function(String)? onChanged;
  final Function(String)? onSaved;
  final Function(String, String, int) setError;

  const SuggestionDropdown({
    required this.config,
    required this.value,
    required this.onSelected,
    required this.setError,
    this.onChanged,
    this.onSaved,
    super.key,
  });

  @override
  State<SuggestionDropdown> createState() => SuggestionDropdownState();
}

class SuggestionDropdownState extends State<SuggestionDropdown> {
  void _setDefaultValues() {
    widget.config['filter_api_url'] = defaultValue(
      widget.config,
      'filter_api_url',
    ); // Ex. "fda_food_query"
    widget.config['filter_api_request_method'] = defaultValue(
      widget.config,
      "filter_api_request_method",
      "POST",
    ); // Ex. true or false
    widget.config['filter_search_param_name'] = defaultValue(
      widget.config,
      'filter_search_param_name',
    ); // Ex. "food_name"
    widget.config['filter_search_other_param'] = defaultValue(
      widget.config,
      'filter_search_other_param',
    ); // Ex. {"autocomplete": "1"}
    widget.config['suggestion_id_fieldname'] = defaultValue(
      widget.config,
      "suggestion_id_fieldname",
    ); // Ex. "id"
    widget.config['suggestion_desc_fieldname'] = defaultValue(
      widget.config,
      "suggestion_desc_fieldname",
    ); // Ex. "description"
    widget.config['suggestion_name_fieldname'] = defaultValue(
      widget.config,
      "suggestion_name_fieldname",
      widget.config['suggestion_desc_fieldname'],
    ); // Ex. "description"
    widget.config['autocomplete_fields'] = defaultValue(
      widget.config,
      "autocomplete_fields",
      {},
    );
  }

  @override
  Widget build(BuildContext context) {
    _setDefaultValues();

    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(widget.config['label']),
        AsyncAutocomplete(
          config: widget.config,
          value: widget.value,
          onSelected: widget.onSelected,
          onChanged: widget.onChanged,
          onSaved: widget.onSaved,
          setError: widget.setError,
        ),
      ],
    );
  }
}

typedef _Debounceable<S, T> = Future<S?> Function(T parameter);

/// Returns a new function that is a debounced version of the given function.
///
/// This means that the original function will be called only after no calls
/// have been made for the given Duration.
_Debounceable<S, T> _debounce<S, T>(_Debounceable<S?, T> function) {
  _DebounceTimer? debounceTimer;

  return (T parameter) async {
    if (debounceTimer != null && !debounceTimer!.isCompleted) {
      debounceTimer!.cancel();
    }
    debounceTimer = _DebounceTimer();
    try {
      await debounceTimer!.future;
    } on _CancelException {
      return null;
    }
    return function(parameter);
  };
}

// A wrapper around Timer used for debouncing.
class _DebounceTimer {
  _DebounceTimer() {
    _timer = Timer(debounceDuration, _onComplete);
  }

  late final Timer _timer;
  final Completer<void> _completer = Completer<void>();

  void _onComplete() {
    _completer.complete();
  }

  Future<void> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  void cancel() {
    _timer.cancel();
    _completer.completeError(const _CancelException());
  }
}

// An exception indicating that the timer was canceled.
class _CancelException implements Exception {
  const _CancelException();
}
