import os.path
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

import base64
from apiclient import errors


def get_service(SCOPES):
    """Adapted from https://github.com/googleworkspace/python-samples/blob/main/gmail/quickstart/quickstart.py
        function to get service, fetch email through Gmail API
        Args:
            SCOPES: access setting to Gmail, see https://developers.google.com/identity/protocols/oauth2/scopes#gmail under Gmail API v1
            Also need token file: either have access to Gmail account or need token.json file in directory the get_attachment.py is located
        Return:
            service: instance to access message information
    """
    creds = None
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.json', 'w') as token:
            token.write(creds.to_json())

    try:
        # Call the Gmail API
        service = build('gmail', 'v1', credentials=creds)
        print('gmail', 'v1', 'service created successfully')
        return service

    except HttpError as error:
        print(f'An error occurred: {error}')
        return None


def get_subject(service, message):
    """get message subject
    Args:
        service: instance to access message information
        message: message information, see https://developers.google.com/gmail/api/reference/rest/v1/users.messages
    Return:
        subject: subject of the message
    adapted from: https://stackoverflow.com/questions/55144261/python-how-to-get-the-subject-of-an-email-from-gmail-api
    """
    messageheader = service.users().messages().get(userId="me", id=message["id"], format="full",
                                                   metadataHeaders=None).execute()
    headers = messageheader["payload"]["headers"]
    subject = [i['value'] for i in headers if i["name"] == "Subject"]
    return subject


def get_attachments(service, user_id, msg_id, store_dir=''):
    """Get and store attachment from Message with given id. Only gets data if they are attachments and not if they are
    in the body of the email.

    Args:
    service: Authorized Gmail API service instance.
    user_id: User's email address. The special value "me" can be used to indicate the authenticated user.
    msg_id: ID of Message containing attachment.
    store_dir: directory which is added to the attachment filename on saving

    adapted from: https://stackoverflow.com/questions/25832631/download-attachments-from-gmail-using-gmail-api
    """
    try:
        message = service.users().messages().get(userId=user_id, id=msg_id).execute()

        # check if message has info on attachments
        if 'parts' in message['payload']:
            for part in message['payload']['parts']:
                if 'attachmentId' in part['body']:
                    attachment = service.users().messages().attachments().get(userId=user_id,
                                                                              messageId=msg_id,
                                                                              id=part['body']['attachmentId']
                                                                              ).execute()
                    file_data = base64.urlsafe_b64decode(attachment['data'].encode('UTF-8'))
                    path = store_dir + part['filename']
                    with open(path, 'wb') as f:
                        f.write(file_data)
                        f.close
                    print('saved: ' + store_dir + part['filename'])

    except errors.HttpError as error:
        print('An error occurred: %s' % error)


if __name__ == '__main__':
    # If modifying these scopes, delete the file token.json.
    SCOPES = ['https://www.googleapis.com/auth/gmail.readonly']

    service = get_service(SCOPES)

    # get messages from service
    message_results = service.users().messages().list(userId='me').execute()
    messages = message_results.get('messages', [])

    # filter for messages with the subject test
    test = 'Your report is ready'

    # create directory in current directory where attachments are saved to
    # caution: if change directory name adjust name in t1_cav_to_sql.py
    current_dir = os.getcwd()
    dir_attachments = current_dir + '/t1_attachments/'
    if not os.path.exists(dir_attachments):
        os.makedirs(dir_attachments)

    for message in messages:
        subject = get_subject(service, message)
        if subject[0] == test:
            get_attachments(service, 'me', message['id'], dir_attachments)
        else:
            print('Message has wrong subject.')
            continue
