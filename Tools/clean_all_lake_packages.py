#!/usr/bin/env python3
import os
import subprocess
from pathlib import Path

packages_dir = Path("Catalog/.lake/packages")

if packages_dir.exists():
    for pkg in packages_dir.iterdir():
        if pkg.is_dir() and (pkg / ".git").exists():
            print(f"[PackageClean] Cleaning {pkg.name}...")
            subprocess.run(["git", "reset", "--hard", "HEAD"], cwd=pkg, capture_output=True)
            subprocess.run(["git", "clean", "-fd"], cwd=pkg, capture_output=True)

print("[PackageClean Complete] All Lake packages clean.")
