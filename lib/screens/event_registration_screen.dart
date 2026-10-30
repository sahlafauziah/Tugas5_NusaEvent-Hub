import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/event_item.dart';
import '../models/registration_ticket.dart';
import '../theme/app_theme.dart';
import '../widgets/event_card.dart';

/// Formulir pendaftaran bertahap (4 langkah, tombol Lanjut / Kembali).
/// Mengembalikan [RegistrationTicket] lewat Navigator.pop jika berhasil.
class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key, required this.event});

  final EventItem event;

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  static const List<String> _stepLabels = [
    'Data Diri',
    'Kehadiran',
    'Paket',
    'Konfirmasi',
  ];
  static const int _lastStep = 3;

  // Satu GlobalKey untuk setiap langkah yang perlu divalidasi.
  final GlobalKey<FormState> _personalKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _attendanceKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _consentKey = GlobalKey<FormState>();

  final PageController _pageCtrl = PageController();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _nimCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _waCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();

  int _step = 0;
  ParticipantType _type = ParticipantType.student;
  DateTime? _date;
  SeminarKit _kit = SeminarKit.basic;
  double _donation = 0;
  bool _submitting = false;

  static const List<String> _rules = [
    'Hadir tepat waktu dan melakukan registrasi ulang di lobi.',
    'Membawa kartu identitas (KTM/KTP) dan menunjukkan kode tiket.',
    'Tidak merekam atau menyebarkan materi tanpa izin pembicara.',
    'Menjaga ketertiban, kebersihan, dan etika selama acara.',
    'Tiket tidak dapat dipindahtangankan kepada orang lain.',
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _nimCtrl.dispose();
    _emailCtrl.dispose();
    _waCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ Navigasi
  void _goTo(int step) {
    setState(() => _step = step);
    _pageCtrl.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();

    if (_step == 0) {
      if (!(_personalKey.currentState?.validate() ?? false)) {
        _snack('Lengkapi data diri dengan benar dulu ya.');
        return;
      }
    } else if (_step == 1) {
      if (!(_attendanceKey.currentState?.validate() ?? false)) {
        _snack('Pilih tanggal kehadiran terlebih dahulu.');
        return;
      }
    } else if (_step == _lastStep) {
      await _submit();
      return;
    }
    _goTo(_step + 1);
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step > 0) _goTo(_step - 1);
  }

  // ------------------------------------------------------------- Aksi
  Future<void> _pickDate() async {
    final event = widget.event;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? event.startDate,
      firstDate: event.startDate,
      lastDate: event.endDate,
      helpText: 'Pilih tanggal kehadiran',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      _dateCtrl.text = formatTanggal(picked, withDay: true);
    });
    _attendanceKey.currentState?.validate();
  }

  void _showRules() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tata Tertib Acara'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final rule in _rules)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('• $rule'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final consentOk = _consentKey.currentState?.validate() ?? false;
    if (!consentOk) {
      _snack('Centang persetujuan tata tertib untuk melanjutkan.');
      return;
    }

    setState(() => _submitting = true);

    // Simulasi proses kirim data ke server.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final now = DateTime.now();
    final ticket = RegistrationTicket(
      id: now.millisecondsSinceEpoch.toString(),
      event: widget.event,
      fullName: _nameCtrl.text.trim(),
      nim: _nimCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      whatsapp: _waCtrl.text.trim(),
      participantType: _type,
      attendanceDate: _date!,
      kit: _kit,
      donation: _donation.round(),
      registeredAt: now,
    );
    Navigator.of(context).pop(ticket);
  }

  // ---------------------------------------------------------- Dekorasi
  InputDecoration _decoration(
    String label,
    IconData icon, {
    String? hint,
    String? helper,
    Widget? suffix,
  }) {
    final scheme = Theme.of(context).colorScheme;
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: border(scheme.outlineVariant),
      enabledBorder: border(scheme.outlineVariant),
      focusedBorder: border(scheme.primary, 2),
      errorBorder: border(scheme.error),
      focusedErrorBorder: border(scheme.error, 2),
    );
  }

  // ------------------------------------------------------------- Build
  @override
  Widget build(BuildContext context) {
    final donation = _donation.round();
    final total = RegistrationTicket.calculateTotal(
      event: widget.event,
      type: _type,
      kit: _kit,
      donation: donation,
    );

    return PopScope(
      canPop: _step == 0 && !_submitting,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _submitting) return;
        if (_step > 0) _goTo(_step - 1);
      },
      child: Scaffold(
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
          title: const Text(
            'Pendaftaran Tiket',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: _StepIndicator(
                      current: _step,
                      labels: _stepLabels,
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildPersonalStep(),
                      _buildAttendanceStep(),
                      _buildPackageStep(),
                      _buildConfirmStep(total),
                    ],
                  ),
                ),
                _buildBottomBar(total),
              ],
            ),
            if (_submitting) ...[
              const ModalBarrier(dismissible: false, color: Colors.black38),
              Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Memproses pendaftaran...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------- Bottom bar
  Widget _buildBottomBar(int total) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isLast = _step == _lastStep;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x228E6FD8),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_step >= 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Total sementara',
                              style: text.bodyMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ),
                          Text(
                            formatRupiah(total),
                            style: text.titleMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      if (_step > 0) ...[
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                            ),
                            onPressed: _submitting ? null : _back,
                            child: const Text('Kembali'),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                          onPressed: _submitting ? null : _next,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  isLast ? 'Daftar Sekarang' : 'Lanjut',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLast
                                    ? Icons.how_to_reg_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------- Langkah 1: data diri
  Widget _buildPersonalStep() {
    return _StepPage(
      children: [
        _EventSummary(event: widget.event),
        const _SectionHeader(
          icon: Icons.person_rounded,
          title: 'Data Diri',
          subtitle: 'Isi sesuai identitas Anda',
        ),
        Form(
          key: _personalKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: _decoration('Nama lengkap', Icons.badge_outlined),
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return 'Nama lengkap wajib diisi';
                  if (v.length < 3) return 'Nama minimal 3 karakter';
                  if (!RegExp(r"^[A-Za-z\s.'\-]+$").hasMatch(v)) {
                    return 'Nama hanya boleh berisi huruf';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nimCtrl,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: _decoration(
                  'NIM',
                  Icons.numbers_rounded,
                  hint: 'Contoh: 2310123456',
                ),
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return 'NIM wajib diisi';
                  if (v.length < 8) return 'NIM harus 8–12 digit angka';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _decoration(
                  'Email',
                  Icons.email_outlined,
                  hint: 'nama@kampus.ac.id',
                ),
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return 'Email wajib diisi';
                  if (!RegExp(r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)+$')
                      .hasMatch(v)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _waCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _next(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  LengthLimitingTextInputFormatter(15),
                ],
                decoration: _decoration(
                  'Nomor WhatsApp',
                  Icons.chat_outlined,
                  hint: '08123456789',
                ),
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return 'Nomor WhatsApp wajib diisi';
                  if (!RegExp(r'^(\+62|62|0)8[1-9][0-9]{7,11}$').hasMatch(v)) {
                    return 'Gunakan format 08xx atau +628xx';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------ Langkah 2: kehadiran
  Widget _buildAttendanceStep() {
    final event = widget.event;

    return _StepPage(
      children: [
        const _SectionHeader(
          icon: Icons.event_available_rounded,
          title: 'Detail Kehadiran',
          subtitle: 'Pilih tipe peserta dan tanggal hadir',
        ),
        for (final t in ParticipantType.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SelectTile(
              title: t.label,
              subtitle: t.priceFactor == 1
                  ? 'Tarif dasar'
                  : 'Tarif dasar +${((t.priceFactor - 1) * 100).round()}%',
              trailing: formatRupiah(
                RegistrationTicket.ticketPriceFor(event, t),
              ),
              selected: _type == t,
              onTap: () => setState(() => _type = t),
            ),
          ),
        const SizedBox(height: 8),
        Form(
          key: _attendanceKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextFormField(
            controller: _dateCtrl,
            readOnly: true,
            onTap: _pickDate,
            decoration: _decoration(
              'Tanggal kehadiran',
              Icons.calendar_month_rounded,
              hint: 'Pilih tanggal',
              helper: 'Tersedia: ${event.dateLabel}',
              suffix: IconButton(
                tooltip: 'Pilih tanggal',
                onPressed: _pickDate,
                icon: const Icon(Icons.edit_calendar_rounded),
              ),
            ),
            validator: (value) => (value == null || value.isEmpty)
                ? 'Tanggal kehadiran wajib dipilih'
                : null,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------- Langkah 3: kit & donasi
  Widget _buildPackageStep() {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final donation = _donation.round();
    const quickDonations = [0, 10000, 25000, 50000];

    return _StepPage(
      children: [
        const _SectionHeader(
          icon: Icons.card_giftcard_rounded,
          title: 'Paket Seminar Kit',
          subtitle: 'Pilih satu paket',
        ),
        for (final kit in SeminarKit.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SelectTile(
              title: kit.label,
              subtitle: kit.description,
              trailing: formatRupiah(kit.price),
              selected: _kit == kit,
              onTap: () => setState(() => _kit = kit),
            ),
          ),
        const _SectionHeader(
          icon: Icons.volunteer_activism_rounded,
          title: 'Donasi (Opsional)',
          subtitle: 'Untuk beasiswa komunitas mahasiswa',
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Nominal donasi', style: text.bodyMedium),
                  ),
                  Text(
                    formatRupiah(donation, zeroLabel: 'Rp0'),
                    style: text.titleMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _donation,
                min: 0,
                max: 50000,
                divisions: 10,
                label: formatRupiah(donation, zeroLabel: 'Rp0'),
                onChanged: (v) => setState(() => _donation = v),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final value in quickDonations)
                    ChoiceChip(
                      label: Text(formatRupiah(value, zeroLabel: 'Tanpa donasi')),
                      showCheckmark: false,
                      selected: donation == value,
                      onSelected: (_) =>
                          setState(() => _donation = value.toDouble()),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------- Langkah 4: konfirmasi
  Widget _buildConfirmStep(int total) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final event = widget.event;
    final donation = _donation.round();
    final ticketPrice = RegistrationTicket.ticketPriceFor(event, _type);

    return _StepPage(
      children: [
        const _SectionHeader(
          icon: Icons.fact_check_rounded,
          title: 'Konfirmasi',
          subtitle: 'Periksa kembali data pendaftaran Anda',
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Divider(height: 22),
              _SummaryRow(label: 'Nama', value: _nameCtrl.text.trim()),
              _SummaryRow(label: 'NIM', value: _nimCtrl.text.trim()),
              _SummaryRow(label: 'Email', value: _emailCtrl.text.trim()),
              _SummaryRow(label: 'WhatsApp', value: _waCtrl.text.trim()),
              _SummaryRow(label: 'Tipe peserta', value: _type.label),
              _SummaryRow(label: 'Tanggal hadir', value: _dateCtrl.text),
              _SummaryRow(label: 'Seminar kit', value: _kit.label),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.softGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              _PriceRow(
                label: 'Tiket (${_type.label})',
                value: formatRupiah(ticketPrice),
              ),
              _PriceRow(
                label: 'Seminar kit ${_kit.label}',
                value: formatRupiah(_kit.price),
              ),
              _PriceRow(
                label: 'Donasi',
                value: formatRupiah(donation, zeroLabel: 'Rp0'),
              ),
              const Divider(height: 20),
              _PriceRow(label: 'Total', value: formatRupiah(total), bold: true),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Form(
          key: _consentKey,
          child: FormField<bool>(
            initialValue: false,
            validator: (value) =>
                value == true ? null : 'Anda harus menyetujui tata tertib',
            builder: (state) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  value: state.value ?? false,
                  onChanged: (v) => state.didChange(v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Saya menyetujui tata tertib acara.'),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _showRules,
                    icon: const Icon(Icons.menu_book_rounded, size: 18),
                    label: const Text('Baca tata tertib'),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      state.errorText ?? '',
                      style: text.bodySmall?.copyWith(color: scheme.error),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// Widget pendukung
// =====================================================================

/// Halaman satu langkah: bisa di-scroll jika keyboard muncul, state dijaga.
class _StepPage extends StatefulWidget {
  const _StepPage({required this.children});

  final List<Widget> children;

  @override
  State<_StepPage> createState() => _StepPageState();
}

class _StepPageState extends State<_StepPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.children,
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.labels});

  final int current;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StepLine(visible: i > 0, active: i <= current),
                    ),
                    _StepDot(index: i, current: current),
                    Expanded(
                      child: _StepLine(
                        visible: i < labels.length - 1,
                        active: i < current,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: text.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: i == current ? FontWeight.w800 : FontWeight.w500,
                    color: i <= current
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.visible, required this.active});

  final bool visible;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 3,
      decoration: BoxDecoration(
        color: !visible
            ? Colors.transparent
            : (active ? scheme.secondary : scheme.outlineVariant),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.index, required this.current});

  final int index;
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = index < current;
    final filled = index <= current;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: filled ? AppColors.headerGradient : null,
        color: filled ? null : Colors.white,
        border: filled
            ? null
            : Border.all(color: scheme.outlineVariant, width: 2),
      ),
      child: done
          ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
          : Text(
              '${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: filled ? Colors.white : scheme.onSurfaceVariant,
              ),
            ),
    );
  }
}

class _EventSummary extends StatelessWidget {
  const _EventSummary({required this.event});

  final EventItem event;

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 64,
                height: 64,
                child: EventPoster(event: event),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event.dateLabel} • ${event.venue}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: text.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu pilihan (radio style) untuk tipe peserta dan paket seminar kit.
class _SelectTile extends StatelessWidget {
  const _SelectTile({
    required this.title,
    required this.trailing,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String trailing;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: selected ? scheme.primaryContainer : Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? scheme.primary : scheme.outline,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: text.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                trailing,
                style: text.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w800)
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 8),
          Text(value, style: style),
        ],
      ),
    );
  }
}
