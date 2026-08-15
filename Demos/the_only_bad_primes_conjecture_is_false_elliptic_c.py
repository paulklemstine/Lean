"""
Denominators of multiples of integral points on Mordell curves E_N : y^2 = x^3 + N.

This script demonstrates, numerically, the results of the accompanying paper
"Good Primes in Bad Places".  Everything is exact rational arithmetic
(fractions.Fraction), so nothing here depends on floating point.

Contents
--------
 1. The duplication formula and the counterexample N = 55, P = (9,28).
 2. The mechanism theorem:  for a prime l not dividing 6N,
        l | den x(2P)   <=>   l | y   ( <=> 2*Pbar = O over F_l ).
 3. The exact exponent:  v_l(den x(2P)) = 2 v_l(y) at every good prime l.
 4. Triplication:  l | den x(3P)  <=>  l | psi_3(P) = 3x^4 + 12Nx.
 5. The doubling tower: rigidity at odd primes, +2 per level at the prime 2.
 6. Universality: every prime l >= 5 is extraneous for a suitable N,
    and arbitrarily many extraneous primes can occur in one denominator.
 7. A survey over semiprime N = p q.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

# --------------------------------------------------------------------------- #
# Elementary number theory helpers
# --------------------------------------------------------------------------- #


def is_prime(n: int) -> bool:
    """Deterministic primality test, adequate for the sizes used here."""
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def factorize(n: int) -> Dict[int, int]:
    """Prime factorisation of |n| as {prime: exponent} (trial division + Pollard rho)."""
    n = abs(n)
    factors: Dict[int, int] = {}
    if n <= 1:
        return factors
    for p in range(2, 100000):
        if p * p > n:
            break
        while n % p == 0:
            factors[p] = factors.get(p, 0) + 1
            n //= p
    if n > 1:
        for q in _rho_factor(n):
            factors[q] = factors.get(q, 0) + 1
    return factors


def _rho_factor(n: int) -> List[int]:
    """Return the multiset of prime factors of n > 1 via Pollard's rho."""
    if n == 1:
        return []
    if is_prime(n):
        return [n]
    from math import gcd

    c = 1
    while True:
        x, y, d = 2, 2, 1
        while d == 1:
            x = (x * x + c) % n
            y = (y * y + c) % n
            y = (y * y + c) % n
            d = gcd(abs(x - y), n)
        if d != n:
            return sorted(_rho_factor(d) + _rho_factor(n // d))
        c += 1


def valuation(n: int, p: int) -> int:
    """The exponent of the prime p in the integer n (0 if p does not divide n)."""
    if n == 0:
        raise ValueError("valuation of 0 is undefined")
    v = 0
    n = abs(n)
    while n % p == 0:
        n //= p
        v += 1
    return v


def pretty_factorization(n: int) -> str:
    """Human-readable factorisation string, e.g. 3136 -> '2^6 * 7^2'."""
    if n in (0, 1):
        return str(n)
    if n > 10 ** 24:  # keep the demo fast: do not attempt to factor huge integers
        return str(n)
    parts = [f"{p}^{e}" if e > 1 else f"{p}" for p, e in sorted(factorize(n).items())]
    return " * ".join(parts)


# --------------------------------------------------------------------------- #
# The Mordell curve E_N : y^2 = x^3 + N  --  explicit multiplication formulas
# --------------------------------------------------------------------------- #

Point = Optional[Tuple[Fraction, Fraction]]  # None denotes the point at infinity O


def on_curve(N: int, P: Point) -> bool:
    """Is P a point of E_N : y^2 = x^3 + N?  (The point at infinity always is.)"""
    if P is None:
        return True
    x, y = P
    return y * y == x * x * x + N


def dbl_x(N: int, x: Fraction) -> Fraction:
    """The classical duplication value x(2P) = (x^4 - 8Nx) / (4(x^3 + N))."""
    return (x**4 - 8 * N * x) / (4 * (x**3 + N))


def psi3(N: int, x: Fraction) -> Fraction:
    """The third division polynomial psi_3 = 3x^4 + 12Nx of E_N."""
    return 3 * x**4 + 12 * N * x


def tri_x(N: int, x: Fraction, y: Fraction) -> Fraction:
    """The classical triplication value x(3P) = x - psi_2 psi_4 / psi_3^2."""
    u = psi3(N, x)
    return (x * u**2 - 8 * y**2 * (x**6 + 20 * N * x**3 - 8 * N**2)) / u**2


def add(N: int, P: Point, Q: Point) -> Point:
    """The group law on E_N : y^2 = x^3 + N over the rationals."""
    if P is None:
        return Q
    if Q is None:
        return P
    x1, y1 = P
    x2, y2 = Q
    if x1 == x2 and y1 == -y2:
        return None
    if P == Q:
        if y1 == 0:
            return None
        lam = 3 * x1 * x1 / (2 * y1)
    else:
        lam = (y2 - y1) / (x2 - x1)
    x3 = lam * lam - x1 - x2
    y3 = lam * (x1 - x3) - y1
    return (x3, y3)


def mul(N: int, n: int, P: Point) -> Point:
    """The n-th multiple nP, computed by double-and-add."""
    if n < 0:
        R = mul(N, -n, P)
        return None if R is None else (R[0], -R[1])
    R: Point = None
    Q: Point = P
    while n:
        if n & 1:
            R = add(N, R, Q)
        Q = add(N, Q, Q)
        n >>= 1
    return R


def denominator_of_x(N: int, n: int, P: Point) -> Optional[int]:
    """The denominator of the x-coordinate of nP (None if nP is the point at infinity)."""
    R = mul(N, n, P)
    return None if R is None else R[0].denominator


def bad_primes(N: int) -> List[int]:
    """The primes of bad reduction of E_N: the primes dividing Delta = -432 N^2."""
    return sorted({2, 3} | set(factorize(N)))


def integral_points(N: int, x_bound: int = 400) -> List[Tuple[int, int]]:
    """All integral points (x,y) with |x| <= x_bound and y > 0 on y^2 = x^3 + N."""
    pts: List[Tuple[int, int]] = []
    for x in range(-x_bound, x_bound + 1):
        t = x**3 + N
        if t <= 0:
            continue
        r = int(round(t ** 0.5))
        for cand in (r - 1, r, r + 1):
            if cand > 0 and cand * cand == t:
                pts.append((x, cand))
                break
    return pts


# --------------------------------------------------------------------------- #
# 1.  The counterexample N = 55, P = (9,28)
# --------------------------------------------------------------------------- #


def demo_counterexample_55() -> None:
    print("=" * 74)
    print("1.  THE COUNTEREXAMPLE:  N = 55 = 5 * 11,  P = (9, 28)")
    print("=" * 74)
    N, x, y = 55, Fraction(9), Fraction(28)
    assert on_curve(N, (x, y)), "P must lie on the curve"
    print(f"  curve            E_55 : y^2 = x^3 + 55,   Delta = -432 * 55^2")
    print(f"  bad primes       {bad_primes(N)}          (the primes dividing Delta)")
    x2 = dbl_x(N, x)
    print(f"  duplication      x(2P) = (9^4 - 8*55*9) / (4*(9^3+55)) = {x2}")
    d = x2.denominator
    print(f"  denominator      {d} = {pretty_factorization(d)}")
    print(f"  group law check  x(2P) via chord-tangent = {mul(N, 2, (x, y))[0]}")
    print()
    print("  The prime 7 divides the denominator, yet 7 does not divide")
    print(f"  Delta = {-432 * 55**2} : indeed {-432 * 55**2} mod 7 = {(-432 * 55**2) % 7}.")
    print("  So 7 is a prime of GOOD reduction appearing in a denominator:")
    print("  the 'only bad primes' conjecture is false.")
    assert d % 7 == 0 and (-432 * N**2) % 7 != 0
    print()
    print("  Second counterexample:  N = 899 = 29 * 31 (twin primes), P = (1, 30)")
    x2b = dbl_x(899, Fraction(1))
    print(f"    x(2P) = {x2b},  denominator {x2b.denominator}"
          f" = {pretty_factorization(x2b.denominator)}")
    print(f"    bad primes of E_899 : {bad_primes(899)};  5 is extraneous.")
    assert x2b.denominator % 5 == 0 and 5 not in bad_primes(899)
    print()


# --------------------------------------------------------------------------- #
# 2.  The mechanism theorem
# --------------------------------------------------------------------------- #


def demo_mechanism() -> None:
    print("=" * 74)
    print("2.  MECHANISM THEOREM:   l | den x(2P)  <=>  l | y   (for l not dividing 6N)")
    print("=" * 74)
    cases: Sequence[Tuple[int, int, int]] = [
        (55, 9, 28),
        (899, 1, 30),
        (17, -2, 3),
        (24, 1, 5),
        (225, 4, 17),
        (-2, 3, 5),
    ]
    for N, xi, yi in cases:
        assert yi * yi == xi**3 + N
        den = dbl_x(N, Fraction(xi)).denominator
        good = [l for l in range(5, 200) if is_prime(l) and (6 * N) % l != 0]
        ok = all(((den % l == 0) == (yi % l == 0)) for l in good)
        appear = sorted(l for l in good if den % l == 0)
        print(f"  N={N:>5}  P=({xi},{yi})   den x(2P) = {pretty_factorization(den)}")
        print(f"          good primes in the denominator: {appear or '(none)'}"
              f"   |  primes dividing y = {sorted(set(factorize(abs(yi))))}")
        print(f"          equivalence verified for all good primes < 200: {ok}")
        assert ok
    print()
    print("  Reduction-theoretic reading:  l | y means the reduction of P modulo l")
    print("  is a point of order dividing 2, i.e. 2*Pbar = O in E_N(F_l).")
    print("  Doubling then sends Pbar to the origin of the formal group, which is")
    print("  precisely what a denominator divisible by l records.")
    print()


# --------------------------------------------------------------------------- #
# 3.  The exact exponent  v_l(den x(2P)) = 2 v_l(y)
# --------------------------------------------------------------------------- #


def demo_exact_exponent() -> None:
    print("=" * 74)
    print("3.  EXACT EXPONENT:   v_l(den x(2P)) = 2 v_l(y)   at every good prime l")
    print("=" * 74)
    cases: Sequence[Tuple[int, int, int]] = [
        (55, 9, 28),
        (899, 1, 30),
        (25 * 49 - 1, 1, 35),
        (121 * 4 - 1, 1, 22),
    ]
    for N, xi, yi in cases:
        assert yi * yi == xi**3 + N
        den = dbl_x(N, Fraction(xi)).denominator
        row = []
        for l in sorted(factorize(abs(yi))):
            if (6 * N) % l == 0:
                continue
            lhs = valuation(den, l) if den % l == 0 else 0
            rhs = 2 * valuation(yi, l)
            row.append(f"l={l}: v(den)={lhs}, 2v(y)={rhs}")
            assert lhs == rhs
        print(f"  N={N:>6}  P=({xi},{yi})   den = {pretty_factorization(den)}")
        print(f"          {'; '.join(row) if row else '(no good prime divides y)'}")
    print()


# --------------------------------------------------------------------------- #
# 4.  Triplication
# --------------------------------------------------------------------------- #


def demo_triplication() -> None:
    print("=" * 74)
    print("4.  TRIPLICATION:   l | den x(3P)  <=>  l | psi_3(P) = 3x^4 + 12Nx")
    print("=" * 74)
    N, xi, yi = 55, 9, 28
    x3 = tri_x(N, Fraction(xi), Fraction(yi))
    assert x3 == mul(N, 3, (Fraction(xi), Fraction(yi)))[0]
    d3 = x3.denominator
    print(f"  N=55, P=(9,28):  x(3P) = {x3}")
    print(f"  denominator      {d3} = {pretty_factorization(d3)}")
    u = psi3(N, Fraction(xi))
    print(f"  psi_3(P)         3*9^4 + 12*55*9 = {u} = {pretty_factorization(int(u))}")
    print(f"  and indeed den x(3P) = psi_3(P)^2 : {int(u) ** 2 == d3}")
    assert int(u) ** 2 == d3
    print()
    print("  So 13 and 73 are good-reduction primes in the denominator of x(3P),")
    print("  while the level-2 extraneous prime 7 has vanished:")
    d2 = dbl_x(N, Fraction(xi)).denominator
    print(f"    7  | den x(2P): {d2 % 7 == 0}      7  | den x(3P): {d3 % 7 == 0}")
    print(f"    13 | den x(2P): {d2 % 13 == 0}     13 | den x(3P): {d3 % 13 == 0}")
    print(f"    73 | den x(2P): {d2 % 73 == 0}     73 | den x(3P): {d3 % 73 == 0}")
    print("  The extraneous primes MOVE with n: they read off the division")
    print("  polynomials psi_n(P), not any fixed set attached to N.")
    good = [l for l in range(5, 500) if is_prime(l) and (6 * N) % l != 0]
    ok = all(((d3 % l == 0) == (int(u) % l == 0)) for l in good)
    print(f"  equivalence l | den x(3P) <=> l | psi_3(P) verified for l < 500: {ok}")
    assert ok
    print()


# --------------------------------------------------------------------------- #
# 5.  The doubling tower: rigidity at odd primes, growth at 2
# --------------------------------------------------------------------------- #


def dbl_iter(N: int, k: int, x: Fraction) -> Fraction:
    """The k-fold iterated duplication value x(2^k P)."""
    for _ in range(k):
        x = dbl_x(N, x)
    return x


def demo_tower() -> None:
    print("=" * 74)
    print("5.  THE DOUBLING TOWER:  frozen good primes, linear growth at 2")
    print("=" * 74)
    N, xi, yi = 55, 9, 28
    x = Fraction(xi)
    print("   k   x(2^k P) denominator factorised          v_7   v_2")
    for k in range(0, 3):
        xk = dbl_iter(N, k, x)
        d = xk.denominator
        v7 = valuation(d, 7) if d % 7 == 0 else 0
        v2 = valuation(d, 2) if d % 2 == 0 else 0
        s = pretty_factorization(d)
        if len(s) > 40:
            s = s[:37] + "..."
        print(f"  {k:>2}   {s:<40} {v7:>4}  {v2:>4}")
    print()
    print("  From level 1 onwards v_7 is frozen at 2 = 2*v_7(28), exactly as the")
    print("  persistence theorem predicts, while v_2 increases by exactly 2 per step.")
    d1 = dbl_iter(N, 1, x).denominator
    d2 = dbl_iter(N, 2, x).denominator
    assert valuation(d1, 7) == valuation(d2, 7) == 2
    assert valuation(d2, 2) == valuation(d1, 2) + 2
    print(f"  Level four:  den x(4P) = {d2}")
    print(f"                        = {pretty_factorization(d2)}")
    print("  Two brand-new good-reduction primes 827 and 1583 have appeared, and")
    print("  none of 7, 827, 1583 divides Delta = -432 * 55^2.")
    assert d2 % 827 == 0 and d2 % 1583 == 0
    for l in (7, 827, 1583):
        assert (6 * N) % l != 0
    print()


# --------------------------------------------------------------------------- #
# 6.  Universality: every prime >= 5 is extraneous somewhere
# --------------------------------------------------------------------------- #


def demo_universality() -> None:
    print("=" * 74)
    print("6.  UNIVERSALITY:  every prime l >= 5 is extraneous for a suitable N")
    print("=" * 74)
    print("  Take N = l^2 m^2 - 1 and the integral point P = (1, l m).")
    print("  Then l does not divide 6N (so l is a prime of good reduction) and")
    print("  l divides y, hence l divides den x(2P).")
    print()
    print("    l     m       N = l^2 m^2 - 1     den x(2P) factorised")
    for l in (5, 7, 11, 13, 101):
        for m in (1, 2):
            N = l * l * m * m - 1
            den = dbl_x(N, Fraction(1)).denominator
            assert (6 * N) % l != 0 and den % l == 0
            s = pretty_factorization(den)
            if len(s) > 34:
                s = s[:31] + "..."
            print(f"  {l:>5} {m:>5} {N:>17}     {s}")
    print()
    print("  Arbitrarily many extraneous primes at once:  put K = product of a")
    print("  finite set S of primes >= 5, N = K^2 m^2 - 1, P = (1, K m).")
    S = [5, 7, 11, 13]
    K = 1
    for p in S:
        K *= p
    N = K * K - 1
    den = dbl_x(N, Fraction(1)).denominator
    print(f"    S = {S},  K = {K},  N = {N}")
    print(f"    den x(2P) = {pretty_factorization(den)}")
    for l in S:
        assert (6 * N) % l != 0 and den % l == 0
    print(f"    every element of S is a good prime dividing the denominator: True")
    print()


# --------------------------------------------------------------------------- #
# 7.  A survey over semiprimes
# --------------------------------------------------------------------------- #


def demo_survey() -> None:
    print("=" * 74)
    print("7.  SURVEY OVER SEMIPRIMES N = p*q  (does the denominator reveal p or q?)")
    print("=" * 74)
    print("  For each semiprime N = p q we take every integral point (x,y) with")
    print("  |x| <= 200, y > 0, and look at the denominators of x(2P) and x(3P).")
    print()
    semiprimes = [
        (5, 11), (3, 5), (5, 7), (7, 11), (3, 11), (29, 31),
        (5, 13), (11, 13), (3, 7), (13, 17), (7, 13),
    ]
    n_total = 0
    n_p_seen = 0
    n_q_seen = 0
    n_only_bad = 0
    n_extraneous = 0
    header = "      N = p*q   points   primes met in den x(2P), x(3P)   p?     q?     only-bad?"
    print(header)
    for p, q in semiprimes:
        N = p * q
        pts = [(a, b) for (a, b) in integral_points(N, 200) if b != 0]
        if not pts:
            continue
        met: set = set()
        for xi, yi in pts:
            for n in (2, 3):
                R = mul(N, n, (Fraction(xi), Fraction(yi)))
                if R is None:
                    continue
                met |= set(factorize(R[0].denominator))
        n_total += 1
        p_seen = p in met
        q_seen = q in met
        only_bad = met <= set(bad_primes(N))
        n_p_seen += p_seen
        n_q_seen += q_seen
        n_only_bad += only_bad
        n_extraneous += not only_bad
        shown = sorted(met)
        pr = ",".join(map(str, shown[:6])) + ("..." if len(shown) > 6 else "")
        print(f"  {N:>8} = {p}*{q}".ljust(20)
              + f"{len(pts):>4}   {pr:<32}"
              + f"{str(p_seen):<7}{str(q_seen):<7}{only_bad}")
    print()
    print(f"  sample size (semiprimes with an integral point) : {n_total}")
    print(f"  smaller factor p met in some denominator        : "
          f"{n_p_seen}/{n_total} = {100.0 * n_p_seen / n_total:.1f}%")
    print(f"  larger factor q met in some denominator         : "
          f"{n_q_seen}/{n_total} = {100.0 * n_q_seen / n_total:.1f}%")
    print(f"  'only bad primes' survives                      : "
          f"{n_only_bad}/{n_total} = {100.0 * n_only_bad / n_total:.1f}%")
    print(f"  at least one extraneous good prime occurs       : "
          f"{n_extraneous}/{n_total} = {100.0 * n_extraneous / n_total:.1f}%")
    print()
    print("  Conclusion: the denominators are governed by the point, through the")
    print("  division polynomials, not by the factorisation of N.  They neither")
    print("  exclude good primes nor reliably exhibit the factors p and q, so they")
    print("  carry no usable factoring signal.")
    print()


def main() -> None:
    demo_counterexample_55()
    demo_mechanism()
    demo_exact_exponent()
    demo_triplication()
    demo_tower()
    demo_universality()
    demo_survey()
    print("=" * 74)
    print("All assertions passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
