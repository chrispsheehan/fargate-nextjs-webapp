# fargate-nextjs-webapps

New image pushed to ecr upon changes detected in `/src` and subsequently deployed to ecs.

## run docker dev locally

docker run --env-file .env -p 3000:3000 -w /app -v ${PWD}/src:/app node:20 npm run dev

## terraform

Required deployment iam privileges.

```json
[
    "dynamodb:*", 
    "s3:*", 
    "ecr:*", 
    "iam:*", 
    "ecs:*",
    "ec2:*", 
    "elasticloadbalancing:*"
]
```


## ci

Commits to `main` will kick off a deployment.

Required github action variables.
- `AWS_ACCOUNT_ID`
- `AWS_REGION`
- `AWS_ROLE` role with deployment privileges
- `AWS_ROLE_VALIDATE_ONLY` role with readonly privileges (can be same as `AWS_ROLE`)