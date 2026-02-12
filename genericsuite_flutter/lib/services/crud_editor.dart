import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genericsuite/services/app_callables_super.dart';
import 'package:genericsuite/services/crud_editor_commons.dart';
import 'package:genericsuite/services/crud_editor_sf_filters.dart';
import 'package:genericsuite/services/crud_editor_sf_timestamps.dart';
import 'package:genericsuite/services/crud_editor_sf_users.dart';
import 'package:genericsuite/services/form_field_service.dart';
import 'package:genericsuite/services/general_messages.dart';
import 'package:genericsuite/services/http_service.dart';
import 'package:genericsuite/services/locator_service.dart';
import 'package:genericsuite/services/message_service.dart';
import 'package:genericsuite/services/utilities.dart';
import 'package:genericsuite/widgets/app_frame.dart';

const gceMainDebug = false;
const debugRunCrudCallback = false;

class CrudEditor extends StatefulWidget {
  final String jsonFileName;
  final AppCallablesSuper appCallables;
  final Map<String, dynamic>? callbacks;
  final Map<String, dynamic>? props;
  final Function()? backButtonAction;

  const CrudEditor({
    required this.jsonFileName,
    required this.appCallables,
    this.callbacks,
    this.props,
    this.backButtonAction,
    super.key,
  });

  @override
  CrudEditorState createState() => CrudEditorState();
}

class CrudEditorState extends State<CrudEditor> {
  final FlutterSecureStorage storage = locator<FlutterSecureStorage>();

  String userId = '';
  Map<String, dynamic> currentUserData = {};
  Map<String, dynamic> editorConfig = {};
  Map<String, dynamic> apiResponse = {};
  String urlGenSuffix = '';

  Map<String, dynamic> searchFilters = {};
  List<dynamic> listingFieldElements = [];
  List<dynamic> items = [];
  int colsForListingLine1 = 1;
  int colsForListingLine2 = 0;

  Map<String, dynamic> callbacks = {};
  dynamic selectedItem;
  bool isEditMode = false;
  bool isCreation = false;
  bool _isLoading = false;

  bool isCreationForced = false;
  bool isEditModeForced = false;
  String itemIdForced = '';
  bool showAppMenu = true;
  bool ignoreUserData = false;

  String errorMessage = '';
  String errorCode = '';
  bool errorWaitForOk = true;
  String infoMessage = '';

  Map<String, dynamic> constants = {};

  /*
   * Schedule bindings, to show error and info messages after the widget is built
   */
  void _scheduleBindings() {
    scheduleMessagesBindings(context, {
      'errorMessage': errorMessage,
      'errorCode': errorCode,
      'infoMessage': infoMessage,
      'errorWaitForOk': errorWaitForOk,
    }, widget.appCallables);
    errorMessage = "";
    errorCode = "";
    errorWaitForOk = true;
    infoMessage = "";
  }

  /*
   * Set the state and schedule show messages
   */
  void _setStateAndShowMessages() {
    _scheduleBindings();
    setState(() {});
  }

  /*
   * Get the select fields options for field types 'select_component' 
   * with dataPopulator attribute
   */
  Map<String, dynamic> _getSelectFieldsOptions() {
    Map<String, dynamic> response = {};
    for (var currentObj in editorConfig['fieldElements']) {
      if (!(currentObj['type'] == 'select_component' &&
          currentObj.containsKey('dataPopulator'))) {
        continue;
      }
      response[currentObj['name']] = {
        'promiseResult':
            callbacks['dataPopulators'][currentObj['dataPopulator']],
      };
    }
    return response;
  }

  void _setEndpointFilter(Map<String, dynamic> parentData) {
    // Check inconsistencies: parentData isn't loaded yet or endpointKeyNames is not defined
    if (parentData.isEmpty || !editorConfig.containsKey('endpointKeyNames')) {
      return;
    }
    // Check inconsistencies: parentData length
    if (parentData.length < editorConfig['endpointKeyNames'].length) {
      return;
    }
    // Set endpointFilter to retrieve the parent table item
    // containing the array of child items, or the child table items
    editorConfig['endpointFilter'] = {};
    editorConfig['endpointKeyNames'].forEach((keyPair) {
      editorConfig['endpointFilter'][keyPair['parameterName']] =
          parentData[keyPair['parentElementName']];
    });

    // IMPORTANT: endpointFilter and parentData
    // This is for editor.type = 'child_listing' / editor.subType = 'array' or 'table'
    // The component call must have the parentData={parentData} attribute
    // and eventually handleFormPageActions={handleFormPageActions}
    editorConfig['parentData'] = parentData;
  }

  Future<bool> _addStandardCallbacks() async {
    editorConfig['dbListPostRead'].add('TimestampDbListPostRead');
    editorConfig['dbPostRead'].add('TimestampDbPostRead');
    editorConfig['dbPreWrite'].add('TimestampDbPreWrite');
    callbacks = widget.callbacks != null
        ? Map<String, dynamic>.from(widget.callbacks!)
        : {};
    try {
      if (!callbacks.containsKey('specificFunctions')) {
        callbacks['specificFunctions'] = <String, dynamic>{};
      }

      callbacks['specificFunctions']['MandatoryFiltersDbListPreRead'] =
          (
            dynamic data,
            Map<String, dynamic> editorConfig,
            String action,
            Map<String, dynamic> params,
            BuildContext? context,
          ) async => mandatoryFiltersDbListPreRead(
            data,
            editorConfig,
            action,
            params,
            context,
          );
      callbacks['specificFunctions']['MandatoryFiltersDbPreRead'] =
          (
            dynamic data,
            Map<String, dynamic> editorConfig,
            String action,
            Map<String, dynamic> params,
            BuildContext? context,
          ) async => mandatoryFiltersDbPreRead(
            data,
            editorConfig,
            action,
            params,
            context,
          );

      callbacks['specificFunctions']['TimestampDbListPostRead'] =
          (
            dynamic data,
            Map<String, dynamic> editorConfig,
            String action,
            Map<String, dynamic> params,
            BuildContext? context,
          ) async => timestampDbListPostRead(
            data,
            editorConfig,
            action,
            params,
            context,
          );
      callbacks['specificFunctions']['TimestampDbPostRead'] =
          (
            dynamic data,
            Map<String, dynamic> editorConfig,
            String action,
            Map<String, dynamic> params,
            BuildContext? context,
          ) async =>
              timestampDbPostRead(data, editorConfig, action, params, context);
      callbacks['specificFunctions']['TimestampDbPreWrite'] =
          (
            dynamic data,
            Map<String, dynamic> editorConfig,
            String action,
            Map<String, dynamic> params,
            BuildContext? context,
          ) async =>
              timestampDbPreWrite(data, editorConfig, action, params, context);

      callbacks['specificFunctions']['UsersValidations'] =
          (
            dynamic data,
            Map<String, dynamic> editorConfig,
            String action,
            Map<String, dynamic> params,
            BuildContext? context,
          ) async =>
              usersValidations(data, editorConfig, action, params, context);
      callbacks['specificFunctions']['UsersDbListPreRead'] =
          (
            dynamic data,
            Map<String, dynamic> editorConfig,
            String action,
            Map<String, dynamic> params,
            BuildContext? context,
          ) async =>
              usersDbListPreRead(data, editorConfig, action, params, context);
      callbacks['specificFunctions']['UsersPasswordValidations'] =
          (
            dynamic data,
            Map<String, dynamic> editorConfig,
            String action,
            Map<String, dynamic> params,
            BuildContext? context,
          ) async => usersPasswordValidations(
            data,
            editorConfig,
            action,
            params,
            context,
          );
      callbacks['specificFunctions']['UsersDbPreWrite'] =
          (
            dynamic data,
            Map<String, dynamic> editorConfig,
            String action,
            Map<String, dynamic> params,
            BuildContext? context,
          ) async =>
              usersDbPreWrite(data, editorConfig, action, params, context);
    } catch (e, stackTrace) {
      errorMessage = 'Error adding standard callbacks';
      errorCode = "FGCE-ASC-E010";
      await logError(
        'CRUD | _addStandardCallbacks | ERROR: $e'
        '\nError Trace:\n${stackTrace.toString()}',
        errorCode,
      );
      return false;
    }
    return true;
  }

