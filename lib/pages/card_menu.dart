import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:presensi/configs/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

class CardMenu extends StatefulWidget {
  @override
  _CardMenuState createState() => _CardMenuState();
}

class _CardMenuState extends State<CardMenu> {
  List attendance;
  DateTime periode = DateTime.now();
  AppConfig config = new AppConfig();
  String firstDate = "";
  String lastDate = "";

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
        var formatter = new DateFormat('dd-MM-yyyy');
        firstDate = formatter.format(picked[0]).toLowerCase();
        lastDate = formatter.format(picked[1]).toLowerCase();
        this.getData(firstDate, lastDate);
      });
    }
  }

  Future<String> getData(String fd, String ld) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String id = sharedPreferences.getInt("employee_id").toString();

    Map data = {
      "employee_id": id,
      "first_date": fd,
      "last_date": ld,
    };

    var res =
        await http.post("${config.apiURL}/api/attendance/periode", body: data);

    setState(() {
      //RESPONSE YANG DIDAPATKAN DARI API TERSEBUT DI DECODE
      var content = json.decode(res.body);
      //KEMUDIAN DATANYA DISIMPAN KE DALAM VARIABLE data,
      //DIMANA SECARA SPESIFIK YANG INGIN KITA AMBIL ADALAH ISI DARI KEY hasil
      attendance = content['data'];
    });
    return 'success!';
  }

  @override
  void initState() {
    super.initState(); //PANGGIL FUNGSI YANG TELAH DIBUAT SEBELUMNYA
  }

  Future<Null> refresh() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    print(attendance);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding:
                        EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
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
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: attendance == null ? 0 : attendance.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        // Change container padding
                        padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                        //
                        height: 150,
                        width: double.maxFinite,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: attendance[index]['overdue'] == 1
                              ? Colors.redAccent
                              : Color(0xFF2979FF),
                          elevation: 0,
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.all(7),
                              child: Stack(children: <Widget>[
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Stack(
                                    children: <Widget>[
                                      Padding(
                                          padding:
                                              EdgeInsets.only(left: 10, top: 5),
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  //icon kalender
                                                  // attendanceIcon(
                                                  //     attendance[index]),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  //Hari dan Tanggal
                                                  attendanceDate(
                                                      attendance[index]
                                                          ['date']),
                                                  Spacer(),
                                                  attendanceStatus(
                                                      attendance[index]
                                                          ['overdue']),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  SizedBox(
                                                    width: 20,
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  attendanceTime(
                                                      attendance[index]
                                                          ['time_in'],
                                                      attendance[index]
                                                          ['time_out'])
                                                ],
                                              )
                                            ],
                                          ))
                                    ],
                                  ),
                                )
                              ]),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.picture_as_pdf),
      //   onPressed: () => {},
      //   foregroundColor: Colors.white,
      //   backgroundColor: Color(0xFF2979FF),
      // ),
    );
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
            margin: EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              'Riwayat Kehadiran',
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

  Widget attendanceIcon(data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(
            Icons.date_range,
            color: Colors.amber,
            size: 40,
          )),
    );
  }

  getDay(d) {
    switch (d) {
      case 1:
        return "Senin";
        break;
      case 2:
        return "Selasa";
        break;
      case 3:
        return "Rabu";
        break;
      case 4:
        return "Kamis";
        break;
      case 5:
        return "Jumat";
        break;
      case 6:
        return "Sabtu";
        break;
      default:
        return "Minggu";
    }
  }

  Widget attendanceDate(date) {
    DateTime todayDate = DateTime.parse(date);
    var formatter = new DateFormat('dd-MMM-yyyy');
    String thisDate = formatter.format(todayDate);

    var day = getDay(todayDate.weekday);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 10.0),
        child: RichText(
          text: TextSpan(
            text: day.toString(),
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 17,
                fontFamily: 'Nunito'),
            children: <TextSpan>[
              TextSpan(
                  text: '\n${thisDate}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Nunito')),
            ],
          ),
        ),
      ),
    );
  }

  Widget attendanceStatus(data) {
    String status = (data == 1) ? "Terlambat" : "Tepat Waktu";
    // MaterialColor status_color = (data == 1) ? Colors.red : Colors.green;
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Align(
        alignment: Alignment.topRight,
        child: RichText(
          text: TextSpan(
            text: status,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget attendanceTime(time_in, time_out) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 10.0),
        child: Row(
          children: <Widget>[
            RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                text: '\n\Jam Masuk : ${time_in}',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Nunito'),
                children: <TextSpan>[
                  TextSpan(
                      text: '\nJam Keluar : ${time_out}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Nunito')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
