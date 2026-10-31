import 'package:flutter/material.dart';

class RecordInvestmentScreen extends StatefulWidget {
  const RecordInvestmentScreen({super.key});

  @override
  State<RecordInvestmentScreen> createState() => _RecordInvestmentScreenState();
}

class _RecordInvestmentScreenState extends State<RecordInvestmentScreen> {
  bool _preAllocateToBudgets = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1420),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1420),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('New Fixed Deposit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Principal Amount Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF181F2E), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PRINCIPAL DEPOSIT AMOUNT', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Text('LKR ', style: TextStyle(color: Color(0xFFA6E22E), fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('1,200,000', style: TextStyle(color: Color(0xFFA6E22E), fontSize: 26, fontWeight: FontWeight.bold)),
                      Text('.00', style: TextStyle(color: Colors.white54, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF122033), borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 4, backgroundColor: Colors.lightBlueAccent),
                        SizedBox(width: 6),
                        Text('Commercial Bank • 12-Month FD', style: TextStyle(color: Colors.lightBlueAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Deposit Spec Details Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF181F2E), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Interest Rate', style: TextStyle(color: Colors.white38, fontSize: 11)), Text('12.00% p.a.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))]),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Deposit Tenure', style: TextStyle(color: Colors.white38, fontSize: 11)), Text('12 Months', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))]),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Maturity Date', style: TextStyle(color: Colors.white38, fontSize: 11)), Text('15 Oct 2027', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))]),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Expected Maturity Interest:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('+LKR 144,000.00', style: TextStyle(color: Color(0xFFA6E22E), fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Pre-allocation Toggle Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PRE-ALLOCATE TO FUTURE BUDGETS (DEB-08)', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text('Pre-assign maturity payout to future monthly budget buckets', style: TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ),
                Switch(
                  value: _preAllocateToBudgets,
                  activeColor: const Color(0xFFA6E22E),
                  onChanged: (val) => setState(() => _preAllocateToBudgets = val),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_preAllocateToBudgets) ...[
              _buildAllocationCard('Emergency Reserve Budget', 'Target fund for unexpected expenses', '50% (LKR 72,000)', Icons.shield_outlined),
              const SizedBox(height: 10),
              _buildAllocationCard('Holiday & Travel Budget', 'Pre-allocated for Oct 2027 trip', '50% (LKR 72,000)', Icons.flight_takeoff_rounded),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF152317), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.shade900.withOpacity(0.4))),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFFA6E22E), size: 16),
                    SizedBox(width: 8),
                    Text('100% of Maturity Payout Pre-Allocated (LKR 144,000)', style: TextStyle(color: Color(0xFFA6E22E), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA6E22E),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirm & Record Investment', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationCard(String title, String subtitle, String percentage, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF181F2E), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.white, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
          Text(percentage, style: const TextStyle(color: Color(0xFFA6E22E), fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}