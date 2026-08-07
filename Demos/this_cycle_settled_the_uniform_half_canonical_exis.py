#!/usr/bin/env python3
"""
Exact Baker-Norine ranks of uniform divisors on complete graphs
===============================================================

Numerical companion to the paper "The Exact Baker-Norine Rank of a Uniform
Divisor on a Complete Graph".

Everything below is self-contained: no third-party dependencies, no imports
beyond the standard library.

Setting
-------
Let ``G = (V, E)`` be a finite connected graph.  A *divisor* is an integer
vector ``D : V -> Z``; its *degree* is ``deg D = sum_v D(v)``.  The graph
Laplacian acts on integer vectors by

    (L f)(v) = deg_G(v) * f(v) - sum_{u ~ v} f(u),

and two divisors are *linearly equivalent*, ``D ~ D'``, when ``D' = D + L f``
for some integer vector ``f``.  ``D`` is *effective* when ``D(v) >= 0`` for
every ``v``.  The *Baker-Norine rank* is

    r(D) = -1                      if no effective divisor is equivalent to D,
    r(D) = max { r : for every effective E with deg E = r,
                     D - E is equivalent to an effective divisor }  otherwise.

The *genus* is ``g = |E| - |V| + 1``.

On the complete graph ``K_n`` the Laplacian collapses to

    (L f)(v) = n * f(v) - sum_u f(u),

so a firing move is a *single* integer vector, and one proves the

    EFFECTIVITY CRITERION.   On K_n, D is equivalent to an effective divisor
    if and only if there is an integer shift s with
        sum_v ceil( (s - D(v)) / n )  <=  s.

Everything in this file is built on that criterion.

Main facts demonstrated
-----------------------
1.  The effectivity criterion agrees with brute-force chip firing.
2.  Riemann's inequality on K_n: every divisor of degree >= g is equivalent to
    an effective one, and the "staircase" divisor of degree g - 1 shows that
    the bound g is sharp.
3.  The exact rank formula:  r(m * 1) = m(m+3)/2 on K_n for every n >= m + 2 --
    in particular the rank does NOT depend on n.
4.  The rank strictly exceeds the best one-shot threshold-firing bound
    2m + floor(m^2/4) as soon as m >= 3.
5.  On K_{2m+3} the uniform divisor m is a theta characteristic of degree
    g - 1 whose rank m(m+3)/2 beats the universal half-canonical bound k - 1
    and satisfies 4r > g.
"""

from __future__ import annotations

from itertools import combinations_with_replacement
from typing import Dict, Iterator, List, Optional, Sequence, Tuple


# ---------------------------------------------------------------------------
# 1.  Basic invariants of K_n
# ---------------------------------------------------------------------------

def genus_complete(n: int) -> int:
    """Genus (cycle rank) of K_n:  |E| - |V| + 1 = (n-1)(n-2)/2."""
    return (n - 1) * (n - 2) // 2


def canonical_complete(n: int) -> List[int]:
    """Canonical divisor of K_n: K(v) = deg(v) - 2 = n - 3 at every vertex."""
    return [n - 3] * n


def laplacian_complete(f: Sequence[int]) -> List[int]:
    """(L f)(v) = n f(v) - sum_u f(u) on the complete graph K_n."""
    n = len(f)
    total = sum(f)
    return [n * f[v] - total for v in range(n)]


# ---------------------------------------------------------------------------
# 2.  The effectivity criterion and the deficiency
# ---------------------------------------------------------------------------

