#!/bin/sh
# SPDX-License-Identifier: AGPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 grommunio GmbH
#
# Packs src/ into a Keycloak theme jar. Needs only python3 (no jar/zip binaries).
# Usage: ./build.sh [output.jar]   (default: grommunio-theme.jar in the repo root)
set -eu
cd "$(dirname "$0")"
exec python3 - "${1:-grommunio-theme.jar}" <<'PY'
import os, sys, time, zipfile

SRC = "src"
out = sys.argv[1]
epoch = int(os.environ.get("SOURCE_DATE_EPOCH", "0") or 0)
stamp = time.gmtime(epoch)[:6] if epoch else (1980, 1, 1, 0, 0, 0)
manifest = "Manifest-Version: 1.0\r\nCreated-By: grommunio keycloak-theme build.sh\r\n\r\n"


def add(zf, name, data):
    zi = zipfile.ZipInfo(name, stamp)
    if name.endswith("/"):
        zi.external_attr = (0o40755 << 16) | 0x10
        zi.compress_type = zipfile.ZIP_STORED
    else:
        zi.external_attr = 0o644 << 16
        zi.compress_type = zipfile.ZIP_DEFLATED
    zf.writestr(zi, data)


files = []
for root, dirs, names in os.walk(SRC):
    dirs.sort()
    for n in sorted(names):
        path = os.path.join(root, n)
        rel = os.path.relpath(path, SRC).replace(os.sep, "/")
        if rel == "META-INF/MANIFEST.MF":
            continue
        files.append((rel, path))

if not any(rel == "META-INF/keycloak-themes.json" for rel, _ in files):
    sys.exit("src/META-INF/keycloak-themes.json missing")

tmp = out + ".tmp"
with zipfile.ZipFile(tmp, "w") as zf:
    seen = {"META-INF/"}
    add(zf, "META-INF/", b"")
    add(zf, "META-INF/MANIFEST.MF", manifest.encode())
    for rel, path in files:
        parts = rel.split("/")
        for i in range(1, len(parts)):
            d = "/".join(parts[:i]) + "/"
            if d not in seen:
                seen.add(d)
                add(zf, d, b"")
        with open(path, "rb") as f:
            add(zf, rel, f.read())
os.replace(tmp, out)
print(out)
PY
