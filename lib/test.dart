// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

class Greeter {
  final String name;
  Greeter(this.name);

  void sayHello() => print('Hello, $name!');
}

List<Category> _categories = [
  Category(name: 'Category 1', subcategories: [
    SubCategory(name: 'Subcategory 1', items: [
      Item(name: 'Item 1'),
      Item(name: 'Item 2'),
    ]),
    SubCategory(name: 'Subcategory 2', items: [
      Item(name: 'Item 3'),
      Item(name: 'Item 4'),
    ]),
  ]),
  Category(name: 'CategoryX', subcategories: [
    SubCategory(name: 'SubcategoryX', items: [
      Item(name: 'Item 5'),
      Item(name: 'Item 6'),
    ]),
    SubCategory(name: 'SubcategoryY', items: [
      Item(name: 'ItemN'),
      Item(name: 'Item 8'),
    ]),
  ]),
];

void main() {
  addItem(Item(name: 'ItemP', color: 'x0006h'), 'CategoryX', 'SubcategoryY',
      'ItemN', 0, false);
  for (var category in _categories) {
    print(category.name);
    for (var subcategory in category.subcategories) {
      print(subcategory.name);
      for (var item in subcategory.items) {
        print(item.name);
        print(item.color);
      }
    }
  }
}

void addItem(Item item, String? category, String? subcategory, String? itemName,
    int? index, bool isUpdate) async {
  try {
    if (isUpdate) {
      _categories
          .firstWhere((x) => x.name == category)
          .subcategories
          .firstWhere((x) => x.name == subcategory)
          .items
          ?.add(item);
    } else {
      _categories
          .firstWhere((x) => x.name == category)
          .subcategories
          .firstWhere((x) => x.name == subcategory)
          .items
          ?.firstWhere((x) => x.name == itemName)
          .replaceWith(item);
    }
  } catch (e) {}
}

class Category {
  String name;
  List<SubCategory> subcategories;

  Category({required this.name, this.subcategories = const []});
}

class SubCategory {
  String name;
  List<Item> items;

  SubCategory({required this.name, this.items = const []});
}

class Item {
  String name;
  String color;

  Item({required this.name, this.color = ''});

  void replaceWith(Item item) {
    name = item.name;
    color = item.color;
  }
}
