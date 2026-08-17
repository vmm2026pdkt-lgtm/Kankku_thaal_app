import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

/// EditCategorySheet — bottom sheet for creating or editing a category:
/// name, icon, color.
class EditCategorySheet extends StatefulWidget {
  final String type;
  final CategoryModel? existing;
  const EditCategorySheet({super.key, required this.type, this.existing});

  @override
  State<EditCategorySheet> createState() => _EditCategorySheetState();
}

class _EditCategorySheetState extends State<EditCategorySheet> {
  final _nameController = TextEditingController();
  String _icon = AppConstants.selectableIcons.first;
  String _color = AppConstants.selectableColors.first;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameController.text = widget.existing!.name;
      _icon = widget.existing!.icon;
      _color = widget.existing!.color;
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'பெயரை உள்ளிடவும்');
      return;
    }
    final provider = context.read<CategoryProvider>();
    if (widget.existing != null) {
      await provider.updateCategory(widget.existing!, name: _nameController.text.trim(), icon: _icon, color: _color);
    } else {
      await provider.addCategory(name: _nameController.text.trim(), type: widget.type, icon: _icon, color: _color);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.existing != null ? 'வகையை திருத்து' : 'புதிய வகை',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(hintText: 'வகை பெயர்', errorText: _nameError),
              ),
              const SizedBox(height: 20),
              Text('Icon', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppConstants.selectableIcons.map((key) {
                  final selected = key == _icon;
                  return GestureDetector(
                    onTap: () => setState(() => _icon = key),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected ? AppHelpers.colorFromHex(_color).withOpacity(0.2) : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: selected ? Border.all(color: AppHelpers.colorFromHex(_color), width: 2) : null,
                      ),
                      child: Icon(AppConstants.iconFor(key), size: 22),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('நிறம்', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppConstants.selectableColors.map((hex) {
                  final selected = hex == _color;
                  return GestureDetector(
                    onTap: () => setState(() => _color = hex),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppHelpers.colorFromHex(hex),
                        shape: BoxShape.circle,
                        border: selected ? Border.all(color: Colors.black, width: 2) : null,
                      ),
                      child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _save, child: const Text('சேமிக்கவும்')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
