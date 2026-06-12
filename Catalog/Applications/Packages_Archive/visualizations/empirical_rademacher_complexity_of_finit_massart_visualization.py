"""Standalone visualization: empirical Rademacher complexity vs class size,
compared against the conjectured Massart bound B*sqrt(2 log|F| / n).

Requires matplotlib. Run: python viz_massart.py
"""
from __future__ import annotations
import itertools, math, random
from typing import Sequence, Tuple
import matplotlib.pyplot as plt

def emp_rad(F: Sequence[Sequence[float]]) -> float:
    n = len(F[0])
    if n == 0:
        return 0.0
    total = 0.0
    for sigma in itertools.product((1, -1), repeat=n):
        total += max(sum(s * x for s, x in zip(sigma, v)) for v in F)
    return total / (2 ** n * n)

def main() -> None:
    n, B = 10, 1.0
    rng = random.Random(0)
    sizes = [1, 2, 4, 8, 16, 32, 64, 128]
    emp = []
    bound = []
    for k in sizes:
        F = [[rng.choice((B, -B)) for _ in range(n)] for _ in range(k)]
        emp.append(emp_rad(F))
        bound.append(B * math.sqrt(2 * math.log(k) / n) if k > 1 else 0.0)
    plt.figure(figsize=(7, 5))
    plt.plot(sizes, emp, "o-", label="empirical Rademacher complexity")
    plt.plot(sizes, bound, "s--", label="Massart bound B*sqrt(2 log|F|/n)")
    plt.xscale("log", base=2)
    plt.xlabel("class size |F|")
    plt.ylabel("complexity")
    plt.title(f"Empirical Rademacher complexity vs class size (n={n}, B={B})")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("massart_visualization.png", dpi=150)
    print("Saved massart_visualization.png")

if __name__ == "__main__":
    main()
