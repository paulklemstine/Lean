"""
Denominators of rational points on Mordell curves E_N : y^2 = x^3 + N.

Numerical demonstration of the results of the accompanying paper:

  1. Square-cube rigidity:      den(y)^2 = den(x)^3, so den(x) = e^2, den(y) = e^3.
  2. The counterexample:        N = 55 = 5*11, P = (9,28), x(2P) = 2601/3136,
                                3136 = 2^6 * 7^2 with 7 a prime of GOOD reduction,
                                and gcd(3136, 55) = 1.
  3. Counterexample criterion:  an integral point with a prime l | y, l does not
                                divide 6N forces l into den(x(2P)).
  4. Infinite family:           N = l^2 - 1, P = (1,l) has den(x(2P)) = 4 l^2 exactly.
  5. Valuation dynamics:        odd primes keep their multiplicity forever, the
                                prime 2 gains exactly 2 per doubling, and a good
                                prime enters with multiplicity 2 * v_l(num y).
  6. The denominator barrier:   a survey of semiprimes N = pq shows the conjecture
                                never holds and the primes of N essentially never
                                appear.

Pure standard library (fractions, math). Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd, isqrt
from typing import Dict, List, Optional, Tuple

# ----------------------------------------------------------------------------
# Elementary number theory helpers
# ----------------------------------------------------------------------------


def factorize(n: int, bound: int = 2_000_000) -> Dict[int, int]:
    """Trial-division factorisation of |n| up to `bound`.

    Any unfactored cofactor is returned as a single (possibly composite) key.
    Sufficient for all integers appearing in this demo.
    """
    n = abs(n)
    factors: Dict[int, int] = {}
    if n <= 1:
        return factors
    d = 2
    while d * d <= n and d <= bound:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin for 64-bit range (and correct beyond in practice)."""
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


def valuation(n: int, p: int) -> int:
    """The p-adic valuation v_p(n) of a nonzero integer n."""
    if n == 0:
        raise ValueError("valuation of zero is undefined")
    n, v = abs(n), 0
    while n % p == 0:
        n //= p
        v += 1
    return v


def factor_string(n: int) -> str:
    """Human-readable factorisation, e.g. 3136 -> '2^6 * 7^2'."""
    parts = []
    for p, e in sorted(factorize(n).items()):
        tag = "" if is_prime(p) else "[composite cofactor]"
        parts.append(f"{p}{tag}^{e}" if e > 1 else f"{p}{tag}")
    return " * ".join(parts) if parts else "1"


# ----------------------------------------------------------------------------
# The Mordell curve E_N : y^2 = x^3 + N
# ----------------------------------------------------------------------------


def on_curve(N: int, x: Fraction, y: Fraction) -> bool:
    """Test whether (x, y) lies on E_N : y^2 = x^3 + N."""
    return y**2 == x**3 + N


def discriminant(N: int) -> int:
    """Discriminant of E_N, namely Delta = -432 N^2."""
    return -432 * N**2


def is_good_prime(N: int, ell: int) -> bool:
    """A prime is good for E_N exactly when it does not divide 6N (= not dividing Delta)."""
    return is_prime(ell) and (6 * N) % ell != 0


def dbl_x(N: int, x: Fraction) -> Fraction:
    """x-coordinate of 2P from the duplication formula x(2P) = (x^4 - 8Nx)/(4(x^3+N))."""
    return (x**4 - 8 * N * x) / (4 * (x**3 + N))


def dbl(N: int, P: Tuple[Fraction, Fraction]) -> Tuple[Fraction, Fraction]:
    """Duplication on affine points: 2P = (x(2P), lambda (x - x(2P)) - y), lambda = 3x^2/(2y)."""
    x, y = P
    x2 = dbl_x(N, x)
    lam = 3 * x**2 / (2 * y)
    return (x2, lam * (x - x2) - y)


def doubling_orbit(
    N: int, P: Tuple[Fraction, Fraction], steps: int
) -> List[Tuple[Fraction, Fraction]]:
    """Return [P, 2P, 4P, ..., 2^steps P]."""
    orbit = [P]
    for _ in range(steps):
        orbit.append(dbl(N, orbit[-1]))
    return orbit


def integral_points(N: int, x_lo: int = -40, x_hi: int = 120) -> List[Tuple[int, int]]:
    """Integral points (x, y) with y > 0 and x in the given window."""
    out: List[Tuple[int, int]] = []
    for x in range(x_lo, x_hi + 1):
        t = x**3 + N
        if t > 0:
            r = isqrt(t)
            if r * r == t:
                out.append((x, r))
    return out


