#!/bin/bash

# Demande des entrées utilisateur
read -p "Entrez l'adresse IP du Wazuh Indexer: " WAZUH_INDEXER_IP
read -p "Entrez le nom d'utilisateur Wazuh: " USERNAME
read -s -p "Entrez le mot de passe Wazuh: " PASSWORD

echo "\nMerci, mise à jour en cours..."

# Vérification des privilèges
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être exécuté en tant que root" 
   exit 1
fi

# Mise à jour des paquets système
apt-get update
apt-get install -y gnupg apt-transport-https

# Ajout de la clé GPG et du dépôt Wazuh
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
apt-get update

# Arrêt des services avant la mise à jour
systemctl stop filebeat
systemctl stop wazuh-dashboard
systemctl stop wazuh-manager

# Désactiver la réplication des shards
curl -X PUT "https://$WAZUH_INDEXER_IP:9200/_cluster/settings" -u $USERNAME:$PASSWORD -k -H "Content-Type: application/json" -d '{"persistent": {"cluster.routing.allocation.enable": "primaries"}}'

# Flush du cluster
curl -X POST "https://$WAZUH_INDEXER_IP:9200/_flush" -u $USERNAME:$PASSWORD -k

# Arrêt du service Wazuh Indexer
systemctl stop wazuh-indexer

# Mise à jour du Wazuh Indexer
apt-get install -y wazuh-indexer

# Redémarrage du Wazuh Indexer
systemctl daemon-reload
systemctl enable wazuh-indexer
systemctl start wazuh-indexer

# Vérification de l'état des nœuds
curl -k -u $USERNAME:$PASSWORD https://$WAZUH_INDEXER_IP:9200/_cat/nodes?v

# Réactivation de l'allocation des shards
curl -X PUT "https://$WAZUH_INDEXER_IP:9200/_cluster/settings" -u $USERNAME:$PASSWORD -k -H "Content-Type: application/json" -d '{"persistent": {"cluster.routing.allocation.enable": "all"}}'

# Mise à jour du Wazuh Manager
apt-get install -y wazuh-manager

# Mise à jour du module Filebeat
curl -s https://packages.wazuh.com/4.x/filebeat/wazuh-filebeat-0.4.tar.gz | sudo tar -xvz -C /usr/share/filebeat/module
curl -so /etc/filebeat/wazuh-template.json https://raw.githubusercontent.com/wazuh/wazuh/v4.11.0/extensions/elasticsearch/7.x/wazuh-template.json
chmod go+r /etc/filebeat/wazuh-template.json

# Redémarrage de Filebeat
systemctl daemon-reload
systemctl enable filebeat
systemctl start filebeat
filebeat setup --pipelines
filebeat setup --index-management -E output.logstash.enabled=false

# Mise à jour du Wazuh Dashboard
cp /etc/wazuh-dashboard/opensearch_dashboards.yml /etc/wazuh-dashboard/opensearch_dashboards.yml.old
apt-get install -y wazuh-dashboard
systemctl daemon-reload
systemctl enable wazuh-dashboard
systemctl start wazuh-dashboard

#Relance le service Wazuh manager
systemctl restart wazuh-manager

# Vérification des versions
apt list --installed wazuh-indexer
apt list --installed wazuh-manager
apt list --installed wazuh-dashboard

echo "Mise à jour de Wazuh terminée avec succès !"

