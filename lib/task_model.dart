class TaskModel {
  final int id;
  final String task;
  final DateTime date;

  TaskModel({this.id, this.task, this.date});

  Map<String, dynamic> toMap() {
    // used when inserting data to the database
    return <String, dynamic>{
      "id": id,
      "task": task,
      "date": date,
    };
  }
}
