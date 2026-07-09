"""Visualize ranks of apparition and primitive-part sizes for Fibonacci.

Produces two panels:
  (1) the least prime factor of primPart(n) (a primitive prime divisor) vs n,
      on a log scale, with prime indices highlighted;
  (2) the rank of apparition alpha(p) of small primes p, illustrating the law
      p | F(n) <=> alpha(p) | n.
Requires matplotlib. Run: python visualize.py
"""
from math import gcd
from typing import Dict, List
import matplotlib.pyplot as plt


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True


def least_prime_factor(n: int) -> int:
    d = 2
    while d * d <= n:
        if n % d == 0:
            return d
        d += 1
    return n


def prim_part(n: int) -> int:
    r = fib(n)
    for d in (x for x in range(1, n) if n % x == 0):
        m = fib(d)
        while True:
            g = gcd(r, m)
            if g <= 1:
                break
            r //= g
    return r


def rank_of_apparition(p: int, limit: int = 400) -> int:
    for n in range(1, limit + 1):
        if fib(n) % p == 0:
            return n
    return -1


def main() -> None:
    ns = list(range(13, 81))
    prim_lpf = [least_prime_factor(prim_part(n)) for n in ns]
    colors = ["crimson" if is_prime(n) else "steelblue" for n in ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    ax1.scatter(ns, prim_lpf, c=colors, s=40)
    ax1.set_yscale("log")
    ax1.set_xlabel("index n")
    ax1.set_ylabel("least prime factor of primPart(n)")
    ax1.set_title("Primitive prime divisor of F(n)\n(red = prime index)")
    ax1.grid(True, which="both", ls=":", alpha=0.5)

    primes = [p for p in range(2, 60) if is_prime(p)]
    ranks = [rank_of_apparition(p) for p in primes]
    ax2.bar([str(p) for p in primes], ranks, color="seagreen")
    ax2.set_xlabel("prime p")
    ax2.set_ylabel("rank of apparition  alpha(p)")
    ax2.set_title("First index n with p | F(n)")
    ax2.tick_params(axis="x", rotation=90)

    fig.tight_layout()
    fig.savefig("carmichael_fibonacci.png", dpi=150)
    print("wrote carmichael_fibonacci.png")


if __name__ == "__main__":
    main()
