FROM registry.redhat.io/ubi10/go-toolset@sha256:05f3da136a4dbe077f30606e2e53a4f5cab185989c98309823ea06a9a1c52a50 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-image-processing ./cmd/image-processing

FROM registry.redhat.io/ubi10-minimal@sha256:cc3d766e796fbb50d6fcd599f4bad4c231aeae41822c6e86e7da664a996221ca

RUN \
  microdnf clean all && \
  rm -rf /var/cache/yum && \
  # The following setup is necessary so that this image can run as any user
  mkdir -p /shared-home/.docker /shared-home/.ssh && chmod -R 0777 /shared-home && \
  # This is the default user that will be used when strategy steps use different runAs configuration.
  # This must be in synchronization with our default configuration.
  echo 'nonroot:x:1000:1000:nonroot:/:/sbin/nologin' > /etc/passwd && \
  echo 'nonroot:x:1000:' > /etc/group

ENV PATH="$PATH:/ko-app"
ENV HOME="/shared-home"

COPY --from=builder /opt/app-root/src/openshift-builds-image-processing /ko-app/image-processing
COPY LICENSE /licenses/

USER 1000

ENTRYPOINT ["/ko-app/image-processing"]

LABEL \
    com.redhat.component="openshift-builds-image-processing" \
    cpe="cpe:/a:redhat:openshift_builds:1.9::el10" \
    description="Red Hat OpenShift Builds Image Processing" \
    distribution-scope="public" \
    io.k8s.description="Red Hat OpenShift Builds Image Processing" \
    io.k8s.display-name="Red Hat OpenShift Builds Image Processing" \
    io.openshift.tags="builds,image-processing" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-image-processing-rhel10" \
    release="4" \
    summary="Red Hat OpenShift Builds Image Processing" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.9.3"
