postgres:
	docker run --name postgres15 --network bank-network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:15-alpine
createdb:
	docker exec -it postgres15 createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres15 dropdb simple_bank

migrateup:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" --verbose up

migrateup1:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" --verbose up 1


migratedown:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" --verbose down


migratedown1:
	migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" --verbose down


sqli:
	docker run --rm -v "${CURDIR}:/src" -w /src kjconroy/sqlc init

sqlg:		
	docker run --rm -v "${CURDIR}:/src" -w /src kjconroy/sqlc generate

mock:
	mockgen --build_flags=--mod=mod -package=mockdb    -destination db/mock/store.go bank-api/db/sqlc Store

test:
	go test -v -cover ./...

server:
	go run main.go

srn:
	docker run --name simplebank --network bank-network -p 8080:8080 -e GIN_MODE=release -e DB_SOURCE="postgresql://root:secret@postgres15:5432/simple_bank?sslmode=disable" simplebank:latest

.PHONY: postgres createdb dropdb migrateup migratedown sqli sqlg mock srn
