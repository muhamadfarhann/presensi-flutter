import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:presensi/models/todo.dart';

typedef OnDelete();

class TodoForm extends StatefulWidget {
  final Todo todo;
  final state = _TodoFormState();
  final OnDelete onDelete;

  TodoForm({Key key, this.todo, this.onDelete}) : super(key: key);
  @override
  _TodoFormState createState() => state;

  bool isValid() => state.validate();
}

class _TodoFormState extends State<TodoForm> {
  final form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Material(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(8),
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppBar(
                leading: Icon(Icons.verified_user),
                elevation: 0,
                title: Text(
                  'Todo Detail',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
                ),
                backgroundColor: Color(0xFF2979FF),
                centerTitle: true,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: widget.onDelete,
                  )
                ],
              ),
              Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Nunito",
                  ),
                  initialValue: widget.todo.task,
                  onSaved: (val) => widget.todo.task = val,
                  validator: (val) =>
                      val.length > 3 ? null : 'Isi Todo dengan benar',
                  decoration: InputDecoration(
                    labelText: 'Task',
                    hintText: 'Input Task',
                    icon: Icon(AntDesign.filetext1),
                    // Change dense to false
                    isDense: false,
                    //
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///form validator
  bool validate() {
    var valid = form.currentState.validate();
    if (valid) form.currentState.save();
    return valid;
  }
}
