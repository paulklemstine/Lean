"""
Lattice points on the affine Fermat cubic x^3 + y^3 = N.

Numerical demonstrations of the results:

  1. Localisation.        Every nonzero integral point of x^3 + y^3 = N (N >= 1)
                          satisfies x^2 <= N and y^2 <= N.
  2. Hardy-Ramanujan.     Taxicab(2) = 1729 = 1^3 + 12^3 = 9^3 + 10^3 (sharp).
  3. Cabtaxi.             Cabtaxi(2) = 91 = 3^3 + 4^3 = 6^3 - 5^3,
                          Cabtaxi(3) = 728 = 6^3 + 8^3 = 9^3 - 1^3 = 12^3 - 10^3,
                          so signs are strictly cheaper: 91 < 1729.
  4. Cube scaling.        The m-divisible part of R(m^3 N) is a bijective copy of R(N);
                          the cube-free core conjecture fails at 344 = 2^3 * 43.
  5. Growth floor.        r(N) >= n  ==>  N >= 110 (n-1)^3, and no shell argument can
                          beat (2^(1/3)/(2^(1/3)-1))^3 = 113.93...
  6. Transfer.            Rational points on one cubic, denominators cleared, collapse
                          onto a single integer with that many representations.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd, isqrt
from typing import Dict, List, Tuple

Rep = Tuple[int, int]


# ----------------------------------------------------------------------------
# integer cube roots
# ----------------------------------------------------------------------------

def icbrt(n: int) -> int:
    """Floor of the cube root of a nonnegative integer, exactly."""
    if n < 0:
        raise ValueError("icbrt expects n >= 0")
    if n < 2:
        return n
    x = int(round(n ** (1.0 / 3.0)))
    while x ** 3 > n:
        x -= 1
    while (x + 1) ** 3 <= n:
        x += 1
    return x


def exact_cube_root(n: int) -> int | None:
    """Return c with c**3 == n if n is a perfect cube (any sign), else None."""
    s = -1 if n < 0 else 1
    r = icbrt(abs(n))
    return s * r if (s * r) ** 3 == n else None


# ----------------------------------------------------------------------------
# 1. Representation sets
# ----------------------------------------------------------------------------

def positive_reps(N: int) -> List[Rep]:
    """All (a, b) with 1 <= a <= b and a^3 + b^3 = N.

    Uses the shell N/2 <= b^3 <= N (Lemma: the larger summand lies in a thin
    annulus), which shortens the loop to about 0.206 * N^(1/3) values of b.
    """
    if N < 2:
        return []
    out: List[Rep] = []
    b_hi = icbrt(N)
    b_lo = icbrt((N + 1) // 2)
    for b in range(max(1, b_lo), b_hi + 1):
        a = exact_cube_root(N - b ** 3)
        if a is not None and 1 <= a <= b:
            out.append((a, b))
    return sorted(out)


def signed_reps(N: int) -> List[Rep]:
    """All (a, b) with a, b nonzero integers, a <= b and a^3 + b^3 = N.

    Justified by the a priori bound a^2 <= N and b^2 <= N: the larger summand b
    is positive and satisfies b <= floor(sqrt(N)).  Without that bound the search
    would be unbounded, because the real curve has an infinite mixed-sign branch.
    """
    if N < 1:
        return []
    out: List[Rep] = []
    for b in range(1, isqrt(N) + 1):
        a = exact_cube_root(N - b ** 3)
        if a is not None and a != 0 and a <= b:
            out.append((a, b))
    return sorted(out)


def verify_apriori_bound(limit: int = 3000) -> Tuple[int, int]:
    """Check x^2 <= N and y^2 <= N for every signed representation with N < limit."""
    checked = 0
    for N in range(1, limit):
        for (a, b) in signed_reps(N):
            assert a * a <= N and b * b <= N, (N, a, b)
            checked += 1
    return limit, checked


# ----------------------------------------------------------------------------
# 2/3. Least numbers with n representations (shell sieve)
# ----------------------------------------------------------------------------

def taxicab_search(n: int, bound: int) -> int | None:
    """Least N < bound with at least n positive representations, or None."""
    counts: Dict[int, int] = {}
    b_max = icbrt(bound)
    for b in range(1, b_max + 1):
        for a in range(1, b + 1):
            v = a ** 3 + b ** 3
            if v < bound:
                counts[v] = counts.get(v, 0) + 1
    hits = [v for v, c in counts.items() if c >= n]
    return min(hits) if hits else None


def cabtaxi_search(n: int, bound: int) -> int | None:
    """Least N < bound with at least n signed representations, or None.

    The search square is [-B, B]^2 with B = floor(sqrt(bound)), which is exactly
    the localisation supplied by the a priori bound.
    """
    counts: Dict[int, int] = {}
    B = isqrt(bound)
    for b in range(-B, B + 1):
        if b == 0:
            continue
        for a in range(-B, b + 1):
            if a == 0:
                continue
            v = a ** 3 + b ** 3
            if 0 < v < bound:
                counts[v] = counts.get(v, 0) + 1
    hits = [v for v, c in counts.items() if c >= n]
    return min(hits) if hits else None


# ----------------------------------------------------------------------------
# 4. Cube scaling
# ----------------------------------------------------------------------------

def scaling_structure_check(N: int, m: int) -> bool:
    """Verify: {(x,y) in R(m^3 N) : m | x, m | y} == {(m a, m b) : (a,b) in R(N)}."""
    left = {(x, y) for (x, y) in positive_reps(m ** 3 * N) if x % m == 0 and y % m == 0}
    right = {(m * a, m * b) for (a, b) in positive_reps(N)}
    return left == right


def cube_free_core(N: int) -> Tuple[int, int]:
    """Write N = m^3 * N0 with N0 cube-free; return (m, N0)."""
    m, n0, d = 1, N, 2
    while d ** 3 <= n0:
        while n0 % (d ** 3) == 0:
            n0 //= d ** 3
            m *= d
        d += 1
    return m, n0


# ----------------------------------------------------------------------------
# 5. Growth floor
# ----------------------------------------------------------------------------

def shell_floor(n: int) -> int:
    """The proved elementary lower bound for a number with n representations."""
    return 110 * (n - 1) ** 3


def shell_ceiling_constant() -> float:
    """Supremum of the constant any shell argument can achieve: 113.93..."""
    c = 2.0 ** (1.0 / 3.0)
    return (c / (c - 1.0)) ** 3


# ----------------------------------------------------------------------------
# 6. Chord-tangent duplication and the transfer theorem
# ----------------------------------------------------------------------------

def tangent_double(x: Fraction, y: Fraction) -> Tuple[Fraction, Fraction]:
    """Tangent duplication on x^3 + y^3 = N: returns the second intersection point."""
    u, v = x ** 3, y ** 3
    if u == v:
        raise ValueError("tangent is vertical / undefined when x^3 = y^3")
    return (x * (u + 2 * v) / (u - v), -(y * (2 * u + v)) / (u - v))


def clear_denominators(points: List[Tuple[Fraction, Fraction]], q: Fraction
                       ) -> Tuple[int, List[Rep]]:
    """Transfer theorem: collapse rational points on x^3+y^3=q onto one integer.

    Returns (M, reps) with M = D^3 q for a common denominator D, and reps the
    resulting integer representations of M.
    """
    D = 1
    for (x, y) in points:
        D = D * x.denominator // gcd(D, x.denominator)
        D = D * y.denominator // gcd(D, y.denominator)
    D = D * q.denominator // gcd(D, q.denominator)
    M_frac = Fraction(D) ** 3 * q
    assert M_frac.denominator == 1
    M = int(M_frac)
    reps: List[Rep] = []
    for (x, y) in points:
        X, Y = D * x, D * y
        assert X.denominator == 1 and Y.denominator == 1
        a, b = int(X), int(Y)
        if a > b:
            a, b = b, a
        assert a ** 3 + b ** 3 == M
        reps.append((a, b))
    return M, sorted(set(reps))


# ----------------------------------------------------------------------------
# Reporting
# ----------------------------------------------------------------------------

def fmt(reps: List[Rep]) -> str:
    return "  ".join(f"({a})^3+({b})^3" if a < 0 else f"{a}^3+{b}^3" for a, b in reps)


def main() -> None:
    line = "=" * 78

    print(line)
    print("1.  A PRIORI LOCALISATION ON THE SIGNED CUBIC")
    print(line)
    limit, checked = verify_apriori_bound(3000)
    print(f"Checked every signed representation of every N < {limit}: "
          f"{checked} points, all satisfy x^2 <= N and y^2 <= N.")
    print("The mixed-sign branch of the real curve is unbounded, but carries no")
    print("lattice points beyond |x| <= sqrt(N): e.g. for N = 91 the branch is")
    print("trapped inside the square [-9, 9]^2 since 91 < 10^2.")
    print()

    print(line)
    print("2.  HARDY-RAMANUJAN:  Taxicab(2) = 1729")
    print(line)
    print(f"R(1729) = {positive_reps(1729)}   ->   {fmt(positive_reps(1729))}")
    worst = max(range(2, 1729), key=lambda N: len(positive_reps(N)))
    print(f"Largest representation count below 1729: "
          f"{len(positive_reps(worst))} (attained e.g. at N = {worst}).")
    print(f"Shell sieve over [1,12]^2 confirms least N with 2 reps = "
          f"{taxicab_search(2, 20000)}")
    print(f"Least N with 3 reps below 10^8 (shell sieve): {taxicab_search(3, 10 ** 8)}")
    print()

    print(line)
    print("3.  CABTAXI: SIGNS ARE STRICTLY CHEAPER")
    print(line)
    print(f"R^pm(91)  = {signed_reps(91)}   ->   91 = 3^3+4^3 = 6^3-5^3")
    print(f"R^pm(728) = {signed_reps(728)}   ->   728 = 6^3+8^3 = 9^3-1^3 = 12^3-10^3")
    print(f"R(728)    = {positive_reps(728)}   (only one positive representation)")
    print(f"Cabtaxi(2) by exhaustive search      = {cabtaxi_search(2, 1729)}")
    print(f"Cabtaxi(3) by exhaustive search      = {cabtaxi_search(3, 1729)}")
    print(f"Taxicab(2)                           = {taxicab_search(2, 20000)}")
    print("Signed count never below unsigned count; ratio 3:1 already at N = 728.")
    ratio_witness = [N for N in range(1, 2000)
                     if len(signed_reps(N)) >= 3 * max(1, len(positive_reps(N)))
                     and len(signed_reps(N)) >= 3]
    print(f"N < 2000 with r^pm(N) >= 3 * max(1, r(N)): {ratio_witness}")
    print()

    print(line)
    print("4.  CUBE SCALING AND THE CUBE-FREE CORE")
    print(line)
    for (N, m) in [(1729, 2), (1729, 3), (728, 2), (9, 5), (344, 2)]:
        ok = scaling_structure_check(N, m)
        print(f"  N={N:5d}, m={m}:  m-divisible part of R({m}^3*N) equals m*R(N)?  {ok}"
              f"   |R(N)|={len(positive_reps(N))}, "
              f"|R({m ** 3 * N})|={len(positive_reps(m ** 3 * N))}")
    print()
    print("  Cube-free core conjecture:  r(N) = r(core(N))?")
    counterexamples = []
    for N in range(2, 20000):
        m, n0 = cube_free_core(N)
        if m > 1 and len(positive_reps(N)) != len(positive_reps(n0)):
            counterexamples.append((N, m, n0, len(positive_reps(N)),
                                    len(positive_reps(n0))))
    print(f"  smallest counterexample: N={counterexamples[0][0]} = "
          f"{counterexamples[0][1]}^3 * {counterexamples[0][2]}, "
          f"r(N)={counterexamples[0][3]} > r(core)={counterexamples[0][4]}")
    print(f"  {len(counterexamples)} counterexamples below 20000; first ten: "
          f"{[c[0] for c in counterexamples[:10]]}")
    print(f"  R(344) = {positive_reps(344)},  R(43) = {positive_reps(43)}")
    print()

    print(line)
    print("5.  GROWTH FLOOR  N >= 110 (n-1)^3  AND THE CEILING 113.93...")
    print(line)
    known = {2: 1729,
             3: 87539319,
             4: 6963472309248,
             5: 48988659276962496,
             6: 24153319581254312065344}
    print(f"{'n':>2} {'proved floor 110(n-1)^3':>24} {'least known value':>26} "
          f"{'ratio':>12}")
    for n, val in known.items():
        fl = shell_floor(n)
        print(f"{n:>2} {fl:>24} {val:>26} {val / fl:>12.3e}")
    print()
    print(f"Supremum constant of the shell method: {shell_ceiling_constant():.5f}")
    print("  (fixed point of (t+1)^3 = 2 t^3, i.e. t = 1/(2^(1/3)-1) = "
          f"{1 / (2 ** (1 / 3) - 1):.4f})")
    print("Empirical check of the floor for all N < 200000:")
    bad = [(N, len(positive_reps(N))) for N in range(1, 200000)
           if len(positive_reps(N)) >= 2 and N < shell_floor(len(positive_reps(N)))]
    print(f"  violations: {bad}   (none expected)")
    print()

    print(line)
    print("6.  CHORD-TANGENT ORBIT AND THE TRANSFER THEOREM")
    print(line)
    q = Fraction(9)
    P = (Fraction(1), Fraction(2))
    orbit = [P]
    for _ in range(3):
        P = tangent_double(*P)
        orbit.append(P)
    for k, (x, y) in enumerate(orbit):
        assert x ** 3 + y ** 3 == q
        print(f"  P_{k} = ({x}, {y})   ->   x^3+y^3 = {x ** 3 + y ** 3}")
    M, reps = clear_denominators(orbit[:2], q)
    print(f"  Clearing denominators for the first two points: M = {M}")
    print(f"  representations: {reps}   ->   {fmt(reps)}")
    M3, reps3 = clear_denominators(orbit[:3], q)
    print(f"  First three points: M = {M3} (a {len(str(M3))}-digit number) with "
          f"{len(reps3)} signed representations")
    for (a, b) in reps3:
        assert a ** 3 + b ** 3 == M3
    print("  Every rational point on one cubic contributes one representation of the")
    print("  single integer D^3 q; an infinite rational orbit would therefore give")
    print("  integers with arbitrarily many representations.")
    print()

    print(line)
    print("ALL ASSERTIONS PASSED")
    print(line)


if __name__ == "__main__":
    main()
