[
    {
        "name": "${container_name}",
        "image": "${image_uri}",
        "cpu": 0,
        "portMappings": [
            {
                "name": "${container_name}-${container_port}-tcp",
                "containerPort": ${container_port},
                "hostPort": ${host_port},
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