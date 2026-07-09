"""Visualization: smooth-number density L(x, y)/x and the sieve lower bound.

Generates a plot of the exact density L(x, y)/x against x for several fixed
smoothness thresholds y, overlaid with the unconditional sieve lower bound
(x - primeContribution)/x.  The curves coincide in the exact regime (x <~ y^2)
and separate as x grows enough to admit products of two large primes.

Requires: matplotlib, numpy.  Run: python viz_density.py
"""
from __future__ import annotations
from typing import List
import matplotlib.pyplot as plt


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def prime_factors(n: int) -> List[int]:
    fs, m, d = [], n, 2
    while d * d <= m:
        if m % d == 0:
            fs.append(d)
            while m % d == 0:
                m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        fs.append(m)
    return fs


def L(x: int, y: int) -> int:
    return sum(1 for n in range(1, x + 1) if all(p <= y for p in prime_factors(n)))


def sieve_lb(x: int, y: int) -> int:
    contrib = sum(x // p for p in range(y + 1, x + 1) if is_prime(p))
    return max(0, x - contrib)


def main() -> None:
    xs = list(range(20, 1001, 20))
    fig, ax = plt.subplots(figsize=(9, 6))
    for y in (5, 10, 20):
        dens = [L(x, y) / x for x in xs]
        lb = [sieve_lb(x, y) / x for x in xs]
        line, = ax.plot(xs, dens, label=f"L(x,{y})/x  (exact)")
        ax.plot(xs, lb, "--", color=line.get_color(),
                label=f"sieve LB / x  (y={y})")
    ax.set_xlabel("x")
    ax.set_ylabel("density of y-smooth integers in (0, x]")
    ax.set_title("Smooth-number density vs. the unconditional sieve lower bound")
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("smooth_density.png", dpi=150)
    print("wrote smooth_density.png")


if __name__ == "__main__":
    main()
