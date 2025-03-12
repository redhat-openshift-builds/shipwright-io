FROM registry.access.redhat.com/ubi9/go-toolset@sha256:703937e152d049e62f5aa8ab274a4253468ab70f7b790d92714b37cf0a140555 AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-webhook ./cmd/shipwright-build-webhook

FROM registry.access.redhat.com/ubi9-minimal@sha256:30bbd445046a3a63f5f5557a3c67dee74e3c8e7855eb0347630b020f3689823f

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
