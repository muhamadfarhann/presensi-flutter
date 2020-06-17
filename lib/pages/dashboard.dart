import 'package:flutter/material.dart';
import 'package:presensi/models/user.dart';
import 'package:presensi/pages/card_menu.dart';
import 'package:presensi/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {

  final User user;

  const Dashboard({Key key, this.user}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    _pref();
    super.initState();
  }

  _pref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return this.sharedPreferences = sharedPreferences;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              sharedPreferences.clear();
              sharedPreferences.commit();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => LoginPage()),
                  (Route<dynamic> route) => false);
            },
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: Text('Welcome, ${this.widget.user.name}'),
          ),
          Center(
            child: Text('Email, ${this.widget.user.email}'),
          ),
          Center(
            child: Text('Posisi, ${this.widget.user.position}'),
          ),
          Center(
            child: Text('Status, ${this.widget.user.status}'),
          ),
          Center(
            child: Text('NIP: , ${this.widget.user.code}'),
          ),
          Center(
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CardMenu()));
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  'Lihat Absen',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(),
    );
  }
}
