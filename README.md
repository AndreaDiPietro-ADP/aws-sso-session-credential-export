> for using the `default` profile, example

```cli
aws sso login && \
cd $HOME/ExportAwsSSOFileCredentials && ./export.sh
```

> for using a **custom** profile like `my-iam-profile`, example

```cli
aws sso login --profile my-iam-profile && \
cd $HOME/ExportAwsSSOFileCredentials && ./export.sh --profile my-iam-profile
```
