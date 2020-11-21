#!/bin/bash
#set -x


cat <<EOT > /etc/yum.repos.d/elastic.repo
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOT


rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

if [[ $(uname -r | sed 's/^.*\(el[0-9]\+\).*$/\1/') == "el8" ]]
then    
  dnf -y install --enablerepo=elasticsearch elasticsearch
else
  yum -y install --enablerepo=elasticsearch elasticsearch
fi

cat <<EOF > /etc/elasticsearch/elasticsearch.yml
node.name: node-1
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
cluster.initial_master_nodes: ["node-1"]
EOF

systemctl restart elasticsearch.service

echo "Elastic Search is now installed !"
