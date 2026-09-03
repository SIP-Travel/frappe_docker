#!/usr/bin/env python3
"""Fail early if apps.json file:// paths are missing or not git checkouts."""
import json
import os
import sys
from urllib.parse import urlparse

apps_path = sys.argv[1] if len(sys.argv) > 1 else "/opt/frappe/apps.json"
apps = json.load(open(apps_path))

for app in apps:
    url = app.get("url") or ""
    parsed = urlparse(url)
    if parsed.scheme != "file":
        continue
    path = parsed.path
    print(f"checking {url} -> {path}")
    if not os.path.isdir(path):
        print(f"ERROR: missing local app path: {path}", file=sys.stderr)
        sys.exit(1)
    if not os.path.isdir(os.path.join(path, ".git")):
        print(f"ERROR: {path} is not a git checkout (.git missing)", file=sys.stderr)
        sys.exit(1)
    print(f"OK: {path}")
