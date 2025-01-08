# Jan 6

## Set Up Two S3 Buckets
One contains the static files for website hosting. The other bucket is created for redirect purpose. If the user types a url without root domain, for example `domain.com` instead of `www.domain.com`, the second bucket receives the request and redirects to the first main bucket.
- For the moment, I allowed **all public access**. You should NOT do it in real production. I did it for testing purpose.
- I created a bucket policy to allow `GetObject` action for everyone
**Example Bucket Policy**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::{{bucket_name}}/*"
    }
  ]
}
```

## Register Domain with Route53
I registered my domain name `sean-seungeon.com` in Route53. The pricing was $14/year, which is not bad at all!! Just save two cups of coffee from Starbucks

## Configure Route53 to S3 buckets
I create **2 A records** in my domain.
