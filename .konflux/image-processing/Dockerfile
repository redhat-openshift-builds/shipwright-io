FROM registry.redhat.io/ubi9/go-toolset@sha256:71f121a44270e46a17a548d6b92096a1a0fb56db44927ad318d095177d6dce4b AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-image-processing ./cmd/image-processing

FROM registry.redhat.io/ubi9-minimal@sha256:161a4e29ea482bab6048c2b36031b4f302ae81e4ff18b83e61785f40dc576f5d

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
    version="v1.5.2" \
    summary="Red Hat OpenShift Builds Image Processing" \
    maintainer="openshift-builds@redhat.com" \
    description="Red Hat OpenShift Builds Image Processing" \
    io.k8s.description="Red Hat OpenShift Builds Image Processing" \
    io.k8s.display-name="Red Hat OpenShift Builds Image Processing" \
    io.openshift.tags="builds,image-processing" \
    cpe="cpe:/a:redhat:openshift_builds:1.5::el9" \
    distribution-scope="public" \
    url="https://catalog.redhat.com/en/software/container-stacks/detail/6565a473b9526bf84dae4d85" \
    vendor="Red Hat, Inc." \
    release="1.5.2"
