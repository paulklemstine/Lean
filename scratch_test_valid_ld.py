import os
import json
import subprocess
from pathlib import Path

catalog_dir = Path("/home/raver1975/lean/Catalog")
elan_lean = "/home/raver1975/.elan/toolchains/leanprover--lean4---v4.28.0/bin/lean"

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
env["LD_LIBRARY_PATH"] = (
    "/home/raver1975/.elan/toolchains/leanprover--lean4---v4.28.0/lib/lean:"
    "/home/raver1975/.elan/toolchains/leanprover--lean4---v4.28.0/lib:"
    "/home/raver1975/lean/Catalog/.lake/build/lib:"
    "/home/raver1975/lean/Catalog/.lake/packages/mathlib/.lake/build/lib:"
    "/home/raver1975/lean/Catalog/.lake/packages/plausible/.lake/build/lib:"
    "/home/raver1975/lean/Catalog/.lake/packages/LeanSearchClient/.lake/build/lib:"
    "/home/raver1975/lean/Catalog/.lake/packages/importGraph/.lake/build/lib:"
    "/home/raver1975/lean/Catalog/.lake/packages/proofwidgets/.lake/build/lib:"
    "/home/raver1975/lean/Catalog/.lake/packages/aesop/.lake/build/lib:"
    "/home/raver1975/lean/Catalog/.lake/packages/Qq/.lake/build/lib:"
    "/home/raver1975/lean/Catalog/.lake/packages/batteries/.lake/build/lib:"
    "/home/raver1975/lean/Catalog/.lake/packages/Cli/.lake/build/lib"
)

test_file = catalog_dir / "TestValid.lean"
print(f"Testing direct lean with LD_LIBRARY_PATH on {test_file.name}...")

proc = subprocess.run([elan_lean, "--json", str(test_file)], cwd=str(catalog_dir), env=env, capture_output=True, text=True)
print(f"Return code: {proc.returncode}")

has_error = False
for line in proc.stdout.splitlines():
    if line.strip():
        try:
            msg = json.loads(line)
            if msg.get("severity") == "error":
                has_error = True
                print(f"  Error: {msg.get('text')}")
        except Exception:
            pass

if proc.returncode == 0 and not has_error:
    print("TestValid.lean PASSED COMPILATION 100%!")
else:
    print("TestValid.lean FAILED COMPILATION")