  /*
   * Set the editor configutation from the JSON config file
   */
  Future<bool> _getEditorConfig() async {
    String configFilename =
        "assets/config_dbdef/frontend/${widget.jsonFileName}";
    if (gceMainDebug) {
      logDebug('CRUD | _getEditorConfig | configFilename: $configFilename');
    }
    return getJsonFile(configFilename)
        .then((editorConfigRaw) {
          editorConfig = Map<String, dynamic>.from(editorConfigRaw);
          if (gceMainDebug) {
            logDebug('CRUD | _getEditorConfig | configFilename LOADED');
          }
          return _setEditorConfig();
        })
        .catchError((e) {
          errorMessage =
              'Error loading config file'
              '${gceMainDebug ? '\nDetail: $e\nFile: $configFilename' : ''}';
          errorCode = "FGCE-GEC-E010";
          return logError(
            'CRUD | _getEditorConfig | ERROR: $e',
            errorCode,
          ).then((_) {
            return false;
          });
        });
  }

  Future<bool> _setEditorConfig() async {
    if (editorConfig.isEmpty) {
      editorConfig['error'] = 'Empty editor config';
      return false;
    }
    editorConfig['error'] = '';

    urlGenSuffix = editorConfig['dbApiUrl'];

    // Custom Callbacks (Specific Functions):

    // dbListPreRead: Before read data from database in the listing.
    // Good place for hidden filters.
    // Default: []
    if (!editorConfig.containsKey('dbListPreRead') ||
        editorConfig['dbListPreRead'] == null) {
      editorConfig['dbListPreRead'] = [];
    }
    // dbListPostRead: After read data from database in the listing.
    // Default: []
    if (!editorConfig.containsKey('dbListPostRead') ||
        editorConfig['dbListPostRead'] == null) {
      editorConfig['dbListPostRead'] = [];
    }

    // dbPreRead: Before read data from database.
    // If any error, shows the error message.
    // Default: []
    if (!editorConfig.containsKey('dbPreRead') ||
        editorConfig['dbPreRead'] == null) {
      editorConfig['dbPreRead'] = [];
    }

    // dbPreValidations: Validate data before show the Data Form.
    // If any error, shows the error message and prevents edition of the Data Form or deletion of the row.
    // Default: []
    if (!editorConfig.containsKey('dbPreValidations') ||
        editorConfig['dbPreValidations'] == null) {
      editorConfig['dbPreValidations'] = [];
    }

    // dbPostRead: After read data from database in formData.
    // If any error, shows the error message.
    // Default: []
    if (!editorConfig.containsKey('dbPostRead') ||
        editorConfig['dbPostRead'] == null) {
      editorConfig['dbPostRead'] = [];
    }

    // validations: FormData field values validation before write to the database.
    // If any error, prevents the database write and stays in FormData.
    // Default: []
    if (!editorConfig.containsKey('validations') ||
        editorConfig['validations'] == null) {
      editorConfig['validations'] = [];
    }

    // dbPreWrite: Before write to database, after a successfull validation.
    // If any error, shows the error message, prevents the database write and stays in FormData.
    // Default: []
    if (!editorConfig.containsKey('dbPreWrite') ||
        editorConfig['dbPreWrite'] == null) {
      editorConfig['dbPreWrite'] = [];
    }

    // dbPostWrite: After a successful write to database.
    // If any error, shows the error message and stays in FormData.
    // Default: []
    if (!editorConfig.containsKey('dbPostWrite') ||
        editorConfig['dbPostWrite'] == null) {
      editorConfig['dbPostWrite'] = [];
    }

    // mandatoryFilters: Mandatory filters. It's a map of key-value pairs. If the value is "{CurrentUserId}", it will be replaced with the current user ID. Filters will be added to dbListPreRead and dbPreRead. Default: {}
    if (!editorConfig.containsKey('mandatoryFilters') ||
        editorConfig['mandatoryFilters'] == null) {
      editorConfig['mandatoryFilters'] = {};
    } else {
      editorConfig['dbListPreRead'].add('MandatoryFiltersDbListPreRead');
      editorConfig['dbPreRead'].add('MandatoryFiltersDbPreRead');
    }

    // userIdFilter: User ID filter. Default: false
    if (!editorConfig.containsKey('userIdFilter') ||
        editorConfig['userIdFilter'] == null) {
      editorConfig['userIdFilter'] = false;
    }
    if (editorConfig['userIdFilter']) {
      editorConfig['mandatoryFilters']['userId'] = userId;
    }

    // THESE 3 CALLBACKS MUST BE LAST ONES
    // Date <-> Timestamp management: For creation and update of timestamp fields
    if (!await _addStandardCallbacks()) {
      return false;
    }

    // Editor Configuration:

    // childComponents: Child components. Default: []
    if (!editorConfig.containsKey('childComponents') ||
        editorConfig['childComponents'] == null) {
      editorConfig['childComponents'] = [];
    }

    // primaryKeyName: Primary Key parameter name for API calls. Default: 'id'
    if (!editorConfig.containsKey('primaryKeyName') ||
        editorConfig['primaryKeyName'] == null) {
      editorConfig['primaryKeyName'] = 'id';
    }

    // type: Editor type. Options: 'master_listing' | 'child_listing'. Default: 'master_listing'
    if (!editorConfig.containsKey('type') || editorConfig['type'] == null) {
      editorConfig['type'] = 'master_listing';
    }

    // subType: Editor sub-type. Options: 'array' | 'table'. Default: 'table'
    if (!editorConfig.containsKey('subType') ||
        editorConfig['subType'] == null) {
      editorConfig['subType'] = 'table';
    }

    // endpointKeyNames: Endpoint Key Names, for child listing. Default: []
    if (!editorConfig.containsKey('endpointKeyNames') ||
        editorConfig['endpointKeyNames'] == null) {
      editorConfig['endpointKeyNames'] = [];
    }

    // arrayName: Array name for the 'array' subType child listing. These elements are inside a real table. Default: []
    if (!editorConfig.containsKey('arrayName') ||
        editorConfig['arrayName'] == null) {
      editorConfig['arrayName'] = [];
    }

    editorConfig['endpointFilter'] = {};
    bool subTypeError = false;
    if (editorConfig['subType'] == 'array') {
      if (!editorConfig.containsKey('array_name') ||
          editorConfig['array_name'] == null) {
        subTypeError = true;
        editorConfig['error'] =
            'Missing "array_name" parameter. It must be specified for subType "array".';
      } else if (!editorConfig.containsKey('endpointKeyNames') ||
          editorConfig['endpointKeyNames'] == null) {
        subTypeError = true;
        // Missing "endpointKeyNames" parameter. It must be specified for subType "{subType}".
        editorConfig['error'] =
            'Missing endpointKeyNames parameter for subType "{subType}"'
                .replaceAll("{subType}", editorConfig['subType']);
      }
    }

    // Child data for 'table' subType child listing. These elements are outside a real table.
    if (editorConfig['subType'] == 'table' &&
        (!editorConfig.containsKey('endpointKeyNames') ||
            editorConfig['endpointKeyNames'] == null)) {
      subTypeError = true;
      editorConfig['error'] =
          'Missing endpointKeyNames parameter for subType "{subType}"'
              .replaceAll("{subType}", editorConfig['subType']);
    }

    if (editorConfig['type'] == 'child_listing' && !subTypeError) {
      // Filters for child components
      if (editorConfig['subType'] == 'array') {
        if (editorConfig['endpointKeyNames'].length == 0) {
          editorConfig['error'] =
              'endpointKeyNames parameter is empty. It must be specified for subType "{subType}"'
                  .replaceAll("{subType}", editorConfig['subType']);
        }
      } else if (editorConfig['subType'] == 'table') {
        if (editorConfig['endpointKeyNames'].length == 0) {
          editorConfig['error'] =
              'endpointKeyNames parameter is empty. It must be specified for subType "{subType}"'
                  .replaceAll("{subType}", editorConfig['subType']);
        }
      } else {
        editorConfig['error'] =
            'Incorrect "subType" parameter. It must be "array" or "table" for "child_listing" type. Current value: ${editorConfig['subType']}';
      }
      if (editorConfig['error'].isNotEmpty) {
        errorMessage = editorConfig['error'];
        errorCode = "FGCE-LEC-E010";
        await logError(
          'CRUD | _loadEditorConfig | ERROR [1]: ${editorConfig['error']}',
          errorCode,
        );
        return false;
      }
      if (widget.props != null && widget.props!.containsKey('parentData')) {
        _setEndpointFilter(widget.props!['parentData']);
      }
    }

    // Get parameters passed by the caller (as if they were passed by a URL)
    editorConfig['urlParams'] = {
      // TODO: verify if these parameters make any sense
      // 'page': widget.props!['page'] ?? 1,
      // 'limit': widget.props!['limit'] ?? 0, // 0=no limit
    };

    // Set default values for column definitions
    editorConfig['fieldElements'] = _getColumns();

    // Populate Select type Fields Options
    editorConfig['selectFieldsOptionsPromises'] = _getSelectFieldsOptions();

    listingFieldElements = editorConfig['fieldElements'].where((field) {
      return field['listing'] == true;
    }).toList();

    if (gceMainDebug) {
      logDebug(
        'CRUD | _loadEditorConfig | listingFieldElements: ${listingFieldElements.toString()}',
      );
    }

    // Reenter on create
    if (!editorConfig.containsKey('createReenter') ||
        editorConfig['createReenter'] == null) {
      // TODO: check it this work
      editorConfig['createReenter'] = false;
    }

    // To start the editor in edit mode or creation mode
    if (gceMainDebug) {
      logDebug(
        'CRUD | _loadEditorConfig | widget.props: ${widget.props.toString()}',
      );
    }
    if (widget.props != null) {
      if (widget.props!.containsKey('isEditMode')) {
        if (gceMainDebug) {
          logDebug(
            'CRUD | _loadEditorConfig | FORCED isEditMode: ${widget.props!['isEditMode']}',
          );
        }
        isEditModeForced = widget.props!['isEditMode'];
        itemIdForced = widget.props!['itemId'] ?? '';
        if (itemIdForced.isEmpty) {
          editorConfig['error'] = 'itemIdForced is empty';
        }
      }
      if (widget.props!.containsKey('isCreation')) {
        isCreationForced = widget.props!['isCreation'];
        isCreation = isCreationForced;
        if (gceMainDebug) {
          logDebug(
            'CRUD | _loadEditorConfig | FORCED isCreation: ${widget.props!['isCreation']}',
          );
        }
      }
      if (widget.props!.containsKey('showAppMenu')) {
        showAppMenu = widget.props!['showAppMenu'];
      }
      if (widget.props!.containsKey('searchFilters')) {
        // TODO: make searchFilters work
        searchFilters = widget.props!['searchFilters'];
      }
      if (widget.props!.containsKey('colsForListingLine1')) {
        // TODO: check it this work
        colsForListingLine1 = widget.props!['colsForListingLine1'];
      }
      if (widget.props!.containsKey('colsForListingLine2')) {
        // TODO: check it this work
        colsForListingLine2 = widget.props!['colsForListingLine2'];
      }
    }

    if (editorConfig['error'].isNotEmpty) {
      errorMessage = editorConfig['error'];
      errorCode = "FGCE-LEC-E020";
      await logError(
        'CRUD | _loadEditorConfig | ERROR [2]: ${editorConfig['error']}',
        errorCode,
      );
      return false;
    }

    if (gceMainDebug) {
      logDebug(
        'CRUD | 3) loadconfig | userId: $userId | editorConfig: $editorConfig',
      );
    }
    return true;
  }

