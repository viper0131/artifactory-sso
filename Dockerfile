FROM centos:centos7

ARG NEXUS=https://artifactory-zgw-ci.apps.sbx.ocp.zgw-services.nl/zgw/repository/zgw
ENV ARTIFACTORY_VERSION=6.3.3 \
    DOWNLOAD_URL="https://bintray.com/jfrog/artifactory/download_file?file_path=" \
    PG_LIB_VERSION=42.2.2

# Setup global database variables
ENV DB_USERNAME=artifactory \
    DB_PASSWORD=none \
    DB_NAME=artifactory \
    DB_HOST=postgresql \
    DB_PORT=5432 \
    JDBC_CLASS=org.postgresql.Driver \
    JDBC_DB_TYPE=postgresql \
    JDBC_URL_SUFFIX=''
ENV ARTIFACTORY_USER_NAME=artifactory \
    ARTIFACTORY_USER_ID=1030 \
    ARTIFACTORY_HOME=/opt/jfrog/artifactory \
    ARTIFACTORY_DATA=/var/opt/jfrog/artifactory \
    RECOMMENDED_MAX_OPEN_FILES=32000 \
    MIN_MAX_OPEN_FILES=10000 \
    RECOMMENDED_MAX_OPEN_PROCESSES=1024 \
    POSTGRESQL_VERSION=9.4.1212 


RUN yum -y install unzip
RUN set -ex \
    && mkdir -pv /opt/jfrog

#COPY assets/artifactory-oss.zip /opt/jfrog/artifactory-oss.zip
RUN  curl -sL -o /opt/jfrog/artifactory-oss.zip \
            ${DOWNLOAD_URL}jfrog-artifactory-oss-${ARTIFACTORY_VERSION}.zip
RUN unzip -q /opt/jfrog/artifactory-oss.zip -d /opt/jfrog/ 
RUN mv ${ARTIFACTORY_HOME}-oss-${ARTIFACTORY_VERSION}/ ${ARTIFACTORY_HOME}/
RUN rm -rf ${ARTIFACTORY_HOME}/etc ${ARTIFACTORY_HOME}/logs /opt/jfrog/artifactory-oss.zip
RUN sed -i "s/nofiles/${ARTIFACTORY_USER_NAME}/" /etc/group
RUN set -x; adduser --shell /sbin/nologin --no-create-home -u ${ARTIFACTORY_USER_ID} ${ARTIFACTORY_USER_NAME}
RUN chown -R ${ARTIFACTORY_USER_ID}:0 ${ARTIFACTORY_HOME} && \
    chmod -R 0775 ${ARTIFACTORY_HOME}

COPY assets/entrypoint.sh /entrypoint.sh

WORKDIR ${ARTIFACTORY_HOME} 

RUN yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel

ENTRYPOINT ["/entrypoint.sh"]
