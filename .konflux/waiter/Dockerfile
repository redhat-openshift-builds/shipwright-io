FROM registry.redhat.io/ubi9/go-toolset@sha256:71101fd9ba32aabeaec2c073e5786c91642aaee902475fce3d8280457fb19e9d AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-waiter ./cmd/waiter

FROM registry.redhat.io/ubi9-minimal@sha256:69f5c9886ecb19b23e88275a5cd904c47dd982dfa370fbbd0c356d7b1047ef68

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
    name="openshift-builds/openshift-builds-waiter-rhel9" \
    version="v1.6.1" \
    summary="Red Hat OpenShift Builds Waiter" \
    maintainer="openshift-builds@redhat.com" \
    description="Red Hat OpenShift Builds Waiter" \
    io.k8s.description="Red Hat OpenShift Builds Waiter" \
    io.k8s.display-name="Red Hat OpenShift Builds Waiter" \
    io.openshift.tags="builds,waiter" \
    cpe="cpe:/a:redhat:openshift_builds:1.6::el9" \
    distribution-scope="restricted" \
    release="2" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc."
