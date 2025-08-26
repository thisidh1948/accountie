import 'package:accountie/models/category_model.dart';
import 'package:accountie/categories/add_subcategory_dialog.dart';
import 'package:accountie/categories/items_page.dart';
import 'package:accountie/widgets/tile_widget.dart';
import 'package:flutter/material.dart';

class SubCategoriesPage extends StatelessWidget {
  final Category category;
  const SubCategoriesPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    int noOfTiles = MediaQuery.of(context).size.width >= 600 ? 6 : 3;
    List<SubCategory> subcategories = category.subcategories ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Subcategories of ${category.name}'),
      ),
      body: subcategories.isEmpty
          ? const Center(child: Text("No Subcategories Found"))
          : LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: noOfTiles,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: subcategories.length,
                  itemBuilder: (context, index) {
                    final subcat = subcategories[index];
                    return CustTileWidget(
                      icon: subcat.icon ?? subcat.name,
                      label: subcat.name,
                      color: subcat.color ?? '',
                      index: subcat.index,
                      onTap: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemsPage(
                              category: category,
                              subCategory: subcat,
                            ),
                          ),
                        ),
                      },
                      onLongPress: () => {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              AddSubCategoryDialog(categoryId: category.name, initialSubCategory: subcat),
                        )
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
          );
        },
        tooltip: 'Add New Subcategory',
        child: const Icon(Icons.add),
      ),
    );
  }
}
