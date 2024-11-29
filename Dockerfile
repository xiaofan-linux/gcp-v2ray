FROM  alpine:latest
LABEL maintainer="V2Fly Community <dev@v2fly.org>"

# `docker buildx` automatically sets this arg value
ARG TARGETARCH

# The repository contains latest stable releases and nightlies built for multiple architectures
ARG V2RAY_VERSION="v5.22.0"
ARG V2RAY_URL="https://github.com/v2fly/v2ray-core/releases/download/${V2RAY_VERSION}/v2ray-linux-64.zip"
ARG V2RAY_AMD64_SHA256SUM="ab181a2f70ea4c5536e98660c3462f5f2b3775e6268ee27dec91c8c80b0da946"

RUN echo "mkdir v2ray ..." \
    && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray

# copy in static files
# all scripts are 0755 (rwx r-x r-x)
COPY entrypoint /usr/local/bin/
COPY config.json /etc/v2ray/

RUN echo "Installing v2ray ..." \
    && wget -q --tries=5 --output-document=/tmp/v2ray-linux.${TARGETARCH}.zip "${V2RAY_URL}" \
    && echo "${V2RAY_AMD64_SHA256SUM}  /tmp/v2ray-linux.${TARGETARCH}.zip" | tee /tmp/v2ray.sha256 \
    && sha256sum -c /tmp/v2ray.sha256 \
    && cd /tmp; unzip /tmp/v2ray-linux.${TARGETARCH}.zip \
    && cd /tmp; mv v2ray /usr/bin/ \
    && cd /tmp; mv geosite.dat geoip.dat /usr/local/share/v2ray/ \
    && rm -rf /tmp/*

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint"]
