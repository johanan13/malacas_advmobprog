import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:malacas_longexam_mobile/models/item_model.dart';
import 'package:malacas_longexam_mobile/services/item_service.dart';
import 'package:malacas_longexam_mobile/widgets/custom_text.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Item item;
  const ItemDetailsScreen({super.key, required this.item});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final formKey = GlobalKey<FormState>();
  bool isSaving = false;
  bool isActive = true;
  bool isEditing = false;

  late TextEditingController nameController;
  late TextEditingController qtyTotalController;
  late TextEditingController qtyAvailableController;
  late TextEditingController descriptionController;
  late TextEditingController photoUrlController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item.name);
    qtyTotalController = TextEditingController(text: widget.item.qtyTotal);
    qtyAvailableController = TextEditingController(text: widget.item.qtyAvailable);
    descriptionController = TextEditingController(
      text: widget.item.description.join("\n"),
    );
    photoUrlController = TextEditingController(text: widget.item.photoUrl);
    isActive = widget.item.isActive;
  }

  @override
  void dispose() {
    nameController.dispose();
    qtyTotalController.dispose();
    qtyAvailableController.dispose();
    descriptionController.dispose();
    photoUrlController.dispose();
    super.dispose();
  }

  Widget _statusChip(bool active) {
    return Chip(
      label: Text(active ? 'Active' : 'Inactive'),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: active ? Colors.green : Colors.grey),
    );
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

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text(
            "Are you sure you want to permanently delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        showLoadingDialog(context, "Deleting item...");
        await ItemService().deleteItem(widget.item.iid);

        if (mounted) {
          Navigator.of(context).pop(); // close loading dialog
          Navigator.of(context).pop(true); // go back and notify parent
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Item deleted successfully")),
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: CustomText(
          text: widget.item.name.isEmpty ? 'Untitled' : widget.item.name,
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          maxLines: 2,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.cancel : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
          // ✅ Delete button only if item is inactive
          if (!widget.item.isActive)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteItem,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isEditing ? _buildEditForm() : _buildDetailView(),
      ),
    );
  }

  Widget _buildDetailView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.item.photoUrl.isNotEmpty
              ? Image.network(widget.item.photoUrl,
                  height: 300.h, width: double.infinity, fit: BoxFit.cover)
              : Placeholder(fallbackHeight: 200.h, fallbackWidth: double.infinity),
          SizedBox(height: 20.h),

          // --- Name + Status ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomText(
                  text: widget.item.name.isEmpty ? 'Untitled' : widget.item.name,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  maxLines: 2,
                ),
              ),
              _statusChip(widget.item.isActive),
            ],
          ),

          // --- Description first ---
          if (widget.item.description.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.item.description.map((d) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("• ", style: TextStyle(fontSize: 14.sp)),
                      Expanded(
                        child: CustomText(
                          text: d,
                          fontSize: 14.sp,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          // --- Available below description, aligned left ---
          SizedBox(height: 12.h),
          CustomText(
            text: "Available: ${widget.item.qtyAvailable} / ${widget.item.qtyTotal}",
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return StatefulBuilder(
      builder: (ctx, setLocalState) {
        List<String> toList(String raw) {
          return raw
              .split(RegExp(r'[\n,]'))
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }

        Future<void> save() async {
          if (isSaving) return;
          if (!formKey.currentState!.validate()) return;
          showLoadingDialog(context, 'Updating item...');

          setLocalState(() => isSaving = true);

          try {
            final payLoad = {
              'name': nameController.text.trim(),
              'description': toList(descriptionController.text.trim()),
              'photoUrl': photoUrlController.text.trim(),
              'qtyTotal': qtyTotalController.text.trim(),
              'qtyAvailable': qtyAvailableController.text.trim(),
              'isActive': isActive,
            };

            final Map res =
                await ItemService().updateItem(widget.item.iid, payLoad);
            final created = (res['item'] ?? res);
            final newItem = Item.fromJson(created);

            if (ctx.mounted) Navigator.of(ctx).pop();
            if (mounted) {
              Navigator.of(context).pop(newItem);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item updated.')),
              );
            }
          } catch (e) {
            setLocalState(() => isSaving = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update: $e')),
              );
            }
          }
        }

        return Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: 12.h),
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
                SizedBox(height: 12.h),
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
                SizedBox(height: 12.h),
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
                    return items.isEmpty
                        ? 'At least one description item'
                        : null;
                  },
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: photoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Photo URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8.h),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (val) => setLocalState(() => isActive = val),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    onPressed: save,
                    label: const Text('Save'),
                  ),
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.cancel),
                    onPressed: () {
                      setState(() {
                        isEditing = !isEditing;
                      });
                    },
                    label: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
