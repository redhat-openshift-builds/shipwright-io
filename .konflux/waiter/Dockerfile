FROM registry.redhat.io/ubi10/go-toolset@sha256:290ba654458e9a269b1509d10e6ebbd3c2b2456570e73e73201adb3ee54fb244 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-waiter ./cmd/waiter

FROM registry.redhat.io/ubi10-minimal@sha256:bcecd3e74c9d03eb1a596c6c8f366775a289d422ac5925ec1539924d762ebf23

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
    cpe="cpe:/a:redhat:openshift_builds:1.9::el10" \
    description="Red Hat OpenShift Builds Waiter" \
    distribution-scope="public" \
    io.k8s.description="Red Hat OpenShift Builds Waiter" \
    io.k8s.display-name="Red Hat OpenShift Builds Waiter" \
    io.openshift.tags="builds,waiter" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-waiters-rhel10" \
    release="1" \
    summary="Red Hat OpenShift Builds Waiter" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.9.0"
