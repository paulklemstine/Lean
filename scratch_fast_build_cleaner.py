import os
import re
import subprocess
from pathlib import Path

catalog_dir = Path("/home/raver1975/lean/Catalog")
elan_lake = "/home/raver1975/.elan/bin/lake"

def get_lean_files():
    files_list = []
    for root, dirs, files in os.walk(catalog_dir):
        rel_root = Path(root).relative_to(catalog_dir)
        if len(rel_root.parts) > 0 and (rel_root.parts[0] == ".lake" or any(p.lower() == "packages" for p in rel_root.parts)):
            continue
        for f in files:
            if f.endswith(".lean"):
                files_list.append(Path(root) / f)
    return files_list

def main():
    print("=== Fast Lake Build Iterative Cleaner ===", flush=True)
    
    total_removed = 0
    iteration = 0

    while True:
        iteration += 1
        lean_files = get_lean_files()
        print(f"\n--- Iteration {iteration}: {len(lean_files)} Lean files remaining ---", flush=True)

        proc = subprocess.run(
            [elan_lake, "build"],
            cwd=str(catalog_dir),
            capture_output=True,
            text=True
        )

        if proc.returncode == 0:
            print("SUCCESS! lake build completed with 0 errors!", flush=True)
            print(f"Final total clean, verified, compiling Lean files: {len(lean_files)}", flush=True)
            break

        # Parse output for failing .lean files
        combined_output = proc.stdout + "\n" + proc.stderr
        failed_files = set()

        for line in combined_output.splitlines():
            # Match error patterns like: "path/to/file.lean:line:col: error:"
            m = re.search(r'([A-Za-z0-9_\-/]+\.lean):\d+:\d+:\s+error:', line)
            if m:
                failed_files.add(m.group(1))
            else:
                # Match "error: path/to/file.lean: ..."
                m2 = re.search(r'error:\s+([A-Za-z0-9_\-/]+\.lean)', line)
                if m2:
                    failed_files.add(m2.group(1))

        if not failed_files:
            print("lake build failed but no specific .lean files identified in error output.", flush=True)
            print("Sample error output:")
            print("\n".join(combined_output.splitlines()[-20:]))
            break

        print(f"Found {len(failed_files)} failing Lean file(s) in this iteration.", flush=True)
        for rel_f in failed_files:
            full_p = catalog_dir / rel_f
            if full_p.exists():
                try:
                    full_p.unlink()
                    total_removed += 1
                    print(f"  Removed failing file: {rel_f}", flush=True)
                except Exception as e:
                    print(f"  Failed to remove {rel_f}: {e}", flush=True)
            else:
                # Check relative match
                for p in lean_files:
                    if str(p).endswith(rel_f):
                        try:
                            p.unlink()
                            total_removed += 1
                            print(f"  Removed failing file: {p.relative_to(catalog_dir)}", flush=True)
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
