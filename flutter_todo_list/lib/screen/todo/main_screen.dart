import 'package:flutter/material.dart';
import 'package:flutter_todo_list/models/todo_model.dart';
import 'package:flutter_todo_list/screen/todo/update_todo_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:flutter_todo_list/provider/todo/todo_provider.dart';
import 'package:flutter_todo_list/screen/todo/create_todo.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().getAll(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Todo",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateTodoScreen()),
              ).then((_) {
                if (context.mounted) {
                  context.read<TodoProvider>().getAll(context);
                }
              });
            },
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Consumer<TodoProvider>(
          builder: (context, value, child) {
            if (value.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (value.todos.isNotEmpty) {
              return ListView.builder(
                itemCount: value.todos.length,
                itemBuilder: (context, index) {
                  value.todos.sort(
                    (a, b) => b.createdAt.compareTo(a.createdAt),
                  );
                  final todo = value.todos[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onLongPress: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => UpdateTodoScreen(
                                      todoID: todo.id, title: todo.title)))
                              .then((_) {
                            if (context.mounted) {
                              context.read<TodoProvider>().getAll(context);
                              print('updated');
                            }
                          });
                        },
                        onTap: () {
                          todo.isCompleted = !todo.isCompleted;
                          value.updateTodoTitle.text = todo.title;
                          value.updateTodoDescription.text = todo.description;
                          value.updateTodoIsCompleted = todo.isCompleted;

                          value.updateTodo(
                            context,
                            todo.id,
                            todo.title,
                            updateAll: false,
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(
                              todo.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  todo.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Created: ${DateFormat('dd MMM yyyy').format(todo.createdAt)}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              todo.isCompleted
                                  ? Icons.check_circle
                                  : Icons.circle,
                              color:
                                  todo.isCompleted ? Colors.green : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(
              child: Text("Empty"),
            );
          },
        ),
      ),
    );
  }
}
