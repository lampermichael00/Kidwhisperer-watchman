import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: context.read<AppState>().child.displayName);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Child display name',
              helperText: 'Stored only on this phone.',
              border: OutlineInputBorder(),
            ),
            onSubmitted: state.renameChild,
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () => state.renameChild(_name.text),
            child: const Text('Save name'),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.pin),
            title: Text('Pairing PIN  ${state.child.pairingPin ?? '—'}'),
            subtitle: const Text('Rotate if the watch was lost.'),
            trailing: TextButton(onPressed: state.rotatePin, child: const Text('Rotate')),
          ),
          const Divider(height: 32),
          const ListTile(
            leading: Icon(Icons.cloud_off),
            title: Text('Cloud'),
            subtitle: Text('Disabled. No account, no analytics, no upload path compiled in.'),
          ),
          const ListTile(
            leading: Icon(Icons.policy_outlined),
            title: Text('COPPA posture'),
            subtitle: Text(
              'Collect only what the parent typed plus on-device sensor scores. No third-party SDKs. Wipe is one tap.',
            ),
          ),
          const Divider(height: 32),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade800),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Wipe local data?'),
                  content: const Text('Deletes name, fences, alerts, and pairing PIN from this phone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Wipe')),
                  ],
                ),
              );
              if (ok == true) await state.wipeLocalData();
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text('Wipe all local data'),
          ),
          const SizedBox(height: 24),
          Text(
            'KidWhisperer Watchman  0.1.0\nDemo location path uses Anaconda, MT so fences exercise without hardware.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
