AWS Infrastructure Automation (IaC) ☁️

Overview

This project demonstrates "Infrastructure as Code" (IaC) using Python and the official AWS SDK (boto3). It is designed to automatically provision a secure, fully functioning cloud web server with a single execution command.

It handles the creation of strict firewall rules (Security Groups) and deploys an EC2 instance pre-configured with an Apache web server via an automated bash startup script (UserData).

Features

Automated Security: Creates a Security Group allowing only SSH (Port 22) and HTTP (Port 80) traffic.

Automated Provisioning: Deploys a t2.micro Ubuntu EC2 instance.

Automated Configuration: Injects a bash script to install and start a web server the moment the machine boots.

Prerequisites

Python 3.x

AWS CLI installed and configured with your IAM credentials (aws configure)

The boto3 Python library

Installation & Usage

Install the required AWS SDK for Python:

pip install boto3


Update the KEY_NAME variable in the script to match your existing AWS SSH Key Pair.

Execute the script:

python3 aws_provision.py


Wait for the terminal to output the public IP address of your newly deployed server!

Security Note

Do not hardcode your AWS Access Keys directly into the Python script. Always use environment variables or the AWS CLI credential file to maintain cloud security best practices.
