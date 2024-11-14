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
                "curl -f http://localhost:${container_port}/ || exit 1"
            ],
            "interval": 30,
            "retries": 3,
            "start_period": 60,
            "timeout": 5
        },
        "essential": true,
        "environment": [
            {
                "name": "AWS_REGION",
                "value": "${aws_region}"
            },
            {
                "name": "NEXT_PUBLIC_WOODLAND_CREATURE",
                "value": "${public_woodland_creature}"
            },
            {
                "name": "SECRET_WOODLAND_CREATURE",
                "value": "${secret_woodland_creature}"
            },
            {
                "name": "API_KEY_SSM_PARAM_NAME",
                "value": "${api_key_ssm_param_name}"
            }
        ],
        "environmentFiles": [],
        "mountPoints": [],
        "volumesFrom": [],
        "ulimits": []
    }
]