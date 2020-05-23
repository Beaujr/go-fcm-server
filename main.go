package main

import (
	"flag"
	"fmt"
	"github.com/beaujr/go-fcm-server/common"
	"github.com/beaujr/go-fcm-server/handlers"
	"github.com/gorilla/mux"
	"log"
	"net/http"
)
var port = flag.Int("port", 10001, "Set Port")

func main(){
	flag.Parse()
	fmt.Println(fmt.Sprintf("Server Started on Port:%d", *port))
	myRouter := mux.NewRouter().StrictSlash(true)
	firebaseClient := common.NewClient()
	myRouter.Handle("/send/{topic}", handlers.SendFCMTopicMessage(firebaseClient))

	err := http.ListenAndServe(fmt.Sprintf(":%d", *port), myRouter)
	if err != nil {
		log.Panic(err)
	}
}