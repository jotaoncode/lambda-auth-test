## Lambda framework basic login

The current implementation defines 2 lambda functions with a login and a signup with the goal of calling the signup and saving the user and password, and when calling the login will provide the given user token for the existing user.

Information is being saved in Dynamo DB.

### Requirements

An account of AWS or using localstack.

With the given credentials , access key / secret key, fill those values inside of the file providers.tf

### Deploy

Install dependencies

```sh 
yarn install
```

Build the lambda functions

```sh
yarn build
```

Initial Deploy to aws (initially it is running with a parallelism of 1, later can be run with yarn deploy normally)
```sh
yarn initial_deploy
```

### Manual Test

Signup the user:
```sh
curl -X POST https://juan:qwerqwer@<RESOURCE_CREATED_GATEWAY_API>/signup
```
Result expected is a 201 from the gateway of the signup of the user


Login the user:
```sh
curl -X POST -d '{"name": <USERNAME>, "password": <PASSWORD>}' --header "Content-Type: application/json" https://<RESOURCE_CREATED_GATEWAY_API>/login
```
Result expected the token to be consider for the frontend

### TODOs

- OpenAPI reference as a bonus.
- Remove parallelism 1, and check terraform configurations.
- Provide jest with supertest against a localstack instance exposed using docker.
- Create a folder for realeases for .zip files.
- Consider a terraform folder or something to have less files on the root level
- Credentials should be provided without using the provider file