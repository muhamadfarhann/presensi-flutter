import 'package:flutter/material.dart';
import 'package:presensi/models/user.dart';
import 'package:presensi/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard2 extends StatefulWidget {

  final User user;

  const Dashboard2({Key key, this.user}) : super(key: key);
  
  @override
  _Dashboard2State createState() => _Dashboard2State();
}

class _Dashboard2State extends State<Dashboard2> {

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
      body: ListView(
        children: <Widget>[
          _top(),
          SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Category",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
                ),
                Text(
                  "View All",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Container(
            height: 200.0,
            child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 3 / 2),
              children: <Widget>[
                gridItem(Icons.equalizer, "Riwayat Absensi"),
                gridItem(Icons.event, "A"),
                gridItem(Icons.add_shopping_cart, "B"),
                gridItem(Icons.bluetooth_searching, "C"),
                gridItem(Icons.add_location, "D"),
                gridItem(Icons.keyboard, "E")
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Text(
                  "Latest",
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          cardItem(1),
          cardItem(2),
          cardItem(3),
          cardItem(4),
        ],
      ),
    );
  }

  cardItem(image) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/farhan.jpg"),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(20.0)),
          ),
          SizedBox(
            width: 20.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Test",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
              ),
              SizedBox(height: 10.0),
              Text(
                "15 Items",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              Text(
                "By Muhamad Farhan",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _top() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF2979FF),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: AssetImage("images/farhan.jpg"),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    "Hi, ${this.widget.user.name}\nYou are ${this.widget.user.position}",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.exit_to_app),
                color: Colors.white,
                onPressed: () {
                  sharedPreferences.clear();
                  sharedPreferences.commit();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => LoginPage()),
                      (Route<dynamic> route) => false);
                },
              ),
            ],
          ),
          SizedBox(
            height: 30.0,
          ),
          TextField(
            decoration: InputDecoration(
                hintText: "Search anything to do",
                fillColor: Colors.white,
                filled: true,
                suffixIcon: Icon(Icons.filter_list),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: Colors.transparent)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0)),
          ),
        ],
      ),
    );
  }

  gridItem(icon, name) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          child: Icon(
            icon,
            size: 16.0,
            color: Colors.white,
          ),
          backgroundColor: Color(0xFF2979FF).withOpacity(0.9),
        ),
        SizedBox(
          height: 10.0,
        ),
        Text(
          name,
          style: TextStyle(),
        ),
      ],
    );
  }
}
