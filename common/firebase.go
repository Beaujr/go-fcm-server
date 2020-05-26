package common

import (
	"context"
	firebase "firebase.google.com/go"
	"firebase.google.com/go/messaging"
	"fmt"
	"google.golang.org/api/option"
	"log"
)

// GoReportClient is a struct which holds the Github client, context, and the User (token belongs to)
type FirebaseClient struct {
	*messaging.Client
}

func NewClient() *FirebaseClient {
	opt := option.WithCredentialsFile("config/serviceAccountKey.json")
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Panic(err)
	}

	client, err := app.Messaging(context.Background())
	if err != nil {
		log.Panic(err)
	}

	return &FirebaseClient{client}
}

func (c *FirebaseClient) SendToTopic(ctx context.Context, topic string, notification messaging.Notification) error {
	message := &messaging.Message{
		Notification: &notification,
		Topic:        topic,
	}

	// Send a message to the devices subscribed to the provided topic.
	response, err := c.Send(ctx, message)
	if err != nil {
		return err
	}

	fmt.Println("Successfully sent message:", response)
	return nil
}
