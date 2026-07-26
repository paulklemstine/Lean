import os
import re
import sys
import subprocess
from pathlib import Path

catalog_dir = Path("/home/raver1975/lean/Catalog")
elan_lake = "/home/raver1975/.elan/bin/lake"

def main():
    print("=== Streaming Iterative Lake Build Cleaner ===", flush=True)

    total_removed = 0
    iteration = 0

    while True:
        iteration += 1
        print(f"\n--- Iteration {iteration} ---", flush=True)

        proc = subprocess.Popen(
            [elan_lake, "build"],
            cwd=str(catalog_dir),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1
        )

        failed_files = set()

        for line in proc.stdout:
            line_str = line.strip()
            if not line_str:
                continue

            # Print build progress lines
            if line_str.startswith("✔") or "Built" in line_str:
                print(line_str, flush=True)
            elif "error:" in line_str:
                print(f"ERROR LINE: {line_str}", flush=True)

            # Match error patterns like: "path/to/file.lean:line:col: error:"
            m = re.search(r'([A-Za-z0-9_\-/]+\.lean):\d+:\d+:\s+error:', line_str)
            if m:
                failed_files.add(m.group(1))
            else:
                m2 = re.search(r'error:\s+([A-Za-z0-9_\-/]+\.lean)', line_str)
                if m2:
                    failed_files.add(m2.group(1))

        proc.wait()

        if proc.returncode == 0 and not failed_files:
            print("\nSUCCESS! lake build completed with 0 errors!", flush=True)
            break

        if not failed_files:
            print("lake build failed with non-zero exit code but no specific files matched in output.", flush=True)
            break

        print(f"\nRemoving {len(failed_files)} failing Lean file(s)...", flush=True)
        for rel_f in failed_files:
            full_p = catalog_dir / rel_f
            if full_p.exists():
                try:
                    full_p.unlink()
                    total_removed += 1
                    print(f"  Deleted: {rel_f}", flush=True)
                except Exception as e:
                    print(f"  Error deleting {rel_f}: {e}", flush=True)
            else:
                # Search for matching file under catalog_dir
                for root, dirs, files in os.walk(catalog_dir):
                    for f in files:
                        p = Path(root) / f
                        if str(p).endswith(rel_f):
                            try:
                                p.unlink()
                                total_removed += 1
                                print(f"  Deleted: {p.relative_to(catalog_dir)}", flush=True)
                            except Exception:
                                pass

    print(f"\nTotal Lean files removed due to compilation errors: {total_removed}", flush=True)

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
