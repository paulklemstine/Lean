"""
Visualization: union upper bound vs. disjoint-block lower bound vs. true
containment probability for the Library of Babel.

Generates a figure showing how, as the volume length L grows, the union bound
(prob_contains_substring_bound) becomes vacuous (> 1) while the disjoint-block
lower bound (prob_contains_substring_lower_bound) climbs to 1, sandwiching the
true probability (estimated by Monte Carlo) in between.
"""

from __future__ import annotations

import random
from typing import List

import matplotlib.pyplot as plt


def union_upper(b: int, L: int, k: int) -> float:
    return (L - k + 1) / b ** k if k <= L else 0.0


def block_lower(b: int, L: int, k: int) -> float:
    q = 1.0 - 1.0 / b ** k
    return 1.0 - q ** (L // k)


def monte_carlo_contains(b: int, L: int, k: int, pattern: List[int],
                         trials: int = 4000) -> float:
    hits = 0
    for _ in range(trials):
        v = [random.randrange(b) for _ in range(L)]
        ok = any(v[i:i + k] == pattern for i in range(L - k + 1))
        hits += ok
    return hits / trials


def main() -> None:
    b, k = 2, 3
    pattern = [1, 0, 1]
    Ls = list(range(k, 60))
    upper = [min(union_upper(b, L, k), 2.0) for L in Ls]
    lower = [block_lower(b, L, k) for L in Ls]
    truth = [monte_carlo_contains(b, L, k, pattern) for L in Ls]

    plt.figure(figsize=(9, 5.5))
    plt.axhline(1.0, color="grey", ls=":", lw=1, label="probability ceiling = 1")
    plt.plot(Ls, upper, "r--", label="union upper bound  (L-k+1) b^-k")
    plt.plot(Ls, lower, "b-", label="disjoint-block lower bound")
    plt.plot(Ls, truth, "k.", label="true Pr[contains] (Monte Carlo)")
    plt.fill_between(Ls, lower, [min(u, 1.0) for u in upper], color="green",
                     alpha=0.08)
    plt.xlabel("volume length L")
    plt.ylabel("probability")
    plt.title(f"Library of Babel: containment of pattern {pattern} (b={b}, k={k})")
    plt.ylim(0, 1.6)
    plt.legend(loc="center right")
    plt.tight_layout()
    plt.savefig("babel_bounds.png", dpi=150)
    print("wrote babel_bounds.png")


if __name__ == "__main__":
    main()
