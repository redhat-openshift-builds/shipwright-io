FROM registry.redhat.io/ubi9/go-toolset@sha256:23c7cb17e9c53a65f9ab01f2edf1a4e07c9a9dc2258ed63d69e06925e7cea381 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-webhook ./cmd/shipwright-build-webhook

FROM registry.redhat.io/ubi9-minimal@sha256:08d4c70f1baf6537a0728656cf7942d561e74a35916509d205b6519861266352

ENV PATH="$PATH:/ko-app"

COPY --from=builder /opt/app-root/src/openshift-builds-webhook .
COPY LICENSE /licenses/

USER 1000

ENTRYPOINT ["./openshift-builds-webhook"]

LABEL \
    com.redhat.component="openshift-builds-webhook" \
    cpe="cpe:/a:redhat:openshift_builds:1.8::el9" \
    description="Red Hat OpenShift Builds Webhook" \
    distribution-scope="public" \
    io.k8s.description="Red Hat OpenShift Builds Webhook" \
    io.k8s.display-name="Red Hat OpenShift Builds Webhook" \
    io.openshift.tags="builds,webhook" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-webhook-rhel9" \
    release="5" \
    summary="Red Hat OpenShift Builds Webhook" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.8.4"
