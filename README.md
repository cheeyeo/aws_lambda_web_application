### AWS LAMBDA EXAMPLE

Quotes:

https://www.goodreads.com/author/quotes/1429989.Richard_P_Feynman?page=2



##### DYNAMODB

https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-dynamo-db.html#http-api-dynamo-db-create-function


https://docs.aws.amazon.com/code-library/latest/ug/python_3_dynamodb_code_examples.html







Research into running a web app on AWS LAMBDA

ref: 

https://thekevinwang.com/2022/04/25/any-web-app-on-lambda/

https://github.com/awslabs/aws-lambda-web-adapter

https://www.docker.com/blog/containerized-python-development-part-1/

https://itnext.io/using-aws-lambda-function-url-to-build-a-serverless-backend-for-slack-a292ef355a5d


GUIDE TO BUILD PYTHON IMAGES USING MULTI-STAGE AND VENV WHICH WORKS WITH LAMBDA:
https://luis-sena.medium.com/creating-the-perfect-python-dockerfile-51bdec41f1c8



BETTER GUIDE FOR LAMBDA DOCKER APPS + API GATEWAY:

https://aws.amazon.com/blogs/architecture/field-notes-three-steps-to-port-your-containerized-application-to-aws-lambda/



WAYPOINT TO DEPLOY APPS:
https://www.waypointproject.io/








### IAM ROLES FOR LAMBDA

Assuming lambda role name is `lambda-ex`

```
aws iam create-role --role-name lambda-ex --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```


# Using aws ecr credentials helpers
https://github.com/awslabs/amazon-ecr-credential-helper

Only need to create ~/.docker/config.json with
```
{
	"credsStore": "ecr-login"
}
```

docker push/pull should just work without needing to run `aws ecr get-login-password ...`


```
export FUNCTION_NAME=python-app
export ACCOUNT_ID=432271807077
export REPOSITORY=python-lambda-test
export TAG=latest

aws lambda create-function \
  --region us-east-1 \
  --package-type Image \
  --function-name $FUNCTION_NAME \
  --code ImageUri=$ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$REPOSITORY:$TAG \
  --role arn:aws:iam::$ACCOUNT_ID:role/lambda-ex

# BELOW CREATES AN API GATEWAY
# NOTE: IT ADDS A GREEDY ROUTE TO /{proxy+} which allows for / and /foobar

aws apigatewayv2 create-api \
  --region us-east-1 \
  --name python-app \
  --protocol-type HTTP \
  --target arn:aws:lambda:us-east-1:432271807077:function:python-app \
  --route-key "GET /{proxy+}" \
  --query "{ApiEndpoint: ApiEndpoint, ApiId: ApiId}" \
  --output json


export API_ENDPOINT="https://n3ine000w9.execute-api.us-east-1.amazonaws.com"
export API_ID="n3ine000w9"

aws lambda add-permission \
  --region us-east-1 \
  --statement-id invoice-generator-api \
  --action lambda:InvokeFunction \
  --function-name arn:aws:lambda:us-east-1:432271807077:function:python-app \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:us-east-1:432271807077:$API_ID/*/*/{proxy+}"

===============================================================================

# BELOW CREATES A LAMBDA FUNCTION URL RESOURCE ...
aws lambda create-function-url-config \
  --region us-east-1 \
  --function-name python-app \ 
  --auth-type NONE

aws lambda add-permission \
    --region us-east-1 \
    --function-name python-app \
    --action lambda:InvokeFunctionUrl \
    --statement-id FunctionURLAllowPublicAccess \
    --principal "*" \
    --function-url-auth-type NONE
```