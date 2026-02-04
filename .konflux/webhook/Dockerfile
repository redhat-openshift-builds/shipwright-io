FROM registry.redhat.io/ubi9/go-toolset@sha256:71f121a44270e46a17a548d6b92096a1a0fb56db44927ad318d095177d6dce4b AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-webhook ./cmd/shipwright-build-webhook

FROM registry.redhat.io/ubi9-minimal@sha256:ecd4751c45e076b4e1e8d37ac0b1b9c7271930c094d1bcc5e6a4d6954c6b2289

ENV PATH="$PATH:/ko-app"

COPY --from=builder /opt/app-root/src/openshift-builds-webhook .
COPY LICENSE /licenses/

USER 1000

ENTRYPOINT ["./openshift-builds-webhook"]

LABEL \
    com.redhat.component="openshift-builds-webhook" \
    name="openshift-builds/openshift-builds-webhook-rhel9" \
    version="v1.5.2" \
    summary="Red Hat OpenShift Builds webhook" \
    maintainer="openshift-builds@redhat.com" \
    description="Red Hat OpenShift Builds webhook" \
    io.k8s.description="Red Hat OpenShift Builds Webhook" \
    io.k8s.display-name="Red Hat OpenShift Builds Webhook" \
    io.openshift.tags="builds,conversion-webhook" \
    cpe="cpe:/a:redhat:openshift_builds:1.5::el9" \
    distribution-scope="public" \
    url="https://catalog.redhat.com/en/software/container-stacks/detail/6565a473b9526bf84dae4d85" \
    vendor="Red Hat, Inc." \
    release="1.5.2"
