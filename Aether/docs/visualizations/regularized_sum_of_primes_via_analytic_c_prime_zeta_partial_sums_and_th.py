"""Visualize the prime zeta partial sums and the convergence wall at s = 1.
Requires matplotlib. Saves prime_zeta_abscissa.png."""
from __future__ import annotations
from typing import List
import matplotlib.pyplot as plt

def primes_up_to(limit: int) -> List[int]:
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return [i for i, p in enumerate(sieve) if p]

def main() -> None:
    primes = primes_up_to(100_000)
    counts = [10, 50, 200, 1000, 5000, len(primes)]
    fig, ax = plt.subplots(figsize=(8, 5))
    for s in (2.0, 1.5, 1.2, 1.05, 1.0, 0.9):
        ys = [sum(p ** (-s) for p in primes[:n]) for n in counts]
        ax.plot(counts, ys, marker="o", label=f"s = {s}")
    ax.set_xscale("log")
    ax.set_xlabel("number of primes summed")
    ax.set_ylabel("partial sum of p^(-s)")
    ax.set_title("Prime zeta partial sums: convergence for s>1, divergence for s<=1")
    ax.legend()
    fig.tight_layout()
    fig.savefig("prime_zeta_abscissa.png", dpi=150)
    print("saved prime_zeta_abscissa.png")

if __name__ == "__main__":
    main()
