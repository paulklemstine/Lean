"""Visualization: the Anti-Gravity Trade-off ceiling and the floating theorems.

Plots, for each dependency index n on a log-y axis:
  * the weight  w(n) = n,
  * the trade-off lower bound  2 ** proofComplexity(n),
and highlights the anti-gravity theorems (powers of two) where the two coincide.

Run:  python _viz.py   ->   writes anti_gravity_tradeoff.png
"""
from __future__ import annotations
from typing import List
import matplotlib.pyplot as plt


def prime_factors_list(n: int) -> List[int]:
    if n < 2:
        return []
    factors: List[int] = []
    d, m = 2, n
    while d * d <= m:
        while m % d == 0:
            factors.append(d)
            m //= d
        d += 1
    if m > 1:
        factors.append(m)
    return factors


def proof_complexity(n: int) -> int:
    return len(prime_factors_list(n))


def main() -> None:
    N = 256
    xs = list(range(1, N + 1))
    weights = xs
    lower = [2 ** proof_complexity(n) for n in xs]
    floaters = [n for n in xs if 2 ** proof_complexity(n) == n]

    fig, ax = plt.subplots(figsize=(11, 6))
    ax.plot(xs, weights, color="#1f77b4", lw=1.2, label="weight(n) = n")
    ax.plot(xs, lower, color="#d62728", lw=1.0, alpha=0.8,
            label=r"$2^{\mathrm{proofComplexity}(n)}$ (trade-off floor)")
    ax.scatter(floaters, floaters, color="#2ca02c", zorder=5, s=45,
               label="anti-gravity theorems (powers of two)")
    ax.set_yscale("log", base=2)
    ax.set_xlabel("dependency index  n")
    ax.set_ylabel("value (log scale, base 2)")
    ax.set_title("Anti-Gravity Trade-off:  "
                 r"$2^{\mathrm{proofComplexity}} \leq \mathrm{weight}$, "
                 "equality on the powers of two")
    ax.legend(loc="upper left")
    ax.grid(True, which="both", ls=":", alpha=0.4)
    fig.tight_layout()
    fig.savefig("anti_gravity_tradeoff.png", dpi=150)
    print("wrote anti_gravity_tradeoff.png")


if __name__ == "__main__":
    main()
