FROM python:3.9.1-slim-buster

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

RUN \
 echo "**** install apt packages ****" && \
 apt-get update && \
 apt-get upgrade -y && \
 apt-get install -y \
 unrar-free libatlas-base-dev \
 git-core && \
 echo "**** download and install bazarr ****"&& \
 git clone https://github.com/morpheus65535/bazarr.git /opt/bazarr && \
 python3 -m pip install -r /opt/bazarr/requirements.txt && \
 echo "**** cleanup ****" && \
 apt-get remove --purge -y git-core && \
 apt-get autoremove -y && apt-get clean && \
 rm -rf /var/lib/apt/lists/* && \
 echo DONE


# add local files
WORKDIR /opt/
COPY healthcheck.sh .
COPY start.sh .
RUN chmod +x *.sh

# ports and volumes
EXPOSE 6767
VOLUME /config

HEALTHCHECK --interval=5m --timeout=5s \
  CMD /opt/healthcheck.sh

ENTRYPOINT ["/opt/start.sh"]
