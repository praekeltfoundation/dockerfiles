FROM pypy:2-5.3.1-slim
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# pip: Disable cache and use Praekelt Foundation Python Package Index
ENV PIP_NO_CACHE_DIR="false" \
    PIP_EXTRA_INDEX_URL="https://jessie.wheelhouse.praekelt.org/simple"

# Install utility scripts
COPY ./common/scripts /scripts
COPY ./debian/scripts /scripts
ENV PATH $PATH:/scripts

# Install dinit (dumb-init)
ENV DINIT_VERSION="1.1.2" \
    DINIT_SHA256="3a994810864576b2fd4c87b7513976e8a7dff11a5e1fa1784297ff23380c1c3d"
RUN set -x \
    && apt-get-install.sh curl \
    && cd /tmp \
    && DINIT_DEB_FILE="dumb-init_${DINIT_VERSION}_amd64.deb" \
    && curl -sSL -O "https://github.com/Yelp/dumb-init/releases/download/v$DINIT_VERSION/$DINIT_DEB_FILE" \
    && echo "$DINIT_SHA256 *$DINIT_DEB_FILE" | sha256sum -c - \
    && dpkg --install $DINIT_DEB_FILE \
    && rm $DINIT_DEB_FILE \
    && ln -s $(which dumb-init) /usr/local/bin/dinit \
    && apt-get-purge.sh curl

# Set dinit as the default entrypoint
ENTRYPOINT ["dinit"]
CMD ["pypy"]
