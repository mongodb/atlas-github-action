#!/usr/bin/env bash

# Copyright 2025 MongoDB Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ -z "$MONGODB_ATLAS_PUBLIC_API_KEY" ]; then
  echo "MONGODB_ATLAS_PUBLIC_API_KEY env var is not set"
  exit 1
fi
if [ -z "$MONGODB_ATLAS_PRIVATE_API_KEY" ]; then
  echo "MONGODB_ATLAS_PRIVATE_API_KEY env var is not set"
  exit 1
fi
if [ -z "$MONGODB_ATLAS_ORG_ID" ]; then
  echo "MONGODB_ATLAS_ORG_ID env var is not set"
  exit 1
fi
if [ -z "$CLIENT_ID" ]; then
  echo "CLIENT_ID env var is not set"
  exit 1
fi

output=$(
    curl --user "${MONGODB_ATLAS_PUBLIC_API_KEY}:${MONGODB_ATLAS_PRIVATE_API_KEY}" \
    --digest \
    --header "Accept: application/vnd.atlas.2025-03-12+json" \
    --header "Content-Type: application/json" \
    -X DELETE "https://cloud.mongodb.com/api/atlas/v2/orgs/${MONGODB_ATLAS_ORG_ID}/serviceAccounts/${CLIENT_ID}"
)
error_code=$(echo "$output" | jq -r '.error')

if [ "$error_code" -ge 300 ]; then
  echo "Failed to delete service account with Client ID $CLIENT_ID. Response:"
  echo "$output"
  exit 1
else
  echo "Service account with Client ID $CLIENT_ID has been deleted successfully."
fi
