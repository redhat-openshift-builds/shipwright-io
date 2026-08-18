FROM registry.redhat.io/ubi10/go-toolset@sha256:1db86a2b0f77c1197b011de5140236effc27b1a1724c0105d4926857a0756de5 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-git-cloner ./cmd/git

FROM registry.redhat.io/ubi10-minimal@sha256:61f820b7893b6226e499e928db99c59a0a9135aa17e4e056fdaf1015908cca14

RUN \
  microdnf --assumeyes --nodocs install git git-lfs && \
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

COPY --from=builder /opt/app-root/src/openshift-builds-git-cloner /ko-app/git
COPY LICENSE /licenses/

USER 1000

ENTRYPOINT ["/ko-app/git"]

LABEL \
    com.redhat.component="openshift-builds-git-cloner" \
    cpe="cpe:/a:redhat:openshift_builds:1.9::el10" \
    description="Red Hat OpenShift Builds git-cloner" \
    distribution-scope="public" \
    io.k8s.description="Red Hat OpenShift Builds Git Cloner" \
    io.k8s.display-name="Red Hat OpenShift Builds Git Cloner" \
    io.openshift.tags="builds,git-cloner" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-git-cloner-rhel10" \
    release="1" \
    summary="Red Hat OpenShift Builds git Cloner" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.9.0"
