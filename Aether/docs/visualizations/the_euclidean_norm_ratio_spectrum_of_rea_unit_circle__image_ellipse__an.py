"""
Visualization: the image of the unit circle under a unimodular 2x2 matrix is an
ellipse of equal area, and the constructed witness vector lands on the locus where
the ellipse meets the unit circle (the unit-stretch direction).

Requires matplotlib. Saves 'norm_ratio_spectrum.png'.
"""
from __future__ import annotations

import math
from typing import Tuple

import matplotlib.pyplot as plt

Matrix = Tuple[float, float, float, float]


def unstretched_vector(M: Matrix) -> Tuple[float, float]:
    a, b, c, d = M
    A = a * a + c * c - 1.0
    B = a * b + c * d
    if abs(A) < 1e-12:
        return (1.0, 0.0)
    D = B * B - A * (b * b + d * d - 1.0)
    s = math.sqrt(max(D, 0.0))
    return ((-B + s) / A, 1.0)


def main() -> None:
    M: Matrix = (2.0, 1.0, 1.0, 1.0)  # Fibonacci / Arnold cat map, det = 1
    a, b, c, d = M
    ts = [2 * math.pi * i / 720 for i in range(721)]
    circ_x = [math.cos(t) for t in ts]
    circ_y = [math.sin(t) for t in ts]
    img_x = [a * x + b * y for x, y in zip(circ_x, circ_y)]
    img_y = [c * x + d * y for x, y in zip(circ_x, circ_y)]

    v = unstretched_vector(M)
    nv = math.hypot(*v)
    vu = (v[0] / nv, v[1] / nv)         # unit witness direction
    Mvu = (a * vu[0] + b * vu[1], c * vu[0] + d * vu[1])

    fig, ax = plt.subplots(figsize=(7, 7))
    ax.plot(circ_x, circ_y, color="#1f77b4", lw=2, label="unit circle (inputs)")
    ax.plot(img_x, img_y, color="#d62728", lw=2, label="image ellipse  M·(circle)")
    ax.annotate("", xy=vu, xytext=(0, 0),
                arrowprops=dict(arrowstyle="->", color="green", lw=2.5))
    ax.annotate("", xy=Mvu, xytext=(0, 0),
                arrowprops=dict(arrowstyle="->", color="black", lw=2.5))
    ax.scatter([vu[0]], [vu[1]], color="green", zorder=5,
               label=f"witness v (|v|={nv*0+1:.0f})")
    ax.scatter([Mvu[0]], [Mvu[1]], color="black", zorder=5,
               label=f"M·v  (|M·v|={math.hypot(*Mvu):.3f})")
    ax.set_aspect("equal")
    ax.grid(alpha=0.3)
    ax.set_title("Unit-stretch direction of the unimodular matrix [[2,1],[1,1]]\n"
                 "image ellipse has equal area; v and M·v have equal length")
    ax.legend(loc="upper left", fontsize=9)
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    fig.tight_layout()
    fig.savefig("norm_ratio_spectrum.png", dpi=150)
    print("saved norm_ratio_spectrum.png")


if __name__ == "__main__":
    main()
