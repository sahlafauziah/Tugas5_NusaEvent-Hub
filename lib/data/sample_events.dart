import '../models/event_item.dart';

/// Data contoh seminar & workshop NusaEvent Hub.
/// Poster dibaca dari assets/images/poster_N.png (disediakan sendiri).
/// Jika file belum ada, aplikasi menampilkan placeholder gradient.
final List<EventItem> sampleEvents = [
  EventItem(
    id: 'ev-01',
    title: 'Building Generative AI Apps with Gemini',
    category: EventCategory.ai,
    speaker: 'Dr. Raka Pratama, M.Kom.',
    venue: 'Aula Utama',
    startDate: DateTime(2026, 11, 14),
    endDate: DateTime(2026, 11, 14),
    time: '09.00 – 15.00 WIB',
    price: 50000,
    quota: 200,
    registered: 143,
    description:
        'Seminar tentang cara membangun aplikasi berbasis generative AI: '
        'prompt engineering, integrasi API, hingga pertimbangan etika dan '
        'keamanan data. Cocok untuk pemula yang ingin mulai membuat produk AI.',
    posterAsset: 'assets/images/poster_1.png',
  ),
  EventItem(
    id: 'ev-02',
    title: 'Machine Learning for Beginners Workshop',
    category: EventCategory.ai,
    speaker: 'Sari Wulandari, S.T., M.T.',
    venue: 'Lab Komputer',
    startDate: DateTime(2026, 11, 21),
    endDate: DateTime(2026, 11, 22),
    time: '08.30 – 16.00 WIB',
    price: 75000,
    quota: 40,
    registered: 40,
    description:
        'Workshop dua hari untuk melatih model klasifikasi pertama Anda '
        'menggunakan Python dan scikit-learn. Peserta membawa laptop sendiri.',
    posterAsset: 'assets/images/poster_2.png',
  ),
  EventItem(
    id: 'ev-03',
    title: 'Flutter Workshop: Material 3 UI',
    category: EventCategory.mobile,
    speaker: 'Dimas Anggara, S.Kom.',
    venue: 'Ruang Workshop A',
    startDate: DateTime(2026, 11, 28),
    endDate: DateTime(2026, 11, 28),
    time: '09.00 – 16.00 WIB',
    price: 60000,
    quota: 60,
    registered: 38,
    description:
        'Praktik membangun antarmuka Flutter yang responsif dengan Material 3: '
        'theming, navigasi tab, daftar, grid, dan formulir dengan validasi.',
    posterAsset: 'assets/images/poster_3.png',
  ),
  EventItem(
    id: 'ev-04',
    title: 'Native vs Cross-Platform: Memilih Stack Mobile',
    category: EventCategory.mobile,
    speaker: 'Rina Maharani, M.Cs.',
    venue: 'Aula Utama',
    startDate: DateTime(2026, 12, 5),
    endDate: DateTime(2026, 12, 5),
    time: '13.00 – 16.00 WIB',
    price: 25000,
    quota: 150,
    registered: 61,
    description:
        'Diskusi panel tentang kelebihan dan kekurangan Kotlin, Swift, Flutter, '
        'dan React Native untuk kebutuhan produk dan karier developer.',
    posterAsset: 'assets/images/poster_4.png',
  ),
  EventItem(
    id: 'ev-05',
    title: 'Smart Home with ESP32 Workshop',
    category: EventCategory.iot,
    speaker: 'Bagus Setiawan, S.T.',
    venue: 'Ruang Workshop B',
    startDate: DateTime(2026, 12, 12),
    endDate: DateTime(2026, 12, 13),
    time: '09.00 – 15.00 WIB',
    price: 90000,
    quota: 30,
    registered: 22,
    description:
        'Merakit sistem rumah pintar sederhana: sensor suhu, relay lampu, dan '
        'dashboard MQTT. Kit komponen disediakan panitia selama workshop.',
    posterAsset: 'assets/images/poster_5.png',
  ),
  EventItem(
    id: 'ev-06',
    title: 'IoT Data Pipeline & Edge Computing',
    category: EventCategory.iot,
    speaker: 'Prof. Hendra Kusuma, Ph.D.',
    venue: 'Aula Utama',
    startDate: DateTime(2026, 12, 19),
    endDate: DateTime(2026, 12, 19),
    time: '10.00 – 14.00 WIB',
    price: 30000,
    quota: 120,
    registered: 47,
    description:
        'Membahas alur data dari sensor ke cloud, kapan memakai edge computing, '
        'serta studi kasus pertanian cerdas dan monitoring energi.',
    posterAsset: 'assets/images/poster_6.png',
  ),
  EventItem(
    id: 'ev-07',
    title: 'Ethical Hacking & Web Security Basics',
    category: EventCategory.cybersecurity,
    speaker: 'Aldo Firmansyah, CEH',
    venue: 'Lab Komputer',
    startDate: DateTime(2026, 12, 6),
    endDate: DateTime(2026, 12, 6),
    time: '09.00 – 15.00 WIB',
    price: 55000,
    quota: 80,
    registered: 71,
    description:
        'Pengenalan OWASP Top 10 dan praktik penetration testing di lingkungan '
        'lab yang legal dan terisolasi. Wajib mematuhi kode etik peserta.',
    posterAsset: 'assets/images/poster_7.png',
  ),
  EventItem(
    id: 'ev-08',
    title: 'Digital Forensics & Incident Response',
    category: EventCategory.cybersecurity,
    speaker: 'Nadia Putri, M.Sc.',
    venue: 'Ruang Workshop A',
    startDate: DateTime(2026, 12, 20),
    endDate: DateTime(2026, 12, 20),
    time: '09.00 – 16.00 WIB',
    price: 65000,
    quota: 50,
    registered: 18,
    description:
        'Belajar menangani insiden keamanan: pengumpulan bukti digital, analisis '
        'log, dan penyusunan laporan insiden secara sistematis.',
    posterAsset: 'assets/images/poster_8.png',
  ),
];
