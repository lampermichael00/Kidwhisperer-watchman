import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/location_service.dart';

class FencesScreen extends StatelessWidget {
  const FencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Geofences')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _promptAdd(context, state),
        icon: const Icon(Icons.add),
        label: const Text('Fence'),
      ),
      body: state.fences.isEmpty
          ? const Center(child: Text('No fences yet. Add Home to start.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: state.fences.length,
              itemBuilder: (context, i) {
                final f = state.fences[i];
                return Card(
                  child: SwitchListTile(
                    title: Text(f.name),
                    subtitle: Text(
                      '${f.radiusMeters.round()} m · ${f.center.lat.toStringAsFixed(4)}, ${f.center.lon.toStringAsFixed(4)}',
                    ),
                    value: f.enabled,
                    onChanged: (v) => state.toggleFence(f.id, v),
                    secondary: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => state.removeFence(f.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _promptAdd(BuildContext context, AppState state) async {
    final nameCtrl = TextEditingController(text: 'School');
    final radiusCtrl = TextEditingController(text: '150');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New fence'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(
              controller: radiusCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Radius (meters)'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Centered on the current last fix (demo path around Anaconda).',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );
    if (ok != true) return;
    final radius = double.tryParse(radiusCtrl.text) ?? 150;
    final center = state.child.lastFix ?? LocationService.home;
    await state.addFence(nameCtrl.text.trim().isEmpty ? 'Fence' : nameCtrl.text.trim(), center, radius);
  }
}
