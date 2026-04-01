import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/doctor.dart';
import 'dart:html' as html;


class DoctorProfilePage extends StatefulWidget {
  final User user;

  const DoctorProfilePage({super.key, required this.user});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  Doctor? doctor;
  bool isLoading = true;
  bool isAvailable = true;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  void fetch() async {
    final list = await ApiService.getDoctors();
    doctor = list.firstWhere((d) => d.doctorCode == widget.user.code);
    setState(() => isLoading = false);
  }

  String img(String? path) {
    if (path == null || path.isEmpty) return "";
    return "http://localhost:1234$path";
  }

  void uploadPhoto() {
    final input = html.FileUploadInputElement();
    input.click();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Color(0xFFF9FAF7),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            children: [

              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medical_services, color: Color(0xFF0A3D2E)),
                      SizedBox(width: 8),
                      Text("Clinical Dashboard",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xFF0A3D2E)))
                    ],
                  ),
                  Icon(Icons.notifications)
                ],
              ),

              SizedBox(height: 30),

              // AVATAR (STITCH STYLE)
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF4AE176), Color(0xFF0A3D2E)],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 56,
                        backgroundImage: doctor!.photo != null
                            ? NetworkImage(img(doctor!.photo))
                            : null,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: uploadPhoto,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF0A3D2E),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 6)
                          ],
                        ),
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),

              SizedBox(height: 18),

              // NAME
              Text(
                doctor!.name,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00261B)),
              ),

              SizedBox(height: 6),

              Text(
                "${doctor!.doctorCode} · ${doctor!.specialization}",
                style: TextStyle(
                    letterSpacing: 1.2,
                    fontSize: 12,
                    color: Colors.grey),
              ),

              SizedBox(height: 20),

              // BUTTONS
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00261B), Color(0xFF0A3D2E)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text("Edit Profile",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(child: Text("Upload Photo")),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // AVAILABILITY CARD
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 8)
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFF6BFF8F),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.event_available,
                              color: Color(0xFF0A3D2E)),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Availability Status",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("Currently accepting patients",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      ],
                    ),
                    Switch(
                      value: isAvailable,
                      activeColor: Color(0xFF0A3D2E),
                      onChanged: (v) => setState(() => isAvailable = v),
                    )
                  ],
                ),
              ),

              SizedBox(height: 20),

              // INFO CARD
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF1F2EF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _info(Icons.email, "Email Address", doctor!.email ?? "-"),
                    _info(Icons.phone, "Phone Number", doctor!.phone ?? "-"),
                    _info(Icons.medical_services, "Specialization",
                        doctor!.specialization ?? "-"),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // STATS CARD (SPLIT STYLE)
              Container(
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Color(0xFF00261B), Color(0xFF0A3D2E)],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _stat("TOTAL CONSULTATIONS", "1,248"),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.black.withOpacity(0.1),
                        child: _stat("EXPERIENCE", "12 Yrs"),
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: 30),

              // SETTINGS
              _menu("Security & Password"),
              _menu("Language Preferred"),
              _menu("Logout Account", isLogout: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(IconData icon, String title, String val) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title.toUpperCase(),
          style: TextStyle(fontSize: 11, color: Colors.grey)),
      subtitle: Text(val, style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _stat(String t, String v) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(t, style: TextStyle(color: Colors.white70, fontSize: 10)),
        Text(v,
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold))
      ],
    );
  }

  Widget _menu(String t, {bool isLogout = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(t,
              style: TextStyle(
                  color: isLogout ? Colors.red : Colors.black,
                  fontWeight: FontWeight.w600)),
          Icon(Icons.arrow_forward_ios, size: 14)
        ],
      ),
    );
  }
}