"""Visualization: capacity growth curve of expected Rademacher complexity.

Plots R_n(H) as the hypothesis class grows, illustrating monotonicity
(Theorem 4.5) and the uniform upper bound R_n(H) <= B = 1 (Theorem 4.6).
Requires matplotlib.
"""
from __future__ import annotations
from itertools import product
from typing import Sequence
import random
import matplotlib.pyplot as plt


def corr(sigma: Sequence[int], h: Sequence[float]) -> float:
    n = len(h)
    return sum(s * x for s, x in zip(sigma, h)) / n if n else 0.0


def expected_rademacher(n: int, H: Sequence[Sequence[float]]) -> float:
    patterns = list(product((-1, 1), repeat=n))
    return sum(max(corr(s, h) for h in H) for s in patterns) / len(patterns)


def main() -> None:
    n = 8
    random.seed(1)
    pool = [[random.choice([-1.0, 1.0]) for _ in range(n)] for _ in range(64)]
    sizes = list(range(1, 65))
    vals = [expected_rademacher(n, pool[:m]) for m in sizes]

    plt.figure(figsize=(8, 5))
    plt.plot(sizes, vals, marker="o", ms=3, lw=1.4, label=r"$R_n(H)$")
    plt.axhline(1.0, color="crimson", ls="--", label="upper bound B = 1")
    plt.xlabel("number of hypotheses |H|")
    plt.ylabel("expected Rademacher complexity")
    plt.title(f"Capacity grows with class size (n = {n}, binary signs)")
    plt.legend()
    plt.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig("capacity_growth.png", dpi=150)
    print("saved capacity_growth.png")


if __name__ == "__main__":
    main()