  /*
  * Load the widget configuration
  */
  Future<bool> _loadConfig() async {
    if (gceMainDebug) {
      logDebug('CRUD | 1) loadconfig...');
    }
    return storage.read(key: 'user_data').then((userDataValue) {
      return getAllConstants().then((constantsMap) {
        return loadConfig().then((configStr) {
          constants = constantsMap;

          if (userDataValue == null || userDataValue.isEmpty) {
            if (widget.props != null &&
                widget.props!.containsKey('ignoreUserData')) {
              ignoreUserData = widget.props!['ignoreUserData'];
            }
            if (ignoreUserData) {
              currentUserData = {};
            } else {
              errorMessage = "User data not found [1]";
              errorCode = "FGCE-UC-E010";
              return false;
            }
          } else {
            currentUserData = Map<String, dynamic>.from(
              json.decode(userDataValue),
            );
          }

          if (gceMainDebug) {
            logDebug(
              'CRUD | 1.1) loadconfig | currentUserData: $currentUserData',
            );
          }

          Map<String, dynamic> config = Map<String, dynamic>.from(
            json.decode(configStr),
          );
          userId = config["userId"];

          if (gceMainDebug) {
            logDebug(
              'CRUD | 2) loadconfig | userId: $userId'
              ' | jsonFileName: ${widget.jsonFileName}',
            );
          }

          return _getEditorConfig().then((result) {
            if (result) {
              if (isEditModeForced) {
                _loadSelectedItem(itemIdForced).then((result) {
                  setState(() {
                    selectedItem = result;
                  });
                  return true;
                });
              } else if (isCreationForced) {
                setState(() {
                  selectedItem = _getEmptyItem();
                  isCreation = true;
                });
                if (gceMainDebug) {
                  logDebug(
                    'CRUD | _loadEditorConfig | isCreationForced | selectedItem: ${selectedItem.toString()}',
                  );
                }
                return true;
              } else {
                _loadItems().then((result) {
                  return true;
                });
              }
            }
            return result;
          });
        });
      });
    });
  }

