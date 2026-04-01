// doctor_appointment.dart (STITCH EXACT)

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/appointment.dart';
import '../../models/patient.dart';
import '../doctor/doctor_patient_list.dart';
import '../doctor/doctor_medical_record.dart';
import '../doctor/doctor_profile.dart';

class DoctorAppointmentPage extends StatefulWidget {
  final User user;

  const DoctorAppointmentPage({super.key, required this.user});

  @override
  State<DoctorAppointmentPage> createState() =>
      _DoctorAppointmentPageState();
}

class _DoctorAppointmentPageState
    extends State<DoctorAppointmentPage> {
  List<Appointment> appointments = [];
  List<Patient> patients = [];
  bool isLoading = true;

  Map<String, String> selectedStatus = {};

  @override
  void initState() {
    super.initState();
    fetch();
  }

  void fetch() async {
    try {
      appointments = await ApiService.getAppointments();
    } catch (_) {}

    try {
      patients = await ApiService.getPatients();
    } catch (_) {}

    setState(() => isLoading = false);
  }

  List<Appointment> get myAppointments =>
      appointments.where((a) => a.doctorCode == widget.user.code).toList();

  String getName(String code) =>
      ApiService.getPatientName(code, patients);

  String? getPhoto(String code) {
    try {
      return patients.firstWhere((p) => p.patientCode == code).photo;
    } catch (_) {
      return null;
    }
  }

  String img(String? path) =>
      path == null || path.isEmpty ? "" : "http://localhost:1234$path";

  int get totalToday => myAppointments.length;
  int get pending =>
      myAppointments.where((a) => a.status == "scheduled").length;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Color(0xFFF9FAF7),
      bottomNavigationBar: _bottomNav(),

      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [

            // ================= HEADER =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          NetworkImage("https://i.pravatar.cc/150"),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Clinic Central",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        Text("PRACTITIONER PANEL",
                            style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1,
                                color: Colors.grey))
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 10),
                    Icon(Icons.notifications, color: Colors.green)
                  ],
                )
              ],
            ),

            SizedBox(height: 30),

            // ================= HERO =================
            Text("DAILY SCHEDULE",
                style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 2,
                    color: Colors.grey)),

            Text("Appointments",
                style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00261B))),

            SizedBox(height: 10),

            Text(
                "Manage your daily patient flow and medical records for today.",
                style: TextStyle(color: Colors.grey)),

            SizedBox(height: 20),

            // ================= STATS =================
            Row(
              children: [
                _statBox("TOTAL TODAY", "$totalToday", false),
                SizedBox(width: 10),
                _statBox("PENDING", "$pending", true),
              ],
            ),

            SizedBox(height: 20),

            // ================= FILTER =================
            Row(
              children: [
                _filter("All Slots", true),
                _filter("Morning", false),
                _filter("Afternoon", false),
              ],
            ),

            SizedBox(height: 20),

            // ================= CARDS =================
            ...myAppointments.map((a) {
              final name = getName(a.patientCode);
              final photo = getPhoto(a.patientCode);
              final isCompleted = a.status == "completed";

              return Container(
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border(
                    left: BorderSide(
                        color: isCompleted
                            ? Colors.grey.shade300
                            : Colors.green,
                        width: 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // HEADER
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage:
                              photo != null ? NetworkImage(img(photo)) : null,
                          child: photo == null ? Text(name[0]) : null,
                        ),
                        SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text("ID: ${a.patientCode}",
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.grey.shade300
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(a.status.toUpperCase()),
                        )
                      ],
                    ),

                    SizedBox(height: 16),

                    // INFO GRID
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("DATE & TIME",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey)),
                            SizedBox(height: 4),
                            Text(a.date),
                            Text(a.time),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("SYMPTOMS",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey)),
                            SizedBox(height: 4),
                            Text(a.symptoms ?? "-"),
                          ],
                        )
                      ],
                    ),

                    SizedBox(height: 16),

                    // DROPDOWN
                    DropdownButtonFormField<String>(
                      value: selectedStatus[a.appointmentCode] ?? a.status,
                      items: ["scheduled", "completed", "cancelled"]
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: isCompleted
                          ? null
                          : (val) {
                              setState(() {
                                selectedStatus[a.appointmentCode] = val!;
                              });
                            },
                    ),

                    SizedBox(height: 12),

                    // BUTTON
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.transparent
                            : null,
                        gradient: isCompleted
                            ? null
                            : LinearGradient(
                                colors: [
                                  Color(0xFF00261B),
                                  Color(0xFF0A3D2E)
                                ],
                              ),
                        border: isCompleted
                            ? Border.all(color: Colors.grey)
                            : null,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          isCompleted
                              ? "Record Locked"
                              : "Save Changes",
                          style: TextStyle(
                              color: isCompleted
                                  ? Colors.grey
                                  : Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),

          ],
        ),
      ),
    );
  }

  Widget _statBox(String title, String value, bool green) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: green ? Colors.green : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 10)),
            Text(value,
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _filter(String text, bool active) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Color(0xFF00261B) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                color: active ? Colors.white : Colors.black)),
      ),
    );
  }

   Widget _bottomNav() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _nav(Icons.dashboard, "Dashboard", false, () {}),

          _nav(Icons.calendar_today, "Appointments", true, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorAppointmentPage(user: widget.user),
              ),
            );
          }),

          _nav(Icons.groups, "Patients", false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorPatientListPage(user: widget.user),
              ),
            );
          }),

          _nav(Icons.description, "Records", false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorMedicalRecordPage(user: widget.user),
              ),
            );
          }),

          _nav(Icons.person, "Profile", false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorProfilePage(user: widget.user),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _nav(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? Colors.green : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
