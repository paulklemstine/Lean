"""Numerical demonstrations for the Lazy Caterer Hierarchy.

This self-contained script illustrates the main results relating the lazy caterer
numbers p(n) (maximal planar regions from n lines) and the cake numbers c(n)
(maximal spatial regions from n planes), both realised as truncated rows of
Pascal's triangle, and linked by the layer recurrence  c(n+1) = c(n) + p(n).

All functions are inlined and use only the Python standard library.
"""

from __future__ import annotations

from math import comb
from typing import List, Tuple


# ---------------------------------------------------------------------------
# Closed forms
# ---------------------------------------------------------------------------

def caterer(n: int) -> int:
    """Lazy caterer number p(n) = n(n+1)/2 + 1 (maximal planar regions, n lines)."""
    return n * (n + 1) // 2 + 1


def cake(n: int) -> int:
    """Cake number c(n) = (n^3 + 5n + 6)/6 (maximal spatial regions, n planes)."""
    return (n * n * n + 5 * n + 6) // 6


# ---------------------------------------------------------------------------
# Binomial (truncated Pascal row) forms
# ---------------------------------------------------------------------------

def caterer_pascal(n: int) -> int:
    """p(n) as the sum of the first three entries of Pascal's row n."""
    return comb(n, 0) + comb(n, 1) + comb(n, 2)


def cake_pascal(n: int) -> int:
    """c(n) as the sum of the first four entries of Pascal's row n."""
    return comb(n, 0) + comb(n, 1) + comb(n, 2) + comb(n, 3)


def region_count(d: int, n: int) -> int:
    """H_d(n) = sum of the first d+1 entries of Pascal's row n.

    General dimensional tower: H_1(n)=n+1, H_2=p (lazy caterer), H_3=c (cake).
    """
    return sum(comb(n, k) for k in range(d + 1))


# ---------------------------------------------------------------------------
# Recurrence-based computation (additions only)
# ---------------------------------------------------------------------------

def caterer_and_cake_by_recurrence(N: int) -> Tuple[List[int], List[int]]:
    """Compute p(0..N) and c(0..N) using only additions.

    p(0)=1, p(n+1)=p(n)+(n+1);  c(0)=1, c(n+1)=c(n)+p(n).
    """
    p: List[int] = [1]
    c: List[int] = [1]
    for n in range(N):
        p.append(p[n] + (n + 1))
        c.append(c[n] + p[n])  # layer recurrence
    return p, c


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_sequences(N: int = 8) -> None:
    print("n :   p(n) (plane)   c(n) (space)")
    for n in range(N + 1):
        print(f"{n:2d}:   {caterer(n):8d}     {cake(n):8d}")


def demo_binomial_forms(N: int = 10) -> None:
    print("\nClosed form matches truncated Pascal row:")
    for n in range(N + 1):
        assert caterer(n) == caterer_pascal(n)
        assert cake(n) == cake_pascal(n)
    print(f"  verified p(n)=C(n,0)+C(n,1)+C(n,2) and "
          f"c(n)=C(n,0)+..+C(n,3) for n=0..{N}")


def demo_layer_recurrence(N: int = 12) -> None:
    print("\nLayer recurrence c(n+1) = c(n) + p(n):")
    for n in range(N + 1):
        assert cake(n + 1) == cake(n) + caterer(n)
    print(f"  verified for n=0..{N}")
    p, c = caterer_and_cake_by_recurrence(N)
    assert p == [caterer(n) for n in range(N + 1)]
    assert c == [cake(n) for n in range(N + 1)]
    print("  recurrence-only computation agrees with closed forms")


def demo_first_and_second_differences(N: int = 10) -> None:
    print("\nFirst differences p(n+1)-p(n) = n+1  (constant 2nd difference = 1):")
    diffs = [caterer(n + 1) - caterer(n) for n in range(N)]
    print("  first differences:", diffs)
    for n in range(N):
        assert diffs[n] == n + 1
    for n in range(N - 1):
        assert caterer(n + 2) + caterer(n) == 2 * caterer(n + 1) + 1


def demo_triangular_bridge(N: int = 10) -> None:
    print("\nBridge to triangular numbers p(n) = 1 + (0+1+...+n):")
    for n in range(N + 1):
        assert caterer(n) == 1 + sum(range(n + 1))
    print(f"  verified for n=0..{N}")


def demo_partial_sums(N: int = 10) -> None:
    print("\nTetrahedral partial sums  sum_{k<=n} p(k) = (n+1) + C(n+2,3):")
    for n in range(N + 1):
        lhs = sum(caterer(k) for k in range(n + 1))
        rhs = (n + 1) + comb(n + 2, 3)
        assert lhs == rhs
    print(f"  verified for n=0..{N}")


def demo_parity_law(N: int = 16) -> None:
    print("\nParity law: p(n) odd  <=>  n % 4 in {0, 3}:")
    pattern = []
    for n in range(N + 1):
        is_odd = caterer(n) % 2 == 1
        predicted = n % 4 == 0 or n % 4 == 3
        assert is_odd == predicted
        pattern.append("odd " if is_odd else "even")
    print("  parities:", " ".join(pattern[:12]), "...")


def demo_dimensional_tower(N: int = 6) -> None:
    print("\nGeneral tower H_d(n) = sum_{k<=d} C(n,k)  (H_2=p, H_3=c):")
    for d in range(1, 5):
        row = [region_count(d, n) for n in range(N + 1)]
        print(f"  d={d}: {row}")
    # cross-check the dimensional layer recurrence H_d(n+1)=H_d(n)+H_{d-1}(n)
    for d in range(1, 5):
        for n in range(N):
            assert region_count(d, n + 1) == region_count(d, n) + region_count(d - 1, n)
    print("  layer recurrence H_d(n+1)=H_d(n)+H_{d-1}(n) verified")


if __name__ == "__main__":
    demo_sequences()
    demo_binomial_forms()
    demo_layer_recurrence()
    demo_first_and_second_differences()
    demo_triangular_bridge()
    demo_partial_sums()
    demo_parity_law()
    demo_dimensional_tower()
    print("\nAll demonstrations passed.")
