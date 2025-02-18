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

# Jan 8 2025

## Plan to Set Up Github Action

In order to automate S3 upload process, I felt a need to set up a **Github Action**. so that everytime there are changes in pages, Github triggers CI pipeline and automatically uploads to S3 bucket.

So I created a default Github Action. This should be a good starting point to think how my pipeline looks.

First, I added a .yaml file under `./github/workflows`. Each yaml file represents one **workflow**. I think it's similar to Jenkins pipeline.

Example yaml file

```yaml
name: GitHub Actions Demo
run-name: ${{ github.actor }} is testing out GitHub Actions 🚀
on: [push]
jobs:
  Explore-GitHub-Actions:
    runs-on: ubuntu-latest
    steps:
      - run: echo "🎉 The job was automatically triggered by a ${{ github.event_name }} event."
      - run: echo "🐧 This job is now running on a ${{ runner.os }} server hosted by GitHub!"
      - run: echo "🔎 The name of your branch is ${{ github.ref }} and your repository is ${{ github.repository }}."
      - name: Check out repository code
        uses: actions/checkout@v4
      - run: echo "💡 The ${{ github.repository }} repository has been cloned to the runner."
      - run: echo "🖥️ The workflow is now ready to test your code on the runner."
      - name: List files in the repository
        run: |
          ls ${{ github.workspace }}
      - run: echo "🍏 This job's status is ${{ job.status }}."
```

In the first workflow, I added basic steps. Just echoing things! This example shows how to use workflow syntax. `job`, `runner`, `github` etc

## Github Action Lingos I learned

- A repo can have multiple `workflows`.
- An `Event` is something that triggers workflow. An example includes code being pushed and creating a Pull Request.
  - You can also trigger dworkflow on a schedule
- A `job` is a set of `step`s on the same `runner`.
  - You can share data between steps. They are under same runner
  - You can configure job dependency. When a Job A has dependency on Job B, Job A waits for Job B to finish executing
- You can define multiple `job`s in one workflow. They all appear in Github UI.
- each job will execute on a `runner` machine and run a series of one or more `steps`
- An `Action` is a custom app that performs repetitive tasks. You can use an Action to reduce tedious work in workflow file.
  - You can create your own action or find pre-made one in Marketplace.
- Each step can either run a script that you define or run an `action`, which is a reusable extensions.

![!My Image](https://docs.github.com/assets/cb-25535/mw-1440/images/help/actions/overview-actions-simple.webp)

# Jan 9

## Set up OpenID Connect(OIDC) to authenticate with AWS

In order to update S3 objects, the workflow needs to be authenticated. Github recommends to use OIDC.

Thanks to OIDC, we don't have to store AWS credentials as long-lived Github secrets. More secure way

I created an IAM Role that Workflow can consume

References:

- <https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services#adding-the-identity-provider-to-aws>
- <https://www.youtube.com/watch?v=aOoRaVuh8Lc&ab_channel=CodeMadeSimple>

# Jan 12

## Grant S3 Permission to Github Actions

After getting Github athenticated, I needed to grant permission to the role that Github Action assumes.

This is to enable github action to interact with S3 bucket.

I first defined a few based on the "Least Previledge Principal".

### Example IAM Role policy

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:ListBucket",
                "s3:GetObject",
                "s3:DeleteObject",
            ],
            "Resource": [
                "arn:aws:s3:::sean-seungeon-kim.com/*",
                "arn:aws:s3:::sean-seungeon-kim.com"
            ]
        }
    ]
}
```

After adding policies, I tested if the automation of s3 website upload. I changed heading 1 from '404' to 'Sorry'. After pushing, the sync command worked and the page changed!

![Alt text](./readme-images/aws-s3-sync.png)

![alt text](./readme-images/sync-example-sorry.png)


# Jan 18

I used `CloudFront Function` to fix path-not-found issue in S3.

Rendered Jekyll requests contains href that looks like this

```
        <li class=" ">
          <a href="/experience" >Experience</a>
        </li>