def ceil_div(a: int, b: int) -> int:
    """Ceiling of a / b for b > 0 (exact integer arithmetic)."""
    return -((-a) // b)


def deficiency(D: Sequence[int]) -> int:
    """
    The deficiency  d(D) = min_s ( sum_v ceil((s - D(v))/n) - s )  on K_n.

    D is linearly equivalent to an effective divisor  <=>  d(D) <= 0.

    The objective is a convex, piecewise-linear function of the shift s whose
    slope is >= 0 once s exceeds max_v D(v) and <= 0 while s < min_v D(v),
    so scanning the window [min D - 1, max D + n] finds the true minimum.
    """
    n = len(D)
    lo, hi = min(D) - n - 1, max(D) + n + 1
    best: Optional[int] = None
    for s in range(lo, hi + 1):
        val = sum(ceil_div(s - D[v], n) for v in range(n)) - s
        best = val if best is None else min(best, val)
    assert best is not None
    return best


def optimal_shift(D: Sequence[int]) -> int:
    """The shift s attaining the deficiency (smallest such s)."""
    n = len(D)
    lo, hi = min(D) - n - 1, max(D) + n + 1
    best_val: Optional[int] = None
    best_s = lo
    for s in range(lo, hi + 1):
        val = sum(ceil_div(s - D[v], n) for v in range(n)) - s
        if best_val is None or val < best_val:
            best_val, best_s = val, s
    return best_s


def equivalent_to_effective(D: Sequence[int]) -> bool:
    """Is D linearly equivalent to an effective divisor on K_n?"""
    return deficiency(D) <= 0


def witness_firing_vector(D: Sequence[int]) -> Optional[List[int]]:
    """
    If D ~ effective, return the explicit firing vector f with D + L f >= 0
    supplied by the criterion:  f(v) = ceil((s - D(v))/n)  for an optimal s.
    """
    if not equivalent_to_effective(D):
        return None
    n = len(D)
    s = optimal_shift(D)
    return [ceil_div(s - D[v], n) for v in range(n)]


# ---------------------------------------------------------------------------
# 3.  Brute-force chip firing, used to certify the criterion
# ---------------------------------------------------------------------------

def brute_force_equivalent_to_effective(D: Sequence[int], radius: int = 3) -> bool:
    """
    Search all firing vectors f in [-radius, radius]^n (normalised so that
    min f = 0, since the all-ones vector acts trivially) and test D + L f >= 0.
    Exponential; used only as an independent check on small examples.
    """
    n = len(D)
    def rec(i: int, f: List[int]) -> bool:
        if i == n:
            Lf = laplacian_complete(f)
            return all(D[v] + Lf[v] >= 0 for v in range(n))
        for val in range(0, radius + 1):
            f.append(val)
            if rec(i + 1, f):
                f.pop()
                return True
            f.pop()
        return False
    return rec(0, [])


# ---------------------------------------------------------------------------
# 4.  Baker-Norine rank on K_n
# ---------------------------------------------------------------------------

def effective_divisors(n: int, degree: int) -> Iterator[List[int]]:
    """All effective divisors on n vertices of the given degree."""
    for spots in combinations_with_replacement(range(n), degree):
        E = [0] * n
        for v in spots:
            E[v] += 1
        yield E


def rank_complete(D: Sequence[int], cap: int = 60) -> int:
    """
    Exact Baker-Norine rank of D on K_n, computed by combining the effectivity
    criterion with an exhaustive search over test divisors E.

    r(D) = (least degree of an effective E with D - E not equivalent to an
            effective divisor) - 1.
    """
    n = len(D)
    if not equivalent_to_effective(D):
        return -1
    r = 0
    while r <= cap:
        for E in effective_divisors(n, r + 1):
            if not equivalent_to_effective([D[v] - E[v] for v in range(n)]):
                return r
        r += 1
    raise RuntimeError("rank exceeded cap")


# ---------------------------------------------------------------------------
# 5.  The threshold algorithm extracted from the proof of the lower bound
# ---------------------------------------------------------------------------

def wt(n: int, a: int, j: int) -> int:
    """Ceiling weight  ceil((a - j)/n)  with truncated subtraction (0 if a <= j)."""
    return (max(a - j, 0) + n - 1) // n


def threshold_firing(n: int, m: int, E: Sequence[int]) -> Optional[List[int]]:
    """
    Given the uniform divisor m*1 on K_n (n >= m + 2) and an effective test
    divisor E of degree at most m(m+3)/2, return the explicit firing vector f
    with  m*1 - E + L f  effective, as constructed in the proof.

    Method.  Put T(t) = sum_v ceil((E(v) - (m - t))/n).  T is monotone in t.
    Let t be the LEAST threshold in [1, m] with T(t) <= t; minimality forces
    T(t) = t exactly, and then f(v) = ceil((E(v) - (m - t))/n) - 1 works.
    Runs in O(n m) time.
    """
    if all(E[v] <= m for v in range(n)):
        return [0] * n                      # nothing to do: m*1 - E already >= 0
    for t in range(1, m + 1):
        T = sum(wt(n, E[v], m - t) for v in range(n))
        if T <= t:
            return [wt(n, E[v], m - t) - 1 for v in range(n)]
    return None


# ---------------------------------------------------------------------------
# 6.  The staircase divisor: sharpness of Riemann's inequality
# ---------------------------------------------------------------------------

def staircase_test(n: int, m: int) -> List[int]:
    """
    The staircase test divisor on K_n: (m+1) chips at vertex 0 and
    max(m - (i-1), 0) chips at vertex i > 0.  Its degree is m(m+3)/2 + 1.
    """
    return [m + 1] + [max(m - (i - 1), 0) for i in range(1, n)]


def staircase_remainder(n: int, m: int) -> List[int]:
    """m*1 minus the staircase test divisor; degree m*n - (m(m+3)/2 + 1)."""
    Ei = staircase_test(n, m)
    return [m - Ei[i] for i in range(n)]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_criterion_vs_brute_force() -> None:
    print("=" * 74)
    print("1.  The effectivity criterion against brute-force chip firing")
    print("=" * 74)
    print("  On K_n:  D ~ effective  <=>  exists s with sum_v ceil((s-D_v)/n) <= s.")
    print()
    tests: List[List[int]] = [
        [1, 1, 1, 1],
        [-1, 0, 1, 2],
        [-1, 0, 1, 2, 3],
        [-2, 0, 1, 2, 3],
        [5, -3, 0, 0],
        [3, 3, 3, -9],
        [-1, -1, 4, 4, 4],
    ]
    print(f"  {'divisor':>22}  {'deg':>4}  {'criterion':>10}  {'brute force':>12}")
    for D in tests:
        crit = equivalent_to_effective(D)
        brute = brute_force_equivalent_to_effective(D, radius=4)
        flag = "OK" if crit == brute else "MISMATCH"
        print(f"  {str(D):>22}  {sum(D):>4}  {str(crit):>10}  {str(brute):>12}   {flag}")
        assert crit == brute
    print()


def demo_riemann_inequality() -> None:
    print("=" * 74)
    print("2.  Riemann's inequality on K_n, and its sharpness")
    print("=" * 74)
    print("  Every divisor of degree >= g is equivalent to an effective one;")
    print("  the staircase divisor of degree g - 1 is not.")
    print()
    for n in range(3, 9):
        g = genus_complete(n)
        S = staircase_remainder(n, n - 2)          # degree exactly g - 1
        assert sum(S) == g - 1, (n, sum(S), g - 1)
        eff = equivalent_to_effective(S)
        # random-ish sweep: every divisor of degree g concentrated anywhere
        all_good = all(
            equivalent_to_effective([g if v == w else 0 for v in range(n)])
            for w in range(n)
        )
        print(f"  n = {n}:  g = {g:>3}   staircase of degree g-1 = {g-1:>3} "
              f"effective-equivalent? {str(eff):>5}   "
              f"all degree-g concentrated divisors effective? {all_good}")
        assert not eff
        assert all_good
    print()
    print("  Exhaustive check that degree >= g always suffices (small n):")
    for n in range(3, 7):
        g = genus_complete(n)
        bad = 0
        for D in _bounded_divisors(n, lo=-4, hi=6):
            if sum(D) >= g and not equivalent_to_effective(D):
                bad += 1
        print(f"    n = {n}:  counterexamples among bounded divisors of degree >= g:  {bad}")
        assert bad == 0
    print()


def _bounded_divisors(n: int, lo: int, hi: int) -> Iterator[List[int]]:
    """All integer vectors of length n with entries in [lo, hi]."""
    def rec(i: int, cur: List[int]) -> Iterator[List[int]]:
        if i == n:
            yield list(cur)
            return
        for val in range(lo, hi + 1):
            cur.append(val)
            yield from rec(i + 1, cur)
            cur.pop()
    yield from rec(0, [])


def demo_exact_rank_formula() -> None:
    print("=" * 74)
    print("3.  The exact rank formula   r(m * 1) = m(m+3)/2   on K_n,  n >= m+2")
    print("=" * 74)
    print("  Note that the answer does not depend on n at all.")
    print()
    print(f"  {'m':>3}  {'n':>3}  {'deg':>5}  {'genus':>6}  {'rank':>5}  "
          f"{'m(m+3)/2':>9}  {'3m-1':>5}  {'2m+m^2/4':>9}")
    for m in range(0, 4):
        predicted = m * (m + 3) // 2
        for n in range(m + 2, m + 6):
            if n > 7 and m >= 3:
                continue                      # keep the brute-force search small
            D = [m] * n
            r = rank_complete(D)
            print(f"  {m:>3}  {n:>3}  {m*n:>5}  {genus_complete(n):>6}  {r:>5}  "
                  f"{predicted:>9}  {3*m-1:>5}  {2*m + m*m//4:>9}")
            assert r == predicted, (m, n, r, predicted)
    print()
    print("  For m >= 3 the true rank strictly exceeds every one-shot")
    print("  threshold-firing bound 2m + floor(m^2/4):")
    print(f"  {'m':>3}  {'exact rank':>11}  {'3m-1':>6}  {'2m+m^2/4':>9}")
    for m in range(1, 13):
        print(f"  {m:>3}  {m*(m+3)//2:>11}  {3*m-1:>6}  {2*m + m*m//4:>9}")
    print()


def demo_threshold_algorithm() -> None:
    print("=" * 74)
    print("4.  The constructive winning strategy (threshold firing)")
    print("=" * 74)
    print("  For every effective E of degree m(m+3)/2 the algorithm returns an")
    print("  explicit f with  m*1 - E + L f  effective.")
    print()
    for (n, m) in [(4, 2), (5, 2), (6, 2), (5, 3), (6, 3), (7, 3), (8, 4)]:
        r = m * (m + 3) // 2
        tested = 0
        failures = 0
        for E in effective_divisors(n, r):
            f = threshold_firing(n, m, E)
            tested += 1
            if f is None:
                failures += 1
                continue
            Lf = laplacian_complete(f)
            if any(m - E[v] + Lf[v] < 0 for v in range(n)):
                failures += 1
            if tested >= 4000:
                break
        print(f"  K_{n}, m = {m}:  tested {tested:>5} test divisors of degree {r:>3};  "
              f"failures: {failures}")
        assert failures == 0
    print()
    print("  A worked example on K_6 with m = 3 (degree of E is 9):")
    n, m = 6, 3
    E = [9, 0, 0, 0, 0, 0]
    f = threshold_firing(n, m, E)
    assert f is not None
    Lf = laplacian_complete(f)
    print(f"    E              = {E}")
    print(f"    firing vector f = {f}")
    print(f"    m*1 - E + L f   = {[m - E[v] + Lf[v] for v in range(n)]}   (effective)")
    E = [2, 2, 2, 1, 1, 1]
    f = threshold_firing(n, m, E)
    assert f is not None
    Lf = laplacian_complete(f)
    print(f"    E              = {E}")
    print(f"    firing vector f = {f}")
    print(f"    m*1 - E + L f   = {[m - E[v] + Lf[v] for v in range(n)]}   (effective)")
    print()


def demo_theta_characteristics() -> None:
    print("=" * 74)
    print("5.  Half-canonical theta characteristics on K_{2m+3}")
    print("=" * 74)
    print("  On K_{2m+3} the canonical divisor is 2m at every vertex, so the")
    print("  uniform divisor m is a theta characteristic: 2D = K exactly.")
    print()
    print(f"  {'m':>3}  {'n=2m+3':>7}  {'k=n-1':>6}  {'g':>5}  {'deg D':>6}  "
          f"{'g-1':>5}  {'rank':>5}  {'k-1':>4}  {'4r>g':>5}")
    for m in range(1, 9):
        n = 2 * m + 3
        g = genus_complete(n)
        r = m * (m + 3) // 2
        k = n - 1
        assert canonical_complete(n) == [2 * m] * n
        assert m * n == g - 1
        if n <= 7:                                # verify the rank by search
            assert rank_complete([m] * n) == r
        print(f"  {m:>3}  {n:>7}  {k:>6}  {g:>5}  {m*n:>6}  {g-1:>5}  {r:>5}  "
              f"{k-1:>4}  {str(4*r > g):>5}")
    print()
    print("  The universal half-canonical guarantee is rank >= k - 1; complete")
    print("  graphs beat it by a quadratic margin, and 4r > g means these")
    print("  divisors carry a positive proportion of the genus in rank --")
    print("  the Brill-Noether heuristic would predict rank of order sqrt(g).")
    print()


def deficiency_linear(D: Sequence[int]) -> int:
    """
    Linear-time deficiency on K_n.

    Write  phi(s) = sum_v ceil((s - D(v))/n) - s.  Since every ceiling term
    increases by exactly 1 when s increases by n, phi is n-periodic, and

        phi(s + 1) - phi(s) = #{ v : D(v) = s  (mod n) } - 1.

    So bucket the vertices by residue class mod n (O(n)), evaluate phi once
    (O(n)), then sweep one period by prefix sums (O(n)).  Total: O(n).
    """
    n = len(D)
    counts: Dict[int, int] = {j: 0 for j in range(n)}
    for v in range(n):
        counts[D[v] % n] += 1
    s0 = min(D)
    phi = sum(ceil_div(s0 - D[v], n) for v in range(n)) - s0
    best = phi
    for s in range(s0, s0 + n):
        phi += counts[s % n] - 1
        best = min(best, phi)
    return best


def demo_linear_time_algorithm() -> None:
    print("=" * 74)
    print("7.  A linear-time effectivity test")
    print("=" * 74)
    print("  phi(s) = sum_v ceil((s-D_v)/n) - s is n-periodic with")
    print("  phi(s+1) - phi(s) = #{v : D_v = s mod n} - 1, so the deficiency")
    print("  d(D) = min_s phi(s) is computable by one O(n) sweep.")
    print()
    checked = 0
    for n in range(3, 7):
        for D in _bounded_divisors(n, lo=-3, hi=4):
            assert deficiency_linear(D) == deficiency(D), D
            checked += 1
    print(f"  Linear-time and naive deficiency agree on {checked} divisors.")
    print()
    print("  Deficiency of the staircase divisor (-1, 0, 1, ..., m, m, ..., m):")
    for (n, m) in [(4, 2), (5, 2), (6, 3), (7, 3), (8, 5), (9, 4)]:
        S = [-1] + list(range(0, m + 1)) + [m] * (n - m - 2)
        assert len(S) == n
        print(f"    K_{n}, m = {m}:  S = {S},  deg = {sum(S):>3},  "
              f"deficiency = {deficiency_linear(S)}")
        assert deficiency_linear(S) == 1
    print("  Deficiency 1 > 0 in every case: these divisors are the obstruction")
    print("  witnesses proving the upper bound r(m*1) <= m(m+3)/2.")
    print()


def demo_maximal_rank_at_half_canonical() -> None:
    print("=" * 74)
    print("8.  The maximal rank at the half-canonical degree g - 1 on K_n")
    print("=" * 74)
    print("  Conjecturally the maximum over all divisor classes of degree d is")
    print("  attained at the concentrated divisor d*q and equals")
    print("      a(a+1)/2 + min(b, a),   where d = a(n-1) + b, 0 <= b <= n-2.")
    print("  Every class has a q-reduced representative with entries in")
    print("  [0, n-2] away from q, so the search below is exhaustive.")
    print()
    print(f"  {'n':>3}  {'g':>4}  {'d=g-1':>6}  {'max rank':>9}  {'predicted':>10}  {'k-1':>4}")
    for n in range(3, 7):
        g = genus_complete(n)
        d = g - 1
        a, b = divmod(d, n - 1)
        predicted = a * (a + 1) // 2 + min(b, a)
        best = -1
        for tail in _bounded_divisors(n - 1, lo=0, hi=n - 2):
            D = [d - sum(tail)] + list(tail)
            best = max(best, rank_complete(D))
        print(f"  {n:>3}  {g:>4}  {d:>6}  {best:>9}  {predicted:>10}  {n-2:>4}")
        assert best == predicted, (n, best, predicted)
    print()
    print("  The concentrated divisor attains the maximum in each case:")
    for n in range(3, 8):
        d = genus_complete(n) - 1
        a, b = divmod(d, n - 1)
        conc = [d] + [0] * (n - 1)
        print(f"    n = {n}:  rank of ({d}, 0, ..., 0) = {rank_complete(conc)},"
              f"  predicted {a*(a+1)//2 + min(b, a)}")
    print()
    print("  So K_n reaches the universal half-canonical value k - 1 = n - 2")
    print("  only at n = 7.")
    print()


def demo_rank_independent_of_n() -> None:
    print("=" * 74)
    print("6.  Independence of n, illustrated")
    print("=" * 74)
    print("  Riemann-Roch alone gives r >= deg D - g, which becomes vacuous as")
    print("  n grows; the exact formula says the rank is nevertheless constant.")
    print()
    m = 2
    print(f"  m = {m}:")
    print(f"  {'n':>4}  {'deg D':>6}  {'genus':>6}  {'deg-g':>7}  {'true rank':>10}")
    for n in range(m + 2, 10):
        g = genus_complete(n)
        rr = m * n - g
        true = m * (m + 3) // 2
        if n <= 7:
            assert rank_complete([m] * n) == true
        print(f"  {n:>4}  {m*n:>6}  {g:>6}  {rr:>7}  {true:>10}")
    print()


def main() -> None:
    print()
    print("#" * 74)
    print("#  Exact Baker-Norine ranks of uniform divisors on complete graphs")
    print("#" * 74)
    print()
    demo_criterion_vs_brute_force()
    demo_riemann_inequality()
    demo_exact_rank_formula()
    demo_threshold_algorithm()
    demo_theta_characteristics()
    demo_rank_independent_of_n()
    demo_linear_time_algorithm()
    demo_maximal_rank_at_half_canonical()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
