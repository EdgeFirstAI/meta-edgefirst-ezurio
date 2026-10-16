#!/bin/bash
# Publish an EdgeFirst Yocto for Ezurio release to the EdgeFirst repo.
#
#   publish-release.sh [--dry-run] MACHINE VERSION DEPLOY_DIR
#
# VERSION is YYYY.MM.PATCH and must match the EDGEFIRST_RELEASE the image was
# built with, which names the files in DEPLOY_DIR.
#
# Layout under s3://edgefirst-repo/ezurio/ (https://repo.edgefirst.ai/ezurio/):
#
#   edgefirst-root.crt.pem                    trust anchor, for reference
#   edgefirst-ezurio.crt.pem                  Ezurio intermediate, for reference
#   <machine>/latest.json                     the one mutable object
#   <machine>/<version>/<name>.swu            SWUpdate package (fw_update)
#   <machine>/<version>/<name>.wic.bz2        full media image
#   <machine>/<version>/<name>.wic.bmap       block map for bmaptool
#   <machine>/<version>/SHA256SUMS
#
# Everything under <version>/ is immutable and cached for a year; a release is
# never replaced, a fix is a new PATCH. The prefix is anonymously readable, so
# no signed URLs are involved.
set -euo pipefail

DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then DRY_RUN=true; shift; fi

USAGE="usage: publish-release.sh [--dry-run] MACHINE VERSION DEPLOY_DIR"
MACHINE="${1:?$USAGE}"
VERSION="${2:?$USAGE}"
DEPLOY_DIR="${3:?$USAGE}"

[[ "$VERSION" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{1,2}$ ]] || { echo "VERSION must be YYYY.MM.PATCH: $VERSION" >&2; exit 1; }

PRODUCT="EdgeFirst Yocto for Ezurio"
VENDOR="ezurio"
BUCKET="s3://edgefirst-repo/$VENDOR"
BASE_URL="https://repo.edgefirst.ai/$VENDOR"
DISTRIBUTION_ID="ENV44D23AY6RF"
CA_DIR="${EDGEFIRST_CERT_PATH:?EDGEFIRST_CERT_PATH must point at the EdgeFirst CA directory}"
ROOT_CRT="$CA_DIR/root/edgefirst-root.crt.pem"
INT_CRT="$CA_DIR/$VENDOR/edgefirst-$VENDOR.crt.pem"

STEM="image-edgefirst-$MACHINE-$VERSION"
PUBLISHED_STEM="edgefirst-yocto-$VENDOR-$MACHINE-$VERSION"
EXTENSIONS=(swu wic.bz2 wic.bmap)

for f in "$ROOT_CRT" "$INT_CRT"; do
    [ -f "$f" ] || { echo "missing $f" >&2; exit 1; }
done
for ext in "${EXTENSIONS[@]}"; do
    [ -f "$DEPLOY_DIR/$STEM.$ext" ] || { echo "missing $DEPLOY_DIR/$STEM.$ext (was it built with EDGEFIRST_RELEASE=$VERSION?)" >&2; exit 1; }
done

WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

# Never publish a package a device would reject: the signature has to be
# present and has to chain to the root the images trust. The default verify
# purpose is deliberate; it is the S/MIME one the device applies, which a leaf
# without the emailProtection key usage fails.
SWU="$DEPLOY_DIR/$STEM.swu"
( cd "$WORK" && cpio -id --quiet sw-description sw-description.sig < "$SWU" ) \
    || { echo "$SWU has no sw-description.sig; it is not signed" >&2; exit 1; }
openssl cms -verify -binary -inform DER -in "$WORK/sw-description.sig" \
    -content "$WORK/sw-description" -CAfile "$ROOT_CRT" -out /dev/null 2>"$WORK/verify.log" \
    || { echo "signature on $SWU does not verify against $ROOT_CRT" >&2; cat "$WORK/verify.log" >&2; exit 1; }
echo "==> $STEM.swu signature verifies against the EdgeFirst root"

if ! $DRY_RUN && aws s3 ls "$BUCKET/$MACHINE/$VERSION/" --only-show-errors | grep -q .; then
    echo "$VERSION is already published for $MACHINE; releases are immutable, publish a new PATCH" >&2
    exit 1
fi

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
: > "$WORK/SHA256SUMS"
declare -A SHA SIZE
for ext in "${EXTENSIONS[@]}"; do
    src="$(readlink -f "$DEPLOY_DIR/$STEM.$ext")"
    ln -s "$src" "$WORK/$PUBLISHED_STEM.$ext"
    SHA[$ext]="$(sha256sum "$src" | cut -d' ' -f1)"
    SIZE[$ext]="$(stat -c%s "$src")"
    echo "${SHA[$ext]}  $PUBLISHED_STEM.$ext" >> "$WORK/SHA256SUMS"
    echo "    $PUBLISHED_STEM.$ext  $(numfmt --to=iec "${SIZE[$ext]}")"
done

VERSION_URL="$BASE_URL/$MACHINE/$VERSION"
cat > "$WORK/latest.json" <<JSON
{
  "product": "$PRODUCT",
  "machine": "$MACHINE",
  "version": "$VERSION",
  "published": "$NOW",
  "swu": {
    "url": "$VERSION_URL/$PUBLISHED_STEM.swu",
    "sha256": "${SHA[swu]}",
    "size": ${SIZE[swu]}
  },
  "wic": {
    "url": "$VERSION_URL/$PUBLISHED_STEM.wic.bz2",
    "bmap": "$VERSION_URL/$PUBLISHED_STEM.wic.bmap",
    "sha256": "${SHA[wic.bz2]}",
    "size": ${SIZE[wic.bz2]}
  },
  "sha256sums": "$VERSION_URL/SHA256SUMS",
  "keyring": "$BASE_URL/edgefirst-root.crt.pem"
}
JSON

run() { if $DRY_RUN; then echo "[dry-run] $*"; else "$@"; fi; }

for ext in "${EXTENSIONS[@]}"; do
    case "$ext" in
        swu|wic.bz2) type=application/octet-stream ;;
        *)           type=application/xml ;;
    esac
    run aws s3 cp "$WORK/$PUBLISHED_STEM.$ext" "$BUCKET/$MACHINE/$VERSION/$PUBLISHED_STEM.$ext" \
        --content-type "$type" --cache-control "public, max-age=31536000, immutable" --only-show-errors
done
run aws s3 cp "$WORK/SHA256SUMS" "$BUCKET/$MACHINE/$VERSION/SHA256SUMS" \
    --content-type text/plain --cache-control "public, max-age=31536000, immutable" --only-show-errors

for crt in "$ROOT_CRT" "$INT_CRT"; do
    run aws s3 cp "$crt" "$BUCKET/$(basename "$crt")" \
        --content-type application/x-pem-file --cache-control "public, max-age=300" --only-show-errors
done

# latest.json is the only mutable object, so it gets a short TTL and is
# uploaded last: it never points at a release that is not fully in place.
run aws s3 cp "$WORK/latest.json" "$BUCKET/$MACHINE/latest.json" \
    --content-type application/json --cache-control "public, max-age=60, must-revalidate" --only-show-errors

run aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" \
    --paths "/$VENDOR/$MACHINE/latest.json" "/$VENDOR/edgefirst-root.crt.pem" "/$VENDOR/edgefirst-$VENDOR.crt.pem" \
    --query 'Invalidation.Id' --output text

echo "==> $PRODUCT $VERSION for $MACHINE"
echo "    $VERSION_URL/"
echo "    pointer  $BASE_URL/$MACHINE/latest.json"
