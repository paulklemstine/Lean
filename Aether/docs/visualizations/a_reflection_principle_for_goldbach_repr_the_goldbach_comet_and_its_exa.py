import matplotlib.pyplot as plt
from typing import Set


def sieve_primes(limit: int) -> Set[int]:
    if limit < 2:
        return set()
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return {i for i in range(limit + 1) if sieve[i]}


def goldbach_count(n: int, primes: Set[int]) -> int:
    return sum(1 for p in range(n // 2 + 1) if p in primes and (n - p) in primes)


def plot_goldbach_comet(limit: int = 2000) -> None:
    """Plot the Goldbach comet g(n) against the exact ceiling floor(n/2)+1."""
    primes = sieve_primes(limit)
    xs = list(range(4, limit + 1, 2))
    gs = [goldbach_count(n, primes) for n in xs]
    ceiling = [n // 2 + 1 for n in xs]
    plt.figure(figsize=(10, 6))
    plt.scatter(xs, gs, s=4, alpha=0.5, label="g(n): Goldbach partitions")
    plt.plot(xs, ceiling, "r-", lw=1, label="universal bound floor(n/2)+1")
    plt.xlabel("even n")
    plt.ylabel("number of representations")
    plt.title("The Goldbach comet and its exact ceiling")
    plt.legend()
    plt.tight_layout()
    plt.savefig("goldbach_comet.png", dpi=150)
    print("saved goldbach_comet.png")


if __name__ == "__main__":
    plot_goldbach_comet()
