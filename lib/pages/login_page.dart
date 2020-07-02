import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:presensi/configs/app_config.dart';
import 'package:presensi/pages/dashboard.dart';
import 'package:presensi/models/user.dart';
import 'package:presensi/pages/home.dart';
import 'package:presensi/src/widget/bezzier_container.dart';
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
  String _error;
  bool _isLoading = false;
  AppConfig config = new AppConfig();

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
      var response = await http
          .get("${config.apiURL}/api/user/get-profile", headers: requestHeaders);
      if (response.statusCode == 200) {
        jsonResponse = json.decode(response.body);

          setState(() {
            _isLoading = false;
            _error = null;
          });
          sharedPreferences.setInt("employee_id)", jsonResponse['id']);
          User user = new User(
            code: jsonResponse['employee_code'],
            name: jsonResponse['name'],
            position: jsonResponse['position'],
            status: jsonResponse['status'],
          );
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => Home(user: user)),
              (Route<dynamic> route) => false);
      
      } else {
        setState(() {
          _isLoading = false;
          _error = "Terjadi Kesalahan Sistem";
        });
        print(response.body);
      }
    }
  }

  // Sign in
  signIn(String email, password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    
    Map data = {
      'username': email,
      'password': password,
      'client_id': '2',
      'grant_type': 'password',
      'client_secret': '56kTBcFFZOwnFz9KSE72soNQOevnyIZR2DHz4HBZ'
    };

    var jsonResponse = null;

    var response =
        await http.post("${config.apiURL}/oauth/token", body: data);
        
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

      final response2 = await http.get(
          '${config.apiURL}/api/user/get-profile',
          headers: requestHeaders);
      final responseJson2 = json.decode(response2.body);
      sharedPreferences.setInt("employee_id", responseJson2['id']);
      print(sharedPreferences.getInt("employee_id").toString());
      User user = new User(
        code: responseJson2['employee_code'],
        name: responseJson2['name'],
        position: responseJson2['position'],
        status: responseJson2['status'],
      );

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => Home(user: user)),
          (Route<dynamic> route) => false);
    } else {
      setState(() {
        _isLoading = false;
        _error = jsonResponse["message"];
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
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              controller: emailController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              controller: passwordController,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
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
                signIn(emailController.text, passwordController.text);
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
            'Login',
            style: TextStyle(fontSize: 17),
            
          ),
        ),
      ),
    );
  }

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  // Widget _divider() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(vertical: 10),
  //     child: Row(
  //       children: <Widget>[
  //         SizedBox(
  //           width: 20,
  //         ),
  //         Expanded(
  //           child: Padding(
  //             padding: EdgeInsets.symmetric(horizontal: 10),
  //             child: Divider(
  //               thickness: 1,
  //             ),
  //           ),
  //         ),
  //         Text('or'),
  //         Expanded(
  //           child: Padding(
  //             padding: EdgeInsets.symmetric(horizontal: 10),
  //             child: Divider(
  //               thickness: 1,
  //             ),
  //           ),
  //         ),
  //         SizedBox(
  //           width: 20,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _facebookButton() {
  //   return Container(
  //     height: 50,
  //     margin: EdgeInsets.symmetric(vertical: 20),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.all(Radius.circular(10)),
  //     ),
  //     child: Row(
  //       children: <Widget>[
  //         Expanded(
  //           flex: 1,
  //           child: Container(
  //             decoration: BoxDecoration(
  //               color: Color(0xff1959a9),
  //               borderRadius: BorderRadius.only(
  //                   bottomLeft: Radius.circular(5),
  //                   topLeft: Radius.circular(5)),
  //             ),
  //             alignment: Alignment.center,
  //             child: Text('f',
  //                 style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 25,
  //                     fontWeight: FontWeight.w400)),
  //           ),
  //         ),
  //         Expanded(
  //           flex: 5,
  //           child: Container(
  //             decoration: BoxDecoration(
  //               color: Color(0xff2872ba),
  //               borderRadius: BorderRadius.only(
  //                   bottomRight: Radius.circular(5),
  //                   topRight: Radius.circular(5)),
  //             ),
  //             alignment: Alignment.center,
  //             child: Text('Log in with Facebook',
  //                 style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.w400)),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Dashboard()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Don\'t have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Register',
              style: TextStyle(
                  color: Color(0xFF29B6FC),
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
        text: 'Login',
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
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer()),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .20),
                  _title(),
                  SizedBox(height: height * .105),
                  showAlert(),
                  _emailPasswordWidget(),
                  SizedBox(height: 20),
                  _submitButton(),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.centerRight,
                    child: Text('Forgot Password ?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
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
