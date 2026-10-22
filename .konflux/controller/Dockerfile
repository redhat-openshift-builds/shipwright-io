FROM registry.redhat.io/ubi9/go-toolset@sha256:d4d25f236c2b3cd27eb407e3b3478bef0b75d644ee6d11772217f537be926b11 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-controller ./cmd/shipwright-build-controller

FROM registry.redhat.io/ubi9-minimal@sha256:1d7c5517a4a1a8e2688620b39ee980e82505ca1ab7ae5541b5463120ae9b3897

ENV PATH="$PATH:/ko-app"

COPY --from=builder /opt/app-root/src/openshift-builds-controller .
COPY LICENSE /licenses/

USER 1000

ENTRYPOINT ["./openshift-builds-controller"]

LABEL \
    com.redhat.component="openshift-builds-controller" \
    cpe="cpe:/a:redhat:openshift_builds:1.8::el9" \
    description="Red Hat OpenShift Builds Controller" \
    distribution-scope="public" \
    io.k8s.description="Red Hat OpenShift Builds Controller" \
    io.k8s.display-name="Red Hat OpenShift Builds Controller" \
    io.openshift.tags="builds,controller" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-controller-rhel9" \
    release="3" \
    summary="Red Hat OpenShift Builds Controller" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.8.2"
