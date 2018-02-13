# rpi-kibana

This is just another forked Git repo of the Docker [official image](https://docs.docker.com/docker-hub/official_repos/) for [kibana](https://registry.hub.docker.com/_/kibana/). 

The aim of this repo is to make the official Docker image for kibana compatible with Raspberry Pi.

See [the official Docker Hub page](https://registry.hub.docker.com/_/kibana/) for the full readme on how to use this Docker image based on the official one.

(tested on a raspberry pi 3, Linux 4.4.50-v7+ armv7l GNU/Linux)

```yaml
elasticsearch:
  image: jritsema/rpi-elasticsearch:2.4.0
  volumes:
    - ./elasticsearch:/data
  ports:
    - "9200:9200"
    - "9300:9300"
  environment:
    - CLUSTER_NAME=my-cluster
    - LISTEN=0.0.0.0
  restart: always

kibana:
  image: jritsema/rpi-kibana:4.6.1
  volumes:
    - ./kibana/config/:/opt/kibana/config/
  ports:
    - "5601:5601"
  links:
    - elasticsearch
  restart: always
```

