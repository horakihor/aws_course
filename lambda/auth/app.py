import base64
import json
import os

def auth(event, context):

    method = event['methodArn']
    # Get authorization header in lowercase
    authorization_header = {k.lower(): v for k, v in event['headers'].items() if k.lower() == 'authorization'}
    print("authorization: " + json.dumps(authorization_header))

    # Get the username:password hash from the authorization header
    username_password_hash = authorization_header['authorization'].split()[1]
    print("username_password_hash: " + username_password_hash)

    username_password_hash = base64.b64decode(username_password_hash).decode('utf-8')
    username, password = username_password_hash.split(':')

    print("username: " + username)
    print("password: " + password)

    if username == os.environ['USERNAME'] and password == os.environ['PASSWORD']:
        effect = 'Allow'
    else:
        raise Exception('Unauthorized')

    return gen_policy(username, effect, method)


def gen_policy(principal_id, effect, resource):
    auth_resp = {}
    auth_resp['principalId'] = principal_id
    if effect and resource:
        policy_doc = {}
        policy_doc['Version'] = '2012-10-17'
        policy_doc['Statement'] = []
        statement = {}
        statement['Action'] = 'execute-api:Invoke'
        statement['Effect'] = effect
        statement['Resource'] = resource
        policy_doc['Statement'].append(statement)
        auth_resp['policyDocument'] = policy_doc
    return auth_resp
