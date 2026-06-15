"""Visualization: depth vs. semantic state complexity for chain and bushy types.

Plots log2(log2(T+1)) against depth to expose the single- vs. double-exponential
separation: chain types appear sub-linear (single exponential), bushy types
appear linear (double exponential, since log2 log2 2^(2^n) = n).

Requires matplotlib. Run:  python3 _viz_growth.py
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt


def chain_T(n: int) -> int:
    """T of a chain of depth n:  T = 3*2^n - 2."""
    return 3 * 2 ** n - 2


def bushy_T(n: int) -> int:
    """T of bushy(n):  T_{n+1} = (T_n + 1)^2, T_0 = 1."""
    t = 1
    for _ in range(n):
        t = (t + 1) ** 2
    return t


def main() -> None:
    depths: List[int] = list(range(0, 8))
    chain_vals = [math.log2(math.log2(chain_T(n) + 1)) for n in depths]
    bushy_vals = [math.log2(math.log2(bushy_T(n) + 1)) for n in depths]

    plt.figure(figsize=(8, 5))
    plt.plot(depths, chain_vals, "o-", label="chain types  (single exp: ~log2(depth))")
    plt.plot(depths, bushy_vals, "s-", label="bushy types  (double exp: = depth)")
    plt.xlabel("arrow depth")
    plt.ylabel("log2( log2( T(A) + 1 ) )")
    plt.title("Depth does not control complexity: chains vs. bushy types")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("growth_separation.png", dpi=150)
    print("wrote growth_separation.png")


if __name__ == "__main__":
    main()
