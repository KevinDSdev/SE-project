import 'package:flutter/material.dart';

class RecurringSubscriptionsScreen extends StatelessWidget {
  const RecurringSubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly Total Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF181F2E), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Monthly Recurring Total', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    Text('OCTOBER 2026', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('LKR 84,500/mo', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildSummaryChip('Utilities', 'LKR 46,200', '3 bills active', Colors.blue),
                    const SizedBox(width: 6),
                    _buildSummaryChip('Subscriptions', 'LKR 13,300', '4 streaming/apps', Colors.lightGreen),
                    const SizedBox(width: 6),
                    _buildSummaryChip('Insurance', 'LKR 25,000', '1 premium active', Colors.amber),
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
                  child: const Text('+ Add Subscription', style: TextStyle(color: Color(0xFFA6E22E), fontWeight: FontWeight.bold, fontSize: 12)),
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
                  child: const Text('+ Add Recurring Bill', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('UPCOMING BILLS & REMINDERS (DUE THIS WEEK)', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          _buildUpcomingBill('CEB Electricity Bill', 'LKR 18,500', 'Due in 3 days (23 Oct)', Colors.amber.shade900),
          const SizedBox(height: 10),
          _buildUpcomingBill('Dialog Fiber', 'LKR 7,200', 'Due in 6 days (26 Oct)', Colors.orange.shade800),
          const SizedBox(height: 24),
          const Text('SUBSCRIPTION MANAGER (STATUS & CONTROLS)', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          _buildSubItem('Netflix 4K Premium', 'LKR 4,200/mo', 'Monthly • Visa ••4821 • Next: 28 Oct', Colors.red.shade900),
          const SizedBox(height: 10),
          _buildSubItem('Spotify Premium Family', 'LKR 2,100/mo', 'Monthly • Mastercard ••9012 • Next: 02 Nov', Colors.green.shade900),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label, String amount, String sub, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: accent, fontSize: 10)),
            const SizedBox(height: 2),
            Text(amount, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 8)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingBill(String title, String amount, String due, Color badgeColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF181F2E), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.flash_on, color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(due, style: const TextStyle(color: Colors.amber, fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const Text('Manage Bill', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubItem(String title, String amount, String details, Color logoColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF181F2E), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: logoColor, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(details, style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const Row(children: [CircleAvatar(radius: 3, backgroundColor: Color(0xFFA6E22E)), SizedBox(width: 4), Text('ACTIVE', style: TextStyle(color: Color(0xFFA6E22E), fontSize: 9, fontWeight: FontWeight.bold))]),
            ],
          ),
        ],
      ),
    );
  }
}