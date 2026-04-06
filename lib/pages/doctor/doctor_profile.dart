import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/doctor.dart';
import '../../theme.dart';
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
        child: CustomScrollView(
          slivers: [
            // ================= HEADER (TIDAK ADA LOGOUT) =================
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00261B), Color(0xFF004D40)],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),

                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: selectedImage != null
                                ? FileImage(selectedImage!)
                                : (doctor?.photo != null &&
                                              doctor!.photo!.isNotEmpty
                                          ? NetworkImage(
                                              photoUrl(doctor!.photo)!,
                                            )
                                          : null)
                                      as ImageProvider?,
                          ),

                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: pickImage,
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.camera_alt, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      Text(
                        widget.user.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        "Doctor • ${doctor?.specialization ?? '-'}",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ================= AVAILABILITY (NEW DESIGN) =================
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          // ICON BOX
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xFFE8F8F1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.event_available,
                              color: Colors.green,
                            ),
                          ),

                          SizedBox(width: 12),

                          // TEXT
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Availability",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  isAvailable
                                      ? "AVAILABLE NOW"
                                      : "NOT AVAILABLE",
                                  style: TextStyle(
                                    color: isAvailable
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // SWITCH CUSTOM
                          Switch(
                            value: isAvailable,
                            onChanged: updateStatus,
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // ================= DOCTOR ID & SPECIALIZATION =================
                    Row(
                      children: [
                        Expanded(
                          child: _smallCard("Doctor ID", widget.user.code),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _smallCard(
                            "Specialization",
                            doctor?.specialization ?? "-",
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // ================= EMAIL & PHONE =================
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _tile(
                            Icons.email_rounded,
                            "Email",
                            doctor?.email ?? "-",
                          ),
                          Divider(height: 1),
                          _tile(
                            Icons.phone_rounded,
                            "Phone",
                            doctor?.phone ?? "-",
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // ================= LOGOUT =================
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
            ),
          ],
        ),
      ),
    );
  }
  // ================= WIDGET =================

  Widget _tile(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey)),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey)),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
