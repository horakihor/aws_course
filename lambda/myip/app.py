import json
import requests

def lambda_handler(event, context):
    try:
        ip = requests.get("http://checkip.amazonaws.com/")
    except requests.RequestException as e:
        print(e)
        raise e

    return {
        "statusCode": 200,
        "body": json.dumps({
            "Your public IP": ip.text.replace("\n", "")
        }),
    }
