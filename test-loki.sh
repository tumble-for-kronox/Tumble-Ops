#!/bin/bash

# Define the Loki endpoint
LOKI_URL="http://localhost:32767/loki/api/v1/push"

# Create the current timestamp in nanoseconds
TIMESTAMP=$(date +%s%N)

# Define the JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
  "streams": [
    {
      "stream": {
        "job": "test-job",
        "level": "info"
      },
      "values": [
        ["$TIMESTAMP", "This is a test log message"]
      ]
    }
  ]
}
EOF
)

# Send the log to Loki
curl -X POST "$LOKI_URL" \
   -H "Content-Type: application/json" \
   -d "$JSON_PAYLOAD"

