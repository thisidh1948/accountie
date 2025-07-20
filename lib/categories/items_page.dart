import 'package:accountie/models/category_model.dart';
import 'package:accountie/categories/add_item_dialog.dart';
import 'package:accountie/categories/add_subcategory_dialog.dart';
import 'package:accountie/widgets/svg_icon_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemsPage extends StatelessWidget {
  final Category category;
  final SubCategory subCategory;
  const ItemsPage(
      {super.key, required this.category, required this.subCategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' Items of ${category.name}'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(category.name)
            .collection('subcategories')
            .doc(subCategory.name)
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          final items = docs.map((doc) => Item.fromMap(doc.data())).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final double availableWidth = constraints.maxWidth;
              const double minItemWidth = 170;
              final int crossAxisCount = (availableWidth / minItemWidth)
                  .floor()
                  .clamp(1, items.length > 0 ? items.length : 1);
              const double desiredAspectRatio = 0.7;

              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: desiredAspectRatio,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {},
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddItemDialog(
                            categoryId: category.name,
                            subCategoryId: subCategory.name,
                            initialItem: item,
                          ),
                        );
                      },
                      onDoubleTap: () async {
                        await FirebaseFirestore.instance
                            .collection('categories')
                            .doc(category.name)
                            .collection('subcategories')
                            .doc(subCategory.name)
                            .collection('items')
                            .doc(item.name)
                            .delete();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: category.icon != null &&
                                        category.icon!.isNotEmpty
                                    ? SvgIconWidget(
                                        iconFileName: item.icon ?? '',
                                        width: 90,
                                        height: 90,
                                      )
                                    : const Icon(
                                        Icons.category_outlined,
                                        size: 90,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.name,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              height: 24,
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                  color: item.color != null && item.color!.isNotEmpty
                                      ? Color(int.parse(item.color!))
                                      : Colors.amber),
                              child: const Center(
                                child: Text(
                                  'Color',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            Text(
                              'Index: ${item.index}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddItemDialog(
              categoryId: category.name,
              subCategoryId: subCategory.name,
            ),
          );
        },
        tooltip: 'Add New Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
