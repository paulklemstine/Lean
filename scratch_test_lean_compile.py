import os
import sys
import json
import subprocess
from pathlib import Path

lean_bin = "/home/raver1975/.elan/toolchains/leanprover--lean4---v4.28.0/bin/lean"
catalog_dir = Path("/home/raver1975/lean/Catalog")

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

def check_compile(filepath: Path) -> bool:
    try:
        proc = subprocess.run(
            [lean_bin, "--json", str(filepath)],
            cwd=str(catalog_dir),
            env=env,
            capture_output=True,
            text=True,
            timeout=15
        )
        if proc.returncode != 0:
            return False
        
        # Check json messages for error severity
        for line in proc.stdout.splitlines():
            line = line.strip()
            if not line:
                continue
            try:
                msg = json.loads(line)
                if msg.get("severity") == "error":
                    return False
            except Exception:
                pass
        return True
    except Exception as e:
        return False

# Test on 5 files
lean_files = []
for root, dirs, files in os.walk(catalog_dir):
    rel_root = Path(root).relative_to(catalog_dir)
    if len(rel_root.parts) > 0 and (rel_root.parts[0] == ".lake" or any(p.lower() == "packages" for p in rel_root.parts)):
        continue
    for f in files:
        if f.endswith(".lean"):
            lean_files.append(Path(root) / f)

print(f"Testing compilation check on first 10 files...")
for p in lean_files[:10]:
    ok = check_compile(p)
    print(f"  {p.relative_to(catalog_dir)} -> {'OK' if ok else 'FAIL'}")

