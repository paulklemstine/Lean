"""
Denominators on Mordell curves: the failure of the "only bad primes" conjecture,
the local criteria at the doubling and tripling layers, the exact residue-class
counts, and the information barrier below a bound B.

Curve family:      E_N : y^2 = x^3 + N          (N a nonzero integer)
Discriminant:      Delta(E_N) = -432 * N^2      (bad primes: 2, 3 and the primes of N)

Everything here is exact: rational arithmetic via `fractions.Fraction`, integer
factorisation by trial division, and finite field work by brute force over Z/ell.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import factorial, gcd
from typing import Dict, List, Optional, Sequence, Tuple

# --------------------------------------------------------------------------- #
# Basic integer utilities
# --------------------------------------------------------------------------- #


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin primality test (exact for all 64-bit inputs and beyond)."""
    if n < 2:
        return False
    small_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    for p in small_primes:
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in small_primes:
        z = pow(a, d, n)
        if z in (1, n - 1):
            continue
        for _ in range(s - 1):
            z = z * z % n
            if z == n - 1:
                break
        else:
            return False
    return True


def _pollard_rho(n: int) -> int:
    """Return a nontrivial factor of the composite n (Brent's variant of Pollard's rho)."""
    if n % 2 == 0:
        return 2
    c = 1
    while True:
        x, y, d = 2, 2, 1
        while d == 1:
            x = (x * x + c) % n
            y = (y * y + c) % n
            y = (y * y + c) % n
            d = gcd(abs(x - y), n)
        if d != n:
            return d
        c += 1


