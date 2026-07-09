"""
Visualization: Frobenius eigenvalues on the circle of radius sqrt(p).

For a fixed prime p, sweep the Hecke eigenvalue a across [-2*sqrt(p), 2*sqrt(p)]
and plot the resulting conjugate eigenvalue pairs alpha = sqrt(p)*e^{i theta},
beta = conjugate(alpha). All admissible eigenvalues land exactly on the circle
|z| = sqrt(p), illustrating deligne_root_abs and deligne_frob_eigenvalues.
"""

from __future__ import annotations

import math
import cmath
from typing import List, Tuple

import matplotlib.pyplot as plt


def hecke_roots(a: float, p: float) -> Tuple[complex, complex]:
    """Roots of X^2 - a X + p."""
    sq = cmath.sqrt(complex(a * a - 4.0 * p))
    return (a + sq) / 2.0, (a - sq) / 2.0


def main() -> None:
    p = 13.0
    r = math.sqrt(p)
    two_r = 2.0 * r

    # The reference critical circle |z| = sqrt(p).
    ts = [i * 2.0 * math.pi / 400 for i in range(401)]
    cx = [r * math.cos(t) for t in ts]
    cy = [r * math.sin(t) for t in ts]

    xs: List[float] = []
    ys: List[float] = []
    a = -two_r
    while a <= two_r + 1e-9:
        alpha, beta = hecke_roots(a, p)
        for z in (alpha, beta):
            xs.append(z.real)
            ys.append(z.imag)
        a += two_r / 60.0

    fig, ax = plt.subplots(figsize=(6, 6))
    ax.plot(cx, cy, color="0.7", lw=1.0, label=f"critical circle |z| = sqrt(p) = {r:.3f}")
    ax.scatter(xs, ys, s=18, color="crimson", zorder=3,
               label="Frobenius eigenvalue pairs")
    ax.axhline(0, color="0.85", lw=0.6)
    ax.axvline(0, color="0.85", lw=0.6)
    ax.set_aspect("equal")
    ax.set_title(f"GL2 Frobenius eigenvalues on |z| = sqrt(p),  p = {int(p)}")
    ax.set_xlabel("Re(z)")
    ax.set_ylabel("Im(z)")
    ax.legend(loc="upper right", fontsize=8)
    fig.tight_layout()
    fig.savefig("frobenius_circle.png", dpi=150)
    print("Saved frobenius_circle.png")


if __name__ == "__main__":
    main()
