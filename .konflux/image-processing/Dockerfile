FROM registry.redhat.io/ubi9/go-toolset@sha256:8b211cc8793d8013140844e8070aa584a8eb3e4e6e842ea4b03dd9914b1a5dc6 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-image-processing ./cmd/image-processing

FROM registry.redhat.io/ubi9-minimal@sha256:69f5c9886ecb19b23e88275a5cd904c47dd982dfa370fbbd0c356d7b1047ef68

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
    name="openshift-builds/openshift-builds-image-processing-rhel9" \
    version="v1.6.1" \
    summary="Red Hat OpenShift Builds Image Processing" \
    maintainer="openshift-builds@redhat.com" \
    description="Red Hat OpenShift Builds Image Processing" \
    io.k8s.description="Red Hat OpenShift Builds Image Processing" \
    io.k8s.display-name="Red Hat OpenShift Builds Image Processing" \
    io.openshift.tags="builds,image-processing" \
    cpe="cpe:/a:redhat:openshift_builds:1.6::el9" \
    distribution-scope="restricted" \
    release="2" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc."
