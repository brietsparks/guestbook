FROM golang:1.14 as builder
WORKDIR /guestbook-server
COPY . /guestbook-server
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-w' cmd/main.go
#RUN CGO_ENABLED=0 go mod download && go build cmd/main.go
ENTRYPOINT ["/guestbook-server/main"]

FROM alpine:latest
WORKDIR /guestbook-server
COPY --from=builder guestbook-server/main .
ENTRYPOINT ["/guestbook-server/main"]
