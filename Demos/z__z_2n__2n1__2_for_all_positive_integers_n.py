"""
Numerical demonstration of the width invariant of G_n = Z_2 x (Z_2)^n
and its tropical (min-plus) dual.

The group G_n is identified with the (n+1)-dimensional Boolean lattice B_{n+1}.
Its rank layers have sizes given by binomial coefficients C(n+1, k), which:

  * sum to 2^{n+1}                          (the group order),
  * have maximum  beta(G_n) = C(n+1, floor((n+1)/2))   (the poset width),
  * have minimum  1                          (the tropical dual, at the poles).

This script is self-contained: every function is inlined and type-hinted.
Run:  python demo.py
"""

from __future__ import annotations

from math import comb, floor
from typing import List, Tuple


def group_order(n: int) -> int:
    """Return |Z_2 x (Z_2)^n| = 2^(n+1)."""
    return 2 ** (n + 1)


def rank_profile(n: int) -> List[int]:
    """Return the rank profile [C(n+1, k) for k = 0 .. n+1] of B_{n+1}."""
    m = n + 1
    return [comb(m, k) for k in range(m + 1)]


def beta(n: int) -> int:
    """Return the width invariant beta(G_n) = C(n+1, floor((n+1)/2))."""
    m = n + 1
    return comb(m, m // 2)


def profile_sum(n: int) -> int:
    """Sum of the rank profile; equals the group order 2^(n+1)."""
    return sum(rank_profile(n))


def classical_width(n: int) -> int:
    """Classical aggregation (max) of the rank profile: the poset width."""
    return max(rank_profile(n))


def tropical_width_dual(n: int) -> int:
    """Tropical (min-plus) aggregation of the rank profile: the minimum, = 1."""
    return min(rank_profile(n))


def verify_invariants(n: int) -> Tuple[bool, bool, bool, bool]:
    """Check the four core identities for a given n."""
    prof = rank_profile(n)
    m = n + 1
    order_ok = group_order(n) == 2 ** m
    partition_ok = sum(prof) == group_order(n)
    width_ok = max(prof) == beta(n) == comb(m, m // 2)
    tropical_ok = min(prof) == 1
    return order_ok, partition_ok, width_ok, tropical_ok


def main() -> None:
    print("=" * 72)
    print(" Width invariant of G_n = Z_2 x (Z_2)^n  and its tropical dual")
    print("=" * 72)
    header = f"{'n':>3} | {'|G_n|=2^(n+1)':>13} | {'sum profile':>11} | "
    header += f"{'beta (width)':>12} | {'tropical min':>12}"
    print(header)
    print("-" * len(header))

    for n in range(0, 11):
        order = group_order(n)
        s = profile_sum(n)
        w = classical_width(n)
        t = tropical_width_dual(n)
        print(f"{n:>3} | {order:>13} | {s:>11} | {w:>12} | {t:>12}")

    print()
    print("Rank profiles (Pascal rows) of B_{n+1}:")
    for n in range(0, 6):
        print(f"  n={n} (B_{n+1}): {rank_profile(n)}   width={beta(n)}")

    print()
    print("Verification of the four invariants for n = 0 .. 20:")
    all_ok = True
    for n in range(0, 21):
        checks = verify_invariants(n)
        all_ok &= all(checks)
        if not all(checks):
            print(f"  FAIL at n={n}: {checks}")
    print("  All invariants hold." if all_ok else "  Some invariant FAILED.")

    print()
    print("Min-max duality on the rank profile:")
    for n in (2, 5, 9):
        prof = rank_profile(n)
        print(
            f"  n={n}: max={max(prof)} (central C({n+1},{(n+1)//2})), "
            f"min={min(prof)} (poles, empty/full set)"
        )


if __name__ == "__main__":
    main()
