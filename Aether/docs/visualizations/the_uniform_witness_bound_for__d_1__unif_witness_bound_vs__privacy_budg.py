"""
Visualization: the Uniform Witness Bound W(d,s,n) as a function of the
privacy budget s, with the two regimes (saturated s=0 and witnessed s>=1)
shown together with the trivial-star and complete-family cardinalities.

Generates 'witness_bound.png'.  Requires matplotlib.
"""

from __future__ import annotations

from math import comb
from typing import List

import matplotlib.pyplot as plt


def witness_bound(d: int, s: int, n: int) -> int:
    if s == 0:
        return comb(n, d + 1)
    return comb(n, d) // s


def main() -> None:
    d, n = 3, 12
    s_values: List[int] = list(range(0, d + 1))
    bounds: List[int] = [witness_bound(d, s, n) for s in s_values]

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(s_values, bounds, "o-", lw=2.2, ms=9, color="#1f77b4",
            label=r"$W(d,s,n)$")
    ax.axhline(comb(n, d + 1), ls="--", color="#2ca02c",
               label=r"complete family $\binom{n}{d+1}$")
    ax.axhline(comb(n - 1, d), ls=":", color="#d62728",
               label=r"trivial star $\binom{n-1}{d}$")

    for s, b in zip(s_values, bounds):
        ax.annotate(str(b), (s, b), textcoords="offset points",
                    xytext=(0, 10), ha="center", fontsize=9)

    ax.set_title(f"Uniform witness bound  (d={d}, n={n})", fontsize=13)
    ax.set_xlabel("missing-trace size  s  (privacy budget)")
    ax.set_ylabel("maximum family size")
    ax.set_xticks(s_values)
    ax.grid(alpha=0.3)
    ax.legend()
    fig.tight_layout()
    fig.savefig("witness_bound.png", dpi=150)
    print("Wrote witness_bound.png")


if __name__ == "__main__":
    main()
