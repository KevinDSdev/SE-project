import 'package:flutter/material.dart';

class InvestmentPortfolioScreen extends StatelessWidget {
  const InvestmentPortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Investment Value Card
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
                    Text('Total Investment Value', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    Text('OCTOBER 2026', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('LKR 2,850,000', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF152317),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade900.withOpacity(0.4)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Expected Interest', style: TextStyle(color: Colors.white54, fontSize: 10)),
                            SizedBox(height: 4),
                            Text('+LKR 384,750', style: TextStyle(color: Color(0xFFA6E22E), fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF122033),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade900.withOpacity(0.4)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Maturity Portfolio Value', style: TextStyle(color: Colors.white54, fontSize: 10)),
                            SizedBox(height: 4),
                            Text('LKR 3,234,750', style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 13)),
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
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA6E22E),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('+ Add New Investment / Fixed Deposit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          const Text('ACTIVE FIXED DEPOSITS (3 ACCOUNTS)', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          _buildFdItem('Commercial Bank - 12M', 'LKR 1,200,000', 'Matures: 15 Mar 2027', 0.65, Colors.blue),
          const SizedBox(height: 10),
          _buildFdItem('Sampath Bank - 6M', 'LKR 850,000', 'Matures: 02 Dec 2026', 0.85, Colors.amber),
          const SizedBox(height: 24),
          const Text('PRE-ALLOCATED RETURNS TO FUTURE BUDGETS', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          _buildPreAllocItem('Dec 2026 • HNB FD Maturity Payout', '+LKR 56,312', "Assigned to: 'Holiday Travel Budget'"),
          const SizedBox(height: 10),
          _buildPreAllocItem('Mar 2027 • ComBank Payout', '+LKR 168,000', "Assigned to: 'Emergency Reserve'"),
        ],
      ),
    );
  }

  Widget _buildFdItem(String title, String amount, String maturity, double progress, Color bankColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF181F2E), borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: bankColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.account_balance, color: bankColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(maturity, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation(bankColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildPreAllocItem(String title, String amount, String budgetTarget) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF181F2E), borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.blue.shade900.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
                  child: Text(budgetTarget, style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 10)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(color: Color(0xFFA6E22E), fontWeight: FontWeight.bold, fontSize: 13)),
              const Text('Pre-assigned 100%', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}