import json
import boto3


def lambda_handler(event, context):
    print(event)
    invoking_event = json.loads(event["invokingEvent"])
    print(invoking_event)
    rule_parameters = json.loads(event["ruleParameters"])
    print(rule_parameters)

    if not is_scheduled_notification(invoking_event):
        raise Exception(
            "Invoked for a notification other than Scheduled Notification... Ignoring.")

    try:
        config = boto3.client("config")

        account_id = event["accountId"]
        compliance, annotaiton = evaluate_compliance(rule_parameters["unaudited_users"])
        ordering_timestamp = invoking_event["notificationCreationTime"]

        config.put_evaluations(
            Evaluations=[
                {
                    'ComplianceResourceType': 'AWS::IAM::User',
                    'ComplianceResourceId': 'string',
                    'ComplianceType': compliance,
                    'Annotation': annotaiton,
                    'OrderingTimestamp': ordering_timestamp
                },
            ],
            ResultToken=event["resultToken"],
        )

    except Exception as e:
        print(e)
        raise e


def is_scheduled_notification(invoking_event):
    return invoking_event["messageType"] == "ScheduledNotification"


def evaluate_compliance(unaudited_users):
    iam = boto3.client("iam")
    response = iam.list_users()

    if len(response["Users"]) == 0:
        print("COMPLIANT: No IAM users exist.")
        return "COMPLIANT", "No IAM users exist."

    if is_unaudited_users_only(response["Users"], unaudited_users):
        print("COMPLIANT: Only unaudited users exist.")
        return "COMPLIANT", "Only unaudited users exist."

    print("NON_COMPLIANT: Some IAM users exist.")
    return "NON_COMPLIANT", "Some IAM users exist."


def is_unaudited_users_only(users, unaudited_users):
    for user in users:
        if user["UserName"] not in unaudited_users:
            return False

    return True
