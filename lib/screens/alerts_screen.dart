import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/watchman_theme.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          TextButton(
            onPressed: state.markAllRead,
            child: const Text('Mark read', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: state.inbox.isEmpty
          ? const Center(child: Text('Quiet. Alerts will land here.'))
          : ListView.separated(
              itemCount: state.inbox.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final a = state.inbox[i];
                return ListTile(
                  leading: Icon(_icon(a.kind), color: _color(a.kind)),
                  title: Text(a.title, style: TextStyle(fontWeight: a.read ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text(a.body),
                  trailing: Text(
                    DateFormat.jm().format(a.at.toLocal()),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
    );
  }

  IconData _icon(AlertKind k) {
    switch (k) {
      case AlertKind.geofenceEnter:
        return Icons.login;
      case AlertKind.geofenceExit:
        return Icons.logout;
      case AlertKind.cry:
        return Icons.child_care;
      case AlertKind.sos:
        return Icons.sos;
      case AlertKind.lowBattery:
        return Icons.battery_alert;
      case AlertKind.info:
        return Icons.info_outline;
    }
  }

  Color _color(AlertKind k) {
    switch (k) {
      case AlertKind.sos:
      case AlertKind.cry:
        return WatchmanTheme.alert;
      case AlertKind.geofenceExit:
        return WatchmanTheme.amber;
      default:
        return WatchmanTheme.moss;
    }
  }
}
