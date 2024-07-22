import 'package:flutter/material.dart';
import 'package:meal_plan_app/src/imports/imports_widgets.dart';

class CustomForm extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<String> labels;
  final void Function()? onButtonPressed;
  final String buttonText;

  const CustomForm({
    required this.controllers,
    required this.labels,
    required this.onButtonPressed,
    required this.buttonText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < controllers.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: TextFormField(
              controller: controllers[i],
              decoration: InputDecoration(
                labelText: labels[i],
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: labels[i].toLowerCase().contains('senha'),
              keyboardType: labels[i] == 'Email'
                  ? TextInputType.emailAddress
                  : TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, preencha este campo';
                }
                if (labels[i] == 'Email' &&
                    !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Por favor, insira um email válido';
                }
                if (labels[i] == 'Senha' &&
                  !RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(value)) {
                return 'A senha deve conter pelo menos uma letra maiúscula, uma letra minúscula, um caractere especial e um número';
              }
                return null;
              },
            ),
          ),
        const SizedBox(height: 30),
        CustomButton(
          text: buttonText,
          onPressed: onButtonPressed,
        ),
      ],
    );
  }
}

class MultipleChoiceForm extends StatefulWidget {
  final List<TextEditingController> controllers;
  final Map<String, List<dynamic>> labels;
  final String buttonText;
  final void Function() onButtonPressed;

  const MultipleChoiceForm({
    required this.controllers,
    required this.labels,
    required this.buttonText,
    required this.onButtonPressed,
    super.key,
  });

  @override
  MultipleChoiceFormState createState() => MultipleChoiceFormState();
}

class MultipleChoiceFormState extends State<MultipleChoiceForm> {
  // Map to hold the selected value of each radio group
  final Map<String, String> _radioGroupValues = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  for (var i = 0; i < widget.labels.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: _buildQuestion(
                        widget.controllers[i],
                        widget.labels.keys.elementAt(i),
                        widget.labels.values.elementAt(i)[0] as String,
                        List<String>.from(widget.labels.values.elementAt(i)[1]
                            as List<dynamic>),
                      ),
                    ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        CustomButton(
          text: widget.buttonText,
          onPressed: widget.onButtonPressed,
        ),
      ],
    );
  }

  Widget _buildQuestion(
    TextEditingController controller,
    String label,
    String componentType,
    List<String> options,
  ) {
    switch (componentType) {
      case 'dropdown':
        return CustomDropdownButtonFormField(
          label: label,
          options: options,
          onChanged: (newValue) {
            setState(() {
              controller.text = newValue!;
            });
          },
        );
      case 'checkbox':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
            ...options.map((option) {
              return CheckboxListTile(
                title:
                    Text(option, style: const TextStyle(color: Colors.white)),
                value: controller.text.contains(option),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      controller.text += '$option;';
                    } else {
                      controller.text =
                          controller.text.replaceAll('$option;', '');
                    }
                  });
                },
              );
            }),
          ],
        );
      case 'radio':
        _radioGroupValues[label] ??= '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
            ...options.map((option) {
              return RadioListTile<String>(
                title:
                    Text(option, style: const TextStyle(color: Colors.white)),
                value: option,
                groupValue: _radioGroupValues[label],
                onChanged: (String? value) {
                  setState(() {
                    _radioGroupValues[label] = value!;
                    controller.text = value;
                  });
                },
              );
            }),
          ],
        );
      default:
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700),
            filled: true,
            fillColor: Colors.white.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
          ),
        );
    }
  }
}

class CustomDropdownButtonFormField extends StatefulWidget {
  final List<String> options;
  final String label;
  final ValueChanged<String?>? onChanged;

  const CustomDropdownButtonFormField({
    super.key,
    required this.options,
    required this.label,
    this.onChanged,
  });

  @override
  CustomDropdownButtonFormFieldState createState() =>
      CustomDropdownButtonFormFieldState();
}

class CustomDropdownButtonFormFieldState
    extends State<CustomDropdownButtonFormField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String? _selectedItem;

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8.0),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: widget.options
                  .map(
                    (option) => ListTile(
                      title: Text(option,
                          style: const TextStyle(color: Colors.black)),
                      onTap: () {
                        setState(() {
                          _selectedItem = option;
                        });
                        widget.onChanged?.call(option);
                        _toggleDropdown();
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700),
            filled: true,
            fillColor: Colors.white.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
          ),
          child: Text(
            _selectedItem ?? '',
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }
}