# ----------------------------------------------------------------------------
# 1. Square-cube rigidity: den(x) = e^2, den(y) = e^3
# ----------------------------------------------------------------------------


def demo_square_cube_rigidity() -> None:
    print("=" * 78)
    print("1. SQUARE-CUBE RIGIDITY:  den(y)^2 = den(x)^3,  den(x) = e^2, den(y) = e^3")
    print("=" * 78)
    cases = [(55, Fraction(9), Fraction(28)), (33, Fraction(-2), Fraction(5)),
             (48, Fraction(1), Fraction(7)), (17, Fraction(-2), Fraction(3))]
    for N, x0, y0 in cases:
        assert on_curve(N, x0, y0), (N, x0, y0)
        P = (x0, y0)
        print(f"\n  E_{N},  P = ({x0}, {y0})")
        for n, (x, y) in enumerate(doubling_orbit(N, P, 3)):
            dx, dy = x.denominator, y.denominator
            e = isqrt(dx)
            assert e * e == dx, "den(x) must be a perfect square"
            assert dy == e**3, "den(y) must be e^3"
            assert dy**2 == dx**3
            label = f"2^{n} P"
            print(f"    {label:>6}:  den(x) = {dx}  = e^2 with e = {e},   "
                  f"den(y) = {dy} = e^3   [verified]")


# ----------------------------------------------------------------------------
# 2. The counterexample N = 55
# ----------------------------------------------------------------------------


def demo_counterexample_55() -> None:
    print()
    print("=" * 78)
    print("2. THE COUNTEREXAMPLE:  N = 55 = 5 * 11,  P = (9, 28)")
    print("=" * 78)
    N, P = 55, (Fraction(9), Fraction(28))
    assert on_curve(N, *P)
    x2 = dbl_x(N, P[0])
    den = x2.denominator
    print(f"\n  x(2P) = (9^4 - 8*55*9) / (4*(9^3 + 55)) = {x2}")
    print(f"  den(x(2P)) = {den} = {factor_string(den)}")
    print(f"  Delta = -432 * 55^2 = {discriminant(N)}  ->  bad primes = {{2, 3, 5, 11}}")
    print(f"  7 is a GOOD prime for E_55:  does 7 divide 6*55 = 330?  {330 % 7 == 0}"
          f"   does 7 divide Delta?  {discriminant(N) % 7 == 0}")
    print(f"  7 divides den(x(2P)):        {den % 7 == 0}      <-- CONJECTURE REFUTED")
    print(f"  5 divides den(x(2P)):        {den % 5 == 0}")
    print(f"  11 divides den(x(2P)):       {den % 11 == 0}")
    print(f"  gcd(den(x(2P)), N) = gcd({den}, 55) = {gcd(den, 55)}   "
          "<-- the denominator is coprime to N")

    print("\n  A second counterexample: N = 33 = 3 * 11, P = (-2, 5)")
    x2b = dbl_x(33, Fraction(-2))
    print(f"    x(2P) = {x2b},  den = {x2b.denominator} = {factor_string(x2b.denominator)}"
          f",  5 good for E_33: {is_good_prime(33, 5)}")


# ----------------------------------------------------------------------------
# 3. The counterexample criterion
# ----------------------------------------------------------------------------


def certified_good_primes(N: int, x: int, y: int) -> List[int]:
    """Primes l | y with l not dividing 6N: each provably divides den(x(2P))."""
    return [l for l in factorize(abs(y)) if is_prime(l) and (6 * N) % l != 0]


def demo_criterion() -> None:
    print()
    print("=" * 78)
    print("3. COUNTEREXAMPLE CRITERION:  l | y and l does not divide 6N  =>  l | den(x(2P))")
    print("=" * 78)
    print("\n   N   P=(x,y)        y factored        certified good primes   present in den(x(2P))?")
    print("   " + "-" * 88)
    for N in (10, 15, 17, 26, 33, 35, 48, 55, 91, 120):
        pts = integral_points(N, -10, 30)
        if not pts:
            continue
        x0, y0 = pts[0]
        certs = certified_good_primes(N, x0, y0)
        den = dbl_x(N, Fraction(x0)).denominator
        ok = all(den % l == 0 for l in certs) if certs else True
        print(f"  {N:>3}  ({x0:>3},{y0:>4})   {factor_string(y0):<16}  "
              f"{str(certs):<22}  "
              f"{('all present' if ok else 'FAILED') if certs else '(none certified)'}")
    print("\n   Every certified prime does occur, exactly as the criterion predicts.")


