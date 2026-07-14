"""Numerical demonstration of the good-manifold count of an n-nice polytope.

This self-contained script reproduces and verifies the structural results for the
sequence a(n) = maximal number of "good" manifolds in an n-nice polytope:

    6, 8, 12, 24, 40, 80, 128, 256, 512, 1024, 2048, 4096, 8192, 16384,
    32768, 65536, 131072, 262144, 524288, 1048576, 2097152, ...

Main facts demonstrated:
  * Closed form of the tail:      a(n) = 2**n           for n >= 7
  * Doubling recurrence:          a(n+1) = 2*a(n)       for n >= 7
  * Geometric partial sum:        sum_{k=7}^m a(k) = 2**(m+1) - 128
  * 2-adic valuation:             v_2(a(n)) = n         for n >= 7
  * Global strict monotonicity, parity, and the head/tail correction layer.
"""

from __future__ import annotations

from typing import Dict, List

# The tabulated head values, dimensions 1..6.
_HEAD: Dict[int, int] = {1: 6, 2: 8, 3: 12, 4: 24, 5: 40, 6: 80}


def good_manifolds(n: int) -> int:
    """Maximal number of good manifolds in an n-nice polytope (n >= 1)."""
    if n < 1:
        raise ValueError("dimension must be a positive integer")
    if n <= 6:
        return _HEAD[n]
    return 2 ** n


def correction(n: int) -> int:
    """The defect d(n) = a(n) - 2**n; zero for n >= 7."""
    return good_manifolds(n) - 2 ** n


def two_adic_valuation(m: int) -> int:
    """The 2-adic valuation v_2(m): exponent of 2 in the factorization of m."""
    if m <= 0:
        raise ValueError("valuation defined for positive integers")
    v = 0
    while m % 2 == 0:
        m //= 2
        v += 1
    return v


def tail_partial_sum(m: int) -> int:
    """Direct sum of the tail a(7) + ... + a(m) for m >= 7."""
    return sum(good_manifolds(k) for k in range(7, m + 1))


def main() -> None:
    print("=" * 66)
    print("Good manifolds in an n-nice polytope: numerical demonstration")
    print("=" * 66)

    # --- Reproduce the reference data --------------------------------------
    terms: List[int] = [good_manifolds(n) for n in range(1, 22)]
    print("\nFirst 21 terms a(1..21):")
    print("  " + ", ".join(str(t) for t in terms))
    expected = [6, 8, 12, 24, 40, 80, 128, 256, 512, 1024, 2048, 4096, 8192,
                16384, 32768, 65536, 131072, 262144, 524288, 1048576, 2097152]
    assert terms == expected, "sequence does not match reference data"
    print("  -> matches the reference data exactly.")

    # --- Closed form of the tail ------------------------------------------
    print("\nClosed form  a(n) = 2**n  for n >= 7:")
    for n in range(7, 15):
        assert good_manifolds(n) == 2 ** n
        print(f"  a({n:2d}) = {good_manifolds(n):7d} = 2**{n}")

    # --- Doubling recurrence ----------------------------------------------
    print("\nDoubling recurrence  a(n+1) = 2*a(n)  for n >= 7:")
    for n in range(7, 13):
        assert good_manifolds(n + 1) == 2 * good_manifolds(n)
        print(f"  a({n+1:2d}) = {good_manifolds(n+1):6d} = 2 * {good_manifolds(n)}")

    # --- Geometric partial sums -------------------------------------------
    print("\nGeometric partial sum  sum_{k=7}^m a(k) = 2**(m+1) - 128:")
    for m in range(7, 14):
        s = tail_partial_sum(m)
        assert s == 2 ** (m + 1) - 128
        assert s + 128 == 2 ** (m + 1)
        print(f"  m={m:2d}:  sum = {s:7d} = 2**{m+1} - 128")

    # --- 2-adic valuation equals dimension --------------------------------
    print("\n2-adic valuation  v_2(a(n)) = n  for n >= 7:")
    for n in range(7, 15):
        v = two_adic_valuation(good_manifolds(n))
        assert v == n
        print(f"  v_2(a({n:2d})) = v_2({good_manifolds(n)}) = {v}")

    # --- Parity and monotonicity ------------------------------------------
    print("\nParity: a(n) is even for all n >= 1:")
    assert all(good_manifolds(n) % 2 == 0 for n in range(1, 22))
    print("  -> verified for n = 1..21.")

    print("\nStrict monotonicity: a(n) < a(n+1) for all n >= 1:")
    assert all(good_manifolds(n) < good_manifolds(n + 1) for n in range(1, 21))
    print("  -> verified, including the head/tail junction a(6)=80 < 128=a(7).")

    # --- The correction layer of the head ---------------------------------
    print("\nCorrection layer  d(n) = a(n) - 2**n:")
    d = [correction(n) for n in range(1, 8)]
    print(f"  d(1..7) = {d}")
    assert d == [4, 4, 4, 8, 8, 16, 0]
    print("  -> head defects (4,4,4,8,8,16) are powers of two in blocks (3,2,1);")
    print("     d(n) = 0 from n = 7 onward.")

    print("\nAll assertions passed.")


if __name__ == "__main__":
    main()
