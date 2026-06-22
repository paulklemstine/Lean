"""Visualization: the apparition lattice and the Fibonacci-shadow closure.

Generates two panels:
  (left)  fibRank m for m = 1..60, highlighting prime moduli;
  (right) the closure map m -> F(fibRank m), with fixed points (Fibonacci values)
          marked on the diagonal.

Requires matplotlib. Run:  python _assets_viz.py
"""
from __future__ import annotations

from math import gcd
import matplotlib.pyplot as plt


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def fib_rank(m: int) -> int:
    if m == 0:
        return 0
    a, b = 0 % m, 1 % m
    k = 0
    while True:
        k += 1
        a, b = b, (a + b) % m
        if a == 0:
            return k


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True


def main() -> None:
    N = 60
    ms = list(range(1, N + 1))
    ranks = [fib_rank(m) for m in ms]
    prime_mask = [is_prime(m) for m in ms]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    colors = ["#d62728" if p else "#1f77b4" for p in prime_mask]
    ax1.bar(ms, ranks, color=colors)
    ax1.set_title("Rank of apparition  fibRank(m)\n(red = prime modulus)")
    ax1.set_xlabel("modulus m")
    ax1.set_ylabel("fibRank m  (least k>0 with m | F(k))")

    fibs = {fib(k) for k in range(0, 25)}
    closure = [fib(fib_rank(m)) for m in ms]
    fixed = [m for m in ms if m in fibs]
    fixed_c = [fib(fib_rank(m)) for m in fixed]
    ax2.scatter(ms, closure, s=18, color="#1f77b4", label="closure c(m)=F(fibRank m)")
    ax2.scatter(fixed, fixed_c, s=70, facecolors="none", edgecolors="#d62728",
                linewidths=1.6, label="fixed points = Fibonacci values")
    ax2.plot([1, N], [1, N], "k--", alpha=0.4, label="diagonal c(m)=m")
    ax2.set_yscale("log")
    ax2.set_title("Closure operator rounds m up to its Fibonacci shadow")
    ax2.set_xlabel("modulus m")
    ax2.set_ylabel("c(m) = F(fibRank m)  (log scale)")
    ax2.legend(loc="upper left", fontsize=8)

    fig.suptitle("The Fibonacci apparition adjunction  fibRank \u22a3 fib", fontsize=13)
    fig.tight_layout()
    fig.savefig("apparition_adjunction.png", dpi=150)
    print("Saved apparition_adjunction.png")


if __name__ == "__main__":
    main()
