# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START gmail_quickstart]
from __future__ import print_function

import os.path

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError




def get_service(SCOPES):
    """Adapted from https://github.com/googleworkspace/python-samples/blob/main/gmail/quickstart/quickstart.py
        function to get service, fetch email through Gmail API
        Args:
            SCOPES: access setting to Gmail, see https://developers.google.com/identity/protocols/oauth2/scopes#gmail under Gmail API v1
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
        # TODO(developer) - Handle errors from gmail API.
        print(f'An error occurred: {error}')
        return None


def fetchMessage(service, message):
    messageheader = service.users().messages().get(userId="me", id=message["id"], format="full",
                                                   metadataHeaders=None).execute()
    headers = messageheader["payload"]["headers"]
    subject = [i['value'] for i in headers if i["name"] == "Subject"]
    return subject


if __name__ == '__main__':
    # If modifying these scopes, delete the file token.json.
    SCOPES = ['https://www.googleapis.com/auth/gmail.readonly']
    service = get_service(SCOPES)
    results = service.users().labels().list(userId='me').execute()
    labels = results.get('labels', [])
    message_results = service.users().messages().list(userId='me').execute()
    messages = message_results.get('messages', [])

    test='Your report is ready'

    print('email id:')
    for message in messages:
        print(message['id'])
        subject= fetchMessage(service, message) 
        if subject[0] == test:
            print(subject)
        else:
            print('not right subject')
            continue
# [END gmail_quickstart]
