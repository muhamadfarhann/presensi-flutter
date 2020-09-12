import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:presensi/pages/dashboard.dart';
import 'package:presensi/pages/login_page.dart';
import 'package:presensi/pages/sign_up.dart';
import 'package:presensi/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presensi/configs/app_config.dart';

class WelcomePage extends StatefulWidget {

  WelcomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> { 
  
  AppConfig config = new AppConfig();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  } 
  
  checkLoginStatus() async {
    print(config.apiURL);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String id = sharedPreferences.getInt("user_id").toString();
    if (sharedPreferences.getInt("user_id") != null) {
      
      var jsonResponse = null;
      var response = await http
          .post("${config.apiURL}/api/user/get-user", body: {
            'id': id
          });
      if (response.statusCode == 200) {
        jsonResponse = json.decode(response.body);
        if (jsonResponse != null && jsonResponse['statusCode'] == 200) {
          // User user = new User(
          //     code:'', //jsonResponse['data']['employee']['employee_code'],
          //     name: '',// jsonResponse['data']['employee']['name'],
          //     position: '',//jsonResponse['data']['employee']['position'],
          //     status: '',//jsonResponse['data']['employee']['status'],
          //     email: ''//jsonResponse['data']['email']);
          // );

          User user = new User(
              code: jsonResponse['data']['employee']['employee_code'],
              name: jsonResponse['data']['employee']['name'],
              position: jsonResponse['data']['employee']['position'],
              status: jsonResponse['data']['employee']['status']);

          //print(jsonResponse['data']['employee']['name']);

          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => Dashboard()),
              (Route<dynamic> route) => false);

          // Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard(user: user)));
        }
      }
    }
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Colors.white
        ),
        child: Text(
          'Login',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF29B6FC)
          ),
        ),
      ),
    );
  }

  Widget _signUpButton(){
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.white, width:2),
        ),
        child: Text(
          'Daftar Sekarang',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _title(){
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Presensi \nKaryawan',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2,4),
                blurRadius: 5,
                spreadRadius: 2
              )
            ],
            color: Color(0xFF2979FF),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _title(),
              SizedBox(
                height: 80
              ),
              _submitButton(),
              SizedBox(
                height: 20,
              ),
              _signUpButton(),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        )
      ),
    );
  }

}