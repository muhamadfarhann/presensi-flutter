import 'package:flutter/material.dart';
import 'package:presensi/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presensi/configs/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Profile extends StatefulWidget {
  // final User user;

  // const Profile({Key key, this.user}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Future<User> user;
  @override
  void initState() {
    super.initState();
    user = getUser();
  }

  AppConfig config = new AppConfig();

  Future<User> getUser() async {
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

        sharedPreferences.setInt(
            "employee_id)", jsonResponse['employee']['id']);

        print(jsonResponse['employee']['attendance']);

        String timeIn = 'Belum Absen';
        String timeOut = 'Belum Absen';

        if (jsonResponse['employee']['attendance'] != null) {
          timeIn = jsonResponse['employee']['attendance']['time_in'].toString();
          timeOut = jsonResponse['employee']['attendance']['time_out'] != null
              ? jsonResponse['employee']['attendance']['time_out'].toString()
              : "Belum Absen";
        }

        User user = new User(
          code: jsonResponse['employee']['employee_code'],
          name: jsonResponse['employee']['name'],
          position: jsonResponse['employee']['position'],
          status: jsonResponse['employee']['status'],
          email: jsonResponse['email'],
          phone: jsonResponse['employee']['phone'],
          address: jsonResponse['employee']['address'],
          photo: jsonResponse['employee']['photo'],
          timeIn: timeIn,
          timeOut: timeOut,
        );

        return user;
      } else {
        throw Exception('Failed to load Data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double widthC = MediaQuery.of(context).size.width * 100;
    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildHeader(context, widthC),
              SizedBox(height: 10.0),
              _buildInfo(context, widthC),
            ],
          ),
        ));
  }

  Widget _buildHeader(BuildContext context, double width) {
    return Stack(
      children: <Widget>[
        Ink(
          height: 250,
          color: Color(0xFF2979FF),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 50),
          child: FutureBuilder<User>(
            future: user,
             builder: (context, snapshot) {
                List<Widget> children;
                if (snapshot.hasData) {
                  children = <Widget>[
                      CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 54,
                            backgroundImage: NetworkImage("${config.apiURL}/images/${snapshot.data.photo}")
                          ),
                        ),
                        _buildMainInfo(context, width)
                  ];
                  return Center(child: Column(
                    children: children, 
                    
                  ));
                }
                return CircularProgressIndicator();
             }
          ),
        ),
        Container(
            margin: const EdgeInsets.only(top: 210),
            child: _buildInfoCard(context))
      ],
    );
  }

  Widget _buildInfoCard(context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Card(
            elevation: 5.0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 16.0, bottom: 16.0, right: 10.0, left: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        'Jam Masuk',
                        style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: FutureBuilder<User>(
                          future: user,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(snapshot.data.timeIn);
                            } else if (snapshot.hasError) {
                              return Text("${snapshot.error}");
                            }
                            return CircularProgressIndicator();
                          },
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        'Jam Keluar',
                        style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: FutureBuilder<User>(
                          future: user,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(snapshot.data.timeOut);
                            } else if (snapshot.hasError) {
                              return Text("${snapshot.error}");
                            }
                            return CircularProgressIndicator();
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainInfo(BuildContext context, double width) {
    return Container(
      width: width,
      margin: const EdgeInsets.all(10),
      alignment: AlignmentDirectional.center,
      child: FutureBuilder<User>(
        future: user,
        builder: (context, snapshot) {
           List<Widget> children;
              if (snapshot.hasData) {
                children = <Widget>[
                  Text(snapshot.data.name,
                    style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('${snapshot.data.status} - ${snapshot.data.position}',
                        style: TextStyle(
                        color: Colors.grey.shade50, fontStyle: FontStyle.italic))
                  ];
                return Center(
                  child: Column(
                    children: children)
                );
              }
            return CircularProgressIndicator();
        }
      ),
    );
  }

  Widget _buildInfo(BuildContext context, double width) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Card(
        color: Colors.white,
        child: Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.all(15),
          child: FutureBuilder<User>(
            future: user,
            builder: (context, snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                children = <Widget>[
                  ListTile(
                    leading: Icon(Icons.email, color: Color(0xFF2979FF)),
                    title: Text("Email",
                        style: TextStyle(fontSize: 18, color: Colors.black)),
                    subtitle: Text(snapshot.data.email,
                        style: TextStyle(fontSize: 15, color: Colors.black54)),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.phone, color: Color(0xFF2979FF)),
                    title: Text("Telepon",
                        style: TextStyle(fontSize: 18, color: Colors.black)),
                    subtitle: Text(snapshot.data.phone,
                        style: TextStyle(fontSize: 15, color: Colors.black54)),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.home, color: Color(0xFF2979FF)),
                    title: Text("Alamat",
                        style: TextStyle(fontSize: 18, color: Colors.black)),
                    subtitle: Text(snapshot.data.address,
                        style: TextStyle(fontSize: 15, color: Colors.black54)),
                  ),
                ];
                return Center(child: Column(children: children));
              }
              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
