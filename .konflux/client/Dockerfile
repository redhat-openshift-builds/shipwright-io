FROM registry.redhat.io/ubi10/go-toolset@sha256:26d2558491a2ec993c46fc13c68ebb7638737661825d9876b40311f5e585d7c2 AS builder

ENV GOEXPERIMENT=strictfipsruntime

USER 0

COPY hack/build-binary.sh build-binary.sh
COPY cli cli

RUN OUTPUT_DIR="/releases" VERSION="1.9.0" ./build-binary.sh

LABEL \ 
    com.redhat.component="openshift-builds-client" \
    cpe="cpe:/a:redhat:openshift_builds:1.9::el10" \
    description="Red Hat OpenShift Builds Client" \
    distribution-scope="private" \
    io.k8s.description="Red Hat OpenShift Builds Client" \
    io.k8s.display-name="Red Hat OpenShift Builds Client" \
    io.openshift.tags="builds,client" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-client-rhel10" \
    release="1" \
    summary="Red Hat OpenShift Builds Client" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.9.0"

USER 65532:65532
