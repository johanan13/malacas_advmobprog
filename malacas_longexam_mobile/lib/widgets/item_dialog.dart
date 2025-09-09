import 'package:flutter/material.dart';

class ItemFormDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final String? initialPhotoUrl;
  final String? initialQtyTotal;
  final String? initialQtyAvailable;
  final List<String>? initialDescription;
  final bool initialActive;
  final Future<Map> Function(Map<String, dynamic>) onSubmit;

  const ItemFormDialog({
    super.key,
    required this.title,
    this.initialName,
    this.initialPhotoUrl,
    this.initialQtyTotal,
    this.initialQtyAvailable,
    this.initialDescription,
    this.initialActive = true,
    required this.onSubmit,
  });

  @override
  State<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<ItemFormDialog> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController photoUrlController;
  late TextEditingController qtyTotalController;
  late TextEditingController qtyAvailableController;
  late TextEditingController descriptionController;

  bool isSaving = false;
  late bool isActive;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName ?? "");
    photoUrlController = TextEditingController(text: widget.initialPhotoUrl ?? "");
    qtyTotalController = TextEditingController(text: widget.initialQtyTotal ?? "");
    qtyAvailableController = TextEditingController(text: widget.initialQtyAvailable ?? "");
    descriptionController = TextEditingController(
      text: widget.initialDescription?.join("\n") ?? "",
    );
    isActive = widget.initialActive;
  }

  List<String> _toList(String raw) {
    return raw
        .split(RegExp(r'[\n,]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> save() async {
    if (isSaving) return;
    if (!formKey.currentState!.validate()) return;

    showLoadingDialog(context, "${widget.title}...");

    setState(() => isSaving = true);
    try {
      final payload = {
        'name': nameController.text.trim(),
        'photoUrl': photoUrlController.text.trim(),
        'qtyTotal': qtyTotalController.text.trim(),
        'qtyAvailable': qtyAvailableController.text.trim(),
        'description': _toList(descriptionController.text.trim()),
        'isActive': isActive,
      };

      final Map res = await widget.onSubmit(payload);

      if (mounted) Navigator.of(context).pop(); // close loading
      if (mounted) Navigator.of(context).pop(res); // close dialog & return data
    } catch (e) {
      setState(() => isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: photoUrlController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Photo URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: qtyTotalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Quantity',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: qtyAvailableController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Available Quantity',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText:
                      'Description (one entry per line or comma-separated)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  final items = v == null
                      ? []
                      : v
                          .trim()
                          .split(RegExp(r'[\n,]'))
                          .where((s) => s.trim().isNotEmpty)
                          .toList();
                  return items.isEmpty ? 'At least one description' : null;
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: isActive,
                onChanged: (val) => setState(() => isActive = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          onPressed: save,
          label: const Text('Save'),
        ),
      ],
    );
  }
}
