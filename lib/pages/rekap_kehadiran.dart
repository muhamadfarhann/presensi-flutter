import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:presensi/configs/app_config.dart';
import 'package:presensi/models/recap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

class RekapKehadiran extends StatefulWidget {
  @override
  _RekapKehadiranState createState() => _RekapKehadiranState();
}

class _RekapKehadiranState extends State<RekapKehadiran> {
  DateTime periode = DateTime.now();
  AppConfig config = new AppConfig();
  String firstDate = "";
  String lastDate = "";
  dynamic recap = new List<String>();
  int hasData = 0;

  @override
  void initState() {
    super.initState(); //PANGGIL FUNGSI YANG TELAH DIBUAT SEBELUMNYA
  }

  Future<Null> refresh() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    double widthC = MediaQuery.of(context).size.width * 100;
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: RefreshIndicator(
            onRefresh: refresh,
            color: Colors.grey[200],
            child: Column(
              // mainAxisSize: MainAxisSize.max,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _top(),
                SizedBox(
                  height: 20,
                ),
                _periode(),
                _buildInfoCard(context),
                SizedBox(
                  height: 10,
                ),
                _buildInfo(context, widthC),
              ],
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   child: Icon(Icons.picture_as_pdf),
          //   onPressed: () => {},
          //   foregroundColor: Colors.white,
          //   backgroundColor: Color(0xFF2979FF),
          // ),
        ));
  }

  _top() {
    return Container(
      padding: EdgeInsets.only(top: 35, bottom: 10),
      decoration: BoxDecoration(
        color: Color(0xFF2979FF),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0)),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 80),
            child: Text(
              'Rekap Kehadiran',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: IconButton(
                icon: Icon(Icons.date_range),
                iconSize: 25,
                color: Colors.white,
                // onPressed: () => _selectDate(context),
                onPressed: () => _selectDate(context)),
          ),
        ],
      ),
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final List<DateTime> picked = await DateRangePicker.showDatePicker(
        context: context,
        initialFirstDate: (new DateTime.now()).add(new Duration(days: -7)),
        initialLastDate: new DateTime.now(),
        firstDate: new DateTime(2015),
        lastDate: new DateTime(2021));

    if (picked != null && picked != periode) {
      setState(() {
        var formatter = new DateFormat('dd-MM-yyyy');
        firstDate = formatter.format(picked[0]).toLowerCase();
        lastDate = formatter.format(picked[1]).toLowerCase();
        this.getData(firstDate, lastDate);
      });
    }
  }

  Widget _periode() {
    return Container(
      padding: EdgeInsets.only(
                          top: 5, bottom: 5, left: 15, right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.blue[100],
        boxShadow: [
          BoxShadow(
            color: Colors.blue[100],
            spreadRadius: 3,
          ),
        ],
      ),
      child: Text(
        "Periode : ${firstDate} s/d ${lastDate}",
        style: TextStyle(
            color: Colors.blue,
            fontFamily: 'Nunito',
            fontSize: 15,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 15, left: 10, right: 10),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(
                  top: 16.0, bottom: 16.0, right: 10.0, left: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        'NIK',
                        style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nunito'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: hasData == 1
                            ? Text(
                                recap['code'],
                                style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w300),
                              )
                            : Text(""),

                        // child: FutureBuilder<User>(
                        //   future: user,
                        //   builder: (context, snapshot) {
                        //     if (snapshot.hasData) {
                        //       return Text(snapshot.data.timeIn);
                        //     } else if (snapshot.hasError) {
                        //       return Text("${snapshot.error}");
                        //     }
                        //     return CircularProgressIndicator();
                        //   },
                        // ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        'Nama',
                        style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nunito'),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 6.0),
                        child: hasData == 1
                            ? Text(
                                recap['name'],
                                style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w300),
                              )
                            : Text(""),
                        //   child: FutureBuilder<Recap>(
                        //     future: recap,
                        //     builder: (context, snapshot) {
                        //       print(recap);
                        //       if (snapshot.hasData) {
                        //         return Text(snapshot.data.name);
                        //       } else if (snapshot.hasError) {
                        //         return Text("tes");
                        //       } else {
                        //         return Text("");
                        //       }
                        //       return CircularProgressIndicator();
                        //     },
                        //   ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context, double width) {
    final height = MediaQuery.of(context).size.height * 0.6;
    return Container(
      height: height,
      padding: EdgeInsets.all(10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        color: Colors.white,
        child: Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.all(15),
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.email, color: Color(0xFF2979FF)),
                title: Text(
                  "Total Kehadiran",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Nunito'),
                ),
                subtitle: hasData == 1
                    ? Text(
                        "${recap['present']} Hari",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            fontFamily: 'Nunito'),
                      )
                    : Text("Pilih Periode"),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.phone, color: Color(0xFF2979FF)),
                title: Text(
                  "Total Terlambat",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Nunito'),
                ),
                subtitle: hasData == 1
                    ? Text(
                        "${recap['overdue']} Hari",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            fontFamily: 'Nunito'),
                      )
                    : Text("Pilih Periode"),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.home, color: Color(0xFF2979FF)),
                title: Text(
                  "Total Alpha",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Nunito'),
                ),
                subtitle: hasData == 1
                    ? Text(
                        "${recap['alpha']} Hari",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            fontFamily: 'Nunito'),
                      )
                    : Text("Pilih Periode"),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.home, color: Color(0xFF2979FF)),
                title: Text(
                  "Total Sakit",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Nunito'),
                ),
                subtitle: hasData == 1
                    ? Text(
                        "${recap['sick']} Hari",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            fontFamily: 'Nunito'),
                      )
                    : Text("Pilih Periode"),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.home, color: Color(0xFF2979FF)),
                title: Text("Total Izin",
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Nunito')),
                subtitle: hasData == 1
                    ? Text(
                        "${recap['permit']} Hari",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            fontFamily: 'Nunito'),
                      )
                    : Text("Pilih Periode"),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.home, color: Color(0xFF2979FF)),
                title: Text("Total Cuti",
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Nunito')),
                subtitle: hasData == 1
                    ? Text(
                        "${recap['furlough']} Hari",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            fontFamily: 'Nunito'),
                      )
                    : Text("Pilih Periode"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> getData(String fd, String ld) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String id = sharedPreferences.getInt("employee_id").toString();

    Map data = {
      "employee_id": id,
      "first_date": fd,
      "last_date": ld,
    };
    var response =
        await http.post("${config.apiURL}/api/attendance/recap", body: data);

    setState(() {
      //RESPONSE YANG DIDAPATKAN DARI API TERSEBUT DI DECODE
      var content = json.decode(response.body);
      // print(content['data']);
      //KEMUDIAN DATANYA DISIMPAN KE DALAM VARIABLE data,
      //DIMANA SECARA SPESIFIK YANG INGIN KITA AMBIL ADALAH ISI DARI KEY hasil
      recap = content['data'];
      hasData = 1;
      print(recap['code']);
    });
    return 'success!';
  }
}
