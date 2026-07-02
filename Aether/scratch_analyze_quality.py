import json
import glob
from pathlib import Path

packages = glob.glob('/home/raver1975/lean/Packages/*.json')
packages = [p for p in packages if not p.endswith('lineage.json') and not p.endswith('future_directions.json') and not p.endswith('index.json')]

# sort by modification time, newest first
packages.sort(key=lambda x: Path(x).stat().st_mtime, reverse=True)

print(f"Total packages: {len(packages)}")
for pkg_path in packages[:10]:
    with open(pkg_path, 'r') as f:
        data = json.load(f)
        
    title = data.get('title', 'Unknown')
    q_score = data.get('quality_score', 0)
    q_detail = data.get('quality_detail', {})
    
    print(f"Project: {title}")
    print(f"Overall Quality: {q_score}")
    print("Details:")
    for k, v in q_detail.items():
        print(f"  {k}: {v}")
    print("-" * 40)
