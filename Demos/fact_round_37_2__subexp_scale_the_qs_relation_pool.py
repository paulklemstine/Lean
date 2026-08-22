#!/usr/bin/env python3
"""
Numerical demonstrations for
  "Random-Equivalence of the Quadratic-Sieve Relation Pool at Every Scale".

Self-contained: standard library only.  Every routine is inlined and type
hinted.  Running this file reproduces, at small scale, each of the paper's
main claims:

  1. Exact local-hit census:      sum_a r_p(a) = p  and  2|A_p| = p - 1.
  2. Kernel/orbit-stabiliser:     |ker(u -> u^2)| * |A_p| = p - 1.
  3. Universality:                sum_b #f^{-1}(b) = |domain| for ANY map f;
                                  pointwise uniform  <=>  bijection.
  4. Congruence of squares:       |A(N,B)| + 1 relations force a square
                                  subproduct (F_2 linear dependency).
  5. Sparsity:                    Psi(x,B) <= (log2 x + 1)^pi(B).
  6. Dickman:                     rho(u) = 1 - ln u on [1,2];
                                  L(u) > 1 > rho(u) on (1,2];
                                  L(2) > 9 rho(2);  L(u) < 1 for u >= 3.
  7. Finite-size correction:      c(v) = lnln v / ln v is decreasing and
                                  lies in [0.1, 0.25] for e^12 <= v <= e^20.
  8. Size-matched smoothness experiment: the x^2 - N pool versus a random
     control of the same bit size, both compared against rho(u).

Usage:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from decimal import Decimal, getcontext
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Set, Tuple

# --------------------------------------------------------------------------- #
# Basic number theory helpers
# --------------------------------------------------------------------------- #


def primes_up_to(bound: int) -> List[int]:
    """All primes p <= bound, by a simple sieve of Eratosthenes."""
    if bound < 2:
        return []
    flags: List[bool] = [True] * (bound + 1)
    flags[0] = flags[1] = False
    for p in range(2, int(bound**0.5) + 1):
        if flags[p]:
            for m in range(p * p, bound + 1, p):
                flags[m] = False
    return [p for p in range(bound + 1) if flags[p]]


def quadratic_residues(p: int) -> Set[int]:
    """The set A_p of NONZERO quadratic residues modulo the odd prime p."""
    return {(x * x) % p for x in range(1, p)}


def root_count(p: int, a: int) -> int:
    """r_p(a) = #{x mod p : x^2 = a mod p}."""
    return sum(1 for x in range(p) if (x * x) % p == a % p)


def factorize_smooth(n: int, factor_base: Sequence[int]) -> Optional[Dict[int, int]]:
    """Factor n over the factor base; return None if n is not smooth."""
    if n <= 0:
        return None
    exponents: Dict[int, int] = {}
    m: int = n
    for p in factor_base:
        while m % p == 0:
            m //= p
            exponents[p] = exponents.get(p, 0) + 1
    return exponents if m == 1 else None


# --------------------------------------------------------------------------- #
# 1 & 2.  Exact local-hit census and the orbit-stabiliser cancellation
# --------------------------------------------------------------------------- #


def local_hit_census(p: int) -> Tuple[int, int, int, int]:
    """
    Return (total_hits, n_admissible, kernel_order, period) for the odd prime p.

    total_hits   = sum over all residues a of r_p(a)     -- should equal p
    n_admissible = |A_p|                                 -- should equal (p-1)/2
    kernel_order = |{u : u^2 = 1 mod p}|                 -- should equal 2
    period       = |(Z/p)^*| = p - 1
    """
    total: int = sum(root_count(p, a) for a in range(p))
    admissible: Set[int] = quadratic_residues(p)
    kernel: List[int] = [u for u in range(1, p) if (u * u) % p == 1]
    return total, len(admissible), len(kernel), p - 1


