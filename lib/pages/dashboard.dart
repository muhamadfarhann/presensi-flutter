import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:presensi/configs/app_config.dart';
import 'package:presensi/models/attendance.dart';
import 'package:presensi/models/user.dart';
import 'package:presensi/pages/card_menu.dart';
import 'package:presensi/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  final User user;

  const Dashboard({Key key, this.user}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  SharedPreferences sharedPreferences;
  Attendance attendance = null;
  String result = "Test";
  String messageLocation = "";
  String deviceId = "";
  String typeValue;
  AppConfig config = new AppConfig();
  List types = ["Izin", "Sakit", "Cuti"];

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
                  mainAxisSpacing: 30.0,
                  crossAxisCount: 3,
                  childAspectRatio: 3 / 2),
              children: <Widget>[
                gridItem(AntDesign.calendar, "Riwayat Absensi", 1),
                gridItem(AntDesign.scan1, "Scan Absen", 2),
                gridItem(AntDesign.solution1, "Lapor Absen", 3),
                gridItem(Icons.bluetooth_searching, "C", 4),
                gridItem(Icons.add_location, "D", 5),
                gridItem(Icons.keyboard, "E", 6)
              ],
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.all(16.0),
          //   child: Row(
          //     children: <Widget>[
          //       Text(
          //         "Latest",
          //         style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          //       )
          //     ],
          //   ),
          // ),
          // cardItem(1),
          // cardItem(2),
          // cardItem(3),
          // cardItem(4),
        ],
      ),
    );
  }

  TextEditingController _textFieldController = TextEditingController();

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Lapor Ketidakhadiran'),
            content: Column(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _textFieldController,
                        decoration: InputDecoration(hintText: "Keterangan"),
                      ),
                      DropdownButton(
                        hint: Text("- Pilih Keterangan -"),
                        value: typeValue,
                        items: types.map((value) {
                          return DropdownMenuItem(
                            child: new Text(value),
                            value: value,
                          );
                        }).toList(), 
                        onChanged: (value) {
                          setState(() {
                            typeValue = value;
                          });
                        }
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Submit'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
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
                      // backgroundImage: AssetImage("images/farhan.jpg"),
                      backgroundImage: NetworkImage(
                          "${config.apiURL}/images/${this.widget.user.photo}")),
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CardMenu()));
                break;
              case 2:
                _scanQR().then((value) {});
                break;
              case 3:
                _displayDialog(context);
                break;
              default:
            }
          },
          child: CircleAvatar(
            child: Icon(
              icon,
              size: 26.0,
              color: Color(0xFF2979FF),
            ),
            radius: 26.0,
            backgroundColor: Colors.white,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Text(name),
      ],
    );
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

  // Method untuk memulai scan qr
  Future<Attendance> _scanQR() async {
    try {
      var now = new DateTime.now();
      var newDt = DateFormat.Hms().format(now);
      var formatter = new DateFormat('yyyy-MM-dd');
      String myDate = formatter.format(now);

      String qrResult = await BarcodeScanner.scan();
      // print(qrResult);
      print("Hasil QR: ${qrResult}");

      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      final androidDeviceId = androidDeviceInfo.androidId;
      print("Dev ID: ${androidDeviceId}");
      print("Hasil Flutter: ${myDate}");
      // Geolocator
      if (qrResult == myDate) {
        final position = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

        Map data = {
          "employee_id": sharedPreferences.getInt("employee_id").toString(),
          "date": myDate.toString(),
          "time_in": newDt.toString(),
          "time_out": newDt.toString(),
          "overdue": "",
          "note": "",
          "latitude_in": "${position.latitude}",
          "longitude_in": "${position.longitude}",
          "latitude_out": "${position.latitude}",
          "longitude_out": "${position.longitude}",
          "device_id": androidDeviceId,
        };

        var jsonResponse = null;
        AppConfig config = new AppConfig();
        var response = await http.post("${config.apiURL}/api/attendance/store",
            body: data);

        print(response.statusCode);

        if (response.statusCode == 200) {
          jsonResponse = json.decode(response.body);

          if (jsonResponse['statusCode'] == 403) {
            showAlertDialog('Failed', jsonResponse['message'], DialogType.ERROR,
                context, () {});
          } else {
            showAlertDialog('Success', jsonResponse['message'],
                DialogType.SUCCES, context, () {});
          }
        }
      } else {
        var message =
            "Tidak Dapat Melakukan Kehadiran, Pastikan QR Code Sesuai";
        showAlertDialog('Failed', message, DialogType.ERROR, context, () {});
      }
      setState(() {
        // attendance = value;
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        result = "Perizinan kamera ditolak";
      } else {
        setState(() {
          result = "Error ! $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "Anda menekan tombol kembali sebelum memindai QR";
        attendance = null;
      });
    } catch (ex) {
      setState(() {
        result = "Error ! $ex";
      });
    }
  }
}
