FROM registry.redhat.io/ubi10/go-toolset@sha256:a7e505b797c95c8e618a364de3a8c0383882935a12a1222a376d667c65d119b8 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-controller ./cmd/shipwright-build-controller

FROM registry.redhat.io/ubi10-minimal@sha256:61f820b7893b6226e499e928db99c59a0a9135aa17e4e056fdaf1015908cca14

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
