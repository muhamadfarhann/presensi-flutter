// Class PostResult
class Attendance {

  // Membuat variabel dengan tipe data string
  int id;
  String employeeId;
  String date;
  String timeIn;
  String timeOut;
  String overdue;
  String note;
  String latitudeIn;
  String longitudeIn;
  String latitudeOut;
  String longitudeOut;

  // Method constructor
  Attendance({
    this.id = 0, 
    this.employeeId, 
    this.date, 
    this.timeIn, 
    this.timeOut, 
    this.overdue,
    this.note,
    this.latitudeIn,
    this.longitudeIn,
    this.latitudeOut,
    this.longitudeOut
    
});

  // // Membuat factory method untuk membuat object dari postresult hasil mapping dari json object
  // factory Attendance.createAttendance(Map<String, dynamic> object) {
  //   // print(object);
  //   // Mengembalikan object postresult yang baru
  //   return Attendance(
  //     id: object['id'],
  //     employeeId: object['employee_id'],
  //     date: object['date'],
  //     timeIn: object['time_in'],
  //     timeOut: object['time_out'],
  //     overdue: object['overdue'],
  //     note: object['note'],
  //     latitudeIn: object['latitude_in'],
  //     longitudeIn: object['longitude_in'],
  //     latitudeOut: object['latitude_out'],
  //     longitudeOut: object['longitude_out'],
  //   );

  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     "id": id, 
  //     "employee_id": employeeId, 
  //     "date": date, 
  //     "time_in": timeIn, 
  //     "time_out": timeOut, 
  //     "overdue": overdue,
  //     "note": note,
  //     "latitude_in": latitudeIn,
  //     "longitude_in": longitudeIn,
  //     "latitude_out": latitudeOut,
  //     "longitude_out": longitudeOut
  //   };
  // }

  // @override
  // String toString() {
  //   return 
  //   'Attendance{id: $id, employee_id: $employeeId, date: $date, time_in: $timeIn, time_out: $timeOut, overdue: $overdue, note: $note, latitude_in: $latitudeIn, longitude_in: $longitudeIn, latitude_out: $latitudeOut, longitude_out: $longitudeOut}';
  // }


  // // Method untuk menghubungkan aplikasi kepada API yang membutuhkan data name dan job
  // static Future<Attendance> connectToAPI(String employeeId, String date, String timeIn, String timeOut, String overdue, String note, String latitudeIn, String longitudeIn, String latitudeOut, String longitudeOut) async {
  //   AppConfig config = new AppConfig();
  //   // Membutuhkan URL API
  //   String apiURL = "${config.apiURL}/api/attendance/store";

  //   // Memanggil http request
  //   final apiResult = await http.post(apiURL, body:{
  //     "employee_id": employeeId, 
  //     "date": date, 
  //     "time_in": timeIn, 
  //     "time_out": timeOut, 
  //     "overdue": overdue,
  //     "note": note,
  //     "latitude_in": latitudeIn,
  //     "longitude_in": longitudeIn,
  //     "latitude_out": latitudeOut,
  //     "longitude_out": longitudeOut
  //   });
  //   // Untuk mendapatkan bentuk json
  //   var jsonObject = json.decode(apiResult.body);
    
  //   // Mengembalikan nilai object postresult dari jsonObject
  //   return Attendance.createAttendance(jsonObject);
  // }
  
}
