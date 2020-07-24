FROM golang:1.14
WORKDIR /guestbook-server
COPY . /guestbook-server
RUN go mod download && go build cmd/main.go
ENTRYPOINT ["/guestbook-server/main"]
