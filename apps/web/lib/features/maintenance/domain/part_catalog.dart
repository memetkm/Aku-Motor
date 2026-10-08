enum PartCategory {
  oliMesin,
  oliGardan,
  vbelt,
  rollerCvt,
  kampasRem,
  ban,
  aki,
  filterUdara,
}

class PartEducationInfo {
  const PartEducationInfo({
    required this.name,
    required this.intervalKilometer,
    required this.intervalMonth,
    required this.vulnerabilityReason,
    required this.consequenceLight,
    required this.consequenceMedium,
    required this.consequenceFatal,
    required this.estimatedCostNow,
    required this.estimatedCostLater,
  });

  final String name;
  final int intervalKilometer;
  final int intervalMonth;
  final String vulnerabilityReason;
  final String consequenceLight;
  final String consequenceMedium;
  final String consequenceFatal;
  final int estimatedCostNow;
  final int estimatedCostLater;
}

class PartCatalog {
  static const Map<String, PartEducationInfo> items = {
    'Oli Mesin': PartEducationInfo(
      name: 'Oli Mesin',
      intervalKilometer: 3000,
      intervalMonth: 2,
      vulnerabilityReason:
          'Bekerja pada suhu ekstrem dan gesekan putaran piston ribuan RPM tanpa henti.',
      consequenceLight:
          'Tarikan mesin terasa berat, suhu mesin cepat panas, dan bensin menjadi lebih boros.',
      consequenceMedium:
          'Oli mengental menjadi endapan lumpur (sludge), camshaft dan dinding silinder mulai aus tergores.',
      consequenceFatal:
          'Piston macet total (seher ngancing), setang seher patah, silinder baret parah, dan motor harus turun mesin total.',
      estimatedCostNow: 65000,
      estimatedCostLater: 2500000,
    ),
    'V-Belt': PartEducationInfo(
      name: 'V-Belt',
      intervalKilometer: 24000,
      intervalMonth: 24,
      vulnerabilityReason:
          'Terbuat dari karet elastis yang terus ditarik dan terpapar panas tinggi ruang CVT transmisi matic.',
      consequenceLight:
          'Akselerasi awal bergetar (gredek), tarikan motor terasa selip saat menanjak.',
      consequenceMedium:
          'Karet sabuk retak-retak mikro dan mengikis permukaan rumah roller dan pulley CVT.',
      consequenceFatal:
          'Sabuk putus mendadak di jalan raya saat melaju kencang, roda belakang dapat terkunci dan menghancurkan mangkok CVT.',
      estimatedCostNow: 150000,
      estimatedCostLater: 950000,
    ),
    'Kampas Rem': PartEducationInfo(
      name: 'Kampas Rem',
      intervalKilometer: 10000,
      intervalMonth: 12,
      vulnerabilityReason:
          'Habis terkikis gesekan pengereman setiap hari demi menghentikan laju motor.',
      consequenceLight:
          'Jarak pengereman bertambah panjang dan tuas rem terasa ambles saat ditekan.',
      consequenceMedium:
          'Pelat besi kampas bergesekan langsung dengan piringan cakram sehingga piringan tergores dalam dan bergelombang.',
      consequenceFatal:
          'Rem blong total, piringan cakram berisiko pecah atau kaliper rem terkunci, menyebabkan kecelakaan fatal di jalan raya.',
      estimatedCostNow: 60000,
      estimatedCostLater: 650000,
    ),
    'Ban': PartEducationInfo(
      name: 'Ban',
      intervalKilometer: 12000,
      intervalMonth: 18,
      vulnerabilityReason:
          'Satu-satunya bagian yang bersentuhan langsung dengan aspal kasar, cuaca hujan, dan kerikil tajam.',
      consequenceLight:
          'Kenyamanan berkendara menurun dan motor terasa keras atau membal saat melibas marka jalan.',
      consequenceMedium:
          'Alur pembuangan air menipis, ban sangat mudah bocor tertusuk benda kecil dan kehilangan daya cengkeram.',
      consequenceFatal:
          'Terpeleset parah saat jalanan basah (aquaplaning), ban meletus tiba-tiba pada kecepatan tinggi yang berujung kecelakaan parah.',
      estimatedCostNow: 250000,
      estimatedCostLater: 1800000,
    ),
    'Roller CVT': PartEducationInfo(
      name: 'Roller CVT',
      intervalKilometer: 20000,
      intervalMonth: 20,
      vulnerabilityReason:
          'Berputar dan terlempar ribuan kali mengikuti gaya sentrifugal di dalam rumah pulley.',
      consequenceLight:
          'Tarikan awal motor terasa lambat dan timbul suara gemeretak halus di CVT.',
      consequenceMedium:
          'Bentuk roller berubah peang/gepeng, kecepatan maksimum motor (top speed) tidak tercapai.',
      consequenceFatal:
          'Roller hancur berkeping-keping di dalam pulley, merusak jalur rumah roller dan pulley depan macet total.',
      estimatedCostNow: 75000,
      estimatedCostLater: 550000,
    ),
    'Aki': PartEducationInfo(
      name: 'Aki',
      intervalKilometer: 20000,
      intervalMonth: 24,
      vulnerabilityReason:
          'Cairan dan sel kimia di dalam baterai mengalami penurunan voltase dan degradasi alami.',
      consequenceLight:
          'Klakson terdengar serak dan nyala lampu speedometer meredup saat mesin idle.',
      consequenceMedium:
          'Electric starter tidak merespons sama sekali, menyulitkan pengguna menghidupkan motor.',
      consequenceFatal:
          'Sistem injeksi, ECU, dan fuel pump mati mendadak saat berkendara karena tidak ada pasokan voltase stabil.',
      estimatedCostNow: 230000,
      estimatedCostLater: 1200000,
    ),
    'Filter Udara': PartEducationInfo(
      name: 'Filter Udara',
      intervalKilometer: 10000,
      intervalMonth: 10,
      vulnerabilityReason:
          'Menyaring seluruh debu, pasir jalanan, dan kotoran agar tidak masuk ke ruang pembakaran.',
      consequenceLight:
          'Pasokan udara tercekik sehingga tenaga motor tertahan dan akselerasi loyo.',
      consequenceMedium:
          'Campuran bensin dan udara tidak ideal, konsumsi BBM boros, serta busi cepat berkerak hitam.',
      consequenceFatal:
          'Debu halus lolos ke ruang silinder dan mengikis dinding liner mesin hingga kompresi bocor.',
      estimatedCostNow: 50000,
      estimatedCostLater: 700000,
    ),
    'Oli Gardan': PartEducationInfo(
      name: 'Oli Gardan',
      intervalKilometer: 8000,
      intervalMonth: 6,
      vulnerabilityReason:
          'Sering diabaikan pemilik matic padahal melumasi gesekan gir rasio transmisi belakang.',
      consequenceLight:
          'Terdengar suara desing pelan dari area roda belakang saat motor melaju santai.',
      consequenceMedium:
          'Gesekan logam gir rasio semakin kering, timbul suara dengung kasar yang mengganggu.',
      consequenceFatal:
          'Gir rasio rompal/rontok dan laher transmisi pecah sehingga roda belakang terkunci mati tidak bisa berputar.',
      estimatedCostNow: 20000,
      estimatedCostLater: 850000,
    ),
  };

  static List<String> get partNames => items.keys.toList();

  static PartEducationInfo getInfo(String partName) {
    return items[partName] ??
        const PartEducationInfo(
          name: 'Komponen Motor',
          intervalKilometer: 5000,
          intervalMonth: 6,
          vulnerabilityReason: 'Komponen mengalami keausan seiring jarak tempuh kendaraan.',
          consequenceLight: 'Performa kendaraan dan efisiensi berkurang.',
          consequenceMedium: 'Komponen pendukung lainnya ikut mengalami keausan dini.',
          consequenceFatal: 'Komponen patah atau rusak total sehingga membahayakan keselamatan.',
          estimatedCostNow: 75000,
          estimatedCostLater: 600000,
        );
  }
}

