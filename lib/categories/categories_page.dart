import 'package:accountie/models/category_model.dart';
import 'package:accountie/categories/add_category_page.dart';
import 'package:accountie/categories/subcategories_page.dart';
import 'package:accountie/widgets/svg_icon_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: StreamBuilder<QuerySnapshot<Category>>(
          stream: FirebaseFirestore.instance
              .collection('categories')
              .withConverter<Category>(
                fromFirestore: (snapshot, _) =>
                    Category.fromFirestore(snapshot),
                toFirestore: (category, _) => category.toFirestore(),
              )
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print('Error loading products: ${snapshot.error}');
              return const Center(child: Text('Error loading products.'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text('No products found. Add a new product!'));
            }

            final List<Category> categories =
                snapshot.data!.docs.map((doc) => doc.data()).toList();
            print('Loaded categories: ${categories.length}');

            return LayoutBuilder(
              builder: (context, constraints) {
                final double availableWidth = constraints.maxWidth;
                const double minItemWidth = 170;

                // Calculate the crossAxisCount based on available width and minimum item width
                // Ensure at least 1 column
                final int crossAxisCount = (availableWidth / minItemWidth)
                    .floor()
                    .clamp(
                        1,
                        categories
                            .length); // Clamp to prevent more columns than items

                // Calculate the actual item width based on the determined crossAxisCount and spacing
                // This isn't strictly needed for childAspectRatio, but gives context
                final double itemWidth =
                    (availableWidth - (crossAxisCount - 1) * 16.0 - 2 * 16.0) /
                        crossAxisCount;

                // Adjust childAspectRatio to make tiles significantly taller than wide
                // Smaller value means taller tile. Let's try 0.7 or 0.6.
                // 1.0 is square. 0.9 was slightly taller. 0.7 will be significantly taller.
                const double desiredAspectRatio =
                    0.7; // Height will be width / 0.7 (approx 1.4 * width)

                return GridView.builder(
                  padding:
                      const EdgeInsets.all(16.0), // Padding around the grid
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        crossAxisCount, // Dynamically calculated number of columns
                    crossAxisSpacing: 16.0, // Horizontal spacing between items
                    mainAxisSpacing: 16.0, // Vertical spacing between items
                    // Use the desired aspect ratio to give more vertical space
                    childAspectRatio:
                        desiredAspectRatio, // Using a smaller value for taller tiles
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          print('Tapped on category: ${category.name}');
                          // Navigate to SubCategoryPage for this category
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
                        onDoubleTap: () {
                          // Delete the category
                          FirebaseFirestore.instance
                              .collection('categories')
                              .doc(category.name)
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
                                          iconFileName: category.icon ?? '',
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
                                category.name,
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
                                  color: category.color!.isNotEmpty
                                      ? Color(int.parse(category.color ?? 0xFFFFFFFF.toRadixString(16)))
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
                                'Index: ${category.index}',
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
          }),
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
