FROM registry.redhat.io/ubi9/go-toolset@sha256:d4d25f236c2b3cd27eb407e3b3478bef0b75d644ee6d11772217f537be926b11 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-image-bundler ./cmd/bundle

FROM registry.redhat.io/ubi9-minimal@sha256:c4c285d42941ebb2bd4da878479008e1e4536bb599aad1dbe568f89de9053661

ENV PATH="$PATH:/ko-app"

COPY --from=builder /opt/app-root/src/openshift-builds-image-bundler /ko-app/bundle
COPY LICENSE /licenses/

USER 1000

ENTRYPOINT ["/ko-app/bundle"]

LABEL \
    com.redhat.component="openshift-builds-image-bundler" \
    cpe="cpe:/a:redhat:openshift_builds:1.8::el9" \
    description="Red Hat OpenShift Builds Image Bundler" \
    distribution-scope="public" \
    io.k8s.description="Red Hat OpenShift Builds Image Bundler" \
    io.k8s.display-name="Red Hat OpenShift Builds Image Bundler" \
    io.openshift.tags="builds,image-bundler" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-image-bundler-rhel9" \
    release="3" \
    summary="Red Hat OpenShift Builds Image Bundler" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.8.2"
