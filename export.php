<?php
// echo "riciao:" . print_r($argv, true);

$accessKeyId = "";
$secretAccessKey = "";
$sessionToken = "";
$expiration = "";

foreach ($argv as $key => $value) {
    switch ($value) {
        case 'AccessKeyId:':
            $accessKeyId = rtrim($argv[$key+1], ',');
            break;
        case 'SecretAccessKey:':
            $secretAccessKey = rtrim($argv[$key+1], ',');
            break;
        case 'SessionToken:':
            $sessionToken = rtrim($argv[$key+1], ',');
            break;
        case 'Expiration:':
            $expiration = rtrim($argv[$key+1], ',');
        break;
    }
}

$awsCredentialsContent = <<<FILECONTENT
[default]
aws_access_key_id=$accessKeyId
aws_secret_access_key=$secretAccessKey
aws_session_token=$sessionToken
FILECONTENT;

// echo $awsCredentialsContent;

$file = 'credentials';
// Open the file to get existing content
//$current = file_get_contents($file);

echo "Writing new credentials into ~/.aws/credentials\n";
// Write the contents to the file
file_put_contents($file, $awsCredentialsContent);
echo "~/.aws/credentials updated.\n";

echo "Session Expiration: $expiration\n";
return 0;