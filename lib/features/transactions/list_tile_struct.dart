import 'package:accountie/models/account_model.dart';
import 'package:accountie/models/category_model.dart';
import 'package:accountie/models/record_model.dart';
import 'package:accountie/widgets/svg_icon_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

ListTile getListTile(List<Category> categories, record, titleText,
      BuildContext context, List<Account> accounts) {
    return ListTile(
      leading: SvgIconWidget(
        iconFileName: getIconLabel(categories, record.category,
            subCategory: record.subCategory,
            item: record.items?.first.name ?? ''),
        width: 34,
        height: 34,
      ),
      title: Text(titleText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text(
        '${record.category} - ${record.subCategory}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Text(
        record.amount.toString(),
        style: TextStyle(
          color: record.type ? Colors.green : Colors.red,
        ),
      ),
      onTap: () => _showTransactionDetails(
          context,
          record,
          accounts
              .firstWhere((element) => element.accountNumber == record.account),
          categories.firstWhere((element) => element.name == record.category)),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    TRecord record,
    Account account,
    Category category,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIconRow(account, category, record),
                const SizedBox(height: 16),
                _buildDetailText('Id', record.recordId),
                _buildDetailText(
                    'Date', DateFormat.yMMMd().format(record.transactionDate)),
                _buildDetailText(
                  'Location',
                  '${record.location?.cityName ?? ''}, '
                      '${record.location?.areaName ?? ''}, '
                      '${record.location?.pincode ?? ''}',
                ),
                if (record.description?.trim().isNotEmpty == true)
                  _buildDetailText('Description', record.description!),

                if(record.type)
                _buildDetailText(
                  'Amount: +',
                  '${record.amount}',
                  style: TextStyle(
                    color: record.type ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if(!record.type)
                _buildDetailText(
                  'Amount: -',
                  '${record.amount}',
                  style: TextStyle(
                    color: record.type ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (record.tags?.isNotEmpty == true)
                  _buildDetailText('Tags', record.tags!.join(', ')),
                if (record.items?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Items',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildItemTable(record.items!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailText(String label, String value, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$label: $value', style: style),
    );
  }

  Widget _buildIconColumn(String label, String iconFileName) {
    return Column(
      children: [
        SvgIconWidget(iconFileName: iconFileName, width: 24, height: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildIconRow(Account account, Category category, TRecord record) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconColumn(account.name, account.icon ?? 'NA'),
        _buildIconColumn(
          record.category,
          getIconLabel([category], record.category),
        ),
        _buildIconColumn(
          record.subCategory,
          getIconLabel([category], record.category,
              subCategory: record.subCategory),
        ),
      ],
    );
  }

  Widget _buildItemTable(List<RecordItem> items) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
      },
      children: [
        const TableRow(
          children: [
            Padding(padding: EdgeInsets.all(8), child: Text('Name')),
            Padding(padding: EdgeInsets.all(8), child: Text('Brand')),
            Padding(padding: EdgeInsets.all(8), child: Text('Qty')),
            Padding(padding: EdgeInsets.all(8), child: Text('Price')),
            Padding(padding: EdgeInsets.all(8), child: Text('Total')),
          ],
        ),
        ...items.map((item) {
          final total = item.quantity * item.unitPrice;
          return TableRow(
            children: [
              Padding(padding: const EdgeInsets.all(8), child: Text(item.name)),
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(item.brand ?? '')),
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('${item.quantity}')),
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('${item.unitPrice}')),
              Padding(padding: const EdgeInsets.all(8), child: Text('$total')),
            ],
          );
        }).toList(),
      ],
    );
  }

   String getIconLabel(
    List<Category> categories,
    String category, {
    String subCategory = '',
    String item = '',
  }) {
    final cat = categories.firstWhere(
      (c) => c.name == category,
      orElse: () => Category(
          name: category,
          icon: '',
          color: '',
          index: 0,
          subcategories: []), // fallback if not found
    );

    if (subCategory.isEmpty) return cat.icon ?? cat.name;

    final subCat = cat.subcategories.firstWhere(
      (s) => s.name == subCategory,
      orElse: () => SubCategory(
          name: subCategory,
          icon: '',
          color: '',
          index: 0,
          items: [],
          type: false),
    );

    if (item.isEmpty) return subCat.icon ?? subCat.name;

    final ite = subCat.items?.firstWhere(
      (i) => i.name == item,
      orElse: () => Item(name: item),
    );

    return ite?.icon ?? ite?.name ?? '';
  }