import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:presensi/configs/app_config.dart';
import 'package:presensi/pages/dashboard.dart';
import 'package:presensi/pages/sign_up.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String bullet = "\u2022 ";
  String _error;
  bool _isLoading = false;
  AppConfig config = new AppConfig();
  ProgressDialog progressDialog;

  @override
  void initState() {
    checkLoginStatus();
    super.initState();
  }

  checkLoginStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // String id = sharedPreferences.getInt("employee_id").toString();
    String token = sharedPreferences.getString("token");
    if (token != null) {
      // get User
      var jsonResponse = null;

      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${token}'
      };
      var response = await http.get("${config.apiURL}/api/user/get-profile",
          headers: requestHeaders);
      if (response.statusCode == 200) {
        jsonResponse = json.decode(response.body);

        setState(() {
          _isLoading = false;
          _error = null;
        });
        sharedPreferences.setInt(
            "employee_id)", jsonResponse['employee']['id']);

        String timeIn = 'Belum Absen';
        String timeOut = 'Belum Absen';

        if (jsonResponse['employee']['attendance'] != null) {
          timeIn = jsonResponse['employee']['attendance']['time_in'];
          timeOut =
              jsonResponse['employee']['attendance']['time_out'].toString() !=
                      null
                  ? jsonResponse['employee']['attendance']['time_out']
                  : "Belum Absen";
        }
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => Dashboard()),
            (Route<dynamic> route) => false);
      } else {
        setState(() {
          _isLoading = false;
          _error = "Terjadi Kesalahan Sistem";
        });
      }
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

  // Sign in
  signIn(String email, password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map data = {
      'username': email,
      'password': password,
      'client_id': '2',
      'grant_type': 'password',
      'client_secret': 'SW9uL4QFXM81iHO85ioiIVazyGfLopXpWqmQK47M'
    };

    var jsonResponse = null;

    var response = await http.post("${config.apiURL}/oauth/token", body: data);

    jsonResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        _error = null;
      });
      sharedPreferences.setString("token", jsonResponse['access_token']);

      var token = sharedPreferences.getString('token');

      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${token}'
      };

      final response2 = await http.get('${config.apiURL}/api/user/get-profile',
          headers: requestHeaders);
      final responseJson2 = json.decode(response2.body);
      sharedPreferences.setInt("employee_id", responseJson2['employee']['id']);

      String timeIn = 'Belum Absen';
      String timeOut = 'Belum Absen';

      if (responseJson2['employee']['attendance'] != null) {
        timeIn = responseJson2['employee']['attendance']['time_in'];
        timeOut =
            responseJson2['employee']['attendance']['time_out'].toString() !=
                    null
                ? responseJson2['employee']['attendance']['time_out']
                : "Belum Absen";
      }

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => Dashboard()),
          (Route<dynamic> route) => false);
    } else {
      showAlertDialog(
          'Failed', jsonResponse['message'], DialogType.ERROR, context, () {});
      setState(() {
        _isLoading = false;
        // _error = jsonResponse["message"];
      });
      // print(response.body);
    }
  }

  @override
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
            Text('Back',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Nunito'))
          ],
        ),
      ),
    );
  }

  Widget _entryFieldEmail(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Nunito'),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              controller: emailController,
              style: TextStyle(
                fontFamily: "Nunito",
                fontSize: 15,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10),
                  )
                ),
                hintText: "user@example.com",
                fillColor: Color(0xfff3f3f4),
                filled: false,
            ),
            )
        ],
      ),
    );
  }

  Widget _entryFieldPassword(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Nunito'),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: passwordController,
            obscureText: isPassword,
            style: TextStyle(
              fontSize: 15,
              fontFamily: "Nunito",
            ),
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10),
                  )
                ),
                hintText: '${bullet}${bullet}${bullet}${bullet}${bullet}${bullet}',
                fillColor: Color(0xfff3f3f4),
                filled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton(ProgressDialog) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      child: FlatButton(
        onPressed: emailController.text == "" || passwordController.text == ""
            ? null
            : () {
                setState(() {
                  _isLoading = true;
                });
                progressDialog.show();
                Future.delayed(Duration(seconds: 2)).then((value) {
                  // progressDialog.update(message: "Menyambungkan");
                  signIn(emailController.text, passwordController.text);
                  progressDialog.hide();
                });
              },
        textColor: Colors.white,
        padding: EdgeInsets.all(0.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Color(0xFF2979FF),
          ),
          //  padding: EdgeInsets.only(left: 143, right: 143, top: 15, bottom: 15),
          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            'Login',
            style: TextStyle(
                fontSize: 15, fontFamily: 'Nunito', color: Colors.white),
          ),
        ),
      ),
    );
  }

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignUpPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Belum Memiliki Akun ?',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito'),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Register',
              style: TextStyle(
                  // color: Color(0xFF29B6FC),
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'Nunito',
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
        text: 'Login',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontSize: 30,
          fontWeight: FontWeight.w700,
          // color: Color(0xFF29B6FC),
        ),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryFieldEmail("Email"),
        _entryFieldPassword("Password", isPassword: true),
      ],
    );
  }

  Widget showAlert() {
    if (_error != null) {
      return Container(
        color: Colors.pinkAccent[400],
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline, color: Colors.white),
            ),
            Expanded(
              child: AutoSizeText(
                _error,
                maxLines: 3,
                style: TextStyle(color: Colors.white),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                },
              ),
            )
          ],
        ),
      );
    }
    return SizedBox(
      height: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        color: Color(0xFF2979FF),
        // borderRadius: BorderRadius.only(
        //   bottomLeft: Radius.circular(30.0),
        //   bottomRight: Radius.circular(30.0),
        //   topLeft: Radius.circular(30.0),
        //   topRight: Radius.circular(30.0),
        // ),
      ),
      height: height,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .15),
                  _title(),
                  SizedBox(height: height * .070),
                  // showAlert(),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0),
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        _emailPasswordWidget(),
                        SizedBox(height: 20),
                        _submitButton(progressDialog),
                      ],
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.centerRight,
                    child: Text('Forgot Password ?',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ),
                  // _divider(),
                  // _facebookButton(),
                  _createAccountLabel(),
                ],
              ),
            ),
          ),
          Positioned(top: 40, left: 0, child: _backButton()),
        ],
      ),
    ));
  }
}
