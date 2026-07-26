import os
import json
import subprocess
from pathlib import Path
from multiprocessing import Pool

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
            timeout=25
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
                    return (rel_path, False, f"Lean error: {msg.get('text', '')[:50]}")
            except Exception:
                pass
        return (rel_path, True, "OK")
    except subprocess.TimeoutExpired:
        return (rel_path, False, "Timeout")
    except Exception as e:
        return (rel_path, False, str(e))

def main():
    lean_files = []
    for root, dirs, files in os.walk(catalog_dir):
        rel_root = Path(root).relative_to(catalog_dir)
        if len(rel_root.parts) > 0 and (rel_root.parts[0] == ".lake" or any(p.lower() == "packages" for p in rel_root.parts)):
            continue
        for f in files:
            if f.endswith(".lean"):
                lean_files.append(str(Path(root).relative_to(catalog_dir) / f))

    print(f"Testing 20 files with lake env lean on absolute path...")
    with Pool(processes=8) as pool:
        for rel_path, ok, reason in pool.imap_unordered(check_file, lean_files[:20], chunksize=1):
            print(f"  {rel_path} -> {'PASSED' if ok else 'FAILED (' + reason + ')'}", flush=True)

if __name__ == "__main__":
    main()
