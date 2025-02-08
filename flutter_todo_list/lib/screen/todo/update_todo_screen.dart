import 'package:flutter/material.dart';
import 'package:flutter_todo_list/provider/todo/todo_provider.dart';
import 'package:provider/provider.dart';

class UpdateTodoScreen extends StatefulWidget {
  const UpdateTodoScreen({
    super.key,
    required this.todoID,
    required this.title,
  });
  final int todoID;
  final String title;

  @override
  State<UpdateTodoScreen> createState() => _UpdateTodoScreenState();
}

class _UpdateTodoScreenState extends State<UpdateTodoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<TodoProvider>(
        builder: (context, value, child) {
          return Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: value.updateTodoTitle,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: value.updateTodoDescription,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completed:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: value.updateTodoIsCompleted,
                      onChanged: (answer) {
                        setState(() {
                          value.updateTodoIsCompleted = answer;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 58, 20, 173)),
                    onPressed: () async {
                      if (value.updateTodoTitle.text.isNotEmpty) {
                        await value.updateTodo(
                          context,
                          widget.todoID,
                          widget.title,
                        );
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Update',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 172, 36, 26)),
                    onPressed: () async {
                      await value.deleteTodo(
                        context,
                        widget.todoID,
                        widget.title,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: Icon(Icons.delete),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
