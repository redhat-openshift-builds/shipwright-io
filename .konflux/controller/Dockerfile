FROM registry.redhat.io/ubi10/go-toolset@sha256:5b963df4afc1fe44e33e524450c98eb20b12e4a3c00120dcc66afcac2309652b AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-controller ./cmd/shipwright-build-controller

FROM registry.redhat.io/ubi10-minimal@sha256:e3a5632d7ae8a97e06f634522d06187f12793e90ac0d7b51bc671c83a96d8eda

ENV PATH="$PATH:/ko-app"

COPY --from=builder /opt/app-root/src/openshift-builds-controller .
COPY LICENSE /licenses/

USER 1000

ENTRYPOINT ["./openshift-builds-controller"]

LABEL \
    com.redhat.component="openshift-builds-controller" \
    cpe="cpe:/a:redhat:openshift_builds:1.9::el10" \
    description="Red Hat OpenShift Builds Controller" \
    distribution-scope="public" \
    io.k8s.description="Red Hat OpenShift Builds Controller" \
    io.k8s.display-name="Red Hat OpenShift Builds Controller" \
    io.openshift.tags="builds,controller" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-controller-rhel10" \
    release="1" \
    summary="Red Hat OpenShift Builds Controller" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.9.0"
