import sys
from pathlib import Path
sys.path.append(str(Path("/home/raver1975/lean/Aether")))
from research_memory import FutureDirectionsManager

manager = FutureDirectionsManager(Path("/home/raver1975/lean/Aether/.aether_workspace"))
print(f"Total directions: {len(manager._directions)}")
d = manager.select_direction_weighted(domain_filter="Novelty")
if d:
    print(f"Selected: {d.title} (source: {d.source}, issue: {d.github_issue})")
else:
    print("None selected.")
