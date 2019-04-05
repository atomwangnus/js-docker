# Copyright (c) 2016. TIBCO Software Inc.
# This file is subject to the license terms contained
# in the license file that is distributed with this file.
# version: 6.3.0-v1.0.4



FROM tomcat:8.0-jre8
ARG JRS_VERSION=7.1.1
# Copy jasperreports-server-<ver> zip file from resources dir.
# Build will fail if file not present.

#DOWNLOAD JASPERSERVER BIN ZIP from gcs

#RUN wget "https://storage.cloud.google.com/gke-shared/jasperreport/${JRS_VERSION}/jasperserver_${JRS_VERSION}_bin.zip" -O resources/jasperreports-server.zip --no-verbose

RUN mkdir -p /usr/src/jasperreports-server/
RUN mkdir -p /usr/local/share/jasperreports-pro/WEB-INF/lib/
RUN mkdir -p /usr/local/share/jasperreports-pro/WEB-INF/

#RUN wget "https://storage.cloud.google.com/gke-shared/jasperreport/license/jasperserver.license" -O /usr/src/jasperreports-server/jasperserver.license --no-verbose

#copy the WEB-INF extra files
#RUN wget "https://storage.cloud.google.com/gke-shared/jasperreport/${JRS_VERSION}/WEB-INF/applicationContext-externalAuth-Keycloak.xml" -O /usr/local/share/jasperreports-pro/WEB-INF/applicationContext-externalAuth-Keycloak.xml --no-verbose

#RUN wget "https://storage.cloud.google.com/gke-shared/jasperreport/${JRS_VERSION}/WEB-INF/slave.json" -O /usr/local/share/jasperreports-pro/WEB-INF/slave.json --no-verbose


#copy the WEB-INF/LIB
#RUN wget "https://storage.cloud.google.com/gke-shared/jasperreport/${JRS_VERSION}/WEB-INF/lib/jasperserver-keycloak-adapter-0.0.3-SNAPSHOT.jar" -O /usr/local/share/jasperreports-pro/WEB-INF/lib/jasperserver-keycloak-adapter-0.0.3-SNAPSHOT.jar --no-verbose

#RUN wget "https://storage.cloud.google.com/gke-shared/jasperreport/${JRS_VERSION}/WEB-INF/lib/keycloak-adapter-core-2.5.5.Final.jar" -O /usr/local/share/jasperreports-pro/WEB-INF/lib/keycloak-adapter-core-2.5.5.Final.jar --no-verbose

#RUN wget "https://storage.cloud.google.com/gke-shared/jasperreport/${JRS_VERSION}/WEB-INF/lib/keycloak-adapter-spi-2.5.5.Final.jar" -O /usr/local/share/jasperreports-pro/WEB-INF/lib/keycloak-adapter-spi-2.5.5.Final.jar --no-verbose

#RUN wget "https://storage.cloud.google.com/gke-shared/jasperreport/${JRS_VERSION}/WEB-INF/lib/keycloak-common-2.5.5.Final.jar" -O /usr/local/share/jasperreports-pro/WEB-INF/lib/keycloak-common-2.5.5.Final.jar --no-verbose

#RUN wget "https://storage.cloud.google.com/gke-shared/jasperreport/${JRS_VERSION}/WEB-INF/lib/keycloak-core-2.5.5.Final.jar" -O /usr/local/share/jasperreports-pro/WEB-INF/lib/keycloak-core-2.5.5.Final.jar --no-verbose

#RUN wget "https://storage.cloud.google.com/gke-shared/jasperreport/${JRS_VERSION}/WEB-INF/lib/keycloak-spring-security-adapter-2.5.5.Final.jar" -O /usr/local/share/jasperreports-pro/WEB-INF/lib/keycloak-spring-security-adapter-2.5.5.Final.jar --no-verbose

