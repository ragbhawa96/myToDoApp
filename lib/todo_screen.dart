import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mydoapp/dbhelper.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final dbHelper = Databasehelper.instance;

  final textEditingController = TextEditingController();
  bool validated = true;
  String errText = '';

  var myItems = List();
  List<Widget> children = new List<Widget>(); // children widget set.

  /*add new task to db*/
  String todoEdited = '';
  void addTodo() async {
    Map<String, dynamic> row = {
      Databasehelper.columnName: todoEdited,
      Databasehelper.columnStatus: 0,
    };
    final id = await dbHelper.insert(row);
    print("$id");
    Navigator.of(context).pop();
    todoEdited = "";
    setState(() {
      validated = true;
      errText = "";
    });
  }

  /*mark completed tasks*/
  Icon markCompletedTask(String taskStatus) {
    if (taskStatus == '1') {
      return Icon(
        Icons.check_circle,
        color: Colors.green,
      );
    } else {
      return Icon(
        Icons.circle,
        color: Colors.grey.shade300,
      );
    }
  }

  Future<bool> query() async {
    myItems = [];
    children = [];

    var allRows = await dbHelper.queryall();

    allRows.forEach((row) {
      myItems.add(row.toString());

      children.add(Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(60.0)),
        elevation: 8.0,
        margin: EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 5.0,
        ),
        color: row['status'] == '0' ? null : Colors.grey.shade100,
        child: Container(
//          decoration: row['status'] == '0'
//              ? null
//              : BoxDecoration(color: Colors.grey.shade50),

          padding: EdgeInsets.all(5.0),
          child: ListTile(
            title: Text(
              row['todo'],
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18.0,
                decoration: row['status'] == '0'
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            onLongPress: () {
              dbHelper.deletedata(row['id']);
              setState(() {});
            },
            trailing: IconButton(
              icon: markCompletedTask(row['status']),
              onPressed: () {
                setState(() {
                  dbHelper.updateData(row['id'], 1);
                  print(row['status']);
//                  toggle = !toggle;
                });
                print("Icon button pressed.");
              },
            ),
          ),
        ),
      ));
    });
    return Future.value(true);
  }

  /*alert dialog for making new task*/
  void showAlertDialog() {
    textEditingController.text = "";
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Text(
                "Add Task",
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: textEditingController,
                    autofocus: true,
                    onChanged: (_val) {
                      todoEdited = _val;
                    },
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    decoration: InputDecoration(
                      errorText: validated ? null : errText,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () {
                            if (textEditingController.text.isEmpty) {
                              setState(() {
                                errText = "Can't Be Empty";
                                validated = false;
                              });
                            } else if (textEditingController.text.length > 50) {
                              setState(() {
                                errText = "Too many characters";
                                validated = false;
                              });
                            } else {
                              addTodo();
                            }
                          },
                          child: Text(
                            "ADD",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.blue,
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          });
        });
  }

  /* basic card of the task
  Widget myCard(String task) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(5.0),
        child: ListTile(
          title: Text(
            "$task",
          ),
          onLongPress: () {
            print("this is going be deleted");
          },
        ),
      ),
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snap) {
        if (snap.hasData == null) {
          return Center(
            child: Text(
              "No Data",
            ),
          );
        } else {
          if (myItems.length == 0) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: showAlertDialog,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
              appBar: AppBar(
                backgroundColor: Colors.blue,
                centerTitle: true,
                title: Text(
                  "ALL TASKS",
                  style: GoogleFonts.openSans(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              backgroundColor: Colors.white,
              body: Center(
                child: Text(
                  "No Task Avaliable",
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            );
          } else {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: showAlertDialog,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                backgroundColor: Colors.blue,
              ),
              appBar: AppBar(
                backgroundColor: Colors.blue,
                centerTitle: true,
                title: Text(
                  "ALL TASKS",
                  style: GoogleFonts.openSans(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                child: Column(
                  children: children,
                ),
              ),
            );
          }
        }
      },
      future: query(),
    );
  }
}
