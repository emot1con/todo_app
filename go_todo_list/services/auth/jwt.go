package auth

import (
	"context"
	"fmt"
	"go_todo_list/contract"
	"go_todo_list/utils"
	"net/http"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/julienschmidt/httprouter"
)

type UserKey string

var UserIdKey UserKey = "userId"

func GenerateJWTToken(userId int, role string, duration time.Duration) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"userId": userId,
		"exp":    time.Now().Add(duration).Unix(),
		"role":   role,
	})

	signedToken, err := token.SignedString([]byte(os.Getenv("JWT_KEY")))
	if err != nil {
		return "", err
	}

	return signedToken, nil
}

func AuthWithJWT(handle httprouter.Handle, repo contract.UserRepository) httprouter.Handle {
	return func(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
		tokenString := r.Header.Get("Authorization")
		if tokenString == "" {
			utils.WriteError(w, http.StatusUnauthorized, fmt.Errorf("token missing"))
			return
		}

		token, err := jwt.Parse(tokenString, func(t *jwt.Token) (interface{}, error) {
			if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
			}
			return []byte(os.Getenv("JWT_KEY")), nil
		})

		if err != nil || !token.Valid {
			utils.WriteError(w, http.StatusUnauthorized, fmt.Errorf("invalid token: %v", err))
			return
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			utils.WriteError(w, http.StatusUnauthorized, fmt.Errorf("invalid token claims"))
			return
		}

		userId, ok := claims["userId"].(float64)
		if !ok {
			utils.WriteError(w, http.StatusUnauthorized, fmt.Errorf("invalid user id"))
			return
		}

		user, err := repo.GetUserByID(int(userId))
		if err != nil {
			utils.WriteError(w, http.StatusUnauthorized, fmt.Errorf("user not found: %v", err))
			return
		}

		ctx := r.Context()
		ctx = context.WithValue(ctx, UserIdKey, user.ID)
		r = r.WithContext(ctx)

		handle(w, r, p)
	}
}

func RefreshToken(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	header := r.Header.Get("Authorization")
	if header == "" {
		utils.WriteError(w, http.StatusUnauthorized, fmt.Errorf("token missing"))
		return
	}

	token, err := jwt.Parse(header, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
		}

		return []byte(os.Getenv("JWT_KEY")), nil
	})
	if err != nil || !token.Valid {
		utils.WriteError(w, http.StatusUnauthorized, fmt.Errorf("invalid token: %v", err))
		return
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		utils.WriteError(w, http.StatusUnauthorized, fmt.Errorf("invalid token claims"))
		return
	}

	expired := claims["exp"].(float64)

	if time.Now().Unix() > int64(expired) {
		utils.WriteError(w, http.StatusUnauthorized, fmt.Errorf("token expired"))
		return
	}

	accesToken, err := GenerateJWTToken(int(claims["userId"].(float64)), "user", time.Hour*1)
	if err != nil {
		utils.WriteError(w, http.StatusInternalServerError, fmt.Errorf("failed to generate access token: %v", err))
		return
	}

	refreshToken, err := GenerateJWTToken(int(claims["userId"].(float64)), "user", time.Hour*24*30*3)
	if err != nil {
		utils.WriteError(w, http.StatusInternalServerError, fmt.Errorf("failed to generate refresh token: %v", err))
		return
	}

	utils.WriteJSON(w, http.StatusOK, map[string]string{
		"accesToken":      accesToken,
		"refreshToken":    refreshToken,
		"exp":             time.Now().Add(time.Hour * 1).String(),
		"expRefreshToken": time.Now().Add(time.Hour * 24 * 30 * 3).String(),
		"role":            "user",
	},
	)

}

func GetUserIDFromContext(ctx context.Context) int {
	id, ok := ctx.Value(UserIdKey).(int)
	if !ok {
		return -1
	}
	return id
}
