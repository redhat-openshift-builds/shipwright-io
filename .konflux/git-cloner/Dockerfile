FROM registry.redhat.io/ubi10/go-toolset@sha256:935247a2ed320544d720997c59fa95f4fc6b1f01228f0494a91b7a54e6b496e6 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-git-cloner ./cmd/git

FROM registry.redhat.io/ubi10-minimal@sha256:b217fa65d8c21058887b18f005f587e47a17dd1281a5196ac88d01724a273dbd

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
    cpe="cpe:/a:redhat:openshift_builds:1.8::el9" \
    description="Red Hat OpenShift Builds git-cloner" \
    distribution-scope="public" \
    io.k8s.description="Red Hat OpenShift Builds Git Cloner" \
    io.k8s.display-name="Red Hat OpenShift Builds Git Cloner" \
    io.openshift.tags="builds,git-cloner" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-git-cloner-rhel9" \
    release="1" \
    summary="Red Hat OpenShift Builds git Cloner" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.8.0"
