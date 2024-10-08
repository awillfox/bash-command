#!/bin/bash

# Function to display the menu
function show_menu() {
  echo "Select Go plugins to install (separate choices with spaces):"
  echo "0) REAL MAN USE NO PLUGIN"
  echo "A) ALL OF IT"
  echo "1) go-money"
  echo "2) sentry-go"
  echo "3) chi/v5"
  echo "4) go-chi/render"
  echo "5) google/go-querystring"
  echo "6) jackc/pgx/v5"
  echo "7) k0kubun/pp/v3"
  echo "8) go-redis/v9"
  echo "9) viper"
  echo "10) google.golang.org/grpc"
  echo "11) google.golang.org/protobuf"
  echo
}

# Ask the user for the project name
read -p "Enter your project name: " project_name

# Check if a name was provided
if [ -z "$project_name" ]; then
  echo "You must enter a project name."
  exit 1
fi

# Create a folder with the project name
mkdir "$project_name"

# Check if the folder was successfully created
if [ $? -eq 0 ]; then
  # Navigate to the newly created folder
  cd "$project_name"

  mkdir -p internal/sql

  go mod init "$project_name"

  # Create a 'main.go' file
  touch main.go

  echo '
  package main

import (
	"log"
)

func main() {
	log.Println("gwenchana gwenchana teng neng neng neng")
}

  ' >main.go

  echo 'version: '3'

dotenv: [".env"]

tasks:
  protogen:
    cmds:
      - protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative  $(find proto/ -iname "*.proto")
  migrate-dev:
    cmds:
      - atlas schema apply --url "$PSQL_URL" --to "file://schema.hcl" --dev-url "$PSQL_DEV_URL"

  migrate-prod:
    cmds:
      - atlas schema apply --url "$PSQL_PROD_URL" --to "file://schema.hcl"

  migrate-tuna:
    cmds:
      - atlas schema apply --url "$PSQL_TUNA_URL" --to "file://schema.hcl"

  generate-sql-schema:
    cmds:
      - atlas schema inspect -u "$PSQL_URL" --format "{{`{{ sql . }}`}}" > schema.sql

  sqlcgen:
    cmds:
      - sqlc generate' >Taskfile.yml

  echo '
version: "2"
sql:
  - engine: "postgresql"
    queries:
      - "internal/sql"
    schema: "schema.sql"
    gen:
      go:
        package: "sqlc"
        sql_package: "pgx/v5"
        out: "sqlc"
        emit_json_tags: true
        emit_empty_slices: true
      ' >sqlc.yaml

  random_string=$(tr -dc 'A-Za-z0-9~!@#$%^&*()_+=-[]{}|;:,.<>?' </dev/urandom | head -c 32)

  echo 'BASE_URL=
PSQL_CONNECTION=
PSQL_URL=
PSQL_DEV_URL=
ENV="DEV"
SECRET_TOKEN="'$random_string'"
REDIS_URL=
SENTRY_DSN=
' >.env

  echo "Project folder '$project_name' created successfully."

  show_menu
  read -p "Enter your choices (e.g. 1 2): " choices

  if [[ "$choices" == "A" || "$choices" == "a" ]]; then
    echo "Installing all plugins..."
    go get github.com/Rhymond/go-money
    go get github.com/getsentry/sentry-go
    go get github.com/go-chi/chi/v5
    go get github.com/go-chi/render
    go get github.com/google/go-querystring
    go get github.com/jackc/pgx/v5
    go get github.com/k0kubun/pp/v3
    go get github.com/redis/go-redis/v9
    go get github.com/spf13/viper
    go get google.golang.org/grpc
    go get google.golang.org/protobuf
  else
    for choice in $choices; do
      case $choice in
      1)
        echo "Installing github.com/Rhymond/go-money..."
        go get github.com/Rhymond/go-money
        ;;
      2)
        echo "Installing github.com/getsentry/sentry-go..."
        go get github.com/getsentry/sentry-go
        ;;
      3)
        echo "Installing github.com/go-chi/chi/v5..."
        go get github.com/go-chi/chi/v5
        ;;
      4)
        echo "Installing github.com/go-chi/render..."
        go get github.com/go-chi/render
        ;;
      5)
        echo "Installing github.com/google/go-querystring..."
        go get github.com/google/go-querystring
        ;;
      6)
        echo "Installing github.com/jackc/pgx/v5..."
        go get github.com/jackc/pgx/v5
        ;;
      7)
        echo "Installing github.com/k0kubun/pp/v3..."
        go get github.com/k0kubun/pp/v3
        ;;
      8)
        echo "Installing github.com/redis/go-redis/v9..."
        go get github.com/redis/go-redis/v9
        ;;
      9)
        echo "Installing github.com/spf13/viper..."
        go get github.com/spf13/viper
        ;;
      10)
        echo "Installing google.golang.org/grpc..."
        go get google.golang.org/grpc
        ;;
      11)
        echo "Installing google.golang.org/protobuf..."
        go get google.golang.org/protobuf
        ;;
      0)
        echo "No plugins selected."
        ;;
      *)
        echo "Invalid choice: $choice"
        ;;
      esac
    done
  fi
  echo "Go Mod Tidying"
  go mod tidy

  echo "Done"

else
  echo "Failed to create project folder. It may already exist or there was an error."
fi
