import 'package:accountie/categories/add_account_page.dart';
import 'package:accountie/models/account_model.dart';
import 'package:accountie/categories/add_category_page.dart';
import 'package:accountie/widgets/svg_icon_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: StreamBuilder<QuerySnapshot<Account>>(
          stream: FirebaseFirestore.instance
              .collection('accounts')
              .withConverter<Account>(
                fromFirestore: (snapshot, _) => Account.fromFirestore(snapshot),
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

            final List<Account> accounts =
                snapshot.data!.docs.map((doc) => doc.data()).toList();
            print('Loaded Accounts: ${accounts.length}');

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
                        accounts
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
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                        },
                        onLongPress: () {
                          // Open edit dialog for Category
                          showDialog(
                              context: context,
                              builder: (context) => AddAccountDialog(
                                initialAccount: account,
                              ));
                        },
                        onDoubleTap: () {
                          // Delete the category
                          FirebaseFirestore.instance
                              .collection('accounts')
                              .doc(account.accountNumber)
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
                                  child: account.icon!.isNotEmpty
                                      ? SvgIconWidget(
                                          iconFileName: account.icon ?? '',
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
                                account.name,
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
                                  color: account.color != null && account.color!.isNotEmpty
                                      ? Color(int.parse(account.color!))
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
                                'Index: ${account.index}',
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
            builder: (context) => const AddAccountDialog(),
          );
        },
        tooltip: 'Add New Category',
        child: const Icon(Icons.add),
      ),
    );
  }
}
