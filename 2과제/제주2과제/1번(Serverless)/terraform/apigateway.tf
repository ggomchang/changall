resource "aws_api_gateway_rest_api" "rest_api" {
  name = "serverless-api-gw"
}

resource "aws_api_gateway_resource" "user" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "user"
}

resource "aws_api_gateway_method" "user_post" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.user.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "user_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.user.id
  http_method             = aws_api_gateway_method.user_post.http_method
  integration_http_method = "POST"
  type                    = "AWS"

  uri         = "arn:aws:apigateway:ap-northeast-2:dynamodb:action/PutItem"
  credentials = aws_iam_role.api_gateway_res_api_role.arn

  request_templates = {
    "application/json" = <<EOF
      #if($input.params('id').contains('admin'))
      {
        
      }
      #else
      {
        "TableName" : "serverless-user-table",
        "Item" : {
          "id" : {
            "S" : "$input.params('id')"
          },
          "age" : {
            "S" : "$input.params('age')"
          },
          "company" : {
            "S" : "$input.params('company')"
          }
        }
      }
      #end
      EOF
  }
}

resource "aws_api_gateway_method_response" "user_post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.user.id
  http_method = aws_api_gateway_method.user_post.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "user_post_response_500" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.user.id
  http_method = aws_api_gateway_method.user_post.http_method
  status_code = "500"

  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_integration_response" "user_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.user.id
  http_method = aws_api_gateway_method.user_post.http_method
  status_code = aws_api_gateway_method_response.user_post_response_200.status_code

  response_templates = {
    "application/json" = jsonencode({ "msg" : "Success insert data" })
  }

  depends_on = [
    aws_api_gateway_integration.user_post_integration
  ]
}

resource "aws_api_gateway_integration_response" "user_post_integration_response_500" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.user.id
  http_method = aws_api_gateway_method.user_post.http_method
  status_code = aws_api_gateway_method_response.user_post_response_500.status_code

  response_templates = {
    "application/json" = <<EOF
    {
      "message": "Internal server error"
    }
    EOF
  }

  selection_pattern = ".*400"
  depends_on = [
    aws_api_gateway_integration.user_post_integration
  ]
}


resource "aws_api_gateway_method" "user_get" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.user.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "user_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.user.id
  http_method             = aws_api_gateway_method.user_get.http_method
  integration_http_method = "POST"
  type                    = "AWS"

  uri         = "arn:aws:apigateway:ap-northeast-2:dynamodb:action/GetItem"
  credentials = aws_iam_role.api_gateway_res_api_role.arn

  request_templates = {
    "application/json" = jsonencode({
      "TableName" : "serverless-user-table",
      "Key" : {
        "id" : {
          "S" : "$input.params('id')"
        }
      }
    })
  }
}

resource "aws_api_gateway_integration_response" "user_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.user.id
  http_method = aws_api_gateway_method.user_get.http_method
  status_code = aws_api_gateway_method_response.user_get_response_200.status_code

  response_templates = {
    "application/json" = <<EOF
    {
      "id": "$input.path('$.Item.id.S')",
      "age": "$input.path('$.Item.age.S')",
      "company": "$input.path('$.Item.company.S')"
    }
    EOF
  }

  depends_on = [
    aws_api_gateway_integration.user_get_integration
  ]
}

resource "aws_api_gateway_method_response" "user_get_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.user.id
  http_method = aws_api_gateway_method.user_get.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = "v1"

  depends_on = [
    aws_api_gateway_integration_response.user_post_integration_response,
    aws_api_gateway_integration_response.user_get_integration_response,
    aws_api_gateway_integration_response.user_post_integration_response_500
  ]
}
