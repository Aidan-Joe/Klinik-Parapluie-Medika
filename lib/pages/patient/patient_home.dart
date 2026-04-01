import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../models/medicalrecord.dart';
import '../../models/patient.dart';
import '../../theme.dart';
import '../../widgets/patient_nav_bar.dart';
import '../../widgets/profile_avatar.dart';
import 'patient_appointments.dart';
import 'patient_book_appointment.dart';
import 'patient_medical_records.dart';
import 'patient_profile.dart';

class PatientHome extends StatefulWidget {
  final User user;
  const PatientHome({Key? key, required this.user}) : super(key: key);

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _DashboardTab(user: widget.user, onNavigate: _go),
      PatientAppointments(user: widget.user),
      PatientMedicalRecords(user: widget.user),
      PatientProfile(user: widget.user),
    ];
  }

  void _go(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: PatientNavBar(
        currentIndex: _currentIndex,
        onTap: _go,
      ),
    );
  }
}

// ─── DASHBOARD TAB ────────────────────────────────────────────────────────────

class _DashboardTab extends StatefulWidget {
  final User user;
  final void Function(int) onNavigate;
  const _DashboardTab({required this.user, required this.onNavigate});

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  List<Appointment>   appointments = [];
  List<Doctor>        doctors      = [];
  List<MedicalRecord> records      = [];
  Patient?            profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (mounted) setState(() => isLoading = true);
    await Future.wait([
      ApiService.getAppointments().then((v) => appointments = v).catchError((_) {}),
      ApiService.getDoctors().then((v) => doctors = v).catchError((_) {}),
      ApiService.getMedicalRecords().then((v) => records = v).catchError((_) {}),
      ApiService.getMyProfile(widget.user.code).then((v) => profile = v).catchError((_) {}),
    ]);
    if (mounted) setState(() => isLoading = false);
  }

  // ─── Computed ─────────────────────────────────────────────────────────────

  List<Appointment> get _upcoming {
    final today = DateTime.now();
    return appointments.where((a) {
      try {
        final d = DateTime.parse(a.date);
        return !d.isBefore(DateTime(today.year, today.month, today.day)) &&
            a.status.toLowerCase() != 'completed';
      } catch (_) { return false; }
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  int get _scheduledCount =>
      _upcoming.where((a) => a.status.toLowerCase() == 'scheduled').length;

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.darkGreen)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryRow(),
                  const SizedBox(height: 24),
                  _bookCta(),
                  const SizedBox(height: 28),
                  _sectionHeader('Upcoming Appointments', onTap: () => widget.onNavigate(1)),
                  const SizedBox(height: 14),
                  if (_upcoming.isEmpty)
                    _emptyState('No upcoming appointments', Icons.calendar_today_outlined)
                  else
                    ..._upcoming.take(3).map(_appointmentCard),
                  const SizedBox(height: 28),
                  _sectionHeader('Recent Medical Records', onTap: () => widget.onNavigate(2)),
                  const SizedBox(height: 14),
                  if (records.isEmpty)
                    _emptyState('No medical records yet', Icons.description_outlined)
                  else
                    _recentRecordsCard(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sliver AppBar ────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 190,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.darkGreen,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: AppDecorations.headerGradient,
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome back,',
                          style: TextStyle(color: Colors.white60, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(widget.user.name, style: AppTextStyles.headingOnDark),
                      const SizedBox(height: 4),
                      Text(
                        DateTime.now().toString().substring(0, 10),
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                  ProfileAvatar(
                    name: widget.user.name,
                    photoUrl: photoUrl(profile?.photo),
                    radius: 28,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Summary Row ──────────────────────────────────────────────────────────

  Widget _summaryRow() {
    return Row(
      children: [
        _summaryCard('Upcoming', _upcoming.length,
            Icons.calendar_today_rounded, AppColors.accentBlue),
        const SizedBox(width: 12),
        _summaryCard('Records', records.length,
            Icons.description_rounded, AppColors.accentTeal),
        const SizedBox(width: 12),
        _summaryCard('Scheduled', _scheduledCount,
            Icons.schedule_rounded, AppColors.accentOrange),
      ],
    );
  }

  Widget _summaryCard(String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          border: Border(top: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text('$value',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen)),
            const SizedBox(height: 3),
            Text(label, style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }

  // ─── Book CTA ─────────────────────────────────────────────────────────────

  Widget _bookCta() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientBookAppointment(
            user: widget.user,
            doctors: doctors,
            onBooked: _fetchData,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppDecorations.darkCard,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accentGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.darkGreen, size: 22),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Book an Appointment',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  SizedBox(height: 3),
                  Text('Choose a doctor and consultation time',
                      style: TextStyle(color: Colors.white60, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.accentGreen, size: 18),
          ],
        ),
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────────────────────

  Widget _sectionHeader(String title, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.heading3),
        GestureDetector(
          onTap: onTap,
          child: const Text('View All',
              style: TextStyle(
                  color: AppColors.accentTeal,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      ],
    );
  }

  // ─── Appointment Card ─────────────────────────────────────────────────────

  Widget _appointmentCard(Appointment a) {
    final doctorName = ApiService.getDoctorName(a.doctorCode, doctors);
    final color      = appointmentStatusColor(a.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: AppDecorations.iconBadge(AppColors.darkGreen),
            child: const Icon(Icons.medical_services_rounded,
                color: AppColors.darkGreen, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctorName, style: AppTextStyles.bodyBold),
                const SizedBox(height: 3),
                Text('${a.date}  •  ${a.time}',
                    style: AppTextStyles.caption),
                if (a.symptoms != null && a.symptoms!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('Symptoms: ${a.symptoms}',
                      style: AppTextStyles.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: AppDecorations.statusBadge(color),
            child: Text(a.status.toUpperCase(),
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ─── Recent Records ───────────────────────────────────────────────────────

  Widget _recentRecordsCard() {
    return Container(
      decoration: AppDecorations.cardFlat,
      child: Column(
        children: records.reversed.take(3).map((r) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: AppDecorations.iconBadge(AppColors.accentTeal),
                      child: const Icon(Icons.description_rounded,
                          color: AppColors.accentTeal, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.diagnosis.isNotEmpty ? r.diagnosis : 'No diagnosis',
                            style: AppTextStyles.bodyBold,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          Text(r.visitDate, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    if (r.prescription.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(r.prescription,
                            style: const TextStyle(
                                color: AppColors.statusCompleted,
                                fontSize: 11),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                ),
              ),
              if (r != records.reversed.take(3).last)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────

  Widget _emptyState(String msg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 36, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(msg, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
