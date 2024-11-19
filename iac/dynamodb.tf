resource "aws_dynamodb_table" "movies" {
  name           = "gotech_world_movies"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "scott_pilgrim" {
  table_name = aws_dynamodb_table.movies.name
  hash_key   = aws_dynamodb_table.movies.hash_key
  range_key  = aws_dynamodb_table.movies.range_key

  item = jsonencode(
    {
      ID    = { S = "1" },
      Title = { S = "Scott Pilgrim vs. the World" },
      Genres = {
        SS = [
          "Action",
          "Comedy",
        ]
      },
      Rating = { N = "7.5" }
    }
  )
}