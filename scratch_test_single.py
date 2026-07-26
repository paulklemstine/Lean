import os
import json
import subprocess
from pathlib import Path

catalog_dir = Path("/home/raver1975/lean/Catalog")
elan_lean = "/home/raver1975/.elan/bin/lean"

env = os.environ.copy()
env["LEAN_PATH"] = (
    "/home/raver1975/lean/Catalog/.lake/packages/Cli/.lake/build/lib/lean:"
    "/home/raver1975/lean/Catalog/.lake/packages/batteries/.lake/build/lib/lean:"
    "/home/raver1975/lean/Catalog/.lake/packages/Qq/.lake/build/lib/lean:"
    "/home/raver1975/lean/Catalog/.lake/packages/aesop/.lake/build/lib/lean:"
    "/home/raver1975/lean/Catalog/.lake/packages/proofwidgets/.lake/build/lib/lean:"
    "/home/raver1975/lean/Catalog/.lake/packages/importGraph/.lake/build/lib/lean:"
    "/home/raver1975/lean/Catalog/.lake/packages/LeanSearchClient/.lake/build/lib/lean:"
    "/home/raver1975/lean/Catalog/.lake/packages/plausible/.lake/build/lib/lean:"
    "/home/raver1975/lean/Catalog/.lake/packages/mathlib/.lake/build/lib/lean:"
    "/home/raver1975/lean/Catalog/.lake/build/lib/lean:"
    "/home/raver1975/.elan/toolchains/leanprover--lean4---v4.28.0/lib/lean"
)
env["LEAN_SRC_PATH"] = (
    "/home/raver1975/lean/Catalog/.lake/packages/mathlib:"
    "/home/raver1975/lean/Catalog"
)

target = catalog_dir / "Tropical/Core/NewResearch.lean"
print(f"Testing direct lean invocation on {target}...")

proc = subprocess.run([elan_lean, "--json", str(target)], cwd=str(catalog_dir), env=env, capture_output=True, text=True)
print(f"Return code: {proc.returncode}")
for line in proc.stdout.splitlines()[:5]:
    print(f"STDOUT: {line}")
for line in proc.stderr.splitlines()[:5]:
    print(f"STDERR: {line}")