def factorize(n: int) -> Dict[int, int]:
    """Prime factorisation of |n| (trial division on small primes, then Pollard rho)."""
    n = abs(n)
    out: Dict[int, int] = {}
    if n <= 1:
        return out
    for d in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        while n % d == 0:
            out[d] = out.get(d, 0) + 1
            n //= d
    stack = [n] if n > 1 else []
    while stack:
        m = stack.pop()
        if m == 1:
            continue
        if is_prime(m):
            out[m] = out.get(m, 0) + 1
            continue
        f = _pollard_rho(m)
        stack.extend([f, m // f])
    return out


def primes_up_to(bound: int) -> List[int]:
    """All primes <= bound, by a simple sieve of Eratosthenes."""
    if bound < 2:
        return []
    sieve = [True] * (bound + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(bound**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, bound + 1, i):
                sieve[j] = False
    return [i for i, ok in enumerate(sieve) if ok]


def bad_primes(nn: int) -> List[int]:
    """The primes dividing Delta(E_N) = -432 N^2, i.e. {2, 3} union primes of N."""
    return sorted({2, 3} | set(factorize(nn)))


# --------------------------------------------------------------------------- #
# The group law on E_N : y^2 = x^3 + N over Q
# --------------------------------------------------------------------------- #

Point = Optional[Tuple[Fraction, Fraction]]  # None is the point at infinity O


def on_curve(nn: int, p: Point) -> bool:
    """Test whether p lies on E_N (the point at infinity always does)."""
    if p is None:
        return True
    x, y = p
    return y * y == x * x * x + nn


def add_points(nn: int, p: Point, q: Point) -> Point:
    """Chord-and-tangent addition on E_N : y^2 = x^3 + N."""
    if p is None:
        return q
    if q is None:
        return p
    x1, y1 = p
    x2, y2 = q
    if x1 == x2 and y1 == -y2:
        return None
    if p == q:
        if y1 == 0:
            return None
        lam = Fraction(3 * x1 * x1, 2 * y1)
    else:
        lam = Fraction(y2 - y1, x2 - x1)
    x3 = lam * lam - x1 - x2
    y3 = lam * (x1 - x3) - y1
    return (x3, y3)


def multiply_point(nn: int, p: Point, k: int) -> Point:
    """Compute k*P by double-and-add."""
    result: Point = None
    base = p
    m = k
    while m > 0:
        if m & 1:
            result = add_points(nn, result, base)
        base = add_points(nn, base, base)
        m >>= 1
    return result


def x_denominator(p: Point) -> int:
    """Denominator of the x-coordinate of a finite point, in lowest terms."""
    assert p is not None, "the point at infinity has no x-coordinate"
    return p[0].denominator


# --------------------------------------------------------------------------- #
# Division-polynomial data at layers 2 and 3
# --------------------------------------------------------------------------- #


def psi3(nn: int, x: int) -> int:
    """Third division polynomial of y^2 = x^3 + N:  psi_3(x) = 3x^4 + 12Nx = 3x(x^3+4N)."""
    return 3 * x**4 + 12 * nn * x


def phi3(nn: int, x: int) -> int:
    """Numerator of x(3P):  phi_3(x) = x^9 - 96Nx^6 + 48N^2x^3 + 64N^3."""
    return x**9 - 96 * nn * x**6 + 48 * nn**2 * x**3 + 64 * nn**3


def double_x(nn: int, x: int, y: int) -> Fraction:
    """x(2P) = (x^4 - 8Nx) / (4y^2) for an integral point (x, y) of E_N."""
    return Fraction(x**4 - 8 * nn * x, 4 * y**2)


def triple_x(nn: int, x: int) -> Fraction:
    """x(3P) = phi_3(x) / psi_3(x)^2 for an integral point with psi_3(x) != 0."""
    return Fraction(phi3(nn, x), psi3(nn, x) ** 2)


# --------------------------------------------------------------------------- #
# Residue-class loci mod ell
# --------------------------------------------------------------------------- #


def vanishing_classes_2(nn: int, ell: int) -> List[int]:
    """V_2(N, ell) = { t in F_ell : t^3 + N = 0 }, the layer-2 producing classes."""
    return [t for t in range(ell) if (t**3 + nn) % ell == 0]


def vanishing_classes_3(nn: int, ell: int) -> List[int]:
    """V_3(N, ell) = { t in F_ell : 3t^4 + 12Nt = 0 }, the layer-3 producing classes."""
    return [t for t in range(ell) if (3 * t**4 + 12 * nn * t) % ell == 0]


# --------------------------------------------------------------------------- #
# Demonstration 1: the counterexample N = 55, P = (9, 28)
# --------------------------------------------------------------------------- #


def demo_counterexample() -> None:
    print("=" * 74)
    print("1.  The counterexample:  N = 55 = 5 * 11,  P = (9, 28) on y^2 = x^3 + 55")
    print("=" * 74)
    nn, x, y = 55, 9, 28
    assert y * y == x**3 + nn
    print(f"    Delta(E_55) = -432 * 55^2 = {-432 * nn**2}")
    print(f"    bad primes  = {bad_primes(nn)}")

    x2 = double_x(nn, x, y)
    print(f"\n    x(2P) = (9^4 - 8*55*9) / (4*28^2) = {x2.numerator}/{x2.denominator}")
    print(f"    denominator {x2.denominator} = {factorize(x2.denominator)}")
    print(f"    7 divides the denominator, and 7 does not divide Delta:"
          f" {x2.denominator % 7 == 0 and (-432 * nn**2) % 7 != 0}")
    print("    ==> the 'only bad primes' conjecture is FALSE.")

    print(f"\n    Mechanism:  y = 28 = 2^2 * 7, and 7 | y forces 7^2 | 4y^2 while")
    print(f"    the numerator x^4 - 8Nx = 2601 = 3^2 * 17^2 is prime to 7.")
    print(f"    Equivalently 9^3 + 55 = 784 = 2^4 * 7^2, so P reduces to a point")
    print(f"    of order 2 modulo 7 and 2P reduces to the identity.")

    x3 = triple_x(nn, x)
    print(f"\n    x(3P) = {x3.numerator}/{x3.denominator}")
    print(f"    psi_3(9) = {psi3(nn, 9)} = {factorize(psi3(nn, 9))}")
    print(f"    denominator factorisation: {factorize(x3.denominator)}")
    print("    the good primes 13 and 73 appear; the bad primes 5 and 11 do not.")


# --------------------------------------------------------------------------- #
# Demonstration 2: the local criteria, checked against the true denominators
# --------------------------------------------------------------------------- #


def demo_criteria(nn: int = 55, x: int = 9, y: int = 28, bound: int = 200) -> None:
    print()
    print("=" * 74)
    print(f"2.  Local criteria at layers 2 and 3 (N = {nn}, P = ({x}, {y}), primes <= {bound})")
    print("=" * 74)
    d2 = double_x(nn, x, y).denominator
    d3 = triple_x(nn, x).denominator
    print("    layer 2:  ell | den x(2P)  <=>  ell | y  <=>  x^3 + N = 0 in F_ell")
    print("    layer 3:  ell | den x(3P)  <=>  ell | psi_3(x) = 3x(x^3 + 4N)")
    print()
    print("    ell   good?   den2?  crit2   den3?  crit3")
    for ell in primes_up_to(bound):
        if ell < 5 or nn % ell == 0:
            continue
        c2 = (y % ell == 0)
        c3 = (psi3(nn, x) % ell == 0)
        a2 = (d2 % ell == 0)
        a3 = (d3 % ell == 0)
        assert a2 == c2 and a3 == c3, f"criterion failed at ell = {ell}"
        if a2 or a3:
            print(f"    {ell:>4}   good     {str(a2):>5}  {str(c2):>5}   "
                  f"{str(a3):>5}  {str(c3):>5}")
    print("    (all primes 5 <= ell <= %d of good reduction verified; only the" % bound)
    print("     denominator-active ones are listed)")


# --------------------------------------------------------------------------- #
# Demonstration 3: the residue-class counting laws
# --------------------------------------------------------------------------- #


def demo_counting(bound: int = 60) -> None:
    print()
    print("=" * 74)
    print("3.  Counting the denominator-producing residue classes")
    print("=" * 74)
    print("    supersingular ell = 2 mod 3 : #V2 = 1 and #V3 = 2, always")
    print("    ordinary      ell = 1 mod 3 : #V2 in {0,3} and #V3 in {1,4}")
    print()
    print("    ell  ell%3   #V2(55)  #V3(55)   sum_c #V2 = ell   sum_c #V3 = 2ell-1")
    for ell in primes_up_to(bound):
        if ell < 5:
            continue
        v2 = len(vanishing_classes_2(55, ell))
        v3 = len(vanishing_classes_3(55, ell))
        s2 = sum(len(vanishing_classes_2(c, ell)) for c in range(ell))
        s3 = sum(len(vanishing_classes_3(c, ell)) for c in range(ell))
        assert s2 == ell and s3 == 2 * ell - 1
        if ell % 3 == 2:
            assert v2 == 1 and (55 % ell == 0 or v3 == 2)
        elif 55 % ell != 0:
            assert v2 in (0, 3) and v3 in (1, 4)
        print(f"    {ell:>3}    {ell % 3}       {v2}        {v3}          "
              f"{s2:>4} = {ell:<4}      {s3:>4} = {2 * ell - 1}")
    print()
    print("    N = 55:  V2 mod 7  =", vanishing_classes_2(55, 7),
          " (and 9 = 2 mod 7, hence 7 is active)")
    print("    N = 55:  V2 mod 13 =", vanishing_classes_2(55, 13),
          " (13 is blind at layer 2)")
    print("    N = 55:  V3 mod 13 =", vanishing_classes_3(55, 13),
          " (but active at layer 3: 9 = 9 mod 13)")


def demo_active_densities(bound: int = 100) -> None:
    print()
    print("=" * 74)
    print("4.  How many residues N mod ell are denominator-active?")
    print("=" * 74)
    print("    layer 2, ell = 2 mod 3 : all ell residues")
    print("    layer 2, ell = 1 mod 3 : exactly (ell + 2)/3 residues")
    print("    layer 3               : all ell residues, for every prime")
    print()
    print("    ell  ell%3   active2   predicted   density2      active3")
    for ell in primes_up_to(bound):
        if ell < 5:
            continue
        a2 = sum(1 for c in range(ell) if vanishing_classes_2(c, ell))
        a3 = sum(1 for c in range(ell) if vanishing_classes_3(c, ell))
        pred = ell if ell % 3 == 2 else (ell + 2) // 3
        assert a2 == pred and a3 == ell
        print(f"    {ell:>3}    {ell % 3}      {a2:>5}      {pred:>5}     "
              f"{a2 / ell:0.4f}        {a3:>4}")


# --------------------------------------------------------------------------- #
# Demonstration 5: every prime >= 5 occurs at layer 3
# --------------------------------------------------------------------------- #


def demo_realisation(primes: Sequence[int] = (5, 7, 11, 13, 17, 19, 23, 29, 31)) -> None:
    print()
    print("=" * 74)
    print("5.  Every prime ell >= 5 is a good-reduction denominator prime")
    print("      witness:  N = 1 - ell^3,  P = (ell, 1),  layer 3")
    print("=" * 74)
    print("    ell        N = 1 - ell^3   ell | Delta?   ell | den x(3P)?")
    for ell in primes:
        nn = 1 - ell**3
        assert 1 == ell**3 + nn
        divides_delta = (-432 * nn**2) % ell == 0
        d3 = triple_x(nn, ell).denominator
        assert not divides_delta and d3 % ell == 0
        print(f"    {ell:>3}   {nn:>16}        {str(divides_delta):>5}"
              f"            {str(d3 % ell == 0):>5}")


# --------------------------------------------------------------------------- #
# Demonstration 6: the semiprime survey
# --------------------------------------------------------------------------- #


def find_integral_point(nn: int, x_bound: int = 400) -> Optional[Tuple[int, int]]:
    """Search for a small integral point (x, y) on E_N with y != 0."""
    for x in range(-x_bound, x_bound + 1):
        v = x**3 + nn
        if v <= 0:
            continue
        r = int(round(v ** 0.5))
        for cand in (r - 1, r, r + 1):
            if cand > 0 and cand * cand == v:
                return (x, cand)
    return None


def demo_survey(layers: int = 4) -> None:
    print()
    print("=" * 74)
    print("6.  Survey of semiprimes: which primes actually show up in denominators?")
    print("=" * 74)
    semiprimes = [(5, 11), (3, 7), (5, 7), (7, 11), (3, 11), (5, 13),
                  (7, 13), (3, 13), (11, 13), (5, 17), (3, 17)]
    print("    N=pq   P=(x,y)     denominator primes of x(nP), 2 <= n <= %d" % layers)
    hits_p = hits_q = only_bad = total = 0
    for p, q in semiprimes:
        nn = p * q
        pt = find_integral_point(nn)
        if pt is None:
            continue
        total += 1
        x, y = pt
        seen: set[int] = set()
        base: Point = (Fraction(x), Fraction(y))
        for n in range(2, layers + 1):
            r = multiply_point(nn, base, n)
            if r is None:
                continue
            seen |= set(factorize(x_denominator(r)))
        if p in seen:
            hits_p += 1
        if q in seen:
            hits_q += 1
        if seen <= {2, 3, p, q}:
            only_bad += 1
        print(f"    {nn:>4}   ({x:>3},{y:>4})   {sorted(seen)}")
    print()
    print(f"    smaller factor p appears : {hits_p}/{total} = {100 * hits_p / total:0.1f}%")
    print(f"    larger  factor q appears : {hits_q}/{total} = {100 * hits_q / total:0.1f}%")
    print(f"    only {{2,3,p,q}} appear     : {only_bad}/{total} = "
          f"{100 * only_bad / total:0.1f}%")


# --------------------------------------------------------------------------- #
# Demonstration 7: the information barrier
# --------------------------------------------------------------------------- #


def barrier_twin(nn: int, bound: int, search_limit: int = 10_000_000) -> Optional[int]:
    """
    Find a prime M > N with M = N (mod B!), so that the layer-2 and layer-3
    criteria of E_M agree with those of E_N at every prime ell <= B.
    """
    modulus = factorial(bound)
    if gcd(nn, modulus) != 1:
        return None
    m = nn + modulus
    while m < nn + search_limit * modulus:
        if is_prime(m):
            return m
        m += modulus
    return None


def demo_barrier(nn: int = 17 * 19, bound: int = 13) -> None:
    print()
    print("=" * 74)
    print(f"7.  The information barrier at B = {bound}")
    print("=" * 74)
    m = barrier_twin(nn, bound)
    assert m is not None and is_prime(m)
    print(f"    N = {nn} = {factorize(nn)}  (a semiprime, both factors > B)")
    print(f"    M = {m}  (prime),  M = N mod {bound}! = {factorial(bound)}")
    print()
    print("    ell   V2(N)                V2(M)                V3(N) = V3(M)?")
    for ell in primes_up_to(bound):
        v2n, v2m = vanishing_classes_2(nn, ell), vanishing_classes_2(m, ell)
        v3n, v3m = vanishing_classes_3(nn, ell), vanishing_classes_3(m, ell)
        assert v2n == v2m and v3n == v3m
        print(f"    {ell:>3}   {str(v2n):<20} {str(v2m):<20} {v3n == v3m}")
    print("    every criterion below B agrees: the data cannot tell the semiprime")
    print("    N apart from the prime M, let alone reveal the factors of N.")

    print()
    print("    A larger example:")
    nn2 = 10007 * 10009
    b2 = 11
    m2 = barrier_twin(nn2, b2)
    assert m2 is not None
    print(f"    N = 10007 * 10009 = {nn2},   B = {b2}")
    print(f"    M = {m2} is prime and congruent to N modulo {b2}! = {factorial(b2)}")
    agree = all(vanishing_classes_2(nn2, ell) == vanishing_classes_2(m2, ell)
                and vanishing_classes_3(nn2, ell) == vanishing_classes_3(m2, ell)
                for ell in primes_up_to(b2))
    print(f"    all layer-2 and layer-3 loci at primes <= {b2} agree: {agree}")


# --------------------------------------------------------------------------- #


def main() -> None:
    demo_counterexample()
    demo_criteria()
    demo_counting()
    demo_active_densities()
    demo_realisation()
    demo_survey()
    demo_barrier()
    print()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
