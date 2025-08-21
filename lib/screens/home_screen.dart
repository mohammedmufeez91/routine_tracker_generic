import 'package:flutter/material.dart';

class HomeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const HomeTile({super.key, required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Routine Tracker')),
      body: ListView(
        children: [
          HomeTile(
            title: 'Manage Time Slots',
            subtitle: 'Create master time labels with clock times',
            icon: Icons.access_time,
            onTap: () => Navigator.pushNamed(context, '/timeslots'),
          ),
          HomeTile(
            title: 'Create Template',
            subtitle: 'Topic, target count, time slot, number of days',
            icon: Icons.post_add,
            onTap: () => Navigator.pushNamed(context, '/create-template'),
          ),
          HomeTile(
            title: 'Daily',
            subtitle: 'See today\'s items and tick them off',
            icon: Icons.today,
            onTap: () => Navigator.pushNamed(context, '/daily'),
          ),
          HomeTile(
            title: 'Stats',
            subtitle: 'View streaks and completion calendar',
            icon: Icons.bar_chart,
            onTap: () => Navigator.pushNamed(context, '/stats'),
          ),
          HomeTile(
            title: 'Set Goal',
            subtitle: 'Set the goal you want to achieve',
            icon: Icons.bar_chart,
            onTap: () => Navigator.pushNamed(context, '/goalsetting'),
          ),
          HomeTile(
            title: 'Analytics',
            subtitle: 'Look into the details of your progress',
            icon: Icons.analytics,
            onTap: () {
              Navigator.pushNamed(context, '/analytics');
            },
          ),
        ],
      ),
    );
  }
}
