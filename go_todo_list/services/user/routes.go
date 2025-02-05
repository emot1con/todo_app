package user

import (
	"fmt"
	"go_todo_list/contract"
	"go_todo_list/services/auth"
	"go_todo_list/types"
	"go_todo_list/utils"
	"net/http"
	"time"

	"github.com/go-playground/validator"
	"github.com/julienschmidt/httprouter"
)

type UserRoutes struct {
	repo      contract.UserRepository
	validator *validator.Validate
}

func NewUserRoutes(repo contract.UserRepository, validator *validator.Validate) *UserRoutes {
	return &UserRoutes{
		repo:      repo,
		validator: validator,
	}
}

func (u *UserRoutes) RegisterRoutes(router *httprouter.Router) {
	router.POST("/auth/register", u.Register)
	router.POST("/auth/login", u.Login)
	router.POST("/auth/refresh-token", auth.RefreshToken)
}

func (u *UserRoutes) Register(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	var payload types.RegisterPayload
	if err := utils.ReadJSON(r, &payload); err != nil {
		utils.WriteError(w, http.StatusBadRequest, fmt.Errorf("bad request: %v", err))
		return
	}

	// validate payload
	if err := u.validator.Struct(payload); err != nil {
		utils.WriteError(w, http.StatusBadRequest, fmt.Errorf("invalid request: %v", err))
		return
	}

	// check if user already exists
	if _, err := u.repo.GetUserByEmail(payload.Email); err == nil {
		utils.WriteError(w, http.StatusBadRequest, fmt.Errorf("user already exists"))
		return
	}

	// hash password
	hashPassword, err := auth.GenerateHashPassword(payload.Password)
	if err != nil {
		utils.WriteError(w, http.StatusInternalServerError, fmt.Errorf("failed to hash password: %v", err))
		return
	}
	payload.Password = hashPassword

	// register user
	result, err := u.repo.Register(payload)
	if err != nil {
		utils.WriteError(w, http.StatusInternalServerError, fmt.Errorf("failed to register user: %v", err))
		return
	}

	utils.WriteJSON(w, http.StatusOK, result)
}

func (u *UserRoutes) Login(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	var payload types.LoginPayload
	if err := utils.ReadJSON(r, &payload); err != nil {
		utils.WriteError(w, http.StatusBadRequest, fmt.Errorf("bad request: %v", err))
		return
	}

	if err := u.validator.Struct(payload); err != nil {
		utils.WriteError(w, http.StatusBadRequest, fmt.Errorf("invalid request: %v", err))
		return
	}

	user, err := u.repo.GetUserByEmail(payload.Email)
	if err != nil {
		utils.WriteError(w, http.StatusNotFound, fmt.Errorf("user not found"))
		return
	}

	if err := auth.ComparePasswords(user.Password, []byte(payload.Password)); err != nil {
		utils.WriteError(w, http.StatusUnauthorized, fmt.Errorf("invalid password"))
		return
	}

	accesToken, err := auth.GenerateJWTToken(user.ID, "user", time.Hour*1)
	if err != nil {
		utils.WriteError(w, http.StatusInternalServerError, fmt.Errorf("failed to generate access token: %v", err))
		return
	}

	refreshToken, err := auth.GenerateJWTToken(user.ID, "user", time.Hour*24*30*3)
	if err != nil {
		utils.WriteError(w, http.StatusInternalServerError, fmt.Errorf("failed to generate access token: %v", err))
		return
	}

	utils.WriteJSON(w, http.StatusOK, map[string]string{
		"accesToken":      accesToken,
		"refreshToken":    refreshToken,
		"exp":             time.Now().Add(time.Hour * 1).String(),
		"expRefreshToken": time.Now().Add(time.Hour * 24 * 30 * 3).String(),
		"role":            "user"},
	)
}
