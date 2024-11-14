# fargate-nextjs-webapps

New image pushed to ecr upon changes detected in `/src` and subsequently deployed to ecs.

## run docker dev locally

```sh
docker run --env-file .env -p 3000:3000 -w /app -v ${PWD}/src:/app node:20 npm run dev
```

## env vars

[reference](https://nextjs.org/docs/pages/building-your-application/configuring/environment-variables#bundling-environment-variables-for-the-browser)

build locally - `API_KEY_SSM_PARAM_NAME=/some/thing AWS_REGION=eu-west-2 npm run build`

`NEXT_PUBLIC_WOODLAND_CREATURE` is save for browser
`SECRET_WOODLAND_CREATURE` is *not safe* for browser - only for backend/runtime
`API_KEY_SSM_PARAM_NAME` key to get value from ssm

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
    "elasticloadbalancing:*",
    "ssm:*",
    "logs:*"
]
```


## ci

Commits to `main` will kick off a deployment.

Required github action variables.
- `AWS_ACCOUNT_ID`
- `AWS_REGION`
- `AWS_ROLE` role with deployment privileges
- `AWS_ROLE_VALIDATE_ONLY` role with readonly privileges (can be same as `AWS_ROLE`)