def demo_local_hits() -> None:
    print("=" * 74)
    print("1-2.  EXACT RANDOM-EQUIVALENCE  and  ORBIT-STABILISER CANCELLATION")
    print("=" * 74)
    print("      sum_a r_p(a) = p      2|A_p| = p-1      |ker| * |A_p| = p-1")
    print()
    header = f"{'p':>6} {'sum r_p(a)':>11} {'|A_p|':>7} {'|ker|':>6} " \
             f"{'|ker|*|A_p|':>12} {'p-1':>6} {'mean hits':>10}"
    print(header)
    print("-" * len(header))
    for p in [3, 5, 7, 11, 13, 17, 19, 23, 31, 101, 1009]:
        total, n_adm, ker, period = local_hit_census(p)
        assert total == p, "Theorem 3.6 failed"
        assert 2 * n_adm == p - 1, "Corollary 3.7 failed"
        assert ker * n_adm == period, "Theorem 4.6 failed"
        print(f"{p:>6} {total:>11} {n_adm:>7} {ker:>6} "
              f"{ker * n_adm:>12} {period:>6} {total / p:>10.4f}")
    print()
    print("  Mean local hit count is EXACTLY 1.000000 at every prime:")
    print("  the value for a sequence of random integers.  No error term.")
    print()
    # The 2/0 dichotomy made visible.
    p = 13
    print(f"  The 2/0 dichotomy at p = {p}:")
    row = "   a      : " + " ".join(f"{a:>2}" for a in range(p))
    print(row)
    print("   r_p(a)  : " + " ".join(f"{root_count(p, a):>2}" for a in range(p)))
    print("  Half the residues are never hit; the other half are hit twice;")
    print("  a = 0 is hit once.  The average is exactly 1.")
    print()


# --------------------------------------------------------------------------- #
# 3.  Universality of the average hit count
# --------------------------------------------------------------------------- #


def hit_counts(f: Callable[[int], int], domain: Iterable[int],
               targets: Iterable[int]) -> Dict[int, int]:
    """h_f(b) = #{a in domain : f(a) = b}, for every b in targets."""
    counts: Dict[int, int] = {b: 0 for b in targets}
    for a in domain:
        b = f(a)
        if b in counts:
            counts[b] += 1
    return counts


def demo_universality() -> None:
    print("=" * 74)
    print("3.  UNIVERSALITY:  sum_b h_f(b) = |domain|  for ANY sieve map f")
    print("=" * 74)
    p: int = 17
    residues: List[int] = list(range(p))
    maps: List[Tuple[str, Callable[[int], int]]] = [
        ("x -> x^2       ", lambda x: (x * x) % p),
        ("x -> x^3       ", lambda x: pow(x, 3, p)),
        ("x -> x^4 + 5x  ", lambda x: (pow(x, 4, p) + 5 * x) % p),
        ("x -> 3x + 1    ", lambda x: (3 * x + 1) % p),
        ("x -> x^2 + x   ", lambda x: (x * x + x) % p),
        ("x -> 0         ", lambda x: 0),
    ]
    header = f"  {'map':<16} {'sum h_f(b)':>11} {'|domain|':>9} " \
             f"{'mean':>7} {'pointwise 1?':>13} {'bijective?':>11}"
    print(header)
    print("  " + "-" * (len(header) - 2))
    for name, f in maps:
        counts = hit_counts(f, residues, residues)
        total = sum(counts.values())
        assert total == p, "Theorem 5.1 failed"
        pointwise = all(v == 1 for v in counts.values())
        bijective = len({f(x) for x in residues}) == p
        assert pointwise == bijective, "Theorem 5.2 failed"
        print(f"  {name:<16} {total:>11} {p:>9} {total / p:>7.3f} "
              f"{str(pointwise):>13} {str(bijective):>11}")
    print()
    print("  Every map, whatever its degree, has mean hit count exactly")
    print("  |domain|/|targets| = 1.  Pointwise uniformity holds precisely")
    print("  for the bijections.  Squaring is not one: hence the 2/0 pattern.")
    print()


