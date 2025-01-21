---
title: "Automate My Website Deployment with CI/CD"
# description: "https://github.com/seanSeungeonKim/sean-seungeon-kim"
date: 2025-01-20T00:00:00+10:00
categories: ["Github Actions"]
icon: "/assets/images/photos/automate-s3-deployment/github-s3.png"
permalink: /project/automate-s3-deployment/
---




![Alt text](/assets/images/photos/automate-s3-deployment/github-s3.png)

# Project Intro

I used Github Action to deploy automatically any changes of static files in S3. All you have to do is just push codes!

Repo: [https://github.com/seanSeungeonKim/sean-seungeon-kim](https://github.com/seanSeungeonKim/sean-seungeon-kim)

---
## Project Duration

December 2024 ~ Jan 2025

---
## Project Details

The following pipeline runs when a new code was pushed to main.

1. Github Action checks out the latest commit hash and description
2. Using official aws-provided action, Authenticate to AWS Account. Github Action assumes IAM role to have minimum policy while interacting with S3.
3. Using S3 API, Sync current files to S3 bucket. If any file is deleted from the repo, delete it on S3 as well.


### Things to add
- How to make it more efficient to choose what file to exclude during `S3 Sync`. Right now I have to manually add `--exclude=""` option
