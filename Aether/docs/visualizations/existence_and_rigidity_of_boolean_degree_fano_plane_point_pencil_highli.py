import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from typing import FrozenSet, List


def visualize_fano_pencil(point: int = 0) -> None:
    """Draw the Fano plane PG(2,2)=J_2(3,2) and highlight the point-pencil of
    `point`: lines through it are drawn bold/red (value 1), others grey (value 0).
    """
    # Standard triangular Fano embedding: 7 points, 7 lines (one is the incircle).
    coords = {
        0: (0.0, 1.0), 1: (-0.87, -0.5), 2: (0.87, -0.5),
        3: (-0.43, 0.25), 4: (0.43, 0.25), 5: (0.0, -0.5),
        6: (0.0, 0.0),
    }
    lines: List[FrozenSet[int]] = [
        frozenset({0, 3, 1}), frozenset({0, 4, 2}), frozenset({1, 5, 2}),
        frozenset({0, 6, 5}), frozenset({1, 6, 4}), frozenset({2, 6, 3}),
        frozenset({3, 4, 5}),  # the incircle
    ]
    fig, ax = plt.subplots(figsize=(6, 6))
    for line in lines:
        through = point in line
        color = "crimson" if through else "0.7"
        lw = 3.0 if through else 1.0
        if line == frozenset({3, 4, 5}):
            circ = plt.Circle((0.0, -0.083), 0.33, fill=False,
                              color=color, lw=lw)
            ax.add_patch(circ)
        else:
            pts = [coords[p] for p in line]
            xs, ys = zip(*pts)
            order = np.argsort(np.arctan2(np.array(ys) - np.mean(ys),
                                          np.array(xs) - np.mean(xs)))
            xs = [pts[i][0] for i in [0, 1, 2]]
            ys = [pts[i][1] for i in [0, 1, 2]]
            ax.plot([min(xs), max(xs)],
                    [ys[xs.index(min(xs))], ys[xs.index(max(xs))]],
                    color=color, lw=lw, zorder=1)
    for p, (x, y) in coords.items():
        ax.scatter([x], [y], s=200,
                   color="black" if p != point else "crimson", zorder=3)
        ax.annotate(str(p), (x, y), color="white", ha="center", va="center",
                    zorder=4, fontsize=9)
    ax.set_title(f"Fano plane: point-pencil of p={point} (red = value 1)")
    ax.set_aspect("equal")
    ax.axis("off")
    plt.tight_layout()
    plt.savefig("fano_pencil.png", dpi=150)
    print("saved fano_pencil.png")


if __name__ == "__main__":
    visualize_fano_pencil(0)
