import 'package:accountie/categories/accounts_page.dart';
import 'package:accountie/categories/categories_page.dart';
import 'package:accountie/categories/tags_page.dart';
import 'package:accountie/widgets/tile_widget.dart';
import 'package:flutter/material.dart';

class TemplatePage extends StatelessWidget {
  const TemplatePage({super.key});
  @override
  Widget build(BuildContext context) {

    int noOfTiles = MediaQuery.of(context).size.width >= 600 ? 6 : 3;

    return Scaffold(
        appBar: AppBar(title: const Text('Templates Page')),
        body: GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: noOfTiles, // Two tiles per row
          crossAxisSpacing: 16,
          mainAxisSpacing: 16, // Wider tiles
          physics: const PageScrollPhysics(),
          shrinkWrap: true,
          children: [
            CustTileWidget(
              icon: 'edit.svg',
              label: 'Categories',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesPage()),
              ),
            ),
            CustTileWidget(
              icon: 'debt.svg',
              label: 'Accounts',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountsPage()),
              ),
            ),
            CustTileWidget(
              icon: 'tag.svg',
              label: 'Tags',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TagsPage()),
              ),
            ),
            // Add more tiles here...
          ],
        ));
  }
}
