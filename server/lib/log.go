package lib

import (
	"fmt"
)

type Logger interface {
	Info(...interface{})
	Warn(...interface{})
	Error(...interface{})
}

type BasicLogger struct {
}

func (l *BasicLogger) Info(args ...interface{}) {
	fmt.Println(args...)
}

func (l *BasicLogger) Warn(args ...interface{}) {
	fmt.Println(args...)
}

func (l *BasicLogger) Error(args ...interface{})  {
	fmt.Println(args...)
}

var DefaultLogger Logger = &BasicLogger{}
