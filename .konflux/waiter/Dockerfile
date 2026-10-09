FROM registry.redhat.io/ubi9/go-toolset@sha256:6f246e8913d082df463b62a74c72f0d2b410583e1b2ac48add39cd7ede59ce62 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-waiter ./cmd/waiter

FROM registry.redhat.io/ubi9-minimal@sha256:1d7c5517a4a1a8e2688620b39ee980e82505ca1ab7ae5541b5463120ae9b3897

RUN \
  microdnf --assumeyes --nodocs install tar && \
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

COPY --from=builder /opt/app-root/src/openshift-builds-waiter /ko-app/waiter
COPY LICENSE /licenses/

USER 1000

ENTRYPOINT ["/ko-app/waiter"]

LABEL \
    com.redhat.component="openshift-builds-waiter" \
    cpe="cpe:/a:redhat:openshift_builds:1.8::el9" \
    description="Red Hat OpenShift Builds Waiter" \
    distribution-scope="public" \
    io.k8s.description="Red Hat OpenShift Builds Waiter" \
    io.k8s.display-name="Red Hat OpenShift Builds Waiter" \
    io.openshift.tags="builds,waiter" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-waiters-rhel9" \
    release="3" \
    summary="Red Hat OpenShift Builds Waiter" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.8.2"
