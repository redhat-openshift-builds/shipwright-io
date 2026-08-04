FROM registry.access.redhat.com/hi/go@sha256:5fc103bed56527348adfac3c035f3402d28546c9818d8340dc5dd5f0e3d486fe AS builder

WORKDIR /opt/app-root/src
COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-git-cloner ./cmd/git

FROM registry.access.redhat.com/hi/go@sha256:24a845aaae98720e94f76cfd396a1a73daa9f27ce5c4a600c20687739b4b8a84

USER 0
WORKDIR /

# TARGETARCH comes from --platform (do not use uname -m; wrong under Mac/Podman qemu)
ARG TARGETARCH=amd64

RUN \
  dnf install -y git curl tar gzip && \
  case "${TARGETARCH}" in \
    amd64) LFS_ARCH=linux-amd64 ;; \
    arm64) LFS_ARCH=linux-arm64 ;; \
    *) echo "unsupported TARGETARCH=${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fsSL -o /tmp/git-lfs.tgz \
    "https://github.com/git-lfs/git-lfs/releases/download/v3.6.1/git-lfs-${LFS_ARCH}-v3.6.1.tar.gz" && \
  tar -xzf /tmp/git-lfs.tgz -C /tmp && \
  install -m 0755 /tmp/git-lfs-3.6.1/git-lfs /usr/bin/git-lfs && \
  test -x /usr/bin/git-lfs && \
  rm -rf /tmp/git-lfs.tgz /tmp/git-lfs-3.6.1 && \
  dnf clean all && \
  mkdir -p /shared-home/.docker /shared-home/.ssh && chmod -R 0777 /shared-home && \
  echo 'nonroot:x:1000:1000:nonroot:/:/sbin/nologin' > /etc/passwd && \
  echo 'nonroot:x:1000:' > /etc/group

ENV GODEBUG=fips140=on
ENV PATH="/usr/bin:/usr/sbin:/ko-app:${PATH}"
ENV HOME="/shared-home"

COPY --from=builder /opt/app-root/src/openshift-builds-git-cloner /ko-app/git
COPY LICENSE /licenses/

USER 1000

ENTRYPOINT ["/ko-app/git"]

LABEL \
    com.redhat.component="openshift-builds-git-cloner" \
    cpe="cpe:/a:redhat:openshift_builds:1.8::el10" \
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
    version="v1.8.0"
