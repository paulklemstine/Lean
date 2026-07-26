import os
import json
import subprocess
from pathlib import Path

catalog_dir = Path("/home/raver1975/lean/Catalog")
elan_lake = "/home/raver1975/.elan/bin/lake"
elan_lean = "/home/raver1975/.elan/bin/lean"

# 1. Get exact environment from `lake env env`
res = subprocess.run([elan_lake, "env", "env"], cwd=str(catalog_dir), capture_output=True, text=True)
env = os.environ.copy()
for line in res.stdout.splitlines():
    if "=" in line:
        k, v = line.split("=", 1)
        env[k] = v

print("LEAN_PATH from lake env:")
print(env.get("LEAN_PATH"))
print("LEAN_SRC_PATH from lake env:")
print(env.get("LEAN_SRC_PATH"))

lean_files = []
for root, dirs, files in os.walk(catalog_dir):
    rel_root = Path(root).relative_to(catalog_dir)
    if len(rel_root.parts) > 0 and (rel_root.parts[0] == ".lake" or any(p.lower() == "packages" for p in rel_root.parts)):
        continue
    for f in files:
        if f.endswith(".lean"):
            lean_files.append(Path(root) / f)

print(f"\nTesting direct lean binary execution on 10 files...")
for p in lean_files[:10]:
    rel_p = str(p.relative_to(catalog_dir))
    proc = subprocess.run(
        [elan_lean, "--json", str(p)],
        cwd=str(catalog_dir),
        env=env,
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
                    print(f"  {rel_p}: ERROR -> {msg.get('caption', '')}: {msg.get('text', '')[:60].strip()}")
            except Exception:
                pass
    if proc.returncode != 0 and not has_err:
        print(f"  {rel_p}: FAIL (exit {proc.returncode}) -> {proc.stderr[:100].strip()}")
    elif not has_err:
        print(f"  {rel_p}: OK")