  /*
   * Execute an API call
   */
  Future<Map<String, dynamic>> _runApiCall(
    String urlSuffix,
    String requestMethod,
    dynamic bodyParams,
    Map<String, dynamic> getParams,
  ) async {
    setState(() {
      _isLoading = true;
    });
    HttpUtilities api = HttpUtilities();
    Map<String, dynamic> body = bodyParams.cast<String, dynamic>();
    if (gceMainDebug) {
      logDebug(
        'CRUD | _runApiCall | urlSuffix: $urlSuffix | requestMethod: $requestMethod | body: $body | getParams: $getParams',
      );
    }
    final localApiResp = await api.httpsCall(
      requestMethod,
      urlSuffix,
      {},
      body,
      getParams,
    );
    if (gceMainDebug) {
      logDebug('CRUD | _runApiCall | localApiResp: $localApiResp');
    }
    _isLoading = false;
    return localApiResp;
  }

  /*
  GenericSuite field types:

    * 'text': generates a text input field (single line).
    * 'textarea': generates a textarea input field (multi line).
    * 'number': generates a number input field (float).
    * 'integer': generates a integer input field (no decimals).
    * 'date': generates a date input field (date only).
    * 'datetime-local': generates a datetime-local input field (date and
        time).
    * 'email': generates an email input field (and validates it during the
        input).
    * 'label': generates a label with no input field.
    * 'hr', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6': generates a horizontal rule.
    * '_id': generates a hidden input field with the current object's
        primary key value.
    * 'select': generates a select input field from a list of options.
    * 'select_component': generates a select input field with a ReactJS
        component that populates the options from the database.
    * 'suggestion_dropdown': generates a input field with a suggestion
        dropdown from the database or a API call.
    * 'component': shows a value generated from a ReactJS component.
    
    * 'select_table': generates a select input field from a list of items in
        a related table. (Not implemented yet)
  */

  /*
   * Get an empty item fom the edito configuration
   */
  Map<String, dynamic> _getEmptyItem() {
    return (editorConfig['fieldElements'] as List<dynamic>)
        .where(
          (field) =>
              ![
                'label',
                'hr',
                'h1',
                'h2',
                'h3',
                'h4',
                'h5',
                'h6',
              ].contains(field['type']) &&
              field['name'] != '_id',
        )
        .map((field) {
          switch (field['type']) {
            case 'integer':
              return {
                field['name']: getValueToEdit(
                  field['default_value'],
                  0,
                  currentUserData,
                ),
              };
            case 'number':
              return {
                field['name']: getValueToEdit(
                  field['default_value'],
                  0.0,
                  currentUserData,
                ),
              };
            case 'date':
              return {
                field['name']: getValueToEdit(
                  field['default_value'],
                  getTodayDateTime(),
                  currentUserData,
                ),
              };
            case 'datetime-local':
              return {
                field['name']: getValueToEdit(
                  field['default_value'],
                  getTodayDateTime(),
                  currentUserData,
                ),
              };
            default:
              return {
                field['name']: getValueToEdit(
                  field['default_value'],
                  '',
                  currentUserData,
                ),
              };
          }
        })
        .fold<Map<String, dynamic>>(
          {},
          (a, b) => a..addAll(Map<String, dynamic>.from(b)),
        );
  }

  /*
   * Set item values from the data read from the database
   */
  // Map<String, dynamic> _getItemValuesFromDb(Map<String, dynamic> itemValues) {
  //   return editorConfig['fieldElements']
  //       .where((field) => !['label', 'hr', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6']
  //           .contains(field['type']))
  //       .map((field) {
  //     return {field['name']: itemValues[field['name']]};
  //   }).reduce((a, b) => a..addAll(b));
  // }

