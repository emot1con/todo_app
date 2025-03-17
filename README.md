# Todo App (Flutter & Go)

A simple task management application built with Flutter for the frontend and Go for the backend.

## Features
- Add, update, and delete tasks.
- Mark tasks as completed.
- Store tasks in a database.
- REST API for backend communication.

## Tech Stack
- **Frontend:** Flutter
- **Backend:** Go (HTTP Router framework)
- **Database:** PostgreSQL

## Getting Started

### Backend Setup (Go)
1. **Clone the repository:**
   ```sh
   git clone https://github.com/emot1con/todo_with_backend.git
   ```
2. **Navigate to the backend folder:**
   ```sh
   cd todo_with_backend
   ```
3. **Install dependencies:**
   ```sh
   go mod tidy
   ```
4. **Configure environment variables:**
   - Create a `.env` file in the `backend` directory.
   - Add the following:
     ```env
     DATABASE_URL=your_database_connection_string
     SERVER_PORT=8080
     ```
5. **Run the backend server:**
   ```sh
   go run main.go
   ```

### Frontend Setup (Flutter)
1. **Navigate to the frontend folder:**
   ```sh
   cd ../frontend
   ```
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Run the Flutter app:**
   ```sh
   flutter run
   ```

## API Endpoints
- `GET /tasks` - Fetch all tasks.
- `POST /tasks` - Create a new task.
- `PUT /tasks/{id}` - Update a task.
- `DELETE /tasks/{id}` - Delete a task.

## License
This project is open-source and available under the MIT License.

