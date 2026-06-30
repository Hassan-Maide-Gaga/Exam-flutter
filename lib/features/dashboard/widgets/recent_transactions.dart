import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/transaction.dart';
import '../../../core/theme/app_theme.dart';

class RecentTransactions extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onViewAll;

  const RecentTransactions({
    super.key,
    required this.transactions,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Aucune transaction récente',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dernières transactions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Voir tout'),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          ...transactions.take(5).map((t) => _buildTransactionTile(t)),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    // ✅ Utilisation de la propriété isIncome
    final isIncome = transaction.isIncome;
    final amountColor = isIncome ? AppTheme.successColor : AppTheme.errorColor;
    final amountPrefix = isIncome ? '+' : '-';

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: transaction.type.color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          transaction.type.icon,
          color: transaction.type.color,
          size: 20,
        ),
      ),
      title: Text(
        transaction.type.displayName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        DateFormat('dd/MM/yyyy HH:mm').format(transaction.transactionDate),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        '$amountPrefix ${NumberFormat.currency(locale: 'fr_SN', symbol: 'XOF', decimalDigits: 0).format(transaction.amount)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: amountColor,
        ),
      ),
      isThreeLine: false,
      dense: true,
    );
  }
}