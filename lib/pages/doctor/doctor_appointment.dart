import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/appointment.dart';
import '../../models/patient.dart';
import '../doctor/doctor_patient_list.dart';
import '../doctor/doctor_medical_record.dart';
import '../doctor/doctor_profile.dart';
import '../../theme.dart';
import '../../widgets/doctor_navbar.dart';

class DoctorAppointmentPage extends StatefulWidget {
  final User user;

  const DoctorAppointmentPage({super.key, required this.user});

  @override
  State<DoctorAppointmentPage> createState() => _DoctorAppointmentPageState();
}

class _DoctorAppointmentPageState extends State<DoctorAppointmentPage> {
  List<Appointment> appointments = [];
  List<Patient> patients = [];
  bool isLoading = true;

  int currentIndex = 1;

  String selectedFilter = "all";

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

  // ================= DATA =================

  List<Appointment> get myAppointments =>
      appointments.where((a) => a.doctorCode == widget.user.code).toList();

  int get totalVisit => myAppointments.length;

  int get scheduled =>
      myAppointments.where((a) => a.status == "scheduled").length;

  // ================= FILTER =================

  List<Appointment> get filteredAppointments {
    if (selectedFilter == "morning") {
      return myAppointments.where((a) {
        final hour = int.tryParse(a.time.split(":")[0]) ?? 0;
        return hour < 12;
      }).toList();
    }

    if (selectedFilter == "afternoon") {
      return myAppointments.where((a) {
        final hour = int.tryParse(a.time.split(":")[0]) ?? 0;
        return hour >= 12;
      }).toList();
    }

    return myAppointments;
  }

  // ================= HELPERS =================

  String getName(String code) => ApiService.getPatientName(code, patients);

  String? getPhoto(String code) {
    try {
      return photoUrl(
        patients.firstWhere((p) => p.patientCode == code).photo,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Color(0xFFF9FAF7),

      // ================= NAVBAR =================
      bottomNavigationBar: DoctorNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);

          switch (index) {
            case 0:
              Navigator.pop(context);
              break;
            case 1:
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorPatientListPage(user: widget.user),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorMedicalRecordPage(user: widget.user),
                ),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorProfilePage(user: widget.user),
                ),
              );
              break;
          }
        },
      ),

      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // ================= HEADER =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // LEFT SIDE
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF00261B),
                      child: Text(
                        widget.user.name.isNotEmpty
                            ? widget.user.name[0].toUpperCase()
                            : "D",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    SizedBox(width: 10),

                    Text(
                      "Clinic Parapluie",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF00261B),
                      ),
                    ),
                  ],
                ),

                // RIGHT SIDE
                Icon(Icons.notifications, color: Color(0xFF00261B)),
              ],
            ),

            SizedBox(height: 30),

            // ================= HERO =================
            Text(
              "DAILY SCHEDULE",
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 2,
                color: Colors.grey,
              ),
            ),

            Text(
              "Appointments",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00261B),
              ),
            ),

            SizedBox(height: 10),

            Text(
              "Manage your daily patient flow and medical records for today.",
              style: TextStyle(color: Colors.grey),
            ),

            SizedBox(height: 20),

            // ================= STATS =================
            Row(
              children: [
                _statBox("TOTAL VISIT", "$totalVisit", false),
                SizedBox(width: 10),
                _statBox("SCHEDULED", "$scheduled", true),
              ],
            ),

            SizedBox(height: 20),

            // ================= FILTER =================
            Row(
              children: [
                _filter("All Slots", "all"),
                _filter("Morning", "morning"),
                _filter("Afternoon", "afternoon"),
              ],
            ),

            SizedBox(height: 20),

            // ================= LIST =================
            ...filteredAppointments.map((a) {
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
                      color: isCompleted ? Colors.grey.shade300 : Colors.green,
                      width: 4,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: photo != null
                              ? NetworkImage(photo)
                              : null,
                          child: photo == null ? Text(name[0]) : null,
                        ),
                        SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "ID: ${a.patientCode}",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: a.status == "completed"
                                ? Colors.grey.shade300
                                : a.status == "scheduled"
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(a.status.toUpperCase()),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DATE & TIME",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(a.date),
                            Text(a.time),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SYMPTOMS",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(a.symptoms ?? "-"),
                          ],
                        ),
                      ],
                    ),
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
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filter(String text, String value) {
    final active = selectedFilter == value;

    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          setState(() => selectedFilter = value);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? Color(0xFF00261B) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: TextStyle(color: active ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}
