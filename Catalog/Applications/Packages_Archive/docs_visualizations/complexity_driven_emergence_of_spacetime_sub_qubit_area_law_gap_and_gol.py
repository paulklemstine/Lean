"""
Visualization: the sub-qubit area-law gap and the golden entanglement density.

Produces a two-panel figure:
  (left)  fusionCount(n) = fib(n+2) vs the qubit ceiling 2^n on a log scale,
          highlighting the strictly growing gap (Theorem 2, fusionCount_lt_two_pow).
  (right) entanglement density log(fusion(n))/n converging to log(phi),
          with the universal curvature deficit log 2 - log phi shaded.

Run:  python3 visualization.py    (saves area_law_gap.png)
"""

from __future__ import annotations

import math

import matplotlib.pyplot as plt


def fusion_count(n: int) -> int:
    if n == 0:
        return 1
    if n == 1:
        return 2
    a, b = 1, 2
    for _ in range(n - 1):
        a, b = b, a + b
    return b


def make_figure(n_max: int = 30, out: str = "area_law_gap.png") -> None:
    ns = list(range(n_max + 1))
    fusion = [fusion_count(n) for n in ns]
    qubit = [2 ** n for n in ns]
    phi = (1.0 + math.sqrt(5.0)) / 2.0
    density = [math.log(fusion_count(n)) / n for n in ns[1:]]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    ax1.semilogy(ns, qubit, "o-", label=r"qubit ceiling $2^n$", color="#c0392b")
    ax1.semilogy(ns, fusion, "s-", label=r"$\mathrm{fusionCount}(n)=F_{n+2}$",
                 color="#2980b9")
    ax1.fill_between(ns, fusion, qubit, alpha=0.15, color="#7f8c8d",
                     label="strict sub-qubit gap")
    ax1.set_xlabel("chain length $n$")
    ax1.set_ylabel("Hilbert-space dimension (log scale)")
    ax1.set_title("Strict sub-qubit area law")
    ax1.legend()
    ax1.grid(True, which="both", alpha=0.3)

    ax2.plot(ns[1:], density, "o-", color="#27ae60",
             label=r"$\log\,\mathrm{fusionCount}(n)/n$")
    ax2.axhline(math.log(phi), color="#8e44ad", ls="--",
                label=r"$\log\varphi\approx0.4812$")
    ax2.axhline(math.log(2), color="#c0392b", ls=":",
                label=r"$\log 2\approx0.6931$")
    ax2.fill_between(ns[1:], math.log(phi), math.log(2), alpha=0.12, color="#c0392b")
    ax2.text(n_max * 0.45, (math.log(2) + math.log(phi)) / 2,
             "curvature deficit\n$\\log 2-\\log\\varphi\\approx0.2119$",
             ha="center", va="center", fontsize=9)
    ax2.set_xlabel("chain length $n$")
    ax2.set_ylabel("entanglement density")
    ax2.set_title("Golden density converges to $\\log\\varphi$")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.suptitle("Golden networks live below the area-law ceiling", fontsize=14)
    fig.tight_layout()
    fig.savefig(out, dpi=150)
    print(f"saved {out}")


if __name__ == "__main__":
    make_figure()
