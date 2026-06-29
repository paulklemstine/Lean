"""Visualization: Fibonacci entry points z(p) against the envelope p +/- 1.

For each prime p != 5, the entry point z(p) (least m with p | F(m)) divides
p - (5|p), hence z(p) <= p + 1. This plot shows z(p) as a scatter against p,
with the lines y = p-1 and y = p+1 bounding it, and colours indicating whether
z(p) | p-1 (5 is a QR mod p) or z(p) | p+1.

Standalone: requires only matplotlib.
"""

from __future__ import annotations

from typing import List, Optional, Tuple
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


def entry_point(p: int, bound: int = 2000) -> Optional[int]:
    a, b = 0, 1
    for m in range(1, bound + 1):
        a, b = b, a + b
        if a % p == 0:
            return m
    return None


def main() -> None:
    primes: List[int] = [p for p in range(2, 200) if is_prime(p) and p != 5]
    ps, zs, colors = [], [], []
    for p in primes:
        z = entry_point(p)
        if z is None:
            continue
        ps.append(p)
        zs.append(z)
        colors.append("#06d6a0" if (p - 1) % z == 0 else "#ef476f")

    fig, ax = plt.subplots(figsize=(9, 6))
    xs = list(range(2, 200))
    ax.plot(xs, [x - 1 for x in xs], "--", color="#888", label="y = p - 1")
    ax.plot(xs, [x + 1 for x in xs], "--", color="#444", label="y = p + 1")
    ax.scatter(ps, zs, c=colors, s=42, edgecolors="k", linewidths=.4, zorder=3)
    ax.scatter([], [], c="#06d6a0", label="z(p) | p - 1  (5 is QR mod p)")
    ax.scatter([], [], c="#ef476f", label="z(p) | p + 1  (5 is non-residue)")
    ax.set_xlabel("prime p")
    ax.set_ylabel("Fibonacci entry point z(p)")
    ax.set_title("Fibonacci entry points stay within the envelope  z(p) <= p + 1")
    ax.legend(loc="upper left")
    ax.grid(True, alpha=.25)
    fig.tight_layout()
    fig.savefig("entry_points.png", dpi=150)
    print("wrote entry_points.png")


if __name__ == "__main__":
    main()