COPY resources/jasperreports-server*zip /tmp/jasperserver.zip
COPY resources/WEB-INF/lib/*.jar /usr/local/share/jasperreports-pro/WEB-INF/lib/
COPY resources/WEB-INF/applicationContext-externalAuth-Keycloak.xml	 /usr/local/share/jasperreports-pro/WEB-INF/
COPY resources/WEB-INF/slave.json	 /usr/local/share/jasperreports-pro/WEB-INF/

RUN apt-get update && apt-get install -y postgresql-client unzip xmlstarlet && \
    rm -rf /var/lib/apt/lists/* && \
    unzip /tmp/jasperserver.zip -d /usr/src/ && \
    mv /usr/src/jasperreports-server-* /usr/src/jasperreports-server && \
    mkdir -p /usr/local/share/jasperreports-pro/license && \
    rm -rf /tmp/*

# Extract phantomjs, move to /usr/local/share/phantomjs, link to /usr/local/bin.
# Comment out if phantomjs not required.
RUN wget \
    "https://bitbucket.org/ariya/phantomjs/downloads/\
phantomjs-2.1.1-linux-x86_64.tar.bz2" \
    -O /tmp/phantomjs.tar.bz2 --no-verbose && \
    tar -xjf /tmp/phantomjs.tar.bz2 -C /tmp && \
    rm -f /tmp/phantomjs.tar.bz2 && \
    mv /tmp/phantomjs*linux-x86_64 /usr/local/share/phantomjs && \
    ln -sf /usr/local/share/phantomjs/bin/phantomjs /usr/local/bin && \
    rm -rf /tmp/*
# In case you wish to download from a different location you can manually
# download the archive and copy from resources/ at build time. Note that you
# also # need to comment out the preceding RUN command
#COPY resources/phantomjs*bz2 /tmp/phantomjs.tar.bz2
#RUN tar -xjf /tmp/phantomjs.tar.bz2 -C /tmp && \
#    rm -f /tmp/phantomjs.tar.bz2 && \
#    mv /tmp/phantomjs*linux-x86_64 /usr/local/share/phantomjs && \
#    ln -sf /usr/local/share/phantomjs/bin/phantomjs /usr/local/bin && \
#    rm -rf /tmp/*

# Set default environment options.
ENV CATALINA_OPTS="${JAVA_OPTIONS:--Xmx2g -XX:+UseParNewGC \
    -XX:+UseConcMarkSweepGC} \
    -Djs.license.directory=${JRS_LICENSE:-/usr/local/share/jasperreports-pro/license}"

# Configure tomcat for SSL (optional). Uncomment ENV and RUN to enable generation of
# self-signed certificate and to set up JasperReports Server to use HTTPS only.
#
#ENV DN_HOSTNAME=${DN_HOSTNAME:-localhost.localdomain} \
#    KS_PASSWORD=${KS_PASSWORD:-changeit} \
#    JRS_HTTPS_ONLY=${JRS_HTTPS_ONLY:-true} \
#    HTTPS_PORT=${HTTPS_PORT:-8443}
#
#RUN keytool -genkey -alias self_signed -dname "CN=${DN_HOSTNAME}" \
#        -keyalg RSA -storepass "${KS_PASSWORD}" \
#        -keypass "${KS_PASSWORD}" \
#        -keystore /root/.keystore && \
#    xmlstarlet ed --inplace --subnode "/Server/Service" --type elem \
#        -n Connector -v "" --var connector-ssl '$prev' \
#    --insert '$connector-ssl' --type attr -n port -v "${HTTPS_PORT:-8443}" \
#    --insert '$connector-ssl' --type attr -n protocol -v \
#        "org.apache.coyote.http11.Http11NioProtocol" \
#    --insert '$connector-ssl' --type attr -n maxThreads -v "150" \
#    --insert '$connector-ssl' --type attr -n SSLEnabled -v "true" \
#    --insert '$connector-ssl' --type attr -n scheme -v "https" \
#    --insert '$connector-ssl' --type attr -n secure -v "true" \
#    --insert '$connector-ssl' --type attr -n clientAuth -v "false" \
#    --insert '$connector-ssl' --type attr -n sslProtocol -v "TLS" \
#    --insert '$connector-ssl' --type attr -n keystorePass \
#        -v "${KS_PASSWORD}"\
#    --insert '$connector-ssl' --type attr -n keystoreFile \
#        -v "/root/.keystore" \
#    ${CATALINA_HOME}/conf/server.xml

# Expose ports. Note that you must do one of the following:
# map them to local ports at container runtime via "-p 8080:8080 -p 8443:8443"
# or use dynamic ports.
EXPOSE ${HTTP_PORT:-8080} ${HTTPS_PORT:-8443}

COPY scripts/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

# Default action executed by entrypoint script.
CMD ["run"]
