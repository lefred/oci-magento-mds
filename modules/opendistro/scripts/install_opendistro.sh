#!/bin/bash
#set -x

curl https://d3g5vo6xdbdb9a.cloudfront.net/yum/opendistroforelasticsearch-artifacts.repo -o /etc/yum.repos.d/opendistroforelasticsearch-artifacts.repo



if [[ $(uname -r | sed 's/^.*\(el[0-9]\+\).*$/\1/') == "el8" ]]
then
  dnf install -y java-11-openjdk-devel
  dnf -y install opendistroforelasticsearch
else
  yum -y install java-11-openjdk-devel
  yum -y install opendistroforelasticsearch
fi

cat <<EOF > /etc/elasticsearch/elasticsearch.yml
node.name: node-1
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
cluster.initial_master_nodes: ["node-1"]
discovery.seed_hosts: ["node-1"]
opendistro_security.disabled: true
EOF

systemctl restart elasticsearch.service

echo "OpenDistro for ElasticSearch is now installed !"