  /*
   * Run the CRUD Custom Callbacks (specific functions)
   */
  Future<Map<String, dynamic>> _runCrudCallback(
    String funcType,
    dynamic originalData,
    String action,
    Map<String, dynamic> params,
  ) async {
    List<dynamic> responses = [];
    dynamic data = originalData;
    Map<String, dynamic> finalResult = genericFuncArrayDefaultValue(data);

    if (callbacks.isEmpty ||
        !callbacks.containsKey('specificFunctions') ||
        editorConfig[funcType] == null ||
        editorConfig[funcType].isEmpty) {
      if (debugRunCrudCallback) {
        logDebug(
          'CRUD | _runCrudCallback | ERROR: No callbacks found for $funcType'
          '\n | action: $action'
          '\n | params: $params'
          '\n | originalData: $originalData'
          '\n | finalResult: $finalResult',
        );
      }
      return finalResult;
    }

    if (debugRunCrudCallback) {
      logDebug(
        'CRUD | _runCrudCallback | [$funcType] | Begin'
        '\n | action: $action'
        '\n | params: $params'
        '\n | originalData: $originalData'
        '\n | finalResult: $finalResult',
      );
    }

    String funcName = "";
    try {
      // Add current user data to params so specific functions can use it
      if (debugRunCrudCallback) {
        logDebug(
          'CRUD | _runCrudCallback | init callingParams = params: ${params.toString()}',
        );
      }
      Map<String, dynamic> callingParams = params;
      if (debugRunCrudCallback) {
        logDebug(
          'CRUD | _runCrudCallback | Adding current user data to params: ${currentUserData.toString()}',
        );
      }
      callingParams['currentUser'] = Map<String, dynamic>.from(currentUserData);
      if (debugRunCrudCallback) {
        logDebug(
          'CRUD | _runCrudCallback Before Loop'
          '\n | callingParams: ${callingParams.toString()}'
          '\n | editorConfig[funcType]: ${editorConfig[funcType].toString()}',
        );
      }

      // Run the callback functions
      String error = "";
      for (var callbackName in editorConfig[funcType]) {
        funcName = callbackName;
        if (!callbacks['specificFunctions'].containsKey(callbackName)) {
          if (debugRunCrudCallback) {
            logDebug(
              'CRUD | _runCrudCallback | [$funcType] | Processing: $callbackName...',
            );
          }
          error += "Not found Callback '$callbackName' in [$funcType]\n";
          continue;
        }
        if (debugRunCrudCallback) {
          logDebug(
            'CRUD | _runCrudCallback | [$funcType] | Starting: $callbackName...',
          );
        }
        Map<String, dynamic> callbackResult =
            await callbacks['specificFunctions'][callbackName]!(
              data,
              editorConfig,
              action,
              callingParams,
              context,
            );
        if (debugRunCrudCallback) {
          logDebug(
            'CRUD | _runCrudCallback | [$funcType] | $funcName | callbackResult: ${callbackResult.toString()}',
          );
        }
        responses.add(callbackResult);

        if (callbackResult['error'] == null ||
            callbackResult['error'].toString().isEmpty) {
          data = callbackResult['fieldValues'];
        }
      }

      finalResult = await reduceAllResponses(funcType, responses, data);

      if (error.isNotEmpty) {
        finalResult['error'] = error + finalResult['error'];
        finalResult['error_code'] = "FGCE-RCB-E010";
        await logError(
          'CRUD | _runCrudCallback [1] | ${finalResult['error']}',
          finalResult['error_code'],
        );
      }
    } catch (e, stackTrace) {
      finalResult['error'] =
          '[$funcType] | ${funcName.isNotEmpty ? funcName : 'Function Name Unknown'} | ERROR: $e';
      finalResult['error_code'] = "FGCE-RCB-E020";
      await logError(
        'CRUD | _runCrudCallback [2] | ${finalResult['error']} [${finalResult['error_code']}]'
        '\nError trace:\n${stackTrace.toString()}',
        finalResult['error_code'],
      );
    }

    return finalResult;
  }

  List<dynamic> _getColumns() {
    return editorConfig['fieldElements'].map((field) {
      if (!field.containsKey('listing') || field['listing'] == null) {
        field['listing'] = false;
      }
      if (!field.containsKey('required') || field['required'] == null) {
        field['required'] = false;
      }
      if (!field.containsKey('primaryKey') || field['primaryKey'] == null) {
        field['primaryKey'] = false;
        if (field['type'] == "_id") {
          field['primaryKey'] = true;
        }
      }
      if (field['primaryKey']) {
        field['readonly'] = true;
        editorConfig['primaryKeyName'] = field['name'];
      }
      return field;
    }).toList();
  }

  String rowId(Map<String, dynamic> row) {
    if (debugRunCrudCallback) {
      logDebug(
        'rowId | editorConfig[primaryKeyName]: ${editorConfig['primaryKeyName']} | row: ${row.toString()}',
      );
    }
    String response = getId(
      row.containsKey('_id') && getId(row['_id']).isNotEmpty
          ? row['_id']
          : row[editorConfig['primaryKeyName']],
    );
    if (debugRunCrudCallback) {
      logDebug('rowId | response: $response');
    }
    return response;
  }

  /*
    * Load items from the database and set the "items" widget variable.
    */
  Future<void> _loadItems() async {
    if (gceMainDebug) {
      logDebug('CRUD | (1) _loadItems | userId: $userId');
    }

    Map<String, dynamic> callbackResp = {};
    Map<String, dynamic> getParams = fixMapString(editorConfig['urlParams']);
    if (searchFilters.isNotEmpty) {
      searchFilters.forEach((key, value) {
        getParams[key] = value;
      });
    }

    // dbListPreRead: Before read data from database in the listing.
    // To set a Listing filters, assign funcResponse.fieldValues[db_field]=filter_value
    // Good place for hidden filters.
    callbackResp = await _runCrudCallback(
      'dbListPreRead',
      getParams,
      actionList,
      {},
    );
    if (callbackResp['error'] != "") {
      errorMessage = getApiErrorMessage('internalError');
      errorCode = callbackResp['error_code'] + "\n" + "FGCE-LI-E010";
      await logError(
        'CRUD | _loadItems | dbListPreRead | ERROR / callbackResp: ${callbackResp.toString()}',
        errorCode,
      );
      _setStateAndShowMessages();
      return;
    }

    if (gceMainDebug) {
      logDebug(
        'CRUD | _loadItems | dbListPreRead | SUCCESS / callbackResp: ${callbackResp.toString()}'
        '\n | endpointFilter: ${editorConfig['endpointFilter'].toString()}'
        '\n | fieldValues: ${callbackResp['fieldValues'].toString()}',
      );
    }

    getParams = Map<String, dynamic>.from({
      ...getParams,
      ...fixMapString(editorConfig['endpointFilter']),
      ...fixMapString(callbackResp['fieldValues']),
    });

    if (gceMainDebug) {
      logDebug('CRUD | _loadItems | getParams: ${getParams.toString()}');
    }

    // Read item list from database (API)
    Map<String, dynamic> body = {};
    final localApiResp = await _runApiCall(
      urlGenSuffix,
      'get',
      body,
      getParams,
    );
    if (localApiResp['error']) {
      if (gceMainDebug) {
        logDebug(
          'CRUD | _loadItems | ERROR / localApiResp: ${localApiResp.toString()}',
        );
      }
      errorMessage = localApiResp['error_message'];
      errorCode = "FGCE-LI-E020";
      if (gceMainDebug) {
        logDebug(
          'CRUD | (2) _loadItems | ERROR / localApiResp: ${localApiResp.toString()}',
        );
      }
      _setStateAndShowMessages();
      return;
    }

    try {
      // Load items from the API response
      items = json.decode(localApiResp['resultset']);
    } catch (e, stackTrace) {
      errorMessage = "Error loading items";
      errorCode = "FGCE-LI-E030";
      await logError(
        'CRUD | _loadItems | ERROR doing json.decode / localApiResp: ${localApiResp.toString()}'
        '\nError Trace:\n${stackTrace.toString()}',
        errorCode,
      );
      _setStateAndShowMessages();
      return;
    }

    List<dynamic> originalItems = List<dynamic>.from(items);

    if (gceMainDebug) {
      logDebug(
        'CRUD | (2) _loadItems | SUCCESS / localApiResp: ${localApiResp.toString()}',
      );
    }

    // dbListPostRead: After read data from database in the listing.
    callbackResp = await _runCrudCallback(
      'dbListPostRead',
      items,
      actionList,
      {},
    );
    if (callbackResp['error'] != "") {
      errorMessage = getApiErrorMessage('internalError');
      errorCode = callbackResp['error_code'] + "\n" + "FGCE-LI-E040";
      await logError(
        'CRUD | _loadItems | dbListPostRead | ERROR / callbackResp: ${callbackResp.toString()}',
        errorCode,
      );
      _setStateAndShowMessages();
      return;
    }

    if (gceMainDebug) {
      logDebug(
        'CRUD | _loadItems | dbListPostRead | SUCCESS / callbackResp: ${callbackResp.toString()}',
      );
    }

    try {
      items = List<dynamic>.from(callbackResp['fieldValues']);
    } catch (e, stackTrace) {
      errorMessage = "Error loading items";
      errorCode = "FGCE-LI-E050";
      await logError(
        'CRUD | _loadItems | ERROR doing List<dynamic>.from / callbackResp: $callbackResp'
        '\nError Trace:\n${stackTrace.toString()}',
        errorCode,
      );
      items = originalItems;
      _setStateAndShowMessages();
      return;
    }

    isEditMode =
        isCreationForced ||
        isEditModeForced ||
        (editorConfig['createReenter'] && isCreation);
    isCreation = isCreationForced;

    _setStateAndShowMessages();
  }

