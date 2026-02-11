import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genericsuite/services/app_callables_super.dart';

import '../services/http_service.dart';
import '../services/message_service.dart';
// import '../services/theme_config.dart';
import '../services/utilities.dart';

const apDrwDebug = false;

const acceptedUserGroups = ['users'];
const defaultUserGroup = 'users';

class AppDrawer extends StatefulWidget {
  // final FlutterSecureStorage storage;
  final AppCallablesSuper appCallables;

  // const AppDrawer({Key? key, required this.storage, required this.appCallables})
  const AppDrawer({super.key, required this.appCallables});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String errorMessage = "";
  String errorCode = "";
  String infoMessage = "";
  bool _isLoading = false;
  bool _hamburgerMenuInLeftDrawer = true;

  Map<String, dynamic> configItems = {};
  String apiBaseUrl = '';
  List<Map<String, dynamic>> menuConfig = [];

  /*
   * Schedule bindings, to show error and info messages after the widget is built
   */
  void _scheduleBindings() {
    scheduleMessagesBindings(context, {
      'errorMessage': errorMessage,
      'errorCode': errorCode,
      'infoMessage': infoMessage,
    }, widget.appCallables);
    errorMessage = "";
    errorCode = "";
    infoMessage = "";
  }

  /*
   * Set the state and schedule show messages
   */
  void _setStateAndShowMessages() {
    setState(() {});
    _scheduleBindings();
  }

  String menuItemValidation(Map<String, dynamic> item) {
    if (!item.containsKey('title') || item['title'] == null) {
      // Items with no title are inconsistent
      return "";
    }
    if (!item.containsKey('location') || item['location'] == null) {
      item['location'] = "";
    }
    if (!item.containsKey('path') || item['path'] == null) {
      item['path'] = "";
    }
    if (!item.containsKey('on_click') || item['on_click'] == null) {
      item['on_click'] = "";
    }
    if (item['location'].isEmpty &&
        item['path'].isEmpty &&
        item['on_click'].isEmpty) {
      // Items with no location, path or on_click aren't menu items
      if (!item.containsKey('type') || item['type'] == null) {
        return "";
      }
      if (item['type'] != 'editor') {
        return "";
      }
    }
    if (!item.containsKey('sec_group') || item['sec_group'] == null) {
      item['sec_group'] = defaultUserGroup;
    }
    if (!acceptedUserGroups.contains(item['sec_group'])) {
      // Items with invalid sec_group ar not used in the app
      return "";
    }
    if (!item.containsKey('element')) {
      item['element'] = "";
    }
    if (!item.containsKey('function')) {
      item['function'] = "";
    }
    if (item['element']!.isEmpty &&
        item['on_click']!.isEmpty &&
        item['function']!.isEmpty) {
      // Items with no element or on_click aren't menu items or inconsistent
      return "";
    }
    return item['element']!.isEmpty ? item['on_click'] : item['element'];
  }

