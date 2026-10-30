import 'package:flutter/material.dart';

import '../models/event_item.dart';

/// Kondisi filter daftar seminar.
class EventFilter {
  const EventFilter({this.category, this.onlyAvailable = false});

  final EventCategory? category;
  final bool onlyAvailable;

  int get activeCount => (category != null ? 1 : 0) + (onlyAvailable ? 1 : 0);

  bool matches(EventItem event) =>
      (category == null || event.category == category) &&
      (!onlyAvailable || event.isAvailable);
}

Future<EventFilter?> showFilterBottomSheet(
  BuildContext context,
  EventFilter current,
) {
  return showModalBottomSheet<EventFilter>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => FilterBottomSheet(initial: current),
  );
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key, required this.initial});

  final EventFilter initial;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late EventCategory? _category;
  late bool _onlyAvailable;

  @override
  void initState() {
    super.initState();
    _category = widget.initial.category;
    _onlyAvailable = widget.initial.onlyAvailable;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Seminar',
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih kategori dan ketersediaan kursi.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text('Kategori', style: text.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                for (final c in EventCategory.values)
                  ChoiceChip(
                    avatar: Icon(c.icon, size: 18),
                    label: Text(c.label),
                    showCheckmark: false,
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hanya yang masih ada kuota'),
              subtitle: const Text('Sembunyikan seminar yang sudah penuh'),
              value: _onlyAvailable,
              onChanged: (v) => setState(() => _onlyAvailable = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pop(context, const EventFilter()),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      EventFilter(
                        category: _category,
                        onlyAvailable: _onlyAvailable,
                      ),
                    ),
                    child: const Text('Terapkan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