  /*
    * Load SELECTED item from the database and set the "item" widget variable.
    */
  Future<Map<String, dynamic>> _loadSelectedItem(String itemId) async {
    if (gceMainDebug) {
      logDebug(
        'CRUD | (1) _loadSelectedItem | userId: $userId | itemId: $itemId',
      );
    }

    Map<String, dynamic> callbackResp = {};
    Map<String, dynamic> getParams = fixMapString(editorConfig['urlParams']);

    getParams[editorConfig['primaryKeyName']] = itemId;

    // dbPreRead: Before read data from database.
    // If any error, shows the error message.
    callbackResp = await _runCrudCallback(
      'dbPreRead',
      getParams,
      isCreation ? actionCreate : actionUpdate,
      {},
    );
    if (callbackResp['error'] != "") {
      errorMessage = getApiErrorMessage('internalError');
      errorCode = callbackResp['error_code'] + "\n" + "FGCE-LSI-E010";
      await logError(
        'CRUD | _loadSelectedItem | dbPreRead | ERROR / callbackResp: $callbackResp',
        errorCode,
      );
      _setStateAndShowMessages();
      return {};
    }

    if (gceMainDebug) {
      logDebug(
        'CRUD | _loadSelectedItem | dbPreRead | SUCCESS / callbackResp: $callbackResp'
        ' | endpointFilter: ${editorConfig['endpointFilter']}'
        ' | fieldValues: ${callbackResp['fieldValues']}',
      );
    }

    getParams = Map<String, dynamic>.from({
      ...getParams,
      ...fixMapString(editorConfig['endpointFilter']),
      ...fixMapString(callbackResp['fieldValues']),
    });

    // Read item from database (API)
    Map<String, dynamic> body = {};
    final localApiResp = await _runApiCall(
      urlGenSuffix,
      'get',
      body,
      getParams,
    );
    if (localApiResp['error']) {
      errorMessage = localApiResp['error_message'];
      errorCode = "FGCE-LSI-E020";
      if (gceMainDebug) {
        logDebug(
          'CRUD | (2) _loadSelectedItem | ERROR / localApiResp: $localApiResp',
        );
      }
      _setStateAndShowMessages();
      return {};
    }

    // Load item from the API response
    Map<String, dynamic> itemData = json.decode(localApiResp['resultset']);
    isEditMode = editorConfig['createReenter'] && isCreation ? true : false;
    isCreation = false;
    if (gceMainDebug) {
      logDebug(
        'CRUD | (2) _loadSelectedItem | SUCCESS / localApiResp: $localApiResp',
      );
    }

    // dbPostRead: After read data from database in formData.
    // If any error, shows the error message and stay in the listing.
    callbackResp = await _runCrudCallback(
      'dbPostRead',
      itemData,
      isCreation ? actionCreate : actionUpdate,
      {},
    );
    if (callbackResp['error'] != "") {
      errorMessage = getApiErrorMessage('internalError');
      errorCode = callbackResp['error_code'] + "\n" + "FGCE-LSI-E030";
      await logError(
        'CRUD | _loadSelectedItem | dbPostRead | ERROR / callbackResp: $callbackResp',
        errorCode,
      );
      _setStateAndShowMessages();
      return {};
    }

    itemData = callbackResp['fieldValues'];

    // dbPreValidations: Validate data before show the Data Form.
    // If any error, shows the error message and prevents edition of the Data Form or deletion of the row.
    callbackResp = await _runCrudCallback(
      'dbPreValidations',
      itemData,
      isCreation ? actionCreate : actionUpdate,
      {},
    );
    if (callbackResp['error'] != "") {
      errorMessage = getApiErrorMessage('internalError');
      errorCode = callbackResp['error_code'] + "\n" + "FGCE-LSI-E040";
      await logError(
        'CRUD | _loadSelectedItem | dbPreValidations | ERROR / callbackResp: $callbackResp',
        errorCode,
      );
      _setStateAndShowMessages();
      return {};
    }

    itemData = callbackResp['fieldValues'];
    isEditMode = true;

    return itemData;
  }

