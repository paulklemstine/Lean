"""
Functional-Graph & Orbit Visualizer for Finite Self-Modifying Machines
======================================================================
Renders the orbit of a finite self-map dyn : config -> config, highlighting
the preperiod tail (rho-stem) and the periodic cycle (rho-loop), and marks
bad states to illustrate the alignment obstruction. Uses matplotlib only.
"""
from __future__ import annotations
from typing import Callable, Dict, Hashable, List, Set, Tuple
import math
import matplotlib.pyplot as plt

Config = Hashable


def find_collision(f: Callable[[Config], Config], x: Config, card: int) -> Tuple[int, int]:
    seen: Dict[Config, int] = {}
    cur = x
    for k in range(card + 1):
        if cur in seen:
            return seen[cur], k
        seen[cur] = k
        cur = f(cur)
    raise RuntimeError("pigeonhole guarantees a collision")


def draw_orbit(f: Callable[[Config], Config], x: Config, card: int,
               bad: Set[Config]) -> None:
    i, j = find_collision(f, x, card)            # tail length i, period j-i
    orbit: List[Config] = []
    cur = x
    for _ in range(j):
        orbit.append(cur)
        cur = f(cur)
    period = j - i
    fig, ax = plt.subplots(figsize=(9, 6))
    pos: Dict[int, Tuple[float, float]] = {}
    # tail laid horizontally, cycle laid on a circle
    for t in range(i):
        pos[t] = (t * 1.6, 0.0)
    cx, cy, r = i * 1.6 + 2.2, 0.0, 1.6
    for c in range(period):
        ang = 2 * math.pi * c / period
        pos[i + c] = (cx + r * math.cos(ang), cy + r * math.sin(ang))
    for idx, conf in enumerate(orbit):
        nxt = (idx + 1) if idx + 1 < j else i      # cycle wraps to start of loop
        x0, y0 = pos[idx]
        x1, y1 = pos[nxt]
        ax.annotate("", xy=(x1, y1), xytext=(x0, y0),
                    arrowprops=dict(arrowstyle="->", color="#555", lw=1.5))
    for idx, conf in enumerate(orbit):
        x0, y0 = pos[idx]
        col = "#e74c3c" if conf in bad else ("#3498db" if idx < i else "#2ecc71")
        ax.scatter([x0], [y0], s=900, c=col, edgecolors="k", zorder=3)
        ax.text(x0, y0, str(conf), ha="center", va="center",
                color="white", fontweight="bold", zorder=4)
    ax.set_title(f"Orbit: tail length {i}, cycle period {period} (N={card})")
    ax.axis("off")
    ax.set_aspect("equal")
    plt.tight_layout()
    plt.savefig("orbit_graph.png", dpi=140)
    print("wrote orbit_graph.png")


if __name__ == "__main__":
    succ = {0: 1, 1: 2, 2: 3, 3: 4, 4: 2, 5: 0}
    draw_orbit(lambda k: succ[k], 0, 6, bad={3})
