import 'package:flutter/material.dart';

enum TransactionType {
  DEPOSIT,
  WITHDRAWAL,
  TRANSFER,
  PAYMENT,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.DEPOSIT:
        return 'Dépôt';
      case TransactionType.WITHDRAWAL:
        return 'Retrait';
      case TransactionType.TRANSFER:
        return 'Transfert';
      case TransactionType.PAYMENT:
        return 'Paiement';
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.DEPOSIT:
        return const Color(0xFF2E7D32);
      case TransactionType.WITHDRAWAL:
        return const Color(0xFFC62828);
      case TransactionType.TRANSFER:
        return const Color(0xFF0D47A1);
      case TransactionType.PAYMENT:
        return const Color(0xFFE65100);
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.DEPOSIT:
        return Icons.arrow_downward;
      case TransactionType.WITHDRAWAL:
        return Icons.arrow_upward;
      case TransactionType.TRANSFER:
        return Icons.swap_horiz;
      case TransactionType.PAYMENT:
        return Icons.payment;
    }
  }

  // ✅ AJOUT : Vérifier si c'est un revenu
  bool get isIncome {
    return this == TransactionType.DEPOSIT;
  }
}

class Transaction {
  final int id;
  final String reference;
  final TransactionType type;
  final double amount;
  final double fee;
  final String description;
  final DateTime transactionDate;
  final String? recipientPhone;
  final String? serviceName;

  Transaction({
    required this.id,
    required this.reference,
    required this.type,
    required this.amount,
    required this.fee,
    required this.description,
    required this.transactionDate,
    this.recipientPhone,
    this.serviceName,
  });

  // ✅ AJOUT : Propriété calculée pour savoir si c'est un revenu
  bool get isIncome => type.isIncome;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // ✅ Gestion des valeurs null
    final typeStr = json['type'] ?? 'DEPOSIT';
    TransactionType type;
    try {
      type = TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.$typeStr',
        orElse: () => TransactionType.DEPOSIT,
      );
    } catch (e) {
      type = TransactionType.DEPOSIT;
    }

    return Transaction(
      id: json['id'] ?? 0,
      reference: json['reference'] ?? 'N/A',
      type: type,
      amount: (json['amount'] ?? 0).toDouble(),
      fee: (json['fee'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'])
          : DateTime.now(),
      recipientPhone: json['recipientPhone'],
      serviceName: json['serviceName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'type': type.toString().split('.').last,
      'amount': amount,
      'fee': fee,
      'description': description,
      'transactionDate': transactionDate.toIso8601String(),
      'recipientPhone': recipientPhone,
      'serviceName': serviceName,
    };
  }
}