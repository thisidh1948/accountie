import 'package:accountie/models/account_model.dart';
import 'package:accountie/models/category_model.dart';
import 'package:accountie/models/structure.dart';
import 'package:accountie/widgets/svg_icon_widgets.dart';
import 'package:flutter/material.dart';

class SelectDialogWidget extends StatelessWidget {
  final List<Structure> structures;
  final String title;
  const SelectDialogWidget({super.key, required this.structures, required this.title});

  @override
  Widget build(BuildContext context) {
    return SelectionDialog<Structure>(
      title: title,
      items: structures,
      itemBuilder: (structure) => structure.icon != null && structure.icon!.isNotEmpty
          ? SvgIconWidget(iconFileName: structure.icon!)
          : Icon(Icons.category, color: Colors.grey),
      itemToString: (structure) => structure.name ?? 'Unnamed',
    );}
}

class SelectSubCategoryDialog extends StatelessWidget {
  final List<SubCategory> subcategories;
  const SelectSubCategoryDialog({super.key, required this.subcategories});

  @override
  Widget build(BuildContext context) {
    return SelectionDialog<SubCategory>(
      title: 'Select Subcategory',
      items: subcategories,
      itemBuilder: (subcategory) =>
          subcategory.icon != null && subcategory.icon!.isNotEmpty
              ? SvgIconWidget(iconFileName: subcategory.icon!)
              : Icon(Icons.category, color: Colors.grey),
      itemToString: (subcategory) => subcategory.name ?? 'Unnamed Subcategory',
    );
  }
}

class SelectAccountDialog extends StatelessWidget {
  final List<Account> accounts;
  const SelectAccountDialog({super.key, required this.accounts});

  @override
  Widget build(BuildContext context) {
    return SelectionDialog<Account>(
      title: 'Select Account',
      items: accounts, // Use the directly provided accounts list
      itemBuilder: (account) =>
          account.icon != null && account.icon!.isNotEmpty
              ? SvgIconWidget(
                  iconFileName: account.icon!)
              : Icon(Icons.account_balance,
                  color: account.color != null && account.color!.isNotEmpty
                      ? Color(int.parse(account.color!))
                      : Colors.grey),
      itemToString: (account) =>
          '${account.name ?? 'N/A'} - ${account.accountNumber ?? 'N/A'} (${account.accountholder})',
    );
  }
}

class SelectionDialog<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final String Function(T item) itemToString;

  const SelectionDialog({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    required this.itemToString,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: items.isEmpty
          ? const Text('No items available.')
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: items.map((item) {
                  return ListTile(
                    leading: itemBuilder(item),
                    title: Text(itemToString(item)),
                    onTap: () {// Debugging line
                       // Debugging line to print item details
                      Navigator.of(context).pop(item);
                    },
                  );
                }).toList(),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

