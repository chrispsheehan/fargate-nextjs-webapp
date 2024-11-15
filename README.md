# fargate-nextjs-webapps

New image pushed to ecr upon changes detected in `/src` and subsequently deployed to ecs.

## run dev locally

```sh
npm i
npm run build
npm run start
```

## overview

`/app` is the frontend (client side) code
`/pages` is the backend (server side) code

## env vars

[reference](https://nextjs.org/docs/pages/building-your-application/configuring/environment-variables#bundling-environment-variables-for-the-browser)

build locally - `API_KEY_SSM_PARAM_NAME=/some/thing AWS_REGION=eu-west-2 npm run build`

`NEXT_PUBLIC_WOODLAND_CREATURE` is save for browser
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


## gotchas

- health checks failing trigging a rollback. 
  - issue: ECS will override env vars. `HOSTNAME` is required to enable a container to hit localhost for health checks.
  - debug: local docker run health check simulation works fine.
  - fix: 
    - add install for `curl` in dockerfile
    - add the `HOSTNAME` env var with value `0.0.0.0` to the ECS task definition
    - hit `http://0.0.0.0:${container_port}` in the task health check