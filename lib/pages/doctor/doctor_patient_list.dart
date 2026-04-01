import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/patient.dart';
import '../../models/appointment.dart';
import '../doctor/doctor_appointment.dart';
import '../doctor/doctor_medical_record.dart';
import '../doctor/doctor_profile.dart';

class DoctorPatientListPage extends StatefulWidget {
  final User user;

  const DoctorPatientListPage({super.key, required this.user});

  @override
  State<DoctorPatientListPage> createState() => _DoctorPatientListPageState();
}

class _DoctorPatientListPageState extends State<DoctorPatientListPage> {
  List<Patient> patients = [];
  List<Appointment> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  void fetch() async {
    try {
      patients = await ApiService.getPatients();
      print("PATIENT: ${patients.length}");
    } catch (e) {
      print("PATIENT ERROR: $e");
    }

    try {
      appointments = await ApiService.getAppointments();
    } catch (e) {
      print("APPOINTMENT ERROR: $e");
    }

    setState(() => isLoading = false);
  }

  int getVisit(String code) {
    return appointments.where((a) => a.patientCode == code).length;
  }

  String img(String? path) {
    if (path == null || path.isEmpty) return "";
    return "http://localhost:1234$path";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Color(0xFFF9FAF7),
      bottomNavigationBar: _bottomNav(),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF00261B),
        onPressed: () {},
        child: Icon(Icons.person_add),
      ),

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
                    Icon(Icons.medical_services, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      "Clinic Parapluie",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.notifications),
              ],
            ),

            SizedBox(height: 20),

            // ================= TITLE =================
            Text(
              "Patients",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00261B),
              ),
            ),

            Text(
              "ACTIVE RECORDS · ${patients.length} PATIENTS",
              style: TextStyle(color: Colors.grey),
            ),

            SizedBox(height: 20),

            // ================= SEARCH =================
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: "Search by name...",
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height: 20),

            // ================= STATS =================
            Row(
              children: [
                Expanded(child: _statBox("12", "NEW PATIENTS", true)),
                SizedBox(width: 10),
                Expanded(child: _statBox("24", "DAILY VISITS", false)),
              ],
            ),

            SizedBox(height: 20),

            // ================= LIST =================
            ...patients.map((p) {
              final visit = getVisit(p.patientCode);

              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    // AVATAR + STATUS DOT
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: p.photo != null
                              ? NetworkImage(img(p.photo))
                              : null,
                          child: p.photo == null ? Text(p.name[0]) : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "${p.gender ?? '-'}",
                            style: TextStyle(color: Colors.grey),
                          ),

                          Text(
                            p.phone ?? "-",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "$visit VISITS",
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        SizedBox(height: 6),
                        Icon(Icons.arrow_forward_ios, size: 14),
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

  Widget _statBox(String value, String label, bool green) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: green ? Color(0xFF00261B) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: green ? Colors.white : Colors.black,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: green ? Colors.white70 : Colors.black),
          ),
        ],
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

          _nav(Icons.calendar_today, "Appointments", false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorAppointmentPage(user: widget.user),
              ),
            );
          }),

          _nav(Icons.groups, "Patients", true, () {
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
