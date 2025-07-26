import 'package:accountie/categories/accounts_page.dart';
import 'package:accountie/categories/categories_page.dart';
import 'package:accountie/categories/tags_page.dart';
import 'package:accountie/loans/loans_list_page.dart';
import 'package:accountie/records/add_update_record_page.dart';
import 'package:accountie/records/records_view_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// PlaceholderPage if you still need it for other buttons
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('This is the $title page (Placeholder)')),
    );
  }
}

List<Map<String, dynamic>> getAllNavigationItems(BuildContext context) {
  return [
    {
      'label': 'Categories',
      'icon': Icons.add_circle_outline,
      'destinationPage': const CategoriesPage(),
      'iconColor': Colors.purple,
      'cardColor': Colors.deepPurple.shade100,
      'subtitle': 'Browse the service catalogue',
    },
    {
      'label': 'Accounts',
      'icon': Icons.list_alt,
      'destinationPage': const AccountsPage(),
      'iconColor': Colors.teal,
      'cardColor': Colors.teal.shade100,
      'subtitle': 'View your open requests',
    },
    {
      'label': 'Report an Incident',
      'icon': Icons.warning_amber_outlined,
      'destinationPage': const AddRecordDialogPage(),
      'iconColor': Colors.blue,
      'cardColor': Colors.blue.shade100,
      'subtitle': 'Get help with an issue',
    },
    {
      'label': 'Manage Users',
      'icon': Icons.people_outline,
      'destinationPage': const TagsPage(),
      'iconColor': Colors.red,
      'cardColor': Colors.red.shade100,
      'subtitle': 'Manage user accounts',
    },
    {
      'label': 'Manage Products',
      'icon': Icons.inventory_2_outlined,
      'destinationPage': const PlaceholderPage(title: 'Report an Incident'),
      'iconColor': Colors.orange,
      'cardColor': Colors.orange.shade100,
      'subtitle': 'Manage inventory and items',
    },
    {
      'label': 'RECORDS',
      'icon': Icons.assessment_outlined,
      'destinationPage': const RecordListPage(),
      'iconColor': Colors.grey,
      'cardColor': Colors.grey.shade100,
      'subtitle': 'See all requests across departments',
    },
    {
      'label': 'Loans',
      'icon': Icons.analytics_outlined,
      'destinationPage': LoansListPage(),
      'iconColor': Colors.deepOrange,
      'cardColor': Colors.deepOrange.shade100,
      'subtitle': 'LOANS',
    },
  ];
}
