class Coin {
  final int id;
  final bool emitida;
  final int valor;
  final String idPais;
  final String paisVO;
  final String paisES;
  final String flag;
  final int anoInicio;
  final int? anoFin;
  final String? fecha;       // Para mostrar: dd/mm/aaaa
  final String? dateSort;    // Para ordenar: aaaa/mm/dd
  final bool conm;
  final bool conj;
  final String? conjOficial;
  final String? idSerie;
  final String? descrSerieES;
  final String? titulo;
  final String? descrCoinES;
  final String? descCoinEN;
  final String? imageCoin;
  final String? imageComun1;
  final String? imageComun2;
  final String? motivoES;
  final String? motivoEN;
  final String? tagES;
  final String? subtagES;
  final String? coincidencia;
  final String? rareza;
  final String? frase;

  const Coin({
    required this.id,
    required this.emitida,
    required this.valor,
    required this.idPais,
    required this.paisVO,
    required this.paisES,
    required this.flag,
    required this.anoInicio,
    this.anoFin,
    this.fecha,
    this.dateSort,
    required this.conm,
    required this.conj,
    this.conjOficial,
    this.idSerie,
    this.descrSerieES,
    this.titulo,
    this.descrCoinES,
    this.descCoinEN,
    this.imageCoin,
    this.imageComun1,
    this.imageComun2,
    this.motivoES,
    this.motivoEN,
    this.tagES,
    this.subtagES,
    this.coincidencia,
    this.rareza,
    this.frase,
  });

  factory Coin.fromCsvRow(Map<String, dynamic> row) {
    int parseIntSafe(dynamic v) {
      if (v == null || v.toString().trim().isEmpty) return 0;
      return int.tryParse(v.toString().trim()) ?? 0;
    }

    bool parseBool(dynamic v) {
      if (v == null) return false;
      final s = v.toString().trim();
      return s == '1' || s.toLowerCase() == 'true';
    }

    String? parseStr(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty || s == 'nan' || s == 'NaN' ? null : s;
    }

    return Coin(
      id: parseIntSafe(row['IDcoin']),
      emitida: parseBool(row['emitida']),
      valor: parseIntSafe(row['valor']),
      idPais: parseStr(row['IDpais']) ?? '',
      paisVO: parseStr(row['paisVO']) ?? '',
      paisES: parseStr(row['paisES']) ?? '',
      flag: parseStr(row['flag']) ?? '',
      anoInicio: parseIntSafe(row['anoinicio']),
      anoFin: row['anofin'] != null && row['anofin'].toString().trim().isNotEmpty
          ? int.tryParse(row['anofin'].toString().trim())
          : null,
      fecha: parseStr(row['fecha']),
      dateSort: parseStr(row['DateSort']),
      conm: parseBool(row['conm']),
      conj: parseBool(row['conj']),
      conjOficial: parseStr(row['conj_oficial']),
      idSerie: parseStr(row['IDserie']),
      descrSerieES: parseStr(row['descr_serieES']),
      titulo: parseStr(row['titulo']),
      descrCoinES: parseStr(row['descr_coinES']),
      descCoinEN: parseStr(row['desc_coin_EN']),
      imageCoin: parseStr(row['image_coin']),
      imageComun1: parseStr(row['image_comun1']),
      imageComun2: parseStr(row['image_comun2']),
      motivoES: parseStr(row['motivoES']),
      motivoEN: parseStr(row['motivoEN']),
      tagES: parseStr(row['tagES']),
      subtagES: parseStr(row['subtagES']),
      coincidencia: parseStr(row['Coincidencia']),
      rareza: parseStr(row['rareza']),
      frase: parseStr(row['frase']),
    );
  }

  /// Etiqueta legible del valor facial
  String get valorLabel {
    switch (valor) {
      case 200: return '2 €';
      case 100: return '1 €';
      case 50:  return '50 céntimos';
      case 20:  return '20 céntimos';
      case 10:  return '10 céntimos';
      case 5:   return '5 céntimos';
      case 2:   return '2 céntimos';
      case 1:   return '1 céntimo';
      default:  return '$valor';
    }
  }

  /// Rango de años para mostrar
  String get yearRange {
    if (anoFin != null && anoFin != anoInicio) return '$anoInicio-$anoFin';
    return '$anoInicio';
  }

  /// Clave de ordenación: DateSort si existe, si no aaaa/12/31 del anoinicio
  String get sortKey => dateSort ?? '$anoInicio/12/31';

  /// Verdadero si la moneda fue emitida en el año dado
  bool issuedInYear(int year) {
    if (year < anoInicio) return false;
    if (anoFin != null && year > anoFin!) return false;
    return true;
  }
}
