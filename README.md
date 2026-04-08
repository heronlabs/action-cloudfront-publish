# Publish CloudFront Action

A GitHub Action that issues an `aws cloudfront create-invalidation --paths "/*"` against a given distribution. Use it after publishing static assets to S3 so CloudFront viewers get fresh content.

It authenticates to AWS via OIDC — no long-lived access keys.

## Requirements

### Permissions

```yaml
permissions:
  id-token: write
  contents: read
```

### AWS IAM Role

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

### Supported Runners

- `ubuntu-24.04` (recommended)
- `ubuntu-22.04`
- `ubuntu-latest`

### Dependencies

- `aws` CLI (pre-installed on GitHub-hosted runners)
- Internal: `aws-actions/configure-aws-credentials@v6`

## Inputs

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `AWS_ROLE_TO_ASSUME` | ARN of the IAM role to assume via OIDC | Yes | — |
| `AWS_REGION` | AWS region used when calling CloudFront | Yes | — |
| `AWS_ROLE_DURATION_SECONDS` | Duration in seconds for the assumed role session | Yes | — |
| `DISTRIBUTION_ID` | CloudFront distribution ID to invalidate | Yes | — |

## Outputs

This action does not produce outputs.

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

      - name: Invalidate CloudFront
        uses: heronlabs/publish-cloudfront-action@v2
        with:
          AWS_ROLE_TO_ASSUME: ${{ secrets.AWS_ROLE_ARN }}
          AWS_REGION: us-east-1
          AWS_ROLE_DURATION_SECONDS: 900
          DISTRIBUTION_ID: E1ABCDEF2GHIJK
```

## Notes

- **Invalidates everything**: the action always uses the `/*` path. CloudFront charges per invalidation path after the free tier, so frequent deployments may incur small costs.
- **Run after the sync step**: invalidation only helps if fresh objects already exist at the origin. Pair with `heronlabs/publish-s3-action@v2` (or equivalent) first.

## License

MIT

---

See also: [`workloads/docs/actions/publish-cloudfront-action.md`](https://github.com/heronlabs/workloads/blob/main/docs/actions/publish-cloudfront-action.md)
