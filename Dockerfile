FROM ubuntu:18.04

LABEL maintainer "Alexander Merck <alexander.t.merck@gmail.com>"
LABEL maintainer "Jesse Bowling <jessebowling@gmail.com>"
LABEL name "chn-hpfeeds-logger"
LABEL version "1.8"
LABEL release "1"
LABEL summary "Community Honey Network hpfeeds logger"
LABEL description "Small App for reading from CHN's hpfeeds broker and writing logs"
LABEL authoritative-source-url "https://github.com/CommunityHoneyNetwork/hpfeeds-logger"
LABEL changelog-url "https://github.com/CommunityHoneyNetwork/hpfeeds-logger/commits/master"

ENV playbook "hpfeeds-logger.yml"

RUN apt-get update \
    && apt-get install -y gcc git python-virtualenv python-dev python-pip runit libgeoip-dev

ADD . /opt/
RUN virtualenv /opt/hpfeeds-logger/hpfeeds-logger-test
RUN source /opt/hpfeeds-logger/hpfeeds-logger-env/bin/activate
RUN pip install -r /opt/hpfeeds-logger/requirements.txt
RUN git clone https://github.com/CommunityHoneyNetwork/hpfeeds.git /srv
RUN ln -s /srv//hpfeeds/lib/hpfeeds.py /opt/hpfeeds-logger/hpfeeds.py
COPY /opt/hpfeeds-logger.sysconfig /etc/default/hpfeeds-logger
RUN chmod 0644 /etc/default/hpfeeds-logger
RUN mkdir /etc/service/hpfeeds-logger && chmod 0755 /etc/service/hpfeeds-logger
COPY --chown=root:root /opt/hpfeeds-logger.run.j2 /etc/service/hpfeeds-logger/run
RUN chmod 0755 /etc/service/hpfeeds-logger/run

ENTRYPOINT ["/usr/bin/runsvdir", "-P", "/etc/service"]
