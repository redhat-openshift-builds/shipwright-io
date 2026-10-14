FROM registry.redhat.io/ubi9/go-toolset@sha256:f9e171ed4a2ecfd284b6d977d60f6a0ed33eac8628ad806a80cdf3521cb8bede AS builder

ENV GOEXPERIMENT=strictfipsruntime

USER 0

COPY hack/build-binary.sh build-binary.sh
COPY cli cli

RUN OUTPUT_DIR="/releases" VERSION="1.8.0" ./build-binary.sh

LABEL \ 
    com.redhat.component="openshift-builds-client" \
    cpe="cpe:/a:redhat:openshift_builds:1.8::el9" \
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
    version="v1.8.0"

USER 65532:65532
