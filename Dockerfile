FROM ubuntu

ENV DEBIAN_FRONTEND=noninteractive

ARG BUILDKIT_UID=1000
ARG BUILDKIT_GID=$BUILDKIT_UID
RUN addgroup --gid=$BUILDKIT_GID buildkit
RUN useradd --home-dir /buildkit --create-home --uid $BUILDKIT_UID --gid $BUILDKIT_GID buildkit
COPY buildkit-sudoers /etc/sudoers.d/buildkit
COPY --chown=buildkit:buildkit services.yml /buildkit/.amp/services.yml

RUN echo "America/Sao_Paulo" > /etc/timezone && \
    apt update && \
    apt install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php -y && \
    apt install -y sudo \
        curl \
        git \
        unzip \
        zip \
        lsb-release \
        php5.6-cli \
        php5.6-common \
        php5.6-curl \
        php5.6-gd \
        php5.6-imap \
        php5.6-intl \
        php5.6-json \
        php5.6-gettext \
        php5.6-mcrypt \
        php5.6-mysqli \
        php5.6-mbstring \
        php5.6-xml \
        mysql-server && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt install -y nodejs && \
    curl -O https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt install -fy ./google-chrome-stable_current_amd64.deb && \
    rm -rf google-chrome-stable_current_amd64.deb && \
    apt purge -y software-properties-common && \
    apt autoremove -y --purge && \
    apt-get clean && \
    service mysql restart && \
    mysql -e "CREATE USER 'buildkit'@'localhost' IDENTIFIED BY 'pass'; GRANT ALL ON *.* to 'buildkit'@'localhost' IDENTIFIED BY 'pass' WITH GRANT OPTION; FLUSH PRIVILEGES" && \
    su - buildkit -c "git clone https://github.com/civicrm/civicrm-buildkit /buildkit/buildkit" && \
    su - buildkit -c "/buildkit/buildkit/bin/civi-download-tools" && \
    su - buildkit -c "/buildkit/buildkit/bin/civibuild create drupal-clean --civi-ver 5.3.1" && \
    rm -rf /tmp/*
