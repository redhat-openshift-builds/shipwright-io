FROM registry.redhat.io/ubi9/go-toolset@sha256:82b82ecf4aedf67c4369849047c2680dba755fe57547bbb05eca211b22038e29 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY hack/build-binary.sh build-binary.sh
COPY cli cli

RUN OUTPUT_DIR="/releases" ./build-binary.sh

LABEL \ 
    com.redhat.component="openshift-builds-client" \
    cpe="cpe:/a:redhat:openshift_builds:1.7::el9" \
    description="Red Hat OpenShift Builds Client" \
    distribution-scope="private" \
    io.k8s.description="Red Hat OpenShift Builds Client" \
    io.k8s.display-name="Red Hat OpenShift Builds Client" \
    io.openshift.tags="builds,client" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-client-rhel9" \
    release="1" \
    summary="Red Hat OpenShift Builds Client" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.7.0"
