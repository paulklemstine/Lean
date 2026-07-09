"""
Visualization of the Fibonacci Law of Apparition.

Produces a scatter plot of the normalized rank alpha(p) / p against p for primes
7 <= p < N, coloured by which branch holds (alpha | p-1 vs alpha | p+1), with the
diagonal envelope alpha(p) <= p+1 drawn for reference.  Saves 'apparition.png'.

Self-contained except for matplotlib.
"""

from __future__ import annotations

from typing import List, Tuple

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


def divisors(n: int) -> List[int]:
    small, large = [], []
    d = 1
    while d * d <= n:
        if n % d == 0:
            small.append(d)
            if d != n // d:
                large.append(n // d)
        d += 1
    return small + large[::-1]


def fib_pair_mod(n: int, m: int) -> Tuple[int, int]:
    if m == 1:
        return (0, 0)
    if n == 0:
        return (0, 1 % m)
    a, b = fib_pair_mod(n >> 1, m)
    c = (a * ((2 * b - a) % m)) % m
    d = (a * a + b * b) % m
    return (d, (c + d) % m) if n & 1 else (c, d)


def fib_mod(n: int, m: int) -> int:
    return fib_pair_mod(n, m)[0]


def rank_bounded(p: int) -> int:
    for d in sorted(set(divisors(p - 1)) | set(divisors(p + 1))):
        if fib_mod(d, p) == 0:
            return d
    raise RuntimeError("law violated")


def main(limit: int = 2000) -> None:
    xs_minus, ys_minus, xs_plus, ys_plus = [], [], [], []
    for p in range(7, limit):
        if not is_prime(p):
            continue
        a = rank_bounded(p)
        if (p - 1) % a == 0:
            xs_minus.append(p)
            ys_minus.append(a / p)
        else:
            xs_plus.append(p)
            ys_plus.append(a / p)

    plt.figure(figsize=(10, 6))
    plt.scatter(xs_minus, ys_minus, s=8, alpha=0.6,
                label=r"$\alpha(p)\mid p-1$  ($p\equiv\pm1\,\mathrm{mod}\,5$)")
    plt.scatter(xs_plus, ys_plus, s=8, alpha=0.6,
                label=r"$\alpha(p)\mid p+1$  ($p\equiv\pm2\,\mathrm{mod}\,5$)")
    plt.axhline(1.0, color="gray", linestyle="--", linewidth=1,
                label=r"envelope $\alpha(p)=p+1$")
    plt.xlabel("prime $p$")
    plt.ylabel(r"normalized rank $\alpha(p)/p$")
    plt.title("Fibonacci rank of apparition, coloured by branch")
    plt.legend(loc="lower right")
    plt.tight_layout()
    plt.savefig("apparition.png", dpi=150)
    print("saved apparition.png")


if __name__ == "__main__":
    main()
