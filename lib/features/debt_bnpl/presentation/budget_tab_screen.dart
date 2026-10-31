import 'package:flutter/material.dart';
import 'debt_dashboard_screen.dart';
import '../../investment/presentation/investment_portfolio_screen.dart';
import '../../subscription/presentation/recurring_subscriptions_screen.dart';

class BudgetTabScreen extends StatefulWidget {
  const BudgetTabScreen({super.key});

  @override
  State<BudgetTabScreen> createState() => _BudgetTabScreenState();
}

class _BudgetTabScreenState extends State<BudgetTabScreen> {
  int _selectedSubTab = 0; // 0: Debt & BNPL, 1: Investments, 2: Subscriptions

  final List<Widget> _subViews = const [
    DebtDashboardScreen(),
    InvestmentPortfolioScreen(),
    RecurringSubscriptionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const primaryLime = Color(0xFFA6E22E);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1420),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Sub-Tab Header Segmented Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF181F2E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    _buildSubTabChip(index: 0, label: 'Debt & BNPL'),
                    _buildSubTabChip(index: 1, label: 'Investments'),
                    _buildSubTabChip(index: 2, label: 'Subscriptions'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Main Sub-View Content Body
            Expanded(
              child: IndexedStack(
                index: _selectedSubTab,
                children: _subViews,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTabChip({required int index, required String label}) {
    final isSelected = _selectedSubTab == index;
    const primaryLime = Color(0xFFA6E22E);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSubTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? primaryLime : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF0F1420) : Colors.white54,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}