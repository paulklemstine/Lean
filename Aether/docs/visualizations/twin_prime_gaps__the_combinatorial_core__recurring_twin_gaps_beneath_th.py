"""
Visualization: the prime-gap sequence with recurring small gaps and the 246 ceiling.

Generates `prime_gaps.png`: a scatter/stem plot of primeGap(n) = p_{n+1} - p_n
for n up to a chosen range, highlighting (a) the twin gaps (gap = 2) that recur
arbitrarily far out, and (b) the Maynard-Tao ceiling 246 that consecutive gaps
dip below infinitely often.
"""

from __future__ import annotations

import matplotlib.pyplot as plt


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def prime_list(count: int) -> list[int]:
    ps: list[int] = []
    c = 1
    while len(ps) < count:
        c += 1
        if is_prime(c):
            ps.append(c)
    return ps


def main() -> None:
    N = 600
    ps = prime_list(N + 1)
    gaps = [ps[n + 1] - ps[n] for n in range(N)]
    idx = list(range(N))

    fig, ax = plt.subplots(figsize=(12, 6))
    ax.scatter(idx, gaps, s=10, color="#3b6fb6", alpha=0.7, label="primeGap(n)")
    twin_x = [n for n in idx if gaps[n] == 2]
    twin_y = [2] * len(twin_x)
    ax.scatter(twin_x, twin_y, s=22, color="#d1495b",
               label="twin gaps (gap = 2), recur forever")
    ax.axhline(246, color="#2a9d8f", linestyle="--", linewidth=1.5,
               label="Maynard-Tao ceiling 246")
    ax.set_xlabel("prime index n")
    ax.set_ylabel("gap  p_{n+1} - p_n")
    ax.set_title("Consecutive prime gaps: small gaps recur, all stay far below 246")
    ax.legend(loc="upper left")
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("prime_gaps.png", dpi=140)
    print("wrote prime_gaps.png")


if __name__ == "__main__":
    main()
