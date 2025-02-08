class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String userId;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.userId,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'userId': userId,
    };
  }
}

List<TodosResponseModel> todosResponseModelFromJson(List<dynamic> jsonList) =>
    List<TodosResponseModel>.from(
        jsonList.map((json) => TodosResponseModel.fromJson(json)));

List<Map<String, dynamic>> todosResponseModelToJson(
        List<TodosResponseModel> data) =>
    List<Map<String, dynamic>>.from(data.map((todo) => todo.toJson()));

class TodosResponseModel {
  final int id;
  final String title;
  final String description;
  bool isCompleted;
  final int userId;
  final DateTime createdAt;

  TodosResponseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.userId,
    required this.createdAt,
  });

  factory TodosResponseModel.fromJson(Map<String, dynamic> json) =>
      TodosResponseModel(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        isCompleted: json["is_completed"],
        userId: json["user_id"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "is_completed": isCompleted,
        "user_id": userId,
        "created_at": createdAt.toIso8601String(),
      };
}

class TodoCreatePayload {
  final String title;
  final String description;
  final bool isCompleted;

  TodoCreatePayload({
    required this.title,
    required this.description,
    required this.isCompleted,
  });

  factory TodoCreatePayload.fromJson(Map<String, dynamic> json) =>
      TodoCreatePayload(
        title: json["title"],
        description: json["description"],
        isCompleted: json["is_completed"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "is_completed": isCompleted,
      };
}

class UpdateTodoPayload {
  final String title;
  final String description;
  final bool isCompleted;
  final int userId;

  UpdateTodoPayload({
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.userId,
  });

  factory UpdateTodoPayload.fromJson(Map<String, dynamic> json) =>
      UpdateTodoPayload(
        title: json["title"],
        description: json["description"],
        isCompleted: json["is_completed"],
        userId: json["user_id"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "is_completed": isCompleted,
        "user_id": userId,
      };
}
