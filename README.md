**Wazuh Upgrade Script**

**Description**

This Bash script automates the upgrade of Wazuh's core components (Indexer, Manager, and Dashboard) on an Ubuntu/Debian installation.

Comments in the script are in French.

**Installation**

Clone this repository to your machine:
```
git clone https://github.com/your-repo/Wazuh-upgrade-script.git
cd Wazuh-upgrade-script
```

**Usage**

Run the script as root:
```
sudo bash upgrade_wazuh.sh
```

**Verification**

After execution, verify that the updates were successfully applied by running:
```
apt list --installed wazuh-indexer
apt list --installed wazuh-manager
apt list --installed wazuh-dashboard
```
