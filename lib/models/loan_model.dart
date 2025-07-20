import 'package:cloud_firestore/cloud_firestore.dart';

class LoanModel {
  final String loanId;
  final String type;
  final String partyName;
  final bool isEMI;
  final double principalAmount;
  final double interestRate;
  final String currency;
  final DateTime startDate;
  final String compoundingFrequency;
  final String repaymentFrequency;
  final double totalAmountPaid;
  final double balanceAmount;
  final String status;
  final String notes;
  final List<Installment> installments;

  LoanModel({
    required this.loanId, 
    required this.type,
    required this.partyName,
    required this.isEMI,
    required this.principalAmount,
    required this.interestRate,
    required this.currency,
    required this.startDate,
    required this.compoundingFrequency,
    required this.repaymentFrequency,
    required this.totalAmountPaid,
    required this.balanceAmount,
    required this.status,
    required this.notes,
    required this.installments,
  });

  factory LoanModel.fromMap(Map<String, dynamic> map, String id) {
    return LoanModel(
      loanId: id,
      type: map['type'],
      partyName: map['partyName'],
      isEMI: map['isEMI'],
      principalAmount: (map['principalAmount'] as num).toDouble(),
      interestRate: (map['interestRate'] as num).toDouble(),
      currency: map['currency'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      compoundingFrequency: map['compoundingFrequency'],
      repaymentFrequency: map['repaymentFrequency'],
      totalAmountPaid: (map['totalAmountPaid'] as num).toDouble(),
      balanceAmount: (map['balanceAmount'] as num).toDouble(),
      status: map['status'],
      notes: map['notes'],
      installments: (map['installments'] as List?)?.map((e) => Installment.fromMap(Map<String, dynamic>.from(e))).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'partyName': partyName,
      'isEMI': isEMI,
      'principalAmount': principalAmount,
      'interestRate': interestRate,
      'currency': currency,
      'startDate': Timestamp.fromDate(startDate),
      'compoundingFrequency': compoundingFrequency,
      'repaymentFrequency': repaymentFrequency,
      'totalAmountPaid': totalAmountPaid,
      'balanceAmount': balanceAmount,
      'status': status,
      'notes': notes,
      'installments': installments.map((e) => e.toMap()).toList(),
    };
  }
}

class Installment {
  final String installmentId;
  final DateTime dueDate;
  final double scheduledAmount;
  final double paidAmount;
  final DateTime? paidDate;
  final String status;
  final String? transactionId;

  Installment({
    required this.installmentId,
    required this.dueDate,
    required this.scheduledAmount,
    required this.paidAmount,
    this.paidDate,
    required this.status,
    this.transactionId,
  });

  factory Installment.fromMap(Map<String, dynamic> map) {
    return Installment(
      installmentId: map['installmentId'],
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      scheduledAmount: (map['scheduledAmount'] as num).toDouble(),
      paidAmount: (map['paidAmount'] as num).toDouble(),
      paidDate: map['paidDate'] != null ? (map['paidDate'] as Timestamp).toDate() : null,
      status: map['status'],
      transactionId: map['transactionId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'installmentId': installmentId,
      'dueDate': Timestamp.fromDate(dueDate),
      'scheduledAmount': scheduledAmount,
      'paidAmount': paidAmount,
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'status': status,
      'transactionId': transactionId,
    };
  }
}
