import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/facture.dart';

class BillItem extends StatelessWidget {
  final Facture facture;
  final bool isSelected;
  final VoidCallback onToggle;

  const BillItem({
    super.key,
    required this.facture,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (_) => onToggle(),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _getServiceColor(facture.serviceName).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                facture.serviceName,
                style: TextStyle(
                  color: _getServiceColor(facture.serviceName),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const Spacer(),
            Text(
              NumberFormat.currency(
                locale: 'fr_SN',
                symbol: 'XOF ',
                decimalDigits: 0,
              ).format(facture.amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Réf: ${facture.reference}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              'Échéance: ${DateFormat('dd/MM/yyyy').format(facture.dueDate)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        secondary: Icon(
          Icons.receipt,
          color: _getServiceColor(facture.serviceName),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Color _getServiceColor(String service) {
    final colors = {
      'ISM': Colors.blue,
      'WOYAFAL': Colors.orange,
      'SENELEC': Colors.green,
      'SONATEL': Colors.purple,
      'RAPIDO': Colors.red,
      'ORANGE_MONEY': Colors.orange,
      'WAVE': Colors.teal,
    };
    return colors[service] ?? Colors.grey;
  }
}