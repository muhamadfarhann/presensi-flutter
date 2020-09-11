import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:presensi/pages/login_page.dart';
import 'package:presensi/src/widget/bezzier_container.dart';
import 'package:http/http.dart' as http;
import 'package:presensi/configs/app_config.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isLoading = false;
  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text(
              'Kembali',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _entryFieldNIP(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(height: 10),
          TextField(
              controller: nipController,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true)),
        ],
      ),
    );
  }

  Widget _entryFieldEmail(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(height: 10),
          TextField(
              controller: emailController,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true)),
        ],
      ),
    );
  }

  Widget _entryFieldPassword(String title, {bool isPassword = true}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(height: 10),
          TextField(
              controller: passwordController,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true)),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      child: RaisedButton(
        onPressed: emailController.text == "" || passwordController.text == ""
            ? null
            : () {
                setState(() {
                  _isLoading = true;
                });
                signUp(nipController.text, emailController.text,
                    passwordController.text);
              },
        textColor: Colors.white,
        padding: EdgeInsets.all(0.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Color(0xFF29B6FC), Color(0xFF2979FF)],
            ),
          ),
          //  padding: EdgeInsets.only(left: 143, right: 143, top: 15, bottom: 15),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            'Daftar',
            style: TextStyle(fontSize: 17),
          ),
        ),
      ),
    );
  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Sudah mempunyai akun ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Login',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Daftar',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Color(0xFF29B6FC),
        ),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryFieldNIP("NIP"),
        _entryFieldEmail("Email"),
        _entryFieldPassword("Password", isPassword: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer(),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .2),
                    _title(),
                    SizedBox(height: 50),
                    _emailPasswordWidget(),
                    SizedBox(height: 20),
                    _submitButton(),
                    SizedBox(height: height * .14),
                    _loginAccountLabel()
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }

  final TextEditingController nipController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  signUp(String employeeCode, email, password) async {
    print(password);
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    final androidDeviceId = androidDeviceInfo.androidId;

    Map data = {
      "employee_code": employeeCode,
      "email": email,
      "password": password,
      "device_id": androidDeviceId
    };
    print(data);
    var jsonResponse = null;
    AppConfig config = new AppConfig();
    var response =
        await http.post("${config.apiURL}/api/user/create", body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      showAlertDialog('Success', jsonResponse['message'], DialogType.SUCCES,
          context, () {
            Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => LoginPage()),
                      (Route<dynamic> route) => false);
          });
    } else {
      jsonResponse = json.decode(response.body);
      showAlertDialog(
          'Failed', jsonResponse['message'], DialogType.ERROR, context, () {});
    }
  }

  void showAlertDialog(String title, String message, DialogType dialogType,
      BuildContext context, VoidCallback onOkPress) {
    AwesomeDialog(
            context: context,
            animType: AnimType.TOPSLIDE,
            dialogType: dialogType,
            title: title,
            headerAnimationLoop: false,
            desc: message,
            btnOkIcon: Icons.check_circle,
            btnOkColor: Color(0xFF2979FF),
            btnOkOnPress: onOkPress)
        .show();
  }
}
