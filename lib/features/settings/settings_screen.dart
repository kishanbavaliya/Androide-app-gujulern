import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/constants/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmReset(BuildContext context) async {
    final app = context.read<AppProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text(
          'This will erase your XP, streak, quiz scores and completed '
          'lessons. Your country and language selections stay the same. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await app.resetProgress();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress has been reset.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionCard(
            children: [
              _InfoTile(
                icon: Icons.public,
                title: 'Country',
                value:
                    '${app.selectedCountry?.flag ?? ''} ${app.selectedCountry?.name ?? '-'}',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.country),
              ),
              _InfoTile(
                icon: Icons.language,
                title: 'App language',
                value: app.appLanguage?.nativeName ?? '-',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.appLanguage),
              ),
              _InfoTile(
                icon: Icons.school,
                title: 'Learning language',
                value: app.learningLanguage?.nativeName ?? '-',
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.learningLanguage),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Pronunciation',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _SectionCard(
            children: [
              SwitchListTile(
                value: app.soundEnabled,
                onChanged: (v) => app.setSoundEnabled(v),
                title: const Text('Sound / pronunciation'),
                secondary: const Icon(Icons.volume_up),
              ),
              ListTile(
                leading: const Icon(Icons.speed),
                title: const Text('Speech speed'),
                subtitle: Slider(
                  value: app.speechRate,
                  min: 0.2,
                  max: 1.0,
                  divisions: 8,
                  label: app.speechRate.toStringAsFixed(1),
                  onChanged: (v) => app.setSpeechRate(v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Data',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _SectionCard(
            children: [
              ListTile(
                leading: const Icon(Icons.restart_alt, color: Colors.red),
                title: const Text('Reset progress',
                    style: TextStyle(color: Colors.red)),
                onTap: () => _confirmReset(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionCard(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                subtitle: Text(
                    '${AppConstants.appName} · fully offline · v1.0.0'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: Colors.black54)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18),
        ],
      ),
      onTap: onTap,
    );
  }
}
