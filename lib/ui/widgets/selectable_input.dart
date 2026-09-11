import '../core/app_theme.dart';
import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../utils/language_provider.dart';
import 'package:provider/provider.dart';

class SelectableInput extends StatefulWidget {
  final List<int> options;
  final ValueChanged<int?> onChanged; // return the selected value, or null
  final ValueChanged<bool>? onValidation; // return validation state
  final TextInputType keyboardType;
  final String labelText;
  final int? defaultValue;

  const SelectableInput({
    super.key,
    required this.options,
    required this.onChanged,
    this.onValidation,
    this.keyboardType = TextInputType.number,
    this.labelText = 'Enter value',
    this.defaultValue,
  });

  @override
  State<SelectableInput> createState() => _SelectableInputState();
}

class _SelectableInputState extends State<SelectableInput> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int? selectedValue;

  @override
  void initState() {
    super.initState();
    _loadDefaultValue();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadDefaultValue() {
    if (widget.defaultValue != null) {
      selectedValue = widget.defaultValue;
      _controller.text = widget.defaultValue.toString();
    }
  }

  void _updateSelection(int? value) {
    setState(() {
      selectedValue = value != null && widget.options.contains(value)
          ? value
          : null;
    });
    widget.onChanged(value);
    // Trigger validation
    final isValid = _formKey.currentState?.validate() ?? false;
    widget.onValidation?.call(isValid);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: true,
    );
    final lang = languageProvider.languageCode;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(widget.labelText, style: textTheme.titleSmall),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  keyboardType: widget.keyboardType,
                  onChanged: (value) {
                    _updateSelection(int.tryParse(value.trim()));
                  },
                  style: textTheme.bodySmall,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.get('validNumberMsg', lang);
                    }
                    if (int.tryParse(value.trim()) == null) {
                      return AppStrings.get('validNumberMsg', lang);
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widget.options.map((option) {
              final bool isSelected = option == selectedValue;

              return Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _controller.value = TextEditingValue(
                      text: option.toString(),
                    );
                    _updateSelection(option);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSelected ? AppColors.sectionBg : null,
                  ),
                  child: Text(option.toString()),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class SelectableRatioInput extends StatefulWidget {
  final List<String> options;
  final ValueChanged<String> onChanged; // return text value
  final ValueChanged<bool>? onValidation; // return validation state
  final TextInputType keyboardType;
  final String labelText;
  final String? defaultValue;

  const SelectableRatioInput({
    super.key,
    required this.options,
    required this.onChanged,
    this.onValidation,
    this.keyboardType = TextInputType.number,
    this.labelText = 'Enter value',
    this.defaultValue,
  });

  @override
  State<SelectableRatioInput> createState() => _SelectableRatioInputState();
}

class _SelectableRatioInputState extends State<SelectableRatioInput> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedValue;

  @override
  void initState() {
    super.initState();
    _loadDefaultValue();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadDefaultValue() {
    if (widget.defaultValue != null) {
      selectedValue = widget.defaultValue;
      _controller.text = widget.defaultValue!;
    }
  }

  void _updateSelection(String value) {
    setState(() {
      selectedValue = widget.options.contains(value) ? value : null;
    });
    widget.onChanged(value);
    // Trigger validation
    final isValid = _formKey.currentState?.validate() ?? false;
    widget.onValidation?.call(isValid);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(widget.labelText, style: textTheme.titleSmall),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  readOnly: true,

                  keyboardType: widget.keyboardType,
                  decoration: InputDecoration(
                    disabledBorder: OutlineInputBorder(),
                    errorText: null,
                  ),
                  onChanged: (value) {
                    final stringValue = value;
                    _updateSelection(stringValue);
                  },

                  style: textTheme.bodySmall,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Value cannot be empty";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: widget.options.map((option) {
              final bool isSelected = option == selectedValue;

              return Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _controller.value = TextEditingValue(text: option);
                    _updateSelection(option);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSelected ? AppColors.sectionBg : null,
                  ),
                  child: Text(option.toString()),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
