import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/dashboard_provider.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_transactions.dart';
import '../../auth/providers/auth_provider.dart';

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
          // 🔔 Bouton de notification (optionnel)
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Afficher les notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Aucune notification'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          // 🚪 Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
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

  /// 🔒 Affiche la boîte de dialogue de confirmation de déconnexion
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.logout, color: AppTheme.errorColor),
              SizedBox(width: 8),
              Text('Déconnexion'),
            ],
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
                _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Se déconnecter'),
            ),
          ],
        );
      },
    );
  }

  /// 🚪 Exécute la déconnexion
  Future<void> _logout(BuildContext context) async {
    // Afficher un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 1. Récupérer le provider d'authentification
      final authProvider = context.read<AuthProvider>();
      
      // 2. Effectuer la déconnexion
      await authProvider.logout();
      
      // 3. Fermer le loader
      Navigator.pop(context);
      
      // 4. Afficher un message de succès
      Fluttertoast.showToast(
        msg: 'Déconnecté avec succès',
        backgroundColor: AppTheme.successColor,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
      
      // 5. Naviguer vers l'écran de connexion avec suppression de l'historique
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false, // Supprime toutes les routes précédentes
      );
      
    } catch (e) {
      // En cas d'erreur
      Navigator.pop(context); // Fermer le loader
      
      Fluttertoast.showToast(
        msg: 'Erreur lors de la déconnexion',
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
      
      print('❌ Erreur déconnexion: $e');
    }
  }
}