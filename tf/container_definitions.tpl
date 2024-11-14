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
        "healthcheck": {
            "command": [
                "CMD-SHELL", 
                "wget -qO- http://127.0.0.1:${container_port}/api/health || exit 1"
            ],
            "interval": 5,
            "timeout": 2,
            "retries": 3,
            "startPeriod": 10
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
        }],
        "environmentFiles": [],
        "mountPoints": [],
        "volumesFrom": [],
        "ulimits": []
    }
]