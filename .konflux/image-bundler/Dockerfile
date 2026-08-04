FROM registry.access.redhat.com/hi/go@sha256:5fc103bed56527348adfac3c035f3402d28546c9818d8340dc5dd5f0e3d486fe AS builder

WORKDIR /opt/app-root/src
COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-image-bundler ./cmd/bundle

FROM registry.access.redhat.com/hi/core-runtime@sha256:8e597a23a81b65132b7d64d827eb723b035324ec4565ab7aed442540ffbc0841

WORKDIR /

ENV GODEBUG=fips140=on
ENV PATH="$PATH:/ko-app"

COPY --from=builder /opt/app-root/src/openshift-builds-image-bundler /ko-app/bundle
COPY LICENSE /licenses/

USER 1000

ENTRYPOINT ["/ko-app/bundle"]

LABEL \
    com.redhat.component="openshift-builds-image-bundler" \
    cpe="cpe:/a:redhat:openshift_builds:1.8::el10" \
    description="Red Hat OpenShift Builds Image Bundler" \
    distribution-scope="public" \
    io.k8s.description="Red Hat OpenShift Builds Image Bundler" \
    io.k8s.display-name="Red Hat OpenShift Builds Image Bundler" \
    io.openshift.tags="builds,image-bundler" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-image-bundler-rhel10" \
    release="1" \
    summary="Red Hat OpenShift Builds Image Bundler" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.8.0"
