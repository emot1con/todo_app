package todo

import (
	"fmt"
	"go_todo_list/contract"
	"go_todo_list/services/auth"
	"go_todo_list/types"
	"go_todo_list/utils"
	"net/http"
	"strconv"

	"github.com/go-playground/validator"
	"github.com/julienschmidt/httprouter"
)

type TodoRoutes struct {
	repo      contract.TodoRepository
	userRepo  contract.UserRepository
	validator *validator.Validate
}

func NewTodoRoutes(repo contract.TodoRepository, validator *validator.Validate, userRepo contract.UserRepository) *TodoRoutes {
	return &TodoRoutes{
		repo:      repo,
		validator: validator,
		userRepo:  userRepo,
	}
}

func (t *TodoRoutes) RegisterRoutes(router *httprouter.Router) {
	router.POST("/todo", auth.AuthWithJWT(t.CreateTodo, t.userRepo))
	router.GET("/todo", auth.AuthWithJWT(t.GetAllTodos, t.userRepo))
	router.PUT("/todo/:todoID", auth.AuthWithJWT(t.UpdateTodo, t.userRepo))
	router.DELETE("/todo/:todoID", auth.AuthWithJWT(t.DeleteTodoByID, t.userRepo))
}

func (t *TodoRoutes) CreateTodo(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	id := auth.GetUserIDFromContext(r.Context())
	var payload types.TodoPayload
	if err := utils.ReadJSON(r, &payload); err != nil {
		utils.WriteError(w, http.StatusBadRequest, fmt.Errorf("bad request: %v", err))
		return
	}

	if err := t.validator.Struct(payload); err != nil {
		utils.WriteError(w, http.StatusBadRequest, fmt.Errorf("invalid request: %v", err))
		return
	}
	payload.UserID = id

	if err := t.repo.CreateTodo(payload); err != nil {
		utils.WriteError(w, http.StatusInternalServerError, fmt.Errorf("failed to create todo: %v", err))
		return
	}

	utils.WriteJSON(w, http.StatusOK, map[string]string{"message": "todo created successfully"})
}

func (t *TodoRoutes) GetAllTodos(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	userId := auth.GetUserIDFromContext(r.Context())
	todos, err := t.repo.GetAllTodos(userId)
	if err != nil {
		utils.WriteError(w, http.StatusInternalServerError, fmt.Errorf("failed to get todos: %v", err))
		return
	}

	utils.WriteJSON(w, http.StatusOK, todos)
}

func (t *TodoRoutes) UpdateTodo(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	var payload types.TodoPayload
	if err := utils.ReadJSON(r, &payload); err != nil {
		utils.WriteError(w, http.StatusBadRequest, fmt.Errorf("bad request: %v", err))
		return
	}
	if err := t.validator.Struct(payload); err != nil {
		utils.WriteError(w, http.StatusBadRequest, fmt.Errorf("invalid request: %v", err))
		return
	}

	todo, err := t.getTodoByID(p)
	if err != nil {
		utils.WriteError(w, http.StatusBadRequest, fmt.Errorf("invalid todo id: %v", err))
		return
	}

	todo.Title = payload.Title
	todo.Description = payload.Description
	todo.IsCompleted = payload.IsCompleted

	updatedTodo, err := t.repo.UpdateTodo(todo)
	if err != nil {
		utils.WriteError(w, http.StatusInternalServerError, fmt.Errorf("failed to update todo: %v", err))
		return
	}

	utils.WriteJSON(w, http.StatusOK, updatedTodo)
}

func (t *TodoRoutes) DeleteTodoByID(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	id := p.ByName("todoID")
	userId, err := strconv.Atoi(id)
	if err != nil {
		utils.WriteError(w, http.StatusBadRequest, fmt.Errorf("invalid user id"))
		return
	}

	if err := t.repo.DeleteTodoByID(userId); err != nil {
		utils.WriteError(w, http.StatusBadRequest, err)
		return
	}

	utils.WriteJSON(w, http.StatusOK, map[string]string{"message": "todo deleted successfully"})
}

func (t *TodoRoutes) getTodoByID(p httprouter.Params) (types.Todo, error) {
	id := p.ByName("todoID")
	userId, err := strconv.Atoi(id)
	if err != nil {
		return types.Todo{}, err
	}

	todo, err := t.repo.GetTodoByID(userId)
	if err != nil {
		return types.Todo{}, err

	}

	return todo, nil
}
