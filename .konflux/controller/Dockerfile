FROM registry.redhat.io/ubi9/go-toolset@sha256:55673c32716cf114c19d098e585b2b51b8f7c57f543a6011d8e9aa031cd996fe AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-controller ./cmd/shipwright-build-controller

FROM registry.redhat.io/ubi9-minimal@sha256:175bafd5bc7893540ed6234bb979acfe3574fd6570e6762bbc527c757f854cea

ENV PATH="$PATH:/ko-app"

COPY --from=builder /opt/app-root/src/openshift-builds-controller .
COPY LICENSE /licenses/

USER 1000

ENTRYPOINT ["./openshift-builds-controller"]

LABEL \
    com.redhat.component="openshift-builds-controller" \
    name="openshift-builds/openshift-builds-controller-rhel9" \
    version="v1.6.1" \
    summary="Red Hat OpenShift Builds Controller" \
    maintainer="openshift-builds@redhat.com" \
    description="Red Hat OpenShift Builds Controller" \
    io.k8s.description="Red Hat OpenShift Builds Controller" \
    io.k8s.display-name="Red Hat OpenShift Builds Controller" \
    io.openshift.tags="builds,controller" \
    cpe="cpe:/a:redhat:openshift_builds:1.6::el9" \
    distribution-scope="restricted" \
    release="2" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc."
