import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String budgetId;
  final String name;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final double targetAmount;
  final double currentSpent;
  final double currentSaved;
  final List<String> categoriesIncluded;
  final List<String>? accountsIncluded;
  final String status;
  final String? notes;
  final int? index; // Optional: Unique identifier for the budget

  BudgetModel({
    required this.budgetId,
    required this.name,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.targetAmount,
    required this.currentSpent,
    required this.currentSaved,
    required this.categoriesIncluded,
    this.accountsIncluded,
    required this.status,
    this.notes,
    this.index,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map, String id) {
    return BudgetModel(
      budgetId: id,
      name: map['name'],
      period: map['period'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentSpent: (map['currentSpent'] as num).toDouble(),
      currentSaved: (map['currentSaved'] as num).toDouble(),
      categoriesIncluded: (map['categoriesIncluded'] as List).map((e) => e.toString()).toList(),
      accountsIncluded: (map['accountsIncluded'] as List?)?.map((e) => e.toString()).toList(),
      status: map['status'],
      notes: map['notes'],
      index: map['index'] != null ? (map['index'] as num).toInt() : null, // Optional index field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'period': period,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'targetAmount': targetAmount,
      'currentSpent': currentSpent,
      'currentSaved': currentSaved,
      'categoriesIncluded': categoriesIncluded,
      'accountsIncluded': accountsIncluded,
      'status': status,
      'notes': notes,
      'index': index, // Optional index field
    };
  }
}
