FROM brew.registry.redhat.io/rh-osbs/openshift-golang-builder:rhel_9_1.23 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-waiter ./cmd/waiter

FROM registry.access.redhat.com/ubi9-minimal@sha256:ac61c96b93894b9169221e87718733354dd3765dd4a62b275893c7ff0d876869

RUN \
  microdnf --assumeyes --nodocs install tar && \
  microdnf clean all && \
  rm -rf /var/cache/yum && \
  echo 'nonroot:x:1000:1000:nonroot:/:/sbin/nologin' > /etc/passwd && \
  echo 'nonroot:x:1000:' > /etc/group && \
  mkdir /.docker && \
  chown 1000:1000 /.docker

COPY --from=builder /openshift-builds-waiter /ko-app/waiter
COPY LICENSE /licenses/

USER 1001

ENTRYPOINT ["/ko-app/waiter"]

LABEL \
    com.redhat.component="openshift-builds-waiter" \
    name="openshift-builds/waiter" \
    version="v1.3.0" \
    summary="Red Hat OpenShift Builds Waiter" \
    maintainer="openshift-builds@redhat.com" \
    description="Red Hat OpenShift Builds Waiter" \
    io.k8s.description="Red Hat OpenShift Builds Waiter" \
    io.k8s.display-name="Red Hat OpenShift Builds Waiter" \
    io.openshift.tags="builds,waiter"
