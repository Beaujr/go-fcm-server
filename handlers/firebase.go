package handlers

import (
	"context"
	"encoding/json"
	"firebase.google.com/go/messaging"
	"github.com/beaujr/go-fcm-server/common"
	"github.com/gorilla/mux"
	"net/http"
)

func SendFCMTopicMessage(client *common.FirebaseClient) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			w.WriteHeader(http.StatusMethodNotAllowed)
			return
		}

		topic := mux.Vars(r)["topic"]

		decoder := json.NewDecoder(r.Body)
		var t messaging.Notification
		err := decoder.Decode(&t)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		err = client.SendToTopic(context.Background(), topic, t)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		w.WriteHeader(http.StatusCreated)
		return
	})
}
