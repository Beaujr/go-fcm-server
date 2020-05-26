# go-fcm-server

go-fcm-server is an basic HTTP webserver which accepts a FCM message in a JSON payload, and forwards to the Firebase Cloud Topic

```bash
curl -X POST \
  http://<host>:<port>/fcm/send/<topic> \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -d '{ "title": "<Title>", "body":"<Body>", "image": "<image>"}'
```

## Installation
```cmake
make docker_build
```

## Usage
Place your FCM service account key json within 
```sh
config/serviceAccountKey.json
```

## Contributing
Do whatever you want

## License
[MIT](https://choosealicense.com/licenses/mit/)