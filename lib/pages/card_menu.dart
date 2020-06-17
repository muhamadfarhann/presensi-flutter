import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:presensi/configs/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardMenu extends StatefulWidget {
  @override
  _CardMenuState createState() => _CardMenuState();
}

class _CardMenuState extends State<CardMenu> {

  List attendance;
  
  AppConfig config = new AppConfig();
  
  Future<String> getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String id = sharedPreferences.getInt("employee_id").toString();
    print("ID ANda ${id}");
    final String url = '${config.apiURL}/api/attendance';
    // MEMINTA DATA KE SERVER DENGAN KETENTUAN YANG DI ACCEPT ADALAH JSON
    // var res = await http
    //       .post(url, body: {
    //         'id': id
    //       });
    var res = await http
        .get(Uri.encodeFull(url), headers: {'accept': 'application/json'});

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
    super.initState();
    this.getData(); //PANGGIL FUNGSI YANG TELAH DIBUAT SEBELUMNYA
  }

  @override
  Widget build(BuildContext context) {
    print(attendance);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(title: Text('Data Absensi')),
            body: Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                        itemCount: attendance == null ? 0 : attendance.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            height: 150,
                            width: double.maxFinite,
                            child: Card(
                              elevation: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                        width: 2.0, color: Colors.blue),
                                  ),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(7),
                                  child: Stack(children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Stack(
                                        children: <Widget>[
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10, top: 5),
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      //icon kalender
                                                      attendanceIcon(
                                                          attendance[index]),
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
            )));
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
    var day = getDay(todayDate.weekday);
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: day.toString(),
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
          children: <TextSpan>[
            TextSpan(
                text: '\n${date}',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget attendanceStatus(data) {
    String status = (data == 1) ? "Terlambat" : "Tepat Waktu";
    MaterialColor status_color = (data == 1) ? Colors.red : Colors.green;
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Align(
        alignment: Alignment.topRight,
        child: RichText(
          text: TextSpan(
            text: status,
            style: TextStyle(color: status_color, fontSize: 14),
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
                  color: Colors.grey,
                  fontSize: 16,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: '\nJam Keluar : ${time_out}',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
