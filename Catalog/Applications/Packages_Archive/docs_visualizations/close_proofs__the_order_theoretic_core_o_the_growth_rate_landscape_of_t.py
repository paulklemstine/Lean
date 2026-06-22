"""Visualization: the growth-rate landscape of the p-degrees.

Renders (1) the strict separation lin < fib, (2) the polynomial-exponent height
ladder 2^(n^k) on a log-log-style axis, and (3) the collapse of the naive
exponential ladder 2^(k*n).  Requires matplotlib.
"""
from __future__ import annotations
import math
import matplotlib.pyplot as plt


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: linear vs Fibonacci (log scale on y).
    ns = list(range(1, 25))
    axes[0].semilogy(ns, ns, "o-", label="lin(n) = n")
    axes[0].semilogy(ns, [fib(n) for n in ns], "s-", label="fib(n) = F(n)")
    axes[0].set_title("Strict separation: lin < fib")
    axes[0].set_xlabel("theorem index n")
    axes[0].set_ylabel("proof size (log)")
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Panel 2: height ladder 2^(n^k) -> log2(size) = n^k.
    ns2 = list(range(1, 9))
    for k in (1, 2, 3):
        axes[1].plot(ns2, [n ** k for n in ns2], "o-", label=f"k={k}: log2 size = n^{k}")
    axes[1].set_title("Infinite height ladder  2^(n^k)")
    axes[1].set_xlabel("theorem index n")
    axes[1].set_ylabel("log2(proof size) = n^k")
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    # Panel 3: collapsing ladder 2^(k*n) -> log2 = k*n (all polynomially comparable).
    for k in (1, 2, 3):
        axes[2].plot(ns2, [k * n for n in ns2], "o-", label=f"k={k}: log2 size = {k}n")
    axes[2].set_title("Collapsing ladder  2^(k*n)  (one degree)")
    axes[2].set_xlabel("theorem index n")
    axes[2].set_ylabel("log2(proof size) = k*n")
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)

    fig.suptitle("The growth-rate landscape behind the poset of p-degrees")
    fig.tight_layout()
    fig.savefig("pdegrees_landscape.png", dpi=140)
    print("saved pdegrees_landscape.png")


if __name__ == "__main__":
    main()
