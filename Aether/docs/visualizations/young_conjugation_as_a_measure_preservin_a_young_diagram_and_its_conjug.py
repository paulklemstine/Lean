"""Draw a Young diagram beside its conjugate (transpose)."""
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from typing import List


def conjugate(part: List[int]) -> List[int]:
    if not part:
        return []
    return [sum(1 for r in part if r > j) for j in range(part[0])]


def draw_diagram(ax, part: List[int], title: str) -> None:
    for i, row in enumerate(part):
        for j in range(row):
            ax.add_patch(patches.Rectangle((j, -i), 1, 1,
                         facecolor="#8ecae6", edgecolor="black"))
    ax.set_aspect("equal"); ax.set_title(title); ax.autoscale_view()
    ax.set_xticks([]); ax.set_yticks([])


def draw(part: List[int] = [5, 3, 3, 1]) -> None:
    fig, (a, b) = plt.subplots(1, 2, figsize=(10, 5))
    draw_diagram(a, part, f"lambda = {part}")
    draw_diagram(b, conjugate(part), f"lambda' = {conjugate(part)}")
    plt.savefig("diagram.png", dpi=150, bbox_inches="tight")


if __name__ == "__main__":
    draw()
