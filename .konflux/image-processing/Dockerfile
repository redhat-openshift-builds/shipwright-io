FROM registry.redhat.io/ubi9/go-toolset@sha256:8b211cc8793d8013140844e8070aa584a8eb3e4e6e842ea4b03dd9914b1a5dc6 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-image-processing ./cmd/image-processing

FROM registry.redhat.io/ubi9-minimal@sha256:83006d535923fcf1345067873524a3980316f51794f01d8655be55d6e9387183

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
    cpe="cpe:/a:redhat:openshift_builds:1.7::el9" \
    description="Red Hat OpenShift Builds Image Processing" \
    distribution-scope="public" \
    io.k8s.description="Red Hat OpenShift Builds Image Processing" \
    io.k8s.display-name="Red Hat OpenShift Builds Image Processing" \
    io.openshift.tags="builds,image-processing" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-image-processing-rhel9" \
    release="1" \
    summary="Red Hat OpenShift Builds Image Processing" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.7.0"
