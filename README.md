### AWS LAMBDA Web App 


[AWS Lambda Web Adapter]: https://github.com/awslabs/aws-lambda-web-adapter
[Quotations]: https://www.goodreads.com/author/quotes/1429989.Richard_P_Feynman?page=1


Example of building and running Flask web application on AWS Lambda using [AWS Lambda Web Adapter]

The web application returns a random quotation on each page refresh. The [Quotations] are by physicist Richard Feynmann.


### Deployment

The stack used include:

* AWS Lambda
* AWS DynamoDB
* Python Flask
* Docker


The terraform to create the infra is in **terraform_files**. Note that it currently creates the ECR repo but since we are also deploying the lambda as an image, it will error. Still trying to work round that issue...

```
terraform -chdir=terraform_files init

terraform -chdir=terraform_files plan -out=tfplan

terraform -chdir=terraform_files apply tfplan
```

To seed the database, the provided **quotes.csv** file has a sample 11 quotes:
```
python aws_dynamodb.py --csv quotes.csv
```

Note the ECR url as you will need to build and push the image to ECR manually.

To view the application, use the function url in the output
e.g. https://XXXXX.lambda-url.eu-west-1.on.aws/



### Development

To run locally, it uses docker compose:
```
docker compose up

docker compose down
```

To run automatic rebuild:
```
docker compose watch
```

Visit the application by visiting http://localhost:7531


### References
- [AWS ECR Credential helper]: https://github.com/awslabs/amazon-ecr-credential-helper
- [Run any web app on Lambda]: https://thekevinwang.com/2022/04/25/any-web-app-on-lambda/
- [Lambda Docker apps]: https://aws.amazon.com/blogs/architecture/field-notes-three-steps-to-port-your-containerized-application-to-aws-lambda/
- [Python multi-stage build]: https://luis-sena.medium.com/creating-the-perfect-python-dockerfile-51bdec41f1c8
- [Applied Lambda docker apps]: https://itnext.io/using-aws-lambda-function-url-to-build-a-serverless-backend-for-slack-a292ef355a5d
- [Containerized python development]: https://www.docker.com/blog/containerized-python-development-part-1/
