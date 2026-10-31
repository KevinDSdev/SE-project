import 'package:flutter/material.dart';
import '../../investment/presentation/investment_portfolio_screen.dart';
import '../../subscription/presentation/recurring_subscriptions_screen.dart';

class DebtDashboardScreen extends StatefulWidget {
  const DebtDashboardScreen({super.key});

  @override
  State<DebtDashboardScreen> createState() => _DebtDashboardScreenState();
}

class _DebtDashboardScreenState extends State<DebtDashboardScreen> {
  int _selectedSubTab = 0; // 0: Debt & BNPL, 1: Investments, 2: Subscriptions

  final List<String> _titles = const [
    'Debt & BNPL Dashboard',
    'Investment Portfolio',
    'Recurring & Subscriptions',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1420),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1420),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
          onPressed: () {},
        ),
        title: Text(
          _titles[_selectedSubTab],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // 1. DYNAMIC SUB-VIEW CONTENT
          Expanded(
            child: IndexedStack(
              index: _selectedSubTab,
              children: [
                _buildDebtAndBnplView(),
                const InvestmentPortfolioScreen(),
                const RecurringSubscriptionsScreen(),
              ],
            ),
          ),

          // 2. BOTTOM STICKY SUB-TAB PILL BAR
          Container(
            color: const Color(0xFF0F1420),
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF181F2E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  _buildSubTabChip(0, 'Debt & BNPL'),
                  _buildSubTabChip(1, 'Investments'),
                  _buildSubTabChip(2, 'Subscriptions'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabChip(int index, String label) {
    final isSelected = _selectedSubTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSubTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFA6E22E) : Colors.transparent,
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

  Widget _buildDebtAndBnplView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Outstanding Debt Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF181F2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Outstanding Debt', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    Text('OCTOBER 2026', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('LKR 465,000', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      Expanded(flex: 60, child: Container(height: 6, color: const Color(0xFFA6E22E))),
                      Expanded(flex: 15, child: Container(height: 6, color: const Color(0xFF2D5A27))),
                      Expanded(flex: 25, child: Container(height: 6, color: const Color(0xFF1E3A5F))),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF231B15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade900.withOpacity(0.3)),
                        ),
                        child: const Column(
                          children: [
                            Text('Credit Cards', style: TextStyle(color: Colors.amber, fontSize: 10)),
                            SizedBox(height: 2),
                            Text('LKR 285,000', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF152317),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade900.withOpacity(0.3)),
                        ),
                        child: const Column(
                          children: [
                            Text('Koko & Mintpay', style: TextStyle(color: Colors.lightGreen, fontSize: 10)),
                            SizedBox(height: 2),
                            Text('LKR 65,000', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF122033),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade900.withOpacity(0.3)),
                        ),
                        child: const Column(
                          children: [
                            Text('Bank Loans', style: TextStyle(color: Colors.lightBlue, fontSize: 10)),
                            SizedBox(height: 2),
                            Text('LKR 115,000', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFA6E22E)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('+ Add Debt', style: TextStyle(color: Color(0xFFA6E22E), fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA6E22E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('+ Add BNPL Plan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('ACTIVE BNPL PLANS (KOKO & MINTPAY)', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF181F2E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(8)),
                      alignment: Alignment.center,
                      child: const Text('SINGER', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Singer Mega - LG Smart TV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('LKR 35,000', style: TextStyle(color: Color(0xFFA6E22E), fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('LKR 17,500 due 26 Oct', style: TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Row(
                    children: [
                      Expanded(flex: 33, child: Container(height: 4, color: const Color(0xFFA6E22E))),
                      Expanded(flex: 67, child: Container(height: 4, color: Colors.white12)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1 of 3 Paid', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    Text('Remaining: 2 installments', style: TextStyle(color: Color(0xFFA6E22E), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('CREDIT CARDS & BANK LOANS', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          _buildCardItem(
            bankName: 'ComBank Platinum (••4821)',
            amount: 'LKR 185,000',
            available: 'Available: LKR 215,000',
            accentColor: Colors.orange,
            logoColor: Colors.blue,
          ),
          const SizedBox(height: 10),
          _buildCardItem(
            bankName: 'HNB World (••9012)',
            amount: 'LKR 100,000',
            available: 'Available: LKR 150,000',
            accentColor: Colors.lightBlue,
            logoColor: Colors.lightBlue,
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Synced with BOC Flex & Local Banks • Updated Today',
              style: TextStyle(color: Colors.white30, fontSize: 11),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCardItem({
    required String bankName,
    required String amount,
    required String available,
    required Color accentColor,
    required Color logoColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181F2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: logoColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: Icon(Icons.credit_card, color: logoColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(bankName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(amount, style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(available, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Row(
              children: [
                Expanded(flex: 50, child: Container(height: 4, color: accentColor)),
                Expanded(flex: 50, child: Container(height: 4, color: Colors.white12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}