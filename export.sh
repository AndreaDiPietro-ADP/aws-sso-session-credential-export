#bin/bash
AWS_SSO_PROFILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      AWS_SSO_PROFILE="--profile $2"
      shift 2
      ;;
    *)
      break  # Stop processing options if not recognized
      ;;
  esac
done

 aws configure $AWS_SSO_PROFILE export-credentials | \
 xargs docker run -i --rm --name my-running-script-x-sso-aws-credentials-export \
  -v "$PWD/export.php":/usr/src/myapp/export.php \
  -v "$HOME/.aws/credentials:/usr/src/myapp/credentials" \
  -w /usr/src/myapp php:8.2-cli php export.php


# Unset the PROFILE environment variable
unset AWS_SSO_PROFILE