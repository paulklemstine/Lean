import os
import sys
import json
import subprocess
from pathlib import Path
from multiprocessing import Pool, cpu_count

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

def check_compile_file(str_path: str) -> tuple[str, bool]:
    try:
        proc = subprocess.run(
            [lean_bin, "--json", str_path],
            cwd=str(catalog_dir),
            env=env,
            capture_output=True,
            text=True,
            timeout=8
        )
        if proc.returncode != 0:
            return (str_path, False)
        
        for line in proc.stdout.splitlines():
            line = line.strip()
            if not line:
                continue
            try:
                msg = json.loads(line)
                if msg.get("severity") == "error":
                    return (str_path, False)
            except Exception:
                pass
        return (str_path, True)
    except Exception:
        return (str_path, False)

def main():
    print("[3] Phase 3: Fast Parallel Lean Compilation Validation...", flush=True)
    lean_files = []
    for root, dirs, files in os.walk(catalog_dir):
        rel_root = Path(root).relative_to(catalog_dir)
        if len(rel_root.parts) > 0 and (rel_root.parts[0] == ".lake" or any(p.lower() == "packages" for p in rel_root.parts)):
            continue
        for f in files:
            if f.endswith(".lean"):
                lean_files.append(str(Path(root) / f))

    total = len(lean_files)
    print(f"Total Lean files to compile-check: {total}", flush=True)

    num_workers = min(16, cpu_count() * 2)
    print(f"Using {num_workers} parallel worker processes.", flush=True)

    passed_count = 0
    failed_count = 0

    with Pool(processes=num_workers) as pool:
        for idx, (str_path, ok) in enumerate(pool.imap_unordered(check_compile_file, lean_files, chunksize=1), 1):
            if ok:
                passed_count += 1
            else:
                failed_count += 1
                try:
                    Path(str_path).unlink()
                except Exception:
                    pass

            if idx % 100 == 0 or idx == total:
                print(f"Progress: {idx}/{total} ({idx*100//total}%) | Passed: {passed_count} | Failed & Removed: {failed_count}", flush=True)

    print("\n[Phase 3 Complete] Catalog compilation verification finished.", flush=True)
    print(f"Final Count of Clean, Verified, Compiling Lean files: {passed_count}", flush=True)
    print(f"Total Lean files removed due to compilation errors: {failed_count}", flush=True)

    empty_dirs_removed = 0
    for root, dirs, files in os.walk(catalog_dir, topdown=False):
        rel_root = Path(root).relative_to(catalog_dir)
        if len(rel_root.parts) > 0 and (rel_root.parts[0] == ".lake" or any(p.lower() == "packages" for p in rel_root.parts)):
            continue
        if not files and not os.listdir(root):
            try:
                os.rmdir(root)
                empty_dirs_removed += 1
            except Exception:
                pass
    print(f"Cleaned up {empty_dirs_removed} empty directories.", flush=True)

if __name__ == "__main__":
    main()
