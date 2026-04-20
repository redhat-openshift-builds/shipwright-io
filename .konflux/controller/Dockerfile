FROM registry.redhat.io/ubi9/go-toolset@sha256:1e1c89558f8bf86db3d88e5d5de0b6bd396ef948749a2c5d6a752ea46f35d4db AS builder

ENV GOEXPERIMENT=strictfipsruntime

COPY build .

RUN CGO_ENABLED=1 GO111MODULE=on go build -a -mod=vendor -ldflags="-s -w" -tags="strictfipsruntime" -o openshift-builds-controller ./cmd/shipwright-build-controller

FROM registry.redhat.io/ubi9-minimal@sha256:fe688da81a696387ca53a4c19231e99289591f990c904ef913c51b6e87d4e4df

ENV PATH="$PATH:/ko-app"

COPY --from=builder /opt/app-root/src/openshift-builds-controller .
COPY LICENSE /licenses/

USER 1000

ENTRYPOINT ["./openshift-builds-controller"]

LABEL \
    com.redhat.component="openshift-builds-controller" \
    cpe="cpe:/a:redhat:openshift_builds:1.7::el9" \
    description="Red Hat OpenShift Builds Controller" \
    distribution-scope="public" \
    io.k8s.description="Red Hat OpenShift Builds Controller" \
    io.k8s.display-name="Red Hat OpenShift Builds Controller" \
    io.openshift.tags="builds,controller" \
    maintainer="openshift-builds@redhat.com" \
    name="openshift-builds/openshift-builds-controller-rhel9" \
    release="1" \
    summary="Red Hat OpenShift Builds Controller" \
    url="https://github.com/redhat-openshift-builds/shipwright-io" \
    vendor="Red Hat, Inc." \
    version="v1.7.0"
