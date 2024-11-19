import {DynamoDBClient} from "@aws-sdk/client-dynamodb";
import {DynamoDBDocumentClient, GetCommand} from "@aws-sdk/lib-dynamodb";
import {APIGatewayProxyEvent, APIGatewayProxyResult} from "aws-lambda";

const tableName = "gotech_world_movies";

type Movie = {
    title: string;
    rating: number;
    id: string;
    genres: string[];
}

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    console.log("Getting first movie.");

    const client = new DynamoDBClient({});
    const docClient = DynamoDBDocumentClient.from(client);

    const command = new GetCommand({
        TableName: tableName,
        Key: {
            ID: "1",
        },
    });

    try {
        const dynamoResponse = await docClient.send(command);

        if (!dynamoResponse?.Item) {
            return {
                statusCode: 404,
                body: JSON.stringify({
                    message: "Movie not found",
                }),
            };
        }

        const body: Movie = {
            title: dynamoResponse.Item.Title,
            rating: dynamoResponse.Item.Rating,
            id: dynamoResponse.Item.ID,
            genres: []
        };

        body.genres = Array.from(dynamoResponse.Item.Genres);

        return {
            statusCode: 200,
            body: JSON.stringify(body),
        };
    } catch (e: any) {
        console.log(e);

        return {
            statusCode: 500,
            body: JSON.stringify({
                message: e.message,
            }),
        };
    }
};
