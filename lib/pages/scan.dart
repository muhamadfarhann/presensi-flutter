import 'package:barcode_scan/barcode_scan.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presensi/models/attendance.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class Scan extends StatefulWidget {
  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {

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
  Future _scanQR() async {
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
          result = qrResult;
          attendance = value;
          messageLocation = "${position.latitude}, ${position.longitude}";
          deviceId = androidDeviceId;
        });

    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Perizinan kamera ditolak";
        });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Scanner + Location"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text("NRP " + result),
            Text("Lokasi " + messageLocation),
            Text("Android Device ID  " + deviceId),
            Text((attendance !=
                    null) // Menampilkan hasil postresult menggunakan if
                ? attendance.id.toString() +
                    " | "  +
                    attendance.employeeId +
                    " | " +
                    attendance.date +
                    " | " +
                    attendance.timeIn
                : "Tidak ada data"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera_alt),
        onPressed: _scanQR,
        label: Text("Scan"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}