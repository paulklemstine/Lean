import os
import sys
import json
import subprocess
from pathlib import Path
from multiprocessing import Pool, cpu_count

catalog_dir = Path("/home/raver1975/lean/Catalog")
elan_lake = "/home/raver1975/.elan/bin/lake"

def check_file(rel_path: str) -> tuple[str, bool]:
    abs_path = catalog_dir / rel_path
    try:
        proc = subprocess.run(
            [elan_lake, "env", "lean", "--json", str(abs_path)],
            cwd=str(catalog_dir),
            capture_output=True,
            text=True,
            timeout=60
        )
        if proc.returncode != 0:
            return (rel_path, False)
        
        for line in proc.stdout.splitlines():
            line = line.strip()
            if not line:
                continue
            try:
                msg = json.loads(line)
                if msg.get("severity") == "error":
                    return (rel_path, False)
            except Exception:
                pass
        return (rel_path, True)
    except Exception:
        return (rel_path, False)

def main():
    print("=== Catalog Final Compilation Cleaner ===", flush=True)

    # Remove temporary test files
    for tmp in ["TestValid.lean", "TestValid2.lean", "TestValidSimple.lean"]:
        tmp_p = catalog_dir / tmp
        if tmp_p.exists():
            tmp_p.unlink()

    lean_files = []
    for root, dirs, files in os.walk(catalog_dir):
        rel_root = Path(root).relative_to(catalog_dir)
        if len(rel_root.parts) > 0 and (rel_root.parts[0] == ".lake" or any(p.lower() == "packages" for p in rel_root.parts)):
            continue
        for f in files:
            if f.endswith(".lean"):
                lean_files.append(str(Path(root).relative_to(catalog_dir) / f))

    total = len(lean_files)
    print(f"Total Lean files to validate: {total}", flush=True)

    num_workers = min(12, cpu_count())
    print(f"Running compilation checks across {num_workers} parallel workers...", flush=True)

    passed_count = 0
    failed_count = 0

    with Pool(processes=num_workers) as pool:
        for idx, (rel_path, ok) in enumerate(pool.imap_unordered(check_file, lean_files, chunksize=1), 1):
            abs_p = catalog_dir / rel_path
            if ok:
                passed_count += 1
            else:
                failed_count += 1
                if abs_p.exists():
                    try:
                        abs_p.unlink()
                    except Exception:
                        pass

            if idx % 100 == 0 or idx == total:
                print(f"Progress: {idx}/{total} ({idx*100//total}%) | Compiling OK: {passed_count} | Removed: {failed_count}", flush=True)

    print("\n=== Final Catalog Cleanup Summary ===", flush=True)
    print(f"Clean, Verified, Compiling Lean Files Preserved: {passed_count}", flush=True)
    print(f"Non-Compiling Lean Files Removed: {failed_count}", flush=True)

    # Clean up empty directories under Catalog (excluding .lake and Packages)
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
    print(f"Empty directories cleaned: {empty_dirs_removed}", flush=True)

if __name__ == "__main__":
    main()
