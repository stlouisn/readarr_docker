FROM stlouisn/ubuntu:latest AS dl

ARG TARGETARCH

ARG APP_VERSION

ARG DEBIAN_FRONTEND=noninteractive

RUN \

    # Update apt-cache
    apt-get update && \

    # Install jq
    apt-get install -y --no-install-recommends \
        curl && \

    # Download Readarr
    if [ "arm" = "$TARGETARCH" ] ; then curl -o /tmp/readarr.tar.gz -sSL "http://readarr.servarr.com/v1/update/develop/updatefile?os=linux&runtime=netcore&arch=arm" ; fi && \
    if [ "arm64" = "$TARGETARCH" ] ; then curl -o /tmp/readarr.tar.gz -sSL "http://readarr.servarr.com/v1/update/develop/updatefile?os=linux&runtime=netcore&arch=arm64" ; fi && \
    if [ "amd64" = "$TARGETARCH" ] ; then curl -o /tmp/readarr.tar.gz -sSL "http://readarr.servarr.com/v1/update/develop/updatefile?os=linux&runtime=netcore&arch=x64" ; fi && \

    # Extract Readarr
    mkdir -p /userfs && \
    tar -xf /tmp/readarr.tar.gz -C /userfs/ && \

    # Disable Readarr-Update
    rm -r /userfs/Readarr/Readarr.Update/

FROM stlouisn/ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive

COPY rootfs /

RUN \

    # Create readarr group
    groupadd \
        --system \
        --gid 10000 \
        readarr && \

    # Create readarr user
    useradd \
        --system \
        --no-create-home \
        --shell /sbin/nologin \
        --comment readarr \
        --gid 10000 \
        --uid 10000 \
        readarr && \

    # Update apt-cache
    apt-get update && \

    # Install sqlite
    apt-get install -y --no-install-recommends \
        sqlite3 && \

    # Install unicode support
    apt-get install -y --no-install-recommends \
        libicu70 && \

    # Clean apt-cache
    apt-get autoremove -y --purge && \
    apt-get autoclean -y && \

    # Cleanup temporary folders
    rm -rf \
        /root/.cache \
        /root/.wget-hsts \
        /tmp/* \
        /usr/local/man \
        /usr/local/share/man \
        /usr/share/doc \
        /usr/share/doc-base \
        /usr/share/man \
        /var/cache \
        /var/lib/apt \
        /var/log/*

COPY --chown=readarr:readarr --from=dl /userfs /

VOLUME /config

ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
