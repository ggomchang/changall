resource "aws_api_gateway_rest_api" "rest_api" {
  name = "wsi-api"
}

resource "aws_api_gateway_resource" "healthz" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "healthz"
}

resource "aws_api_gateway_method" "healthz_get" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.healthz.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "healthz_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.healthz.id
  http_method = aws_api_gateway_method.healthz_get.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({ "statusCode" : 200 })
  }
}

resource "aws_api_gateway_method_response" "helthz_get_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.healthz.id
  http_method = aws_api_gateway_method.healthz_get.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "healthz_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.healthz.id
  http_method = aws_api_gateway_method.healthz_get.http_method
  status_code = aws_api_gateway_method_response.helthz_get_response_200.status_code

  response_templates = {
    "application/json" = jsonencode({ "status" : "ok" })
  }
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
    "application/json" = jsonencode({
      "TableName" : "wsi-table",
      "Item" : {
        "name" : {
          "S" : "$input.path('$.name')"
        },
        "age" : {
          "N" : "$input.path('$.age')"
        },
        "country" : {
          "S" : "$input.path('$.country')"
        }
      }
    })
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

resource "aws_api_gateway_integration_response" "user_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.user.id
  http_method = aws_api_gateway_method.user_post.http_method
  status_code = aws_api_gateway_method_response.user_post_response_200.status_code

  response_templates = {
    "application/json" = jsonencode({ "msg" : "Finished" })
  }

  depends_on = [
    aws_api_gateway_integration.user_post_integration
  ]
}

resource "aws_api_gateway_method" "user_delete" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.user.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "user_delete_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.user.id
  http_method             = aws_api_gateway_method.user_delete.http_method
  integration_http_method = "POST"
  type                    = "AWS"

  uri         = "arn:aws:apigateway:ap-northeast-2:dynamodb:action/DeleteItem"
  credentials = aws_iam_role.api_gateway_res_api_role.arn

  request_templates = {
    "application/json" = jsonencode({
      "TableName" : "wsi-table",
      "Key" : {
        "name" : {
          "S" : "$input.params('name')"
        }
      }
    })
  }
}

resource "aws_api_gateway_method_response" "user_delete_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.user.id
  http_method = aws_api_gateway_method.user_delete.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "user_delete_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.user.id
  http_method = aws_api_gateway_method.user_delete.http_method
  status_code = aws_api_gateway_method_response.user_delete_response_200.status_code

  response_templates = {
    "application/json" = jsonencode({ "msg" : "Deleted" })
  }

  depends_on = [
    aws_api_gateway_integration.user_delete_integration
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
      "TableName" : "wsi-table",
      "Key" : {
        "name" : {
          "S" : "$input.params('name')"
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
      "name": "$input.path('$.Item.name.S')",
      "age": "$input.path('$.Item.age.N')",
      "country": "$input.path('$.Item.country.S')"
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
    aws_api_gateway_integration_response.healthz_get_integration_response,
    aws_api_gateway_integration_response.user_post_integration_response,
    aws_api_gateway_integration_response.user_delete_integration_response,
    aws_api_gateway_integration_response.user_get_integration_response
  ]
}
