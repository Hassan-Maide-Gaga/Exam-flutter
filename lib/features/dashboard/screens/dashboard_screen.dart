import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_transactions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BadWallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logique de déconnexion
            },
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          if (provider.error != null) {
            return ErrorWidgetCustom(
              message: provider.error!,
              onRetry: () => provider.loadDashboard(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadDashboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BalanceCard(
                    balance: provider.balance,
                    currency: 'XOF',
                    onToggleVisibility: provider.toggleBalanceVisibility,
                    isVisible: provider.isBalanceVisible,
                  ),
                  const SizedBox(height: 16),
                  QuickActions(
                    onTransfer: () {
                      Navigator.pushNamed(context, '/transfer');
                    },
                    onPay: () {
                      Navigator.pushNamed(context, '/bills');
                    },
                    onHistory: () {
                      Navigator.pushNamed(context, '/history');
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Transactions récentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RecentTransactions(
                    transactions: provider.recentTransactions,
                    onViewAll: () {
                      Navigator.pushNamed(context, '/history');
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}