FROM python:3.9.1-slim-buster

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ARG BAZARR_VERSION

RUN \
 echo "**** install apt packages ****" && \
 apt-get update && \
 apt-get upgrade -y && \
 apt-get install -y \
 unrar-free libatlas-base-dev \
 unzip curl gcc && \
 echo "**** download and install bazarr ****"&& \
 echo "**** install bazarr ****" && \
 if [ -z ${BAZARR_VERSION+x} ]; then \
	BAZARR_VERSION=$(curl -sX GET "https://api.github.com/repos/morpheus65535/bazarr/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/bazarr.tar.gz -L \
	"https://github.com/morpheus65535/bazarr/archive/${BAZARR_VERSION}.tar.gz" && \
 mkdir -p \
	/opt/bazarr && \
 tar xf \
 /tmp/bazarr.tar.gz -C \
	/opt/bazarr --strip-components=1 && \
 rm -Rf /opt/bazarr/bin && \
 pip install --no-cache-dir -r /opt/bazarr/requirements.txt && \
 echo "**** cleanup ****" && \
 apt-get remove --purge -y gcc && \
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
