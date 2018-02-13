FROM resin/rpi-raspbian:jessie

# add our user and group first to make sure their IDs get assigned consistently
RUN groupadd -r kibana && useradd -r -m -g kibana kibana

RUN apt-get update && apt-get install -y \
        ca-certificates \
        wget \
    --no-install-recommends

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

# grab tini for signal processing and zombie killing
ENV TINI_VERSION v0.10.0
RUN set -x \
    && wget -O /usr/local/bin/tini "https://github.com/ind3x/rpi-tini/releases/download/$TINI_VERSION/tini" \
    && chmod +x /usr/local/bin/tini \
    && tini -h

# install kibana
ENV KIBANA_VERSION 4.6.1
RUN set -x \
    && cd /tmp \
    && wget "https://download.elastic.co/kibana/kibana/kibana-$KIBANA_VERSION-linux-x86_64.tar.gz" \
    && tar -xvzf kibana-$KIBANA_VERSION-linux-x86_64.tar.gz \
    && mv /tmp/kibana-$KIBANA_VERSION-linux-x86_64 /opt \
    && rm kibana-$KIBANA_VERSION-linux-x86_64.tar.gz \
    && ln -s /opt/kibana-$KIBANA_VERSION-linux-x86_64 /opt/kibana \
    && chown -R kibana:kibana /opt/kibana \
    && chmod o+w /opt/kibana/optimize/.babelcache.json \
    && sed -ri "s!^(\#\s*)?(elasticsearch\.url:).*!\2 'http://elasticsearch:9200'!" /opt/kibana/config/kibana.yml \
    && grep -q 'elasticsearch:9200' /opt/kibana/config/kibana.yml

# install arm version of node
RUN set -x \
    && wget http://node-arm.herokuapp.com/node_latest_armhf.deb  \
    && DEBIAN_FRONTEND=noninteractive dpkg -i node_latest_armhf.deb \
    && ln -sf /usr/local/bin/node /opt/kibana/node/bin/node \
    && ln -sf /usr/local/bin/npm /opt/kibana/node/bin/npm

ENV PATH /opt/kibana/bin:$PATH

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 5601
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["kibana"]
