"""Visualization: p-adic valuations of n! and the lone Bertrand prime.

Renders a heatmap of v_p(n!) for primes p versus n, highlighting the diagonal
band of Bertrand primes p in (n/2, n] where the valuation is exactly 1 -- the
single odd exponent that forbids n! from being a perfect square.
Requires matplotlib and numpy.
"""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True


def v_p_factorial(n: int, p: int) -> int:
    total, q = 0, p
    while q <= n:
        total += n // q
        q *= p
    return total


def main() -> None:
    N = 40
    primes = [p for p in range(2, N + 1) if is_prime(p)]
    grid = np.zeros((len(primes), N + 1), dtype=int)
    for j, n in enumerate(range(N + 1)):
        for i, p in enumerate(primes):
            grid[i, j] = v_p_factorial(n, p) if p <= n else 0

    fig, ax = plt.subplots(figsize=(11, 6))
    im = ax.imshow(grid, origin="lower", aspect="auto", cmap="magma")
    ax.set_xlabel("n")
    ax.set_ylabel("prime p")
    ax.set_yticks(range(len(primes)))
    ax.set_yticklabels(primes)
    ax.set_title("v_p(n!): Bertrand primes (valuation 1) obstruct squareness")
    # outline cells where p in (n/2, n] and valuation == 1
    for j, n in enumerate(range(N + 1)):
        for i, p in enumerate(primes):
            if p <= n < 2 * p and grid[i, j] == 1:
                ax.add_patch(plt.Rectangle((j - 0.5, i - 0.5), 1, 1,
                             fill=False, edgecolor="cyan", lw=1.5))
    fig.colorbar(im, ax=ax, label="valuation v_p(n!)")
    fig.tight_layout()
    fig.savefig("valuation_heatmap.png", dpi=150)
    print("Saved valuation_heatmap.png")


if __name__ == "__main__":
    main()
