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
                        List<String>.from(
                            widget.labels.values.elementAt(i)[1] as List<dynamic>),
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
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black),
            filled: true,
            fillColor: Colors.white.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
          ),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
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
            Text(label, style: const TextStyle(fontSize: 16)),
            ...options.map((option) {
              return CheckboxListTile(
                title: Text(option),
                value: controller.text.contains(option),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      controller.text += '$option;';
                    } else {
                      controller.text = controller.text.replaceAll('$option;', '');
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
            Text(label, style: const TextStyle(fontSize: 16)),
            ...options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
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
            labelStyle: const TextStyle(color: Colors.black),
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

