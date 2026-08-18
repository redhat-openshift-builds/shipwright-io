FROM registry.redhat.io/ubi9/go-toolset@sha256:b2bc0c6c92c56dce575ed1b2dec1ec9f8b345a80ef5e74d9bfd530b6b354feeb AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-image-bundler ./cmd/bundle

FROM registry.redhat.io/ubi9-minimal@sha256:8eb2830d0936237fc13a1f2f7e45aecf90d69043380ad167fad0343632937f41

ENV PATH="$PATH:/ko-app"

COPY --from=builder /opt/app-root/src/openshift-builds-image-bundler /ko-app/bundle
COPY LICENSE /licenses/

USER 1000

ENTRYPOINT ["/ko-app/bundle"]

LABEL \
    com.redhat.component="openshift-builds-image-bundler" \
    cpe="cpe:/a:redhat:openshift_builds:1.7::el9" \
    description="Red Hat OpenShift Builds Image Bundler" \
    distribution-scope="public" \
    io.k8s.description="Red Hat OpenShift Builds Image Bundler" \
    io.k8s.display-name="Red Hat OpenShift Builds Image Bundler" \
    io.openshift.tags="builds,image-bundler" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-image-bundler-rhel9" \
    release="1" \
    summary="Red Hat OpenShift Builds Image Bundler" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.7.0"
