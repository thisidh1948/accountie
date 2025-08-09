import 'package:cloud_firestore/cloud_firestore.dart';

class TRecord {
   String recordId;
   String account;
   bool type;
   String category;
   String subCategory;
   double amount;
   DateTime transactionDate;
   String? description;
   List<String>? tags;
   LocationModel? location;
   String? paymentMethod;
   List<RecordItem>? items;
   String? loanId;
   String? receiptUrl;

  TRecord({
    required this.recordId,
    required this.account,
    required this.type,
    required this.category,
    required this.subCategory,
    required this.amount,
    required this.transactionDate,
    this.description,
    this.tags,
    this.location,
    this.paymentMethod,
    this.items,
    this.loanId,
    this.receiptUrl,
  });

  factory TRecord.fromMap(Map<String, dynamic> map, String id) {
    return TRecord(
      recordId: id,
      account: map['account'],
      type: map['type'] == 'credit', // Assuming type is stored as 'credit' or 'debit'
      category: map['category'],
      subCategory: map['subCategory'],
      amount: (map['amount'] as num).toDouble(),
      transactionDate: (map['transactionDate'] as Timestamp).toDate(),
      description: map['description'],
      tags: stringToList(map['tags']),
      location: stringToLocation(map['location']),
      paymentMethod: map['paymentMethod'],
      items: stringToItems(map['items']),
      loanId: map['loanId'],
      receiptUrl: map['receiptUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'account': account,
      'type': type ? 'credit' : 'debit', // Store as 'credit' or 'debit'
      'category': category,
      'subCategory': subCategory,
      'amount': amount,
      'transactionDate': Timestamp.fromDate(transactionDate ?? DateTime.now()),
      'description': description,
      'tags': tagsString,
      'location': locationString,
      'paymentMethod': paymentMethod,
      'items': itemsString,
      'loanId': loanId,
      'receiptUrl': receiptUrl,
    };
  }
  
  get itemsString =>
      items?.map((item) {
        final taxString = item.tax != null ? ',${item.tax}' : '0';
        return '${item.name},${item.brand ?? ''},${item.quantity},${item.unitPrice},${item.totalAmount}$taxString';
      }).join(';') ??
      '';

  static List<RecordItem> stringToItems(String? str) {
    if (str == null || str.isEmpty) {
      return [];
    }
    return str.split(';').map((itemStr) {
      final parts = itemStr.split(',');
      return RecordItem(
        name: parts[0],
        brand: parts[1].isNotEmpty ? parts[1] : null,
        quantity: int.tryParse(parts[2]) ?? 0,
        unitPrice: double.tryParse(parts[3]) ?? 0.0,
        totalAmount: double.tryParse(parts[4]) ?? 0.0,
        tax: parts.length > 5 && parts[5].isNotEmpty
            ? double.tryParse(parts[5])
            : null,
      );
    }).toList();
  }

  get tagsString => tags?.join(',') ?? '';

  static List<String> stringToList(String? str) {
    if (str == null || str.isEmpty) {
      return [];
    }
    return str.split(',').map((e) => e.trim()).toList();
  }

  get locationString =>
      location != null
          ? '${location!.cityName},${location!.areaName},${location!.pincode}'
          : '';

  static LocationModel stringToLocation(String? str) {
    if (str == null || str.isEmpty) {
      return LocationModel(cityName: '', areaName: '', pincode: 0);
    }
    final parts = str.split(',');
    return LocationModel(
      cityName: parts[0],
      areaName: parts.length > 1 ? parts[1] : '',
      pincode: parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0,
    );
  }

  @override
  String toString() {
    return 'Record{recordId: $recordId, account: $account, type: $type, category: $category, subCategory: $subCategory, amount: $amount, transactionDate: $transactionDate, description: $description, tags: $tags, location: $location, paymentMethod: $paymentMethod, items: $items, loanId: $loanId, receiptUrl: $receiptUrl}';
  }
}

class RecordItem {
   String name;
   String? brand;
   int quantity;
   double unitPrice;
   double totalAmount;
   double? tax; // Optional field for discount

  RecordItem({
    required this.name,
    this.brand,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.tax,
  });

  RecordItem copyWith({
    String? name,
    String? brand,
    int? quantity,
    double? unitPrice,
    double? totalAmount,
    double? tax,
  }) {
    return RecordItem(
      name: name ?? this.name,
      brand: brand ?? this.brand,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      tax: this.tax,
    );
  }

  factory RecordItem.fromMap(Map<String, dynamic> map) {
    return RecordItem(
      name: map['name'],
      brand: map['brand'],
      quantity: map['quantity'],
      unitPrice: (map['unitPrice'] as num).toDouble(),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      tax: map['tax'] != null ? (map['tax'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'tax': tax,
    };
  }
}

class LocationModel {
  final String cityName;
  final String areaName;
  final int pincode;

  LocationModel({
    required this.cityName,
    required this.areaName,
    required this.pincode,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      cityName: map['cityName'] ?? '',
      areaName: map['areaName'] ?? '',
      pincode: map['pincode'] != null ? int.tryParse(map['pincode']) ?? 0 : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cityName': cityName,
      'areaName': areaName,
      'pincode': pincode,
    };
  }
}

