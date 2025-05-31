#!/bin/bash
# Created by The Cloud Bootcamp - Install Security Agent Simulation

echo "Downloading security agent..."
sudo wget -q https://tcb-bootcamps.s3.amazonaws.com/bootcamp-aws/pt/module5/security_agent -P /usr/bin
echo "Security agent installation in progress..."
sudo chmod +x /usr/bin/security_agent
sleep 30
echo "Security agent installation completed."
sudo /usr/bin/security_agent status
