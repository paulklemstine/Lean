"""
Visualization: the sign characters of mirror symmetry.

Produces a two-panel figure:
  (left)  the Euler-characteristic rescaling factor (-1)^n versus dimension n,
          overlaid with the Weil functional-equation sign (-1)^(n+1), making the
          "sign bridge" (-1)^(n+1) = -(-1)^n visually obvious;
  (right) a heatmap of the signed Hodge diamond of the quintic Calabi-Yau
          threefold (entries (-1)^(p+q) h^{p,q}), whose total is chi = -200,
          alongside its mirror (total +200).

Requires only matplotlib + numpy.  Run: python3 _viz.py
"""

from __future__ import annotations

from typing import Dict, Tuple

import numpy as np
import matplotlib.pyplot as plt


def quintic_diamond() -> Dict[Tuple[int, int], int]:
    return {(0, 0): 1, (3, 3): 1, (0, 3): 1, (3, 0): 1,
            (1, 1): 1, (2, 2): 1, (2, 1): 101, (1, 2): 101}


def signed_grid(h: Dict[Tuple[int, int], int], n: int) -> np.ndarray:
    g = np.zeros((n + 1, n + 1))
    for p in range(n + 1):
        for q in range(n + 1):
            g[p, q] = ((-1) ** (p + q)) * h.get((p, q), 0)
    return g


def main() -> None:
    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(13, 5))

    # Panel 1: the two sign characters
    ns = np.arange(0, 9)
    euler_sign = (-1.0) ** ns
    fe_sign = (-1.0) ** (ns + 1)
    ax0.step(ns, euler_sign, where="mid", lw=2.5, label=r"Euler sign $(-1)^n$", color="#2563eb")
    ax0.step(ns, fe_sign, where="mid", lw=2.5, ls="--",
             label=r"Weil FE sign $(-1)^{n+1}$", color="#dc2626")
    ax0.axhline(0, color="#888", lw=.6)
    ax0.set_xlabel("complex dimension n")
    ax0.set_ylabel("sign")
    ax0.set_yticks([-1, 1])
    ax0.set_title(r"Sign bridge:  $(-1)^{n+1} = -(-1)^n$")
    ax0.legend(loc="upper right")
    ax0.grid(alpha=.25)

    # Panel 2: signed quintic diamond and its mirror
    h = quintic_diamond()
    n = 3
    G = signed_grid(h, n)
    Gm = signed_grid({(3 - p, q): v for (p, q), v in h.items()}, n)
    vmax = max(abs(G).max(), abs(Gm).max())
    combined = np.hstack([G, np.full((n + 1, 1), np.nan), Gm])
    im = ax1.imshow(combined, cmap="coolwarm", vmin=-vmax, vmax=vmax)
    for j, base in [(0, G), (n + 2, Gm)]:
        for p in range(n + 1):
            for q in range(n + 1):
                ax1.text(q + j, p, f"{int(base[p, q])}",
                         ha="center", va="center", fontsize=9, color="#111")
    ax1.set_title(f"Signed quintic diamond  (chi={int(G.sum())})"
                  f"   |   mirror (chi={int(Gm.sum())})")
    ax1.set_xticks([])
    ax1.set_yticks(range(n + 1))
    ax1.set_ylabel("p")
    fig.colorbar(im, ax=ax1, fraction=.046, pad=.04, label=r"$(-1)^{p+q}h^{p,q}$")

    fig.suptitle("Arithmetic Mirror Symmetry: one reflection, two faces", fontsize=14)
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("mirror_symmetry_signs.png", dpi=150)
    print("Saved mirror_symmetry_signs.png")


if __name__ == "__main__":
    main()