  /*
   * Save item to the database
   */
  Future<void> _saveItem(Map<String, dynamic> item) async {
    if (gceMainDebug) {
      logDebug(
        'CRUD | _saveItem | isCreation: $isCreation | isCreationForced: $isCreationForced | item: $item',
      );
    }

    List<dynamic> originalItems = List<dynamic>.from(items);

    if (isCreation || isCreationForced) {
      isCreation = true;
      if (item.containsKey('id')) {
        item.remove('id');
      }
      if (item.containsKey('_id')) {
        item.remove('_id');
      }
      if (item.containsKey('user_id') &&
          (item['user_id'] == null || item['user_id'] == '')) {
        item['user_id'] = userId;
      }
      if (gceMainDebug) {
        logDebug('>> CRUD | _saveItem | isCreation | item: $item');
      }
    } else {
      convertObjectId(item);
    }

    Map<String, dynamic> callbackResp = {};

    // validations: FormData field values validation before write to the database.
    // If any error, shows the error message, prevents the database write and stays in FormData.
    callbackResp = await _runCrudCallback(
      'validations',
      item,
      isCreation ? actionCreate : actionUpdate,
      {},
    );
    if (callbackResp['error'] != "") {
      errorMessage = getApiErrorMessage('internalError');
      errorCode = callbackResp['error_code'] + "\n" + "FGCE-SI-E010";
      await logError(
        'CRUD | _saveItem | validations | ERROR / callbackResp: $callbackResp',
        errorCode,
      );
      _setStateAndShowMessages();
      return;
    }

    // dbPreWrite: Before write to database, after a successfull validation.
    // If any error, shows the error message, prevents the database write and stays in FormData.
    callbackResp = await _runCrudCallback(
      'dbPreWrite',
      item,
      isCreation ? actionCreate : actionUpdate,
      {},
    );
    if (callbackResp['error'] != "") {
      errorMessage = getApiErrorMessage('internalError');
      errorCode = callbackResp['error_code'] + "\n" + "FGCE-SI-E020";
      await logError(
        'CRUD | _saveItem | dbPreWrite | ERROR / callbackResp: $callbackResp',
        errorCode,
      );
      _setStateAndShowMessages();
      return;
    }

    item = {...item, ...callbackResp['fieldValues']};

    final localApiResp = await _runApiCall(
      urlGenSuffix,
      (isCreation ? 'post' : 'put'),
      item,
      {},
    );
    if (gceMainDebug) {
      logDebug('CRUD | _saveItem | localApiResp: $localApiResp');
    }
    if (localApiResp['error']) {
      items = originalItems;
      errorMessage = localApiResp['error_message'];
      errorCode = "FGCE-SI-E030";
      await logError(
        'CRUD | _saveItem | ERROR / localApiResp: $localApiResp',
        errorCode,
      );
      _setStateAndShowMessages();
      return;
    }

    // If no rows were updated, show error
    if (int.parse(localApiResp['resultset']['rows_affected']) < 1) {
      items = originalItems;
      errorMessage =
          "${localApiResp['resultset']['rows_affected']} rows updated";
      errorCode = "FGCE-SI-E040";
      _setStateAndShowMessages();
      return;
    }

    // Update item id with the one returned by the API
    item['id'] = localApiResp['resultset']['_id'];

    // dbPostWrite: After a successful write to database.
    // If any error, shows the error message and stays in FormData.
    callbackResp = await _runCrudCallback(
      'dbPostWrite',
      item,
      isCreation ? actionCreate : actionUpdate,
      {},
    );
    if (callbackResp['error'] != "") {
      items = originalItems;
      errorMessage = getApiErrorMessage('internalError');
      errorCode = callbackResp['error_code'] + "\n" + "FGCE-SI-E050";
      await logError(
        'CRUD | _saveItem | dbPostWrite | ERROR / callbackResp: $callbackResp',
        errorCode,
      );
      _setStateAndShowMessages();
      return;
    }

    // Return to the listing
    infoMessage =
        "${localApiResp['resultset']['rows_affected']} item(s) ${isCreation ? 'created' : 'updated'}";
    if (gceMainDebug) {
      logDebug('CRUD | _saveItem | SUCCESS / localApiResp: $localApiResp');
    }

    if (isCreationForced) {
      _setStateAndShowMessages();
      await _goBack();
      return;
    }

    if (isCreation && editorConfig['createReenter']) {
      // Stay in FormData
      return;
    }

    // Go to the listing
    return _loadItems();
  }

  /*
   * Delete item from the database
   */
  Future<void> _deleteItem(String itemId) async {
    if (gceMainDebug) {
      logDebug('CRUD | _deleteItem | itemId: $itemId');
    }

    Map<String, dynamic> callbackResp = {};

    // validations: FormData field values validation before write to the database.
    // If any error, prevents the database write and stays in FormData.
    callbackResp = await _runCrudCallback(
      'validations',
      selectedItem,
      actionDelete,
      {},
    );
    if (callbackResp['error'] != "") {
      errorMessage = getApiErrorMessage('internalError');
      errorCode = callbackResp['error_code'] + "\n" + "FGCE-DI-E010";
      await logError(
        'CRUD | _deleteItem | validations | ERROR / callbackResp: $callbackResp',
        errorCode,
      );
      _setStateAndShowMessages();
      return;
    }

    // dbPreWrite: Before write to database, after a successfull validation.
    // If any error, shows the error message, prevents the database write and stays in FormData.
    callbackResp = await _runCrudCallback(
      'dbPreWrite',
      selectedItem,
      actionDelete,
      {},
    );
    if (callbackResp['error'] != "") {
      errorMessage = getApiErrorMessage('internalError');
      errorCode = callbackResp['error_code'] + "\n" + "FGCE-DI-E020";
      await logError(
        'CRUD | _deleteItem | dbPreWrite | ERROR / callbackResp: $callbackResp',
        errorCode,
      );
      _setStateAndShowMessages();
      return;
    }

    // Delete item from database (API)
    Map<String, dynamic> body = {'id': itemId};
    Map<String, dynamic> getParams = {'id': itemId};
    final localApiResp = await _runApiCall(
      urlGenSuffix,
      'delete',
      body,
      getParams,
    );
    if (localApiResp['error']) {
      errorMessage = localApiResp['error_message'];
      errorCode = "FGCE-DI-E020";
      _setStateAndShowMessages();
      return;
    }

    // dbPostWrite: After a successful write to database.
    // If any error, shows the error message in the listing.
    callbackResp = await _runCrudCallback(
      'dbPostWrite',
      selectedItem,
      actionDelete,
      {},
    );
    if (callbackResp['error'] != "") {
      errorMessage = getApiErrorMessage('internalError');
      errorCode = callbackResp['error_code'] + "\n" + "FGCE-DI-E030";
      await logError(
        'CRUD | _deleteItem | dbPostWrite | ERROR / callbackResp: $callbackResp',
        errorCode,
      );
      isEditMode = false;
      _setStateAndShowMessages();
      return;
    }

    // Return to the listing
    if (gceMainDebug) {
      logDebug('CRUD | _deleteItem | localApiResp: $localApiResp');
    }
    infoMessage =
        "${localApiResp['resultset']['rows_affected']} item(s) deleted";
    if (gceMainDebug) {
      logDebug('CRUD | _deleteItem | SUCCESS / localApiResp: $localApiResp');
    }
    return _loadItems();
  }

