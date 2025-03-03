FROM registry.access.redhat.com/ubi9/go-toolset@sha256:703937e152d049e62f5aa8ab274a4253468ab70f7b790d92714b37cf0a140555 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-webhook ./cmd/shipwright-build-webhook

FROM registry.access.redhat.com/ubi9-minimal@sha256:14f14e03d68f7fd5f2b18a13478b6b127c341b346c86b6e0b886ed2b7573b8e0

COPY --from=builder /opt/app-root/src/openshift-builds-webhook .
COPY LICENSE /licenses/

USER 1001

ENTRYPOINT ["./openshift-builds-webhook"]

LABEL \
    com.redhat.component="openshift-builds-webhook" \
    name="openshift-builds/webhook" \
    version="v1.3.0" \
    summary="Red Hat OpenShift Builds webhook" \
    maintainer="openshift-builds@redhat.com" \
    description="Red Hat OpenShift Builds webhook" \
    io.k8s.description="Red Hat OpenShift Builds Webhook" \
    io.k8s.display-name="Red Hat OpenShift Builds Webhook" \
    io.openshift.tags="builds,conversion-webhook"
