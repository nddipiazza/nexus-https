FROM sonatype/nexus3

LABEL maintainer="Brad Beck <bradley.beck+docker@gmail.com>"

ENV NEXUS_SSL=${NEXUS_HOME}/etc/ssl
ENV PUBLIC_CERT=${NEXUS_SSL}/cacert.pem \
    PUBLIC_CERT_SUBJ=/CN=localhost \
    PRIVATE_KEY=${NEXUS_SSL}/cakey.pem \
    PRIVATE_KEY_PASSWORD=password

USER root

RUN sed -e '/^enabled=1/ s/=1/=0/' -i /etc/yum/pluginconf.d/subscription-manager.conf \
 && yum -y update && yum install -y openssl libxml2 libxslt && yum clean all

RUN sed \
    -e '/^nexus-args/ s:$:,${jetty.etc}/jetty-https.xml:' \
    -e '/^application-port/a \
application-port-ssl=8443\
' \
    -i ${NEXUS_HOME}/etc/nexus-default.properties

COPY entrypoint.sh ${NEXUS_HOME}/entrypoint.sh
RUN chown nexus:nexus ${NEXUS_HOME}/entrypoint.sh && chmod a+x ${NEXUS_HOME}/entrypoint.sh

VOLUME [ "${NEXUS_SSL}" ]

EXPOSE 8443
WORKDIR ${NEXUS_HOME}

ENTRYPOINT [ "./entrypoint.sh" ]

CMD [ "bin/nexus", "run" ]
