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
import 'package:presensi/pages/absent_form.dart';
import 'package:presensi/pages/card_menu.dart';
import 'package:presensi/pages/login_page.dart';
import 'package:presensi/pages/multi_todo_form.dart';
import 'package:presensi/pages/profile.dart';
import 'package:presensi/pages/rekap_kehadiran.dart';
import 'package:presensi/pages/report_absent.dart';
import 'package:presensi/pages/riwayat_todo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DateTime periode = DateTime.now();
  SharedPreferences sharedPreferences;
  Attendance attendance = null;
  String result = "Test";
  String messageLocation = "";
  String firstDate;
  String lastDate;
  String deviceId = "";
  String typeValue;
  List<DateTime> datePicked;
  AppConfig config = new AppConfig();
  List types = ["Izin", "Sakit", "Cuti"];
  TextEditingController noteController = TextEditingController();
  Future<User> user;

  int currentTab = 0;
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen;

  final List<Widget> screens = [
    Dashboard(),
    Profile(),
  ];

  @override
  void initState() {
    super.initState();
    user = getUser();
    _pref();
  }

  _pref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return this.sharedPreferences = sharedPreferences;
  }

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
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.grey[200],
      body: PageStorage(
        child: currentScreen == null ? _body() : currentScreen,
        bucket: bucket,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(AntDesign.scan1),
        backgroundColor: Color(0xFF2979FF),
        onPressed: () {
          _scanQR().then((value) {});
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = _body();
                        currentTab = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          AntDesign.home,
                          color: currentTab == 0 ? Colors.blue : Colors.grey,
                        ),
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            color: currentTab == 0 ? Colors.blue : Colors.grey,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Right Tab bar icons
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen =
                            Profile(); // if user taps on this dashboard tab will be active
                        currentTab = 3;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          AntDesign.user,
                          color: currentTab == 3 ? Colors.blue : Colors.grey,
                        ),
                        Text(
                          'Profil',
                          style: TextStyle(
                            color: currentTab == 3 ? Colors.blue : Colors.grey,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _body() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: <Widget>[
          _top(),
          SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Menu",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                      fontFamily: 'Nunito'),
                ),
              ],
            ),
          ),
          Container(
            height: 350.0,
            child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 30.0,
                  crossAxisCount: 3,
                  childAspectRatio: 3 / 2),
              children: <Widget>[
                gridItem(AntDesign.filetext1, "Todo", 1),
                gridItem(AntDesign.solution1, "Lapor Absensi", 2),
                gridItem(AntDesign.laptop, "Riwayat Todo", 3),
                gridItem(AntDesign.calendar, "Riwayat Presensi", 4),
                gridItem(AntDesign.dotchart, "Riwayat Absensi", 5),
                gridItem(AntDesign.linechart, "Rekap Kehadiran", 6),
                // gridItem(AntDesign.carryout, "Tutup Buku", 7),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method memilih tanggal
  Future<Null> _selectDate(BuildContext context) async {
    final List<DateTime> picked = await DateRangePicker.showDatePicker(
        context: context,
        initialFirstDate: (new DateTime.now()).add(new Duration(days: -7)),
        initialLastDate: new DateTime.now(),
        firstDate: new DateTime(2015),
        lastDate: new DateTime(2021));

    if (picked != null && picked != periode) {
      setState(() {
        datePicked = picked;
      });
    }
  }

  // cardItem(image) {
  //   return Padding(
  //     padding: EdgeInsets.all(16.0),
  //     child: Row(
  //       children: <Widget>[
  //         Container(
  //           width: 100.0,
  //           height: 100.0,
  //           decoration: BoxDecoration(
  //               image: DecorationImage(
  //                 image: AssetImage("images/farhan.jpg"),
  //                 fit: BoxFit.cover,
  //               ),
  //               borderRadius: BorderRadius.circular(20.0)),
  //         ),
  //         SizedBox(
  //           width: 20.0,
  //         ),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             Text(
  //               "Test",
  //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
  //             ),
  //             SizedBox(height: 10.0),
  //             Text(
  //               "15 Items",
  //               style:
  //                   TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
  //             ),
  //             SizedBox(height: 10.0),
  //             Text(
  //               "By Muhamad Farhan",
  //               style:
  //                   TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  _top() {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 40, 15, 30),
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
              Container(
                  child: FutureBuilder<User>(
                      future: user,
                      builder: (context, snapshot) {
                        List<Widget> children;
                        if (snapshot.hasData) {
                          children = <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                              },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    "${config.apiURL}/images/${snapshot.data.photo}"),
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              "Hi, ${snapshot.data.name}\nYou are ${snapshot.data.position}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Nunito'
                              ),
                            ),
                          ];

                          return Center(
                              child: Row(
                            children: children,
                          ));
                        }
                        return CircularProgressIndicator();
                      })),
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
            height: 20.0,
          ),
          TextField(
            style: TextStyle(
              fontFamily: "Nunito",
              fontSize: 15,
            ),
            decoration: InputDecoration(
                hintText: "Cari...",
                fillColor: Colors.white,
                filled: true,
                suffixIcon: Icon(Icons.filter_list),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
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
                    MaterialPageRoute(builder: (context) => MultiTodoForm()));
                break;

              case 2:
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AbsentForm()));
                break;

              case 3:
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RiwayatTodo()));
                break;

              case 4:
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CardMenu()));
                break;

              case 5:
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ReportAbsent()));
                break;

              case 6:
                 Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RekapKehadiran()));
                break;

              case 7:

                break;
              default:
            }
          },
          child: CircleAvatar(
            child: Icon(
              icon,
              size: 23.0,
              color: Color(0xFF2979FF),
            ),
            radius: 24.0,
            backgroundColor: Colors.white,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Text(
          name,
          style: TextStyle(fontFamily: 'Nunito', fontSize: 13),
        ),
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
      var day = DateFormat('EEEE').format(now);

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

       if(day == "Saturday" || day == "Sunday") { 
           var message =
                "Tidak Dapat Melakukan Kehadiran Pada Hari Sabtu dan Minggu";
            showAlertDialog('Failed', message, DialogType.ERROR, context, () {});
       } else {
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
