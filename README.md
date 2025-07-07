# shipwright-io
Shipwright - a framework for building container images on Kubernetes

## Regenerating RPM Lockfile on Mac

The `rpms.lock.yaml` file contains resolved dependencies for packages needed by this project. When the package requirements change (in `rpms.in.yaml`), you may need to regenerate the lockfile.

### Prerequisites

1. **Podman CLI**: Install using Homebrew:
   ```bash
   brew install podman
   ```
2. **Podman Desktop**: Install and start [Podman Desktop](https://podman-desktop.io/) on your Mac

### Steps to Regenerate

1. **Navigate to the project root**:
   ```bash
   cd /path/to/shipwright-io
   ```

2. **Clone the rpm-lockfile-prototype repository** (if not already present):
   ```bash
   cd ..
   git clone https://github.com/konflux-ci/rpm-lockfile-prototype.git
   cd shipwright-io
   ```

3. **Build the rpm-lockfile-prototype container** (one-time setup):
   ```bash
   cd ../rpm-lockfile-prototype
   podman build -f Containerfile -t localhost/rpm-lockfile-prototype .
   cd ../shipwright-io
   ```

4. **Regenerate the lockfile**:
   ```bash
   podman run --rm -v ${PWD}:/work localhost/rpm-lockfile-prototype:latest \
     --image registry.access.redhat.com/ubi9-minimal:9.6 (or the version you are using)\
     --outfile=/work/rpms.lock.yaml \
     /work/rpms.in.yaml
   ```

### What this does

- Uses the correct **UBI 9 Minimal base image** to match our Dockerfiles
- Resolves dependencies for packages listed in `rpms.in.yaml`: `git`, `git-lfs`, `tar`
- Generates lockfile for all supported architectures: `x86_64`, `aarch64`, `s390x`, `ppc64le`
- Creates a reproducible build environment for CI/CD pipelines

### Important Notes

- **Base image alignment**: The command uses image (`registry.access.redhat.com/ubi9-minimal:9.6`) which matches the base image used in our `.konflux/*/Dockerfile` files
- **Container approach**: Required on Mac since DNF libraries are not available natively
- **Architecture support**: The tool automatically handles cross-architecture dependency resolution
- **Public registry**: Uses the public Red Hat registry to avoid authentication requirements

### Troubleshooting

- **Podman errors**: Ensure Podman Desktop is running and the machine is started
- **Network issues**: Verify internet connectivity to access UBI repositories
- **Permission errors**: The container runs as the current user, so file permissions should be preserved