import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:presensi/configs/app_config.dart';
import 'package:presensi/models/todo.dart';
import 'package:presensi/pages/TodoForm.dart';
import 'package:presensi/pages/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class MultiTodoForm extends StatefulWidget {
  @override
  _MultiTodoFormState createState() => _MultiTodoFormState();
}

class _MultiTodoFormState extends State<MultiTodoForm> {
  List<TodoForm> todos = [];
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF2979FF),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Padding(
          padding: EdgeInsets.only(left: 30),
          child: Text(
            'Pengisian Todo Harian',
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w700),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Save'),
            textColor: Colors.white,
            onPressed: onSave,
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   colors: [
            //     Color(0xFF30C1FF),
            //     Color(0xFF2AA7DC),
            //   ],
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            // ),
            color: Colors.grey[200]),
        child:
            // TimeOfDayFormat.a_space_h_colon_mm.length <= 0
            //     ? Center(
            //         child: EmptyState(
            //           title: 'Oops',
            //           message: 'Add form by tapping add button below',
            //         ),
            //       )
            // :
            ListView.builder(
          addAutomaticKeepAlives: true,
          itemCount: todos.length,
          itemBuilder: (_, i) => todos[i],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: onAddForm,
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF2979FF),
      ),
    );
  }

  ///on form user deleted
  void onDelete(Todo _todo) {
    setState(() {
      var find = todos.firstWhere(
        (it) => it.todo == _todo,
        orElse: () => null,
      );
      if (find != null) todos.removeAt(todos.indexOf(find));
    });
  }

  ///on add form
  void onAddForm() {
    setState(() {
      var _todo = Todo();
      todos.add(TodoForm(
        todo: _todo,
        onDelete: () => onDelete(_todo),
      ));
    });
  }

  // on save forms
  onSave() async {
    if (todos.length > 0) {
      var allValid = true;
      todos.forEach((form) => allValid = allValid && form.isValid());
      if (allValid) {
        var data = todos.map((it) => it.todo).toList();
        var todo = List();
        for (var i = 0; i < data.length; i++) {
          var td = {'todo': data[i].task};
          todo.add(data[i].task);
        }
        AppConfig config = new AppConfig();
        var param = json.encode({
          'employee_id': sharedPreferences.getInt("employee_id").toString(),
          "todos": todo
        });

        var jsonResponse = null;
        var response = await http.post("${config.apiURL}/api/todo/store",
            body: param, headers: {'Content-type': 'application/json'});
        if (response.statusCode == 200) {
          jsonResponse = json.decode(response.body);
          showAlertDialog(
              'Success', jsonResponse['message'], DialogType.SUCCES, context,
              () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Dashboard()));
          });
        } else {
          jsonResponse = json.decode(response.body);
          showAlertDialog('Failed', jsonResponse['message'], DialogType.ERROR,
              context, () {});
        }
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     fullscreenDialog: true,
        //     builder: (_) => Scaffold(
        //       appBar: AppBar(
        //         title: Text('List of Todos'),
        //       ),
        //       body: ListView.builder(
        //         itemCount: data.length,
        //         itemBuilder: (_, i) => ListTile(
        //           leading: CircleAvatar(
        //             child: Text(data[i].task.substring(0, 1)),
        //           ),
        //           title: Text(data[i].task),
        //         ),
        //       ),
        //     ),
        //   ),
        // );
      }
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
