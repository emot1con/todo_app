package router

import (
	"database/sql"
	"go_todo_list/services/todo"
	"go_todo_list/services/user"

	"github.com/go-playground/validator"
	"github.com/julienschmidt/httprouter"
)

func NewRouter(DB *sql.DB) *httprouter.Router {
	router := httprouter.New()
	validator := validator.New()

	userRepo := user.NewUserRepoImpl(DB)
	userRoutes := user.NewUserRoutes(userRepo, validator)
	userRoutes.RegisterRoutes(router)

	todoRepo := todo.NewTodoRepoImpl(DB)
	todoRoutes := todo.NewTodoRoutes(todoRepo, validator, userRepo)
	todoRoutes.RegisterRoutes(router)

	return router
}
