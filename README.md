# CloudFront Publish Action

[![CI](https://github.com/heronlabs/action-cloudfront-publish/actions/workflows/ci.yml/badge.svg)](https://github.com/heronlabs/action-cloudfront-publish/actions/workflows/ci.yml)

> Invalidate an AWS CloudFront distribution so viewers pick up fresh origin content.

Authenticates to AWS via OIDC (no long-lived keys) and runs `aws cloudfront create-invalidation --paths "/*"` against the given distribution.

## Usage

```yaml
name: Deploy Web

on:
  push:
    branches: [main]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v6

      - name: Publish assets
        uses: heronlabs/action-s3-publish@v3
        with:
          AWS_ROLE_TO_ASSUME: ${{ secrets.AWS_ROLE_ARN }}
          AWS_REGION: us-east-1
          AWS_ROLE_DURATION_SECONDS: 900
          BUCKET_NAME: my-static-site

      - name: Invalidate CloudFront
        uses: heronlabs/action-cloudfront-publish@v3
        with:
          AWS_ROLE_TO_ASSUME: ${{ secrets.AWS_ROLE_ARN }}
          AWS_REGION: us-east-1
          AWS_ROLE_DURATION_SECONDS: 900
          DISTRIBUTION_ID: E1ABCDEF2GHIJK
```

## Inputs

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `AWS_ROLE_TO_ASSUME` | ARN of the IAM role to assume via OIDC | Yes | — |
| `AWS_REGION` | AWS region used when calling CloudFront | Yes | — |
| `AWS_ROLE_DURATION_SECONDS` | Duration in seconds for the assumed role session | Yes | — |
| `DISTRIBUTION_ID` | CloudFront distribution ID to invalidate | Yes | — |

## Outputs

This action produces no outputs.

## Permissions

```yaml
permissions:
  id-token: write
  contents: read
```

<details><summary>AWS IAM policy</summary>

The assumed role must allow invalidation on the target distribution:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "cloudfront:CreateInvalidation",
      "Resource": "arn:aws:cloudfront::<account-id>:distribution/<distribution-id>"
    }
  ]
}
```

</details>

## Notes

- Always invalidates `/*`; CloudFront bills per path after the free tier, so frequent deploys may incur small costs.
- Only helps if fresh objects already exist at the origin — run after `heronlabs/action-s3-publish@v3`.
- Requires an OIDC trust relationship configured on the AWS account.

## License

MIT
