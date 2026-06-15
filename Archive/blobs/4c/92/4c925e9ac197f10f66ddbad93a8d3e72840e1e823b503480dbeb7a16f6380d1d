"""Visualization: the primitive part of F(n) and the exceptional set.

We plot log10(primPart(n)) against n for 1 <= n <= 60. Every bar is positive
(i.e. primPart(n) > 1, certifying a primitive prime divisor) EXCEPT at the four
exceptional indices n in {1, 2, 6, 12}, where primPart(n) = 1 (log = 0) and the
bar vanishes. The plot makes the sharp threshold n = 13 visually obvious.

Standalone: requires only matplotlib (and the standard library math.gcd).
"""

from __future__ import annotations

from math import gcd, log10
from typing import List
import matplotlib.pyplot as plt


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def proper_divisors(n: int) -> List[int]:
    return [d for d in range(1, n) if n % d == 0]


def strip_all(r: int, m: int) -> int:
    if m <= 1:
        return r
    while True:
        g = gcd(r, m)
        if g <= 1:
            return r
        r //= g


def prim_part(n: int) -> int:
    r = fib(n)
    for d in proper_divisors(n):
        r = strip_all(r, fib(d))
    return r


def main() -> None:
    N = 60
    ns = list(range(1, N + 1))
    vals = [prim_part(n) for n in ns]
    heights = [log10(v) if v > 1 else 0.0 for v in vals]
    exceptional = {1, 2, 6, 12}
    colors = ["#ef476f" if n in exceptional else "#118ab2" for n in ns]

    fig, ax = plt.subplots(figsize=(11, 5.5))
    ax.bar(ns, heights, color=colors, edgecolor="k", linewidth=.3)
    ax.axvline(12.5, color="#ffd166", linestyle="--", linewidth=2,
               label="sharp threshold n = 13")
    ax.set_xlabel("index n")
    ax.set_ylabel("log10(primitive part of F(n))")
    ax.set_title("Primitive part of F(n): positive everywhere except n in {1, 2, 6, 12}")
    ax.bar([], [], color="#ef476f", label="exceptional (primPart = 1)")
    ax.bar([], [], color="#118ab2", label="has primitive divisor")
    ax.legend(loc="upper left")
    ax.grid(True, axis="y", alpha=.25)
    fig.tight_layout()
    fig.savefig("primitive_part.png", dpi=150)
    print("wrote primitive_part.png")


if __name__ == "__main__":
    main()