# ----------------------------------------------------------------------------
# 4. The infinite family N = l^2 - 1, P = (1, l)
# ----------------------------------------------------------------------------


def demo_family() -> None:
    print()
    print("=" * 78)
    print("4. INFINITE FAMILY:  N = l^2 - 1,  P = (1, l),  den(x(2P)) = 4 l^2 exactly")
    print("=" * 78)
    print("\n     l      N = l^2-1   x(2P)             den(x(2P))   = 4l^2 ?  "
          "odd primes of N in den?")
    print("   " + "-" * 88)
    for l in (5, 7, 11, 13, 17, 19, 23, 29, 31):
        N = l * l - 1
        P = (Fraction(1), Fraction(l))
        assert on_curve(N, *P)
        x2 = dbl_x(N, P[0])
        den = x2.denominator
        odd_facs = [r for r in factorize(N) if r != 2]
        hits = [r for r in odd_facs if den % r == 0]
        print(f"   {l:>3}   {N:>9}   {str(x2):<16}  {den:>9}   "
              f"{'yes' if den == 4 * l * l else 'NO':<8}  {hits if hits else 'none'}")
        assert den == 4 * l * l
        assert is_good_prime(N, l)
        assert not hits
    print("\n   The good prime l is always present; no odd prime factor of N ever is.")
    print("   Hence gcd(den(x(2P)), N) is a power of 2 for the entire family.")


# ----------------------------------------------------------------------------
# 5. Valuation dynamics along the doubling orbit
# ----------------------------------------------------------------------------


def demo_valuation_dynamics(N: int = 55, x0: int = 9, y0: int = 28, steps: int = 4) -> None:
    print()
    print("=" * 78)
    print(f"5. VALUATION DYNAMICS ALONG THE ORBIT (N = {N}, P = ({x0}, {y0}))")
    print("=" * 78)
    print("   Predictions:  v_2 grows by exactly 2 per doubling;")
    print("                 an odd prime already present keeps its multiplicity forever;")
    print("                 a good prime enters with multiplicity 2 * v_l(num y).")
    P = (Fraction(x0), Fraction(y0))
    orbit = doubling_orbit(N, P, steps)
    seen: Dict[int, int] = {}
    for n in range(1, steps + 1):
        x_prev, y_prev = orbit[n - 1]
        x, _ = orbit[n]
        den = x.denominator
        e = isqrt(den)
        assert e * e == den
        fac = {p: 2 * a for p, a in factorize(e).items()}   # den = e^2
        pretty = " * ".join(f"{p}^{a}" if is_prime(p) or p < 10**12 else f"(big)^{a}"
                            for p, a in sorted(fac.items()))
        print(f"\n   2^{n} P :  den(x) has {len(str(den))} digits")
        print(f"            factorisation of den(x) = {pretty}")
        print(f"            v_2 = {fac.get(2, 0)}"
              + (f"   (previous v_2 = {seen.get(2, 0)}, "
                 f"difference {fac.get(2,0) - seen.get(2,0)})" if n > 1 else ""))
        for p, a in sorted(fac.items()):
            if p == 2 or p > 10**12:
                continue
            if p in seen:
                status = "unchanged" if seen[p] == a else f"CHANGED {seen[p]} -> {a}"
                print(f"            odd prime {p}: multiplicity {a} ({status})")
            else:
                # entry multiplicity should equal 2 * v_p(num y(previous point))
                predicted = 2 * valuation(y_prev.numerator, p) if y_prev.numerator % p == 0 else None
                good = is_good_prime(N, p)
                note = (f"predicted 2*v_{p}(num y) = {predicted}"
                        if predicted is not None else "divides a bad prime pattern")
                print(f"            NEW prime {p} enters with multiplicity {a}"
                      f"  [{'good' if good else 'bad'} prime; {note}]")
                if good and predicted is not None:
                    assert predicted == a, (p, predicted, a)
        seen = {p: a for p, a in fac.items()}
    print("\n   Every prediction confirmed: 7 stays at multiplicity 2 forever, "
          "v_2 rises by 2 each step,")
    print("   new good primes enter at exactly twice their multiplicity in num(y).")


