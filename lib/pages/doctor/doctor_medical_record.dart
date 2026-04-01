import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/medicalrecord.dart';
import '../../models/patient.dart';
import '../doctor/doctor_appointment.dart';
import '../doctor/doctor_patient_list.dart';
import '../doctor/doctor_profile.dart';

class DoctorMedicalRecordPage extends StatefulWidget {
  final User user;

  const DoctorMedicalRecordPage({super.key, required this.user});

  @override
  State<DoctorMedicalRecordPage> createState() =>
      _DoctorMedicalRecordPageState();
}

class _DoctorMedicalRecordPageState extends State<DoctorMedicalRecordPage> {
  List<MedicalRecord> records = [];
  List<Patient> patients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  void fetch() async {
    try {
      records = await ApiService.getMedicalRecords();
      print("RECORD: ${records.length}");
    } catch (e) {
      print("RECORD ERROR: $e");
    }

    try {
      patients = await ApiService.getPatients();
      print("PATIENT: ${patients.length}");
    } catch (e) {
      print("PATIENT ERROR: $e");
    }

    setState(() => isLoading = false);
  }

  // ================= FORM =================

  void openForm({MedicalRecord? record}) {
    final diagnosis = TextEditingController(text: record?.diagnosis ?? "");
    final treatment = TextEditingController(text: record?.treatment ?? "");
    final prescription = TextEditingController(
      text: record?.prescription ?? "",
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(record == null ? "Add Record" : "Edit Record"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: diagnosis,
                decoration: InputDecoration(labelText: "Diagnosis"),
              ),
              TextField(
                controller: treatment,
                decoration: InputDecoration(labelText: "Treatment"),
              ),
              TextField(
                controller: prescription,
                decoration: InputDecoration(labelText: "Prescription"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (record != null) {
                  final index = records.indexOf(record);

                  records[index] = MedicalRecord(
                    recordCode: record.recordCode,
                    patientCode: record.patientCode,
                    doctorCode: record.doctorCode,
                    diagnosis: diagnosis.text,
                    treatment: treatment.text,
                    prescription: prescription.text,
                    visitDate: record.visitDate,
                  );
                } else {
                  records.add(
                    MedicalRecord(
                      recordCode: "NEW",
                      patientCode: patients.first.patientCode,
                      doctorCode: widget.user.code,
                      diagnosis: diagnosis.text,
                      treatment: treatment.text,
                      prescription: prescription.text,
                      visitDate: DateTime.now().toString().substring(0, 10),
                    ),
                  );
                }
              });

              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  List<MedicalRecord> get myRecords =>
      records.where((r) => r.doctorCode == widget.user.code).toList();

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
        onPressed: () => openForm(),
        child: Icon(Icons.add),
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
                      backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/150",
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Clinic Parapluie",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.notifications),
              ],
            ),

            SizedBox(height: 30),

            // ================= TITLE =================
            Text(
              "CLINICAL DATABASE",
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 2,
                color: Colors.grey,
              ),
            ),

            Text(
              "Medical Records",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00261B),
              ),
            ),

            SizedBox(height: 10),

            Text(
              "Comprehensive view of patient histories and diagnoses.",
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
                  hintText: "Search patient or diagnosis...",
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height: 20),

            // ================= STATS =================
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF00261B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TOTAL RECORDS",
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      Text(
                        "${myRecords.length}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.folder, color: Colors.white54),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ================= LIST =================
            ...myRecords.map((r) {
              String getName(String code) {
                try {
                  return patients.firstWhere((p) => p.patientCode == code).name;
                } catch (e) {
                  return code;
                }
              }

              final name = getName(r.patientCode);
              final initials = name.isNotEmpty
                  ? (name.length >= 2 ? name.substring(0, 2) : name[0])
                  : "--";

              return Container(
                margin: EdgeInsets.only(bottom: 14),
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LEFT SIDE
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey.shade200,
                          child: Text(initials),
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

                            SizedBox(height: 6),

                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: r.diagnosis.contains("Diabetes")
                                        ? Colors.green.shade100
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(r.diagnosis),
                                ),

                                SizedBox(width: 10),

                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 14),
                                    SizedBox(width: 4),
                                    Text(r.visitDate),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    // RIGHT SIDE
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black,
                            elevation: 0,
                          ),
                          onPressed: () => openForm(record: r),
                          icon: Icon(Icons.edit, size: 16),
                          label: Text("Edit"),
                        ),

                        SizedBox(width: 8),

                        Icon(Icons.delete, color: Colors.grey),
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

          _nav(Icons.groups, "Patients", false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorPatientListPage(user: widget.user),
              ),
            );
          }),

          _nav(Icons.description, "Records", true, () {
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
