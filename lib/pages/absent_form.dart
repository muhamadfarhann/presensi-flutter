import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:presensi/configs/app_config.dart';
import 'package:presensi/pages/dashboard.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class AbsentForm extends StatefulWidget {
  @override
  _AbsentFormState createState() => _AbsentFormState();
}

class _AbsentFormState extends State<AbsentForm> {
  // Instansiasi API URL
  AppConfig config = new AppConfig();

  // Session
  SharedPreferences sharedPreferences;

  // Variabel untuk periode
  DateTime periode = DateTime.now();
  String firstDate = "";
  String lastDate = "";

  // Variabel untuk absen / tidak hadir
  String typeValue;
  List types = ["Izin", "Sakit", "Cuti"];
  TextEditingController noteController = TextEditingController();

  ProgressDialog progressDialog;

  // Upload File
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  bool _hasValidMime = false;
  FileType _pickingType;
  TextEditingController _controller = new TextEditingController();

  // Method untuk mengupload dan membuka file explorer
  void _openFileExplorer() async {
    if (_pickingType != FileType.any || _hasValidMime) {
      setState(() => _loadingPath = true);
      try {
        if (_multiPick) {
          _path = null;
          var multiFilePath = FilePicker.getMultiFilePath();
          _paths = await multiFilePath;
        } else {
          _paths = null;
          _path = await FilePicker.getFilePath();
        }
      } on PlatformException catch (e) {
        print("Tidak mendukung" + e.toString());
      }
      if (!mounted) return;
      setState(() {
        _loadingPath = false;
        _fileName = _path != null
            ? _path.split('/').last
            : _paths != null ? _paths.keys.toString() : '...';
      });
    }
  }

  @override
  void initState() {
    _pref();
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
  }

  _pref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return this.sharedPreferences = sharedPreferences;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
          color: Colors.grey[200],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _top(),
              _body(),
            ],
          ),
        ),
      ),
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
              'Lapor Ketidakhadiran',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: IconButton(
                icon: Icon(Icons.date_range),
                iconSize: 30,
                color: Colors.white,
                // onPressed: () => _selectDate(context),
                onPressed: () {}),
          ),
        ],
      ),
    );
  }

  _body() {
    progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    return Container(
        padding: EdgeInsets.only(top: 35, bottom: 10),
        margin: EdgeInsets.only(top: 20, left: 10, right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20, top: 0),
            child: Text(
              "Pilih Lama Izin :",
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(left: 9),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(AntDesign.calendar),
                    onPressed: () {
                      _selectDate(context);
                    },
                  ),
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
                      "${firstDate} s/d ${lastDate}",
                      style: TextStyle(
                          color: Colors.blue,
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              "Keterangan :",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Nunito'),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: DropdownButton(
              hint: Text(
                "- Pilih Keterangan -",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Nunito',
                ),
              ),
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
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              "Catatan :",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: TextField(
              controller: noteController,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Nunito'),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Text('Upload File :'),
          ),
          FlatButton(
            onPressed: () {
              _openFileExplorer();
            },
            child: Container(
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
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
                "Browse...",
                style: TextStyle(
                    color: Colors.blue,
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Builder(
            builder: (BuildContext context) => _loadingPath
                ? Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: CircularProgressIndicator())
                : _path != null || _paths != null
                    ? Container(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        height: MediaQuery.of(context).size.height * 0.20,
                        child: Scrollbar(
                            child: ListView.separated(
                          itemCount: _paths != null && _paths.isNotEmpty
                              ? _paths.length
                              : 1,
                          itemBuilder: (BuildContext context, int index) {
                            final bool isMultiPath =
                                _paths != null && _paths.isNotEmpty;
                            final String name = 'File $index: ' +
                                (isMultiPath
                                    ? _paths.keys.toList()[index]
                                    : _fileName ?? '...');
                            final path = isMultiPath
                                ? _paths.values.toList()[index].toString()
                                : _path;

                            return ListTile(
                              title: Text(
                                name,
                              ),
                              subtitle: Text(path),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(),
                        )),
                      )
                    : Container(),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: FlatButton(
              onPressed: () {
                if (firstDate == '' || lastDate == '' || typeValue == '') {
                  showAlertDialog('Failed', 'Input Data Dengan Benar',
                      DialogType.ERROR, context, () {});
                } else {
                  progressDialog.show();
                  Future.delayed(Duration(seconds: 2)).then((value) {
                    // progressDialog.update(message: "Menyambungkan");
                    absent(noteController.text);
                    progressDialog.hide();
                  });
                }
              },
              textColor: Colors.white,
              padding: EdgeInsets.all(0.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFF2979FF),
                ),
                //  padding: EdgeInsets.only(left: 143, right: 143, top: 15, bottom: 15),
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  'Simpan',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Nunito"),
                ),
              ),
            ),
          )
        ]));
  }

  // Method memilih tanggal
  Future<Null> _selectDate(BuildContext context) async {
    final List<DateTime> picked = await DateRangePicker.showDatePicker(
        context: context,
        initialFirstDate: (new DateTime.now()),
        initialLastDate: new DateTime.now().add(new Duration(days: 3)),
        firstDate: new DateTime(2015),
        lastDate: new DateTime(2021));

    if (picked != null && picked != periode) {
      setState(() {
        var formatter = new DateFormat('dd-MM-yyyy');
        firstDate = formatter.format(picked[0]).toLowerCase();
        lastDate = formatter.format(picked[1]).toLowerCase();
      });
    }
  }

  // Method untuk melakukan izin, cuti, dll
  absent(String note) async {
    Map data = {
      "employee_id": sharedPreferences.getInt("employee_id").toString(),
      "type": typeValue,
      "firstDate": firstDate,
      "lastDate": lastDate,
      "note": note,
    };

    print(data);

    var jsonResponse = null;
    var response =
        await http.post("${config.apiURL}/api/absent/store", body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      showAlertDialog(
          'Success', jsonResponse['message'], DialogType.SUCCES, context, () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Dashboard()));
      });
    } else {
      jsonResponse = json.decode(response.body);
      showAlertDialog(
          'Failed', jsonResponse['message'], DialogType.ERROR, context, () {});
    }
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
}
