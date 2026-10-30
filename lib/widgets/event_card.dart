import 'package:flutter/material.dart';

import '../models/event_item.dart';
import '../theme/app_theme.dart';

List<Color> _posterColors(EventCategory category) {
  switch (category) {
    case EventCategory.ai:
      return const [Color(0xFFB79CF0), Color(0xFFF2A6CB)];
    case EventCategory.mobile:
      return const [Color(0xFF9DB4F2), Color(0xFFC3A4F0)];
    case EventCategory.iot:
      return const [Color(0xFFF6A9CC), Color(0xFFD7B6F5)];
    case EventCategory.cybersecurity:
      return const [Color(0xFF7F63C9), Color(0xFFE48DC2)];
  }
}

/// Poster acara dari aset. Jika file belum disediakan, tampil placeholder.
class EventPoster extends StatelessWidget {
  const EventPoster({super.key, required this.event, this.iconSize = 32});

  final EventItem event;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      event.posterAsset,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          _PosterPlaceholder(category: event.category, iconSize: iconSize),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({required this.category, required this.iconSize});

  final EventCategory category;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _posterColors(category),
        ),
      ),
      child: Icon(category.icon, size: iconSize, color: const Color(0xE6FFFFFF)),
    );
  }
}

/// Chip kecil penanda kategori.
class CategoryTag extends StatelessWidget {
  const CategoryTag({super.key, required this.category});

  final EventCategory category;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 14, color: scheme.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            category.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

/// Kartu seminar horizontal: poster kecil di kiri, info di kanan.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.isRegistered = false,
  });

  final EventItem event;
  final VoidCallback onTap;
  final bool isRegistered;

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
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: 104, child: EventPoster(event: event)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          CategoryTag(category: event.category),
                          if (isRegistered)
                            _StatusBadge(
                              label: 'Terdaftar',
                              background: scheme.secondaryContainer,
                              foreground: scheme.onSecondaryContainer,
                            ),
                          if (!event.isAvailable)
                            _StatusBadge(
                              label: 'Kuota penuh',
                              background: scheme.errorContainer,
                              foreground: scheme.onErrorContainer,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      _MetaRow(icon: Icons.person_rounded, text: event.speaker),
                      const SizedBox(height: 2),
                      _MetaRow(icon: Icons.event_rounded, text: event.dateLabel),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            formatRupiah(event.price),
                            style: text.titleSmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (event.isAvailable)
                            Text(
                              'Sisa ${event.remainingQuota} kursi',
                              style: text.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 14, color: scheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
