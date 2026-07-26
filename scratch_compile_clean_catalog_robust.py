import os
import sys
import json
import subprocess
from pathlib import Path
from multiprocessing import Pool, cpu_count

catalog_dir = Path("/home/raver1975/lean/Catalog")
elan_lake = "/home/raver1975/.elan/bin/lake"
elan_lean = "/home/raver1975/.elan/bin/lean"

# Capture environment from lake env
res = subprocess.run([elan_lake, "env", "env"], cwd=str(catalog_dir), capture_output=True, text=True)
env = os.environ.copy()
for line in res.stdout.splitlines():
    if "=" in line:
        k, v = line.split("=", 1)
        env[k] = v

def check_compile_file(str_path: str) -> tuple[str, bool]:
    filepath = Path(str_path)
    rel_p = str(filepath.relative_to(catalog_dir))
    try:
        proc = subprocess.run(
            [elan_lean, "--json", rel_p],
            cwd=str(catalog_dir),
            env=env,
            capture_output=True,
            text=True,
            timeout=12
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
    print("=== Final Compilation Validation of Catalog Lean Files ===", flush=True)
    lean_files = []
    for root, dirs, files in os.walk(catalog_dir):
        rel_root = Path(root).relative_to(catalog_dir)
        if len(rel_root.parts) > 0 and (rel_root.parts[0] == ".lake" or any(p.lower() == "packages" for p in rel_root.parts)):
            continue
        for f in files:
            if f.endswith(".lean"):
                lean_files.append(str(Path(root) / f))

    total = len(lean_files)
    print(f"Total Lean files to validate: {total}", flush=True)

    num_workers = min(16, cpu_count() * 2)
    print(f"Running across {num_workers} parallel workers...", flush=True)

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

            if idx % 250 == 0 or idx == total:
                print(f"Progress: {idx}/{total} ({idx*100//total}%) | Passed: {passed_count} | Failed & Removed: {failed_count}", flush=True)

    print("\n=== Validation Complete ===", flush=True)
    print(f"Total Valid, Compiling Lean Files Kept: {passed_count}", flush=True)
    print(f"Total Non-Compiling Lean Files Removed: {failed_count}", flush=True)

    # Clean up empty directories
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
    print(f"Removed {empty_dirs_removed} empty directories.", flush=True)

if __name__ == "__main__":
    main()
