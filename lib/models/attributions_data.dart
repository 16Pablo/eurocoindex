/// Datos de atribución de fuentes usadas para documentar las monedas.
///
/// CÓMO ACTUALIZAR:
/// - Nuevo país en la eurozona: añade un [CountryAttributions] más a la
///   lista `countries`, con su nombre y la lista de organismos (nombre + URL).
/// - Un organismo cierra o cambia de web: edita o borra esa línea
///   [AttributionEntry] dentro del país correspondiente.
/// - Nada de esto requiere tocar la pantalla que lo muestra (legal_screen.dart).
class AttributionEntry {
  final String name;
  final String url;
  const AttributionEntry(this.name, this.url);
}

class CountryAttributions {
  final String country;
  final List<AttributionEntry> sources;
  const CountryAttributions(this.country, this.sources);
}

class AttributionsData {
  AttributionsData._();

  static const String flagsNotice =
      'Las imágenes de las banderas utilizadas en la aplicación son de '
      'dominio público.';

  static const String coinsNotice =
      'Las imágenes de las monedas han sido adaptadas y normalizadas por el '
      'autor para su utilización en este catálogo. Se han utilizado como '
      'referencia imágenes y material publicados por bancos centrales, '
      'fábricas de moneda, organismos emisores y otras fuentes numismáticas. '
      'Se indican a continuación los principales organismos oficiales y '
      'fuentes utilizadas para la documentación y representación de las '
      'monedas:';

  /// Organismos generales de la Unión Europea (no específicos de un país)
  static const List<AttributionEntry> euSources = [
    AttributionEntry('Banco Central Europeo',
        'https://www.ecb.europa.eu/euro/coins/html/index.en.html'),
    AttributionEntry('Comisión Europea — Euro coins',
        'https://economy-finance.ec.europa.eu/euro/euro-coins-and-notes/euro-coins_en'),
    AttributionEntry('Comisión Europea — Copyright y reproducción',
        'https://economy-finance.ec.europa.eu/euro/euro-coins-and-notes/copyright-and-reproduction-rules-euro-coins-and-notes_en'),
  ];

  /// Organismos por país. Orden alfabético por nombre de país.
  static const List<CountryAttributions> countries = [
    CountryAttributions('Alemania', [
      AttributionEntry('Deutsche Bundesbank', 'https://www.bundesbank.de/'),
      AttributionEntry(
          'Münze Deutschland', 'https://www.muenze-deutschland.de/'),
    ]),
    CountryAttributions('Andorra', [
      AttributionEntry("Govern d'Andorra", 'https://www.govern.ad/'),
    ]),
    CountryAttributions('Austria', [
      AttributionEntry('Oesterreichische Nationalbank', 'https://www.oenb.at/'),
      AttributionEntry('Münze Österreich', 'https://www.muenzeoesterreich.at/'),
    ]),
    CountryAttributions('Bélgica', [
      AttributionEntry('National Bank of Belgium', 'https://www.nbb.be/'),
      AttributionEntry('SPF Finances', 'https://finances.belgium.be/'),
    ]),
    CountryAttributions('Bulgaria', [
      AttributionEntry('Bulgarian National Bank', 'https://www.bnb.bg/'),
      AttributionEntry('Bulgarian Mint', 'https://www.bulmint.com/'),
    ]),
    CountryAttributions('Chipre', [
      AttributionEntry('Central Bank of Cyprus', 'https://www.centralbank.cy/'),
    ]),
    CountryAttributions('Ciudad del Vaticano', [
      AttributionEntry('Commercializzazione filatelica e numismatica (CFN)',
          'https://www.cfn.va/en/'),
      AttributionEntry('Vatican City State', 'https://www.vaticanstate.va/'),
    ]),
    CountryAttributions('Croacia', [
      AttributionEntry('Croatian National Bank', 'https://www.hnb.hr/'),
      AttributionEntry('Croatian Mint', 'https://croatianmint.hr/en/'),
    ]),
    CountryAttributions('Eslovaquia', [
      AttributionEntry('Národná banka Slovenska', 'https://nbs.sk/'),
      AttributionEntry('Mincovňa Kremnica', 'https://www.mint.sk'),
    ]),
    CountryAttributions('Eslovenia', [
      AttributionEntry('Banka Slovenije', 'https://www.bsi.si/'),
    ]),
    CountryAttributions('España', [
      AttributionEntry('Banco de España', 'https://www.bde.es/'),
      AttributionEntry('FNMT — Real Casa de la Moneda', 'https://www.fnmt.es/'),
    ]),
    CountryAttributions('Estonia', [
      AttributionEntry('Eesti Pank', 'https://www.eestipank.ee/'),
    ]),
    CountryAttributions('Finlandia', [
      AttributionEntry('Bank of Finland', 'https://www.suomenpankki.fi/'),
      AttributionEntry(
          'Helsinkimint by Royal Dutch Mint', 'https://www.helsinkimint.com/'),
    ]),
    CountryAttributions('Francia', [
      AttributionEntry('Banque de France', 'https://www.banque-france.fr/'),
      AttributionEntry('Monnaie de Paris', 'https://www.monnaiedeparis.fr/'),
    ]),
    CountryAttributions('Grecia', [
      AttributionEntry('Bank of Greece', 'https://www.bankofgreece.gr/'),
    ]),
    CountryAttributions('Irlanda', [
      AttributionEntry(
          'Central Bank of Ireland', 'https://www.centralbank.ie/'),
    ]),
    CountryAttributions('Italia', [
      AttributionEntry("Banca d'Italia", 'https://www.bancaditalia.it/'),
      AttributionEntry('Istituto Poligrafico e Zecca dello Stato',
          'https://www.ipzs.it'),
    ]),
    CountryAttributions('Letonia', [
      AttributionEntry('Latvijas Banka', 'https://www.bank.lv/'),
    ]),
    CountryAttributions('Lituania', [
      AttributionEntry('Lietuvos bankas', 'https://www.lb.lt/'),
      AttributionEntry('Lithuanian Mint', 'https://www.lithuanian-mint.lt/'),
    ]),
    CountryAttributions('Luxemburgo', [
      AttributionEntry(
          'Banque centrale du Luxembourg', 'https://www.bcl.lu/'),
    ]),
    CountryAttributions('Malta', [
      AttributionEntry(
          'Central Bank of Malta', 'https://www.centralbankmalta.org/'),
    ]),
    CountryAttributions('Mónaco', [
      AttributionEntry('Gobierno de Mónaco', 'https://monservicepublic.gouv.mc/'),
    ]),
    CountryAttributions('Países Bajos', [
      AttributionEntry('De Nederlandsche Bank', 'https://www.dnb.nl/'),
      AttributionEntry('Royal Dutch Mint', 'https://www.knm.nl/'),
    ]),
    CountryAttributions('Portugal', [
      AttributionEntry('Banco de Portugal', 'https://www.bportugal.pt/'),
      AttributionEntry(
          'Imprensa Nacional-Casa da Moeda', 'https://www.incm.pt/'),
    ]),
    CountryAttributions('San Marino', [
      AttributionEntry(
          'Divisione Filatelica Numismatica', 'https://www.dfn.sm/'),
    ]),
  ];
}
