import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'autocomplete_service.dart';
import 'select_options_service.dart';
import 'utilities.dart';

const gceFsDebug = false;
const useScrollableTextField = false;

class ScrollableTextField extends StatefulWidget {
  final Map<String, dynamic> config;
  final String value;
  final Function onSaved;

  const ScrollableTextField({
    Key? key,
    required this.config,
    required this.value,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<ScrollableTextField> createState() => _ScrollableTextFieldState();
}

class _ScrollableTextFieldState extends State<ScrollableTextField> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool required = widget.config['required'] ?? false;
    bool readOnly = widget.config['readonly'] ?? false;
    return Column(
      children: [
        Text(widget.config['label']),
        const SizedBox(height: 10),
        Expanded(
          // Constrains the height for scrolling
          child: Scrollbar(
            // Optional: Adds a visible scroll handle
            controller: _scrollController,
            thumbVisibility: true, // Forces scrollbar to always show (optional)
            child: TextFormField(
              key: ValueKey(widget.config['name']),
              controller: _textController,
              scrollController: _scrollController,
              keyboardType: TextInputType.multiline,
              readOnly: readOnly,
              maxLines:
                  null, // Allows indefinite vertical expansion until the parent constraint is hit
              decoration: const InputDecoration(
                // hintText: 'Start typing here...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (required &&
                    (value == null || value.isEmpty || value.trim().isEmpty)) {
                  return 'This field is required';
                }
                if (value == null) {
                  return 'Please enter a valid text';
                }
                return null;
              },
              onSaved: (value) => widget.onSaved(value!),
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordField extends StatefulWidget {
  final Map<String, dynamic> config;
  final String value;
  final Function onSaved;

  const PasswordField({
    Key? key,
    required this.config,
    required this.value,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  String _value = '';

  @override
  void initState() {
    super.initState();
    if (gceFsDebug) {
      logDebug(
        ">> INIT fieldName: ${widget.config['name']} | _value: ${widget.value}",
      );
    }
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    String fieldName = widget.config['name'];
    return TextFormField(
      key: ValueKey(fieldName),
      obscureText: _obscureText,
      controller: TextEditingController(text: _value),
      decoration: InputDecoration(
        labelText: widget.config['label'],
        // border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            // Update the state to show or hide the password
            if (gceFsDebug) {
              logDebug(
                ">> fieldName: $fieldName | _obscureText: $_obscureText | _value: $_value",
              );
            }
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      readOnly: widget.config['readonly'] ?? false,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (widget.config['required'] &&
            (value == null || value.isEmpty || value.trim().isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
      onChanged: (value) {
        _value = value;
        widget.onSaved(value);
      },
    );
  }
}

class DataFormBody extends StatefulWidget {
  final FlutterSecureStorage storage;
  final Map<String, dynamic> editorConfig;
  final Map<String, dynamic> constants;
  final Map<String, dynamic> selectedItem;
  final Map<String, dynamic> callbacks;
  final Map<String, dynamic> currentUserData;
  final String action;
  final Function saveItem;
  final Function setEditMode;
  final Function setError;
  final Map<String, dynamic>? props;

  const DataFormBody({
    Key? key,
    required this.storage,
    required this.editorConfig,
    required this.constants,
    required this.selectedItem,
    required this.callbacks,
    required this.currentUserData,
    required this.action,
    required this.saveItem,
    required this.setEditMode,
    required this.setError,
    this.props = const {},
  }) : super(key: key);

  @override
  State<DataFormBody> createState() => _DataFormBodyState();
}

class _DataFormBodyState extends State<DataFormBody> {
  Future _selectDate(String value, Function onSaved) async {
    DateTime initialValue;
    try {
      initialValue = DateTime.parse(value);
    } catch (e) {
      initialValue = DateTime.now().subtract(const Duration(days: 365 * 10));
    }
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialValue,
      firstDate: DateTime(1900),
      lastDate: DateTime(DateTime.now().year, 12, 31),
    );
    if (picked != null) {
      setState(() {
        String cleanedValue = picked.toString().split(
          ' ',
        )[0]; // Remove time part
        onSaved(cleanedValue);
      });
    }
  }

  Widget _erroredComponentWidget(String label, String text, String fieldName) {
    return TextFormField(
      key: ValueKey(fieldName),
      controller: TextEditingController(text: text),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.red,
        labelStyle: const TextStyle(color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white),
      readOnly: true,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      minLines: 2,
    );
  }

  /*
   * Build the data form body
   */
  Widget _buildDataFormBody() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    List<Widget> formFields = [];

    for (var fieldElement in widget.editorConfig['fieldElements']) {
      if (gceFsDebug) {
        logDebug("_buildDataFormBody | Field Element: $fieldElement");
      }

      bool required = fieldElement['required'] ?? false;
      bool readOnly = fieldElement['readonly'] ?? false;
      bool hidden = fieldElement['hidden'] ?? false;
      String defaultValue = fieldElement['default_value'] ?? '';
      String fieldName = fieldElement['name'];
      String fieldElementValue = getValueToEdit(
        widget.selectedItem[fieldName],
        defaultValue,
        widget.currentUserData,
      );

      if (hidden || fieldElement['type'] == '_id') {
        continue;
      }

      switch (fieldElement['type']) {
        case 'label':
          formFields.add(
            Text(
              fieldElement['label'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
          break;

        case 'h1':
        case 'h2':
        case 'h3':
        case 'h4':
        case 'h5':
        case 'h6':
          formFields.add(
            Text(
              fieldElement['label'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fieldElement['type'] == 'h1'
                    ? 22
                    : fieldElement['type'] == 'h2'
                    ? 20
                    : fieldElement['type'] == 'h3'
                    ? 18
                    : fieldElement['type'] == 'h4'
                    ? 16
                    : fieldElement['type'] == 'h5'
                    ? 14
                    : fieldElement['type'] == 'h6'
                    ? 12
                    : 10,
              ),
            ),
          );
          break;

        case 'hr':
          formFields.add(const Text(''));
          formFields.add(const Divider(thickness: 3, color: Colors.grey));
          formFields.add(const Text(''));
          break;

        case 'number':
          formFields.add(
            TextFormField(
              key: ValueKey(fieldName),
              controller: TextEditingController(text: fieldElementValue),
              decoration: InputDecoration(
                labelText: fieldElement['label'],
                // border: const OutlineInputBorder(),
              ),
              readOnly: readOnly,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                // Allows digits and a single decimal point
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (required &&
                    (value == null || value.isEmpty || value.trim().isEmpty)) {
                  return 'This field is required';
                }
                if (value != null && double.tryParse(value) == null) {
                  return 'Please enter a valid number (decimal)';
                }
                return null;
              },
              onChanged: (value) {
                widget.selectedItem[fieldName] = double.parse(value);
              },
              onSaved: (value) =>
                  widget.selectedItem[fieldName] = double.parse(value!),
            ),
          );
          break;

        case 'integer':
          formFields.add(
            TextFormField(
              key: ValueKey(fieldName),
              controller: TextEditingController(text: fieldElementValue),
              decoration: InputDecoration(
                labelText: fieldElement['label'],
                // border: const OutlineInputBorder(),
              ),
              readOnly: readOnly,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // Only allow digits 0-9
              ],
              validator: (value) {
                if (required &&
                    (value == null || value.isEmpty || value.trim().isEmpty)) {
                  return 'This field is required';
                }
                if (value != null && int.tryParse(value) == null) {
                  return 'Please enter a valid number (integer)';
                }
                return null;
              },
              onChanged: (value) {
                widget.selectedItem[fieldName] = int.parse(value);
              },
              onSaved: (value) =>
                  widget.selectedItem[fieldName] = int.parse(value!),
            ),
          );
          break;

        case 'date':
        case 'datetime-local':
          formFields.add(
            TextFormField(
              key: ValueKey(fieldName),
              controller: TextEditingController(text: fieldElementValue),
              decoration: InputDecoration(
                labelText: fieldElement['label'],
                // border: const OutlineInputBorder(),
              ),
              readOnly: readOnly,
              keyboardType: TextInputType.datetime,
              validator: (value) {
                if (required &&
                    (value == null || value.isEmpty || value.trim().isEmpty)) {
                  return 'This field is required';
                }
                if (value != null && DateTime.tryParse(value) == null) {
                  return 'Please enter a valid date';
                }
                return null;
              },
              onChanged: (value) {
                widget.selectedItem[fieldName] = value;
              },
              onTap: () => _selectDate(
                fieldElementValue,
                (value) => widget.selectedItem[fieldName] = value,
              ),
            ),
          );
          break;

        case 'textarea':
          formFields.add(
            useScrollableTextField
                ? ScrollableTextField(
                    config: fieldElement,
                    value: fieldElementValue,
                    onSaved: (value) => widget.selectedItem[fieldName] = value!,
                  )
                : TextFormField(
                    key: ValueKey(fieldName),
                    controller: TextEditingController(text: fieldElementValue),
                    decoration: InputDecoration(
                      labelText: fieldElement['label'],
                      // border: const OutlineInputBorder(),
                    ),
                    readOnly: readOnly,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 2,
                    validator: (value) {
                      if (required &&
                          (value == null ||
                              value.isEmpty ||
                              value.trim().isEmpty)) {
                        return 'This field is required';
                      }
                      if (value == null) {
                        return 'Please enter a valid text';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      widget.selectedItem[fieldName] = value;
                    },
                    onSaved: (value) => widget.selectedItem[fieldName] = value!,
                  ),
          );
          break;

        case 'select':
          Map<String, dynamic> selectElements = Map<String, dynamic>.from(
            widget.constants[fieldElement['select_elements']],
          );
          if (gceFsDebug) {
            logDebug(
              "select | Select Elements: $selectElements | Field Element Value: $fieldElementValue",
            );
          }
          if (readOnly) {
            formFields.add(
              TextFormField(
                key: ValueKey(fieldName),
                controller: TextEditingController(
                  text: getSelectOptionLabel(selectElements, fieldElementValue),
                ),
                decoration: InputDecoration(
                  labelText: fieldElement['label'],
                  // border: const OutlineInputBorder(),
                ),
                readOnly: true,
              ),
            );
            continue;
          } else {
            formFields.add(
              DropdownButtonFormField<String>(
                key: ValueKey(fieldName),
                isExpanded: true,
                value: fieldElementValue,
                decoration: InputDecoration(
                  labelText: fieldElement['label'],
                  // border: const OutlineInputBorder(),
                ),
                items: putSelectOptionsFromArray(
                  selectElements: selectElements,
                ),
                onChanged: (value) {
                  widget.selectedItem[fieldName] = value!;
                },
                onSaved: (value) => widget.selectedItem[fieldName] = value!,
              ),
            );
          }
          break;

        case 'select_component':
          Map<String, dynamic> selectElements = widget
              .editorConfig['selectFieldsOptionsPromises'][fieldElement['component']]['promiseResult'];
          if (readOnly) {
            formFields.add(
              TextFormField(
                key: ValueKey(fieldName),
                controller: TextEditingController(
                  text: getSelectOptionLabel(selectElements, fieldElementValue),
                ),
                decoration: InputDecoration(
                  labelText: fieldElement['label'],
                  // border: const OutlineInputBorder(),
                ),
                readOnly: true,
              ),
            );
          } else {
            formFields.add(
              DropdownButtonFormField<String>(
                key: ValueKey(fieldName),
                value: fieldElementValue,
                decoration: InputDecoration(
                  labelText: fieldElement['label'],
                  // border: const OutlineInputBorder(),
                ),
                items: putSelectOptionsFromArray(
                  selectElements: selectElements,
                ),
                onSaved: (value) => widget.selectedItem[fieldName] = value!,
                onChanged: (value) {
                  widget.selectedItem[fieldName] = value!;
                },
              ),
            );
          }
          break;

        case 'component':
          Widget componentWidget;
          final componentCallbacks =
              widget.callbacks['components'] ?? widget.callbacks['component'];

          if (componentCallbacks != null &&
              componentCallbacks[fieldElement['component']] != null) {
            final dynamic componentResult =
                componentCallbacks[fieldElement['component']](
                  action: widget.action,
                  config: fieldElement,
                  value: fieldElementValue,
                  onChanged: (value) => widget.selectedItem[fieldName] = value!,
                  props: widget.props,
                );

            if (componentResult is TextEditingController) {
              componentWidget = TextFormField(
                key: ValueKey(fieldName),
                controller: componentResult,
                decoration: InputDecoration(labelText: fieldElement['label']),
                readOnly: readOnly,
                keyboardType: TextInputType.text,
              );
            } else if (componentResult is Widget) {
              componentWidget = componentResult;
            } else {
              componentWidget = _erroredComponentWidget(
                fieldElement['label'],
                "Component [${fieldElement['component']}] returned an invalid type: ${componentResult.runtimeType}",
                fieldName,
              );
            }
          } else {
            componentWidget = _erroredComponentWidget(
              fieldElement['label'],
              "Component [${fieldElement['component']}] Not Found",
              fieldName,
            );
          }
          formFields.add(componentWidget);
          break;

        case 'suggestion_dropdown':
          formFields.add(
            SuggestionDropdown(
              storage: widget.storage,
              config: fieldElement,
              value: fieldElementValue,
              onSelected: (value) {
                Map<String, dynamic> valueMap = Map<String, dynamic>.from(
                  jsonDecode(value),
                );
                if (valueMap.isNotEmpty) {
                  if (valueMap[fieldElement['suggestion_desc_fieldname']]
                      .isNotEmpty) {
                    for (var field in valueMap.keys) {
                      widget.selectedItem[field] = valueMap[field];
                    }
                  }
                }
              },
              setError: (value, code, waitForOk) {
                widget.setError(value, code, waitForOk);
              },
            ),
          );
          break;

        case 'password':
          formFields.add(
            PasswordField(
              config: fieldElement,
              value: fieldElementValue,
              onSaved: (value) {
                widget.selectedItem[fieldName] = value!;
              },
            ),
          );
          break;

        default:
          formFields.add(
            TextFormField(
              key: ValueKey(fieldName),
              controller: TextEditingController(text: fieldElementValue),
              decoration: InputDecoration(
                labelText: fieldElement['label'],
                // border: const OutlineInputBorder(),
              ),
              readOnly: readOnly,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (required &&
                    (value == null || value.isEmpty || value.trim().isEmpty)) {
                  return 'This field is required';
                }
                if (value == null) {
                  return 'Please enter a valid text';
                }
                if (fieldElement['type'] == 'email' && !value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              onChanged: (value) {
                widget.selectedItem[fieldName] = value;
              },
              onSaved: (value) => widget.selectedItem[fieldName] = value!,
            ),
          );
          break;
      }
    }

    formFields.add(const SizedBox(height: 20));

    formFields.add(
      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  widget.saveItem(widget.selectedItem);
                }
              },
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                widget.setEditMode(false);
              },
            ),
          ],
        ),
      ),
    );

    return Form(
      key: formKey,
      child: ListView(
        controller: ScrollController(),
        padding: const EdgeInsets.all(8.0),
        children: formFields,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildDataFormBody();
  }
}
