#!/bin/bash

# Stop the Jenkins service
sudo systemctl stop jenkins

# Disable the Jenkins service from starting on boot
sudo systemctl disable jenkins

# Uninstall Jenkins package
sudo apt-get remove --purge jenkins -y

# Remove any remaining dependencies that were installed with Jenkins
sudo apt-get autoremove --purge -y

# Remove Jenkins related configuration files if they exist
sudo rm -rf /var/lib/jenkins
sudo rm -rf /etc/jenkins
sudo rm -rf /var/log/jenkins

# Remove the Jenkins repository from your sources list
sudo rm /etc/apt/sources.list.d/jenkins.list

# Remove the Jenkins GPG key
sudo rm /usr/share/keyrings/jenkins-keyring.asc

# Clean up the apt cache
sudo apt-get clean

# Optionally, remove Java if it's no longer needed
sudo apt-get remove --purge openjdk-17-jre -y
sudo apt-get autoremove -y

echo "Jenkins has been completely removed from your system."