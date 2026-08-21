import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/attributions_data.dart';

/// Pantalla con el aviso de derechos de imagen, las fuentes utilizadas por
/// país y el acceso a las licencias de las bibliotecas de terceros.
///
/// El contenido de las fuentes vive en attributions_data.dart: esta pantalla
/// solo lo recorre y lo pinta, así que añadir un país o quitar un organismo
/// nunca requiere tocar este archivo.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créditos y licencias')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AttributionsData.flagsNotice,
                    style: const TextStyle(fontSize: 14, height: 1.4)),
                const SizedBox(height: 12),
                Text(AttributionsData.coinsNotice,
                    style: const TextStyle(fontSize: 14, height: 1.4)),
              ],
            ),
          ),
          const Divider(),

          _SectionHeader('Unión Europea'),
          for (final source in AttributionsData.euSources)
            _SourceTile(source: source),

          const Divider(),

          for (final country in AttributionsData.countries) ...[
            _SectionHeader(country.country),
            for (final source in country.sources) _SourceTile(source: source),
          ],

          const Divider(),

          _SectionHeader('Bibliotecas de terceros'),
          const _LicensesTile(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Cabecera de sección ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
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

// ── Fila de un organismo con enlace ─────────────────────────────────────────

class _SourceTile extends StatelessWidget {
  final AttributionEntry source;
  const _SourceTile({required this.source});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(source.name, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: () => launchUrl(
        Uri.parse(source.url),
        mode: LaunchMode.externalApplication,
      ),
    );
  }
}

// ── Acceso a licencias de paquetes (generado automáticamente por Flutter) ──

class _LicensesTile extends StatefulWidget {
  const _LicensesTile();

  @override
  State<_LicensesTile> createState() => _LicensesTileState();
}

class _LicensesTileState extends State<_LicensesTile> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: const Text('Licencias de código abierto'),
      subtitle: const Text('Paquetes y bibliotecas utilizados en esta app'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => showLicensePage(
        context: context,
        applicationName: 'EuroCoinDex',
        applicationVersion: _version,
      ),
    );
  }
}
