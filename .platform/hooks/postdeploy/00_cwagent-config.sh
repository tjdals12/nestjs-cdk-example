#!/bin/bash

set -e

ENV_NAME=$(/opt/elasticbeanstalk/bin/get-config container -k environment_name)

cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/aws/elasticbeanstalk/${ENV_NAME}/nginx/access.log",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%d/%b/%Y:%H:%M:%S %z",
            "retention_in_days": 7
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/aws/elasticbeanstalk/${ENV_NAME}/nginx/error.log",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%Y/%m/%d %H:%M:%S",
            "retention_in_days": 7
          }
        ]
      }
    }
  },
  "metrics": {
    "append_dimensions": {
      "InstanceId": "\${aws:InstanceId}",
      "AutoScalingGroupName": "\${aws:AutoScalingGroupName}"
    },
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "resources": ["*"],
        "measurement": ["used_percent"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent