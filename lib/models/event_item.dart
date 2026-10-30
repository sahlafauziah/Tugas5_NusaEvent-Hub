import 'package:flutter/material.dart';

/// Kategori seminar/workshop yang tersedia.
enum EventCategory {
  ai('AI', Icons.psychology_alt_rounded),
  mobile('Mobile', Icons.phone_android_rounded),
  iot('IoT', Icons.sensors_rounded),
  cybersecurity('Cybersecurity', Icons.shield_rounded);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Data satu seminar / workshop.
class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.category,
    required this.speaker,
    required this.venue,
    required this.startDate,
    required this.endDate,
    required this.time,
    required this.price,
    required this.quota,
    required this.registered,
    required this.description,
    required this.posterAsset,
  });

  final String id;
  final String title;
  final EventCategory category;
  final String speaker;
  final String venue;
  final DateTime startDate;
  final DateTime endDate;
  final String time;

  /// Harga dasar tiket (tipe peserta Mahasiswa) dalam rupiah.
  final int price;
  final int quota;
  final int registered;
  final String description;
  final String posterAsset;

  int get remainingQuota => quota - registered;
  bool get isAvailable => remainingQuota > 0;
  bool get isMultiDay => endDate.isAfter(startDate);

  String get dateLabel => isMultiDay
      ? '${formatTanggal(startDate)} – ${formatTanggal(endDate)}'
      : formatTanggal(startDate);
}

const List<String> _namaBulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

const List<String> _namaHari = [
  'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
];

/// Contoh: 14 Nov 2026 atau Sabtu, 14 Nov 2026 (withDay: true).
String formatTanggal(DateTime date, {bool withDay = false}) {
  final base = '${date.day} ${_namaBulan[date.month - 1]} ${date.year}';
  return withDay ? '${_namaHari[date.weekday - 1]}, $base' : base;
}

/// Contoh: 50000 -> Rp50.000. Nilai 0 menjadi [zeroLabel].
String formatRupiah(int value, {String zeroLabel = 'Gratis'}) {
  if (value == 0) return zeroLabel;
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
  }
  return 'Rp$buffer';
}
