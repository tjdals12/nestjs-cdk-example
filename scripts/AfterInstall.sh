#!/bin/bash

set -e

echo "🚀 [AfterInstall] Start"

sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

cat <<'EOF' | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null
{
  "agent": {
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/nginx/access.log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/home/ec2-user/.pm2/logs/app-out.log",
            "log_group_name": "/pm2/app-out.log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/home/ec2-user/.pm2/logs/app-error.log",
            "log_group_name": "/pm2/app-error.log",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "disk": {
        "measurement": ["used_percent"],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    },
    "append_dimensions": {
      "InstanceId": "${aws:InstanceId}"
    }
  }
}
EOF

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

echo "🚀 [AfterInstall] Completed"