```

This path does not work in S3. It is because It is requesting to get /experience, not /experience/index.html. The key path is strict.

In order to fix it, I referenced AWS documentation explaining how to make the url overwrite possible by using CloudFront. REF: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/example_cloudfront_functions_url_rewrite_single_page_apps_section.html

Example CF Function in `Viewer Request` in CF Behavior

```javascript
async function handler(event) {
    var request = event.request;
    var uri = request.uri;
    
    // Check whether the URI is missing a file name.
    if (uri.endsWith('/')) {
        request.uri += 'index.html';
    } 
    // Check whether the URI is missing a file extension.
    else if (!uri.includes('.')) {
        request.uri += '/index.html';
    }

    return request;
}
```

Used emojis in my website! I pasted them on emoji generator site: https://emojipedia.org/


# Jan 20
After getting the redirection working, I started adding another feature. 

## Sending Contact Imformation to Email

AWS Services I Used:
- API Gateway
- AWS Lambda
- Amazon SES(Simple Email Service)


# Jan 21

I realized that manually adding `--exclude` option feels very daunting and tedious. I decided to fix this problem

One thing I can think of is to run a shell script to generate a collective list of files to exclude.

1. In a step called `generate exclude list`, a shell script returns a s3 exclude option.
2. The value of the return value is saved in Github ACtion Env Variabled called `$GITHUB_ENV`

```bash
echo "EXCLUDE_ARGS=${EXCLUDE_ARGS}" >> $GITHUB_ENV
```

3. In next step, `Sync website files to S3`, simply use the env variable in `aws s3 sync` command


This is how it looks at a bigger picture
```yaml

- name: Generate Exclude List
        id: exclusions
        env:
          EXCLUDE_FILE_PATH: ".github/workflows/generate-s3-exclude/exclude.txt"
        run: |
          EXCLUDE_ARGS=""

          # Check if the exclude file exists
          if [[ ! -f "${{ env.EXCLUDE_FILE_PATH}}" ]]; then
            echo "Error: Exclude file '${{ env.EXCLUDE_FILE_PATH}}' not found."
            exit 1
          fi

          # Read each line from the exclude file
          while IFS= read -r line || [ -n "$line" ]; do
            # Skip empty lines or lines that start with a hash (#, used for comments)
            [[ -z "$line" || "$line" =~ ^# ]] && continue

            # Add the line as a --exclude argument
            EXCLUDE_ARGS+="--exclude \"$line\" "
          done < "${{ env.EXCLUDE_FILE_PATH }}"

          # Output the exclude arguments
          echo "echo EXCLUDE_ARGS"
          echo "$EXCLUDE_ARGS"

          echo "EXCLUDE_ARGS=${EXCLUDE_ARGS}" >> $GITHUB_ENV
      - name: Sync website files to S3
        run: |
          aws s3 sync ./_site/ "s3://${{ env.BUCKET_NAME }}" \
            --delete \
            ${{ env.EXCLUDE_ARGS }}

```

# Jan 28

## Send Resume Email with API Gateway and Lambda

In order to send email with resume attached, you need to provision the following resources:

- Create SES and verify my email
- Create Lambda
  - Create Lambda Execution Role to allow `SES` actions
- Create API Gateway

You can manaully provision them but I decided to use `AWS SAM`, Serverless Application Model

```bash
# package cloudformation
## This will take SAM template and generate CF template under gen/ and upload it to s3 bucket
sam package --s3-bucket sean-seungeon-kim.com --s3-prefix sam --template-file template.yaml --output-template-file gen/template-generated.yaml --region us-east-1

# Deploy the package
aws cloudformation deploy --template-file gen/template-generated.yaml --stack-name send-resume-email --capabilities CAPABILITY_IAM --region us-east-1
```

Learnings:
- You need to specify `--region` and `--capabilities`. `capabilities` is used to grant permission to provision stacks


Bypass the CF 
```bash
sam sync --capabilities CAPABILITY_IAM --code --resource AWS::Serverless::Function
```

# Feb 3

Sending request to API Gateway worked. But the problem is that It returns a plain text when the user submits the button. How do I resolve it?

- Create a custom response in API Gateway to redirect the Lambda response to my website path. Something like `/submit-success`.
