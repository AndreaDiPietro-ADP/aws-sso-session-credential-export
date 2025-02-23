#!/bin/bash

COMMAND="$1"
shift

# Help function
print_help() {
  echo "Usage: aws-sso-helper <command> [options]"
  echo ""
  echo "Requires the AWS CLI (AWS CLI v2) to be installed and configured with the 'aws sso' plugin."
  echo ""
  echo "Commands:"
  echo "  help                Show this help information."
  echo "  sso-login           Perform aws sso login and export the profile session credentials."
  echo "  export-session-credentials  Export AWS SSO credentials to credentials file."
  echo "  sso-logout          Perform aws sso logout and clean the profile session credentials."
  echo "  clean-session-credentials   Clean AWS SSO credentials from credentials file."
  echo ""
  echo "Options for sso-login, export-credentials, sso-logout, and clean-credentials:"
  echo "  --profile <profile_name>  Specify the AWS SSO profile to be used for retrieving the session access or for the logout."
  echo "  --export-as-default     Export 'aws_access_key_id', 'aws_secret_access_key', 'aws_session_token' in the  ~/.aws/credentials inside the 'default' profile section instead of the one specified by the --profile option."
}

AWS_SSO_PROFILE=""
EXPORT_AS_DEFAULT=false # Flag to track --export-as-default

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      AWS_SSO_PROFILE="$2"
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

# Function to prepare options for export_credentials_profile
prepare_export_clean_credentials_options() {
  local profile_option=""
  local export_as_default_flag=""

  if [[ -n "$AWS_SSO_PROFILE" ]]; then
    profile_option=" --profile $AWS_SSO_PROFILE"
  fi
  if [[ "$EXPORT_AS_DEFAULT" == "true" ]]; then
    export_as_default_flag=" --export-as-default"
  fi
  echo "$profile_option $export_as_default_flag"
}

# Function to prepare options for aws sso login
prepare_sso_login_logout_options() {
  local profile_option=""
  if [[ -n "$AWS_SSO_PROFILE" ]]; then
    profile_option=" --profile $AWS_SSO_PROFILE"
  fi
  echo "$profile_option"
}

call_export_sso_session_credentials() {
  # Prepare options for export credentials
  echo ""
  echo "Performing export of the session credentials wit: $(prepare_export_clean_credentials_options)"
  commands/export_profile_session_into_credentials.sh $(prepare_export_clean_credentials_options)
}

call_clean_sso_session_credentials() {
  echo ""
  echo "Performing clean of the session credentials with: $(prepare_export_clean_credentials_options)"
  commands/clean_export_profile_session_from_credentials.sh $(prepare_export_clean_credentials_options)
}

is_aws_cli_installed() {
  if ! command -v aws &> /dev/null; then
    echo "Error: The 'aws' command-line tool is not installed or not in your PATH."
    echo "Please ensure the AWS CLI is installed and configured correctly."
    exit 127
  fi
}

case "$COMMAND" in
  help)
    print_help
    ;;
  sso-login)
    is_aws_cli_installed

    echo ""
    echo "Performing aws sso login: $(prepare_sso_login_logout_options)"
    aws sso login $(prepare_sso_login_logout_options)

    if [ $? -ne 0 ]; then
      echo "  Error: aws sso login command failed."
      exit 1
    fi

    call_export_sso_session_credentials
    ;;
  export-session-credentials)
    is_aws_cli_installed

    call_export_sso_session_credentials
    ;;
  sso-logout)
    is_aws_cli_installed

    echo ""
    echo "Performing: aws sso logout $(prepare_sso_login_logout_options)"
    aws sso logout $(prepare_sso_login_logout_options)

    if [ $? -ne 0 ]; then
      echo "  Error: aws sso logout command failed."
      exit 1
    fi

    echo ""
    echo "Performing cleaning of the session credentials"
    call_clean_sso_session_credentials
    ;;
  clean-session-credentials)
    is_aws_cli_installed

    echo ""
    echo "Performing cleaning of the session credentials"
    call_clean_sso_session_credentials
    ;;
  '')
    echo "Choose a command to run"
    echo "=============================="
    print_help
    exit 0
    ;;
  *)
    echo "Error: Unknown command '$COMMAND'"
    print_help
    exit 1
    ;;

esac

unset COMMAND
unset AWS_SSO_PROFILE
unset EXPORT_AS_DEFAULT

exit 0