import 'package:flutter/material.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1420),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1420),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Add Transaction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expense / Income Segmented Control
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFF181F2E), borderRadius: BorderRadius.circular(30)),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: const Color(0xFFA6E22E), borderRadius: BorderRadius.circular(24)),
                      child: const Text('Expense', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      child: const Text('Income', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Amount Display Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF181F2E), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text('Enter Amount Spent', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('LKR ', style: TextStyle(color: Color(0xFFA6E22E), fontSize: 26, fontWeight: FontWeight.bold)),
                      Text('3,150', style: TextStyle(color: Color(0xFFA6E22E), fontSize: 32, fontWeight: FontWeight.bold)),
                      Text('.00', style: TextStyle(color: Colors.white54, fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Tap to edit amount with keypad', style: TextStyle(color: Colors.white24, fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Merchant Name Input Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFF181F2E), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  CircleAvatar(radius: 14, backgroundColor: Colors.red, child: Text('🍕', style: TextStyle(fontSize: 12))),
                  SizedBox(width: 10),
                  Expanded(child: Text('Pizza Hut Sri Lanka (Colombo)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Category', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                Text('Required', style: TextStyle(color: Color(0xFFA6E22E), fontSize: 11)),
              ],
            ),
            const SizedBox(height: 10),
            // Category Selector Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildCatCard('Dining', Icons.restaurant, true, 'Selected'),
                _buildCatCard('Groceries', Icons.shopping_basket_outlined, false, 'Cap: 65K'),
                _buildCatCard('Transport', Icons.directions_bus_outlined, false, 'Cap: 30K'),
                _buildCatCard('Shopping', Icons.shopping_bag_outlined, false, 'Cap: 25K'),
                _buildCatCard('Bills / CEB', Icons.receipt_long_outlined, false, 'Fixed Bills'),
                _buildCatCard('Savings', Icons.account_balance_wallet_outlined, false, 'Goal Fund'),
              ],
            ),
            const SizedBox(height: 20),
            // OCR Receipt Scanner Action Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF181F2E), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.camera_alt_outlined, color: Colors.white)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Capture Receipt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('Take a photo to auto-extract details', style: TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Scan', style: TextStyle(color: Color(0xFFA6E22E), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA6E22E),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirm & Add Transaction', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatCard(String title, IconData icon, bool isSelected, String sub) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF152317) : const Color(0xFF181F2E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? const Color(0xFFA6E22E) : Colors.transparent, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFFA6E22E) : Colors.white54, size: 20),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 11)),
          Text(sub, style: TextStyle(color: isSelected ? const Color(0xFFA6E22E) : Colors.white38, fontSize: 9)),
        ],
      ),
    );
  }
}