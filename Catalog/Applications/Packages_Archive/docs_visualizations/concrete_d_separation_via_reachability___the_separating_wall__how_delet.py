"""Visualization: a path graph and how deleting Z builds a separating wall.

Generates a figure showing the path 0-1-2-3-4 and, for several conditioning
sets Z, which (A,B) pairs become separated. Saves 'separation_wall.png'.
"""
from __future__ import annotations
from typing import Dict, FrozenSet, List, Set, Tuple
import matplotlib.pyplot as plt


def conn_avoid(adj: Dict[int, Set[int]], u: int, v: int,
               z: FrozenSet[int]) -> bool:
    if u in z or v in z:
        return u == v and u not in z
    if u == v:
        return True
    seen, frontier = {u}, [u]
    while frontier:
        x = frontier.pop()
        for y in adj[x]:
            if y not in z and y not in seen:
                if y == v:
                    return True
                seen.add(y)
                frontier.append(y)
    return False


def main() -> None:
    n = 5
    edges: List[Tuple[int, int]] = [(0, 1), (1, 2), (2, 3), (3, 4)]
    adj: Dict[int, Set[int]] = {v: set() for v in range(n)}
    for a, b in edges:
        adj[a].add(b); adj[b].add(a)

    conditioning_sets = [frozenset(), frozenset({2}), frozenset({1, 3})]
    fig, axes = plt.subplots(1, len(conditioning_sets), figsize=(15, 4))
    xs = list(range(n))
    for ax, Z in zip(axes, conditioning_sets):
        ax.set_title(f"Z = {set(Z) if Z else '{}'}")
        for a, b in edges:
            broken = (a in Z) or (b in Z)
            ax.plot([a, b], [0, 0],
                    color="lightgray" if broken else "black",
                    lw=3, zorder=1)
        for v in xs:
            color = "crimson" if v in Z else "steelblue"
            ax.scatter([v], [0], s=600, color=color, zorder=2)
            ax.text(v, 0, str(v), color="white",
                    ha="center", va="center", fontsize=12, zorder=3)
        reach = "0 reaches 4: " + ("YES" if conn_avoid(adj, 0, 4, Z) else "NO")
        ax.text(2, -0.5, reach, ha="center", fontsize=11)
        ax.set_ylim(-1, 1); ax.axis("off")
    fig.suptitle("Deleting Z (red) builds a separating wall in the path 0-1-2-3-4",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("separation_wall.png", dpi=130)
    print("Saved separation_wall.png")


if __name__ == "__main__":
    main()
