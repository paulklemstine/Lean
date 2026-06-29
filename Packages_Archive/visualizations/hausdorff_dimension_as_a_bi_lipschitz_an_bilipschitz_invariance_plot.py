"""Visualization: bi-Lipschitz (affine) invariance of Cantor-set dimension.

Generates a figure with two panels:
  (left)  the middle-thirds Cantor set and three affine images, drawn as
          point clouds on parallel lines, showing the same self-similar
          structure under scaling/translation;
  (right) the box-counting log-log plot whose slope estimates the dimension,
          with the original and all affine images overlapping in slope.

Requires matplotlib. Run:  python viz_bilipschitz.py
"""
from __future__ import annotations
import math
from typing import Callable, List, Sequence
import matplotlib.pyplot as plt


def cantor_points(depth: int) -> List[float]:
    pts: List[float] = []
    for code in range(2 ** depth):
        x, scale, c = 0.0, 1.0, code
        for _ in range(depth):
            scale /= 3.0
            if c & 1:
                x += 2.0 * scale
            c >>= 1
        pts.append(x)
    return pts


def box_count(points: Sequence[float], eps: float) -> int:
    return len({math.floor(p / eps) for p in points})


def main() -> None:
    depth = 11
    pts = cantor_points(depth)
    maps = {
        "original x": (lambda x: x),
        "5x": (lambda x: 5 * x),
        "x + 2": (lambda x: x + 2),
        "-3x + 1": (lambda x: -3 * x + 1),
    }
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    for i, (name, f) in enumerate(maps.items()):
        img = [f(x) for x in pts]
        ax1.scatter(img, [i] * len(img), s=1)
        ax1.text(min(img), i + 0.15, name, fontsize=9)
    ax1.set_title("Cantor set and affine images (same structure)")
    ax1.set_yticks([])
    ax1.set_xlabel("position")

    for name, f in maps.items():
        img = [f(x) for x in pts]
        c = abs(f(1.0) - f(0.0)) or 1.0
        scales = [(1 / 3) ** k for k in range(2, depth)]
        xs = [math.log(1 / (s * c)) for s in scales]
        ys = [math.log(box_count(img, s * c)) for s in scales]
        ax2.plot(xs, ys, marker="o", label=name)
    ax2.set_title("Box-counting log-log (slope = dimension ~ log2/log3)")
    ax2.set_xlabel("log(1/eps)")
    ax2.set_ylabel("log N(eps)")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("bilipschitz_invariance.png", dpi=150)
    print("saved bilipschitz_invariance.png")


if __name__ == "__main__":
    main()
