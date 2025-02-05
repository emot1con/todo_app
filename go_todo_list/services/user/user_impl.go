package user

import (
	"database/sql"
	"go_todo_list/types"
)

type UserRepoImpl struct {
	DB *sql.DB
}

func NewUserRepoImpl(DB *sql.DB) *UserRepoImpl {
	return &UserRepoImpl{
		DB: DB,
	}
}

func (u *UserRepoImpl) Register(user types.RegisterPayload) (string, error) {
	if _, err := u.DB.Query("INSERT INTO users (name, email, password) VALUES (?, ?, ?)", user.Name, user.Email, user.Password); err != nil {
		return "", err
	}

	return "User registered successfully", nil
}

func (u *UserRepoImpl) GetUserByEmail(email string) (types.User, error) {
	var user types.User
	if err := u.DB.QueryRow("SELECT id, name, email, password FROM users WHERE email = ?", email).Scan(&user.ID, &user.Name, &user.Email, &user.Password); err != nil {
		return user, err
	}

	return user, nil
}

func (u *UserRepoImpl) GetUserByID(ID int) (types.User, error) {
	var user types.User
	if err := u.DB.QueryRow("SELECT id, name, email, password FROM users WHERE id = ?", ID).Scan(&user.ID, &user.Name, &user.Email, &user.Password); err != nil {
		return user, err
	}

	return user, nil
}