  /*
   * Load the widget configuration:
   * - Get the menu options executable functions (callables)
   * - Get the menu items from the JSON config file
   */
  Future<bool> _loadConfig() async {
    Map<String, dynamic> callables = widget.appCallables.getMenuCallables();
    if (apDrwDebug) {
      logDebug('Drawer | 1) loadconfig...');
    }
    String configFilename = "assets/config_dbdef/backend/app_main_menu.json";
    setState(() {
      _isLoading = true;
    });
    // return loadConfig(widget.storage).then((configStr) {
    return loadConfig().then((configStr) {
      return getJsonFileList(configFilename).then((menuConfigRaw) {
        Map<String, dynamic> config = json.decode(configStr);
        configItems = config["configItems"];
        _hamburgerMenuInLeftDrawer =
            config["hamburgerMenuInLeftDrawer"] ?? true;
        if (apDrwDebug) {
          logDebug(
            'Drawer | 0.1) Hamburger menu in left drawer: $_hamburgerMenuInLeftDrawer',
          );
        }
        List<Map<String, dynamic>> menuConfigAll = menuConfigRaw;
        menuConfig = [];
        for (var item in menuConfigAll) {
          item['element'] = menuItemValidation(item);
          if (item['element']!.isEmpty) {
            if (apDrwDebug) {
              logDebug(
                'Drawer | 1.1) Checking item because it doesn\'t have an element: ${item.toString()}',
              );
            }
            // Check why it doesn't have an element
            if (item.containsKey('type') && item['type'] == 'nav_dropdown') {
              // This is a navigation dropdown, check if the user has access to it
              if (item.containsKey('sec_group') &&
                  !acceptedUserGroups.contains(item['sec_group'])) {
                // Title with invalid sec_group or not used in the app is skipped
                if (apDrwDebug) {
                  logDebug(
                    'Drawer | 1.2) Skipped because sec_group invalid: ${item.toString()}',
                  );
                }
                continue;
              }
              // This is a title
              item['type'] = 'title';
              menuConfig.add(item);
            } else if (item.containsKey('location') &&
                item['location'] != null &&
                item['location'] == 'hamburger') {
              // This is a hamburger menu item...
              // It will be available in the right top drawer if _hamburgerMenuInLeftDrawer is false,
              // otherwise it will be available here
              if (!_hamburgerMenuInLeftDrawer) {
                if (apDrwDebug) {
                  logDebug(
                    'Drawer | 1.3) Skipped because it\'s the hamburger menu item: ${item.toString()}',
                  );
                }
                continue;
              }
              if (apDrwDebug) {
                logDebug(
                  'Drawer | 1.4) Added because it\'s the hamburger menu item: ${item.toString()}',
                );
              }
              item['type'] = 'title';
              menuConfig.add(item);
            } else {
              if (apDrwDebug) {
                logDebug(
                  'Drawer | 1.5) Skipped because it\'s not a valid menu item: ${item.toString()}',
                );
              }
              continue;
            }
          }
          if (item.containsKey('sub_menu_options') &&
              item['sub_menu_options'] != null) {
            for (var subItem in item['sub_menu_options']) {
              if (apDrwDebug) {
                logDebug('Drawer | 2.1) subItem: ${subItem.toString()}');
              }
              subItem['element'] = menuItemValidation(subItem);
              if (subItem['element']!.isEmpty) {
                if (apDrwDebug) {
                  logDebug(
                    'Drawer | 2.1.1) subItem no va pal baile: ${subItem.toString()}',
                  );
                }
                continue;
              }
              subItem['type'] = 'widget';
              subItem['callable'] = callables[subItem['element']];
              menuConfig.add(subItem);
              if (apDrwDebug) {
                logDebug(
                  'Drawer | 2.1.2) subItem added: ${subItem.toString()}',
                );
              }
            }
          } else {
            item['type'] = 'widget';
            item['callable'] = callables[item['element']];
            menuConfig.add(item);
            if (apDrwDebug) {
              logDebug('Drawer | 2.2) item added: ${item.toString()}');
            }
          }
        }
        if (apDrwDebug) {
          logDebug('Drawer | 3) menuConfig: ${menuConfig.toString()}');
        }
        return true;
      });
    });
  }

  /*
   * Initialize the widget state
   */
  @override
  void initState() {
    super.initState();
    errorMessage = "";
    errorCode = "";
    _loadConfig().then((result) {
      _isLoading = false;
      if (result == false) {
        if (errorMessage.isEmpty) {
          errorMessage = "Session expired. Please log in again.";
          errorCode = "AD-E010";
        }
        _setStateAndShowMessages();
        return false;
      }
      _setStateAndShowMessages();
      return true;
    });
  }

  /*
   * Update the state
   */
  @override
  void didUpdateWidget(covariant AppDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleBindings();
  }

  /*
   * Build the menu
   */
  List<Widget> _buildMenu() {
    List<Widget> menuItems = [];
    menuItems.add(
      DrawerHeader(
        decoration: BoxDecoration(
          color: widget.appCallables.getThemeParams()['drawerBackgroundColor'],
        ),
        child: Image.asset(
          'assets/images/app_logo_circle.png',
          height: 250,
          width: 250,
        ),
      ),
    );
    for (var item in menuConfig) {
      if (apDrwDebug) {
        logDebug('Drawer | Item will be shown: ${item.toString()}');
      }
      menuItems.add(
        ListTile(
          leading: item['type'] == 'title'
              ? null
              : Icon(item['callable']['icon']),
          title: Text(item['title']),
          onTap: () {
            if (item['type'] == 'widget' &&
                (item['callable']['widget'] != null ||
                    item['callable']['function'] != null)) {
              Navigator.pop(context); // Close the drawer
              if (item['callable']['function'] != null) {
                // item['callable']['function'](context, widget.storage);
                item['callable']['function'](context);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        // item['callable']['widget'](widget.storage),
                        item['callable']['widget'](),
                  ),
                );
              }
            } else {
              errorMessage = "${item['title']} is not implemented";
              errorCode = "AD-E020";
              Navigator.pop(context); // Close the drawer
              _setStateAndShowMessages();
            }
          },
        ),
      );
    }
    return menuItems;
  }

  /*
   * Build the Widget
   */
  @override
  Widget build(BuildContext context) {
    if (apDrwDebug) {
      logDebug('Drawer | Building widget');
    }
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: _isLoading
            ? const [Center(child: CircularProgressIndicator())]
            : _buildMenu(),
      ),
    );
  }
}
