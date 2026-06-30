import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onTransfer;
  final VoidCallback onPay;
  final VoidCallback onHistory;

  const QuickActions({
    super.key,
    required this.onTransfer,
    required this.onPay,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.send,
          label: 'Transférer',
          color: AppTheme.primaryColor,
          onTap: onTransfer,
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon: Icons.receipt_long,
          label: 'Payer',
          color: AppTheme.warningColor,
          onTap: onPay,
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon: Icons.history,
          label: 'Historique',
          color: AppTheme.primaryLight,
          onTap: onHistory,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}