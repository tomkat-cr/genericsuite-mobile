import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:genericsuite/services/theme_config_defaults.dart';

// Pure helpers for the CRUD editor listing screen [GS-346].

/*
 * Convert a dynamic value (int, num or numeric String) to a non-negative int.
 * Any other value returns [fallback]. Negative numbers return 0.
 */
int toNonNegativeInt(dynamic value, int fallback) {
  int? parsed;
  if (value is int) {
    parsed = value;
  } else if (value is num) {
    parsed = value.isFinite ? value.toInt() : null;
  } else if (value is String) {
    final text = value.trim();
    parsed = int.tryParse(text) ?? double.tryParse(text)?.toInt();
  }
  if (parsed == null) {
    return fallback;
  }
  return parsed < 0 ? 0 : parsed;
}

/*
 * Get the column count for a listing line.
 * Priority: props > frontend JSON > default.
 */
int resolveListingCols({
  required String key,
  required Map<String, dynamic>? props,
  required Map<String, dynamic>? editorConfig,
  required int defaultValue,
}) {
  int value = defaultValue;
  if (editorConfig != null && editorConfig.containsKey(key)) {
    value = toNonNegativeInt(editorConfig[key], value);
  }
  if (props != null && props.containsKey(key)) {
    value = toNonNegativeInt(props[key], value);
  }
  return value;
}

/*
 * Make sure line1 + line2 <= listingFieldsCount, and line1 >= 1 when
 * there are listing fields (the title must not be empty).
 */
({int line1, int line2}) clampListingCols(
  int line1,
  int line2,
  int listingFieldsCount,
) {
  if (listingFieldsCount <= 0) {
    return (line1: line1 < 0 ? 0 : line1, line2: line2 < 0 ? 0 : line2);
  }
  if (line1 < 1) {
    line1 = 1;
  }
  if (line1 > listingFieldsCount) {
    line1 = listingFieldsCount;
  }
  if (line2 < 0) {
    line2 = 0;
  }
  if (line1 + line2 > listingFieldsCount) {
    line2 = listingFieldsCount - line1;
  }
  return (line1: line1, line2: line2);
}

/*
 * Get a theme param. If the app does not set the key, use the default.
 */
dynamic getListingThemeParam(Map<String, dynamic>? themeParams, String key) {
  return themeParams?[key] ?? defaultThemeParams[key];
}

/*
 * Row background color. Row index 0 is "even" (same as GS FE).
 */
Color listingRowBackgroundColor(int index, Map<String, dynamic>? themeParams) {
  final key = index % 2 == 0
      ? 'listingRowEvenBackgroundColor'
      : 'listingRowOddBackgroundColor';
  return getListingThemeParam(themeParams, key) as Color;
}

/*
 * Row text color. Row index 0 is "even" (same as GS FE).
 */
Color listingRowTextColor(int index, Map<String, dynamic>? themeParams) {
  final key = index % 2 == 0
      ? 'listingRowEvenTextColor'
      : 'listingRowOddTextColor';
  return getListingThemeParam(themeParams, key) as Color;
}

bool _isBlank(dynamic value) {
  return value == null || (value is String && value.trim().isEmpty);
}

DateTime? _parseListingDate(dynamic value) {
  if (value is num) {
    // Epoch: milliseconds, or seconds when the number is small.
    // Use UTC, the same as the form read path (timestampToDate), so the
    // listing and the form show the same date.
    final millis = value.abs() >= 100000000000 ? value.toInt() : value * 1000;
    return DateTime.fromMillisecondsSinceEpoch(millis.toInt(), isUtc: true);
  }
  if (value is String) {
    final text = value.trim();
    final asNumber = num.tryParse(text);
    if (asNumber != null) {
      return _parseListingDate(asNumber);
    }
    return DateTime.tryParse(text);
  }
  return null;
}

String? _formatBoolean(dynamic value) {
  if (value is bool) {
    return value ? 'Yes' : 'No';
  }
  if (value is num) {
    return value != 0 ? 'Yes' : 'No';
  }
  if (value is String) {
    final text = value.trim().toLowerCase();
    if (text == 'true' || text == '1' || text == 'yes') {
      return 'Yes';
    }
    if (text == 'false' || text == '0' || text == 'no') {
      return 'No';
    }
  }
  return null;
}

/*
 * Format one listing value. Return an empty string when there is nothing
 * to show (null or empty), so the caller can skip it.
 *
 * [selectOptions] is the Map {value: label} of the field, when the field
 * is a select, select_component or select_table.
 */
String formatListingValue(
  Map<String, dynamic> field,
  Map<String, dynamic> item, {
  dynamic selectOptions,
}) {
  final String name = '${field['name']}';
  final dynamic raw = item[name];
  final String type = '${field['type']}';

  switch (type) {
    case 'select_table':
      final dynamic description =
          item['${name}_description'] ??
          (selectOptions is Map && raw != null
              ? selectOptions[raw.toString()]
              : null);
      final dynamic shown = _isBlank(description) ? raw : description;
      return _isBlank(shown) ? '' : '$shown';
    case 'select':
    case 'select_component':
      if (_isBlank(raw)) {
        return '';
      }
      if (selectOptions is Map) {
        final dynamic label = selectOptions[raw.toString()];
        if (!_isBlank(label)) {
          return '$label';
        }
      }
      return '$raw';
    case 'date':
    case 'datetime':
    case 'datetime-local':
      if (_isBlank(raw)) {
        return '';
      }
      final parsed = _parseListingDate(raw);
      if (parsed == null) {
        return '$raw';
      }
      return DateFormat(
        type == 'date' ? 'yyyy-MM-dd' : 'yyyy-MM-dd HH:mm',
      ).format(parsed);
    case 'boolean':
    case 'checkbox':
      if (_isBlank(raw)) {
        return '';
      }
      return _formatBoolean(raw) ?? '$raw';
    default:
      return _isBlank(raw) ? '' : '$raw';
  }
}

/*
 * Join the non-empty values with the separator.
 */
String joinListingValues(Iterable<String> values, String separator) {
  return values.where((v) => v.trim().isNotEmpty).join(separator);
}
