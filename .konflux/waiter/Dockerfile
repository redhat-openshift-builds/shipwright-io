FROM registry.redhat.io/ubi9/go-toolset@sha256:59ec4752cf86f0d0dd240b9e29c64d6ee560c28fc986171e126db1db216a246a AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-waiter ./cmd/waiter

FROM registry.redhat.io/ubi9-minimal@sha256:b9b10f42d7eba7ad4a6d5ef26b7d34fdc892b2ffe59b8d0372ec884008569eb6

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
    cpe="cpe:/a:redhat:openshift_builds:1.7::el9" \
    description="Red Hat OpenShift Builds Waiter" \
    distribution-scope="public" \
    io.k8s.description="Red Hat OpenShift Builds Waiter" \
    io.k8s.display-name="Red Hat OpenShift Builds Waiter" \
    io.openshift.tags="builds,waiter" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-waiters-rhel9" \
    release="1" \
    summary="Red Hat OpenShift Builds Waiter" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.7.0"
