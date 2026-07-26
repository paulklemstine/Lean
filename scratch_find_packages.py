import os
from pathlib import Path

root_dir = Path("/home/raver1975/lean")

print("Directories matching *package* or *Package*:")
for r, dirs, files in os.walk(root_dir):
    dirs[:] = [d for d in dirs if not d.startswith(".")]
    for d in dirs:
        if "package" in d.lower():
            p = Path(r) / d
            print(f"  {p.relative_to(root_dir)}")

