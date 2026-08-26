"""
Square-core stack polyominoes: numerical demonstrations.
=========================================================

A *stack polyomino* is a bottom-justified, column-convex polyomino: it is
described completely by its list of column heights h_1, ..., h_r (all >= 1),
subject to the requirement that this list be *unimodal* -- weakly increasing
up to a maximum, then weakly decreasing.  The *core* of the stack is its
maximal plateau: the block of columns whose height equals the maximum k.
The stack has a **square core** when that plateau consists of exactly k
columns, so the top of the shape is a k x k square.

Let a(n) be the number of square-core stack polyominoes of area n.  The
structure theorem behind everything below is the slicing

        (left slope) ++ (k x k square) ++ (right slope),

which yields

        a(n) = sum_{k^2 <= n} sum_{i + j = n - k^2} p_{<=k-1}(i) p_{<=k-1}(j),

where p_{<=b}(m) is the number of partitions of m into parts of size at most
b.  Equivalently, in generating-function form,

        sum_n a(n) x^n = sum_{k >= 0} x^{k^2} / prod_{i=1}^{k-1} (1 - x^i)^2.

This script reproduces, numerically:

  1. the first 32 terms of a(n) and the fact that a(n) = 0 exactly for n in {2,3};
  2. the equality of the direct enumeration of column-height lists with the
     layer formula (a brute-force cross-check for small n);
  3. monotonicity, convexity, failure of log-concavity, failure of 3-convexity;
  4. the exact quasi-polynomial closed form of the third core layer;
  5. the stretched-exponential growth law log a(n) ~ c sqrt(n), the proved
     two-sided bounds, and the vanishing entropy density log a(n)/n -> 0;
  6. the (numerically observed) domination a(n) <= p(n) by the partition
     function, and the numerical approach of log a(n)/sqrt(n) toward the
     Hardy-Ramanujan constant pi sqrt(2/3).

All routines are self-contained; only the standard library is used.
"""

from __future__ import annotations

import math
from itertools import product
from typing import Dict, Iterator, List, Tuple

# ----------------------------------------------------------------------------
# 1. Bounded partition numbers and the layer decomposition
# ----------------------------------------------------------------------------


def bounded_partition_table(b: int, n_max: int) -> List[int]:
    """Return [p_{<=b}(0), ..., p_{<=b}(n_max)].

    Classical coin-change dynamic programme: insert the allowed part sizes
    1, 2, ..., b one at a time.  Complexity O(b * n_max).
    """
    table: List[int] = [0] * (n_max + 1)
    table[0] = 1
    for part in range(1, b + 1):
        for m in range(part, n_max + 1):
            table[m] += table[m - part]
    return table


def stack_square_core_table(n_max: int) -> List[int]:
    """Return [a(0), ..., a(n_max)] via the core-layer decomposition.

    The partition table for parts <= k-1 is updated incrementally as k grows,
    so the whole computation costs O(n_max^2) integer operations for the
    convolutions plus O(n_max^{3/2}) for the table updates.
    """
    a: List[int] = [0] * (n_max + 1)
    parts: List[int] = [0] * (n_max + 1)  # p_{<= k-1}
    parts[0] = 1
    k = 0
    while k * k <= n_max:
        room = n_max - k * k
        for m in range(room + 1):
            a[m + k * k] += sum(parts[j] * parts[m - j] for j in range(m + 1))
        if k >= 1:  # promote p_{<= k-1} to p_{<= k}
            for m in range(k, n_max + 1):
                parts[m] += parts[m - k]
        k += 1
    return a


# ----------------------------------------------------------------------------
# 2. Brute-force enumeration of square-core stacks (cross-check)
# ----------------------------------------------------------------------------


def compositions(n: int) -> Iterator[Tuple[int, ...]]:
    """All ordered tuples of positive integers summing to n (n >= 1)."""
    if n == 0:
        yield ()
        return
    for first in range(1, n + 1):
        for rest in compositions(n - first):
            yield (first,) + rest


def is_unimodal(heights: Tuple[int, ...]) -> bool:
    """True iff the tuple weakly increases and then weakly decreases."""
    i = 0
    while i + 1 < len(heights) and heights[i] <= heights[i + 1]:
        i += 1
    while i + 1 < len(heights) and heights[i] >= heights[i + 1]:
        i += 1
    return i == max(len(heights) - 1, 0)


