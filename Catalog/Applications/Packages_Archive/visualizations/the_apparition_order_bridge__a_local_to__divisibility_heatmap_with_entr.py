"""Visualization: the support of a prime in b^n - 1 is a perfect arithmetic
progression, and the spacing equals the multiplicative order mod p.

Generates a heatmap of divisibility (prime p vs index n) for a(n) = 2^n - 1,
with the entry point (= order of 2 mod p) highlighted.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import gcd


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for d in range(2, int(n ** 0.5) + 1):
        if n % d == 0:
            return False
    return True


def order(b: int, p: int) -> int:
    acc, k = b % p, 1
    while acc != 1 % p:
        acc = (acc * b) % p
        k += 1
    return k


def main() -> None:
    b = 2
    primes = [p for p in range(3, 50) if is_prime(p) and b % p != 0]
    n_max = 30
    grid = np.zeros((len(primes), n_max))
    for i, p in enumerate(primes):
        for n in range(1, n_max + 1):
            grid[i, n - 1] = 1.0 if (pow(b, n, p) == 1 % p) else 0.0

    fig, ax = plt.subplots(figsize=(11, 8))
    ax.imshow(grid, aspect="auto", cmap="Blues", origin="lower",
              extent=[1, n_max, 0, len(primes)])
    for i, p in enumerate(primes):
        e = order(b, p)
        ax.scatter([e], [i + 0.5], color="crimson", s=40, zorder=3)
    ax.set_yticks([i + 0.5 for i in range(len(primes))])
    ax.set_yticklabels(primes)
    ax.set_xlabel("index n")
    ax.set_ylabel("prime p")
    ax.set_title("Support of p in 2^n - 1 (blue = p | 2^n - 1); "
                 "red dot = entry point = order(2 mod p)")
    plt.tight_layout()
    plt.savefig("apparition_support.png", dpi=130)
    print("wrote apparition_support.png")


if __name__ == "__main__":
    main()
