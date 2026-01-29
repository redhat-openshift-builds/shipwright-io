#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

APP_NAME="shp"
VERSION="main"
# Use absolute path for output so it works regardless of where we 'cd' later
# This creates 'releases' in the directory where the script is run
OUTPUT_DIR="$(pwd)/releases"
SRC_DIR="cli"
BUILD_PATH="./cmd/shp"

mkdir -p "$OUTPUT_DIR"

# List of targets in format "OS/ARCH"
TARGETS=(
    "linux/amd64"
    "linux/arm64"
    "linux/s390x"
    "linux/ppc64le"
    "darwin/amd64"
    "darwin/arm64"
    "windows/amd64"
)

echo ">>> Starting Cross-Compilation..."
echo ">>> Source Directory: $SRC_DIR"
echo ">>> Output Directory: $OUTPUT_DIR"

# Enter the source directory (where go.mod likely resides)
cd "$SRC_DIR"

for target in "${TARGETS[@]}"; do
    # Split the target into OS and ARCH
    GOOS=${target%/*}
    GOARCH=${target#*/}

    # Determine file extension for the BINARY
    EXT=""
    if [ "$GOOS" == "windows" ]; then
        EXT=".exe"
    fi

    # Binary name (needs .exe on Windows to run)
    BINARY_FILENAME="${APP_NAME}-${GOOS}-${GOARCH}${EXT}"
    # Archive name (clean, no .exe in the tar.gz filename)
    ARCHIVE_FILENAME="openshift-build-client-${VERSION}-${GOOS}-${GOARCH}.tar.gz"
    
    FULL_BINARY_PATH="${OUTPUT_DIR}/${BINARY_FILENAME}"

    echo "[+] Building for $GOOS/$GOARCH..."

    # Build command targeting ./cmd/shp
    env CGO_ENABLED=0 GOOS=$GOOS GOARCH=$GOARCH go build -ldflags="-s -w" -o "$FULL_BINARY_PATH" "$BUILD_PATH"

    # Package the binary
    # We temporarily switch to the output directory to tar the file cleanly
    pushd "$OUTPUT_DIR" > /dev/null
    
    echo "    -> Packaging $ARCHIVE_FILENAME..."
    tar -czf "$ARCHIVE_FILENAME" "$BINARY_FILENAME"
    
    # Remove the raw binary to save space
    rm "$BINARY_FILENAME"
    
    popd > /dev/null
done

echo ">>> Build complete! Artifacts are in: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"
