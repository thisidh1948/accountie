import 'package:accountie/models/category_model.dart';
import 'package:accountie/categories/add_subcategory_dialog.dart';
import 'package:accountie/categories/items_page.dart';
import 'package:accountie/widgets/svg_icon_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubCategoriesPage extends StatelessWidget {
  final Category category;
  const SubCategoriesPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subcategories of ${category.name}'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(category.name)
            .collection('subcategories')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          final subcategories =
              docs.map((doc) => SubCategory.fromMap(doc.data())).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final double availableWidth = constraints.maxWidth;
              const double minItemWidth = 170;
              final int crossAxisCount = (availableWidth / minItemWidth)
                  .floor()
                  .clamp(
                      1, subcategories.length > 0 ? subcategories.length : 1);
              const double desiredAspectRatio = 0.7;

              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: desiredAspectRatio,
                ),
                itemCount: subcategories.length,
                itemBuilder: (context, index) {
                  final subcat = subcategories[index];
                  return Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemsPage(
                              category: category,
                              subCategory: subcat,
                            ),
                          ),
                        );
                      },
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddSubCategoryDialog(
                            initialSubCategory: subcat,
                            categoryId: category.name,
                          ),
                        );
                      },
                      onDoubleTap: () async {
                        await FirebaseFirestore.instance
                            .collection('categories')
                            .doc(category.name)
                            .collection('subcategories')
                            .doc(subcat.name)
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
                                child: category.icon!.isNotEmpty
                                    ? SvgIconWidget(
                                        iconFileName: subcat.icon ?? '',
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
                              subcat.name,
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
                                color: subcat.color!.isNotEmpty
                                    ? Color(int.parse(subcat.color ?? '0xFFFFFFFF'))
                                    : Colors.amber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'Color',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            Text(
                              'Type: ${subcat.type}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Index: ${subcat.index}',
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
            builder: (context) =>
                AddSubCategoryDialog(categoryId: category.name),
            // builder: (context) => _SubCategoryEditDialog(
            //   onSave: (newSubCat) async {
            //     await FirebaseFirestore.instance
            //         .collection('categories')
            //         .doc(category.category)
            //         .collection('subcategories')
            //         .doc(newSubCat.subcategory)
            //         .set(newSubCat.toMap());
            //   },
            // ),
          );
        },
        tooltip: 'Add New Subcategory',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// class _SubCategoryEditDialog extends StatefulWidget {
//   final SubCategory? initialSubCategory;
//   final Future<void> Function(SubCategory) onSave;
//   const _SubCategoryEditDialog({Key? key, this.initialSubCategory, required this.onSave}) : super(key: key);

//   @override
//   State<_SubCategoryEditDialog> createState() => _SubCategoryEditDialogState();
// }

// class _SubCategoryEditDialogState extends State<_SubCategoryEditDialog> {
//   late TextEditingController nameController;
//   late TextEditingController typeController;
//   late TextEditingController iconController;
//   late TextEditingController colorController;

//   @override
//   void initState() {
//     super.initState();
//     nameController = TextEditingController(text: widget.initialSubCategory?.subcategory ?? '');
//     typeController = TextEditingController(text: widget.initialSubCategory?.type ?? '');
//     iconController = TextEditingController(text: widget.initialSubCategory?.icon ?? '');
//     colorController = TextEditingController(text: widget.initialSubCategory?.color ?? '');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text(widget.initialSubCategory == null ? 'Add Subcategory' : 'Edit Subcategory'),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextFormField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: 'Subcategory Name'),
//             ),
//             TextFormField(
//               controller: typeController,
//               decoration: const InputDecoration(labelText: 'Type'),
//             ),
//             TextFormField(
//               controller: iconController,
//               decoration: const InputDecoration(labelText: 'Icon Name'),
//             ),
//             TextFormField(
//               controller: colorController,
//               decoration: const InputDecoration(labelText: 'Color'),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () async {
//             final subCat = SubCategory(
//               subcategory: nameController.text,
//               type: typeController.text,
//               icon: iconController.text,
//               color: colorController.text,
//               items: [],
//               index: widget.initialSubCategory?.index ?? 0,
//             );
//             await widget.onSave(subCat);
//             Navigator.of(context).pop();
//           },
//           child: const Text('Save'),
//         ),
//       ],
//     );
//   }
// }
