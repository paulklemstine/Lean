import os
import json
import subprocess
from pathlib import Path
from multiprocessing import Pool

catalog_dir = Path("/home/raver1975/lean/Catalog")
elan_lake = "/home/raver1975/.elan/bin/lake"

def check_file(rel_p: str) -> tuple[str, bool]:
    try:
        proc = subprocess.run(
            [elan_lake, "env", "lean", "--json", rel_p],
            cwd=str(catalog_dir),
            capture_output=True,
            text=True,
            timeout=30
        )
        if proc.returncode != 0:
            return (rel_p, False)
        for line in proc.stdout.splitlines():
            if line.strip():
                try:
                    msg = json.loads(line)
                    if msg.get("severity") == "error":
                        return (rel_p, False)
                except Exception:
                    pass
        return (rel_p, True)
    except Exception:
        return (rel_p, False)

lean_files = []
for root, dirs, files in os.walk(catalog_dir):
    rel_root = Path(root).relative_to(catalog_dir)
    if len(rel_root.parts) > 0 and (rel_root.parts[0] == ".lake" or any(p.lower() == "packages" for p in rel_root.parts)):
        continue
    for f in files:
        if f.endswith(".lean"):
            lean_files.append(str(Path(root).relative_to(catalog_dir) / f))

print(f"Total existing Lean files: {len(lean_files)}")
print(f"Testing first 10 files with lake env lean...")

with Pool(processes=8) as pool:
    for rel_p, ok in pool.imap_unordered(check_file, lean_files[:10], chunksize=1):
        print(f"  {rel_p} -> {'OK' if ok else 'FAIL'}", flush=True)

