import requests
import time
import json

# Define the Loki endpoint
loki_url = "http://localhost:32767/loki/api/v1/push"

# Create the current timestamp in nanoseconds
timestamp = str(int(time.time() * 1e9))

# Define the JSON payload
payload = {
    "streams": [
        {
            "stream": {
                "job": "test-job",
                "level": "info"
            },
            "values": [
                [timestamp, "This is a test log message"]
            ]
        }
    ]
}

# Send the log to Loki
headers = {
    "Content-Type": "application/json"
}
response = requests.post(loki_url, headers=headers, data=json.dumps(payload))

# Print the response
print(response.status_code, response.text)

