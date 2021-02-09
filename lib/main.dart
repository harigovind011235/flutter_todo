import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import './dbprovider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo',
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int spno = 0;
  int scno = 0;
  int sdno = 0;
  int tabIndex;

  List progressTask = [];
  List completedTask = [];
  List deletedTask = [];

  String task = '';

  final fieldText = TextEditingController();

  Future _getAllTask() async {
    progressTask = await DbProvider.instance.query({'status': 'progress'});
    completedTask = await DbProvider.instance.query({'status': 'completed'});
    deletedTask = await DbProvider.instance.query({'status': 'deleted'});
  }

  void addTask() async {
    await DbProvider.instance.insert({
      'task': task,
      'date': new DateTime.now().toString(),
      'status': 'progress'
    });
    progressTask = await DbProvider.instance.query({'status': 'progress'});
    completedTask = await DbProvider.instance.query({'status': 'completed'});
    deletedTask = await DbProvider.instance.query({'status': 'deleted'});

    setState(() {
      spno = 0;
      scno = 0;
      sdno = 0;
      task = '';
      fieldText.clear();
    });
  }

  void updateTask(int taskIndex, String status) async {
    await DbProvider.instance.update(
      {'_id': taskIndex, 'status': status},
    );
    progressTask = await DbProvider.instance.query({'status': 'progress'});
    completedTask = await DbProvider.instance.query({'status': 'completed'});
    deletedTask = await DbProvider.instance.query({'status': 'deleted'});

    setState(() {
      spno = 0;
      scno = 0;
      sdno = 0;
    });
  }

  void addTaskWidget(BuildContext ctx) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 400,
          child: Column(
            children: [
              SizedBox(
                height: 15.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'ADD TASK',
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    maxLines: null,
                    controller: fieldText,
                    decoration: InputDecoration(
                      hintText: 'Enter a task',
                      hintStyle: TextStyle(
                        color: Colors.deepOrangeAccent.shade200,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.deepOrangeAccent.shade200,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green,
                          width: 1.0,
                        ),
                      ),
                    ),
                    onChanged: (text) {
                      task = text;
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                child: RawMaterialButton(
                  elevation: 5.0,
                  fillColor: Colors.deepOrangeAccent.shade200,
                  child: Text(
                    'ADD',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    if (task != '') {
                      addTask();
                    }
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getAllTask();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'ToDo',
                style: TextStyle(
                  color: Colors.deepOrangeAccent.shade200,
                  fontSize: 25.0,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
              color: Colors.deepOrangeAccent.shade200,
              icon: Icon(
                Icons.add_circle,
                size: 35.0,
              ),
              onPressed: () => addTaskWidget(context),
            ),
          ],
        ),
        bottomNavigationBar: TabBar(
          unselectedLabelColor: Colors.deepOrangeAccent.shade200,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: Colors.deepOrangeAccent.shade200,
          ),
          tabs: [
            Tab(
              child: Text(
                'Progress',
              ),
              icon: Icon(
                Icons.timelapse,
              ),
            ),
            Tab(
              child: Text(
                'Completed',
              ),
              icon: Icon(
                Icons.check_circle,
              ),
            ),
            Tab(
              child: Text(
                'Deleted',
              ),
              icon: Icon(
                Icons.delete,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  Expanded(
                    child: progressTask.length > 0
                        ? SingleChildScrollView(
                            padding: EdgeInsets.all(5.0),
                            child: Column(
                              children:
                                  (progressTask as List).reversed.map((list) {
                                return Slidable(
                                  actionPane: SlidableDrawerActionPane(),
                                  actionExtentRatio: 0.15,
                                  child: Container(
                                    color: Colors.white,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            Colors.deepOrangeAccent.shade200,
                                        child:
                                            Text((spno = spno + 1).toString()),
                                        foregroundColor: Colors.white,
                                      ),
                                      title: Text(list['task']),
                                    ),
                                  ),
                                  actions: <Widget>[
                                    IconSlideAction(
                                      color: Colors.teal,
                                      icon: Icons.check_circle_outline_outlined,
                                      onTap: () => {
                                        updateTask(list['_id'], 'completed'),
                                      },
                                    ),
                                  ],
                                  secondaryActions: <Widget>[
                                    IconSlideAction(
                                      color: Colors.red,
                                      icon: Icons.delete,
                                      onTap: () => {
                                        updateTask(list['_id'], 'deleted'),
                                      },
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          )
                        : Center(
                            child: Image(
                              image: AssetImage(
                                'assets/images/add.png',
                              ),
                              width: 300.0,
                            ),
                          ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  Expanded(
                    child: completedTask.length > 0
                        ? SingleChildScrollView(
                            padding: EdgeInsets.all(5.0),
                            child: Column(
                              children:
                                  (completedTask as List).reversed.map((list) {
                                return Slidable(
                                  actionPane: SlidableDrawerActionPane(),
                                  actionExtentRatio: 0.15,
                                  child: Container(
                                    color: Colors.white,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            Colors.deepOrangeAccent.shade200,
                                        child:
                                            Text((scno = scno + 1).toString()),
                                        foregroundColor: Colors.white,
                                      ),
                                      title: Text(list['task']),
                                    ),
                                  ),
                                  actions: <Widget>[
                                    IconSlideAction(
                                      color: Colors.deepOrangeAccent,
                                      icon: Icons.timelapse,
                                      onTap: () => {
                                        updateTask(list['_id'], 'progress'),
                                      },
                                    ),
                                  ],
                                  secondaryActions: <Widget>[
                                    IconSlideAction(
                                      color: Colors.red,
                                      icon: Icons.delete,
                                      onTap: () => {
                                        updateTask(list['_id'], 'deleted'),
                                      },
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          )
                        : Center(
                            child: Image(
                              image: AssetImage(
                                'assets/images/complete.png',
                              ),
                              width: 300.0,
                            ),
                          ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  Expanded(
                    child: deletedTask.length > 0
                        ? SingleChildScrollView(
                            padding: EdgeInsets.all(5.0),
                            child: Column(
                              children:
                                  (deletedTask as List).reversed.map((list) {
                                return Slidable(
                                  actionPane: SlidableDrawerActionPane(),
                                  actionExtentRatio: 0.15,
                                  child: Container(
                                    color: Colors.white,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            Colors.deepOrangeAccent.shade200,
                                        child:
                                            Text((sdno = sdno + 1).toString()),
                                        foregroundColor: Colors.white,
                                      ),
                                      title: Text(list['task']),
                                    ),
                                  ),
                                  actions: <Widget>[
                                    IconSlideAction(
                                      color: Colors.deepOrangeAccent,
                                      icon: Icons.timelapse,
                                      onTap: () => {
                                        updateTask(list['_id'], 'progress'),
                                      },
                                    ),
                                  ],
                                  secondaryActions: <Widget>[
                                    IconSlideAction(
                                      color: Colors.teal,
                                      icon: Icons.check_circle,
                                      onTap: () => {
                                        updateTask(list['_id'], 'completed'),
                                      },
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          )
                        : Center(
                            child: Image(
                              image: AssetImage(
                                'assets/images/delete.png',
                              ),
                              width: 300.0,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
