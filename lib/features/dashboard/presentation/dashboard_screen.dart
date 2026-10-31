import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1420),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 90.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: User Welcome Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Welcome back,',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Developer 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFF6366F1),
                    child: Text(
                      'D',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hero Scaffolding Status Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E2A72), Color(0xFF1E1B4B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'FLUTTER 3.47 + RIVERPOD',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Icon(Icons.verified, color: Colors.lightBlueAccent, size: 20),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ready for Android & iOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Universal project scaffolding with state management, custom themes, and clean architecture.',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section: Key Metrics
              const Text(
                'Key Metrics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _buildMetricCard(
                    icon: Icons.check_circle_outline_rounded,
                    iconBg: Colors.indigo.shade900.withOpacity(0.5),
                    iconColor: Colors.indigoAccent,
                    tagText: '+12%',
                    tagColor: Colors.greenAccent,
                    value: '24',
                    label: 'Active Tasks',
                  ),
                  _buildMetricCard(
                    icon: Icons.rocket_launch_outlined,
                    iconBg: Colors.teal.shade900.withOpacity(0.5),
                    iconColor: Colors.tealAccent,
                    tagText: '99.4%',
                    tagColor: Colors.tealAccent,
                    value: '148',
                    label: 'App Builds',
                  ),
                  _buildMetricCard(
                    icon: Icons.speed_rounded,
                    iconBg: Colors.teal.shade900.withOpacity(0.3),
                    iconColor: Colors.lightGreenAccent,
                    tagText: 'Smooth',
                    tagColor: Colors.lightGreenAccent,
                    value: '60 FPS',
                    label: 'Performance',
                  ),
                  _buildMetricCard(
                    icon: Icons.devices_rounded,
                    iconBg: Colors.pink.shade900.withOpacity(0.3),
                    iconColor: Colors.pinkAccent,
                    tagText: 'Native',
                    tagColor: Colors.tealAccent,
                    value: 'Android/iOS',
                    label: 'Platforms',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section: Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionButton(Icons.add_circle_outline, 'New Screen'),
                  _buildQuickActionButton(Icons.sync_rounded, 'Sync Data'),
                  _buildQuickActionButton(Icons.science_outlined, 'Run Tests'),
                  _buildQuickActionButton(Icons.file_download_outlined, 'Export'),
                ],
              ),
              const SizedBox(height: 24),

              // Section: Recent Activity
              const Text(
                'Recent Activity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildActivityTile(
                icon: Icons.check_circle,
                iconColor: const Color(0xFFA6E22E),
                title: 'Flutter SDK Configured',
                subtitle: 'Flutter 3.47 installed with stable Dart runtime',
                time: 'Just now',
              ),
              const SizedBox(height: 10),
              _buildActivityTile(
                icon: Icons.hub,
                iconColor: Colors.indigoAccent,
                title: 'Riverpod Provider Added',
                subtitle: 'State management layer initialized with Auth & Theme',
                time: '5m ago',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String tagText,
    required Color tagColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tagText,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF181F2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Icon(icon, color: Colors.white70, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF181F2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}