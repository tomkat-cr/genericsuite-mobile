import 'package:genericsuite/services/http_service.dart';
import 'package:genericsuite/services/select_options_service.dart';
import 'package:genericsuite/services/utilities.dart';

const gceSelDebug = false;

/// Simple in-memory cache for select options
class SelectCache {
  static final Map<String, dynamic> _data = {};

  static void put(String key, dynamic value) {
    _data[key] = value;
  }

  static dynamic get(String key) {
    return _data[key];
  }

  static bool has(String key) {
    return _data.containsKey(key);
  }

  static void clear() {
    _data.clear();
  }
}

const String msgSelectAnOption = "Select an option...";

/// Generic function to build description from multiple fields
String buildDescription(Map<String, dynamic> option, List<dynamic> fieldArray) {
  String description = '';
  for (var field in fieldArray) {
    if (option[field] != null) {
      description += '${option[field]} ';
    }
  }
  return description.trim();
}

/// Generic select generator that mimics the React version
Future<dynamic> genericSelectGenerator({
  required String dbApiUrl,
  required String selectName,
  dynamic filter,
  Map<String, dynamic>? dbFilter,
  bool showDescription = false,
  List<dynamic> descriptionFields = const ["name"],
}) async {
  if (SelectCache.has(selectName)) {
    if (gceSelDebug) {
      logDebug('>> genericSelectGenerator | Using cache for: $selectName');
    }
    return _processRows(
      SelectCache.get(selectName),
      filter: filter,
      showDescription: showDescription,
      descriptionFields: descriptionFields,
    );
  }

  HttpUtilities api = HttpUtilities();
  Map<String, dynamic> accessKeysListing = {};
  if (dbFilter != null) {
    accessKeysListing.addAll(dbFilter);
  }

  try {
    final response = await api.httpsCall(
      'GET',
      dbApiUrl,
      {},
      {},
      accessKeysListing,
    );
    if (response['error'] == true) {
      return response['error_message'];
    }

    final data = response['resultset'] ?? [];
    SelectCache.put(selectName, data);

    return _processRows(
      data,
      filter: filter,
      showDescription: showDescription,
      descriptionFields: descriptionFields,
    );
  } catch (e) {
    logErrorRaw('genericSelectGenerator | error: $e');
    return e.toString();
  }
}

dynamic _processRows(
  List<dynamic> rows, {
  dynamic filter,
  bool showDescription = false,
  List<dynamic> descriptionFields = const ["name"],
}) {
  // Prepend "Select an option" item
  Map<String, dynamic> selectAnOptionItem = {'_id': null};
  if (descriptionFields.isNotEmpty) {
    selectAnOptionItem[descriptionFields[0]] = msgSelectAnOption;
    for (int i = 1; i < descriptionFields.length; i++) {
      selectAnOptionItem[descriptionFields[i]] = '';
    }
  }

  List<dynamic> allRows = [selectAnOptionItem, ...rows];

  // Filtering
  var filteredRows = allRows.where((option) {
    if (filter == null) return true;
    return option['_id']?.toString() == filter.toString();
  });

  if (showDescription) {
    return filteredRows
        .map((option) => buildDescription(option, descriptionFields))
        .toList();
  }

  // Return formatted Map for DropdownButtonFormField
  Map<String, dynamic> formattedOptions = {};
  for (var option in filteredRows) {
    String id = option['_id']?.toString() ?? '';
    formattedOptions[id] = buildDescription(option, descriptionFields);
  }
  return formattedOptions;
}

/// Helper for select data populator
Future<Map<String, dynamic>> genericSelectDataPopulator({
  required String dbApiUrl,
  required String selectName,
  Map<String, dynamic>? dbFilter,
  List<dynamic> descriptionFields = const ["name"],
  String titleFieldName = "title",
  String valueFieldName = "value",
  String keyName = "_id",
}) async {
  var result = await genericSelectGenerator(
    dbApiUrl: dbApiUrl,
    selectName: selectName,
    dbFilter: dbFilter,
    descriptionFields: descriptionFields,
    showDescription: false,
  );

  if (result is String) {
    return {'error': result};
  }

  // If result is the formatted map, we might need to adjust it for specific field names if requested
  // but usually SelectOptionsService.putSelectOptionsFromArray expects a standard Map<String, dynamic>
  return result as Map<String, dynamic>;
}

/// Returns the description for a selected value in a CRUD editor
dynamic getSelectDescription({
  required Map<String, dynamic> currentObj,
  required Map<String, dynamic> dbRow,
  required Map<String, dynamic> constants,
  required Map<String, dynamic> selectFieldsOptionsPromises,
}) {
  if (gceSelDebug) {
    logDebug("getSelectDescription - currentObj: $currentObj, dbRow: $dbRow");
  }

  String fieldName = currentObj['name'];
  dynamic value = dbRow[fieldName];

  // Generic select (from constants)
  if (currentObj['type'] == 'select') {
    Map<String, dynamic> selectElements = Map<String, dynamic>.from(
      constants[currentObj['select_elements']] ?? {},
    );
    return getSelectOptionLabel(selectElements, value?.toString() ?? '');
  }

  // Component select (with specific data populator result)
  if (currentObj['type'] == 'select_component') {
    Map<String, dynamic>? selectElements =
        selectFieldsOptionsPromises[currentObj['component']]?['promiseResult'];
    if (selectElements != null) {
      return getSelectOptionLabel(selectElements, value?.toString() ?? '');
    }
  }

  // Verify if the attribute (field) exists
  if (value == null) {
    return null;
  }

  // Show specific component (if defined)
  if (currentObj['type'] == 'component' || currentObj['component'] != null) {
    return value;
  }

  // Returns plain value
  return value;
}