def is_square_core_stack(heights: Tuple[int, ...]) -> bool:
    """True iff the profile is unimodal and its maximal plateau is a square."""
    if not heights:
        return True  # the empty stack, of area 0
    if not is_unimodal(heights):
        return False
    k = max(heights)
    return heights.count(k) == k


def brute_force_count(n: int) -> int:
    """Enumerate all column-height profiles of area n and filter."""
    if n == 0:
        return 1
    return sum(1 for h in compositions(n) if is_square_core_stack(h))


# ----------------------------------------------------------------------------
# 3. The third core layer, exactly
# ----------------------------------------------------------------------------


def conv_two(m: int) -> int:
    """conv_2(m) = sum_{i+j=m} p_{<=2}(i) p_{<=2}(j) with p_{<=2}(i)=floor(i/2)+1."""
    g = [i // 2 + 1 for i in range(m + 1)]
    return sum(g[j] * g[m - j] for j in range(m + 1))


def conv_two_closed_form(m: int) -> int:
    """Quasi-polynomial closed form of the third core layer.

    24 * conv_2(2s)   = (2s+2)(2s+3)(2s+4)
    24 * conv_2(2s+1) = (2s+2)(2s+4)(2s+6)
    """
    if m % 2 == 0:
        s = m // 2
        return (2 * s + 2) * (2 * s + 3) * (2 * s + 4) // 24
    s = (m - 1) // 2
    return (2 * s + 2) * (2 * s + 4) * (2 * s + 6) // 24


# ----------------------------------------------------------------------------
# 4. Growth diagnostics
# ----------------------------------------------------------------------------


def partition_table(n_max: int) -> List[int]:
    """Unrestricted partition numbers p(0..n_max)."""
    return bounded_partition_table(n_max, n_max)


def proved_lower_bound_exponent(n: int) -> int:
    """Largest m with 3m^2 + 11m + 8 <= 2n; then 2^m <= a(n) is proved."""
    m = 0
    while 3 * (m + 1) ** 2 + 11 * (m + 1) + 8 <= 2 * n:
        m += 1
    return m


def growth_report(a: List[int], p: List[int], samples: List[int]) -> None:
    print("   n        a(n) digits   log a(n)/sqrt(n)   log p(n)/sqrt(n)   log a(n)/n")
    for n in samples:
        if n >= len(a):
            continue
        la = math.log(a[n])
        print(
            f"{n:6d}   {len(str(a[n])):>10d}   {la / math.sqrt(n):>16.6f}"
            f"   {math.log(p[n]) / math.sqrt(n):>16.6f}   {la / n:>10.6f}"
        )
    print(f"   Hardy-Ramanujan constant pi*sqrt(2/3) = {math.pi * math.sqrt(2 / 3):.6f}")


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_table() -> List[int]:
    print("=" * 78)
    print("1.  The counting sequence a(n)")
    print("=" * 78)
    a = stack_square_core_table(1500)
    print("a(0..31) =", a[:32])
    expected = [1, 1, 0, 0, 1, 2, 3, 4, 5, 7, 9, 13, 17, 24, 31, 42, 54, 71, 90,
                117, 147, 188, 236, 298, 371, 466, 576, 716, 882, 1088, 1331, 1633]
    assert a[:32] == expected
    zeros = [n for n in range(len(a)) if a[n] == 0]
    print("zero set of a  :", zeros, " (exactly the two 'gap' areas 2 and 3)")
    assert zeros == [2, 3]
    print("first 12 gaps  :", [a[n + 1] - a[n] for n in range(12)])
    return a


def demo_bijection(a: List[int]) -> None:
    print()
    print("=" * 78)
    print("2.  Layer formula vs. brute-force enumeration of column profiles")
    print("=" * 78)
    print("  n   layer formula   brute force")
    for n in range(0, 17):
        bf = brute_force_count(n)
        print(f"{n:3d}   {a[n]:13d}   {bf:11d}")
        assert a[n] == bf, n
    print("  -> the arithmetic decomposition really enumerates the polyominoes.")
    print()
    print("  Example: the 7 square-core stacks of area 9, as column heights")
    for h in compositions(9):
        if is_square_core_stack(h):
            print("     ", h)


def demo_shape(a: List[int]) -> None:
    print()
    print("=" * 78)
    print("3.  Monotonicity, convexity, and the two failures")
    print("=" * 78)
    strict = all(a[n] < a[n + 1] for n in range(4, 400))
    convex = all(2 * a[n + 1] <= a[n] + a[n + 2] for n in range(2, 400))
    print(f"  strictly increasing for n >= 4 (checked to 400): {strict}")
    print(f"  convex 2a(n+1) <= a(n)+a(n+2) for n >= 2        : {convex}")
    assert strict and convex
    print(f"  log-concavity fails: a(8)^2 = {a[8] ** 2} < {a[7] * a[9]} = a(7)a(9)")
    assert a[8] ** 2 < a[7] * a[9]
    lhs, rhs = a[10] + 3 * a[8], 3 * a[9] + a[7]
    print(f"  3-convexity fails  : a(10)+3a(8) = {lhs} < {rhs} = 3a(9)+a(7)")
    assert lhs < rhs
    print("  second differences a(n+2)-2a(n+1)+a(n), n = 0..17:")
    print("   ", [a[n + 2] - 2 * a[n + 1] + a[n] for n in range(18)])


def demo_layer_three() -> None:
    print()
    print("=" * 78)
    print("4.  The third core layer is an exact quasi-polynomial")
    print("=" * 78)
    print("  m    conv_2(m)   closed form   third difference")
    for m in range(0, 14):
        d3 = (conv_two(m + 3) - 3 * conv_two(m + 2)
              + 3 * conv_two(m + 1) - conv_two(m))
        print(f"{m:3d}   {conv_two(m):9d}   {conv_two_closed_form(m):11d}   {d3:>+16d}")
        assert conv_two(m) == conv_two_closed_form(m)
    ok_even = all(conv_two(2 * t + 3) - 3 * conv_two(2 * t + 2)
                  + 3 * conv_two(2 * t + 1) - conv_two(2 * t) == -(t + 2)
                  for t in range(60))
    ok_odd = all(conv_two(2 * t + 4) - 3 * conv_two(2 * t + 3)
                 + 3 * conv_two(2 * t + 2) - conv_two(2 * t + 1) == t + 3
                 for t in range(60))
    print(f"  third difference = -(t+2) at m = 2t   : {ok_even}")
    print(f"  third difference = +(t+3) at m = 2t+1 : {ok_odd}")
    assert ok_even and ok_odd


def demo_growth(a: List[int]) -> None:
    print()
    print("=" * 78)
    print("5.  Stretched-exponential growth: log a(n) is of order sqrt(n)")
    print("=" * 78)
    n_max = len(a) - 1
    p = partition_table(n_max)
    growth_report(a, p, [50, 100, 250, 500, 1000, 1500])
    print()
    print("  Proved bounds, checked numerically:")
    print("     n      2^m lower bound (m maximal)     a(n)      30*sqrt(n) vs log a(n)")
    for n in [100, 200, 500, 1000, 1500]:
        m = proved_lower_bound_exponent(n)
        assert 2 ** m <= a[n]
        lower = (math.sqrt(n) - 2) / 2 * math.log(2)
        upper = 30 * math.sqrt(n)
        assert lower <= math.log(a[n]) <= upper
        print(f"  {n:6d}   2^{m:<3d} = {2 ** m:<20d} <= {a[n]:.4e}"
              f"    {lower:8.3f} <= {math.log(a[n]):8.3f} <= {upper:8.3f}")
    print()
    dominated = all(a[n] <= p[n] for n in range(n_max + 1))
    print(f"  a(n) <= p(n) for all n <= {n_max}: {dominated}  (observed, not proved here)")
    print(f"  log a(n)/n at n = {n_max}: {math.log(a[n_max]) / n_max:.6f}"
          "   -> 0 (vanishing entropy density)")


def main() -> None:
    a = demo_table()
    demo_bijection(a)
    demo_shape(a)
    demo_layer_three()
    demo_growth(a)
    print()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
