FROM registry.redhat.io/ubi10/go-toolset@sha256:05f3da136a4dbe077f30606e2e53a4f5cab185989c98309823ea06a9a1c52a50 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-image-bundler ./cmd/bundle

FROM registry.redhat.io/ubi10-minimal@sha256:f0c7b9ae9914fcf183e7c36fc46864903c2d2caf3af327421913ae54b3d29e94

ENV PATH="$PATH:/ko-app"

COPY --from=builder /opt/app-root/src/openshift-builds-image-bundler /ko-app/bundle
COPY LICENSE /licenses/

USER 1000

ENTRYPOINT ["/ko-app/bundle"]

LABEL \
    com.redhat.component="openshift-builds-image-bundler" \
    cpe="cpe:/a:redhat:openshift_builds:1.9::el10" \
    description="Red Hat OpenShift Builds Image Bundler" \
    distribution-scope="public" \
    io.k8s.description="Red Hat OpenShift Builds Image Bundler" \
    io.k8s.display-name="Red Hat OpenShift Builds Image Bundler" \
    io.openshift.tags="builds,image-bundler" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-image-bundler-rhel10" \
    release="3" \
    summary="Red Hat OpenShift Builds Image Bundler" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.9.2"
