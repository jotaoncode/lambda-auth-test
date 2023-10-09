import {DynamoDB, GetItemCommand, PutItemCommand} from "@aws-sdk/client-dynamodb";
import {Context} from "aws-lambda";
import {responseFormatted} from "../response_utils";
import {encrypt} from "../encryption";

const getUserByNamePass = (name: string) => {
  return {
    TableName: process.env.DYNAMODB_USERS_TABLE_NAME,
    Key: {
      name: {
        S: name,
      }
    },
    AttributesToGet: [
      "password"
    ],
  };
}
const createUser = (name: string, password: string) => {
  return {
    TableName: process.env.DYNAMODB_USERS_TABLE_NAME,
    Item: {
      name: {
        S: name,
      },
      password: {
        S: password
      }
    },
  };
}
const handler = async function (event: any) {
  if (!process.env.ENCRYPT_CODE) {
    return responseFormatted(400, "Not defined encrypt code env variable");
  }
  if (!event.headers || !event.headers.Authorization) {
    console.log('No event headers...', event.headers)
    return responseFormatted(400, "User name and password required");
  }

  const decodedString = Buffer.from(event.headers.Authorization.replace('Basic ', ''), 'base64').toString('utf-8');
  const [user, password] = decodedString.split(":")
  if (!user || !password) {
    return responseFormatted(400, "User name and password required");
  }

  const client = new DynamoDB({ region: process.env.REGION});
  const findUser = new GetItemCommand(getUserByNamePass(user));
  const existingUser = await client.send(findUser);
  if (existingUser.Item) {
    return responseFormatted(409, "User name should be unique");
  }

  const command = new PutItemCommand(createUser(user, encrypt(password, process.env.ENCRYPT_CODE)));
  const savedUser = await client.send(command);
  if (savedUser.$metadata.httpStatusCode !== 200) {
    return responseFormatted(500, "Internal error to save user on signup");
  }

  return {
    statusCode: 201
  };
}

exports.handler = handler