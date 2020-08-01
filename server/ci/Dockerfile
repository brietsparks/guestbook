FROM golang:1.14 as builder
WORKDIR /guestbook-server
COPY ../docker /guestbook-server
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-w' cmd/main.go
ENTRYPOINT ["/guestbook-server/main"]

FROM alpine:latest
WORKDIR /guestbook-server
COPY --from=builder guestbook-server/main .
ENTRYPOINT ["/guestbook-server/main"]
