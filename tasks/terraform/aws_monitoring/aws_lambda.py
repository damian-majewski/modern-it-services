import json
import os
import requests

SERVICE_NOW_INSTANCE = os.environ['SERVICE_NOW_INSTANCE']
SERVICE_NOW_USERNAME = os.environ['SERVICE_NOW_USERNAME']
SERVICE_NOW_PASSWORD = os.environ['SERVICE_NOW_PASSWORD']

def lambda_handler(event, context):
    message = event['Records'][0]['Sns']['Message']
    alarm_data = json.loads(message)

    create_service_now_incident(alarm_data)

def create_service_now_incident(alarm_data):
    url = f"https://{SERVICE_NOW_INSTANCE}.service-now.com/api/now/table/incident"

    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json"
    }

    auth = (SERVICE_NOW_USERNAME, SERVICE_NOW_PASSWORD)

    incident_data = {
        "short_description": alarm_data["AlarmName"],
        "description": alarm_data["NewStateReason"],
        "impact": "3",
        "urgency": "3",
    }

    response = requests.post(url, json=incident_data, headers=headers, auth=auth)

    if response.status_code != 201:
        raise Exception(f"Failed to create incident in ServiceNow. Status code: {response.status_code}")
