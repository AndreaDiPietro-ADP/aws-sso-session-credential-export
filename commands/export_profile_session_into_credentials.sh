#!/bin/bash

AWS_SSO_PROFILE=""
AWS_SSO_PROFILE_X_COMMAND=""
PROFILE_SECTION_NAME="" # Initialize PROFILE_SECTION_NAME
EXPORT_AS_DEFAULT=false # Flag to track --export-as-default

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      AWS_SSO_PROFILE="$2"
      AWS_SSO_PROFILE_X_COMMAND=" --profile $2"
      shift 2
      ;;
    --export-as-default)
      EXPORT_AS_DEFAULT=true
      shift 1
      ;;
    *)
      break  # Stop processing options if not recognized
      ;;
  esac
done

CREDENTIALS_OUTPUT=$(aws configure $AWS_SSO_PROFILE_X_COMMAND export-credentials)

if [ $? -ne 0 ]; then
  echo "Error: aws configure export-credentials command failed."
  exit 1
fi

# Parse JSON output using jq
ACCESS_KEY_ID=$(echo "$CREDENTIALS_OUTPUT" | jq -r '.AccessKeyId')
SECRET_ACCESS_KEY=$(echo "$CREDENTIALS_OUTPUT" | jq -r '.SecretAccessKey')
SESSION_TOKEN=$(echo "$CREDENTIALS_OUTPUT" | jq -r '.SessionToken')
EXPIRATION=$(echo "$CREDENTIALS_OUTPUT" | jq -r '.Expiration')


if [ -z "$ACCESS_KEY_ID" ] || [ -z "$SECRET_ACCESS_KEY" ] || [ -z "$SESSION_TOKEN" ] || [ -z "$EXPIRATION" ]; then
  echo "Error: Failed to parse credentials from aws configure export-credentials output."
  echo "Output was:"
  echo "$CREDENTIALS_OUTPUT"
  exit 1
fi

CREDENTIALS_FILE="$HOME/.aws/credentials"

# Determine PROFILE_SECTION_NAME based on --export-as-default and --profile
if [[ "$EXPORT_AS_DEFAULT" == "true" ]]; then
  PROFILE_SECTION_NAME="default"
else
  PROFILE_SECTION_NAME="${AWS_SSO_PROFILE:-default}" # Use AWS_SSO_PROFILE or default if empty
fi

echo "Updating AWS credentials in $CREDENTIALS_FILE for section: [$PROFILE_SECTION_NAME]"

# Check if credentials file exists, if not, create it
if [ ! -f "$CREDENTIALS_FILE" ]; then
  touch "$CREDENTIALS_FILE"
fi

# Use sed to update or create the profile section
sed -i -e "/^\[$PROFILE_SECTION_NAME\]/,/^\[/\"
{
  /^\[$PROFILE_SECTION_NAME\]/b
  /^aws_access_key_id=/c\\aws_access_key_id=$ACCESS_KEY_ID
  /^aws_secret_access_key=/c\\aws_secret_access_key=$SECRET_ACCESS_KEY
  /^aws_session_token=/c\\aws_session_token=$SESSION_TOKEN
  /^aws_session_expiration=/c\\aws_session_expiration=$EXPIRATION
  b
  :end
}\" "$CREDENTIALS_FILE" || {
    echo "INFO: Profile section [$PROFILE_SECTION_NAME] not found, appending to file."
    printf "\n[%s]\naws_access_key_id=%s\naws_secret_access_key=%s\naws_session_token=%s\n" "$PROFILE_SECTION_NAME" "$ACCESS_KEY_ID" "$SECRET_ACCESS_KEY" "$SESSION_TOKEN" >> "$CREDENTIALS_FILE"
  }

echo ""
echo "$CREDENTIALS_FILE updated."
echo ""
echo "Profile [$PROFILE_SECTION_NAME] Session Expiration: $EXPIRATION"

unset AWS_SSO_PROFILE
unset AWS_SSO_PROFILE_X_COMMAND
unset PROFILE_SECTION_NAME
unset EXPORT_AS_DEFAULT
unset CREDENTIALS_OUTPUT
unset ACCESS_KEY_ID
unset SECRET_ACCESS_KEY
unset SESSION_TOKEN
unset EXPIRATION
unset CREDENTIALS_FILE

exit 0