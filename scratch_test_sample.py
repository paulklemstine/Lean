import os
import json
import subprocess
from pathlib import Path

catalog_dir = Path("/home/raver1975/lean/Catalog")
elan_lake = "/home/raver1975/.elan/bin/lake"

lean_files = []
for root, dirs, files in os.walk(catalog_dir):
    rel_root = Path(root).relative_to(catalog_dir)
    if len(rel_root.parts) > 0 and (rel_root.parts[0] == ".lake" or any(p.lower() == "packages" for p in rel_root.parts)):
        continue
    for f in files:
        if f.endswith(".lean"):
            lean_files.append(Path(root) / f)

print(f"Total existing Lean files: {len(lean_files)}")

# Test lake env lean on 5 existing files
for p in lean_files[:5]:
    rel_p = str(p.relative_to(catalog_dir))
    proc = subprocess.run(
        [elan_lake, "env", "lean", "--json", rel_p],
        cwd=str(catalog_dir),
        capture_output=True,
        text=True
    )
    has_err = False
    for line in proc.stdout.splitlines():
        if line.strip():
            try:
                msg = json.loads(line)
                if msg.get("severity") == "error":
                    has_err = True
                    print(f"  {rel_p}: ERROR -> {msg.get('caption', '')}: {msg.get('text', '')[:60]}")
            except Exception:
                pass
    if proc.returncode != 0 and not has_err:
        print(f"  {rel_p}: FAIL (returncode {proc.returncode}) -> {proc.stderr[:100]}")
    elif not has_err:
        print(f"  {rel_p}: OK")

