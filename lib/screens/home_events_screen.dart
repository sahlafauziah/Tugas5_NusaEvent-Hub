import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/sample_events.dart';
import '../models/event_item.dart';
import '../models/registration_ticket.dart';
import '../theme/app_theme.dart';
import '../widgets/curved_bottom_nav.dart';
import '../widgets/event_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/nusa_logo.dart';
import '../widgets/venue_map_viewer.dart';
import 'event_registration_screen.dart';
import 'registered_tickets_screen.dart';

/// Layar utama: 3 tab (Seminar & Workshop, Galeri & Denah, Tiket Terdaftar).
class HomeEventsScreen extends StatefulWidget {
  const HomeEventsScreen({super.key});

  @override
  State<HomeEventsScreen> createState() => _HomeEventsScreenState();
}

class _HomeEventsScreenState extends State<HomeEventsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<RegistrationTicket> _tickets = [];
  EventFilter _filter = const EventFilter();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilterSheet() async {
    final result = await showFilterBottomSheet(context, _filter);
    if (result != null && mounted) setState(() => _filter = result);
  }

  void _showEventDetail(EventItem event) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => _EventDetailSheet(
        event: event,
        onRegister: () {
          Navigator.pop(sheetContext);
          _openRegistration(event);
        },
      ),
    );
  }

  Future<void> _openRegistration(EventItem event) async {
    final ticket = await Navigator.of(context).push<RegistrationTicket>(
      MaterialPageRoute(
        builder: (_) => EventRegistrationScreen(event: event),
      ),
    );
    if (ticket == null || !mounted) return;

    setState(() => _tickets.insert(0, ticket));
    _tabController.animateTo(2);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Pendaftaran berhasil! Tiket ${ticket.code} sudah aktif.',
          ),
        ),
      );
  }

  void _cancelTicket(RegistrationTicket ticket) {
    setState(() => _tickets.removeWhere((t) => t.id == ticket.id));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Tiket "${ticket.event.title}" dibatalkan.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
        toolbarHeight: 72,
        title: const Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    NusaLogo(size: 46),
    SizedBox(width: 12),
    Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'NusaEvent Hub',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 19,
              color: Colors.white,
            ),
          ),
          Text(
            'Temukan seminar & workshop',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xE6FFFFFF),
            ),
          ),
        ],
      ),
    ),
  ],
),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventsTab(context),
          _GalleryVenueTab(events: sampleEvents),
          RegisteredTicketsScreen(tickets: _tickets, onCancel: _cancelTicket),
        ],
      ),
      bottomNavigationBar: CurvedBottomNav(
        animation: _tabController.animation!,
        onTap: (index) => _tabController.animateTo(index),
        items: [
          const CurvedNavItem(icon: Icons.mic_rounded, label: 'Seminar'),
          const CurvedNavItem(
            icon: Icons.photo_library_rounded,
            label: 'Galeri',
          ),
          CurvedNavItem(
            icon: Icons.confirmation_number_rounded,
            label: 'Tiket',
            badgeCount: _tickets.length,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- Tab 1
  Widget _buildEventsTab(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final events = sampleEvents.where((event) {
      final matchesFilter = _filter.matches(event);
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          event.title.toLowerCase().contains(query) ||
          event.speaker.toLowerCase().contains(query) ||
          event.venue.toLowerCase().contains(query) ||
          event.category.label.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.headerGradient,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: const [
                        BoxShadow(color: AppColors.shadow, blurRadius: 18, offset: Offset(0, 8)),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(right: -8, top: -14, child: Icon(Icons.auto_awesome_rounded, size: 94, color: Colors.white.withValues(alpha: .14))),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .20), borderRadius: BorderRadius.circular(30)),
                              child: const Text('EVENTS • LEARN • CONNECT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                            ),
                            const SizedBox(height: 13),
                            const Text('Temukan acara\ninspiratif berikutnya!', style: TextStyle(color: Colors.white, fontSize: 23, height: 1.15, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Text('Perluas wawasan dan bangun koneksi baru bersama komunitas teknologi.', style: TextStyle(color: Colors.white.withValues(alpha: .9), fontSize: 12, height: 1.4)),
                            const SizedBox(height: 15),
                            Row(children: [
                              _HeroStat(value: '${sampleEvents.length}', label: 'Acara'),
                              const SizedBox(width: 20),
                              _HeroStat(value: '${sampleEvents.map((e) => e.category).toSet().length}', label: 'Kategori'),
                              const SizedBox(width: 20),
                              _HeroStat(value: '${_tickets.length}', label: 'Tiket kamu'),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari seminar, pembicara, atau lokasi...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isEmpty ? null : IconButton(icon: const Icon(Icons.close_rounded), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.outline)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.outline)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.purple, width: 1.6)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
              child: Row(
                children: [
                  Badge(
                    isLabelVisible: _filter.activeCount > 0,
                    label: Text('${_filter.activeCount}'),
                    child: IconButton.filledTonal(
                      tooltip: 'Filter',
                      onPressed: _openFilterSheet,
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: const Text('Semua'),
                              selected: _filter.category == null,
                              onSelected: (_) => setState(
                                () => _filter = EventFilter(
                                  onlyAvailable: _filter.onlyAvailable,
                                ),
                              ),
                            ),
                          ),
                          for (final c in EventCategory.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                avatar: Icon(c.icon, size: 18),
                                label: Text(c.label),
                                showCheckmark: false,
                                selected: _filter.category == c,
                                onSelected: (_) => setState(
                                  () => _filter = EventFilter(
                                    category: c,
                                    onlyAvailable: _filter.onlyAvailable,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Menampilkan ${events.length} dari ${sampleEvents.length} acara',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ),
            Expanded(
              child: events.isEmpty
                  ? _buildEmptyFilterState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EventCard(
                            event: event,
                            isRegistered:
                                _tickets.any((t) => t.event.id == event.id),
                            onTap: () => _showEventDetail(event),
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

  Widget _buildEmptyFilterState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
                Icons.search_off_rounded,
                size: 36,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada seminar yang cocok',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coba ubah atau reset filter yang aktif.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => setState(() => _filter = const EventFilter()),
              child: const Text('Reset filter'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .85),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ Tab 2
class _GalleryVenueTab extends StatefulWidget {
  const _GalleryVenueTab({required this.events});

  final List<EventItem> events;

  @override
  State<_GalleryVenueTab> createState() => _GalleryVenueTabState();
}

class _GalleryVenueTabState extends State<_GalleryVenueTab>
    with AutomaticKeepAliveClientMixin {
  int _mode = 0; // 0 = galeri poster, 1 = denah venue

  @override
  bool get wantKeepAlive => true;

  void _showPoster(EventItem event) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: EventPoster(event: event, iconSize: 64),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(dialogContext)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${event.dateLabel} • ${event.venue}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 4),
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Tutup'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
              child: Row(
                children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.lavender, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.collections_rounded, color: AppColors.purpleDeep)),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Galeri & Lokasi Acara', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    SizedBox(height: 3),
                    Text('Lihat poster dan kenali area venue sebelum hadir.', style: TextStyle(fontSize: 11, color: Colors.black54)),
                  ])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(
                      value: 0,
                      icon: Icon(Icons.photo_library_rounded),
                      label: Text('Poster'),
                    ),
                    ButtonSegment<int>(
                      value: 1,
                      icon: Icon(Icons.map_rounded),
                      label: Text('Denah Venue'),
                    ),
                  ],
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Colors.white,
                    selectedBackgroundColor: AppColors.lavender,
                    selectedForegroundColor: AppColors.purpleDeep,
                    side: const BorderSide(color: AppColors.outline),
                  ),
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _mode,
                sizing: StackFit.expand,
                children: [
                  GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: widget.events.length,
                    itemBuilder: (context, index) {
                      final event = widget.events[index];
                      return _PosterTile(
                        event: event,
                        onTap: () => _showPoster(event),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: VenueMapViewer(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterTile extends StatelessWidget {
  const _PosterTile({required this.event, required this.onTap});

  final EventItem event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.shadow,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          EventPoster(event: event, iconSize: 44),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xB3000000)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryTag(category: event.category),
                const SizedBox(height: 6),
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------- Detail sheet
class _EventDetailSheet extends StatelessWidget {
  const _EventDetailSheet({required this.event, required this.onRegister});

  final EventItem event;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: EventPoster(event: event, iconSize: 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CategoryTag(category: event.category),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: text.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.person_rounded,
                    label: 'Pembicara',
                    value: event.speaker,
                  ),
                  _DetailRow(
                    icon: Icons.event_rounded,
                    label: 'Tanggal',
                    value: event.dateLabel,
                  ),
                  _DetailRow(
                    icon: Icons.schedule_rounded,
                    label: 'Waktu',
                    value: event.time,
                  ),
                  _DetailRow(
                    icon: Icons.place_rounded,
                    label: 'Lokasi',
                    value: event.venue,
                  ),
                  _DetailRow(
                    icon: Icons.event_seat_rounded,
                    label: 'Kuota',
                    value: event.isAvailable
                        ? 'Sisa ${event.remainingQuota} dari ${event.quota} kursi'
                        : 'Penuh (${event.quota} kursi)',
                  ),
                  _DetailRow(
                    icon: Icons.payments_rounded,
                    label: 'Harga mulai dari',
                    value: formatRupiah(event.price),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tentang acara',
                    style: text.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(event.description, style: text.bodyMedium),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: event.isAvailable ? onRegister : null,
                icon: const Icon(Icons.confirmation_number_rounded),
                label: Text(
                  event.isAvailable ? 'Daftar Sekarang' : 'Kuota Penuh',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: text.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                Text(value, style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
