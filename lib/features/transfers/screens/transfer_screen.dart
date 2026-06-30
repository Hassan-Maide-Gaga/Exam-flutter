import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/transfer_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receiverController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _receiverController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transférer de l\'argent'),
      ),
      body: Consumer<TransferProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildReceiverField(),
                          const SizedBox(height: 16),
                          _buildAmountField(provider),
                          const SizedBox(height: 16),
                          _buildDescriptionField(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSummary(provider),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Transférer',
                    isLoading: provider.isLoading,
                    onPressed: () => _submitTransfer(provider),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Vous pouvez transférer jusqu\'à votre solde disponible',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReceiverField() {
    return TextFormField(
      controller: _receiverController,
      decoration: const InputDecoration(
        labelText: 'Numéro du destinataire',
        prefixIcon: Icon(Icons.person),
        hintText: '+221 77 123 45 67',
      ),
      keyboardType: TextInputType.phone,
      validator: Validators.validatePhone,
      enabled: !Provider.of<TransferProvider>(context, listen: false).isLoading,
    );
  }

  Widget _buildAmountField(TransferProvider provider) {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Montant (XOF)',
        prefixIcon: Icon(Icons.attach_money),
        hintText: '0',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez saisir un montant';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Veuillez saisir un montant valide';
        }
        if (amount > provider.availableBalance) {
          return 'Montant supérieur au solde disponible';
        }
        return null;
      },
      enabled: !provider.isLoading,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description (Optionnel)',
        prefixIcon: Icon(Icons.note),
        hintText: 'Motif du transfert',
      ),
      enabled: !Provider.of<TransferProvider>(context, listen: false).isLoading,
    );
  }

  Widget _buildSummary(TransferProvider provider) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final receiver = _receiverController.text.trim();

    if (amount <= 0 || receiver.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Récapitulatif',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow('De', provider.phone ?? '---'),
            _buildSummaryRow('À', receiver),
            _buildSummaryRow('Montant', '${amount.toStringAsFixed(0)} XOF'),
            _buildSummaryRow('Frais', '0 XOF'),
            const Divider(),
            _buildSummaryRow(
              'Total',
              '${amount.toStringAsFixed(0)} XOF',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppTheme.primaryColor : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppTheme.primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTransfer(TransferProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final receiver = _receiverController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;
    final description = _descriptionController.text.trim();

    final success = await provider.transfer(receiver, amount);

    if (!mounted) return;

    if (success) {
      Fluttertoast.showToast(
        msg: 'Transfert effectué avec succès ✅',
        backgroundColor: AppTheme.successColor,
        textColor: Colors.white,
      );
      _receiverController.clear();
      _amountController.clear();
      _descriptionController.clear();
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
        msg: provider.error ?? 'Erreur lors du transfert',
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
    }
  }
}