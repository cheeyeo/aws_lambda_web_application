import os
import random
import signal
import sys
import time
import logging
from markupsafe import escape
from flask import Flask, render_template, url_for
import boto3


default_log_args = {
    "level": logging.DEBUG if os.environ.get("DEBUG", False) else logging.INFO,
    "format": "%(asctime)s [%(levelname)s] %(name)s - %(message)s",
    "datefmt": "%d-%b-%y %H:%M",
    "force": True,
}
logging.basicConfig(**default_log_args)
logger = logging.getLogger()


app = Flask(__name__)
port = os.getenv('PORT', '8000')
host = os.getenv('HOST', '0.0.0.0')
table_name = os.getenv('DYNAMODB')
index_name = os.getenv('DYNAMODB_INDEX')
profile_name = os.getenv('AWS_PROFILE')
region_name = os.getenv('AWS_REGION', 'eu-west-1')
db_client = boto3.client('dynamodb', region_name=region_name)


def exit_gracefully(signum, frame):
    r"""
    SIGTERM Handler: https://docs.aws.amazon.com/lambda/latest/operatorguide/static-initialization.html
    Listening for os signals that can be handled,reference: https://docs.aws.amazon.com/lambda/latest/dg/runtimes-extensions-api.html
    Termination Signals: https://www.gnu.org/software/libc/manual/html_node/Termination-Signals.html
    """
    logger.info("[runtime] SIGTERM received")

    logger.info("[runtime] cleaning up")
    # perform actual clean up work here.
    time.sleep(0.2)

    logger.info("[runtime] exiting")
    sys.exit(0)


signal.signal(signal.SIGTERM, exit_gracefully)


@app.route('/')
def root():
    item_count = db_client.scan(
        TableName=table_name, 
        Select='COUNT',
        # ConsistentRead=True
    )

    logger.info(f"ITEMS COUNT: {item_count}")
    random_id = random.randint(1, item_count['Count'])
    logger.info(f"RANDOM ID: {random_id}")

    resp = db_client.scan(
        TableName=table_name,
        IndexName=index_name,
        FilterExpression='ID = :a',
        ExpressionAttributeValues={
            ":a": {
                "N": str(random_id)
            },
        }
    )
    logger.info(resp)
    quotation = resp['Items'][0]

    return render_template('quotation.html', quotation=quotation)


app.run(debug=False, host=host, port=port)