FROM alpine:latest

ARG BAZARR_VERSION

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	g++ \
	gcc \
	libxml2-dev \
	libxslt-dev \
	py3-pip \
	python3-dev && \
 echo "**** install packages ****" && \
 apk add --no-cache \
	curl \
	ffmpeg \
	libxml2 \
	libxslt \
	python3 \
	unrar \
	unzip && \
 echo "**** install bazarr ****" && \
 if [ -z ${BAZARR_VERSION+x} ]; then \
	BAZARR_VERSION=$(curl -sX GET "https://api.github.com/repos/morpheus65535/bazarr/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/bazarr.tar.gz -L \
	"https://github.com/morpheus65535/bazarr/archive/${BAZARR_VERSION}.tar.gz" && \
 mkdir -p \
	/app/bazarr && \
 tar xf \
 /tmp/bazarr.tar.gz -C \
	/app/bazarr --strip-components=1 && \
 rm -Rf /app/bazarr/bin && \
 echo "**** Install requirements ****" && \
 pip3 install --no-cache-dir -U  -r \
	/app/bazarr/requirements.txt && \
 echo "**** clean up ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

# add local files
WORKDIR /app .
COPY healthcheck.sh .
COPY start.sh .
RUN chmod +x *.sh

# ports and volumes
EXPOSE 6767
VOLUME /config

HEALTHCHECK --interval=5m --timeout=5s \
  CMD /app/healthcheck.sh

ENTRYPOINT ["/app/start.sh"]
