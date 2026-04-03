import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/medicalrecord.dart';
import '../../models/patient.dart';
import '../../models/doctor.dart';

import '../../widgets/doctor_navbar.dart';
import '../../theme.dart';
import '../../widgets/profile_avatar.dart';
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
  List<MedicalRecord> filtered = [];
  List<Doctor> doctors = [];

  bool isLoading = true;
  int currentIndex = 3;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    records = await ApiService.getMedicalRecords();
    patients = await ApiService.getPatients();
    doctors = await ApiService.getDoctors();

    filtered = records;

    setState(() => isLoading = false);
  }

  List<MedicalRecord> get myRecords =>
      filtered.where((r) => r.doctorCode == widget.user.code).toList();

  void search(String q) {
    final result = records.where((r) {
      final name = getName(r.patientCode).toLowerCase();
      return name.contains(q.toLowerCase()) ||
          r.diagnosis.toLowerCase().contains(q.toLowerCase());
    }).toList();

    setState(() => filtered = result);
  }

  String getName(String code) {
    try {
      return patients.firstWhere((p) => p.patientCode == code).name;
    } catch (_) {
      return code;
    }
  }

  String? getDoctorPhoto(String code) {
    try {
      return photoUrl(
        doctors.firstWhere((d) => d.doctorCode == code).photo,
      );
    } catch (_) {
      return null;
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

  void openForm({MedicalRecord? record}) {
    String? selectedPatient = record?.patientCode;
    DateTime selectedDate = record != null
        ? DateTime.parse(record.visitDate)
        : DateTime.now();

    final diagnosis = TextEditingController(text: record?.diagnosis ?? "");
    final treatment = TextEditingController(text: record?.treatment ?? "");
    final prescription = TextEditingController(
      text: record?.prescription ?? "",
    );

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(record == null ? "Add Record" : "Edit Record"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedPatient,
                  hint: Text("Select Patient"),
                  items: patients.map((p) {
                    return DropdownMenuItem(
                      value: p.patientCode,
                      child: Text(p.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setModalState(() => selectedPatient = val);
                  },
                ),

                SizedBox(height: 10),

                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      setModalState(() => selectedDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: "Visit Date"),
                    child: Text("${selectedDate.toLocal()}".split(' ')[0]),
                  ),
                ),

                SizedBox(height: 10),

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
              onPressed: () async {
                try {
                  if (selectedPatient == null) {
                    throw Exception("Patient belum dipilih");
                  }

                  final data = {
                    "Patientcode": selectedPatient,
                    "DoctorCode": widget.user.code,
                    "Visit_date": selectedDate.toIso8601String().split("T")[0],
                    "Diagnosis": diagnosis.text,
                    "Treatment": treatment.text,
                    "Prescription": prescription.text,
                  };

                  if (record == null) {
                    await ApiService.createMedicalRecord(data);
                  } else {
                    await ApiService.updateMedicalRecord(
                      record.recordCode,
                      data,
                    );
                  }

                  await fetch();
                  Navigator.pop(context);
                } catch (e) {
                  print("ERROR: $e");

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Gagal simpan data")));
                }
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF00261B),
        onPressed: () => openForm(),
        child: Icon(Icons.add),
      ),

      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ProfileAvatar(
                      name: widget.user.name,
                      photoUrl: getDoctorPhoto(widget.user.code),
                      radius: 20,
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

            SizedBox(height: 30),

             Text(
              "LIST OF MEDICAL RECORDS",
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

            SizedBox(height: 20),

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
                  hintText: "Search patient or diagnosis...",
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF00261B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "${myRecords.length} TOTAL RECORDS",
                style: TextStyle(color: Colors.white),
              ),
            ),

            SizedBox(height: 20),

            ...myRecords.map((r) {
              final name = getName(r.patientCode);

              return Container(
                margin: EdgeInsets.only(bottom: 14),
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    ProfileAvatar(
                      name: name,
                      photoUrl: getPatientPhoto(r.patientCode),
                      radius: 22,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(r.diagnosis),
                          Text(r.visitDate),
                        ],
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () => openForm(record: r),
                      child: Text("Edit"),
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
}
