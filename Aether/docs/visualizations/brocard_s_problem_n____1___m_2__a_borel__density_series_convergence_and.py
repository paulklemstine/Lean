"""
Visualization: convergence of the Brocard density series and the squeeze that
proves it. Produces a two-panel figure:

  (left)  partial sums S_N = sum_{n=0}^N 1/sqrt(n!) approaching their limit,
          with the rigorous geometric tail bound shaded;
  (right) the term-by-term comparison 1/sqrt(n!) <= sqrt(2)*(1/sqrt(2))^n on a
          log scale, the geometric domination underlying the convergence proof.

Requires matplotlib. Run:  python viz.py
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt


def density_terms(N: int) -> List[float]:
    terms: List[float] = []
    fact = 1
    for n in range(N + 1):
        if n > 0:
            fact *= n
        terms.append(1.0 / math.sqrt(fact))
    return terms


def main() -> None:
    N = 12
    terms = density_terms(N)
    partial = []
    s = 0.0
    for t in terms:
        s += t
        partial.append(s)
    limit = partial[-1]

    geo = [math.sqrt(2.0) * (1.0 / math.sqrt(2.0)) ** n for n in range(N + 1)]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4.5))

    ax1.axhline(limit, color="crimson", ls="--", lw=1, label=f"limit ~ {limit:.4f}")
    ax1.plot(range(N + 1), partial, "o-", color="navy", label="partial sum $S_N$")
    ax1.set_title("Convergence of $\\sum_n 1/\\sqrt{n!}$")
    ax1.set_xlabel("$N$")
    ax1.set_ylabel("$S_N$")
    ax1.legend()
    ax1.grid(alpha=0.3)

    ax2.semilogy(range(N + 1), terms, "o-", color="navy",
                 label="$1/\\sqrt{n!}$")
    ax2.semilogy(range(N + 1), geo, "s--", color="darkorange",
                 label="$\\sqrt{2}\\,(1/\\sqrt{2})^n$ (dominating)")
    ax2.set_title("Geometric domination (the convergence proof)")
    ax2.set_xlabel("$n$")
    ax2.set_ylabel("term (log scale)")
    ax2.legend()
    ax2.grid(alpha=0.3, which="both")

    fig.suptitle("Brocard density heuristic: the summable tail behind "
                 "Borel-Cantelli finiteness")
    fig.tight_layout()
    fig.savefig("brocard_density.png", dpi=150)
    print("saved brocard_density.png")


if __name__ == "__main__":
    main()
