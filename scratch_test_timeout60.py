import os
import json
import subprocess
from pathlib import Path

catalog_dir = Path("/home/raver1975/lean/Catalog")
elan_lake = "/home/raver1975/.elan/bin/lake"

def check_file(rel_path: str) -> tuple[str, bool, str]:
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
            return (rel_path, False, f"Exit code {proc.returncode}")
        
        for line in proc.stdout.splitlines():
            line = line.strip()
            if not line:
                continue
            try:
                msg = json.loads(line)
                if msg.get("severity") == "error":
                    return (rel_path, False, f"Lean error: {msg.get('text', '')[:60]}")
            except Exception:
                pass
        return (rel_path, True, "OK")
    except subprocess.TimeoutExpired:
        return (rel_path, False, "Timeout (60s)")
    except Exception as e:
        return (rel_path, False, str(e))

test_files = ["TestValid2.lean", "TestValid.lean"]
print("Testing TestValid2.lean and TestValid.lean with 60s timeout:")
for f in test_files:
    rel, ok, reason = check_file(f)
    print(f"  {rel} -> {'PASSED' if ok else 'FAILED (' + reason + ')'}")

