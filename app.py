import os
import random
from markupsafe import escape
from flask import Flask, render_template, url_for
import boto3


app = Flask(__name__)
port = os.getenv('PORT', '8000')
host = os.getenv('HOST', '0.0.0.0')
table_name = os.getenv('DYNAMODB')
profile_name = os.environ.get('AWS_PROFILE')
region_name = os.environ.get('AWS_REGION', 'eu-west-1')
db_client = boto3.client('dynamodb', region_name=region_name)


@app.route('/')
def root():
    item_count = db_client.scan(
        TableName=table_name, 
        Select='COUNT',
        # ConsistentRead=True
    )

    print(item_count)
    random_id = random.randint(1, item_count['Count'])
    print(random_id)

    resp = db_client.scan(
        TableName=table_name,
        IndexName='QuotationIndex',
        FilterExpression='ID = :a',
        ExpressionAttributeValues={
            ":a": {
                "N": str(random_id)
            },
        }
    )
    print(resp)

    quotation = resp['Items'][0]

    return render_template('quotation.html', quotation=quotation)


app.run(debug=False, host=host, port=port)