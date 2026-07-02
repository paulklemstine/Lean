import sys
from pathlib import Path
sys.path.append(str(Path("/home/raver1975/lean/Aether")))
from research_memory import FutureDirectionsManager

manager = FutureDirectionsManager(Path("/home/raver1975/lean/Aether/.aether_workspace"))
print(f"Total directions: {len(manager._directions)}")
for d in manager._directions:
    print(f"Title: {d.title}, source: {d.source}, issue: {d.github_issue}, status: {d.status}")