  /*
   * Show the delete confirmation dialog
   */
  void _showDeleteConfirmation(String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(itemId);
              },
            ),
          ],
        );
      },
    );
  }

  /*
   * Get the first column name from the editor config
   */
  String _getColumnName(int col) {
    if (col >= listingFieldElements.length) {
      return '';
    }
    String name = listingFieldElements[col]['name'];
    return name;
  }

  String _buildListingLine(
    Map<String, dynamic> item,
    int colStart,
    int colEnd,
  ) {
    String line = '';
    for (int i = colStart; i < colEnd + 1; i++) {
      line += '${item[_getColumnName(i)]} ';
    }
    return line.trim();
  }

  /*
   * Build a listing item
   */
  Widget _buildListItem(BuildContext context, int index) {
    var item = items[index];
    String title = _buildListingLine(item, 0, colsForListingLine1 - 1);
    String subtitle = colsForListingLine2 > 0
        ? _buildListingLine(
            item,
            colsForListingLine1,
            colsForListingLine1 + colsForListingLine2 - 1,
          )
        : "";

    if (gceMainDebug) {
      logDebug(
        'CRUD | _buildListItem | title: $title, subtitle: $subtitle | item: $item',
      );
    }
    return ListTile(
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      onTap: () => {
        _loadSelectedItem(rowId(item)).then((value) {
          selectedItem = value;
          _setStateAndShowMessages();
        }),
      },
    );
  }

  Future<void> _goBack() {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => widget.backButtonAction!()),
    );
  }

  /*
   * Build the listing screen
   */
  Widget _buildList() {
    if (gceMainDebug) {
      logDebug(
        'CRUD | _buildList | isCreationForced: $isCreationForced'
        ' | selectedItem: $selectedItem | items: $items',
      );
    }
    if (widget.backButtonAction != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => _goBack(),
          ),
          title: Text(
            selectedItem == null
                ? ''
                : _buildListingLine(selectedItem, 0, colsForListingLine1 - 1),
          ),
        ),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: _buildListItem,
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: _buildListItem,
    );
  }

  void _setEditMode(bool newEditMode) {
    setState(() {
      isEditMode = newEditMode;
    });
  }

  Future<void> _dialogBuilder(BuildContext context, Map<String, dynamic> data) {
    logDebug('CRUD | _dialogBuilder | data: $data');
    String message = "";
    for (var value in List<String>.from(data['messages'])) {
      message = "$message\n$value";
    }
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(data['title']),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _setError(String message, String code, [int severity = 0]) {
    if (gceMainDebug) {
      logDebug('CRUD | _setError | message: $message, code: $code');
    }
    if (severity == severityHigh) {
      _dialogBuilder(context, {
        "title": "Error",
        "messages": [message, code],
      });
    } else {
      errorMessage = message;
      errorCode = code;
      if (severity == severityLow) {
        // Show error message without waiting for OK
        errorWaitForOk = false;
      }
      setState(() {});
    }
  }

  /*
   * Build the data form
   */
  Widget _buildDataForm() {
    return Scaffold(
      appBar: AppBar(
        // leading: const SizedBox.shrink(),
        leading: !showAppMenu
            ? const SizedBox.shrink()
            : IconButton(
                icon: Icon(
                  widget.backButtonAction == null
                      ? Icons.arrow_back_ios
                      : Icons.arrow_back,
                ),
                onPressed: () {
                  if (widget.backButtonAction != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => widget.backButtonAction!(),
                      ),
                    );
                  } else {
                    _setEditMode(false);
                  }
                },
              ),
        title: Text(
          _buildListingLine(selectedItem, 0, colsForListingLine1 - 1),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'delete') {
                _showDeleteConfirmation(getId(selectedItem['_id']));
              } else if (result == 'save') {
                _saveItem(selectedItem);
              }
            },
            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry<String>> menuItems = [];
              if (widget.backButtonAction == null) {
                menuItems.add(
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                );
              }
              menuItems.add(
                const PopupMenuItem<String>(value: 'save', child: Text('Save')),
              );
              return menuItems;
            },
          ),
        ],
      ),
      body: DataFormBody(
        action: isCreation ? actionCreate : actionUpdate,
        editorConfig: editorConfig,
        constants: constants,
        currentUserData: currentUserData,
        callbacks: callbacks,
        selectedItem: selectedItem,
        saveItem: _saveItem,
        setEditMode: _setEditMode,
        setError: _setError,
        props: widget.props,
      ),
    );
  }

  /*
   * Initialize the state
   */
  @override
  void initState() {
    super.initState();
    errorMessage = "";
    errorCode = "";
    _loadConfig().then((result) {
      if (result == false) {
        if (errorMessage.isEmpty) {
          errorMessage = "Session expired. Please log in again.";
          errorCode = "FGCE-IS-E010";
        }
        _setStateAndShowMessages();
        return false;
      }
      return true;
    });
  }

  /*
   * Update the state
   */
  @override
  void didUpdateWidget(covariant CrudEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleBindings();
  }

  /*
   * Build the Widget
   */
  @override
  Widget build(BuildContext context) {
    if (gceMainDebug) {
      logDebug(
        '${widget.jsonFileName} | build |'
        '\n selectedItem: $selectedItem'
        '\n isEditMode: $isEditMode'
        '\n isEditModeForced: $isEditModeForced'
        '\n isCreation: $isCreation'
        '\n isCreationForced: $isCreationForced'
        '\n _isLoading: $_isLoading'
        '\n errorMessage: $errorMessage'
        '\n errorCode: $errorCode',
      );
    }
    return AppFrame(
      showAppMenu: showAppMenu,
      showBackButton:
          !showAppMenu && (widget.backButtonAction != null || isEditMode),
      action: widget.backButtonAction == null
          ? isEditMode
                ? () => _setEditMode(false)
                : null
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => widget.backButtonAction!(),
              ),
            ),
      appCallables: widget.appCallables,
      title: editorConfig.isNotEmpty && editorConfig.containsKey('title')
          ? editorConfig['title']
          : "",
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isEditMode || isCreationForced
          ? _buildDataForm()
          : _buildList(),
      floatingActionButton: isEditMode || isCreationForced
          ? null
          : FloatingActionButton(
              onPressed: () => setState(() {
                isEditMode = true;
                isCreation = true;
                selectedItem = _getEmptyItem();
              }),
              child: const Icon(Icons.add),
            ),
    );
  }
}
