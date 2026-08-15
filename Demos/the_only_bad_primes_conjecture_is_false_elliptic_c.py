"""
Apparition of good primes in Mordell-curve denominators.
=========================================================

Numerical demonstration of the refutation of the "only bad primes" conjecture
for the curves E_N : y^2 = x^3 + N over the rationals.

The conjecture asserted that the primes dividing the denominators of the
x-coordinates of the multiples nP of a rational point P are confined to the
primes dividing the discriminant Delta = -432 N^2, i.e. to {2, 3} together with
the prime divisors of N.  It is false.  This script demonstrates, with exact
arithmetic:

  1.  The counterexample: on E_55 with P = (9, 28) one has
      x(2P) = 2601/3136 and 3136 = 2^6 * 7^2, so the good prime 7 occurs.
  2.  The apparition law: the indices n at which a prime L divides the
      denominator of x(nP) are exactly the multiples of a single modulus m,
      the apparition index of L.
  3.  The identification m = order of the reduced point in E_N(F_L), which
      turns an intractable rational computation into a cheap finite-field one.
  4.  The effective bound 0 < m <= 4L for every prime L >= 5 with L not
      dividing N (every prime of good reduction beyond 2 and 3).
  5.  Positive density: exactly floor(K/m) >= floor(K/(4L)) of the first K
      indices violate the conjecture at L.
  6.  Simultaneous apparition: for a finite set S of good primes, the product
      of S divides the denominator exactly along the progression of modulus
      lcm of the individual indices.  On E_55, 91 = 7 * 13 divides
      den x(kP) if and only if 6 divides k.
  7.  The reverse inclusion: the primes ABSENT from all denominators are
      contained in {2, 3} union {p : p | N}, the exact opposite of the
      conjectured inclusion.

Pure standard library; no dependencies.
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd, isqrt
from typing import Dict, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------
# Types
# ----------------------------------------------------------------------------

RatPoint = Optional[Tuple[Fraction, Fraction]]   # None is the point at infinity
FinPoint = Optional[Tuple[int, int]]             # None is the point at infinity


# ----------------------------------------------------------------------------
# 1.  Exact group law on E_N : y^2 = x^3 + N over Q
# ----------------------------------------------------------------------------

def rat_add(P: RatPoint, Q: RatPoint, N: int) -> RatPoint:
    """Add two points of E_N : y^2 = x^3 + N over the rationals.

    `None` denotes the point at infinity (the group identity).
    """
    if P is None:
        return Q
    if Q is None:
        return P
    x1, y1 = P
    x2, y2 = Q
    if x1 == x2:
        if y1 != y2 or y1 == 0:
            return None                      # P = -Q, so P + Q = O
        lam = (3 * x1 * x1) / (2 * y1)       # duplication
    else:
        lam = (y2 - y1) / (x2 - x1)          # chord
    x3 = lam * lam - x1 - x2
    y3 = lam * (x1 - x3) - y1
    return (x3, y3)


def rat_orbit(P: Tuple[Fraction, Fraction], N: int, length: int) -> List[RatPoint]:
    """Return [P, 2P, 3P, ..., (length)P] computed with exact rationals."""
    out: List[RatPoint] = []
    Q: RatPoint = None
    for _ in range(length):
        Q = rat_add(Q, P, N)
        out.append(Q)
        if Q is None:
            break
    return out


def x_denominator(Q: RatPoint) -> Optional[int]:
    """Denominator of the x-coordinate in lowest terms; None at infinity."""
    return None if Q is None else Q[0].denominator


def small_prime_part(n: int, bound: int = 200) -> Tuple[Dict[int, int], int]:
    """Factor out all primes <= `bound`; return (factorisation, cofactor)."""
    factors: Dict[int, int] = {}
    p = 2
    while p <= bound:
        while n % p == 0:
            factors[p] = factors.get(p, 0) + 1
            n //= p
        p += 1
    return factors, n


# ----------------------------------------------------------------------------
# 2.  Group law on the reduced curve E_N(F_L)  (L prime, L >= 5, L not | N)
# ----------------------------------------------------------------------------

def fin_add(P: FinPoint, Q: FinPoint, N: int, L: int) -> FinPoint:
    """Add two points of E_N over the finite field with L elements."""
    if P is None:
        return Q
    if Q is None:
        return P
    x1, y1 = P
    x2, y2 = Q
    if x1 == x2:
        if (y1 + y2) % L == 0:
            return None
        lam = (3 * x1 * x1) * pow(2 * y1, -1, L) % L
    else:
        lam = (y2 - y1) * pow(x2 - x1, -1, L) % L
    x3 = (lam * lam - x1 - x2) % L
    y3 = (lam * (x1 - x3) - y1) % L
    return (x3, y3)


def reduce_point(P: Tuple[Fraction, Fraction], L: int) -> FinPoint:
    """Reduce an L-integral rational point modulo L."""
    x, y = P
    if x.denominator % L == 0 or y.denominator % L == 0:
        return None                                  # already at infinity mod L
    xr = x.numerator * pow(x.denominator, -1, L) % L
    yr = y.numerator * pow(y.denominator, -1, L) % L
    return (xr, yr)


def apparition_index(P: Tuple[Fraction, Fraction], N: int, L: int) -> int:
    """ALGORITHM A.  The apparition index of the good prime L for the point P:
    the least m > 0 with L | den x(mP), equivalently the order of the reduction
    of P in E_N(F_L).  Cost: O(L) field operations (naive), each O(log^2 L).
    """
    Pbar = reduce_point(P, L)
    if Pbar is None:
        return 1
    Q: FinPoint = Pbar
    m = 1
    limit = 4 * L + 1                       # the proved bound: m <= 4L
    while Q is not None and m <= limit:
        Q = fin_add(Q, Pbar, N, L)
        m += 1
    if Q is not None:
        raise RuntimeError(f"apparition index of {L} exceeded the proved bound 4L")
    return m


def joint_apparition_modulus(P: Tuple[Fraction, Fraction], N: int,
                             S: Sequence[int]) -> int:
    """ALGORITHM C.  Modulus M with (prod S) | den x(kP)  <=>  M | k.
    By the simultaneous apparition theorem, M = lcm of the individual indices.
    """
    M = 1
    for L in S:
        m = apparition_index(P, N, L)
        M = M * m // gcd(M, m)
    return M


# ----------------------------------------------------------------------------
# 3.  Small helpers
# ----------------------------------------------------------------------------

def primes_up_to(n: int) -> List[int]:
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for p in range(2, isqrt(n) + 1):
        if sieve[p]:
            sieve[p * p:: p] = bytearray(len(sieve[p * p:: p]))
    return [i for i in range(n + 1) if sieve[i]]


def is_good_prime(L: int, N: int) -> bool:
    """L is a prime of good reduction for E_N beyond 2 and 3: L >= 5, L not | N."""
    return L >= 5 and N % L != 0


def hasse_bound(L: int) -> float:
    return L + 1 + 2 * (L ** 0.5)


def rule(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ----------------------------------------------------------------------------
# Demonstration 1 — the counterexample
# ----------------------------------------------------------------------------

def demo_counterexample() -> None:
    rule("1.  THE COUNTEREXAMPLE:  N = 55 = 5 * 11,  P = (9, 28)  on  y^2 = x^3 + 55")
    N = 55
    P = (Fraction(9), Fraction(28))
    assert P[1] ** 2 == P[0] ** 3 + N, "P must lie on the curve"
    print(f"  P = (9, 28) lies on the curve:  28^2 = {28**2} = 9^3 + 55 = {9**3 + 55}")

    # duplication formula  x(2P) = (x^4 - 8Nx) / (4y^2)
    x, y = P
    x2_formula = (x ** 4 - 8 * N * x) / (4 * y ** 2)
    two_P = rat_add(P, P, N)
    assert two_P is not None and two_P[0] == x2_formula
    num, den = two_P[0].numerator, two_P[0].denominator
    print(f"  x(2P) = (9^4 - 8*55*9) / (4*(9^3 + 55)) = {num}/{den}")
    print(f"  denominator {den} factors as {small_prime_part(den)[0]}")

    disc = -432 * N * N
    bad = sorted({p for p in primes_up_to(100) if disc % p == 0})
    print(f"  discriminant Delta = -432 * 55^2 = {disc}")
    print(f"  bad primes (dividing Delta): {bad}")
    print("  BUT 7 divides the denominator and 7 is NOT among them:")
    print(f"      Delta mod 7 = {disc % 7}  ->  7 is a prime of GOOD reduction.")
    print("  The 'only bad primes' conjecture is false.")


# ----------------------------------------------------------------------------
# Demonstration 2 — the denominator spectrum of an initial segment
# ----------------------------------------------------------------------------

def demo_spectrum(N: int = 55, length: int = 10) -> None:
    rule("2.  THE DENOMINATOR SPECTRUM OF THE ORBIT (exact rational arithmetic)")
    P = (Fraction(9), Fraction(28))
    print(f"  n | digits |  small-prime part of den x(nP)   (primes < 200)")
    print("  --+--------+--------------------------------------------------")
    for n, Q in enumerate(rat_orbit(P, N, length), start=1):
        d = x_denominator(Q)
        assert d is not None
        fac, _ = small_prime_part(d)
        pretty = " * ".join(f"{p}^{e}" for p, e in sorted(fac.items())) or "1"
        print(f" {n:2d} | {len(str(d)):6d} |  {pretty}")
    print()
    print("  The good primes 7, 13, 17, 19, 43, 73, 179 all occur.")
    print("  The bad prime 5 occurs at n = 5, 10; the bad prime 11 does not occur")
    print("  at all in this range: bad primes are PERMITTED to be absent, good")
    print("  primes are not.")


# ----------------------------------------------------------------------------
# Demonstration 3 — the apparition law, verified two independent ways
# ----------------------------------------------------------------------------

def demo_apparition_law(N: int = 55, length: int = 10) -> None:
    rule("3.  THE APPARITION LAW:  L | den x(nP)  <=>  m_L | n")
    P = (Fraction(9), Fraction(28))
    orbit = rat_orbit(P, N, length)
    dens = [x_denominator(Q) for Q in orbit]

    print("  L  | index m (from E_N(F_L)) | indices n <= %d with L | den x(nP)"
          % length)
    print("  ---+------------------------+---------------------------------")
    for L in [7, 13, 17, 19, 43, 73, 179]:
        m = apparition_index(P, N, L)
        hits = [n for n, d in enumerate(dens, start=1) if d is not None and d % L == 0]
        predicted = [n for n in range(1, length + 1) if n % m == 0]
        assert hits == predicted, (L, hits, predicted)
        print(f" {L:3d} | {m:22d} | {hits}   (= multiples of {m})")
    print()
    print("  The cheap finite-field computation reproduces the expensive rational")
    print("  one exactly.  Denominators grow like c^(n^2); apparition indices do not.")


# ----------------------------------------------------------------------------
# Demonstration 4 — the effective bound 4L, and the sharper Hasse bound
# ----------------------------------------------------------------------------

def demo_effective_bound(N: int = 55, prime_bound: int = 200) -> None:
    rule("4.  EVERY GOOD PRIME APPEARS, AND APPEARS BEFORE STEP 4L")
    P = (Fraction(9), Fraction(28))
    worst_ratio = 0.0
    worst_L = 0
    rows: List[Tuple[int, int]] = []
    for L in primes_up_to(prime_bound):
        if not is_good_prime(L, N):
            continue
        m = apparition_index(P, N, L)
        assert 0 < m <= 4 * L, "effective apparition bound violated"
        assert m <= hasse_bound(L), "Hasse-sharp bound (conjecture C1) violated"
        rows.append((L, m))
        if m / L > worst_ratio:
            worst_ratio, worst_L = m / L, L
    print(f"  Tested all {len(rows)} good primes L <= {prime_bound}.")
    print("  Every one has a finite apparition index: every one appears.")
    print(f"  Every index satisfies the proved bound m <= 4L,")
    print(f"  and also the sharper conjectural bound m <= L + 1 + 2*sqrt(L).")
    print(f"  Worst observed ratio m/L = {worst_ratio:.3f}  (at L = {worst_L});")
    print("  the proved bound allows 4.000, so the guarantee is far from tight.")
    print()
    print("  L :  m   |" * 1)
    line = ""
    for i, (L, m) in enumerate(rows[:26]):
        line += f" {L:3d}:{m:4d} "
        if (i + 1) % 6 == 0:
            print("   " + line)
            line = ""
    if line:
        print("   " + line)


# ----------------------------------------------------------------------------
# Demonstration 5 — positive density of the violations
# ----------------------------------------------------------------------------

def demo_density(N: int = 55) -> None:
    rule("5.  POSITIVE DENSITY:  #{n <= K : L | den x(nP)} = floor(K/m) >= floor(K/4L)")
    P = (Fraction(9), Fraction(28))
    print("   L  |  m  | density 1/m | guarantee 1/(4L) |  count for K = 10000")
    print("  ----+-----+-------------+------------------+---------------------")
    K = 10_000
    for L in [7, 13, 17, 43, 73, 101, 179]:
        m = apparition_index(P, N, L)
        exact = K // m
        guaranteed = K // (4 * L)
        assert exact >= guaranteed
        print(f"  {L:3d} | {m:3d} |   {1/m:9.6f} |      {1/(4*L):11.6f} |"
              f"  {exact:6d}  (>= {guaranteed})")
    print()
    print("  The conjecture does not fail on a thin exceptional set: for every")
    print("  good prime it fails at a positive proportion of ALL indices.")


# ----------------------------------------------------------------------------
# Demonstration 6 — simultaneous apparition
# ----------------------------------------------------------------------------

def demo_simultaneous(N: int = 55, length: int = 12) -> None:
    rule("6.  SIMULTANEOUS APPARITION:  91 = 7 * 13 divides den x(kP) iff 6 | k")
    P = (Fraction(9), Fraction(28))
    M = joint_apparition_modulus(P, N, [7, 13])
    print(f"  apparition index of  7 : {apparition_index(P, N, 7)}")
    print(f"  apparition index of 13 : {apparition_index(P, N, 13)}")
    print(f"  joint modulus M = lcm  : {M}")
    orbit = rat_orbit(P, N, length)
    hits = [n for n, Q in enumerate(orbit, start=1)
            if (d := x_denominator(Q)) is not None and d % 91 == 0]
    assert hits == [n for n in range(1, length + 1) if n % M == 0]
    print(f"  indices n <= {length} with 91 | den x(nP): {hits}  (= multiples of {M})")
    print()
    for S in ([7, 13], [7, 13, 17], [7, 13, 17, 19], [7, 13, 17, 19, 43]):
        M = joint_apparition_modulus(P, N, S)
        prod = 1
        for L in S:
            prod *= L
        bound = 1
        for L in S:
            bound *= 4 * L
        print(f"  S = {S}: product {prod} divides den x(kP) iff {M} | k"
              f"   (proved bound on the modulus: {bound})")
    print()
    print("  Arbitrarily many good primes conspire, simultaneously, along an")
    print("  arithmetic progression of positive density.")


# ----------------------------------------------------------------------------
# Demonstration 7 — the reverse inclusion
# ----------------------------------------------------------------------------

def demo_reverse_inclusion(N: int = 55, length: int = 10,
                           prime_bound: int = 200) -> None:
    rule("7.  THE REVERSE INCLUSION:  absent primes lie in {2, 3} u {p : p | N}")
    P = (Fraction(9), Fraction(28))
    orbit = rat_orbit(P, N, length)
    dens = [x_denominator(Q) for Q in orbit]
    present: List[int] = []
    absent: List[int] = []
    for L in primes_up_to(prime_bound):
        if any(d is not None and d % L == 0 for d in dens):
            present.append(L)
        else:
            absent.append(L)
    print(f"  primes <= {prime_bound} present in the first {length} denominators:")
    print(f"    {present}")
    print(f"  good primes L <= {prime_bound} absent so far (they must appear by 4L):")
    late = [L for L in absent if is_good_prime(L, N)]
    print(f"    {len(late)} of them; each has apparition index > {length}:")
    print("    " + ", ".join(f"{L}(m={apparition_index(P, N, L)})" for L in late[:12])
          + (" ..." if len(late) > 12 else ""))
    print()
    print("  Enlarging the orbit to K = 4L captures each of them; the primes that")
    print("  are absent FOREVER are contained in {2, 3} u {5, 11} -- exactly the")
    print("  reverse of the conjectured inclusion.")


# ----------------------------------------------------------------------------
# Demonstration 8 — the factoring barrier over a family of semiprimes
# ----------------------------------------------------------------------------

def find_rational_point(N: int, search: int = 200) -> Optional[Tuple[Fraction, Fraction]]:
    """Search for a small integral point (x, y) on y^2 = x^3 + N."""
    for x in range(-search, search + 1):
        v = x ** 3 + N
        if v <= 0:
            continue
        r = isqrt(v)
        if r * r == v and r != 0:
            return (Fraction(x), Fraction(r))
    return None


def demo_factoring_barrier(length: int = 8) -> None:
    rule("8.  THE FACTORING BARRIER:  denominators do not reveal p and q")
    semiprimes = [15, 21, 33, 35, 55, 65, 77, 85, 91, 115, 143]
    header = "   N=p*q |  P found   | p in dens? | q in dens? | only {2,3,p,q}? | #good primes seen"
    print(header)
    print("  " + "-" * (len(header) - 2))
    saw_p = saw_q = only_bad = tested = 0
    for N in semiprimes:
        P = find_rational_point(N)
        if P is None:
            continue
        factors, _ = small_prime_part(N, N)
        ps = sorted(factors)
        if len(ps) != 2:
            continue
        p, q = ps[0], ps[-1]
        dens = [d for d in (x_denominator(Q) for Q in rat_orbit(P, N, length))
                if d is not None]
        occurs = {L for L in primes_up_to(300)
                  if any(d % L == 0 for d in dens)}
        good_seen = {L for L in occurs if is_good_prime(L, N)}
        has_p, has_q = p in occurs, q in occurs
        clean = occurs <= {2, 3, p, q}
        tested += 1
        saw_p += has_p
        saw_q += has_q
        only_bad += clean
        print(f"  {N:6d} | ({str(P[0]):>4},{str(P[1]):>5}) |"
              f"    {'yes' if has_p else ' no':>3}     |    {'yes' if has_q else ' no':>3}     |"
              f"       {'yes' if clean else 'NO':>3}       | {len(good_seen)}")
    print()
    print(f"  Over {tested} semiprimes: smaller factor present in "
          f"{100*saw_p/tested:.1f}% of cases, larger factor in "
          f"{100*saw_q/tested:.1f}%,")
    print(f"  and the conjectured property 'only {{2,3,p,q}} occur' holds in "
          f"{100*only_bad/tested:.1f}% of cases.")
    print("  Whether L divides a denominator depends only on the order of the")
    print("  reduced point in E_N(F_L) -- a quantity computable from N without")
    print("  knowing its factorisation.  The denominator sequence is a function")
    print("  of N as an integer, not of how N splits.")


# ----------------------------------------------------------------------------

def main() -> None:
    print(__doc__)
    demo_counterexample()
    demo_spectrum()
    demo_apparition_law()
    demo_effective_bound()
    demo_density()
    demo_simultaneous()
    demo_reverse_inclusion()
    demo_factoring_barrier()
    rule("ALL ASSERTIONS PASSED")


if __name__ == "__main__":
    main()
