import 'package:flutter/material.dart';

import '../models/event_item.dart';
import '../models/registration_ticket.dart';
import '../theme/app_theme.dart';

/// Tab "Tiket Terdaftar": daftar tiket aktif, geser ke kiri untuk membatalkan.
class RegisteredTicketsScreen extends StatelessWidget {
  const RegisteredTicketsScreen({
    super.key,
    required this.tickets,
    required this.onCancel,
  });

  final List<RegistrationTicket> tickets;
  final void Function(RegistrationTicket ticket) onCancel;

  Future<bool> _confirmCancel(
    BuildContext context,
    RegistrationTicket ticket,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Batalkan Tiket?'),
        content: Text(
          'Tiket "${ticket.event.title}" atas nama ${ticket.fullName} '
          'akan dibatalkan dan tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (tickets.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: scheme.primaryContainer,
                child: Icon(
                  Icons.confirmation_number_outlined,
                  size: 36,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada tiket aktif',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih seminar di tab pertama lalu daftar untuk mendapatkan tiket.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.swipe_left_rounded,
                      size: 18, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Geser tiket ke kiri untuk membatalkan',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: ValueKey(ticket.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmCancel(context, ticket),
                      onDismissed: (_) => onCancel(ticket),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: scheme.errorContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Batalkan',
                              style: TextStyle(
                                color: scheme.onErrorContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.delete_rounded,
                                color: scheme.onErrorContainer),
                          ],
                        ),
                      ),
                      child: _TicketCard(ticket: ticket),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final RegistrationTicket ticket;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      elevation: 3,
      shadowColor: AppColors.shadow,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 8,
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        ticket.event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Aktif',
                        style: text.labelSmall?.copyWith(
                          color: scheme.onSecondaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Kode tiket: ${ticket.code}',
                  style: text.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const Divider(height: 24),
                _TicketRow(
                  icon: Icons.person_rounded,
                  text: '${ticket.fullName} • NIM ${ticket.nim}',
                ),
                _TicketRow(
                  icon: Icons.badge_rounded,
                  text: 'Peserta ${ticket.participantType.label}',
                ),
                _TicketRow(
                  icon: Icons.event_available_rounded,
                  text:
                      'Hadir ${formatTanggal(ticket.attendanceDate, withDay: true)}',
                ),
                _TicketRow(
                  icon: Icons.place_rounded,
                  text: '${ticket.event.venue} • ${ticket.event.time}',
                ),
                _TicketRow(
                  icon: Icons.card_giftcard_rounded,
                  text: 'Seminar kit ${ticket.kit.label}',
                ),
                if (ticket.donation > 0)
                  _TicketRow(
                    icon: Icons.volunteer_activism_rounded,
                    text: 'Donasi ${formatRupiah(ticket.donation)}',
                  ),
                const Divider(height: 24),
                Row(
                  children: [
                    Text('Total dibayar', style: text.bodyMedium),
                    const Spacer(),
                    Text(
                      formatRupiah(ticket.totalPrice),
                      style: text.titleMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
