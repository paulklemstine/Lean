import os
import sys
import json
import subprocess
from pathlib import Path
from multiprocessing import Pool

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
    "/home/raver1975/lean/Catalog/.lake/packages/mathlib/.lake/build/lib"
)

def check_file(str_path: str) -> tuple[str, bool, str]:
    try:
        proc = subprocess.run(
            [elan_lean, "--json", str_path],
            cwd=str(catalog_dir),
            env=env,
            capture_output=True,
            text=True,
            timeout=60
        )
        if proc.returncode != 0:
            err_msg = proc.stderr.strip()[:60] or f"exit {proc.returncode}"
            return (str_path, False, err_msg)
        
        for line in proc.stdout.splitlines():
            line = line.strip()
            if not line:
                continue
            try:
                msg = json.loads(line)
                if msg.get("severity") == "error":
                    return (str_path, False, f"Lean error: {msg.get('text', '')[:60]}")
            except Exception:
                pass
        return (str_path, True, "OK")
    except subprocess.TimeoutExpired:
        return (str_path, False, "Timeout (60s)")
    except Exception as e:
        return (str_path, False, str(e))

def main():
    lean_files = []
    for root, dirs, files in os.walk(catalog_dir):
        rel_root = Path(root).relative_to(catalog_dir)
        if len(rel_root.parts) > 0 and (rel_root.parts[0] == ".lake" or any(p.lower() == "packages" for p in rel_root.parts)):
            continue
        for f in files:
            if f.endswith(".lean"):
                lean_files.append(str(Path(root) / f))

    print(f"Testing 20 files with direct lean binary + full env...", flush=True)
    with Pool(processes=8) as pool:
        for str_path, ok, reason in pool.imap_unordered(check_file, lean_files[:20], chunksize=1):
            rel_p = Path(str_path).relative_to(catalog_dir)
            print(f"  {rel_p} -> {'PASSED' if ok else 'FAILED (' + reason + ')'}", flush=True)

if __name__ == "__main__":
    main()
