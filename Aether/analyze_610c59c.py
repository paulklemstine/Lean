import json
import glob
from pathlib import Path

repo_root = Path('/home/raver1975/lean')
docs_dir = repo_root / 'docs'
idx_file = docs_dir / 'package_index.js'

text = idx_file.read_text(encoding='utf-8')
pkgs = json.loads(text.split('window.PACKAGE_INDEX = ')[1].split(';\n')[0])

print(f"Total packages in package_index.js at 610c59c2ad: {len(pkgs)}")

below_60 = []
for p in pkgs:
    num = p.get('pkg_num')
    title = p.get('title')
    fn = p.get('filename')
    qs = p.get('quality_score')
    
    # Check displayed score
    if qs is not None:
        try:
            val = float(qs)
            if val < 0.60:
                below_60.append((num, title, fn, val))
        except ValueError:
            pass

print(f"\nPackages displayed in menu with Quality Score < 60% (< 0.60): {len(below_60)}")
for num, title, fn, val in below_60:
    print(f"  #{num}: Q={val*100:.1f}% ({val:.2f}) — \"{title}\" ({fn})")
