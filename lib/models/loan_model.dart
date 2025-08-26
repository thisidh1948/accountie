import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoanModel {
  String loanId;
  bool isGiven;
  bool isEmi;
  String partyName;
  String? notes;
  int? compoundFrequency;
  int? correctedAmount;
  double principalAmount;
  double balanceAmount;
  double? monthlyPayment;
  double interestRate;
  DateTime startDate;
  DateTime? endDate;
  List<Installment> installments;
  bool isOpen;

  LoanModel({
    required this.loanId,
    required this.isGiven,
    required this.partyName,
    required this.principalAmount,
    required this.interestRate,
    required this.startDate,
    required this.isOpen,
    this.notes,
    required this.installments,
    required this.endDate,
    required this.balanceAmount,
    required this.monthlyPayment,
    required this.isEmi,
    this.compoundFrequency,
    this.correctedAmount,
  });

  factory LoanModel.fromMap(Map<String, dynamic> map, String id) {
    return LoanModel(
      loanId: id,
      isGiven: map['isGiven'] ?? false,
      partyName: map['partyName'],
      isEmi: map['isEmi'] ?? false,
      principalAmount: (map['principalAmount'] as num).toDouble(),
      interestRate: (map['interestRate'] as num).toDouble(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      isOpen: map['isOpen'] ?? true,
      notes: map['notes'],
      installments: (map['installments'] as List?)
              ?.map((e) => Installment.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      balanceAmount: (map['balanceAmount'] as num).toDouble(),
      monthlyPayment: map['monthlyPayment'] != null
          ? (map['monthlyPayment'] as num).toDouble()
          : 0.0,
      compoundFrequency: map['compoundFrequency'] != null
          ? map['compoundFrequency'] as int?
          : null,
      correctedAmount: map['correctedAmount'] != null
          ? (map['correctedAmount'] as int?)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isGiven': isGiven,
      if (isEmi) 'isEmi': isEmi,
      'partyName': partyName,
      'principalAmount': principalAmount,
      'interestRate': interestRate,
      'startDate': Timestamp.fromDate(startDate),
      'isOpen': isOpen,
      'notes': notes,
      'installments': installments.map((e) => e.toMap()).toList(),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      'balanceAmount': balanceAmount,
      if (monthlyPayment != null) 'monthlyPayment': monthlyPayment,
      if (compoundFrequency != null) 'compoundFrequency': compoundFrequency,
      if (correctedAmount != null) 'correctedAmount': correctedAmount,
    };
  }

  get TotalIntersetPaid {
    return installments
        .where((e) => e.isPaid)
        .fold(0.0, (sum, e) => sum + e.interestComponent);
  }

  get TotalPrincipalPaid {
    return installments
        .where((e) => e.isPaid)
        .fold(0.0, (sum, e) => sum + e.principalComponent);
  }

  get TotalPaid {
    return installments
        .where((e) => e.isPaid)
        .fold(0.0, (sum, e) => sum + (e.paidAmount ?? 0.0));
  }

  get TotalDue {
    return principalAmount - TotalPrincipalPaid;
  }

  int get daysInLoan {
    return startDate.difference(DateTime.now()).inDays;
  }

  void recalculateFromScratch() {
    balanceAmount = principalAmount;
    List<Installment> cpInstallments = List.from(installments);
    installments.clear();
    cpInstallments.sort(
        (a, b) => (a.paidDate ?? startDate).compareTo(b.paidDate ?? startDate));
    for (final inst in cpInstallments.where((e) => e.isPaid)) {
      payment(inst.paidAmount ?? 0.0, inst.paidDate ?? DateTime.now());
    }
  }

  void payment(double amount, DateTime paymentDate) {
    double interest = calculateCurrentInterest(referenceDate: paymentDate);
    final interestComponent = double.parse(interest.toStringAsFixed(2));
    final principalComponent = double.parse((amount - interestComponent)
        .clamp(0, balanceAmount)
        .toStringAsFixed(2));

    balanceAmount = balanceAmount + interestComponent - amount;
    balanceAmount =
        balanceAmount < 0 ? 0 : double.parse(balanceAmount.toStringAsFixed(2));

    print('intersetComp: ${interestComponent.toStringAsFixed(2)}');
    print('principalComp: ${principalComponent.toStringAsFixed(2)}');
    print('balanceAmount: ${balanceAmount.toStringAsFixed(2)}');
    
    installments.add(Installment(
      installmentId: 'PAY-${installments.length + 1}',
      interestComponent: (amount > interestComponent) ? interestComponent : amount,
      principalComponent: principalComponent,
      paidAmount: amount,
      paidDate: paymentDate,
      isPaid: true,
      transactionId: null,
    ));

    if (balanceAmount <= 0) {
      isOpen = false;
    }
  }

  double calculateCurrentInterest({DateTime? referenceDate}) {
    DateTime lastDate = startDate;

    if (installments.isNotEmpty && installments.any((i) => i.isPaid)) {
      lastDate = installments
          .where((i) => i.isPaid)
          .map((i) => i.paidDate ?? startDate)
          .fold(startDate, (a, b) => a.isAfter(b) ? a : b);
    }

    final days = (referenceDate ?? DateTime.now()).difference(lastDate).inDays;
    double interest = 0.0;

    print(days);

    if (days > 365) {
      int years = (days / 365).floor();
      int remainingDays = days % 365;
      double compounded = balanceAmount * pow(1 + (interestRate / 100), years);
      double remainingInterest =
          compounded * (interestRate / 100) * (remainingDays / 365);
      interest = (compounded + remainingInterest) - balanceAmount;
    } else {
      interest = (balanceAmount * (interestRate / 100)) * (days / 365);
    }
    return double.parse(interest.toStringAsFixed(2));
  }
}

class Installment {
  String installmentId;
  double interestComponent;
  double principalComponent;
  double paidAmount;
  DateTime? paidDate;
  bool isPaid;
  String? transactionId;

  Installment({
    required this.installmentId,
    required this.isPaid,
    required this.paidAmount,
    this.paidDate,
    this.transactionId,
    this.interestComponent = 0.0,
    this.principalComponent = 0.0,
  });

  factory Installment.fromMap(Map<String, dynamic> map) {
    return Installment(
      installmentId: map['installmentId'],
      paidAmount: (map['paidAmount'] as num).toDouble(),
      paidDate: map['paidDate'] != null
          ? (map['paidDate'] as Timestamp).toDate()
          : null,
      isPaid: map['isPaid'] ?? false,
      transactionId: map['transactionId'],
      interestComponent: map['interestComponent'] != null
          ? (map['interestComponent'] as num).toDouble()
          : 0.0,
      principalComponent: map['principalComponent'] != null
          ? (map['principalComponent'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'installmentId': installmentId,
      'paidAmount': paidAmount,
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'isPaid': isPaid,
      'transactionId': transactionId,
      'interestComponent': interestComponent,
      'principalComponent': principalComponent,
    };
  }
}
