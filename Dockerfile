FROM debian:buster-slim

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config" \
PYTHONIOENCODING=utf-8

RUN \
 echo "**** install apt-transport-https first ****" && \
 apt-get update && \
 apt-get install -y apt-transport-https && \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
  git-core \
  python3-pip \
  python3-distutils && \
 echo "**** installing bazarr ****" && \
 cd /opt && \
 git clone https://github.com/morpheus65535/bazarr.git /opt/bazarr && \
 cd bazarr && \
 git checkout master && \
 pip3 install -U pip && \
 pip install -U --no-cache-dir -r requirements.txt && \
 echo "**** cleanup ****" && \
 ln -s \
	/usr/bin/python3 \
	/usr/bin/python && \
 apt-get purge --auto-remove -y \
  git-core \
	python3-pip && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*
  
WORKDIR /opt/bazarr
COPY start.sh .
COPY healthcheck.sh .
RUN chmod +x *.sh

EXPOSE 6767
VOLUME /config

HEALTHCHECK --interval=5m --timeout=5s \
  CMD /opt/bazarr/healthcheck.sh

ENTRYPOINT ["/opt/bazarr/start.sh"]
