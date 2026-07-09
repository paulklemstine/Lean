"""Visualization of chip-firing: a divisor before and after a firing move,
with degree conservation displayed.

Generates a matplotlib figure showing a small graph, the chip values at each
vertex before and after firing a chosen vertex, and confirms the total chip
count (degree) is unchanged --- a picture of Theorem 3.2 (deg_lap_eq_zero).

Run:  python visualization.py   (writes chipfiring_demo.png)
"""

from __future__ import annotations

from typing import Dict, List, Tuple
import math

import matplotlib.pyplot as plt


def cycle_positions(n: int) -> Dict[int, Tuple[float, float]]:
    """Place n vertices evenly on a circle."""
    return {
        v: (math.cos(2 * math.pi * v / n), math.sin(2 * math.pi * v / n))
        for v in range(n)
    }


def laplacian(adj: Dict[int, List[int]], f: Dict[int, int]) -> Dict[int, int]:
    """lap f (v) = sum_{w ~ v} (f(v) - f(w))."""
    return {v: sum(f[v] - f[w] for w in adj[v]) for v in adj}


def draw(ax, pos, adj, divisor, title: str) -> None:
    for v, nbrs in adj.items():
        for w in nbrs:
            if v < w:
                x = [pos[v][0], pos[w][0]]
                y = [pos[v][1], pos[w][1]]
                ax.plot(x, y, color="#888", zorder=1, linewidth=1.5)
    for v, (x, y) in pos.items():
        val = divisor[v]
        color = "#2a9d8f" if val >= 0 else "#e76f51"
        ax.scatter([x], [y], s=1400, color=color, zorder=2, edgecolors="black")
        ax.text(x, y, f"{val:+d}", ha="center", va="center",
                color="white", fontsize=14, fontweight="bold", zorder=3)
    ax.set_title(f"{title}\ndegree = {sum(divisor.values())}", fontsize=12)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-1.4, 1.4)
    ax.set_ylim(-1.4, 1.4)


def main() -> None:
    n = 5
    adj: Dict[int, List[int]] = {v: [(v - 1) % n, (v + 1) % n] for v in range(n)}
    pos = cycle_positions(n)

    divisor: Dict[int, int] = {0: 3, 1: -1, 2: 0, 3: 1, 4: -1}
    fire_vertex = 0
    f = {v: (1 if v == fire_vertex else 0) for v in range(n)}
    lap = laplacian(adj, f)
    fired = {v: divisor[v] + lap[v] for v in range(n)}

    fig, axes = plt.subplots(1, 2, figsize=(11, 5.5))
    draw(axes[0], pos, adj, divisor, "Before firing vertex 0")
    draw(axes[1], pos, adj, fired, "After firing vertex 0")
    fig.suptitle("Chip-Firing on the 5-cycle: degree is conserved (Theorem 3.2)",
                 fontsize=14, fontweight="bold")
    fig.tight_layout()
    fig.savefig("chipfiring_demo.png", dpi=140)
    print("wrote chipfiring_demo.png")
    print(f"degree before = {sum(divisor.values())}, "
          f"degree after = {sum(fired.values())}")


if __name__ == "__main__":
    main()
