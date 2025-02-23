#!/bin/bash

AWS_SSO_PROFILE=""
AWS_SSO_PROFILE_X_COMMAND=""
PROFILE_SECTION_NAME="" # Initialize PROFILE_SECTION_NAME
EXPORT_AS_DEFAULT=false # Flag to track --export-as-default

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      AWS_SSO_PROFILE="$2"
      AWS_SSO_PROFILE_X_COMMAND="--profile $2"
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

CREDENTIALS_FILE="$HOME/.aws/credentials"

# Determine PROFILE_SECTION_NAME based on --export-as-default and --profile
if [[ "$EXPORT_AS_DEFAULT" == "true" ]]; then
  PROFILE_SECTION_NAME="default"
else
  PROFILE_SECTION_NAME="${AWS_SSO_PROFILE:-default}" # Use AWS_SSO_PROFILE or default if empty
fi

echo "Cleaning AWS credentials section [$PROFILE_SECTION_NAME] in $CREDENTIALS_FILE"

# Check if credentials file exists
if [ ! -f "$CREDENTIALS_FILE" ]; then
  echo "Warning: Credentials file $CREDENTIALS_FILE not found. No cleaning needed."
  exit 0
fi

# Find the line number of the profile section header
SECTION_START_LINE=$(grep -n "^\[$PROFILE_SECTION_NAME\]" "$CREDENTIALS_FILE" | cut -d':' -f1)

if [ -z "$SECTION_START_LINE" ]; then
  echo "Warning: Profile section [$PROFILE_SECTION_NAME] not found in $CREDENTIALS_FILE. No cleaning needed."
  exit 0
fi

# Find the line number of the next section header after the current one
NEXT_SECTION_START_LINE=$(sed -n "/^\[$PROFILE_SECTION_NAME\]/,\$p" "$CREDENTIALS_FILE" | grep -n "^\[" | tail -n +2 | head -n 1 | cut -d':' -f1)

# Construct sed command to delete the section
if [ -n "$NEXT_SECTION_START_LINE" ]; then
  # Delete from the start of the section to the line before the next section
  SED_COMMAND="sed -i '${SECTION_START_LINE},$(($NEXT_SECTION_START_LINE - 1))d' \"$CREDENTIALS_FILE\""
else
  # Delete from the start of the section to the end of the file
  SED_COMMAND="sed -i '${SECTION_START_LINE},\$d' \"$CREDENTIALS_FILE\""
fi

# Execute the sed command
if eval "$SED_COMMAND"; then
  echo "Successfully cleaned credentials section: [$PROFILE_SECTION_NAME]"
else
  echo "Error: Failed to clean credentials section [$PROFILE_SECTION_NAME] in $CREDENTIALS_FILE."
  exit 1
fi


unset AWS_SSO_PROFILE
unset AWS_SSO_PROFILE_X_COMMAND
unset PROFILE_SECTION_NAME
unset EXPORT_AS_DEFAULT
unset CREDENTIALS_FILE

exit 0