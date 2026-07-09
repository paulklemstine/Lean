"""
Visualization: the magnitude hierarchy of transmonomials and the
non-Archimedean infinitesimal.

Left panel  : order-faithful valuation val(g) = exp(-Lambda(g)) of several
              transmonomials, showing how the value-group order ranks magnitudes
              (smaller group element = larger magnitude = more dominant).
Right panel : the explicit infinitesimal eps = term(posExp, 1). For each n, a
              fine-enough scale s makes the magnitude of n*eps drop below 1,
              illustrating n*eps < 1 (proved in the field for ALL n at once).

Run:  python viz_magnitude_hierarchy.py   (writes magnitude_hierarchy.png)
"""

from __future__ import annotations

from math import exp
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt

TransMono = Dict[int, float]


def valuation(g: TransMono, weight: float = 1.0e3) -> float:
    lam = sum(p * weight ** (-h) for h, p in g.items())
    return exp(-lam)


def main() -> None:
    monomials: List[Tuple[str, TransMono]] = [
        ("1 (const)", {}),
        ("g0^0.5", {0: 0.5}),
        ("g0^1 = posExp", {0: 1.0}),
        ("g0^2", {0: 2.0}),
        ("e1^1", {1: 1.0}),
        ("g(-1)^1", {-1: 1.0}),
    ]
    labels = [name for name, _ in monomials]
    vals = [valuation(g) for _, g in monomials]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.barh(labels, vals, color="#4C72B0")
    ax1.set_xscale("log")
    ax1.set_xlabel("valuation  val(g) = exp(-Lambda(g))  (log scale)")
    ax1.set_title("Magnitude hierarchy of transmonomials\n"
                  "(larger bar = more dominant = smaller group element)")
    ax1.axvline(1.0, color="k", ls="--", lw=1, label="constant 1")
    ax1.legend()

    ns = [1, 10, 100, 1000]
    scales = [s / 10.0 for s in range(1, 120)]
    for n in ns:
        mags = [n * exp(-s) for s in scales]  # magnitude of n*eps at scale s
        ax2.plot(scales, mags, label=f"n = {n}")
    ax2.axhline(1.0, color="k", ls="--", lw=1, label="threshold 1")
    ax2.set_yscale("log")
    ax2.set_xlabel("scale s (finer to the right)")
    ax2.set_ylabel("magnitude of n * eps  (log scale)")
    ax2.set_title("n * eps drops below 1 for every n\n"
                  "(in the field, n*eps < 1 holds for ALL n simultaneously)")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("magnitude_hierarchy.png", dpi=140)
    print("wrote magnitude_hierarchy.png")


if __name__ == "__main__":
    main()
