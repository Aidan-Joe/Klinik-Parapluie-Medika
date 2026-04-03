import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/appointment.dart';
import '../../models/patient.dart';
import '../../models/medicalrecord.dart';
import '../../models/room.dart';
import '../../models/doctor.dart';

import '../../theme.dart';
import '../../widgets/doctor_navbar.dart';
import '../doctor/doctor_appointment.dart';
import '../doctor/doctor_patient_list.dart';
import '../doctor/doctor_medical_record.dart';
import '../doctor/doctor_profile.dart';

class DoctorHome extends StatefulWidget {
  final User user;

  const DoctorHome({Key? key, required this.user}) : super(key: key);

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  List<Appointment> appointments = [];
  List<Patient> patients = [];
  List<MedicalRecord> records = [];
  List<Room> rooms = [];
  String? doctorPhoto;

  bool isLoading = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      final results = await Future.wait([
        ApiService.getAppointments(),
        ApiService.getDoctors(),
        ApiService.getPatients(),
        ApiService.getMedicalRecords(),
        ApiService.getRooms(),
      ]);

      appointments = results[0] as List<Appointment>;
      final doctors = results[1] as List<Doctor>;
      patients = results[2] as List<Patient>;
      records = results[3] as List<MedicalRecord>;
      rooms = results[4] as List<Room>;

      // ambil foto doctor
      final doctor = doctors.firstWhere(
        (d) => d.doctorCode == widget.user.code,
        orElse: () => Doctor(doctorCode: "", name: "", photo: null),
      );

