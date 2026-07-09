"""Visualize the second supplementary law as a residue wheel.

For each odd prime p up to a bound, plot p on a wheel colored by
whether 2 is a quadratic residue mod p (blue: p = +/-1 mod 8) or a
non-residue (red: p = +/-3 mod 8), illustrating the (p^2-1)/8 pattern.
"""
from __future__ import annotations

import matplotlib.pyplot as plt
import numpy as np


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


def main() -> None:
    primes = [p for p in range(3, 200, 2) if is_prime(p)]
    angles = [2 * np.pi * (p % 8) / 8 for p in primes]
    radii = [p for p in primes]
    colors = ["tab:blue" if p % 8 in (1, 7) else "tab:red" for p in primes]
    fig = plt.figure(figsize=(7, 7))
    ax = fig.add_subplot(111, projection="polar")
    ax.scatter(angles, radii, c=colors, s=40)
    ax.set_title("Is 2 a square mod p?  blue: p = +/-1 (mod 8)   red: p = +/-3 (mod 8)")
    plt.tight_layout()
    plt.savefig("second_supplement_wheel.png", dpi=150)
    print("saved second_supplement_wheel.png")


if __name__ == "__main__":
    main()
