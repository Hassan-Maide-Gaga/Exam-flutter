class Facture {
  final int id;
  final String reference;
  final String walletCode;
  final String serviceName;
  final double amount;
  final DateTime dueDate;
  final String period;
  final bool paid;
  final DateTime? paidDate;

  Facture({
    required this.id,
    required this.reference,
    required this.walletCode,
    required this.serviceName,
    required this.amount,
    required this.dueDate,
    required this.period,
    required this.paid,
    this.paidDate,
  });

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      id: json['id'],
      reference: json['reference'],
      walletCode: json['walletCode'],
      serviceName: json['serviceName'],
      amount: json['amount'].toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      period: json['period'],
      paid: json['paid'],
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'])
          : null,
    );
  }
}