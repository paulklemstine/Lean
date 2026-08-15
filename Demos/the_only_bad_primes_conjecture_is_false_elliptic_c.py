"""
Denominators on Mordell curves E_N : y^2 = x^3 + N
==================================================

Numerical companion to "Good Primes Rule the Denominators".

Everything here is exact rational arithmetic on the curve

        E_N : y^2 = x^3 + N ,        Delta(E_N) = -432 N^2 ,

with the chord-and-tangent group law over Q.  The script demonstrates, by
explicit computation, the four statements that the accompanying paper proves:

  (1) COUNTEREXAMPLE.  On E_55 with P = (9, 28),
          x(2P) = 2601/3136,  3136 = 2^6 * 7^2,
      so the good prime 7 (which does not divide Delta = -432*55^2) occurs in a
      denominator.  The "only bad primes" conjecture is false.

  (2) MECHANISM.  A prime l of good reduction divides den x(nP) exactly when
      nP reduces to the identity of E_N(F_l).  The script checks this
      equivalence prime by prime.

  (3) ANTI-FACTORING LAW.  For odd squarefree N and any integral point P, no
      prime factor of N ever divides den x(2^k P).  The script follows doubling
      orbits and confirms gcd(den, N) = 1 at every step.

  (4) UNBOUNDED FAMILY.  N(l,t) = 4 l^2 t^2 - 1 = (2lt-1)(2lt+1) with
      P = (1, 2lt): the good prime l divides den x(2P) while neither factor of
      N does.  Includes the genuine semiprimes 899 = 29*31, 1763 = 41*43 and
      39203 = 197*199.

Pure standard library (fractions, math, typing).  Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd
from typing import Dict, List, Optional, Tuple

# A rational affine point, or None for the point at infinity O.
Point = Optional[Tuple[Fraction, Fraction]]


# ----------------------------------------------------------------------
# Elementary number theory helpers
# ----------------------------------------------------------------------
def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin primality test (valid well beyond 2^64)."""
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


