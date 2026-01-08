FROM registry.redhat.io/ubi9/go-toolset@sha256:380d6de9bbc5a42ca13d425be99958fb397317664bb8a00e49d464e62cc8566c AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY hack/build-binary.sh build-binary.sh
COPY cli cli

RUN OUTPUT_DIR="/releases" ./build-binary.sh

LABEL \ 
    com.redhat.component="openshift-builds-client" \
    name="openshift-builds/client" \
    version="v1.6.0" \
    summary="Red Hat OpenShift Builds Client" \
    maintainer="openshift-builds@redhat.com" \
    description="Red Hat OpenShift Builds Client" \
    io.k8s.description="Red Hat OpenShift Builds Client" \
    io.k8s.display-name="Red Hat OpenShift Builds Client" \  
    io.openshift.tags="builds,cli"
