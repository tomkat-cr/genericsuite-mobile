import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'http_service.dart';
import 'message_service.dart';
import 'utilities.dart';

const acsDebug = false;
const Duration debounceDuration = Duration(milliseconds: 500);

class AsyncAutocomplete extends StatefulWidget {
  final FlutterSecureStorage storage;
  final Map<String, dynamic> config;
  final String value;
  final Function(String) onSelected;
  final Function(String, String, int) setError;

  const AsyncAutocomplete({
    required this.storage,
    required this.config,
    required this.value,
    required this.onSelected,
    required this.setError,
    Key? key,
  }) : super(key: key);

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
        widget.storage,
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

    // Get the description from the options
    final Iterable<String> options = optionsRetrieved.map(
      (item) => item[widget.config['suggestion_desc_fieldname']],
    );

    // Store the options data for later use
    for (var item in optionsRetrieved) {
      optionsData[item[widget.config['suggestion_desc_fieldname']]] = item;
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
  FlutterSecureStorage storage;
  Map<String, dynamic> widgetConfig;
  Function(String, String, int) setError;

  _ApiCall(this.storage, this.widgetConfig, this.setError);

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
    if (localApiResp['error_message'] != null &&
        localApiResp['error_message'].isNotEmpty) {
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
    for (var item in List<dynamic>.from(localApiResp['resultset'])) {
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
    HttpUtilities api = HttpUtilities(storage);
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
  final FlutterSecureStorage storage;
  final Map<String, dynamic> config;
  final String value;
  final Function(String) onSelected;
  final Function(String, String, int) setError;

  const SuggestionDropdown({
    required this.storage,
    required this.config,
    required this.value,
    required this.onSelected,
    required this.setError,
    Key? key,
  }) : super(key: key);

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
          storage: widget.storage,
          config: widget.config,
          value: widget.value,
          onSelected: widget.onSelected,
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
