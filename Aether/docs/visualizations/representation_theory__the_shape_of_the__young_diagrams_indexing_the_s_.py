"""Visualization: Young diagrams of the partitions indexing the S_n table."""
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from typing import List, Tuple

Partition = Tuple[int, ...]


def partitions(n: int, max_part: int = None) -> List[Partition]:
    if max_part is None:
        max_part = n
    if n == 0:
        return [()]
    out = []
    for k in range(min(n, max_part), 0, -1):
        for rest in partitions(n - k, k):
            out.append((k,) + rest)
    return out


N = 5
parts = partitions(N)
cols = len(parts)
fig, axes = plt.subplots(1, cols, figsize=(2.2 * cols, 2.6))
fig.suptitle(f"The p({N}) = {cols} partitions of {N} "
             f"(the rows/columns of the S_{N} character table)", fontsize=13)
for ax, part in zip(axes, parts):
    for i, row in enumerate(part):
        for j in range(row):
            ax.add_patch(Rectangle((j, -i), 1, 1, facecolor="#9ec5ff",
                                   edgecolor="#27408b"))
    ax.set_xlim(-0.3, max(part) + 0.3)
    ax.set_ylim(-len(part) + 0.3, 1.3)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title("+".join(map(str, part)), fontsize=10)
plt.tight_layout()
plt.savefig("young_diagrams.png", dpi=150)
print("wrote young_diagrams.png")
