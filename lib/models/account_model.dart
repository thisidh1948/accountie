import 'package:accountie/models/structure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Account extends Structure {
   String accountholder;
   String type; // options are 'savings', 'credit'. 'savings' is default
   double? balance;
   double initialBalance; // only for credit accounts
   String accountNumber;
   double? creditLimit; //only for credit accounts
   DateTime? dueDate; //only for credit accounts
   DateTime? billingCycleStartDay; //only for credit accounts // Optional: Unique identifier for the account

  Account({
    required this.accountholder,
    required this.type,
    this.balance,
    required this.accountNumber,
    this.creditLimit,
    this.dueDate,
    this.billingCycleStartDay,
    super.index,
    required super.name,
    super.icon,
    super.color,
    required this.initialBalance,
  });

  factory Account.fromMap(Map<String, dynamic> map, String id) {
    return Account(
      accountholder: map['accountholder'],
      type: map['type'],
      balance: map['balance'] != null ? (map['balance'] as num).toDouble() : 0.0,
      name: map['name'] ?? '',
      accountNumber: map['accountNumber'],
      creditLimit: map['creditLimit'] != null
          ? (map['creditLimit'] as num).toDouble()
          : null,
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
      billingCycleStartDay: map['billingCycleStartDay'] != null
          ? (map['billingCycleStartDay'] as Timestamp).toDate()
          : null,
      index: map['index'] != null
          ? (map['index'] as num).toInt()
          : null, // Optional index field
      icon: map['icon'],
      color: map['color'],
      initialBalance: map['initialBalance'] != null
          ? (map['initialBalance'] as num).toDouble()
          : 0.0, // Default to 0.0 if not present
    );
  }

  factory Account.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Account.fromMap(data, snapshot.id);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'accountholder': accountholder,
      'type': type,
      'balance': balance,
      'accountNumber': accountNumber,
      'creditLimit': creditLimit,
      'dueDate': dueDate,
      'billingCycleStartDay': billingCycleStartDay,
      'index': index, // Optional index field
      'initialBalance': initialBalance,
      ...super.toMapStructure(), // Include inherited properties from Structure
      // Only for credit accounts
    };
  }
}
