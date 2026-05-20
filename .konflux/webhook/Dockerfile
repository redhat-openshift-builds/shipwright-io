FROM registry.redhat.io/ubi9/go-toolset@sha256:e06a6f4c85c3ca75f64127542449c9770fb885adfb592f987c576d268ac108de AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-webhook ./cmd/shipwright-build-webhook

FROM registry.redhat.io/ubi9-minimal@sha256:24650313873554b6ba16c1a1b6b9f9142604f6ab735113e1695faf2dd07fdede

ENV PATH="$PATH:/ko-app"

COPY --from=builder /opt/app-root/src/openshift-builds-webhook .
COPY LICENSE /licenses/

USER 1000

ENTRYPOINT ["./openshift-builds-webhook"]

LABEL \
    com.redhat.component="openshift-builds-webhook" \
    name="openshift-builds/openshift-builds-webhook-rhel9" \
    version="v1.6.1" \
    summary="Red Hat OpenShift Builds webhook" \
    maintainer="openshift-builds@redhat.com" \
    description="Red Hat OpenShift Builds webhook" \
    io.k8s.description="Red Hat OpenShift Builds Webhook" \
    io.k8s.display-name="Red Hat OpenShift Builds Webhook" \
    io.openshift.tags="builds,conversion-webhook" \
    cpe="cpe:/a:redhat:openshift_builds:1.6::el9" \
    distribution-scope="restricted" \
    release="2" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc."
