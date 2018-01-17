version: '2'
services:
  logstash-indexer-config:
    restart: always
    image: rancher/logstash-config:v0.2.0
    labels:
      io.rancher.container.hostname_override: container_name
  redis:
    restart: always
    tty: true
    image: redis:3.2.6-alpine
    stdin_open: true
    labels:
      io.rancher.container.hostname_override: container_name
  logstash-indexer:
    restart: always
    tty: true
    volumes_from:
    - logstash-indexer-config
    volumes:
    - /home/bsharin/elk/logstash/AlienVaultIP.yaml:/opt/logstash/AlienVaultIP.yaml
    command:
    - logstash
    - -f
    - /etc/logstash
    - -r
    image: 10.0.211.103:6000/logstash-oss:6.1.1
    links:
    - redis:redis
    external_links:
    - ${elasticsearch_link}:elasticsearch
    stdin_open: true
    labels:
      io.rancher.sidekicks: logstash-indexer-config
      io.rancher.container.hostname_override: container_name
  logstash-collector-config:
    restart: always
    image: rancher/logstash-config:v0.2.0
    labels:
      io.rancher.container.hostname_override: container_name
  logstash-collector:
    restart: always
    tty: true
    links:
    - redis:redis
    ports:
    - 5140:5140/udp
    - 5140:5140/tcp
    - 6000:6000/tcp
    volumes_from:
    - logstash-collector-config
    command:
    - logstash
    - -f
    - /etc/logstash
    - -r
    image: 10.0.211.103:6000/logstash-oss:6.1.1
    stdin_open: true
    labels:
      io.rancher.sidekicks: logstash-collector-config
      io.rancher.container.hostname_override: container_name
