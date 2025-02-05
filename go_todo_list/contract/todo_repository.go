package contract

import "go_todo_list/types"

type TodoRepository interface {
	CreateTodo(todo types.TodoPayload) error
	GetAllTodos(userID int) ([]types.Todo, error)
	GetTodoByID(ID int) (types.Todo, error)
	UpdateTodo(todo types.Todo) (*types.Todo, error)
	DeleteTodoByID(ID int) error
}