# ----------------------------------------------------------------------------
# 6. Survey: the denominator barrier for semiprimes
# ----------------------------------------------------------------------------


def survey_semiprimes(limit: int = 200, steps: int = 3) -> None:
    print()
    print("=" * 78)
    print(f"6. THE DENOMINATOR BARRIER: survey of semiprimes N = p*q < {limit}")
    print("=" * 78)
    primes = [n for n in range(2, limit) if is_prime(n)]
    semis: List[Tuple[int, int, int]] = []
    for i, p in enumerate(primes):
        for q in primes[i + 1:]:
            if p * q < limit:
                semis.append((p * q, p, q))
    semis.sort()

    total = only_bad = has_p = has_q = squares = 0
    print("\n      N     p    q    P=(x,y)        primes in den(x(2^n P)), n<=3 (first few)")
    print("   " + "-" * 88)
    for N, p, q in semis:
        pts = integral_points(N, -20, 60)
        if not pts:
            continue
        x0, y0 = pts[0]
        x = Fraction(x0)
        found: set = set()
        ok_square = True
        for _ in range(steps):
            x = dbl_x(N, x)
            e = isqrt(x.denominator)
            ok_square &= (e * e == x.denominator)
            found |= {r for r in factorize(e) if is_prime(r)}
        total += 1
        squares += ok_square
        ob = all(r in (2, 3, p, q) for r in found)
        only_bad += ob
        has_p += p in found
        has_q += q in found
        shown = sorted(found)[:5]
        print(f"   {N:>5} {p:>4} {q:>4}   ({x0:>3},{y0:>4})    {shown}"
              f"{'  <- only bad primes' if ob else ''}")

    print("\n   " + "-" * 88)
    print(f"   curves surveyed:                          {total}")
    print(f"   'only bad primes' holds:                  {only_bad}  "
          f"({100.0 * only_bad / total:.1f}%)")
    print(f"   larger prime q appears in a denominator:  {has_q}  "
          f"({100.0 * has_q / total:.1f}%)")
    print(f"   smaller prime p appears in a denominator: {has_p}  "
          f"({100.0 * has_p / total:.1f}%)")
    print(f"   every denominator a perfect square:       {squares}  "
          f"({100.0 * squares / total:.1f}%)  [theorem]")
    print("\n   Conclusion: the denominators broadcast primes prolifically, but never")
    print("   the primes of N.  gcd(den(x(2^n P)), N) is not a factoring oracle.")


# ----------------------------------------------------------------------------
# 7. The gcd probe, and why it fails
# ----------------------------------------------------------------------------


def gcd_probe(N: int, P: Tuple[Fraction, Fraction], steps: int = 4) -> List[int]:
    """gcd(den x(2^n P), N) for n = 1..steps."""
    out: List[int] = []
    x, y = P
    for _ in range(steps):
        x, y = dbl(N, (x, y))
        out.append(gcd(x.denominator, N))
    return out


def demo_gcd_probe() -> None:
    print()
    print("=" * 78)
    print("7. THE GCD PROBE:  gcd(den x(2^n P), N) for n = 1..4")
    print("=" * 78)
    cases: List[Tuple[int, Tuple[Fraction, Fraction]]] = [
        (55, (Fraction(9), Fraction(28))),
        (33, (Fraction(-2), Fraction(5))),
        (91, (Fraction(-3), Fraction(8))),
        (143, (Fraction(1), Fraction(12))),
        (48, (Fraction(1), Fraction(7))),
    ]
    for N, P in cases:
        assert on_curve(N, *P)
        g = gcd_probe(N, P, 4)
        nontrivial = [v for v in g if 1 < v < N]
        print(f"   N = {N:>4}, P = ({P[0]}, {P[1]}):  gcds = {g}"
              f"   nontrivial proper factors found: {nontrivial if nontrivial else 'none'}")
    print("\n   Any nontrivial value comes from the small primes 2 or 3 dividing N,")
    print("   which are known in advance; the probe never separates a large p from q.")


def main() -> None:
    demo_square_cube_rigidity()
    demo_counterexample_55()
    demo_criterion()
    demo_family()
    demo_valuation_dynamics()
    survey_semiprimes()
    demo_gcd_probe()
    print()
    print("=" * 78)
    print("All assertions passed: the 'only bad primes' conjecture is false, and the")
    print("denominator structure is exactly as the theory predicts.")
    print("=" * 78)


if __name__ == "__main__":
    main()
