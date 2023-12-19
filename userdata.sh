#!/bin/bash
# Install HTTP server
echo "installing HTTP server"
yum install -y httpd
systemctl start httpd
systemctl enable httpd
# Create sample index page
echo "<h1>Hello World from EC2 instance!</h1>" > /var/www/html/index.html
echo "HTTP server installed"
echo "installing ssm agent"
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent
echo "ssm agent installed"
echo "installing collectd agent"
amazon-linux-extras install collectd
echo "collectd agent installed"

#Bootstrap Jenkins installation and start
#!/bin/bash #specifies the interpreter
#sudo yum update -y  # updates the package list and upgrades installed packages on the system
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo  #downloads the Jenkins repository configuration file and saves it to /etc/yum.repos.d/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key  #imports the GPG key for the Jenkins repository. This key is used to verify the authenticity of the Jenkins packages
sudo yum upgrade -y #  upgrades packages again, which might be necessary to ensure that any new dependencies required by Jenkins are installed
sudo dnf install java-11-amazon-corretto -y  # installs Amazon Corretto 11, which is a required dependency for Jenkins.
sudo yum install jenkins -y  #installs Jenkins itself
sudo systemctl enable jenkins  #enables the Jenkins service to start automatically at boot time
sudo systemctl start jenkins   #starts the Jenkins service immediately
