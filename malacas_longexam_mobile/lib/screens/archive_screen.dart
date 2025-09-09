import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:malacas_longexam_mobile/models/item_model.dart';
import 'package:malacas_longexam_mobile/services/item_service.dart';
import 'package:malacas_longexam_mobile/widgets/custom_text.dart';
import 'package:malacas_longexam_mobile/screens/details_screen.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  late Future<List<Item>> _futureItems;
  List<Item> _archivedItems = [];
  List<Item> _filteredArchived = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureItems = _getArchivedItems();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Item>> _getArchivedItems() async {
    final response = await ItemService().getAllItem();
    final items = (response).map((e) => Item.fromJson(e)).toList();

    // keep only inactive items
    final archived = items.where((item) => !item.isActive).toList();

    _archivedItems = archived;
    _filteredArchived = archived;
    return archived;
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredArchived = _archivedItems
          .where((item) =>
              item.name.toLowerCase().contains(query) ||
              item.description.any((desc) => desc.toLowerCase().contains(query)))
          .toList();
    });
  }

  Widget _statusChip(bool active) {
    return Chip(
      label: Text(active ? 'Active' : 'Inactive'),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: active ? Colors.green : Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            // Search field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Search archived items...",
                  hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10.h),

            FutureBuilder<List<Item>>(
              future: _futureItems,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SizedBox(
                    height: ScreenUtil().screenHeight * 0.6,
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CustomText(
                          text: 'No archived items to display...',
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: ScreenUtil().screenHeight * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator.adaptive(strokeWidth: 3.sp),
                          SizedBox(height: 10.h),
                          const CustomText(
                            text: 'Loading archived items...',
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (_filteredArchived.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: const Center(
                      child: CustomText(
                        text: 'No archived items found...',
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  shrinkWrap: true,
                  itemCount: _filteredArchived.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = _filteredArchived[index];
                    final preview = item.description.isNotEmpty
                        ? item.description.first
                        : '';

                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final updated = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ItemDetailsScreen(item: item),
                            ),
                          );

                          if (updated != null && updated is Item) {
                            setState(() {
                              final idx = _archivedItems
                                  .indexWhere((a) => a.iid == updated.iid);
                              if (idx != -1) {
                                _archivedItems[idx] = updated;
                              }
                              _onSearchChanged();
                            });
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Row(
                            children: [
                              // --- Item Image ---
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.photoUrl.isNotEmpty
                                    ? Image.network(
                                        item.photoUrl,
                                        width: 100.w,
                                        height: 100.w,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 100.w,
                                          height: 100.w,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                              Icons.image_not_supported),
                                        ),
                                      )
                                    : Container(
                                        width: 100.w,
                                        height: 100.w,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image),
                                      ),
                              ),
                              SizedBox(width: 10.w),

                              // --- Item Info ---
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: CustomText(
                                            text: item.name.isEmpty
                                                ? 'Untitled'
                                                : item.name,
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            maxLines: 1,
                                          ),
                                        ),
                                        _statusChip(item.isActive),
                                      ],
                                    ),
                                    if (preview.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(top: 0.h),
                                        child: CustomText(
                                          text: preview,
                                          fontSize: 13.sp,
                                          maxLines: 1,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    SizedBox(height: 6.h),

                                    // Qty info
                                    Row(
                                      children: [
                                        Icon(Icons.inventory_2,
                                            size: 16.sp,
                                            color: Colors.grey[600]),
                                        SizedBox(width: 4.w),
                                        CustomText(
                                          text:
                                              "Available: ${item.qtyAvailable} / ${item.qtyTotal}",
                                          fontSize: 13.sp,
                                          color: Colors.grey[800],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
