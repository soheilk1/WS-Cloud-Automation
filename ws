import boto3
import time

# Configuration
REGION = 'us-east-1'
INSTANCE_TYPE = 't2.micro' # Free tier eligible
AMI_ID = 'ami-0c7217cdde317cfec' # Ubuntu 22.04 LTS AMI (Changes per region)
KEY_NAME = 'my-devsecops-key' # Your SSH key pair name in AWS

# Initialize the Boto3 EC2 client
# Note: Requires AWS credentials configured via `aws configure` or environment variables
ec2_client = boto3.client('ec2', region_name=REGION)
ec2_resource = boto3.resource('ec2', region_name=REGION)

def create_security_group():
    """Creates a strict firewall Security Group allowing only SSH and HTTP."""
    sg_name = 'devsecops-web-sg'
    sg_description = 'Security group for Automated Python Web Server'
    
    try:
        print(f"[*] Creating Security Group: {sg_name}...")
        response = ec2_client.create_security_group(
            GroupName=sg_name,
            Description=sg_description
        )
        sg_id = response['GroupId']
        
        # Add Firewall Rules (Inbound)
        ec2_client.authorize_security_group_ingress(
            GroupId=sg_id,
            IpPermissions=[
                {'IpProtocol': 'tcp', 'FromPort': 22, 'ToPort': 22, 'IpRanges': [{'CidrIp': '0.0.0.0/0'}]}, # SSH
                {'IpProtocol': 'tcp', 'FromPort': 80, 'ToPort': 80, 'IpRanges': [{'CidrIp': '0.0.0.0/0'}]}  # HTTP
            ]
        )
        print(f"[✅] Security Group Created Successfully. ID: {sg_id}")
        return sg_id
        
    except Exception as e:
        print(f"[❌] Error creating Security Group: {e}")
        return None

def provision_instance(sg_id):
    """Deploys the EC2 instance and installs a basic web server via UserData."""
    
    # Bash script that AWS will automatically run when the server boots
    startup_script = """#!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo systemctl enable apache2
    echo "<h1>Deployed via Python Boto3 DevSecOps Automation!</h1>" | sudo tee /var/www/html/index.html
    """
    
    print("\n[*] Provisioning EC2 Virtual Machine...")
    instances = ec2_resource.create_instances(
        ImageId=AMI_ID,
        MinCount=1,
        MaxCount=1,
        InstanceType=INSTANCE_TYPE,
        KeyName=KEY_NAME,
        SecurityGroupIds=[sg_id],
        UserData=startup_script,
        TagSpecifications=[{
            'ResourceType': 'instance',
            'Tags': [{'Key': 'Name', 'Value': 'Automated-DevSecOps-Server'}]
        }]
    )
    
    instance = instances[0]
    print(f"[*] Waiting for instance {instance.id} to start...")
    instance.wait_until_running()
    instance.reload()
    
    print(f"[✅] Instance deployed successfully!")
    print(f"[🌐] Public IP Address: {instance.public_ip_address}")
    print(f"[👉] Access the web server at: http://{instance.public_ip_address}")

if __name__ == "__main__":
    print("--- Starting AWS Infrastructure Automation ---")
    security_group_id = create_security_group()
    if security_group_id:
        provision_instance(security_group_id)
