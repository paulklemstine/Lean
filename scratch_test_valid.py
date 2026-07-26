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

test_file = catalog_dir / "TestValid.lean"
print(f"Testing direct lean invocation on {test_file.name}...")

proc = subprocess.run(
    [elan_lean, "--json", str(test_file)],
    cwd=str(catalog_dir),
    env=env,
    capture_output=True,
    text=True
)

print(f"Return code: {proc.returncode}")
print(f"STDOUT: {proc.stdout}")
print(f"STDERR: {proc.stderr}")

has_error = False
for line in proc.stdout.splitlines():
    if line.strip():
        try:
            msg = json.loads(line)
            if msg.get("severity") == "error":
                has_error = True
                print(f"Error found: {msg.get('text')}")
        except Exception:
            pass

if proc.returncode == 0 and not has_error:
    print("TestValid.lean PASSED COMPILATION 100%!")
else:
    print("TestValid.lean FAILED COMPILATION")

