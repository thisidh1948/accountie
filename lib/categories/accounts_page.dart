import 'package:accountie/categories/add_account_page.dart';
import 'package:accountie/models/account_model.dart';
import 'package:accountie/services/data_service.dart';
import 'package:accountie/widgets/tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DataService dataService = Provider.of<DataService>(context, listen: false);
    final List<Account> accounts = context.watch<DataService>().accounts;
    int noOfTiles = MediaQuery.of(context).size.width >= 600 ? 6 : 3;
    bool isLoading = context.watch<DataService>().isLoading;

    if(isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: GridView.builder(
          padding: const EdgeInsets.all(16.0), // Padding around the grid
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                noOfTiles, // Dynamically calculated number of columns
            crossAxisSpacing: 16.0, // Horizontal spacing between items
            mainAxisSpacing: 16.0, // Vertical spacing between items
          ),
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final account = accounts[index];
            return CustTileWidget(
              icon: account.icon ?? account.name,
              label: account.name,
              onTap: () => {
                showDialog(
                    context: context,
                    builder: (context) => AddAccountDialog(
                          initialAccount: account,
                        ))
              },
              onDoubleTap: () {
                FirebaseFirestore.instance
                    .collection('accounts')
                    .doc(account.accountNumber)
                    .delete();
              },
              onLongPress: () => {
                showDialog(
                    context: context,
                    builder: (context) => AddAccountDialog(
                          initialAccount: account,
                        ))
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
