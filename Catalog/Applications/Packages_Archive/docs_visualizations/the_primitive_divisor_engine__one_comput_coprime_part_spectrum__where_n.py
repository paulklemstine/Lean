"""
visualize.py — Visualizing the primitive-divisor engine for strong divisibility sequences.

Produces a figure with two panels:
  (left)  Fibonacci F(n): the coprime part cp(F, n) on a log scale, with barren
          indices {1,2,6,12} highlighted in red.
  (right) Mersenne 2^n - 1: the coprime part cp(u, n) on a log scale, with the
          single barren index {6} highlighted in red.

Wherever cp > 1 a primitive prime divisor is guaranteed (Theorem
`primitive_of_coprimePart_pos`).  The red bars sit at height 1 — exactly the
classical exception sets of Carmichael (Fibonacci) and Bang (2^n - 1).

Requires: matplotlib, numpy.   Run:  python3 visualize.py
"""

from __future__ import annotations

from math import gcd
from typing import Callable, List

import matplotlib.pyplot as plt
import numpy as np


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne(n: int, a: int = 2) -> int:
    return a ** n - 1


def remove_primes_of(a: int, b: int) -> int:
    if a == 0:
        return 0
    while True:
        g = gcd(a, b)
        if g <= 1:
            return a
        a //= g


def coprime_part(u: Callable[[int], int], n: int) -> int:
    acc = u(n)
    for d in range(1, n):
        if n % d == 0:
            acc = remove_primes_of(acc, u(d))
    return acc


def bars(u: Callable[[int], int], hi: int) -> List[float]:
    return [max(coprime_part(u, n), 1) for n in range(1, hi + 1)]


def main() -> None:
    hi_f, hi_m = 40, 30
    xs_f = np.arange(1, hi_f + 1)
    xs_m = np.arange(1, hi_m + 1)
    cp_f = bars(fib, hi_f)
    cp_m = bars(mersenne, hi_m)

    fib_exc = {1, 2, 6, 12}
    mer_exc = {1, 6}

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    col_f = ["#d62728" if n in fib_exc else "#1f77b4" for n in xs_f]
    ax1.bar(xs_f, cp_f, color=col_f, log=True)
    ax1.axhline(1, color="black", lw=0.8, ls="--")
    ax1.set_title("Fibonacci: coprime part cp(F, n)\n(red = barren, height 1)")
    ax1.set_xlabel("n")
    ax1.set_ylabel("cp(F, n)  (log scale)")

    col_m = ["#d62728" if n in mer_exc else "#2ca02c" for n in xs_m]
    ax2.bar(xs_m, cp_m, color=col_m, log=True)
    ax2.axhline(1, color="black", lw=0.8, ls="--")
    ax2.set_title("Mersenne 2^n - 1: coprime part cp(u, n)\n(red = barren, height 1)")
    ax2.set_xlabel("n")
    ax2.set_ylabel("cp(2^n - 1, n)  (log scale)")

    fig.suptitle(
        "One engine, two theorems: a coprime part > 1 certifies a primitive prime divisor",
        fontsize=13,
    )
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("coprime_part.png", dpi=140)
    print("Wrote coprime_part.png")


if __name__ == "__main__":
    main()