# --------------------------------------------------------------------------- #
# 4.  Congruence of squares from HALF the factor base
# --------------------------------------------------------------------------- #


def admissible_primes(n: int, bound: int) -> List[int]:
    """Primes p <= bound for which n is a quadratic residue mod p."""
    out: List[int] = []
    for p in primes_up_to(bound):
        if p == 2:
            out.append(2)
            continue
        if n % p == 0 or pow(n % p, (p - 1) // 2, p) == 1:
            out.append(p)
    return out


def f2_dependency(vectors: List[List[int]]) -> Optional[List[int]]:
    """
    Given m vectors over F_2 (as 0/1 lists of equal length d), return the index
    set of a nonempty linearly dependent subset summing to zero, or None.
    Gaussian elimination over F_2; O(m * d * min(m,d)).
    """
    m: int = len(vectors)
    if m == 0:
        return None
    d: int = len(vectors[0])
    # augmented rows: (vector, provenance bitmask over the m inputs)
    rows: List[Tuple[List[int], int]] = [(list(v), 1 << i)
                                         for i, v in enumerate(vectors)]
    pivots: Dict[int, Tuple[List[int], int]] = {}
    for vec, prov in rows:
        v = list(vec)
        pr = prov
        for col in range(d):
            if v[col] == 0:
                continue
            if col in pivots:
                pv, pp = pivots[col]
                v = [(a ^ b) for a, b in zip(v, pv)]
                pr ^= pp
            else:
                pivots[col] = (v, pr)
                pr = -1
                break
        if pr != -1 and all(c == 0 for c in v):
            return [i for i in range(m) if (pr >> i) & 1]
    return None


def demo_congruence_of_squares() -> None:
    print("=" * 74)
    print("4.  CONGRUENCE OF SQUARES FROM |A(N,B)| + 1 RELATIONS")
    print("=" * 74)
    n: int = 8051          # = 83 * 97
    bound: int = 60
    full_base: List[int] = primes_up_to(bound)
    adm: List[int] = admissible_primes(n, bound)
    print(f"  N = {n},  B = {bound}")
    print(f"  full factor base    pi(B) = {len(full_base):>3}: {full_base}")
    print(f"  admissible primes  |A(N,B)| = {len(adm):>3}: {adm}")
    print(f"  ratio |A|/pi(B) = {len(adm) / len(full_base):.3f}   (theory: ~0.5)")
    print()

    # Collect smooth sieve values.
    start: int = math.isqrt(n) + 1
    relations: List[Tuple[int, int, Dict[int, int]]] = []
    for x in range(start, start + 40000):
        v = x * x - n
        fac = factorize_smooth(v, adm)
        if fac is not None:
            relations.append((x, v, fac))
        if len(relations) > len(adm):
            break
    print(f"  collected {len(relations)} smooth relations "
          f"(threshold |A(N,B)| + 1 = {len(adm) + 1})")
    for x, v, fac in relations[:6]:
        pretty = " * ".join(f"{p}^{e}" for p, e in sorted(fac.items()))
        print(f"    x = {x:>5}   x^2 - N = {v:>9} = {pretty}")
    if len(relations) > 6:
        print(f"    ... and {len(relations) - 6} more")
    print()

    # Every prime occurring is admissible (Theorem 6.4).
    for _, _, fac in relations:
        assert all(p in adm for p in fac), "Theorem 6.4 failed"
    print("  Support check passed: every prime in every relation is admissible.")

    # F_2 dependency (Theorems 6.3 / 6.5).
    vectors = [[fac.get(p, 0) % 2 for p in adm] for _, _, fac in relations]
    dep = f2_dependency(vectors)
    if dep is None:
        print("  (no dependency found in this sample)")
        print()
        return
    xs = [relations[i][0] for i in dep]
    vs = [relations[i][1] for i in dep]
    prod_v = 1
    for v in vs:
        prod_v *= v
    root = math.isqrt(prod_v)
    assert root * root == prod_v, "Theorem 6.3 failed: product is not a square"
    prod_x = 1
    for x in xs:
        prod_x = (prod_x * x) % n
    print(f"  dependency found on {len(dep)} relations, x = {xs}")
    print(f"  product of values is a perfect square: Y = {root}")
    g1 = math.gcd(prod_x - root % n, n)
    g2 = math.gcd(prod_x + root % n, n)
    print(f"  X = {prod_x} (mod N),  Y = {root % n} (mod N)")
    print(f"  gcd(X - Y, N) = {g1},   gcd(X + Y, N) = {g2}")
    if 1 < g1 < n:
        print(f"  ==> NONTRIVIAL FACTOR: {n} = {g1} * {n // g1}")
    elif 1 < g2 < n:
        print(f"  ==> NONTRIVIAL FACTOR: {n} = {g2} * {n // g2}")
    else:
        print("  (this dependency gave the trivial congruence; more relations "
              "would give another)")
    print()


# --------------------------------------------------------------------------- #
# 5.  Unconditional sparsity of the smooth pool
# --------------------------------------------------------------------------- #


def smooth_pool_count(x: int, bound: int) -> int:
    """Psi(x, B): the number of B-smooth integers in [1, x]."""
    base = primes_up_to(bound)
    return sum(1 for n in range(1, x + 1) if factorize_smooth(n, base) is not None)


def demo_sparsity() -> None:
    print("=" * 74)
    print("5.  SPARSITY:  Psi(x,B) <= (floor(log2 x) + 1)^pi(B)")
    print("=" * 74)
    header = f"  {'x':>7} {'B':>4} {'pi(B)':>6} {'Psi(x,B)':>9} {'bound':>16}"
    print(header)
    print("  " + "-" * (len(header) - 2))
    for x, bound in [(100, 5), (1000, 7), (10000, 11), (10000, 3), (10000, 1)]:
        pi_b = len(primes_up_to(bound))
        psi = smooth_pool_count(x, bound)
        cap = (x.bit_length() - 1 + 1) ** pi_b
        assert psi <= cap, "Theorem 7.2 failed"
        print(f"  {x:>7} {bound:>4} {pi_b:>6} {psi:>9} {cap:>16}")
    print()
    print("  For a FIXED factor base the pool grows only polylogarithmically")
    print("  in x.  This is why B must grow with N, and why the sieve is")
    print("  subexponential rather than polynomial.  Unconditional -- no")
    print("  heuristics are used.")
    print()


# --------------------------------------------------------------------------- #
# 6.  The Dickman function and its leading term
# --------------------------------------------------------------------------- #


getcontext().prec = 80
_RHO_SERIES_CACHE: Dict[int, List[Decimal]] = {}
_RHO_TERMS: int = 70


def _rho_series(k: int) -> List[Decimal]:
    """
    Taylor coefficients of rho on the unit interval [k, k+1], expanded about the
    midpoint m = k + 1/2 in the local variable s = u - m, |s| <= 1/2.

    Method (numerically stable to near machine relative precision, unlike naive
    quadrature): the delay differential equation rho'(u) = -rho(u-1)/u reads, in
    the local variable, P_k'(s) = -P_{k-1}(s) / (m + s), because the shift by one
    unit maps midpoint to midpoint.  Multiply the previous interval's series by
    the geometric expansion 1/(m+s) = sum_j (-1)^j s^j / m^{j+1}, integrate term
    by term, and fix the constant of integration from continuity at u = k.
    """
    if k in _RHO_SERIES_CACHE:
        return _RHO_SERIES_CACHE[k]
    n: int = _RHO_TERMS
    if k == 0:
        series: List[Decimal] = [Decimal(0)] * n
        series[0] = Decimal(1)               # rho == 1 on [0,1]
        _RHO_SERIES_CACHE[0] = series
        return series
    prev: List[Decimal] = _rho_series(k - 1)
    m: Decimal = Decimal(k) + Decimal("0.5")
    # geometric series for 1/(m+s)
    g: List[Decimal] = [Decimal((-1) ** j) / m ** (j + 1) for j in range(n)]
    # truncated product q = prev * g
    q: List[Decimal] = [Decimal(0)] * n
    for i in range(n):
        pi_ = prev[i]
        if pi_ == 0:
            continue
        for j in range(n - i):
            q[i + j] += pi_ * g[j]
    # antiderivative I(s) = sum q_j s^{j+1}/(j+1), with I(0) = 0
    integ: List[Decimal] = [Decimal(0)] * n
    for j in range(n - 1):
        integ[j + 1] = q[j] / Decimal(j + 1)
    # P_k(s) = C - I(s); continuity at u = k, i.e. s = -1/2, against P_{k-1}(1/2)
    half = Decimal("0.5")
    rho_left: Decimal = sum((prev[j] * half ** j for j in range(n)), Decimal(0))
    i_minus_half: Decimal = sum((integ[j] * (-half) ** j for j in range(n)),
                                Decimal(0))
    const: Decimal = rho_left + i_minus_half
    series = [-integ[j] for j in range(n)]
    series[0] += const
    _RHO_SERIES_CACHE[k] = series
    return series


def dickman_rho_exact(u: float) -> Decimal:
    """High-precision rho(u), as a Decimal."""
    if u < 0.0:
        return Decimal(0)
    if u <= 1.0:
        return Decimal(1)
    k: int = int(math.floor(u))
    s: Decimal = Decimal(repr(u)) - (Decimal(k) + Decimal("0.5"))
    total: Decimal = Decimal(0)
    power: Decimal = Decimal(1)
    for c in _rho_series(k):
        total += c * power
        power *= s
    return total


def dickman_rho(u: float) -> float:
    """
    The Dickman function rho(u): rho = 1 on [0,1], and u rho'(u) = -rho(u-1).
    Evaluated from the stable interval-wise Taylor expansion above.
    """
    if u < 0.0:
        return 0.0
    if u <= 1.0:
        return 1.0
    if u <= 2.0:
        return 1.0 - math.log(u)          # exact closed form
    return float(dickman_rho_exact(u))


def dickman_lead(u: float) -> float:
    """L(u) = exp(-u (ln u + lnln u - 1))."""
    lu = math.log(u)
    return math.exp(-u * (lu + math.log(lu) - 1.0))


def demo_dickman() -> None:
    print("=" * 74)
    print("6.  THE DICKMAN LEADING TERM IS NOT A PROBABILITY AT SMALL u")
    print("=" * 74)
    header = f"  {'u':>6} {'rho(u)':>12} {'L(u)':>14} {'L/rho':>12} " \
             f"{'L < 1?':>8} {'rho < 1?':>9}"
    print(header)
    print("  " + "-" * (len(header) - 2))
    for u in [1.2, 1.5, 2.0, 2.5, 3.0, 4.0, 6.0, 10.0, 14.75, 20.0, 30.0, 40.0]:
        r = dickman_rho(u)
        ell = dickman_lead(u)
        print(f"  {u:>6.2f} {r:>12.6e} {ell:>14.6e} {ell / r:>12.4f} "
              f"{str(ell < 1):>8} {str(r < 1):>9}")
    print()
    # Theorem: L(u) > 1 > rho(u) on (1,2]
    for u in [1.01, 1.2, 1.5, 1.8, 2.0]:
        assert dickman_lead(u) > 1.0 > dickman_rho(u), "Theorem 8.3 failed"
    print("  Theorem 8.3 verified on (1,2]:  L(u) > 1 > rho(u).")
    # Theorem: L(2) > 9 rho(2)
    r2, l2 = dickman_rho(2.0), dickman_lead(2.0)
    assert l2 > 9 * r2, "Theorem 8.4 failed"
    print(f"  Theorem 8.4 verified:  L(2) = {l2:.6f} > 9*rho(2) = {9 * r2:.6f}")
    print(f"                         (rho(2) = 1 - ln 2 = {r2:.6f}, "
          f"ratio = {l2 / r2:.4f})")
    # Theorem: L(u) < 1 for u >= 3
    for u in [3.0, 3.5, 5.0, 12.0, 50.0]:
        assert dickman_lead(u) < 1.0, "Theorem 8.5 failed"
    print("  Theorem 8.5 verified:  L(u) < 1 for u >= 3.")
    # closed form check on [1,2]
    for u in [1.1, 1.4, 1.7, 2.0]:
        assert abs(dickman_rho(u) - (1 - math.log(u))) < 1e-12
    print("  Closed form rho(u) = 1 - ln u verified on [1,2].")
    # anchored self-check against independently known values of rho
    anchors: List[Tuple[float, float]] = [
        (3.0, 4.8608e-02), (4.0, 4.9109e-03), (5.0, 3.5472e-04),
        (6.0, 1.9650e-05), (8.0, 3.2321e-08), (10.0, 2.7702e-11),
    ]
    for u, want in anchors:
        got = dickman_rho(u)
        assert abs(got - want) / want < 5e-5, f"rho({u}) anchor check failed"
    print("  Anchor check passed at u = 3,4,5,6,8,10 against known values.")
    print()
    print("  L is not even a probability below u = 3.  Worse, the overshoot")
    print("  factor L/rho GROWS without bound: 12.5 at u = 2, 19.0 at u = 10,")
    print("  31.0 at u = 14.75, 601.8 at u = 40.  What does improve is the")
    print("  EXPONENT: -ln L approximates -ln rho to within 8% only from")
    print("  u ~ 14.75 onwards (at u = 2 the exponent is off by 214%).")
    print("  So L is an asymptotic statement about ln rho, never a usable")
    print("  estimate of rho itself at any reachable u.")
    print()
    print(f"    relative error of the exponent, |ln(L/rho)| / |ln rho|:")
    for u in [2.0, 3.0, 6.0, 10.0, 12.0, 14.75, 20.0, 40.0]:
        r, ell = dickman_rho(u), dickman_lead(u)
        rel = abs(math.log(ell / r)) / abs(math.log(r))
        print(f"      u = {u:>6.2f}   {100 * rel:>7.2f}%")
    print()


# --------------------------------------------------------------------------- #
# 7.  The finite-size correction
# --------------------------------------------------------------------------- #


def finite_correction(v: float) -> float:
    """c(v) = lnln v / ln v."""
    lv = math.log(v)
    return math.log(lv) / lv


def demo_finite_correction() -> None:
    print("=" * 74)
    print("7.  FINITE-SIZE CORRECTION  c(v) = lnln v / ln v")
    print("=" * 74)
    header = f"  {'ln v (nats)':>12} {'bits of v':>10} {'c(v)':>10} " \
             f"{'in [0.1,0.25]?':>15}"
    print(header)
    print("  " + "-" * (len(header) - 2))
    prev: float = 1e9
    for lnv in [12, 14, 16, 18, 20, 30, 50, 100, 1000, 10**6]:
        v = math.exp(min(lnv, 700))
        c = math.log(lnv) / lnv
        in_window = (12 <= lnv <= 20)
        ok = (0.1 <= c <= 0.25) if in_window else True
        assert ok, "Theorem 8.8 failed"
        assert c < prev, "Theorem 8.6 (monotone decay) failed"
        prev = c
        print(f"  {lnv:>12} {lnv / math.log(2):>10.1f} {c:>10.4f} "
              f"{('yes' if in_window and 0.1 <= c <= 0.25 else '-'):>15}")
    print()
    print("  Theorem 8.6 verified: c is decreasing.")
    print("  Theorem 8.7 verified: c -> 0 (see the ln v = 10^6 row).")
    print("  Theorem 8.8 verified: 0.1 <= c(v) <= 0.25 on e^12 <= v <= e^20,")
    print("  which brackets the measured 8.7-12.3% shortfall against rho(u).")
    print()
    print("  Decay is logarithmic: going from ln v = 12 to ln v = 24 -- a")
    print("  DOUBLING of bit length -- improves c only from "
          f"{math.log(12)/12:.4f} to {math.log(24)/24:.4f}.")
    print()


# --------------------------------------------------------------------------- #
# 8.  Size-matched smoothness experiment
# --------------------------------------------------------------------------- #


def is_smooth(n: int, factor_base: Sequence[int]) -> bool:
    """Trial-division smoothness test over the given factor base."""
    m: int = n
    if m <= 0:
        return False
    bound: int = factor_base[-1] if factor_base else 1
    for p in factor_base:
        if p * p > m:
            break                     # the cofactor m is now 1 or prime
        while m % p == 0:
            m //= p
        if m == 1:
            return True
    return m == 1 or m <= bound


def is_probable_prime(n: int) -> bool:
    """Deterministic Miller-Rabin for n < 3.3 * 10^24 (fixed witness set)."""
    if n < 2:
        return False
    small = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    for p in small:
        if n % p == 0:
            return n == p
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in small:
        y = pow(a, d, n)
        if y == 1 or y == n - 1:
            continue
        for _ in range(r - 1):
            y = y * y % n
            if y == n - 1:
                break
        else:
            return False
    return True


def next_prime(n: int) -> int:
    """The least prime >= n."""
    while not is_probable_prime(n):
        n += 1
    return n


def matched_pair_experiment(moduli: Sequence[int], bound: int, samples: int,
                            rng: random.Random
                            ) -> Tuple[Dict[float, List[int]], List[float]]:
    """
    The size-matched design, in miniature.

    For each modulus N and each x above sqrt(N) we form the sieve value
    v = x^2 - N, and we draw a control integer r uniformly from the SAME
    bit-length range.  Both are tested for B-smoothness and binned by their own
    PER-VALUE smoothness parameter u = ln(value)/ln B -- never by the scale of
    N, which was the fatal flaw of the earlier, inconclusive study.

    Returns (bins, per_modulus_ratios) where
      bins: bin_centre -> [sieve_smooth, sieve_total, ctrl_smooth, ctrl_total].
    """
    base: List[int] = primes_up_to(bound)
    log_b: float = math.log(bound)
    width: float = 0.25
    bins: Dict[float, List[int]] = {}
    ratios: List[float] = []

    def bucket(u: float) -> float:
        return round(width * math.floor(u / width) + width / 2, 4)

    for n in moduli:
        start: int = math.isqrt(n) + 1
        s_hits = c_hits = 0
        for i in range(samples):
            x = start + i
            v = x * x - n
            rec = bins.setdefault(bucket(math.log(v) / log_b), [0, 0, 0, 0])
            rec[1] += 1
            if is_smooth(v, base):
                rec[0] += 1
                s_hits += 1
            bits = v.bit_length()
            r = rng.randrange(1 << (bits - 1), 1 << bits)
            rec2 = bins.setdefault(bucket(math.log(r) / log_b), [0, 0, 0, 0])
            rec2[3] += 1
            if is_smooth(r, base):
                rec2[2] += 1
                c_hits += 1
        ratios.append(s_hits / c_hits if c_hits else float("nan"))
    return bins, ratios


def demo_size_matched_experiment(seed: int = 20260821) -> None:
    print("=" * 74)
    print("8.  SIZE-MATCHED SMOOTHNESS: x^2 - N POOL vs RANDOM CONTROL")
    print("=" * 74)
    print("  Binned by the PER-VALUE parameter u = ln v / ln B, against a")
    print("  control pool of random integers of the same bit length, and")
    print("  averaged over many moduli N -- the average over N is precisely")
    print("  what the exact identity sum_a r_p(a) = p controls.")
    print()
    cases: List[Tuple[str, int, int, int, int]] = [
        ("N ~ 2^32", 32, 1500, 80, 700),
        ("N ~ 2^36", 36, 4000, 80, 700),
        ("N ~ 2^40", 40, 10000, 80, 700),
    ]
    for label, bits, bound, n_moduli, samples in cases:
        mod_rng = random.Random(seed + bits)
        half = bits // 2
        moduli: List[int] = []
        for _ in range(n_moduli):
            a = next_prime(mod_rng.randrange(1 << (half - 1), 1 << half))
            b = next_prime(mod_rng.randrange(1 << (half - 1), 1 << half))
            moduli.append(a * b)
        rng = random.Random(seed)
        bins, ratios = matched_pair_experiment(moduli, bound, samples, rng)
        print(f"  {label}:  B = {bound},  pi(B) = {len(primes_up_to(bound))},"
              f"  {n_moduli} semiprime moduli x {samples} values")
        header = (f"    {'u bin':>7} {'sieve n':>8} {'sieve p':>8} "
                  f"{'ctrl n':>8} {'ctrl p':>8} {'ratio':>7} "
                  f"{'rho(u)':>8} {'emp/rho':>8}")
        print(header)
        print("    " + "-" * (len(header) - 4))
        tot = [0, 0, 0, 0]
        for b in sorted(bins):
            s_hit, s_n, c_hit, c_n = bins[b]
            if s_n < 2000 or c_n < 2000:
                continue
            s_p, c_p = s_hit / s_n, c_hit / c_n
            rho = dickman_rho(b)
            print(f"    {b:>7.3f} {s_n:>8} {s_p:>8.4f} {c_n:>8} {c_p:>8.4f} "
                  f"{s_p / c_p:>7.3f} {rho:>8.4f} {s_p / rho:>8.3f}")
            for j in range(4):
                tot[j] += bins[b][j]
        if tot[1] and tot[3] and tot[2]:
            agg = (tot[0] / tot[1]) / (tot[2] / tot[3])
            ordered = sorted(r for r in ratios if r == r)
            lo = ordered[len(ordered) // 10]
            hi = ordered[-1 - len(ordered) // 10]
            med = ordered[len(ordered) // 2]
            print(f"    pooled sieve/control ratio: {agg:.3f}    "
                  f"per-modulus ratio: median {med:.3f}, "
                  f"10-90% band [{lo:.2f}, {hi:.2f}]")
        print()
    print("  Two things are visible.  (i) Averaged over moduli, the sieve pool")
    print("  matches the random control to a few percent, bin by bin.  (ii) An")
    print("  INDIVIDUAL modulus can be well off: the per-modulus ratio ranges")
    print("  over roughly [0.7, 1.4].  That scatter is the small-prime lottery")
    print("  -- whether 3, 5, 7, 11 happen to be admissible for this N -- and")
    print("  it is exactly what the identity sum_a r_p(a) = p says must average")
    print("  to nothing.  The full study (1.2M tests, N up to 2^44) pins the")
    print("  average to 0.993-1.020 at every scale, and finds both pools short")
    print("  of rho(u) by an identical 9-12%: the finite-size correction of")
    print("  Section 7, not a property of x^2 - N.")
    print()


# --------------------------------------------------------------------------- #


def main() -> None:
    print()
    print("#" * 74)
    print("#  RANDOM-EQUIVALENCE OF THE QUADRATIC-SIEVE RELATION POOL")
    print("#  Numerical demonstrations")
    print("#" * 74)
    print()
    demo_local_hits()
    demo_universality()
    demo_congruence_of_squares()
    demo_sparsity()
    demo_dickman()
    demo_finite_correction()
    demo_size_matched_experiment()
    print("=" * 74)
    print("ALL ASSERTIONS PASSED.")
    print("=" * 74)
    print()


if __name__ == "__main__":
    main()
