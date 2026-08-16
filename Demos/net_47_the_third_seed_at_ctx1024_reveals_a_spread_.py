"""
Binary staircase numbers and the census theory of dyadic-grid measurements.

A *staircase number* is a positive integer whose base-two expansion is a nonempty
block of ones followed by a block of zeros:

    st(b, j) = 2**b * (2**j - 1) = 2**(b + j) - 2**b     (j >= 1, b >= 0).

This self-contained demo verifies, numerically, every result of the accompanying
paper:

  1. normal form           -- (b, j) is recoverable as (2-adic valuation, digit sum)
  2. midpoint law          -- 2*st(b, j+1) = st(b+1, j) + 2**(b+j+1)
  3. fraction law          -- st(b, j+1) = (2**(j+1) - 1)/2**(j+1) of the top point
  4. census theorem        -- the grid-admissible staircase numbers of an octave
  5. logarithmic scarcity  -- there are exactly n - g of them
  6. bracket / waste 4/3   -- all of them lie in [3/4 * 2**n, 2**n]
  7. 7/8 median law        -- grid ratio 3  <=>  three-point AP with median 7/8 * 2**n
  8. identifiability       -- a census determines (top point, grid step)
  9. renormalisation       -- doubling both parameters doubles the census
 10. divisibility order    -- st(b,j) | st(b',j')  <=>  b <= b' and j | j'
 11. gcd closure, lcm failure, antichain property, grid step as a gcd
 12. divisor spectrum      -- sigma splits; abundance, deficiency, perfection
 13. counting and density  -- A(n) = n(n+1)/2 + 1 and A(n)/2**n -> 0

Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import Dict, Iterator, List, Set, Tuple

# ----------------------------------------------------------------------------
# 1. The family
# ----------------------------------------------------------------------------


def stair(b: int, j: int) -> int:
    """The staircase number with j ones and b trailing zeros."""
    return (2 ** b) * (2 ** j - 1)


def two_adic_valuation(k: int) -> int:
    """Exponent of 2 in k (k > 0)."""
    v = 0
    while k % 2 == 0:
        k //= 2
        v += 1
    return v


def digit_sum_base_two(k: int) -> int:
    """Number of ones in the binary expansion of k."""
    return bin(k).count("1")


def decode_staircase(k: int) -> Tuple[int, int] | None:
    """Return (b, j) with k = stair(b, j), or None if k is not a staircase number."""
    if k <= 0:
        return None
    b = two_adic_valuation(k)
    m = k >> b
    if (m + 1) & m == 0:          # m + 1 is a power of two  <=>  m is 2**j - 1
        return b, (m + 1).bit_length() - 1
    return None


def is_staircase(k: int) -> bool:
    return decode_staircase(k) is not None


# ----------------------------------------------------------------------------
# 2. The census
# ----------------------------------------------------------------------------


def census(n: int, g: int) -> List[int]:
    """Grid-admissible staircase numbers in the octave (2**(n-1), 2**n]."""
    if not 0 <= g < n:
        raise ValueError("require 0 <= g < n")
    rungs = [2 ** n - 2 ** (n - j) for j in range(2, n - g + 1)]
    return sorted(rungs + [2 ** n])


def census_bruteforce(n: int, g: int) -> List[int]:
    """Same set, obtained by exhaustive search over the octave (small n only)."""
    return sorted(
        k
        for k in range(2 ** (n - 1) + 1, 2 ** n + 1)
        if is_staircase(k) and k % 2 ** g == 0
    )


def median_of(values: List[int]) -> float:
    vs = sorted(values)
    m = len(vs)
    return vs[m // 2] if m % 2 else (vs[m // 2 - 1] + vs[m // 2]) / 2


def infer_grid(observed: List[int]) -> Tuple[int, int]:
    """Recover (n, g) from a set of observed staircase values in one octave."""
    top = max(observed)
    n = (top - 1).bit_length() if top & (top - 1) else top.bit_length() - 1
    step = 0
    for v in observed:
        step = gcd(step, v)
    g = two_adic_valuation(step)
    return n, g


# ----------------------------------------------------------------------------
# 3. Divisor spectrum
# ----------------------------------------------------------------------------


def sigma(k: int) -> int:
    """Sum of divisors of k >= 1 (trial division; adequate for the demo range)."""
    total = 0
    for d in range(1, isqrt(k) + 1):
        if k % d == 0:
            total += d
            partner = k // d
            if partner != d:
                total += partner
    return total


def classify(k: int) -> str:
    s = sigma(k)
    return "abundant" if s > 2 * k else ("perfect" if s == 2 * k else "deficient")


def is_prime(m: int) -> bool:
    if m < 2:
        return False
    for p in range(2, isqrt(m) + 1):
        if m % p == 0:
            return False
    return True


# ----------------------------------------------------------------------------
# 4. Counting
# ----------------------------------------------------------------------------


def staircase_count(n: int) -> int:
    """Number of staircase numbers in [1, 2**n], by direct enumeration."""
    seen: Set[int] = set()
    for b in range(0, n + 1):
        for j in range(1, n + 2):
            v = stair(b, j)
            if 1 <= v <= 2 ** n:
                seen.add(v)
    return len(seen)


def staircase_count_formula(n: int) -> int:
    return n * (n + 1) // 2 + 1


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_normal_form() -> None:
    banner("1. Normal form: (b, j) = (2-adic valuation, binary digit sum)")
    for b, j in [(5, 2), (4, 3), (7, 1), (0, 5), (3, 4)]:
        k = stair(b, j)
        assert two_adic_valuation(k) == b and digit_sum_base_two(k) == j
        assert decode_staircase(k) == (b, j)
        print(f"  st({b},{j}) = {k:5d} = {k:>9b}_2   v2 = {b}, ones = {j}")
    for k in (21, 100, 1000):
        print(f"  {k:5d} = {k:>9b}_2   staircase? {is_staircase(k)}")
    assert not is_staircase(21)


def demo_midpoint_and_fraction() -> None:
    banner("2. Midpoint law and fraction law")
    for b, j in [(4, 2), (5, 3), (0, 1), (9, 4)]:
        lo, mid, top = stair(b + 1, j), stair(b, j + 1), 2 ** (b + j + 1)
        assert 2 * mid == lo + top
        assert mid - lo == 2 ** b == top - mid
        assert 2 ** (j + 1) * mid == (2 ** (j + 1) - 1) * top
        frac = f"{2 ** (j + 1) - 1}/{2 ** (j + 1)}"
        print(
            f"  b={b}, j={j}:  ({lo}, {mid}, {top})  AP step {2 ** b};  "
            f"mid = {frac} of top"
        )
    print("  at b=4, j=2 this is exactly (96, 112, 128): 2*112 = 96 + 128, 8*112 = 7*128")


def demo_census() -> None:
    banner("3. Census theorem, scarcity, bracket, identifiability, renormalisation")
    print(f"  {'n':>2} {'g':>2} {'r=n-g':>5} {'|C|':>4}  census")
    for n, g in [(7, 4), (8, 5), (8, 4), (10, 6), (12, 3)]:
        c = census(n, g)
        if n <= 14:
            assert c == census_bruteforce(n, g), "census theorem failed"
        assert len(c) == n - g                       # logarithmic scarcity
        assert max(c) == 2 ** n                      # top point is the maximum
        assert 4 * min(c) >= 3 * 2 ** n              # bracket
        assert infer_grid(c) == (n, g)               # identifiability
        assert [2 * v for v in c] == census(n + 1, g + 1)   # renormalisation
        print(f"  {n:>2} {g:>2} {n - g:>5} {len(c):>4}  {c}")
    print()
    print("  Waste ratio: top point / smallest admissible value")
    for n, g in [(7, 4), (8, 5), (10, 2)]:
        c = census(n, g)
        print(f"    n={n}, g={g}:  {2 ** n} / {min(c)} = {2 ** n / min(c):.6f}   (= 4/3)")
    print()
    print("  Grid step recovered as a gcd of the two coarsest members:")
    for n, g in [(7, 4), (8, 5), (11, 8)]:
        c = census(n, g)
        print(f"    n={n}, g={g}:  gcd({c[0]}, {c[1]}) = {gcd(c[0], c[1])} = 2^{g}")
        assert gcd(c[0], c[1]) == 2 ** g


def demo_median_law() -> None:
    banner("4. The 7/8 median law and its falsification test")
    print("  grid ratio r = 3  ->  three-point AP with median exactly 7/8 of the top")
    for n in (7, 8, 9, 12):
        c = census(n, n - 3)
        med = median_of(c)
        mean = sum(c) / len(c)
        assert len(c) == 3 and 8 * c[1] == 7 * 2 ** n and med == mean
        print(f"    n={n:>2}: census {c}, mean = median = {med:g} = 7/8 * {2 ** n}")
    print()
    print("  refine the grid at n = 8 (r = 4): the law must break")
    c4 = census(8, 4)
    print(f"    census {c4}")
    print(f"    mean   = {sum(c4) / len(c4):g}")
    print(f"    median = {median_of(c4):g}  -> not a census member, and not 7/8 * 256 = 224")
    assert median_of(c4) == 232 and median_of(c4) not in c4
    print()
    print("  parity of the grid ratio decides whether the median can be admissible:")
    for n, g in [(9, 6), (9, 5), (11, 8), (11, 7)]:
        c = census(n, g)
        print(
            f"    n={n}, g={g}, r={n - g} ({'odd ' if (n - g) % 2 else 'even'}): "
            f"median {median_of(c):g} {'IS' if median_of(c) in c else 'is NOT'} a member"
        )


def demo_divisibility() -> None:
    banner("5. Divisibility: product order, gcd closure, lcm failure, antichains")
    pairs = [((5, 2), (4, 3)), ((0, 2), (0, 6)), ((1, 3), (4, 6)), ((2, 3), (2, 4))]
    for (b, j), (bb, jj) in pairs:
        x, y = stair(b, j), stair(bb, jj)
        predicted = (b <= bb) and (jj % j == 0)
        assert (y % x == 0) == predicted
        print(
            f"  st({b},{j})={x:<6} | st({bb},{jj})={y:<6} ? "
            f"{y % x == 0}   (b<=b': {b <= bb}, j|j': {jj % j == 0})"
        )
    print()
    for (b, j), (bb, jj) in pairs:
        x, y = stair(b, j), stair(bb, jj)
        assert gcd(x, y) == stair(min(b, bb), gcd(j, jj))
        print(f"  gcd({x}, {y}) = {gcd(x, y)} = st({min(b, bb)}, {gcd(j, jj)})")
    print()
    print(f"  lcm(3, 7) = 21 = {21:b}_2 -- staircase? {is_staircase(21)}  (family is no lattice)")
    print()
    print("  every census is an antichain (no member divides another):")
    for n, g in [(7, 4), (9, 3), (12, 6)]:
        c = census(n, g)
        ok = all(y % x != 0 for x in c for y in c if x != y)
        assert ok
        print(f"    n={n}, g={g}: {c} -> antichain: {ok}")


def demo_divisor_spectrum() -> None:
    banner("6. Divisor spectrum: sigma splits; abundance, deficiency, perfection")
    print("  sigma(st(b,j)) = (2^(b+1) - 1) * sigma(2^j - 1)")
    for b, j in [(5, 2), (4, 3), (7, 1), (3, 4), (2, 3)]:
        k = stair(b, j)
        rhs = (2 ** (b + 1) - 1) * sigma(2 ** j - 1)
        assert sigma(k) == rhs
        print(
            f"    st({b},{j}) = {k:<6} sigma = {sigma(k):<6} = {rhs:<6} "
            f"[{classify(k)}]"
        )
    print()
    print("  the measured spread crosses the abundant/deficient boundary:")
    for k in (96, 112, 128):
        print(f"    {k}: sigma = {sigma(k)}, 2k = {2 * k}  -> {classify(k)}")
    assert classify(96) == classify(112) == "abundant" and classify(128) == "deficient"
    print()
    print("  perfect members: st(b, b+1) with 2^(b+1) - 1 prime (Euclid = Euler here)")
    for b in range(1, 8):
        k = stair(b, b + 1)
        pred = is_prime(2 ** (b + 1) - 1)
        assert (classify(k) == "perfect") == pred
        print(
            f"    st({b},{b + 1}) = {k:<7} 2^{b + 1}-1 = {2 ** (b + 1) - 1:<4} "
            f"prime: {str(pred):<5} -> {classify(k)}"
        )
    print("    width-7 near miss: st(3,4) = 120, sigma = 360 = 3 * 120 (3-perfect, not perfect)")
    assert sigma(120) == 3 * 120
    print()
    print("  abundancy index increases strictly in b and converges to 2*sigma(m)/m:")
    j = 3
    m = 2 ** j - 1
    for b in range(0, 9):
        k = stair(b, j)
        print(f"    b={b}: sigma/k = {sigma(k) / k:.8f}")
    print(f"    limit  = {2 * sigma(m) / m:.8f}")


def demo_counting() -> None:
    banner("7. Counting staircase numbers and their vanishing density")
    print(f"  {'n':>3} {'A(n)':>6} {'n(n+1)/2+1':>11} {'2^n':>9} {'density':>10}")
    for n in range(0, 21):
        a = staircase_count(n) if n <= 16 else staircase_count_formula(n)
        assert a == staircase_count_formula(n)
        print(f"  {n:>3} {a:>6} {staircase_count_formula(n):>11} {2 ** n:>9} "
              f"{a / 2 ** n:>10.6f}")
    print()
    print("  at the motivating scale: 29 staircase numbers below 128, of which the")
    print("  16-grid inside the top octave admits exactly 3 -> 3/64 = 4.6875%")
    assert staircase_count_formula(7) == 29 and len(census(7, 4)) == 3


def demo_measured_cell() -> None:
    banner("8. The measured cell, end to end")
    observed = [96, 112, 128]
    print(f"  observed values: {observed}")
    for k in observed:
        b, j = decode_staircase(k)  # type: ignore[misc]
        print(f"    {k:>4} = {k:>8b}_2 = st({b},{j}) = 2^{b + j} - 2^{b}")
    n, g = infer_grid(observed)
    print(f"  inferred top point 2^{n} = {2 ** n}, grid step 2^{g} = {2 ** g}, "
          f"grid ratio r = {n - g}")
    c = census(n, g)
    print(f"  admissible population: {c}  (size {len(c)} = n - g)")
    assert sorted(observed) == c
    print("  the three observations EXHAUST the population -- they are not a sample")
    print(f"  mean = median = {median_of(c):g} = 7/8 * {2 ** n}")
    print(f"  guarantee = {max(c)}, worst-case over-provisioning = "
          f"{max(c) / min(c):.4f} = 4/3")
    print(f"  gcd of the spread = {gcd(gcd(96, 112), 128)} = grid step")
    print("  prediction at the next scale (top point 256, grid step 32): "
          f"{census(8, 5)}, median 224")


def main() -> None:
    demo_normal_form()
    demo_midpoint_and_fraction()
    demo_census()
    demo_median_law()
    demo_divisibility()
    demo_divisor_spectrum()
    demo_counting()
    demo_measured_cell()
    print()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
