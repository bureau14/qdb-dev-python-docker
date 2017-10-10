FROM       ubuntu:xenial

ARG        QDB_VERSION=2.1.0master
ENV        QDB_DEB_VERSION=1
ENV        TERM=dumb

RUN apt-get clean && apt-get update \
    && apt-get install -y locales net-tools iproute2 vim wget

RUN apt-get install -y python2.7
RUN apt-get install -y python-matplotlib
RUN apt-get install -y ipython
RUN apt-get install -y ipython-notebook
RUN apt-get install -y python-pandas
RUN apt-get -y install python-setuptools

# Install core dependencies
COPY       qdb-server_${QDB_VERSION}-${QDB_DEB_VERSION}.deb .
COPY       qdb-web-bridge_${QDB_VERSION}-${QDB_DEB_VERSION}.deb .
COPY       qdb-utils_${QDB_VERSION}-${QDB_DEB_VERSION}.deb .
COPY       qdb-api_${QDB_VERSION}-${QDB_DEB_VERSION}.deb .
RUN        dpkg -i qdb-server_${QDB_VERSION}-${QDB_DEB_VERSION}.deb
RUN        dpkg -i qdb-web-bridge_${QDB_VERSION}-${QDB_DEB_VERSION}.deb
RUN        dpkg -i qdb-utils_${QDB_VERSION}-${QDB_DEB_VERSION}.deb
RUN        dpkg -i qdb-api_${QDB_VERSION}-${QDB_DEB_VERSION}.deb

# PHP
COPY       quasardb-${QDB_VERSION}.tgz .
RUN        pecl install quasardb-${QDB_VERSION}.tgz

# Python
COPY       quasardb-${QDB_VERSION}-py2.7-linux-x86_64.egg .
RUN        easy_install quasardb-${QDB_VERSION}-py2.7-linux-x86_64.egg

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Define working directory
WORKDIR    /var/lib/qdb

ADD        qdb-dev-docker-wrapper.sh /usr/sbin/
ADD        qdb.ipynb /var/lib/qdb/


# Always launch qdb process
ENTRYPOINT ["/usr/sbin/qdb-dev-docker-wrapper.sh"]

# Expose the port qdbd is listening at
EXPOSE     2836
EXPOSE     8080
EXPOSE     8081
