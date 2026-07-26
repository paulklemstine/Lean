import os
import re
from pathlib import Path

root_dir = Path("/home/raver1975/lean")

for r, dirs, files in os.walk(root_dir):
    dirs[:] = [d for d in dirs if d not in ('.git', '.lake', 'node_modules', 'Packages', 'Packages_Archive', 'docs')]
    for f in files:
        if f.endswith('.py') or f.endswith('.sh') or f.endswith('.md') or f.endswith('.js'):
            fp = Path(r) / f
            try:
                txt = fp.read_text(errors='ignore')
                if 'Packages' in txt or 'packages' in txt:
                    for line in txt.splitlines():
                        if 'Packages' in line or 'packages' in line:
                            print(f"{fp.relative_to(root_dir)}: {line.strip()[:100]}")
            except Exception:
                pass
