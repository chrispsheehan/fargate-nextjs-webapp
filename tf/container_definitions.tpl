[
    {
        "name": "${container_name}",
        "image": "nginx",
        "cpu": 0,
        "portMappings": [
            {
                "name": "nginx-80-tcp",
                "containerPort": 80,
                "hostPort": 80,
                "protocol": "tcp",
                "appProtocol": "http"
            }
        ],
        "essential": true,
        "environment": [],
        "environmentFiles": [],
        "mountPoints": [],
        "volumesFrom": [],
        "ulimits": []
    }
]