[
    {
        "name": "${container_name}",
        "image": "${image_uri}",
        "cpu": ${cpu},
        "memory": ${memory},
        "portMappings": [
            {
                "name": "${container_name}-${container_port}-tcp",
                "containerPort": ${container_port},
                "hostPort": ${container_port},
                "protocol": "tcp",
                "appProtocol": "http"
            }
        ],
        "healthCheck": {
            "command": [
                "CMD-SHELL",
                "curl -I http://0.0.0.0:${container_port} || exit 1"
            ],
            "interval": 30,
            "timeout": 5,
            "retries": 3,
            "startPeriod": 30
        },
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${cloudwatch_log_name}",
                "awslogs-region": "${aws_region}",
                "awslogs-stream-prefix": "ecs"
            }
        },
        "essential": true,
        "environment": [{
          "name": "NEXT_PUBLIC_WOODLAND_CREATURE",
          "value": "badger"
        },
        {
          "name": "API_KEY_SSM_PARAM_NAME",
          "value": "${api_key_ssm_param_name}"
        },
        {
          "name": "AWS_REGION",
          "value": "${aws_region}"
        },
        {
          "name": "HOSTNAME",
          "value": "0.0.0.0"
        }],
        "secrets": [
          {
            "name": "STATIC_SECRET",
            "valueFrom": "${static_secret_ssm_arn}"
          }
        ],
        "environmentFiles": [],
        "mountPoints": [],
        "volumesFrom": [],
        "ulimits": []
    }
]