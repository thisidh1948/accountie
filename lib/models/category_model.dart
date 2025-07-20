import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:accountie/models/structure.dart';

class Category extends Structure {
  List<SubCategory> subcategories; // Made final for immutability

  Category({
    required super.name,
    required super.icon, // Category requires icon
    required super.color, // Category requires color
    required super.index, // Category requires index
    required this.subcategories,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      name: map['name'] as String,
      icon: map['icon'] as String? ?? '', // Provide default if map['icon'] is null
      color: map['color'] as String? ?? '', // Provide default if map['color'] is null
      index: map['index'] != null ? (map['index'] as num).toInt() : 0, // Provide default if map['index'] is null
      subcategories: (map['subcategories'] as List<dynamic>?) // Explicitly cast to List<dynamic>?
              ?.map((e) => SubCategory.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }

  factory Category.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('No data found for Category');
    }
    return Category.fromMap(data);
  }

  // toFirestore() method for Category
  Map<String, dynamic> toFirestore() {
    return {
      ...super.toMapStructure(), // Include inherited properties from Structure
      'subcategories': subcategories.map((e) => e.toMap()).toList(),
    };
  }
}

class SubCategory extends Structure {
  bool type;
  List<Item>? items; // Made final for immutability

  SubCategory({
    required super.name,
    required super.icon, // SubCategory requires icon
    required super.color, // SubCategory requires color
    required super.index, // SubCategory requires index
    required this.type,
    this.items,
  });

  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      name: map['name'] as String,
      icon: map['icon'] as String? ?? '', // Provide default if map['icon'] is null
      color: map['color'] as String? ?? '', // Provide default if map['color'] is null
      index: map['index'] != null ? (map['index'] as num).toInt() : 0, // Provide default if map['index'] is null
      type: map['type'] == 'credit', // Assuming type is a boolean indicating credit or debit`,
      items: (map['items'] as List<dynamic>?) // Explicitly cast to List<dynamic>?
          ?.map((e) => Item.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  // toMap() method for SubCategory
  Map<String, dynamic> toMap() {
    return {
      ...super.toMapStructure(), // Include inherited properties from Structure
      'type': type ? 'credit' : 'debit', // Store as 'credit' or 'debit'
      if (items != null) 'items': items!.map((e) => e.toMap()).toList(),
    };
  }
}

class Item extends Structure {

  Item({
    required super.name,
    super.icon,
    super.color,
    super.index,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      name: map['name'] as String,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      index: map['index'] != null ? (map['index'] as num).toInt() : null,
    );
  }

  // toMap() method for Item (can just defer to super's toMapStructure)
  Map<String, dynamic> toMap() {
    return super.toMapStructure();
  }
}