def _pollard_rho(n: int) -> int:
    """A nontrivial factor of a composite odd n, by Pollard's rho (Brent)."""
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
    """Factorization of |n| (n != 0): trial division, then Pollard rho.

    Denominators of x-coordinates on an elliptic curve are perfect squares,
    which the caller can exploit; here we simply handle general integers.
    """
    n = abs(n)
    factors: Dict[int, int] = {}
    for d in [2] + list(range(3, 100000, 2)):
        if d * d > n:
            break
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
    stack = [n] if n > 1 else []
    while stack:
        m = stack.pop()
        if m == 1:
            continue
        if is_prime(m):
            factors[m] = factors.get(m, 0) + 1
            continue
        f = _pollard_rho(m)
        stack += [f, m // f]
    return factors


def pretty_factorization(n: int) -> str:
    """Render n as a product of prime powers, e.g. 3136 -> '2^6 * 7^2'."""
    if n in (0, 1):
        return str(n)
    sign = "-" if n < 0 else ""
    parts = [f"{p}^{e}" if e > 1 else f"{p}" for p, e in sorted(factorize(n).items())]
    return sign + " * ".join(parts)


# ----------------------------------------------------------------------
# The group law on E_N : y^2 = x^3 + N over Q
# ----------------------------------------------------------------------
def on_curve(P: Point, N: int) -> bool:
    """Is P a point of E_N(Q)?  The point at infinity always is."""
    if P is None:
        return True
    x, y = P
    return y * y == x * x * x + N


def negate(P: Point) -> Point:
    """The inverse -P in the group E_N(Q)."""
    if P is None:
        return None
    x, y = P
    return (x, -y)


def add(P: Point, Q: Point, N: int) -> Point:
    """Chord-and-tangent addition on E_N : y^2 = x^3 + N."""
    if P is None:
        return Q
    if Q is None:
        return P
    x1, y1 = P
    x2, y2 = Q
    if x1 == x2 and y1 == -y2:
        return None
    if P == Q:
        if y1 == 0:                       # 2-torsion: the tangent is vertical
            return None
        lam = (3 * x1 * x1) / (2 * y1)    # d/dx of x^3 + N is 3x^2
    else:
        lam = (y2 - y1) / (x2 - x1)
    x3 = lam * lam - x1 - x2
    y3 = lam * (x1 - x3) - y1
    return (x3, y3)


def double(P: Point, N: int) -> Point:
    """2P, computed by the tangent line."""
    return add(P, P, N)


def smul(n: int, P: Point, N: int) -> Point:
    """n * P by double-and-add (n >= 0)."""
    R: Point = None
    Q: Point = P
    while n > 0:
        if n & 1:
            R = add(R, Q, N)
        Q = double(Q, N)
        n >>= 1
    return R


def double_x_closed_form(x: Fraction, y: Fraction, N: int) -> Fraction:
    """x(2P) = (x^4 - 8 N x) / (4 y^2), the duplication formula for E_N."""
    return (x ** 4 - 8 * N * x) / (4 * y * y)


# ----------------------------------------------------------------------
# Reduction mod a prime of good reduction
# ----------------------------------------------------------------------
def reduces_to_identity(P: Point, l: int) -> bool:
    """Does the affine rational point P reduce to O in E_N(F_l)?

    In the coprime parametrisation x = a/e^2, y = b/e^3, reduction to the
    identity means exactly l | e, i.e. l divides the denominator of x.
    """
    if P is None:
        return True
    x, _ = P
    return x.denominator % l == 0


def curve_order_mod_l(N: int, l: int) -> int:
    """#E_N(F_l) by brute-force point count (l small)."""
    squares: Dict[int, List[int]] = {}
    for y in range(l):
        squares.setdefault((y * y) % l, []).append(y)
    total = 1  # the point at infinity
    for x in range(l):
        rhs = (x * x * x + N) % l
        total += len(squares.get(rhs, []))
    return total


# ----------------------------------------------------------------------
# (1) The counterexample N = 55
# ----------------------------------------------------------------------
def demo_counterexample() -> None:
    print("=" * 72)
    print("(1)  THE COUNTEREXAMPLE:  N = 55 = 5 * 11,  P = (9, 28)")
    print("=" * 72)
    N = 55
    P: Point = (Fraction(9), Fraction(28))
    assert on_curve(P, N), "P must lie on E_55"
    print(f"  Discriminant  Delta = -432 * {N}^2 = {-432 * N ** 2}")
    print(f"  Bad primes (divisors of Delta): "
          f"{sorted(factorize(-432 * N ** 2))}")
    print()
    Q = double(P, N)
    assert Q is not None
    x2, y2 = Q
    closed = double_x_closed_form(P[0], P[1], N)
    assert closed == x2, "duplication formula must agree with the group law"
    print(f"  x(2P) = (9^4 - 8*55*9) / (4*(9^3 + 55)) = {x2}")
    print(f"  den x(2P) = {x2.denominator} = {pretty_factorization(x2.denominator)}")
    print("  --> the prime 7 divides the denominator, and 7 does NOT divide Delta.")
    print("      7 is a prime of GOOD reduction.  The conjecture is refuted.")
    print()
    R: Point = P
    print("  Denominator support along the orbit n*P:")
    for n in range(1, 6):
        R = smul(n, P, N)
        if R is None:
            print(f"    n = {n}: point at infinity")
            continue
        d = R[0].denominator
        print(f"    n = {n}: den x({n}P) = {d}"
              f"{'' if d == 1 else ' = ' + pretty_factorization(d)}")
    print()


# ----------------------------------------------------------------------
# (2) The mechanism: denominator primes = primes of reduction to O
# ----------------------------------------------------------------------
def add_mod_l(P: Optional[Tuple[int, int]], Q: Optional[Tuple[int, int]],
              N: int, l: int) -> Optional[Tuple[int, int]]:
    """Chord-and-tangent addition in E_N(F_l), l a prime of good reduction."""
    if P is None:
        return Q
    if Q is None:
        return P
    x1, y1 = P
    x2, y2 = Q
    if x1 == x2 and (y1 + y2) % l == 0:
        return None
    if P == Q:
        lam = 3 * x1 * x1 % l * pow(2 * y1 % l, -1, l) % l
    else:
        lam = (y2 - y1) % l * pow((x2 - x1) % l, -1, l) % l
    x3 = (lam * lam - x1 - x2) % l
    y3 = (lam * (x1 - x3) - y1) % l
    return (x3, y3)


def order_mod_l(x0: int, y0: int, N: int, l: int) -> int:
    """The order of the reduction of the integral point (x0, y0) in E_N(F_l)."""
    base = (x0 % l, y0 % l)
    R: Optional[Tuple[int, int]] = base
    n = 1
    while R is not None:
        R = add_mod_l(R, base, N, l)
        n += 1
    return n


def demo_mechanism(N: int = 55, x0: int = 9, y0: int = 28, nmax: int = 5,
                   lmax: int = 200) -> None:
    print("=" * 72)
    print(f"(2)  THE MECHANISM:  l | den x(nP)  <=>  nP = O in E_{N}(F_l)")
    print("=" * 72)
    P: Point = (Fraction(x0), Fraction(y0))
    assert on_curve(P, N)
    bad = set(factorize(-432 * N ** 2))
    for n in range(1, nmax + 1):
        R = smul(n, P, N)
        if R is None:
            continue
        den = R[0].denominator
        primes = sorted(factorize(den)) if den > 1 else []
        good = [l for l in primes if l not in bad]
        print(f"  n = {n}: denominator primes {primes}"
              f"   good ones: {good if good else '(none)'}")
        for l in good:
            assert reduces_to_identity(R, l)
            if l > 10 ** 5:      # brute-force point counting is too slow here
                print(f"       l = {l}: a good prime; the reduction of P mod l"
                      f" has order dividing {n} (point count skipped)")
                continue
            m = order_mod_l(x0, y0, N, l)
            group = curve_order_mod_l(N, l)
            assert n % m == 0, "the order mod l must divide n"
            print(f"       l = {l}: #E_{N}(F_{l}) = {group}, order of P mod "
                  f"{l} is {m}, and {m} | {n} -- verified")
    print()
    print("  Converse direction, computed inside the finite fields: for every")
    print(f"  good prime l < {lmax}, the first index n with l | den x(nP) is")
    print("  exactly the order of the reduction of P in E_N(F_l).")
    rows: List[Tuple[int, int, int]] = []
    for l in range(5, lmax):
        if not is_prime(l) or l in bad:
            continue
        rows.append((l, order_mod_l(x0, y0, N, l), curve_order_mod_l(N, l)))
    print("    l : first index n (= order of P mod l) [group order]")
    line = ", ".join(f"{l}:{m}[{g}]" for l, m, g in rows[:20])
    print("    " + line)
    # cross-check the prediction against the honest rational computation
    for l, m, _ in rows:
        if m <= nmax:
            R = smul(m, P, N)
            assert R is not None and R[0].denominator % l == 0, \
                f"prediction failed for l = {l}"
            for j in range(1, m):
                S = smul(j, P, N)
                assert S is None or S[0].denominator % l != 0
    print("    all predictions with order <= %d cross-checked over Q." % nmax)
    print()


# ----------------------------------------------------------------------
# (3) The anti-factoring law along doubling orbits
# ----------------------------------------------------------------------
def demo_anti_factoring(cases: Optional[List[Tuple[int, int, int]]] = None,
                        steps: int = 4) -> None:
    print("=" * 72)
    print("(3)  THE ANTI-FACTORING LAW:  gcd(den x(2^k P), N) = 1")
    print("=" * 72)
    if cases is None:
        cases = [(55, 9, 28), (1763, 1, 42), (899, 1, 30), (39203, 1, 198),
                 (15, 1, 4), (33, 4, 11 if 11 * 11 == 4 ** 3 + 33 else 0)]
        cases = [c for c in cases if c[2] != 0 and on_curve(
            (Fraction(c[1]), Fraction(c[2])), c[0])]
    for N, x0, y0 in cases:
        P: Point = (Fraction(x0), Fraction(y0))
        assert on_curve(P, N), f"({x0},{y0}) is not on E_{N}"
        bad = sorted(factorize(N))
        print(f"  N = {N} = {pretty_factorization(N)},  P = ({x0}, {y0})")
        R: Point = P
        for k in range(steps + 1):
            if R is None:
                print(f"    k = {k}: 2^k P = O")
                break
            den = R[0].denominator
            g = gcd(den, N)
            small = str(den) if den < 10 ** 18 else f"<{len(str(den))} digits>"
            print(f"    k = {k}: gcd(den, N) = {g}   den = {small}")
            assert g == 1, "a bad prime appeared -- this contradicts the theorem"
            R = double(R, N)
        print(f"    bad primes {bad} never occur in any of these denominators.")
        print()


# ----------------------------------------------------------------------
# (4) The unbounded semiprime-shaped family N(l,t) = 4 l^2 t^2 - 1
# ----------------------------------------------------------------------
def fam_N(l: int, t: int) -> int:
    """N(l,t) = 4 l^2 t^2 - 1 = (2lt - 1)(2lt + 1)."""
    return 4 * l * l * t * t - 1


def fam_double_x(l: int, t: int) -> Fraction:
    """x(2P) for P = (1, 2lt) on E_{N(l,t)}:  (1 - 8N) / (4(N+1))."""
    N = fam_N(l, t)
    return double_x_closed_form(Fraction(1), Fraction(2 * l * t), N)


def demo_family(params: Optional[List[Tuple[int, int]]] = None) -> None:
    print("=" * 72)
    print("(4)  THE FAMILY  N(l,t) = 4 l^2 t^2 - 1 = (2lt-1)(2lt+1),  P = (1, 2lt)")
    print("=" * 72)
    if params is None:
        params = [(5, 3), (7, 3), (11, 9), (5, 6), (7, 10), (13, 21), (17, 30)]
    header = f"  {'l':>3} {'t':>3} {'N':>12} {'N = p*q':>20} " \
             f"{'den x(2P)':>14} {'factored':>18}  l|den  bad|den"
    print(header)
    print("  " + "-" * (len(header) - 2))
    for l, t in params:
        N = fam_N(l, t)
        p, q = 2 * l * t - 1, 2 * l * t + 1
        assert N == p * q
        X = fam_double_x(l, t)
        den = X.denominator
        tag = f"{p}*{q}" + ("  (twin primes)" if is_prime(p) and is_prime(q) else "")
        ldiv = "yes" if den % l == 0 else "NO"
        baddiv = "yes" if any(den % r == 0 for r in factorize(N)) else "no"
        assert den % l == 0, "the good prime l must divide the denominator"
        assert gcd(den, N) == 1, "no bad prime may divide the denominator"
        print(f"  {l:>3} {t:>3} {N:>12} {tag:>20} {den:>14} "
              f"{pretty_factorization(den):>18}  {ldiv:>5}  {baddiv:>6}")
    print()
    print("  Explicit certified instances:")
    for l, t in [(5, 3), (7, 3), (11, 9)]:
        N = fam_N(l, t)
        X = fam_double_x(l, t)
        print(f"    l = {l:>2}, N = {N} = {2*l*t-1}*{2*l*t+1}, "
              f"x(2P) = {X}, den = {pretty_factorization(X.denominator)}")
    print()


# ----------------------------------------------------------------------
# (5) The survey: what a denominator oracle actually sees
# ----------------------------------------------------------------------
def survey(semiprimes: Optional[List[Tuple[int, int, int]]] = None,
           nmax: int = 5) -> None:
    print("=" * 72)
    print("(5)  SURVEY: does the denominator sequence reveal the factors of N?")
    print("=" * 72)
    if semiprimes is None:
        semiprimes = []
        for N in range(6, 600):
            if N % 2 == 0:          # the theory is stated for odd moduli
                continue
            f = factorize(N)
            if sorted(f.values()) != [1, 1]:
                continue
            for x0 in range(-20, 40):
                r = x0 ** 3 + N
                if r <= 0:
                    continue
                y0 = int(round(r ** 0.5))
                if y0 * y0 == r and y0 != 0:
                    semiprimes.append((N, x0, y0))
                    break
            if len(semiprimes) >= 11:
                break
    p_hits = q_hits = only_bad = 0
    print(f"  {'N':>7} {'p':>5} {'q':>5} {'P':>14}  denominator primes for n <= "
          f"{nmax}")
    for N, x0, y0 in semiprimes:
        p, q = sorted(factorize(N))
        P: Point = (Fraction(x0), Fraction(y0))
        seen: set = set()
        for n in range(1, nmax + 1):
            R = smul(n, P, N)
            if R is None:
                continue
            seen |= set(factorize(R[0].denominator)) if R[0].denominator > 1 else set()
        p_hits += p in seen
        q_hits += q in seen
        only_bad += seen <= {2, 3, p, q}
        print(f"  {N:>7} {p:>5} {q:>5} {str((x0, y0)):>14}  {sorted(seen)}")
    n = len(semiprimes)
    print()
    print(f"  smaller prime p appears in a denominator: {p_hits}/{n} "
          f"= {100.0 * p_hits / n:.1f}%")
    print(f"  larger  prime q appears in a denominator: {q_hits}/{n} "
          f"= {100.0 * q_hits / n:.1f}%")
    print(f"  support contained in {{2,3,p,q}} (the conjecture): {only_bad}/{n} "
          f"= {100.0 * only_bad / n:.1f}%")
    print()


def main() -> None:
    demo_counterexample()
    demo_mechanism()
    demo_anti_factoring()
    demo_family()
    survey()
    print("=" * 72)
    print("All assertions passed: the counterexample, the mechanism, the")
    print("anti-factoring law and the unbounded family are confirmed numerically.")
    print("=" * 72)


if __name__ == "__main__":
    main()
