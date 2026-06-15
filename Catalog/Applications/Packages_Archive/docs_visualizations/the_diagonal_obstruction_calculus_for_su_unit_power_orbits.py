"""Visualization: the admissible set as a union of n-th-power-unit orbits.

Illustrates Theorem 3.5 by colouring residues mod m according to their orbit
under multiplication by n-th powers of units. Saves to 'unit_orbits.png'.
"""
from __future__ import annotations
from math import gcd
import matplotlib.pyplot as plt
import numpy as np


def units(m: int) -> list[int]:
    return [a for a in range(m) if gcd(a, m) == 1]


def nth_power_unit_subgroup(n: int, m: int) -> set[int]:
    return {pow(a, n, m) for a in units(m)}


def main() -> None:
    n, m = 3, 19
    H = nth_power_unit_subgroup(n, m)
    # partition (Z/m)^x into cosets of H (the orbits of Theorem 3.5)
    seen: set[int] = set()
    orbits: list[list[int]] = []
    for a in units(m):
        if a in seen:
            continue
        orbit = sorted({(a * h) % m for h in H})
        orbits.append(orbit)
        seen.update(orbit)

    angles = np.linspace(0, 2 * np.pi, m, endpoint=False)
    fig, ax = plt.subplots(figsize=(7, 7))
    cmap = plt.get_cmap("tab10")
    for k, orbit in enumerate(orbits):
        xs = [np.cos(angles[r]) for r in orbit]
        ys = [np.sin(angles[r]) for r in orbit]
        ax.scatter(xs, ys, s=260, color=cmap(k % 10), zorder=3,
                   label=f"orbit {k+1}")
        for r in orbit:
            ax.annotate(str(r), (np.cos(angles[r]), np.sin(angles[r])),
                        ha="center", va="center", zorder=4)
    ax.add_patch(plt.Circle((0, 0), 1.0, fill=False, color="lightgray"))
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title(f"(Z/{m})^x as orbits of {n}-th-power units H={sorted(H)}")
    ax.legend(loc="upper right", fontsize=8)
    fig.tight_layout()
    fig.savefig("unit_orbits.png", dpi=150)
    print("saved unit_orbits.png")


if __name__ == "__main__":
    main()
