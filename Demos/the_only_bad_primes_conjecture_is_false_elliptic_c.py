"""
Denominators of rational points on Mordell curves y^2 = x^3 + N.

This self-contained script demonstrates, numerically and exactly (no floating point
in the arithmetic), every result of the accompanying paper:

  1.  The counterexample to the "only bad primes" conjecture:
      on E_55 : y^2 = x^3 + 55 with P = (9, 28),
          x(2P) = 2601/3136,  3136 = 2^6 * 7^2,
      and 7 does not divide the discriminant  Delta = -432 * 55^2,
      so the good prime 7 divides a denominator.

  2.  The square-denominator law:  den x = e^2 and den y = e^3 for a single
      integer e, for every rational point of every integral Mordell curve.

  3.  The complete local law at a good prime l >= 5 with l not dividing N:
          l | den x(2P)  <=>  l | den x(P)  or  l | num y(P).

  4.  The exact filtration law:
          v_l(den x(2P)) = v_l(den x(P))       for odd l dividing den x(P),
          v_2(den x(2P)) = v_2(den x(P)) + 2.

  5.  The apparition index law: the set of k with l | den x(kP) is exactly the
      set of multiples of one natural number m(l, P), which at a good prime
      equals the order of the reduced point in E_N(F_l).
      On E_55 with P = (9,28):  m(7) = 2,  m(13) = 3.

  6.  The 2-adic growth law forcing an infinite orbit, hence infinite E_55(Q).

  7.  A survey over semiprime Mordell curves showing that the "only bad primes"
      property essentially never holds.

Run with:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, List, Optional, Set, Tuple

# A rational affine point, or None for the point at infinity.
Point = Optional[Tuple[Fraction, Fraction]]


# ---------------------------------------------------------------------------
# Exact group law on y^2 = x^3 + N over Q
# ---------------------------------------------------------------------------


def on_curve(P: Point, N: int) -> bool:
    """Test whether P lies on y^2 = x^3 + N (the point at infinity always does)."""
    if P is None:
        return True
    x, y = P
    return y * y == x * x * x + N


def add(P: Point, Q: Point, N: int) -> Point:
    """Chord-and-tangent addition on y^2 = x^3 + N, exact rational arithmetic."""
    if P is None:
        return Q
    if Q is None:
        return P
    x1, y1 = P
    x2, y2 = Q
    if x1 == x2 and y1 == -y2:
        return None                       # P + (-P) = O
    if P == Q:
        if y1 == 0:
            return None                   # 2-torsion
        lam = (3 * x1 * x1) / (2 * y1)    # tangent
    else:
        lam = (y2 - y1) / (x2 - x1)       # chord
    x3 = lam * lam - x1 - x2
    y3 = lam * (x1 - x3) - y1
    return (x3, y3)


def multiple(P: Point, k: int, N: int) -> Point:
    """Compute k * P by double-and-add; negative k allowed."""
    if k < 0:
        R = multiple(P, -k, N)
        return None if R is None else (R[0], -R[1])
    result: Point = None
    base = P
    while k > 0:
        if k & 1:
            result = add(result, base, N)
        base = add(base, base, N)
        k >>= 1
        if base is None and k > 0:
            break
    return result


def orbit(P: Point, n: int, N: int) -> List[Point]:
    """Return [P, 2P, ..., nP] by repeated addition."""
    out: List[Point] = []
    Q: Point = P
    for _ in range(n):
        out.append(Q)
        Q = add(Q, P, N)
    return out


# ---------------------------------------------------------------------------
# Elementary number theory helpers
# ---------------------------------------------------------------------------


def factor(n: int, trial_bound: int = 200_000) -> Dict[int, int]:
    """Trial-division factorization; a leftover cofactor is reported as one 'prime'."""
    n = abs(n)
    f: Dict[int, int] = {}
    d = 2
    while d * d <= n and d < trial_bound:
        while n % d == 0:
            f[d] = f.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        f[n] = f.get(n, 0) + 1
    return f


def valuation(n: int, ell: int) -> int:
    """The ell-adic valuation v_ell(n) of a nonzero integer n."""
    v = 0
    n = abs(n)
    while n % ell == 0:
        n //= ell
        v += 1
    return v


def is_square(n: int) -> bool:
    r = int(round(n ** 0.5))
    for c in (r - 1, r, r + 1):
        if c >= 0 and c * c == n:
            return True
    return False


def integer_sqrt(n: int) -> int:
    r = int(round(n ** 0.5))
    for c in (r - 1, r, r + 1):
        if c >= 0 and c * c == n:
            return c
    raise ValueError(f"{n} is not a perfect square")


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True


def bad_primes(N: int) -> Set[int]:
    """Primes dividing Delta = -432 N^2, i.e. {2, 3} together with the primes of N."""
    return {2, 3} | set(factor(N).keys())


def find_small_point(N: int, bound: int = 200) -> Point:
    """Search for a rational (in fact integral) point with |x| <= bound."""
    for x in range(-bound, bound + 1):
        s = x ** 3 + N
        if s <= 0:
            continue
        if is_square(s):
            return (Fraction(x), Fraction(integer_sqrt(s)))
    return None


# ---------------------------------------------------------------------------
# Reduction modulo a good prime, and the apparition index
# ---------------------------------------------------------------------------


def reduce_point(P: Point, ell: int) -> Optional[Tuple[int, int]]:
    """Reduce an affine rational point mod ell; None means it hits infinity."""
    if P is None:
        return None
    x, y = P
    if x.denominator % ell == 0 or y.denominator % ell == 0:
        return None
    inv_dx = pow(x.denominator % ell, ell - 2, ell)
    inv_dy = pow(y.denominator % ell, ell - 2, ell)
    return ((x.numerator % ell) * inv_dx % ell, (y.numerator % ell) * inv_dy % ell)


def add_mod(P: Optional[Tuple[int, int]], Q: Optional[Tuple[int, int]],
            N: int, ell: int) -> Optional[Tuple[int, int]]:
    """Group law of y^2 = x^3 + N over the field with ell elements."""
    if P is None:
        return Q
    if Q is None:
        return P
    x1, y1 = P
    x2, y2 = Q
    if x1 == x2 and (y1 + y2) % ell == 0:
        return None
    if P == Q:
        lam = 3 * x1 * x1 % ell * pow(2 * y1 % ell, ell - 2, ell) % ell
    else:
        lam = (y2 - y1) % ell * pow((x2 - x1) % ell, ell - 2, ell) % ell
    x3 = (lam * lam - x1 - x2) % ell
    y3 = (lam * (x1 - x3) - y1) % ell
    return (x3, y3)


def order_mod(P: Point, N: int, ell: int) -> int:
    """Order of the reduction of P in E_N(F_ell); equals the apparition index."""
    R = reduce_point(P, ell)
    if R is None:
        return 1
    S = R
    k = 1
    while S is not None:
        S = add_mod(S, R, N, ell)
        k += 1
        if k > 4 * ell:                    # far beyond the Hasse bound: safety net
            raise RuntimeError("order computation failed")
    return k


def apparition_index_by_orbit(P: Point, N: int, ell: int, search: int = 12) -> Optional[int]:
    """Smallest k >= 1 with ell | den x(kP), found by walking the orbit."""
    Q: Point = P
    for k in range(1, search + 1):
        if Q is None:
            return k
        if Q[0].denominator % ell == 0:
            return k
        Q = add(Q, P, N)
    return None


# ---------------------------------------------------------------------------
# The individual demonstrations
# ---------------------------------------------------------------------------


def demo_counterexample() -> None:
    print("=" * 78)
    print("1.  THE COUNTEREXAMPLE:  a good prime inside a denominator")
    print("=" * 78)
    N = 55
    P = (Fraction(9), Fraction(28))
    assert on_curve(P, N)
    Delta = -432 * N * N
    P2 = add(P, P, N)
    assert P2 is not None
    x2 = P2[0]
    print(f"  curve      E_{N} : y^2 = x^3 + {N}")
    print(f"  point      P  = (9, 28),   28^2 = {28**2} = 9^3 + 55 = {9**3+55}")
    print(f"  discriminant Delta = -432 * {N}^2 = {Delta} = {factor(Delta)}")
    print(f"  bad primes  {sorted(bad_primes(N))}")
    print(f"  x(2P)      = {x2}")
    print(f"  den x(2P)  = {x2.denominator} = {factor(x2.denominator)}")
    assert x2 == Fraction(2601, 3136)
    assert x2.denominator == 2 ** 6 * 7 ** 2
    assert Delta % 7 != 0
    print("  ==> 7 divides the denominator, and 7 does NOT divide Delta:")
    print("      7 is a prime of GOOD reduction.  The conjecture is false.")

    P3 = add(P2, P, N)
    assert P3 is not None
    x3 = P3[0]
    print()
    print(f"  x(3P)      = {x3}")
    print(f"  den x(3P)  = {x3.denominator} = {factor(x3.denominator)}"
          f" = {integer_sqrt(x3.denominator)}^2")
    dp = set(factor(x3.denominator))
    assert 13 in dp and 73 in dp and 5 not in dp and 11 not in dp
    print("  ==> good primes 13 and 73 are present; neither 5 nor 11 is.")
    print("      Failure in BOTH directions at one multiple of one point.")
    print()


def demo_square_law() -> None:
    print("=" * 78)
    print("2.  THE SQUARE-DENOMINATOR LAW:  den x = e^2,  den y = e^3")
    print("=" * 78)
    cases = [(55, (9, 28)), (35, (1, 6)), (17, (4, 9)), (-2, (3, 5)), (1, (2, 3))]
    print(f"  {'N':>4} {'n':>2}  {'den x':>28}  {'e':>14}  den y = e^3 ?")
    for N, (px, py) in cases:
        P = (Fraction(px), Fraction(py))
        assert on_curve(P, N)
        for n, Q in enumerate(orbit(P, 4, N), start=1):
            if Q is None:
                continue
            dx, dy = Q[0].denominator, Q[1].denominator
            assert is_square(dx), "den x must be a perfect square"
            e = integer_sqrt(dx)
            assert dy == e ** 3, "den y must be the cube of the same e"
            print(f"  {N:>4} {n:>2}  {dx:>28}  {e:>14}  {'yes'}")
    print("  ==> in every case den x is a perfect square e^2 and den y = e^3,")
    print("      so every prime occurs to an EVEN exponent in den x.")
    print("      Consequence: at most sqrt(X)+1 integers below X are achievable")
    print("      denominators, a set of density zero.")
    print()


def demo_local_law() -> None:
    print("=" * 78)
    print("3.  THE COMPLETE LOCAL LAW AT A GOOD PRIME  l >= 5,  l not dividing N")
    print("=" * 78)
    N = 55
    P = (Fraction(9), Fraction(28))
    primes = [7, 13, 17, 19, 23, 29, 31, 37, 41, 43, 73]
    print(f"  {'l':>4} {'n':>3}  {'l|den x(P)':>11} {'l|num y(P)':>11}"
          f" {'predicted':>10} {'observed':>9}")
    for ell in primes:
        if N % ell == 0 or ell < 5:
            continue
        for n, Q in enumerate(orbit(P, 6, N), start=1):
            if Q is None:
                continue
            R = add(Q, Q, N)
            if R is None:
                continue
            lhs_a = Q[0].denominator % ell == 0
            lhs_b = Q[1].numerator % ell == 0
            predicted = lhs_a or lhs_b
            observed = R[0].denominator % ell == 0
            assert predicted == observed, (ell, n)
            if predicted:
                print(f"  {ell:>4} {n:>3}  {str(lhs_a):>11} {str(lhs_b):>11}"
                      f" {str(predicted):>10} {str(observed):>9}")
    print("  ==> in every tested case (all l, all n, both outcomes) the law")
    print("      l | den x(2P)  <=>  l | den x(P) or l | num y(P)  holds.")
    print("      The criterion never mentions the factorization of N.")
    print()


def demo_filtration() -> None:
    print("=" * 78)
    print("4.  THE EXACT FILTRATION LAW:  odd primes freeze, the prime 2 grows by 2")
    print("=" * 78)
    N = 55
    P = (Fraction(9), Fraction(28))
    Q = add(P, P, N)                       # 2P has even denominator
    assert Q is not None
    print("  sub-orbit 2P, 4P, 8P, 16P on E_55:")
    print(f"  {'k':>2} {'v_2(den x)':>11} {'v_7(den x)':>11}")
    R: Point = Q
    v2_prev = None
    for k in range(0, 4):
        assert R is not None
        d = R[0].denominator
        v2, v7 = valuation(d, 2), valuation(d, 7)
        print(f"  {k:>2} {v2:>11} {v7:>11}")
        if v2_prev is not None:
            assert v2 == v2_prev + 2, "v_2 must grow by exactly 2 per doubling"
        assert v7 == 2, "v_7 must be constant along the 2-power sub-orbit"
        v2_prev = v2
        R = add(R, R, N)
    print("  ==> v_2 increases by exactly 2 at each doubling (6, 8, 10, 12),")
    print("      while the odd prime 7 keeps its exponent 2 forever.")
    print()


def demo_apparition_index() -> None:
    print("=" * 78)
    print("5.  THE APPARITION INDEX LAW")
    print("=" * 78)
    N = 55
    P = (Fraction(9), Fraction(28))
    print("  v_l(den x(nP)) for the first multiples of P = (9,28) on E_55:")
    header = "   n |" + "".join(f"{ell:>6}" for ell in (2, 3, 5, 7, 13, 17, 73))
    print(header)
    print("  " + "-" * (len(header) - 2))
    for n, Q in enumerate(orbit(P, 7, N), start=1):
        assert Q is not None
        d = Q[0].denominator
        row = f"  {n:>2} |" + "".join(f"{valuation(d, ell):>6}"
                                      for ell in (2, 3, 5, 7, 13, 17, 73))
        print(row)
    print()
    print("  Support of each row is a set of multiples of one index m(l):")
    print(f"  {'l':>5} {'m by orbit search':>19} {'order of reduction':>20} {'good?':>7}")
    for ell in (7, 13, 17, 73, 19, 23, 29):
        m_orbit = apparition_index_by_orbit(P, N, ell, search=12)
        m_red = order_mod(P, N, ell) if ell not in bad_primes(N) else None
        good = ell not in bad_primes(N)
        if m_orbit is not None and m_red is not None:
            assert m_orbit == m_red, (ell, m_orbit, m_red)
        print(f"  {ell:>5} {str(m_orbit):>19} {str(m_red):>20} {str(good):>7}")
    print("  ==> the two computations agree: the apparition index equals the order")
    print("      of the reduced point in E_N(F_l).  In particular m(7) = 2 and")
    print("      m(13) = 3, so 7 divides den x(kP) exactly for even k, and 13")
    print("      exactly for k divisible by 3.")
    print()
    # The index law as an iff, checked over a range of k (both directions).
    for ell, m in ((7, 2), (13, 3)):
        for k in range(1, 10):
            Q = multiple(P, k, N)
            assert Q is not None
            divides = Q[0].denominator % ell == 0
            assert divides == (k % m == 0), (ell, k)
        print(f"  verified for 1 <= k <= 9:  {ell} | den x(kP)  <=>  {m} | k")
    print()


def demo_infinite_orbit() -> None:
    print("=" * 78)
    print("6.  UNBOUNDED 2-ADIC GROWTH FORCES AN INFINITE ORBIT")
    print("=" * 78)
    N = 55
    P = (Fraction(9), Fraction(28))
    Q = add(P, P, N)
    assert Q is not None
    v0 = valuation(Q[0].denominator, 2)
    seen = set()
    R: Point = Q
    for k in range(0, 5):
        assert R is not None
        v = valuation(R[0].denominator, 2)
        assert v == v0 + 2 * k
        assert R[0] not in seen, "the points must be pairwise distinct"
        seen.add(R[0])
        R = add(R, R, N)
    print(f"  v_2(den x(2^k * 2P)) = {v0} + 2k for k = 0..4:  strictly increasing,")
    print("  hence the points 2^k * 2P are pairwise distinct.")
    print("  ==> (9,28) has INFINITE ORDER and E_55(Q) is an infinite group,")
    print("      proved by watching denominators, with no descent or heights.")
    print("  ==> infinitely many distinct rational points of E_55 carry the")
    print("      good prime 7 in the denominator of their x-coordinate.")
    print()


def demo_semiprime_survey() -> None:
    print("=" * 78)
    print("7.  SURVEY OVER SEMIPRIME MORDELL CURVES  N = p q")
    print("=" * 78)
    pairs: List[Tuple[int, int]] = [
        (3, 5), (5, 7), (5, 11), (3, 7), (7, 11), (3, 11),
        (5, 13), (7, 13), (3, 13), (11, 13), (5, 17),
    ]
    n_multiples = 6
    tested = p_hits = q_hits = only_bad = 0
    print(f"  {'N':>5} {'p':>3} {'q':>3} {'point':>14}  denominator primes (first"
          f" {n_multiples} multiples)")
    for p, q in pairs:
        N = p * q
        P = find_small_point(N)
        if P is None:
            print(f"  {N:>5} {p:>3} {q:>3}   (no small rational point found)")
            continue
        tested += 1
        primes: Set[int] = set()
        for Q in orbit(P, n_multiples, N):
            if Q is None:
                continue
            primes |= set(factor(Q[0].denominator).keys())
        shown = sorted(x for x in primes if x < 10_000)
        p_in, q_in = p in primes, q in primes
        only = primes <= {2, 3, p, q}
        p_hits += int(p_in)
        q_hits += int(q_in)
        only_bad += int(only)
        pt = f"({P[0]},{P[1]})"
        print(f"  {N:>5} {p:>3} {q:>3} {pt:>14}  {shown}"
              f"{' ...' if len(shown) < len(primes) else ''}")
        print(f"        p present: {p_in};  q present: {q_in};"
              f"  only {{2,3,p,q}}: {only}")
    print()
    print(f"  curves tested                            : {tested}")
    print(f"  'only bad primes' held                   : {only_bad}"
          f"  ({100.0 * only_bad / tested:.1f}%)")
    print(f"  smaller factor p appeared                : {p_hits}"
          f"  ({100.0 * p_hits / tested:.1f}%)")
    print(f"  larger  factor q appeared                : {q_hits}"
          f"  ({100.0 * q_hits / tested:.1f}%)")
    print("  ==> denominators do not reveal the factorization of N: they are")
    print("      governed by the order of the reduced point in E_N(F_l), which")
    print("      is blind to how N factors.")
    print()


def main() -> None:
    print()
    print("DENOMINATORS OF RATIONAL POINTS ON MORDELL CURVES  y^2 = x^3 + N")
    print("The 'only bad primes' conjecture, its refutation, and the laws that"
          " replace it")
    print()
    demo_counterexample()
    demo_square_law()
    demo_local_law()
    demo_filtration()
    demo_apparition_index()
    demo_infinite_orbit()
    demo_semiprime_survey()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
