import 'package:flutter/material.dart';
import 'package:presensi/models/user.dart';

class Profile extends StatelessWidget {
  final User user;

  const Profile({Key key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double widthC = MediaQuery.of(context).size.width * 100;
    return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              //==========================================================================================
              // build Top Section of Profile (include : Image & main info & card of info[photos ... ] )
              //==========================================================================================
              _buildHeader(context, widthC),

              SizedBox(height: 10.0),

              //==========================================================================================
              //  build Bottom Section of Profile (include : email - phone number - about - location )
              //==========================================================================================
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
          child: Column(
            children: <Widget>[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                color: Color(0xFF2979FF),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.white,
                      width: 6.0,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                  ),
                ),
              ),
              _buildMainInfo(context, width)
            ],
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
                  new Column(
                    children: <Widget>[
                      new Text(
                        'Jam Masuk',
                        style: new TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: new Text(
                          '3.5k',
                          style: new TextStyle(
                              fontSize: 15.0, color: Color(0xFF2979FF)),
                        ),
                      ),
                    ],
                  ),
                  new Column(
                    children: <Widget>[
                      new Text(
                        'Jam Keluar',
                        style:
                            new TextStyle(fontSize: 15.0, color: Colors.black),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: new Text(
                          '150',
                          style: new TextStyle(
                              fontSize: 15.0, color: Color(0xFF2979FF)),
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
      child: Column(
        children: <Widget>[
          Text('${this.user.name}',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('${this.user.status} - ${this.user.position}',
              style: TextStyle(
                  color: Colors.grey.shade50, fontStyle: FontStyle.italic))
        ],
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
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.email, color: Color(0xFF2979FF)),
                      title: Text("Email",
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                      subtitle: Text("${this.user.email}",
                          style:
                              TextStyle(fontSize: 15, color: Colors.black54)),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.phone, color: Color(0xFF2979FF)),
                      title: Text("Telepon",
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                      subtitle: Text("087722250220",
                          style:
                              TextStyle(fontSize: 15, color: Colors.black54)),
                    ),
                    Divider(),
                    ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: Icon(Icons.home, color: Color(0xFF2979FF)),
                      title: Text("Alamat",
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                      subtitle: Text("Jl. Babakan Ciamis",
                          style:
                              TextStyle(fontSize: 15, color: Colors.black54)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
