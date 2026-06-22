"""
Visualization for Quotient Orbit Compression.

Produces a three-panel figure:
  (1) the observable label trajectory of a deterministic map, with the first
      coarse collision highlighted (the bounded-horizon collision theorem);
  (2) observable orbit count vs. horizon, saturating below the ceiling k;
  (3) compression ratio R_rho = k/|alpha| across a family of lenses.

Requires only matplotlib + numpy.  Run:  python3 visualize.py
"""

from __future__ import annotations

from typing import Callable, Dict, List, Optional, Tuple

import matplotlib.pyplot as plt
import numpy as np


def iterate_labels(
    f: Callable[[int], int], x: int, label: Callable[[int], int], steps: int
) -> List[int]:
    out: List[int] = []
    s = x
    for _ in range(steps + 1):
        out.append(label(s))
        s = f(s)
    return out


def first_collision(labels: List[int]) -> Optional[Tuple[int, int]]:
    seen: Dict[int, int] = {}
    for i, lab in enumerate(labels):
        if lab in seen:
            return seen[lab], i
        seen[lab] = i
    return None


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(16, 4.5))

    # Panel 1: label trajectory + first collision.
    N = 60
    f: Callable[[int], int] = lambda s: (7 * s * s + 3 * s + 11) % N
    k = 6
    label: Callable[[int], int] = lambda s: s % k
    labels = iterate_labels(f, 17, label, k)
    coll = first_collision(labels)
    ax = axes[0]
    ax.plot(range(len(labels)), labels, "o-", color="#2b6cb0", lw=2, ms=8)
    if coll is not None:
        m, n = coll
        ax.scatter([m, n], [labels[m], labels[n]], s=260, facecolors="none",
                   edgecolors="#e53e3e", lw=3, zorder=5,
                   label=f"collision (m,n)=({m},{n})")
        ax.legend(loc="upper right")
    ax.axvline(k, color="gray", ls="--", alpha=0.6)
    ax.text(k, -0.5, "horizon k", color="gray", ha="center")
    ax.set_title("Observable labels collide within k steps")
    ax.set_xlabel("step i"); ax.set_ylabel("label(f^[i](x))")
    ax.set_yticks(range(k))

    # Panel 2: observable orbit count vs horizon (saturates below k).
    M = 100
    g: Callable[[int], int] = lambda s: (5 * s + 1) % M
    kk = 7
    lab2: Callable[[int], int] = lambda s: s % kk
    horizons = list(range(0, 40))
    counts = [len(set(iterate_labels(g, 3, lab2, h))) for h in horizons]
    ax = axes[1]
    ax.step(horizons, counts, where="post", color="#2f855a", lw=2)
    ax.axhline(kk, color="#e53e3e", ls="--", lw=2, label=f"ceiling k={kk}")
    ax.set_ylim(0, kk + 1)
    ax.set_title("Observable orbit count <= k")
    ax.set_xlabel("horizon N"); ax.set_ylabel("# distinct labels")
    ax.legend(loc="lower right")

    # Panel 3: compression ratio across lenses.
    A = 60
    lens_specs: List[Tuple[str, int]] = [
        ("id", A), ("mod12", 12), ("mod6", 6), ("mod4", 4),
        ("parity", 2), ("const", 1),
    ]
    names = [s[0] for s in lens_specs]
    ratios = [s[1] / A for s in lens_specs]
    ax = axes[2]
    bars = ax.bar(names, ratios, color="#6b46c1", alpha=0.85)
    ax.axhline(1.0, color="#e53e3e", ls="--", label="R_rho <= 1")
    ax.set_ylim(0, 1.1)
    ax.set_title("Compression ratio R_rho = k / |alpha|")
    ax.set_ylabel("R_rho"); ax.legend(loc="upper right")
    for b, r in zip(bars, ratios):
        ax.text(b.get_x() + b.get_width() / 2, r + 0.02, f"{r:.2f}",
                ha="center", fontsize=8)

    fig.suptitle("Quotient Orbit Compression: bounded-horizon collisions, "
                 "orbit ceiling, and compression ratio", fontsize=13)
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("quotient_orbit_compression.png", dpi=140)
    print("Saved quotient_orbit_compression.png")


if __name__ == "__main__":
    main()
