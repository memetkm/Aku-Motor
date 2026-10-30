class EmergencyContact {
  const EmergencyContact({
    required this.name,
    required this.serviceName,
    required this.phone,
    required this.description,
  });

  final String name;
  final String serviceName;
  final String phone;
  final String description;
}

abstract class SensorService {
  static const emergencyContacts = [
    EmergencyContact(
      name: 'Derek Resmi Jasa Marga',
      serviceName: 'Derek Tol & Jalan Raya',
      phone: '14080',
      description: 'Layanan derek darurat 24 jam untuk motor & mobil',
    ),
    EmergencyContact(
      name: 'Honda Care Darurat',
      serviceName: 'AHASS Road Service',
      phone: '1-500-989',
      description: 'Montir keliling untuk motor Honda mogok di jalan',
    ),
    EmergencyContact(
      name: 'Yamaha Emergency Service',
      serviceName: 'YES 24 Jam',
      phone: '021-4618000',
      description: 'Bantuan darurat khusus pengguna motor Yamaha',
    ),
    EmergencyContact(
      name: 'Polisi Lalu Lintas',
      serviceName: 'Polri Call Center',
      phone: '110',
      description: 'Laporan insiden kecelakaan atau hambatan lalu lintas',
    ),
  ];
}

