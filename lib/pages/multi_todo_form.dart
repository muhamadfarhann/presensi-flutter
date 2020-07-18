import 'package:flutter/material.dart';
import 'package:presensi/models/todo.dart';
// import 'package:flutter_multipage_form/empty_state.dart';
import 'package:presensi/pages/TodoForm.dart';
import 'package:presensi/pages/empty_state.dart';

class MultiTodoForm extends StatefulWidget {
  @override
  _MultiTodoFormState createState() => _MultiTodoFormState();
}


class _MultiTodoFormState extends State<MultiTodoForm> {
  List<TodoForm> todos = [];

  @override
  Widget build(BuildContext context) {
    var length;
    return Scaffold(
      appBar: AppBar(
        elevation: .0,
        leading: Icon(
          Icons.wb_cloudy,
        ),
        title: Text('Pengisian Todo Harian'),
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
          gradient: LinearGradient(
            colors: [
              Color(0xFF30C1FF),
              Color(0xFF2AA7DC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
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

  ///on save forms
  void onSave() {
    if (todos.length > 0) {
      var allValid = true;
      todos.forEach((form) => allValid = allValid && form.isValid());
      if (allValid) {
        var data = todos.map((it) => it.todo).toList();
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => Scaffold(
                  appBar: AppBar(
                    title: Text('List of Users'),
                  ),
                  body: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (_, i) => ListTile(
                          leading: CircleAvatar(
                            child: Text(data[i].task.substring(0, 1)),
                          ),
                          title: Text(data[i].task),
                        ),
                  ),
                ),
          ),
        );
      }
    }
  }
}
