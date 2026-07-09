"""Visualization: the bush of lines through the origin in F_q^2.

Plots every line L_m through the origin over the prime field F_q on the q x q
grid, highlighting the q-1 points the bush misses (the off-origin vertical axis)
and annotating the exact count |B| = q^2 - q + 1.

Requires matplotlib. Run: python _viz.py
"""
from __future__ import annotations

import matplotlib.pyplot as plt


def plot_bush(q: int = 11) -> None:
    fig, ax = plt.subplots(figsize=(7, 7))
    bush_points = set()
    for m in range(q):
        xs = list(range(q))
        ys = [(m * x) % q for x in xs]
        for x, y in zip(xs, ys):
            bush_points.add((x, y))
        ax.scatter(xs, ys, s=18, alpha=0.35, color="steelblue")

    full = {(a, b) for a in range(q) for b in range(q)}
    missed = full - bush_points
    if missed:
        mx, my = zip(*sorted(missed))
        ax.scatter(mx, my, s=90, color="crimson", marker="x",
                   label=f"missed: {len(missed)} = q-1")

    ax.scatter([0], [0], s=140, color="black", marker="*", label="origin (0,0)")
    ax.set_title(f"Bush in F_{q}^2:  |B| = q^2 - q + 1 = {q*q - q + 1}")
    ax.set_xlabel("x"); ax.set_ylabel("y")
    ax.set_xticks(range(q)); ax.set_yticks(range(q))
    ax.grid(True, alpha=0.2); ax.legend(loc="upper right")
    ax.set_aspect("equal")
    plt.tight_layout()
    plt.savefig("bush_visualization.png", dpi=150)
    print("saved bush_visualization.png")


if __name__ == "__main__":
    plot_bush(11)
