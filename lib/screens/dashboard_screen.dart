import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/watchman_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final child = state.child;
    final fix = child.lastFix;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchman'),
        actions: [
          IconButton(
            tooltip: 'Demo SOS',
            onPressed: state.triggerSosDemo,
            icon: const Icon(Icons.sos),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ChildCard(child: child),
          const SizedBox(height: 12),
          if (fix != null) _FixCard(fix: fix, fences: state.fences),
          const SizedBox(height: 12),
          _CryCard(listening: state.cryListening, onChanged: state.toggleCry),
          const SizedBox(height: 12),
          _PairCard(pin: child.pairingPin ?? '------'),
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child});
  final ChildProfile child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: WatchmanTheme.pine,
              child: Text(
                child.displayName.isEmpty ? '?' : child.displayName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(child.displayName, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        child.watchConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                        size: 16,
                        color: child.watchConnected ? WatchmanTheme.moss : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(child.watchConnected ? 'Watchman linked (demo)' : 'Watchman offline'),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(
                  child.batteryPercent > 20 ? Icons.battery_std : Icons.battery_alert,
                  color: child.batteryPercent > 20 ? WatchmanTheme.moss : WatchmanTheme.alert,
                ),
                Text('${child.batteryPercent}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FixCard extends StatelessWidget {
  const _FixCard({required this.fix, required this.fences});
  final GeoPoint fix;
  final List<Geofence> fences;

  @override
  Widget build(BuildContext context) {
    final inside = fences.where((f) => f.enabled && f.contains(fix)).map((f) => f.name).toList();
    final when = fix.at == null ? '—' : DateFormat.jms().format(fix.at!.toLocal());
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last fix', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('${fix.lat.toStringAsFixed(5)}, ${fix.lon.toStringAsFixed(5)}'),
            Text('Updated $when', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: inside.isEmpty
                  ? [const Chip(label: Text('Outside all fences'))]
                  : inside.map((n) => Chip(label: Text(n), avatar: const Icon(Icons.home_outlined, size: 16))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CryCard extends StatelessWidget {
  const _CryCard({required this.listening, required this.onChanged});
  final bool listening;
  final Future<void> Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: listening ? WatchmanTheme.sage.withOpacity(0.25) : null,
      child: SwitchListTile(
        title: const Text('On-device cry listen'),
        subtitle: const Text('Audio is scored and discarded. Nothing is uploaded or saved.'),
        value: listening,
        onChanged: (v) => onChanged(v),
        secondary: Icon(listening ? Icons.hearing : Icons.hearing_disabled),
      ),
    );
  }
}

class _PairCard extends StatelessWidget {
  const _PairCard({required this.pin});
  final String pin;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.qr_code_2),
        title: const Text('Local pairing PIN'),
        subtitle: Text('$pin  ·  no server, watch enters this PIN'),
      ),
    );
  }
}
