"""
Visualization: the Apparition-Order Bridge as a bar chart.

For b = 2, plot side by side, for each prime p, the entry point of p in the
Mersenne sequence 2^n - 1 (found by global scan) and the multiplicative
order of 2 modulo p (local computation). The two heights coincide for every
prime -- the visual signature of the bridge. We also overlay the line
y = p - 1 to display Fermat descent (entry point | p - 1, so it never
exceeds p - 1).

Requires matplotlib. Run: python visualization.py
"""
from __future__ import annotations
from typing import Dict, List, Optional
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


def factorize(n: int) -> Dict[int, int]:
    f: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            f[d] = f.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        f[n] = f.get(n, 0) + 1
    return f


def mult_order(b: int, p: int) -> Optional[int]:
    b %= p
    e = p - 1
    for q in factorize(p - 1):
        while e % q == 0 and pow(b, e // q, p) == 1:
            e //= q
    return e


def entry_point(b: int, p: int, limit: int = 100000) -> Optional[int]:
    v = 1
    for n in range(1, limit + 1):
        v = (v * b) % p
        if v == 1:
            return n
    return None


def main() -> None:
    b = 2
    primes: List[int] = [p for p in range(3, 80) if is_prime(p)]
    ep = [entry_point(b, p) for p in primes]
    od = [mult_order(b, p) for p in primes]
    pm1 = [p - 1 for p in primes]

    x = range(len(primes))
    fig, ax = plt.subplots(figsize=(13, 6))
    ax.bar([i - 0.2 for i in x], ep, width=0.4, label="entry point (global scan)")
    ax.bar([i + 0.2 for i in x], od, width=0.4, label="order of 2 mod p (local)")
    ax.plot(list(x), pm1, "k--", alpha=0.5, label="p - 1 (Fermat ceiling)")
    ax.set_xticks(list(x))
    ax.set_xticklabels([str(p) for p in primes], rotation=90, fontsize=8)
    ax.set_xlabel("prime p")
    ax.set_ylabel("index")
    ax.set_title("Apparition-Order Bridge for 2^n - 1: entry point = order of 2 mod p")
    ax.legend()
    fig.tight_layout()
    fig.savefig("apparition_order_bridge.png", dpi=150)
    print("Saved apparition_order_bridge.png")


if __name__ == "__main__":
    main()
