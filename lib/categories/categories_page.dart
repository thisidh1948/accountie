import 'package:accountie/models/category_model.dart';
import 'package:accountie/categories/add_category_page.dart';
import 'package:accountie/categories/subcategories_page.dart';
import 'package:accountie/services/data_service.dart';
import 'package:accountie/widgets/tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Category> categories = context.watch<DataService>().categories;
    int noOfTiles = MediaQuery.of(context).size.width >= 600 ? 6 : 3;
    bool _isLoading = context.watch<DataService>().isLoading;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: noOfTiles,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0, // Using a smaller value for taller tiles
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CustTileWidget(
            icon: category.icon ?? category.name,
            label: category.name,
            color: category.color ?? '',
            index: category.index,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SubCategoriesPage(
                    category: category,
                  ),
                ),
              );
            },
            onLongPress: () {
              // Open edit dialog for Category
              showDialog(
                  context: context,
                  builder: (context) => AddCategoryDialog(
                        initialCategory: category,
                      ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddCategoryDialog(),
          );
        },
        tooltip: 'Add New Category',
        child: const Icon(Icons.add),
      ),
    );
  }
}
