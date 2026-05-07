import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final info = await PackageInfo.fromPlatform();
    final provider = context.read<AppProvider>();
    final lastUpdate = await provider.getLastUpdate();
    setState(() {
      _appVersion = '${info.version}+${info.buildNumber}';
      _lastUpdate = lastUpdate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final totalCoins = provider.allCoins.where((c) => c.emitida).length;
    final collected = provider.collectedIds.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          _SectionHeader('Mi colección'),
          Card(
            margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                          'Obtenidas', '$collected', colorScheme.primary),
                      _StatItem('Faltantes',
                          '${totalCoins - collected}', Colors.grey),
                      _StatItem('Total catálogo', '$totalCoins',
                          colorScheme.secondary),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: totalCoins > 0 ? collected / totalCoins : 0,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        collected == totalCoins
                            ? Colors.green
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalCoins > 0
                        ? '${(collected / totalCoins * 100).toStringAsFixed(1)}% completado'
                        : '',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          _SectionHeader('Copia de seguridad'),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Exportar colección'),
            subtitle:
                const Text('Guarda un archivo CSV con tus monedas'),
            onTap: () => _exportCollection(context),
          ),
          const Divider(indent: 56),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Importar colección'),
            subtitle: const Text(
                'Restaura una copia de seguridad (reemplaza la actual)'),
            onTap: () => _importCollection(context),
          ),

          _SectionHeader('Base de datos'),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Actualizar catálogo'),
            subtitle: _lastUpdate != null
                ? Text(
                    'Última actualización: ${_lastUpdate!.day}/${_lastUpdate!.month}/${_lastUpdate!.year}')
                : const Text('Nunca actualizado'),
            onTap: () => _refreshData(context),
          ),

          _SectionHeader('Acerca de'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('EuroCoinDex'),
            subtitle: Text('Versión $_appVersion'),
          ),
          const Divider(indent: 56),
          ListTile(
            leading:
                const Icon(Icons.favorite, color: Colors.red),
            title: const Text('Apoya el proyecto'),
            subtitle:
                const Text('Si te es útil, considera una donación'),
            onTap: () => launchUrl(
              Uri.parse('https://www.paypal.com/paypalme/my/profile'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          const Divider(indent: 56),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Código fuente'),
            subtitle:
                const Text('github.com/16Pablo/eurocoindex'),
            onTap: () => launchUrl(
              Uri.parse('https://github.com/16Pablo/eurocoindex'),
              mode: LaunchMode.externalApplication,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _exportCollection(BuildContext context) async {
    try {
      final provider = context.read<AppProvider>();
      final file = await provider.exportCollection();
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Mi colección EuroCoinDex',
        subject: 'EuroCoinDex - Copia de seguridad',
      );
    } catch (e) {
      _showSnack(context, 'Error al exportar: $e', isError: true);
    }
  }

  Future<void> _importCollection(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Importar colección?'),
        content: const Text(
            'Esto reemplazará tu colección actual con la del archivo. ¿Continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Importar')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final provider = context.read<AppProvider>();
      final count = await provider.importCollection(file);
      _showSnack(context, '$count monedas importadas correctamente');
    } catch (e) {
      _showSnack(context, 'Error al importar: $e', isError: true);
    }
  }

  Future<void> _refreshData(BuildContext context) async {
    final provider = context.read<AppProvider>();
    await provider.loadData();
    final lastUpdate = await provider.getLastUpdate();
    setState(() => _lastUpdate = lastUpdate);
    _showSnack(context, 'Catálogo actualizado correctamente');
  }

  void _showSnack(BuildContext context, String msg,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 1.2,
          ),
        ),
      );
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            value,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color),
          ),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Colors.grey)),
        ],
      );
}
