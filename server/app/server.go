package app

import (
	"fmt"
	"github.com/brietsparks/guestbook-server/lib"
	"github.com/gin-gonic/gin"
	"net/http"
)

type Server struct {
	model  *Model
	port   string
	logger lib.Logger
}

func Serve(model *Model, port string, logger lib.Logger) error {
	r := gin.Default()

	s := &Server{
		model:  model,
		port:   port,
		logger: logger,
	}

	r.GET("/health", s.health)
	r.GET("/items", s.getItemsByIp)
	r.POST("/items", s.createItem)

	return r.Run(fmt.Sprintf(":%s", s.port))
}

func (s *Server) health(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"ok": "1"})
}

func (s *Server) getItemsByIp(c *gin.Context) {
	result, err := s.model.GetItemsByIp(c.ClientIP(), 10)
	if err != nil {
		errId := s.logInternalError(err)
		c.JSON(http.StatusInternalServerError, gin.H{"errorId": errId})
		return
	}

	c.JSON(http.StatusOK, result)
}

type createItemInput struct {
	Value string `json:"value"`
}

func (s *Server) createItem(c *gin.Context) {
	var input createItemInput
	err := c.BindJSON(&input)
	if err != nil {
		errId := s.logInternalError(err)
		c.JSON(http.StatusInternalServerError, gin.H{"errorId": errId})
		return
	}

	item, err := s.model.CreateItem(c.ClientIP(), input.Value)
	if err != nil {
		errId := s.logInternalError(err)
		c.JSON(http.StatusInternalServerError, gin.H{"errorId": errId})
		return
	}

	c.JSON(http.StatusOK, item)
}

// log the error and return its error id
func (s *Server) logInternalError(err error) string {
	errId := lib.RandString(12)
	s.logger.Error(fmt.Sprintf("%s: %s", errId, err))
	return errId
}
