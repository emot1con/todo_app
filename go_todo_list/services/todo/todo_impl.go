package todo

import (
	"database/sql"
	"errors"
	"fmt"
	"go_todo_list/types"
)

type TodoRepoImpl struct {
	DB *sql.DB
}

func NewTodoRepoImpl(db *sql.DB) *TodoRepoImpl {
	return &TodoRepoImpl{DB: db}
}

func (u *TodoRepoImpl) CreateTodo(todo types.TodoPayload) error {
	if _, err := u.DB.Query("INSERT INTO todos (title, description, is_completed, user_id) VALUES (?, ?, ?, ?)",
		todo.Title, todo.Description, todo.IsCompleted, todo.UserID,
	); err != nil {
		return err
	}

	return nil
}

func (u *TodoRepoImpl) GetAllTodos(userID int) ([]types.Todo, error) {
	var todos []types.Todo
	rows, err := u.DB.Query(`
    SELECT todos.id AS todo_id, todos.title, todos.description, todos.is_completed, todos.user_id, todos.created_at
	FROM todos JOIN users ON todos.user_id = users.id WHERE users.id = ?`,
		userID,
	)

	if err != nil {
		return nil, err
	}

	if !rows.Next() {
		return []types.Todo{}, nil
	}

	defer rows.Close()

	for rows.Next() {
		var todo types.Todo
		if err := rows.Scan(&todo.ID, &todo.Title, &todo.Description, &todo.IsCompleted, &todo.UserID, &todo.CreatedAt); err != nil {
			return nil, err
		}

		todos = append(todos, todo)
	}

	return todos, nil
}

func (u *TodoRepoImpl) GetTodoByID(ID int) (types.Todo, error) {
	var todo types.Todo
	row := u.DB.QueryRow("SELECT id, title, description, is_completed, user_id FROM todos WHERE id = ?", ID)

	err := row.Scan(&todo.ID, &todo.Title, &todo.Description, &todo.IsCompleted, &todo.UserID)
	if err != nil {
		if err == sql.ErrNoRows {
			return types.Todo{}, fmt.Errorf("todo not found")
		}
		return types.Todo{}, err
	}

	return todo, nil
}

func (u *TodoRepoImpl) UpdateTodo(todo types.Todo) (*types.Todo, error) {
	_, err := u.DB.Exec("UPDATE todos SET title = ?, description = ?, is_completed = ? WHERE id = ?",
		todo.Title, todo.Description, todo.IsCompleted, todo.ID)
	if err != nil {
		return nil, err
	}

	updateTodo, err := u.GetTodoByID(todo.ID)
	if err != nil {
		return nil, err
	}

	return &updateTodo, nil
}

func (u *TodoRepoImpl) DeleteTodoByID(ID int) error {
	if result, err := u.DB.Exec("DELETE FROM todos WHERE id = ?", ID); err != nil {
		return err
	} else if rowsAffected, _ := result.RowsAffected(); rowsAffected == 0 {
		return errors.New("todo not found")
	}

	return nil
}
