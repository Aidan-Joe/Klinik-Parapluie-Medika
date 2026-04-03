import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/doctor.dart';
import '../../theme.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/doctor_navbar.dart';
import '../../login_page.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'doctor_home.dart';
import 'doctor_appointment.dart';
import 'doctor_patient_list.dart';
import 'doctor_medical_record.dart';

class DoctorProfilePage extends StatefulWidget {
  final User user;
  const DoctorProfilePage({super.key, required this.user});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  Doctor? doctor;
  bool isLoading = true;
  bool isAvailable = false;

  int currentIndex = 4;

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      final doctors = await ApiService.getDoctors();

      doctor = doctors.firstWhere(
        (d) => d.doctorCode == widget.user.code,
        orElse: () => Doctor(doctorCode: "", name: ""),
      );

      isAvailable = doctor?.availability == "Available";
    } catch (e) {
      debugPrint("FETCH ERROR: $e");
    }

    if (mounted) setState(() => isLoading = false);
  }

  void updateStatus(bool value) async {
    if (doctor == null) return;

    setState(() => isAvailable = value);

    try {
      await ApiService.updateDoctorStatus(
        doctor!,
        value ? "Available" : "Not Available",
      );
    } catch (e) {
      print("ERROR STATUS: $e");

      // rollback kalau gagal
      setState(() => isAvailable = !value);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });

    
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.logout();

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (_) => false,
              );
            },
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }

  // Photo URLs are resolved via photoUrl() from theme.dart

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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorHome(user: widget.user),
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorAppointmentPage(user: widget.user),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorPatientListPage(user: widget.user),
                ),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorMedicalRecordPage(user: widget.user),
                ),
              );
              break;
            case 4:
              break;
          }
        },
      ),

      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: selectedImage != null
                          ? FileImage(selectedImage!)
                          : (doctor?.photo != null &&
                                  doctor!.photo!.isNotEmpty
                              ? NetworkImage(photoUrl(doctor!.photo) ?? '')
                              : null) as ImageProvider?,
                      child: doctor?.photo == null && selectedImage == null
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

            SizedBox(height: 30),

            // PROFILE CARD
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF16C47F),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : (doctor?.photo != null &&
                                doctor!.photo!.isNotEmpty
                            ? NetworkImage(photoUrl(doctor!.photo) ?? '')
                            : null) as ImageProvider?,
                    child: doctor?.photo == null && selectedImage == null
                        ? Text(widget.user.name[0])
                        : null,
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.user.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text("Doctor", style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 15),

                  GestureDetector(
                    onTap: pickImage,
                    child: Text(
                      "Change Photo",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // AVAILABILITY
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Availability",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: isAvailable,
                    onChanged: updateStatus,
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // INFO
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _info("Doctor ID", widget.user.code),
                  _info("Specialization", doctor?.specialization ?? "-"),
                ],
              ),
            ),

            SizedBox(height: 30),

            // LOGOUT
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout, color: Colors.red),
                label: Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}