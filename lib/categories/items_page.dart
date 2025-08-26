import 'package:accountie/models/category_model.dart';
import 'package:accountie/categories/add_item_dialog.dart';
import 'package:accountie/services/data_service.dart';
import 'package:accountie/widgets/tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemsPage extends StatelessWidget {
  final Category category;
  final SubCategory subCategory;
  const ItemsPage(
      {super.key, required this.category, required this.subCategory});

  @override
  Widget build(BuildContext context) {
    final List<Category> categories = context.watch<DataService>().categories;
    int noOfTiles = MediaQuery.of(context).size.width >= 600 ? 6 : 3;
    List<Item> items = subCategory.items ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text(' Items of ${category.name}'),
      ),
      body: items.isEmpty
          ? const Center(child: Text("No Items Found"))
          : LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: noOfTiles,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CustTileWidget(
                      icon: item.icon ?? item.name,
                      color: item.color ?? '',
                      label: item.name,
                      index: item.index,
                      onLongPress: () => {
                        showDialog(
                          context: context,
                          builder: (context) => AddItemDialog(
                            categoryId: category.name,
                            subCategoryId: subCategory.name,
                            initialItem: item,
                          ),
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
