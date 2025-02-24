Automated Wazuh Upgrade

This Bash script automates the upgrade of Wazuh's core components (Indexer, Manager, and Dashboard) on an Ubuntu/Debian installation.

Prerequisites

Root or sudo access.

A running Wazuh server.

Active internet connection.

Installation

Clone this repository to your machine:

git clone https://github.com/your-repo/Wazuh-upgrade-script.git
cd Wazuh-upgrade-script

Usage

Run the script as root or with sudo:

sudo bash upgrade_wazuh.sh

The script will prompt you to enter:

The Wazuh Indexer IP address.

The Wazuh username.

The Wazuh password (entered securely).

It will then:

Stop relevant services.

Update the Wazuh repository.

Install the latest versions of Wazuh components.

Restart the services.

Verification

After execution, verify that the updates were successfully applied by running:

apt list --installed wazuh-indexer
apt list --installed wazuh-manager
apt list --installed wazuh-dashboard
