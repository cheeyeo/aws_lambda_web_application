# Uses boto3 to insert quotations into table

import os
from datetime import datetime
import random
import argparse
import pandas
import boto3
import boto3.session



def format_row(row):
    """
    Format row for ingestion into DynamoDB
    """

    return {
        'PutRequest': {
            'Item': {
                'ID': {
                    'N': str(row['ID'])
                },
                'Author': {
                    'S': row['Author']
                },
                'Quotation': {
                    'S': row['Quotation']
                }
            } 
        }
    }


def seed_data(client, db_name, filename):
    """
    Seeds the given db name with initial data
    """

    df = pandas.read_csv(filename)
    # print(data.head())
    df = df.apply(lambda row: format_row(row), axis=1)

    # TODO: Make async for parallel processing?
    # since pandas is column-major format, we convert to numpy then to list for row format...
    resp = client.batch_write_item(
        RequestItems={
            db_name: df[:].to_numpy().tolist()
        }
    )

    print(resp)


def test_query(client, db_name):
    # Query DynamoDB table to get num of items
    item_count = dynamodb_client.scan(
        TableName=table_name, 
        Select='COUNT',
        # ConsistentRead=True
    )
    print(item_count)
    random_id = random.randint(1, item_count['Count'])
    print(random_id)

    resp = dynamodb_client.scan(
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


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv", type=str, required=True, help="Path to seed CSV file")
    args, _ = ap.parse_known_args()

    table_name = os.environ.get('DYNAMODB')
    profile_name = os.environ.get('AWS_PROFILE')
    region_name = os.environ.get('AWS_REGION')

    sess = boto3.session.Session(profile_name=profile_name, region_name=region_name)

    dynamodb_client = sess.client('dynamodb')
    seed_data(dynamodb_client, db_name=table_name, filename=args.csv)