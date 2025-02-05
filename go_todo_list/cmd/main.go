package main

import (
	"go_todo_list/cmd/database/db"
	"go_todo_list/cmd/router"
	"go_todo_list/config"
	"log"
	"net/http"

	"github.com/go-sql-driver/mysql"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Panic("Failed to load environment variables:", err)
	}

	envs := config.InitConfig()

	DB, err := db.NewDB(mysql.Config{
		User:   envs.DBUser,
		Passwd: envs.DBPassword,
		Net:    "tcp",
		Addr:   envs.DBAddress,
		DBName: envs.DBName,
	})
	if err != nil {
		log.Panic("Failed to connect to database:", err)
	}

	router := router.NewRouter(DB)

	srv := http.Server{
		Addr:    "localhost:8080",
		Handler: router,
	}

	log.Println("Server started at localhost:8080")

	if err := srv.ListenAndServe(); err != nil {
		log.Panic("Failed to start server:", err)
	}
}
