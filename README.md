# aws-sso-session-credential-export

**Exports AWS SSO session credentials to your AWS CLI `credentials` file.**

This bash script provides a helper tool to simplify working with AWS Single Sign-On (SSO) session credentials and the AWS Command Line Interface (CLI). It automates the process of logging in with AWS SSO, exporting session credentials, and cleaning up credentials when logging out.

## Prerequisites

*   **AWS CLI v2:**  You must have the AWS Command Line Interface version 2 (AWS CLI v2) installed. You can find installation instructions in the [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).
*   **AWS CLI `sso` plugin configured:** Your AWS CLI must be configured to use AWS SSO. You should have run `aws configure sso` at least once to set up your SSO configuration.  Refer to the [AWS CLI documentation on configuring SSO](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html) for details.
*   **`jq` command-line JSON processor:** The script uses `jq` to parse JSON output from the AWS CLI. You need to have `jq` installed on your system.  You can find installation instructions for your operating system on the [jq website](https://stedolan.github.io/jq/).  For example, on macOS (using Homebrew) and many Linux distributions, you can typically install it with: `brew install jq` or `sudo apt-get install jq` / `sudo yum install jq`.
*   **awk:**  A powerful text processing utility. `awk` is used in the `clean-session-credentials.sh` script to efficiently find and remove sections from the AWS credentials file.  `awk` is a standard utility on most Unix-like operating systems (Linux, macOS).

**Note:**  `awk` is typically pre-installed on Linux and macOS systems. You likely do not need to install it separately. However, if you are using a minimal environment or encounter issues, you may need to ensure `awk` is available in your system's PATH.



## Commands

This script provides the following commands:

*   **`help`**:

    *   Displays this help information, explaining the available commands and options.
    *   Usage: `aws-sso-helper help`

*   **`sso-login`**:

    *   Performs `aws sso login` to initiate the AWS SSO login process.
    *   After successful login, it automatically exports the session credentials for the specified profile (or default SSO profile) into your AWS CLI `credentials` file (`~/.aws/credentials`).
    *   Usage: `aws-sso-helper sso-login [options]`
    *   Options:
        *   `--profile <profile_name>`:  Specify the AWS SSO profile to use for login and credential export. If not provided, it will use the default SSO profile configured in your AWS CLI.
        *   `--export-as-default`: Exports the session credentials into the `[default]` profile section of your `~/.aws/credentials` file, instead of the section named after the SSO profile, it should be usedd in combo with `--profile <profile_name>`.

*   **`export-session-credentials`**:

    *   Exports the AWS SSO session credentials for a configured SSO profile into your AWS CLI `credentials` file. This command does **not** perform a new `aws sso login`. It assumes you are already logged in or have a valid SSO session.
    *   Usage: `aws-sso-helper export-session-credentials [options]`
    *   Options:
        *   `--profile <profile_name>`:  Specify the AWS SSO profile to export credentials from. If not provided, it will attempt to use the default SSO profile.
        *   `--export-as-default`: Exports the session credentials into the `[default]` profile section of your `~/.aws/credentials` file it should be usedd in combo with `--profile <profile_name>`.

*   **`sso-logout`**:

    *   Performs `aws sso logout` to invalidate your AWS SSO session.
    *   After successful logout, it automatically cleans up the session credentials from your AWS CLI `credentials` file for the specified profile (or default SSO profile).
    *   Usage: `aws-sso-helper sso-logout [options]`
    *   Options:
        *   `--profile <profile_name>`:  Specify the AWS SSO profile to use for logout and credential cleanup.  If not provided, it will use the default SSO profile.
        *   `--export-as-default`:  Cleans credentials from the `[default]` profile section of your `~/.aws/credentials` file.

*   **`clean-session-credentials`**:

    *   Cleans up the AWS SSO session credentials from your AWS CLI `credentials` file for a specified profile. This command does **not** perform `aws sso logout`.
    *   Usage: `aws-sso-helper clean-session-credentials [options]`
    *   Options:
        *   `--profile <profile_name>`:  Specify the AWS SSO profile whose credentials should be cleaned. If not provided, it will attempt to clean the default SSO profile's credentials.
        *   `--export-as-default`: Cleans credentials from the `[default]` profile section of your `~/.aws/credentials` file.

## Usage Examples

**1. Display Help:**

```bash
./aws-sso-helper help
```

**2. Perform SSO Login and Export Credentials for the Default SSO Profile:**

```bash
./aws-sso-helper sso-login
```

**3. Perform SSO Login and Export Credentials for a Specific SSO Profile (`my-sso-profile`):**

```bash
./aws-sso-helper sso-login --profile my-sso-profile
```

**4. Perform SSO Login as `my-sso-profile` and Export Credentials to the `[default]` Profile Section:**

```bash
./aws-sso-helper sso-login --profile my-sso-profile --export-as-default
```

**5. Export Session Credentials for a Specific SSO Profile ("my-sso-profile") without Logging In Again:**

```bash
./aws-sso-helper export-session-credentials --profile my-sso-profile
```

**6. Clean Session Credentials for the Default SSO Profile:**

```bash
./aws-sso-helper clean-session-credentials
```

**7. Perform SSO Logout and Clean Credentials for a Specific SSO Profile ("my-sso-profile"):**

```bash
./aws-sso-helper sso-logout --profile my-sso-profile
```

**8. Clean Session Credentials from the `[default]` Profile Section:**

```bash
./aws-sso-helper clean-session-credentials [--export-as-default]
```

## Platform Compatibility

This script is primarily designed for **Linux and macOS** operating systems.

**Credentials File Path:**

The script assumes the AWS CLI credentials file is located at `~/.aws/credentials`. This is the standard path for Linux and macOS.

**Windows Compatibility:**

**This script, in its current form, is likely NOT fully compatible with Windows.**

*   **Credentials File Path:** Windows uses a different path for the AWS CLI credentials file, typically located at `"%USERPROFILE%\.aws\credentials"`.
*   **Shell Commands:** Some of the shell commands used in the scripts (like `sed`, `grep`, `cut`) are standard Unix utilities and may not be directly available in a default Windows environment.  Windows users might need to use WSL (Windows Subsystem for Linux) or install these utilities separately (e.g., via Git for Windows or Cygwin).

**Windows Users (Potential Adaptations):**

Windows users who wish to use this script may need to make the following adaptations:

1.  **Adjust Credentials File Path:** Modify the scripts to use the Windows credentials file path `"%USERPROFILE%\.aws\credentials"` instead of `~/.aws/credentials`.  Environment variables like `%USERPROFILE%` can be used in bash scripts even on WSL or Git Bash.
2.  **Ensure Unix Utilities are Available:**  Make sure that `sed`, `grep`, `cut`, and `command -v` are available in their Windows environment. This might involve using WSL or installing tools like Git for Windows, which provides a bash environment with these utilities.

**Future Windows Support:**

Future versions of this script *may* include more robust Windows support with automatic platform detection and path adjustments.  Contributions and feedback from Windows users are welcome.


## License

This script is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html).

## Author

[Andrea Di Pietro/AndreaDiPietro-ADP](https://github.com/AndreaDiPietro-ADP)