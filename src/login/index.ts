import {DynamoDB, GetItemCommand, PutItemCommand} from "@aws-sdk/client-dynamodb";
import * as joi from "joi";
import {responseFormatted} from "../response_utils";
import * as jwt from 'jsonwebtoken';
import {decrypt} from "../encryption";

const getLoginSchema = () => {
  return joi.object({
    name: joi.string().alphanum().required(),
    password: joi.string().alphanum().required()
  })
}
const getUserByName = (name: string) => {
  return {
    TableName: process.env.DYNAMODB_USERS_TABLE_NAME,
    Key: {
      name: {
        S: name,
      }
    },
    AttributesToGet: [ // AttributeNameList
      "password",
      "name"
    ],
  };
}

const setUserSession = (name: string, token: string) => {
  return {
    TableName: process.env.DYNAMODB_SESSIONS_TABLE_NAME,
    Item: {
      name: {
        S: name,
      },
      token: {
        S: token
      }
    }
  };
}

const handler = async (event: any) => {
  const {
    ENCRYPT_CODE,
    SIGN_SESSION,
    REGION,
  } = process.env
  if (!ENCRYPT_CODE || !SIGN_SESSION) {
    return responseFormatted(500, 'Env variables not defined')
  }
  let eventBody
  try {
    eventBody = JSON.parse(event.body);
  } catch (error) {
    console.log(error)
    return responseFormatted(500, "Error to parse name and password of user from body")
  }

  const {error: badFormatLoginRequest} = getLoginSchema().validate(eventBody)
  if (badFormatLoginRequest) {
    return responseFormatted(400, "User name and password are required");
  }

  const client = new DynamoDB({ region: REGION});
  const getUserCommand = new GetItemCommand(getUserByName(eventBody.name));
  const userFound = await client.send(getUserCommand);
  if (!userFound.Item?.password.S) {
    return responseFormatted(500, "User password not defined");
  }
  if (eventBody.password !== decrypt(userFound.Item?.password.S, ENCRYPT_CODE)) {
    return responseFormatted(403, "Wrong user name or password");
  }

  const token = jwt.sign({data: userFound.Item?.name.S}, SIGN_SESSION)
  const command = new PutItemCommand(setUserSession(eventBody.name, token));
  const user = await client.send(command);
  if (user.$metadata.httpStatusCode !== 200) {
    return responseFormatted(500, "Unexpected error when saving user session")
  }
  return responseFormatted(200, token);
}

exports.handler = handler