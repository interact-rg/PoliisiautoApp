import requests
from faker import Faker

#Creates fake users and organizations for the database, when POST methods are implemented for Students and Teachers those should be added here

#change this depending on where the server is installed
url = "https://add3.fi/api/v1/register"

headers = {
    "Accept": "application/json",
}

#insert bearer token here!
headers_organizations = {
    "Accept": "application/json",
    "Authorization": "Bearer Your_Bearer_Token_Here",
}

# Number of users and organizations to create

num_users = 10
num_organizations = 10

fake = Faker()

for _ in range(num_users):
    user_data = {
        "first_name": fake.first_name(),
        "last_name": fake.last_name(),
        "email": fake.email(),
        "password": salasana,
        "password_confirmation": salasana,
        "device_name": fake.word() + " phone",
    }

    response = requests.post(url, headers=headers, data=user_data)

    if response.status_code == 200:
        print(f"User registered successfully: {user_data['email']}")
    else:
        print(f"Error registering user {user_data['email']}. Status code: {response.status_code}")
        print(response.text)

for _ in range(num_organizations):
    organization_data = {
        "name": fake.company(),
        "street_address": fake.street_address(),
        "city": fake.city(),
        "zip": fake.zipcode(),
    }

    response = requests.post(url_organizations, headers=headers_organizations, data=organization_data)

    if response.status_code == 200:
        print(f"Organization stored successfully: {organization_data['name']}")
    else:
        print(f"Error storing organization {organization_data['name']}. Status code: {response.status_code}")
        print(response.text)