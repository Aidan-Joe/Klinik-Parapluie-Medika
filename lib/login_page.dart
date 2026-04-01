import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'pages/doctor/doctor_home.dart';
import 'models/user.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  void login() async {
    try {
      User user = await ApiService.login(email.text, password.text);

      if (user.role == 'doctor') {
        Navigator.pushReplacement(
          context,
         MaterialPageRoute(builder: (_) => DoctorHome(user: user)),
        );
      } 
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login gagal")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Column(
        children: [
          TextField(
            controller: email,
            decoration: InputDecoration(labelText: "Email"),
          ),
          TextField(
            controller: password,
            decoration: InputDecoration(labelText: "Password"),
          ),
          ElevatedButton(onPressed: login, child: Text("Login")),
        ],
      ),
    );
  }
}
