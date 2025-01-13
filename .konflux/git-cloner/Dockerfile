FROM registry.access.redhat.com/ubi9/go-toolset@sha256:6ec9c3ce36c929ff98c1e82a8b7fb6c79df766d1ad8009844b59d97da9afed43 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-git-cloner ./cmd/git

FROM registry.access.redhat.com/ubi9-minimal@sha256:d85040b6e3ed3628a89683f51a38c709185efc3fb552db2ad1b9180f2a6c38be

RUN \
  microdnf --assumeyes --nodocs install git git-lfs && \
  microdnf clean all && \
  rm -rf /var/cache/yum && \
  echo 'nonroot:x:1000:1000:nonroot:/:/sbin/nologin' > /etc/passwd && \
  echo 'nonroot:x:1000:' > /etc/group && \
  mkdir /.docker && chown 1000:1000 /.docker && \
  mkdir /.ssh && chown 1000:1000 /.ssh

COPY --from=builder /opt/app-root/src/openshift-builds-git-cloner /ko-app/git
COPY LICENSE /licenses/

USER 1001

ENTRYPOINT ["/ko-app/git"]

LABEL \
    com.redhat.component="openshift-builds-git-cloner" \
    name="openshift-builds/git-cloner" \
    version="v1.3.0" \
    summary="Red Hat OpenShift Builds Git Cloner" \
    maintainer="openshift-builds@redhat.com" \
    description="Red Hat OpenShift Builds Git Cloner" \
    io.k8s.description="Red Hat OpenShift Builds Git Cloner" \
    io.k8s.display-name="Red Hat OpenShift Builds Git Cloner" \
    io.openshift.tags="builds,git-cloner"
