import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ToDoItem.dart';

void main() {
  runApp(const ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ToDoPage(title: 'To-Do List'),
    );
  }
}

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key, required this.title});

  final String title;

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  final List<ToDoItem> _todoList = <ToDoItem>[];
  final TextEditingController _nameCtlr = TextEditingController();
  final TextEditingController _desCtlr = TextEditingController();
  final TextEditingController _dateCtlr = TextEditingController();
  final TextEditingController _timeCtlr = TextEditingController();
  bool isItemUpdate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: _todoList.map((ToDoItem todo) => _toDoList(todo)).toList(),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _displayDialog(ToDoItem()),
          tooltip: 'Add Item',
          child: Icon(Icons.add)),
    );
  }

  Future<void> _displayDialog(ToDoItem todo) async {
    if (isItemUpdate) {
      _nameCtlr.text = todo.name;
      _desCtlr.text = todo.description;
      _dateCtlr.text = todo.todoDate;
      _timeCtlr.text = todo.todoTime;
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Column(
          children: [
            AlertDialog(
              title: const Text('Add/Edit a New Task'),
              content: Column(
                children: [
                  TextField(
                    controller: _nameCtlr,
                    decoration:
                        const InputDecoration(hintText: 'Enter a task name'),
                  ),
                  TextField(
                    controller: _desCtlr,
                    decoration:
                        const InputDecoration(hintText: 'Enter a description'),
                  ),
                  TextField(
                    controller: _dateCtlr,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.calendar_today),
                        labelText: "Pick a Date"),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2300));
                      if (pickedDate != null) {
                        String strDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        setState(() {
                          _dateCtlr.text = strDate;
                        });
                      }
                    },
                  ),
                  TextField(
                    controller: _timeCtlr,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.calendar_today),
                        labelText: "Pick a Time"),
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());

                      if (pickedTime != null) {
                        setState(() {
                          _timeCtlr.text =
                              "${pickedTime.hour}:${pickedTime.minute}";
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    isItemUpdate = false;
                    _clearCtrl();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    int index = isItemUpdate ? todo.itemNum : _todoList.length;

                    _addTodoItem(_nameCtlr.text, _desCtlr.text, _dateCtlr.text,
                        _timeCtlr.text, index);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _addTodoItem(String name, String description, String todoDate,
      String todoTime, int itemNum) {
    setState(() {
      if (isItemUpdate) {
        _todoList[itemNum].name = name;
        _todoList[itemNum].description = description;
        _todoList[itemNum].todoDate = todoDate;
        _todoList[itemNum].todoTime = todoTime;
        isItemUpdate = false;
      } else {
        _todoList.add(ToDoItem(
            name: name,
            description: description,
            todoDate: todoDate,
            todoTime: todoTime,
            itemNum: itemNum));
      }
    });
    _clearCtrl();
  }

  // clears the TextField text values
  void _clearCtrl() {
    _nameCtlr.clear();
    _desCtlr.clear();
    _dateCtlr.clear();
    _timeCtlr.clear();
  }

  void _deleteTodoItem(ToDoItem todo) {
    setState(() {
      _todoList.removeAt(todo.itemNum);
      // updates the itemNum value matching the index of ToDoItem in the list
      for (int i = 0; i < _todoList.length; i++) {
        _todoList[i].itemNum = i;
      }
    });
  }

  // create the List of the to-do task in the body
  Widget _toDoList(ToDoItem todo) {
    return ListTile(
        leading: CircleAvatar(
          child: Text((todo.itemNum + 1).toString()),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 5),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(todo.name), Text(todo.description)],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 5),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(todo.todoDate),
                  Text(todo.todoTime),
                ],
              ),
            )
          ],
        ),
        trailing: Column(
          children: [
            GestureDetector(
              onTap: () {
                isItemUpdate = true;
                _displayDialog(todo);
              },
              child: Icon(Icons.edit),
            ),
            GestureDetector(
              onTap: () {
                isItemUpdate = false;
                _deleteTodoItem(todo);
              },
              child: Icon(Icons.delete),
            )
          ],
        ));
  }
}
