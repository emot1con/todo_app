import 'package:flutter/material.dart';
import 'package:flutter_todo_list/provider/todo/todo_provider.dart';
import 'package:provider/provider.dart';

class CreateTodoScreen extends StatefulWidget {
  const CreateTodoScreen({super.key});
  @override
  State<CreateTodoScreen> createState() => _CreateTodoScreenState();
}

class _CreateTodoScreenState extends State<CreateTodoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Todo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: provider.formKeyCreate,
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    onSaved: (title) {
                      provider.createTodoTitle = title!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      provider.createTodoDescription = value!;
                    },
                  ),
                  Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Completed'),
                      Switch(
                        value: provider.createTodoIsCompleted,
                        onChanged: (value) {
                          setState(() {
                            provider.createTodoIsCompleted = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (provider.formKeyCreate.currentState!.validate()) {
                          provider.formKeyCreate.currentState!.save();
                          provider.createTodo(context);
                        }
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Create Todo'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
