"""
Visualization: The Contraction Whirlpool and the Metallic Spiral.

Generates two panels illustrating that valid self-reference = self-similarity:
  (left)  the affine attractor f(x)=c*x+b as a cobweb plot spiralling to its
          unique fixed point x* = b/(1-c);
  (right) the golden gnomon, a self-similar nest of squares spiralling inward
          along the metallic-ratio rectangle.

Run with:  python3 _viz.py   (writes self_similarity.png)
"""

from __future__ import annotations

import math
from typing import List, Tuple

import matplotlib.pyplot as plt


def cobweb(c: float, b: float, x0: float, steps: int) -> Tuple[List[float], List[float]]:
    """Cobweb (staircase) coordinates for iterating f(x) = c*x + b."""
    xs: List[float] = [x0]
    ys: List[float] = [0.0]
    x = x0
    for _ in range(steps):
        fx = c * x + b
        xs += [x, fx]
        ys += [fx, fx]
        x = fx
    return xs, ys


def golden_squares(n: int) -> List[Tuple[float, float, float]]:
    """Return (x, y, side) of nested squares carving a golden rectangle."""
    phi = (1 + math.sqrt(5)) / 2
    w, h = phi, 1.0
    x, y = 0.0, 0.0
    out: List[Tuple[float, float, float]] = []
    left = True
    for _ in range(n):
        s = min(w, h)
        if left:
            out.append((x, y, s))
            x += s
            w -= s
        else:
            out.append((x, y, s))
            y += s
            h -= s
        left = not left
    return out


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))

    # --- Panel 1: contraction whirlpool ---
    c, b, x0 = 0.6, 2.0, 9.0
    xstar = b / (1 - c)
    xs = [i / 50 for i in range(0, 600)]
    ax1.plot(xs, [c * t + b for t in xs], "b-", lw=2, label="f(x)=cx+b")
    ax1.plot(xs, xs, "k--", lw=1, label="y=x")
    cx, cy = cobweb(c, b, x0, 12)
    ax1.plot(cx, cy, "r-", lw=1.2, alpha=0.8, label="orbit")
    ax1.plot([xstar], [xstar], "go", ms=10, label=f"fixed point x*={xstar:g}")
    ax1.set_title("Contraction whirlpool: x = cx + b spirals to its unique fixed point")
    ax1.set_xlabel("x"); ax1.set_ylabel("f(x)")
    ax1.legend(loc="upper left", fontsize=8); ax1.set_xlim(0, 12); ax1.set_ylim(0, 12)

    # --- Panel 2: golden gnomon ---
    for (x, y, s) in golden_squares(8):
        ax2.add_patch(plt.Rectangle((x, y), s, s, fill=False, edgecolor="darkgoldenrod", lw=1.5))
    ax2.set_title("Golden gnomon: a rectangle that contains a scaled copy of itself")
    ax2.set_xlim(-0.1, (1 + math.sqrt(5)) / 2 + 0.1); ax2.set_ylim(-0.1, 1.1)
    ax2.set_aspect("equal"); ax2.axis("off")

    fig.suptitle("Valid self-reference = self-similarity", fontsize=14, weight="bold")
    fig.tight_layout()
    fig.savefig("self_similarity.png", dpi=140)
    print("wrote self_similarity.png")


if __name__ == "__main__":
    main()
