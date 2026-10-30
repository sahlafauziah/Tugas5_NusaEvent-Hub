import 'event_item.dart';

/// Tipe peserta beserta faktor pengali harga tiket.
enum ParticipantType {
  student('Mahasiswa', 1.0),
  lecturer('Dosen / Staf', 1.25),
  general('Umum', 1.5);

  const ParticipantType(this.label, this.priceFactor);

  final String label;
  final double priceFactor;
}

/// Paket seminar kit.
enum SeminarKit {
  basic('Basic', 'E-sertifikat & materi digital', 0),
  standard('Standard', 'Sertifikat cetak, tote bag & notebook', 35000),
  premium('Premium', 'Standard + lanyard eksklusif & merchandise', 75000);

  const SeminarKit(this.label, this.description, this.price);

  final String label;
  final String description;
  final int price;
}

/// Tiket hasil pendaftaran seminar.
class RegistrationTicket {
  const RegistrationTicket({
    required this.id,
    required this.event,
    required this.fullName,
    required this.nim,
    required this.email,
    required this.whatsapp,
    required this.participantType,
    required this.attendanceDate,
    required this.kit,
    required this.donation,
    required this.registeredAt,
  });

  final String id;
  final EventItem event;
  final String fullName;
  final String nim;
  final String email;
  final String whatsapp;
  final ParticipantType participantType;
  final DateTime attendanceDate;
  final SeminarKit kit;
  final int donation;
  final DateTime registeredAt;

  /// Kode tiket pendek yang mudah dibaca.
  String get code => 'NEH-${id.substring(id.length - 6)}';

  int get ticketPrice => ticketPriceFor(event, participantType);

  int get totalPrice => calculateTotal(
        event: event,
        type: participantType,
        kit: kit,
        donation: donation,
      );

  static int ticketPriceFor(EventItem event, ParticipantType type) =>
      (event.price * type.priceFactor).round();

  static int calculateTotal({
    required EventItem event,
    required ParticipantType type,
    required SeminarKit kit,
    required int donation,
  }) =>
      ticketPriceFor(event, type) + kit.price + donation;
}
