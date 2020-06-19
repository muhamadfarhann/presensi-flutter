import 'package:barcode_scan/barcode_scan.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:presensi/models/attendance.dart';
import 'package:presensi/models/user.dart';
import 'package:presensi/pages/card_menu.dart';
import 'package:presensi/pages/login_page.dart';
import 'package:presensi/pages/scan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  final User user;

  const Dashboard({Key key, this.user}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  SharedPreferences sharedPreferences;

// Membuat Field PostResult dengan value null
  Attendance attendance = null;
  
  String result = "";

  // Location
  String messageLocation = "";
  // end location

  // Device ID
  String deviceId = "";
  // End Device ID

  // Method untuk memulai scan qr
  _scanQR() async {
    try {
        var now = new DateTime.now();
        var newDt = DateFormat.Hms().format(now);
        print(now);
        String qrResult = await BarcodeScanner.scan();
        
        // Geolocator
        final position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
       // print(position);
        //end of geolocator

        final value = await Attendance.connectToAPI(
          "1", 
          now.toString(),
          newDt.toString(), 
          "",
          "",
          "",
          "${position.latitude}",
          "${position.longitude}",
          "",
          "",
        );
        
        // device id
        DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
        AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;

        final androidDeviceId = androidDeviceInfo.androidId;
        print(androidDeviceId);
        // end of device id

        // mengubah variabel result menjadi hasil scan
        setState((){
          SnackBar(
          content: Text('Success'),
          action: SnackBarAction(label: 'Berhasil', onPressed: (){} ),
          );
        });

    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
          result = "Perizinan kamera ditolak";        
      }  else {
        setState(() {
          result = "Error ! $ex";
        });
      } 
    } on FormatException {
      setState(() {
        result = "Anda menekan tombol kembali sebelum memindai QR";
      });
    } catch (ex) {
      setState(() {
        result = "Error ! $ex";
      });
    }
    
  }
  
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
                gridItem(Icons.equalizer, "Riwayat Absensi", 1),
                gridItem(Icons.event, "A", 2),
                gridItem(Icons.add_shopping_cart, "B", 3),
                gridItem(Icons.bluetooth_searching, "C", 4),
                gridItem(Icons.add_location, "D", 5),
                gridItem(Icons.keyboard, "E", 6)
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

  gridItem(icon, name, number) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            switch (number) {
              case 1:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CardMenu()));    
                break;
              case 2:
                  _scanQR();
                break;
              default:
            }
          },
          child: CircleAvatar(
            child: Icon(
              icon,
              size: 16.0,
              color: Colors.white,
            ),
            backgroundColor: Color(0xFF2979FF).withOpacity(0.9),
          ),
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
