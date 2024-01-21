{
  "family": "${task_family}",
  "containerDefinitions": [
    {
      "name": "${container_name}",
      "image": "${container_image}",
      "cpu": ${cpu},
      "memory": ${memory},
      "portMappings": [
        {
          "containerPort": ${container_port},
          "hostPort": ${host_port}
        }
      ]
    }
  ],
  "requiresCompatibilities": ["FARGATE"],
  "networkMode": "awsvpc",
  "cpu": "${cpu}",
  "memory": "${memory}"
}
