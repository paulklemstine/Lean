"""
The Pole-Order Obstruction — numerical demonstrations.

Self-contained, dependency-free Python (standard library only) illustrating the
main results about products of *normalized* formal Laurent series

        T = q^{-1} + c_0 + c_1 q + c_2 q^2 + ...

over the complex numbers, and in particular the Monster-sized case of m = 194
factors (one per conjugacy class of the Monster simple group).

Results demonstrated
--------------------
1.  Pole-Order Theorem: a product of m normalized series has order exactly -m,
    with leading coefficient 1; multiplying by q^m restores order 0.
2.  Root-Extraction Theorem: a nonzero Laurent series is an n-th power iff
    n divides its order.  For m = 194 the root spectrum is {1, 2, 97, 194}.
3.  Power classes: order mod n is a complete and sharp invariant of the n-th
    power class in the unit group.
4.  Additive contrast: a sum of m normalized series has order -1, not -m.
5.  Rigidity: a pole of order m in a product of m at-most-simple-pole factors
    forces every factor to have a simple pole.
6.  Pole filtration and principal parts: dim PP_m = m, graded pieces are
    1-dimensional, and the Monster-sized product sits in Pol_194 \\ Pol_193
    with deepest coordinate 1.
7.  Elementary symmetric functions: for linear factors q^{-1} + a_i the
    coefficient in degree k - m is e_k(a).
8.  Replication V_d : q -> q^d multiplies order by d; root spectrum becomes the
    divisors of 194 d; minimal depth for an n-th root is n / gcd(n, 194).
9.  Dissolution over Q-exponents: an n-th root exists for every n, built as
    q^{-m/n} times the binomial n-th root of the corrected unit part.
10. Interpolation: an n-th root with exponents in (1/N)Z exists iff n | 194 N,
    the very same criterion as replication at depth N.
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd
from typing import Dict, Iterable, List, Sequence, Tuple

MONSTER_CLASS_COUNT: int = 194


# ---------------------------------------------------------------------------
# Truncated Laurent series
# ---------------------------------------------------------------------------

class Laurent:
    """A formal Laurent series truncated above a fixed exponent bound.

    Internally a dict from integer exponent to Fraction coefficient, together
    with `top`: coefficients in degrees > top are not tracked.
    """

    __slots__ = ("coeffs", "top")

    def __init__(self, coeffs: Dict[int, Fraction], top: int) -> None:
        self.top: int = top
        self.coeffs: Dict[int, Fraction] = {
            n: Fraction(c) for n, c in coeffs.items() if c != 0 and n <= top
        }

    # -- basic accessors ----------------------------------------------------

    def coeff(self, n: int) -> Fraction:
        return self.coeffs.get(n, Fraction(0))

    def is_zero(self) -> bool:
        return not self.coeffs

    def order(self) -> int:
        """Least exponent with a nonzero coefficient.  Undefined for 0."""
        if self.is_zero():
            raise ValueError("the zero series has no order")
        return min(self.coeffs)

    def leading_coeff(self) -> Fraction:
        return self.coeff(self.order())

    # -- arithmetic ---------------------------------------------------------

    def __add__(self, other: "Laurent") -> "Laurent":
        top = min(self.top, other.top)
        out: Dict[int, Fraction] = dict(self.coeffs)
        for n, c in other.coeffs.items():
            out[n] = out.get(n, Fraction(0)) + c
        return Laurent(out, top)

    def __mul__(self, other: "Laurent") -> "Laurent":
        if self.is_zero() or other.is_zero():
            return Laurent({}, min(self.top, other.top))
        # Truncation bound: product is reliable up to
        # min(self.top + ord(other), other.top + ord(self)).
        top = min(self.top + other.order(), other.top + self.order())
        out: Dict[int, Fraction] = {}
        for a, ca in self.coeffs.items():
            for b, cb in other.coeffs.items():
                if a + b <= top:
                    out[a + b] = out.get(a + b, Fraction(0)) + ca * cb
        return Laurent(out, top)

    def __pow__(self, n: int) -> "Laurent":
        result = Laurent({0: Fraction(1)}, self.top - self.order() * max(n - 1, 0))
        for _ in range(n):
            result = result * self
        return result

    def shift(self, k: int) -> "Laurent":
        """Multiply by q^k."""
        return Laurent({n + k: c for n, c in self.coeffs.items()}, self.top + k)

    def replicate(self, d: int) -> "Laurent":
        """Apply V_d : q -> q^d."""
        return Laurent({n * d: c for n, c in self.coeffs.items()}, self.top * d)

    def truncate(self, top: int) -> "Laurent":
        return Laurent(dict(self.coeffs), min(self.top, top))

    def __repr__(self) -> str:
        if self.is_zero():
            return "0"
        pieces: List[str] = []
        for n in sorted(self.coeffs):
            c = self.coeffs[n]
            cs = str(c)
            if n == 0:
                pieces.append(cs)
            elif n == 1:
                pieces.append(f"{cs}*q")
            else:
                pieces.append(f"{cs}*q^{n}")
        return " + ".join(pieces) + f" + O(q^{self.top + 1})"


def normalized(tail: Sequence[Fraction | int], top: int) -> Laurent:
    """The normalized series q^{-1} + tail[0] + tail[1] q + ... ."""
    coeffs: Dict[int, Fraction] = {-1: Fraction(1)}
    for k, c in enumerate(tail):
        if k <= top:
            coeffs[k] = Fraction(c)
    return Laurent(coeffs, top)


def linear_normalized(a: Fraction | int, top: int) -> Laurent:
    """The linear normalized series q^{-1} + a."""
    return Laurent({-1: Fraction(1), 0: Fraction(a)}, top)


def prod(series: Iterable[Laurent]) -> Laurent:
    it = iter(series)
    result = next(it)
    for s in it:
        result = result * s
    return result


# ---------------------------------------------------------------------------
# Arithmetic of the obstruction
# ---------------------------------------------------------------------------

def divisors(m: int) -> List[int]:
    out: List[int] = []
    d = 1
    while d * d <= m:
        if m % d == 0:
            out.append(d)
            if d != m // d:
                out.append(m // d)
        d += 1
    return sorted(out)


def root_spectrum(m: int, bound: int) -> List[int]:
    """Exponents n <= bound for which a product of m normalized series is an
    n-th power in C((q)).  By the Root-Extraction Theorem: the divisors of m."""
    return [n for n in divisors(m) if n <= bound]


def has_root(m: int, n: int) -> bool:
    """Does a product of m normalized series have an n-th root in C((q))?"""
    return n >= 1 and m % n == 0


def has_root_after_replication(m: int, n: int, d: int) -> bool:
    """Does V_d of the product have an n-th root?  Criterion: n | d*m."""
    return n >= 1 and d >= 1 and (d * m) % n == 0


def minimal_replication_depth(n: int, m: int = MONSTER_CLASS_COUNT) -> int:
    """Least d with an n-th root after V_d.  Equals n / gcd(n, m)."""
    return n // gcd(n, m)


def has_lattice_root(m: int, n: int, N: int) -> bool:
    """Root with exponents in (1/N)Z inside the Puiseux field: n | m*N."""
    return n >= 1 and N >= 1 and (m * N) % n == 0


def critical_exponent(m: int, n: int) -> Fraction:
    """The single rational number whose membership in the exponent set decides
    the existence of an n-th root: -m/n."""
    return Fraction(-m, n)


# ---------------------------------------------------------------------------
# Symmetric functions
# ---------------------------------------------------------------------------

def elementary_symmetric(a: Sequence[Fraction | int], k: int) -> Fraction:
    """e_k(a), computed by the standard O(m*k) dynamic program."""
    e: List[Fraction] = [Fraction(0)] * (k + 1)
    e[0] = Fraction(1)
    for x in a:
        for j in range(min(k, len(a)), 0, -1):
            e[j] += Fraction(x) * e[j - 1]
    return e[k]


# ---------------------------------------------------------------------------
# Binomial n-th root of a power series with constant term 1
# ---------------------------------------------------------------------------

def binomial_coefficient(r: Fraction, k: int) -> Fraction:
    """The generalized binomial coefficient C(r, k) for rational r."""
    num = Fraction(1)
    for j in range(k):
        num *= (r - j)
    den = Fraction(1)
    for j in range(1, k + 1):
        den *= j
    return num / den


def power_series_nth_root(u: List[Fraction], n: int) -> List[Fraction]:
    """Given u = [u_0, ..., u_K] with u_0 = 1, return w with w_0 = 1 and
    w^n = u to order K.

    Degree-by-degree recursion: suppose w_0, ..., w_{k-1} are known and w_k is
    provisionally 0.  In the expansion of w^n, the coefficient of q^k depends on
    w_k only through the single linear term n * w_0^{n-1} * w_k = n * w_k.
    Hence setting w_k := (u_k - [q^k](w^n)) / n corrects degree k exactly and
    leaves all lower degrees untouched.  This is the algebraic realisation of
    the binomial series root of Proposition 2.3.
    """
    assert u and u[0] == 1, "constant term must be 1"
    K = len(u) - 1
    w: List[Fraction] = [Fraction(0)] * (K + 1)
    w[0] = Fraction(1)
    for k in range(1, K + 1):
        # Compute the coefficient of q^k in w^n using the current w
        # (with w[k] still 0); the missing contribution is exactly n*w[k].
        cur = _poly_pow(w, n, k)
        w[k] = (u[k] - cur[k]) / n
    return w


def _poly_mul(a: List[Fraction], b: List[Fraction], K: int) -> List[Fraction]:
    out = [Fraction(0)] * (K + 1)
    for i, ai in enumerate(a):
        if ai == 0 or i > K:
            continue
        for j, bj in enumerate(b):
            if bj == 0 or i + j > K:
                continue
            out[i + j] += ai * bj
    return out


def _poly_pow(a: List[Fraction], n: int, K: int) -> List[Fraction]:
    out = [Fraction(0)] * (K + 1)
    out[0] = Fraction(1)
    for _ in range(n):
        out = _poly_mul(out, a, K)
    return out


def puiseux_root_of_normalized_product(
    tails: Sequence[Sequence[Fraction | int]], n: int, K: int
) -> Tuple[Fraction, List[Fraction]]:
    """The n-th root, over Q-exponents, of a product of m normalized series.

    Returns (e, w) representing y = q^e * (w_0 + w_1 q + ... ), with e = -m/n
    and w^n equal to the corrected product q^m * prod(T_i) to order K.
    """
    m = len(tails)
    # corrected part of q^{-1} + c_0 + c_1 q + ... is 1 + c_0 q + c_1 q^2 + ...
    u: List[Fraction] = [Fraction(1)] + [Fraction(0)] * K
    for tail in tails:
        f: List[Fraction] = [Fraction(1)] + [Fraction(0)] * K
        for k, c in enumerate(tail):
            if k + 1 <= K:
                f[k + 1] = Fraction(c)
        u = _poly_mul(u, f, K)
    w = power_series_nth_root(u, n)
    return Fraction(-m, n), w


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_pole_order() -> None:
    print("=" * 74)
    print("1.  POLE-ORDER THEOREM:  ord(prod of m normalized series) = -m")
    print("=" * 74)
    top = 6
    tails = [[1, 2, 3], [0, -1, 4], [5, 5, 5], [2, 0, 7], [-3, 1, 1]]
    for m in range(1, len(tails) + 1):
        p = prod(normalized(t, top) for t in tails[:m])
        print(f"  m = {m}:  ord = {p.order():>3}   leading coeff = {p.leading_coeff()}"
              f"   (predicted ord = {-m})")
        assert p.order() == -m and p.leading_coeff() == 1
    p = prod(normalized(t, top) for t in tails)
    corrected = p.shift(len(tails))
    print(f"\n  Multiplying by q^{len(tails)} restores order 0:  "
          f"ord = {corrected.order()}, constant term = {corrected.coeff(0)}")
    assert corrected.order() == 0 and corrected.coeff(0) == 1
    print()


def demo_root_spectrum() -> None:
    print("=" * 74)
    print("2.  ROOT-EXTRACTION THEOREM  and the MONSTER root spectrum")
    print("=" * 74)
    m = MONSTER_CLASS_COUNT
    print(f"  m = {m} = 2 * 97 (squarefree).  Divisors: {divisors(m)}")
    print(f"  Root spectrum (n <= 200):  {root_spectrum(m, 200)}")
    for n in (1, 2, 3, 4, 5, 97, 194):
        verdict = "EXISTS    " if has_root(m, n) else "OBSTRUCTED"
        print(f"    n = {n:>3}:  n-th root {verdict}   (n | {m}?  "
              f"{'yes' if m % n == 0 else 'no'})")
    assert has_root(m, 2) and not has_root(m, 3) and not has_root(m, 4)
    print("\n  Small-m sanity check (a product of m factors is an n-th power iff n | m):")
    top = 4
    for m_small, n in [(4, 2), (6, 3), (6, 4)]:
        tails = [[Fraction(i + 1), Fraction(0)] for i in range(m_small)]
        p = prod(normalized(t, top) for t in tails)
        ok = p.order() % n == 0
        print(f"    m = {m_small}, n = {n}:  ord = {p.order()},  n | ord?  {ok}"
              f"   -> {'root exists' if ok else 'no root'}")
        assert ok == has_root(m_small, n)
    print()


def demo_power_classes() -> None:
    print("=" * 74)
    print("3.  POWER CLASSES:  order mod n is a complete and sharp invariant")
    print("=" * 74)
    m = MONSTER_CLASS_COUNT
    for n in (2, 3, 4, 5, 6, 97):
        cls = (-m) % n
        print(f"    n = {n:>3}:  class of the Monster-sized product = {cls:>3} mod {n}"
              f"   -> {'trivial (root exists)' if cls == 0 else 'nontrivial (obstructed)'}")
    print("\n  Sharpness: every residue mod n is realized by some monomial q^k.")
    n = 6
    realized = sorted({k % n for k in range(-20, 21)})
    print(f"    n = {n}: residues realized by q^k, -20 <= k <= 20:  {realized}")
    assert realized == list(range(n))
    print()


def demo_additive_contrast() -> None:
    print("=" * 74)
    print("4.  ADDITIVE CONTRAST:  a SUM of m normalized series has order -1")
    print("=" * 74)
    top = 4
    tails = [[1, 2], [3, 4], [5, 6], [7, 8], [9, 10]]
    for m in range(1, 6):
        s = tails[:m]
        total = normalized(s[0], top)
        for t in s[1:]:
            total = total + normalized(t, top)
        p = prod(normalized(t, top) for t in s)
        print(f"    m = {m}:  ord(sum) = {total.order():>3}   "
              f"ord(product) = {p.order():>3}   residue of sum = {total.coeff(-1)}")
        assert total.order() == -1 and p.order() == -m
    print("\n  Pole-order growth is a purely multiplicative phenomenon.")
    print()


def demo_rigidity() -> None:
    print("=" * 74)
    print("5.  RIGIDITY:  a pole of order m certifies m genuinely singular factors")
    print("=" * 74)
    top = 5
    # Three factors, each with at most a simple pole; product has order -3.
    factors = [normalized([1, 0], top), normalized([2, 1], top), normalized([0, 3], top)]
    p = prod(factors)
    print(f"    three at-most-simple-pole factors, ord(product) = {p.order()}")
    print(f"    orders of factors: {[f.order() for f in factors]}  -> all equal -1, as forced")
    assert p.order() == -3 and all(f.order() == -1 for f in factors)
    # Now replace one factor by a regular one: the product order jumps up.
    regular = Laurent({0: Fraction(1), 1: Fraction(2)}, top)   # order 0
    q = prod([factors[0], factors[1], regular])
    print(f"\n    replacing one factor by a regular series (order 0):"
          f"  ord(product) = {q.order()} > -3")
    print("    so an order of exactly -3 is impossible unless every factor is singular.")
    assert q.order() > -3
    print()


def demo_filtration() -> None:
    print("=" * 74)
    print("6.  POLE FILTRATION:  dim PP_m = m, graded pieces 1-dimensional")
    print("=" * 74)
    print("    Pol_m = { x : x_n = 0 for all n < -m }, an increasing chain of subspaces.")
    print("    Basis of the principal-part space PP_m:  q^-1, q^-2, ..., q^-m.")
    for m in range(0, 6):
        basis = ", ".join(f"q^-{j}" for j in range(1, m + 1)) or "(empty)"
        print(f"      m = {m}:  dim PP_m = {m:>2}   basis: {basis}")
    print("\n    Each graded piece Pol_{m+1}/Pol_m is spanned by q^-(m+1): dimension 1.")
    top = 3
    tails = [[Fraction(i + 1), Fraction(0)] for i in range(7)]
    p = prod(normalized(t, top) for t in tails)
    m = len(tails)
    in_m = all(p.coeff(n) == 0 for n in range(-3 * m, -m))
    in_m_minus = all(p.coeff(n) == 0 for n in range(-3 * m, -(m - 1)))
    print(f"\n    A {m}-fold product:  in Pol_{m}?  {in_m}    in Pol_{m-1}?  {in_m_minus}")
    print(f"    deepest principal-part coordinate (coefficient of q^-{m}) = {p.coeff(-m)}")
    assert in_m and not in_m_minus and p.coeff(-m) == 1
    print(f"\n    Monster-sized case: the product lies in Pol_194 but not Pol_193,")
    print(f"    dim PP_194 = 194, and its deepest coordinate is 1.")
    print()


def demo_symmetric_functions() -> None:
    print("=" * 74)
    print("7.  ELEMENTARY SYMMETRIC FUNCTIONS in the coefficients")
    print("=" * 74)
    for a in ([2, 3], [2, 3, 5], [1, -2, 4, 7]):
        m = len(a)
        top = 2 * m + 2          # generous headroom: truncation must not bite
        p = prod(linear_normalized(x, top) for x in a)
        print(f"\n    a = {a}   (m = {m})")
        print(f"      product = {p}")
        for k in range(m + 1):
            lhs = p.coeff(k - m)
            rhs = elementary_symmetric(a, k)
            mark = "ok" if lhs == rhs else "MISMATCH"
            print(f"        degree {k - m:>3}:  coefficient = {str(lhs):>8}   "
                  f"e_{k}(a) = {str(rhs):>8}   [{mark}]")
            assert lhs == rhs
    print("\n    Endpoints: deepest coefficient is e_0 = 1; constant term is e_m = product of a.")
    a = [1, -2, 4, 7]
    p = prod(linear_normalized(x, 2 * len(a) + 2) for x in a)
    assert p.coeff(-len(a)) == 1
    assert p.coeff(0) == Fraction(1 * -2 * 4 * 7)
    print(f"    check: e_4(1,-2,4,7) = {elementary_symmetric(a, 4)} = constant term "
          f"{p.coeff(0)}")
    print()


def demo_replication() -> None:
    print("=" * 74)
    print("8.  REPLICATION  V_d : q -> q^d   multiplies pole order by d")
    print("=" * 74)
    top = 4
    tails = [[Fraction(1), Fraction(0)], [Fraction(2), Fraction(0)], [Fraction(3), Fraction(0)]]
    p = prod(normalized(t, top) for t in tails)
    for d in (1, 2, 3, 5):
        r = p.replicate(d)
        print(f"    d = {d}:  ord(V_d P) = {r.order():>4}   (predicted {d * p.order()})")
        assert r.order() == d * p.order()
    m = MONSTER_CLASS_COUNT
    print(f"\n    Monster case (m = {m}): V_d of the product has an n-th root iff n | {m}*d.")
    for n in (2, 3, 4, 5, 7, 97):
        d = minimal_replication_depth(n, m)
        print(f"      n = {n:>3}:  minimal replication depth = n/gcd(n,{m}) = {d:>3}"
              f"   (check n | {m}*{d}?  {has_root_after_replication(m, n, d)})")
        assert has_root_after_replication(m, n, d)
        if d > 1:
            assert not has_root_after_replication(m, n, d - 1)
    print("\n    Highlights: the third replication IS a perfect cube (3 | 3*194);")
    print("    a fourth root needs only depth 2, since 2 | 194 does half the work;")
    print("    but no fifth root exists at depth 3, since 5 does not divide 582.")
    assert has_root_after_replication(m, 3, 3)
    assert has_root_after_replication(m, 4, 2)
    assert not has_root_after_replication(m, 5, 3)
    print()


def demo_dissolution() -> None:
    print("=" * 74)
    print("9.  DISSOLUTION over Q-exponents:  every n works")
    print("=" * 74)
    K = 6
    tails = [[Fraction(1), Fraction(2)], [Fraction(-1), Fraction(3)],
             [Fraction(4), Fraction(0)]]
    m = len(tails)
    for n in (2, 3, 5, 7):
        e, w = puiseux_root_of_normalized_product(tails, n, K)
        # verify w^n equals the corrected product to order K
        u: List[Fraction] = [Fraction(1)] + [Fraction(0)] * K
        for tail in tails:
            f = [Fraction(1)] + [Fraction(0)] * K
            for k, c in enumerate(tail):
                if k + 1 <= K:
                    f[k + 1] = Fraction(c)
            u = _poly_mul(u, f, K)
        check = _poly_pow(w, n, K)
        ok = check == u
        head = ", ".join(str(w[i]) for i in range(min(4, K + 1)))
        print(f"    n = {n}:  root exponent e = {e}   w = [{head}, ...]   w^n = U ?  {ok}")
        assert ok and e == Fraction(-m, n)
    print(f"\n    For the Monster-sized product the 194-th root has exponent"
          f" -194/194 = {Fraction(-MONSTER_CLASS_COUNT, MONSTER_CLASS_COUNT)}:")
    print("    a simple-pole series whose 194-th power is the whole product.")
    print()


def demo_interpolation() -> None:
    print("=" * 74)
    print("10. INTERPOLATION:  lattice (1/N)Z  <->  replication depth N")
    print("=" * 74)
    m = MONSTER_CLASS_COUNT
    print(f"    Criterion (lattice):     n-th root with exponents in (1/N)Z  iff  n | {m}*N")
    print(f"    Criterion (replication): n-th root of V_N(P)                 iff  n | {m}*N")
    print("    -> identical.  The two hierarchies are one invariant.\n")
    print(f"    {'n':>4} {'N':>4} {'-n crit. exponent':>20} {'in (1/N)Z':>11} "
          f"{'lattice root':>13} {'V_N root':>10}")
    for n, N in [(2, 1), (3, 1), (3, 3), (4, 1), (4, 2), (5, 1), (5, 5), (7, 7), (97, 1)]:
        e = critical_exponent(m, n)
        in_lattice = (e * N).denominator == 1
        lat = has_lattice_root(m, n, N)
        rep = has_root_after_replication(m, n, N)
        print(f"    {n:>4} {N:>4} {str(e):>20} {str(in_lattice):>11} "
              f"{str(lat):>13} {str(rep):>10}")
        assert in_lattice == lat == rep
    print("\n    N = 1 recovers the integer-exponent spectrum {1, 2, 97, 194};")
    print("    letting N absorb any denominator recovers full dissolution over Q.")
    print("    A cube root appears over (1/N)Z exactly when 3 | N:")
    for N in range(1, 10):
        print(f"      N = {N}:  cube root?  {has_lattice_root(m, 3, N)}"
              f"   (3 | N?  {N % 3 == 0})")
        assert has_lattice_root(m, 3, N) == (N % 3 == 0)
    print()


def main() -> None:
    print()
    print("#" * 74)
    print("#  THE POLE-ORDER OBSTRUCTION — numerical demonstrations".ljust(73) + "#")
    print("#" * 74)
    print()
    demo_pole_order()
    demo_root_spectrum()
    demo_power_classes()
    demo_additive_contrast()
    demo_rigidity()
    demo_filtration()
    demo_symmetric_functions()
    demo_replication()
    demo_dissolution()
    demo_interpolation()
    print("=" * 74)
    print("All demonstrations completed; every assertion held.")
    print("=" * 74)


if __name__ == "__main__":
    main()
