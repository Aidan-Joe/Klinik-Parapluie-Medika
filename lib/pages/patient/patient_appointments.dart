import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../theme.dart';
import 'patient_book_appointment.dart';

class PatientAppointments extends StatefulWidget {
  final User user;
  const PatientAppointments({Key? key, required this.user}) : super(key: key);

  @override
  State<PatientAppointments> createState() => _PatientAppointmentsState();
}

class _PatientAppointmentsState extends State<PatientAppointments>
    with SingleTickerProviderStateMixin {
  List<Appointment> appointments = [];
  List<Doctor>      doctors      = [];
  bool isLoading = true;
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (mounted) setState(() => isLoading = true);
    await Future.wait([
      ApiService.getAppointments().then((v) => appointments = v).catchError((_) {}),
      ApiService.getDoctors().then((v) => doctors = v).catchError((_) {}),
    ]);
    if (mounted) setState(() => isLoading = false);
  }

  List<Appointment> _filter(String status) {
    if (status == 'all') {
      return [...appointments]..sort((a, b) => b.date.compareTo(a.date));
    }
    return appointments
        .where((a) => a.status.toLowerCase() == status)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Appointments'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetchData),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'All'), Tab(text: 'Scheduled'), Tab(text: 'Completed')],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientBookAppointment(
                user: widget.user,
                doctors: doctors,
                onBooked: _fetchData,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Book', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.darkGreen))
          : TabBarView(
              controller: _tabs,
              children: [
                _list(_filter('all')),
                _list(_filter('scheduled')),
                _list(_filter('completed')),
              ],
            ),
    );
  }

  Widget _list(List<Appointment> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 14),
            const Text('No appointments found',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => _card(items[i]),
    );
  }

  Widget _card(Appointment a) {
    final doctorName = ApiService.getDoctorName(a.doctorCode, doctors);
    final doctor = doctors.where((d) => d.doctorCode == a.doctorCode).isNotEmpty
        ? doctors.firstWhere((d) => d.doctorCode == a.doctorCode)
        : null;
    final color = appointmentStatusColor(a.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                ProfileAvatarInline(
                  name: doctorName,
                  photoUrl: null, // Doctors don't expose photo in API listing
                  radius: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctorName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      if (doctor?.specialization != null)
                        Text(doctor!.specialization!,
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Text(a.status.toUpperCase(),
                      style: TextStyle(
                          color: color, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          // ── Body ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _chip(Icons.calendar_today_rounded, a.date),
                    const SizedBox(width: 10),
                    _chip(Icons.access_time_rounded, a.time),
                    if (a.roomCode != null && a.roomCode!.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      _chip(Icons.meeting_room_rounded, a.roomCode!),
                    ],
                  ],
                ),
                if (a.symptoms != null && a.symptoms!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.sick_outlined, size: 15, color: Colors.grey.shade400),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Symptoms: ${a.symptoms}',
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('ID: ${a.appointmentCode}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkGreen.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.darkGreen),
          const SizedBox(width: 5),
          Text(text,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// Small inline avatar without the full ProfileAvatar import overhead
class ProfileAvatarInline extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double radius;
  const ProfileAvatarInline(
      {required this.name, this.photoUrl, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    final initial =
        name.isNotEmpty ? name[0].toUpperCase() : 'D';
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.accentGreen,
        backgroundImage: NetworkImage(photoUrl!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.accentGreen,
      child: Text(initial,
          style: TextStyle(
              color: AppColors.darkGreen,
              fontWeight: FontWeight.bold,
              fontSize: radius * 0.72)),
    );
  }
}