      doctorPhoto = doctor.photo;
    } catch (e) {
      debugPrint("FETCH ERROR: $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  bool isToday(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();

      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    } catch (_) {
      return false;
    }
  }

  List<Appointment> get doctorAppointments =>
      appointments.where((a) => a.doctorCode == widget.user.code).toList();

  List<Appointment> get todayAppointmentsList =>
      doctorAppointments.where((a) => isToday(a.date)).toList();

  List<Appointment> get queueAppointments {
    final list = todayAppointmentsList
        .where((a) => a.status.toLowerCase() != "completed")
        .toList();

    list.sort((a, b) => a.time.compareTo(b.time));

    return list;
  }

  List<MedicalRecord> get todayRecords {
    final filtered = records
        .where((r) => r.doctorCode == widget.user.code)
        .toList();

    filtered.sort((a, b) => b.visitDate.compareTo(a.visitDate));

    return filtered.take(3).toList();
  }

  int get todayAppointments => todayAppointmentsList.length;

  int get completedToday => todayAppointmentsList
      .where((a) => a.status.toLowerCase() == "completed")
      .length;

  int get totalPatients =>
      doctorAppointments.map((e) => e.patientCode).toSet().length;

  int get pendingRecords {
    final todayAppt = todayAppointmentsList;

    final todayPatients = todayAppt.map((a) => a.patientCode).toSet();

    final patientsWithRecord = records
        .where(
          (r) =>
              r.doctorCode == widget.user.code &&
              isToday(r.visitDate) &&
              todayPatients.contains(r.patientCode),
        )
        .map((r) => r.patientCode)
        .toSet();

    final pendingPatients = todayPatients
        .where((p) => !patientsWithRecord.contains(p))
        .toList();

    return pendingPatients.length;
  }

  Appointment? get nextPatient {
    final now = TimeOfDay.now();

    final valid = todayAppointmentsList.where((a) {
      if (a.status.toLowerCase() == "completed") return false;

      try {
        final parts = a.time.split(":");
        final appt = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );

        return (appt.hour > now.hour) ||
            (appt.hour == now.hour && appt.minute >= now.minute);
      } catch (_) {
        return false;
      }
    }).toList();

    if (valid.isEmpty) return null;

    valid.sort((a, b) => a.time.compareTo(b.time));
    return valid.first;
  }

  String getArrival(Appointment a) {
    try {
      final parts = a.time.split(":");
      final appt = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      final diff = appt.difference(DateTime.now()).inMinutes;

      if (diff <= 0) return "Now";
      return "Arriving in $diff mins";
    } catch (_) {
      return "";
    }
  }

  String? getPatientPhoto(String code) {
    try {
      return photoUrl(
        patients.firstWhere((p) => p.patientCode == code).photo,
      );
    } catch (_) {
      return null;
    }
  }

  Room? get myRoom {
    if (todayAppointmentsList.isEmpty) return null;

    final appt = todayAppointmentsList.firstWhere(
      (a) => a.roomCode != null,
      orElse: () => todayAppointmentsList.first,
    );

    try {
      return rooms.firstWhere((r) => r.roomCode == appt.roomCode);
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
      bottomNavigationBar: DoctorNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);

          switch (index) {
            case 0:
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorHome(user: widget.user),
                ),
              );
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorPatientListPage(user: widget.user),
                ),
              );
              break;
            case 3:
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
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: photoUrl(doctorPhoto) != null
                            ? NetworkImage(photoUrl(doctorPhoto)!)
                            : null,
                        child: doctorPhoto == null
                            ? Text(widget.user.name[0])
                            : null,
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

              // GREETING
              Text(
                "Good Morning, ${widget.user.name}",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00261B),
                ),
              ),

              SizedBox(height: 6),

              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 6),
                  Text(
                    DateTime.now().toString().substring(0, 10),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // SUMMARY (FIX DESIGN)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 1.3,
                children: [
                  _summaryCard(
                    "Today's Appointments",
                    todayAppointments,
                    Icons.calendar_today,
                  ),
                  _summaryCard(
                    "Completed Today",
                    completedToday,
                    Icons.check_circle,
                  ),
                  _summaryCard("Total Patients", totalPatients, Icons.people),
                  _summaryCard(
                    "Records Pending",
                    pendingRecords,
                    Icons.description,
                    topColor: Colors.orange,
                    error: true,
                  ),
                ],
              ),

              SizedBox(height: 25),

              // QUEUE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Patient Queue",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DoctorAppointmentPage(user: widget.user),
                        ),
                      );
                    },
                    child: Text(
                      "View Schedule",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),

              if (queueAppointments.isNotEmpty)
                ...queueAppointments.map((a) {
                  String name = ApiService.getPatientName(
                    a.patientCode,
                    patients,
                  );

                  return Container(
                    margin: EdgeInsets.only(bottom: 14),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        // HEADER
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  getPatientPhoto(a.patientCode) != null
                                  ? NetworkImage(
                                      getPatientPhoto(a.patientCode)!,
                                    )
                                  : null,
                              child: getPatientPhoto(a.patientCode) == null
                                  ? Icon(Icons.person, color: Colors.black54)
                                  : null,
                            ),

                            SizedBox(width: 12),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Symptoms: ${a.symptoms ?? "-"}",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 14),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _info("TIME", a.time),
                            _info("ROOM", a.roomCode ?? "-"),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                a.status.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF00261B),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DoctorAppointmentPage(
                                        user: widget.user,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                })
              else
                _emptyQueue(),

              if (nextPatient != null) _nextCard(nextPatient!),

              SizedBox(height: 15),

              if (myRoom != null)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Room Status",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.meeting_room, color: Colors.green),
                        ],
                      ),

                      SizedBox(height: 15),

                      Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Room ${myRoom!.roomCode}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  myRoom!.roomName,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: myRoom!.status == "Available"
                                        ? Colors.green
                                        : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  myRoom!.status,
                                  style: TextStyle(
                                    color: myRoom!.status == "Available"
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 25),

              // ================= RECENT MEDICAL RECORD FIX =================
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Medical Records",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.description, color: Colors.green),
                      ],
                    ),

                    SizedBox(height: 15),

                    // COLUMN TITLE
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "PATIENT",
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "VISIT DATE",
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "DIAGNOSIS",
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    // DATA
                    ...(todayRecords.isNotEmpty
                        ? todayRecords.reversed.take(3).map((r) {
                            final name = ApiService.getPatientName(
                              r.patientCode,
                              patients,
                            );

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  // NAME
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  // DATE
                                  Expanded(
                                    child: Text(
                                      r.visitDate.isNotEmpty
                                          ? r.visitDate
                                          : "-",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),

                                  // DIAGNOSIS + TAG
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.diagnosis.isNotEmpty
                                              ? r.diagnosis
                                              : "No diagnosis",
                                        ),
                                        SizedBox(height: 4),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            r.prescription,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList()
                        // FALLBACK
                        : todayAppointmentsList.take(3).map((a) {
                            final name = ApiService.getPatientName(
                              a.patientCode,
                              patients,
                            );

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "-",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "No record yet",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList()),

                    SizedBox(height: 10),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DoctorMedicalRecordPage(user: widget.user),
                          ),
                        );
                      },
                      child: Text(
                        "View All Records",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _summaryCard(
    String title,
    int value,
    IconData icon, {
    Color topColor = Colors.green,
    bool error = false,
  }) {
    return Container(
      margin: EdgeInsets.all(6),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        border: Border(top: BorderSide(color: topColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: topColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: topColor),
          ),
          Spacer(),
          Text(
            "$value",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: error ? Colors.red : Color(0xFF00261B),
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _emptyQueue() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.hourglass_empty, size: 40, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "No other patients in the immediate queue.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nextCard(Appointment a) {
    String name = ApiService.getPatientName(a.patientCode, patients);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF0A3D2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "NEXT APPOINTMENT",
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
          SizedBox(height: 15),
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(getArrival(a), style: TextStyle(color: Colors.white70)),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6BFF8F),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                try {
                  await ApiService.updateAppointmentStatus(
                    a.appointmentCode,
                    "completed",
                  );
                } catch (e) {
                  print("START SESSION ERROR: $e");
                }

                // 🔥 PINDAH PAGE TETAP JALAN
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorMedicalRecordPage(user: widget.user),
                  ),
                );
              },
              icon: Icon(Icons.play_arrow, color: Colors.black),
              label: Text(
                "Start Consultation",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
