import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/patient.dart';
import '../../models/appointment.dart';
import '../../theme.dart';
import '../../widgets/doctor_navbar.dart';
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
  List<Patient> filteredPatients = [];

  bool isLoading = true;
  int currentIndex = 2;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  void fetch() async {
    patients = await ApiService.getPatients();
    appointments = await ApiService.getAppointments();

    // 🔥 ambil appointment milik dokter ini saja
    final doctorAppointments = appointments
        .where((a) => a.doctorCode == widget.user.code)
        .toList();

    // 🔥 ambil unique patientCode
    final patientCodes = doctorAppointments.map((a) => a.patientCode).toSet();

    // 🔥 filter patient berdasarkan itu
    filteredPatients = patients
        .where((p) => patientCodes.contains(p.patientCode))
        .toList();

    setState(() => isLoading = false);
  }

  // ================= STATS =================

  int get newPatients => patients.length;

  int get dailyVisits => appointments.length;

  int getVisit(String code) {
    return appointments.where((a) => a.patientCode == code).length;
  }

  // ================= SEARCH =================

  void search(String query) {
    final result = patients.where((p) {
      return p.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() => filteredPatients = result);
  }

  // Photo URLs are resolved via photoUrl() from theme.dart

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Color(0xFFF9FAF7),

      // ✅ NAVBAR CONSISTENT
      bottomNavigationBar: DoctorNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);

          switch (index) {
            case 0:
              Navigator.pop(context);
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorAppointmentPage(user: widget.user),
                ),
              );
              break;
            case 2:
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
                Icon(Icons.notifications, color: Color(0xFF00261B)),
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

            SizedBox(height: 20),

            // ================= SEARCH =================
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                onChanged: search,
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
                Expanded(child: _statBox("$newPatients", "NEW PATIENTS", true)),
                SizedBox(width: 10),
                Expanded(
                  child: _statBox("$dailyVisits", "DAILY VISITS", false),
                ),
              ],
            ),

            SizedBox(height: 20),

            // ================= LIST =================
            ...filteredPatients.map((p) {
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
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: p.photo != null
                          ? NetworkImage(photoUrl(p.photo) ?? '')
                          : null,
                      child: p.photo == null ? Text(p.name[0]) : null,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            p.gender ?? "-",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            p.phone ?? "-",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

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
}
