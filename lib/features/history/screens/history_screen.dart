import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../models/transaction.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedType = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistory();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = context.read<HistoryProvider>();
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 100) {
      provider.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des transactions'),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: Consumer<HistoryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.transactions.isEmpty) {
                  return const LoadingWidget();
                }

                if (provider.error != null && provider.transactions.isEmpty) {
                  return ErrorWidgetCustom(
                    message: provider.error!,
                    onRetry: () => provider.loadHistory(),
                  );
                }

                final transactions = provider.filteredTransactions;

                if (transactions.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucune transaction',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadHistory(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: transactions.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == transactions.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return _buildTransactionTile(transactions[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Tous', 'ALL'),
            const SizedBox(width: 8),
            _buildFilterChip('Dépôts', 'DEPOSIT'),
            const SizedBox(width: 8),
            _buildFilterChip('Retraits', 'WITHDRAWAL'),
            const SizedBox(width: 8),
            _buildFilterChip('Transferts', 'TRANSFER'),
            const SizedBox(width: 8),
            _buildFilterChip('Paiements', 'PAYMENT'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedType = value;
        });
        context.read<HistoryProvider>().filterByType(value);
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    // ✅ Utilisation de la propriété isIncome
    final isIncome = transaction.isIncome;
    final amountColor = isIncome ? AppTheme.successColor : AppTheme.errorColor;
    final amountPrefix = isIncome ? '+' : '-';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: transaction.type.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            transaction.type.icon,
            color: transaction.type.color,
            size: 24,
          ),
        ),
        title: Text(
          transaction.type.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.description.isNotEmpty)
              Text(
                transaction.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            // Text(
            //   DateFormat('dd/MM/yyyy HH:mm').format(transaction.transactionDate),
            //   style: const TextStyle(
            //     fontSize: 12,
            //     color: Colors.grey,
            //   ),
            // ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$amountPrefix ${transaction.amount.toStringAsFixed(0)} XOF',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: amountColor,
                fontSize: 16,
              ),
            ),
            if (transaction.fee > 0)
              Text(
                'Frais: ${transaction.fee.toStringAsFixed(0)} XOF',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        isThreeLine: transaction.description.isNotEmpty,
      ),
    );
  }
}