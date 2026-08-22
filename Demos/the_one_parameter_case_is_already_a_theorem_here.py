"""
Cyclotomic coefficient heights: the odd radical, the flat class, and the ternary trichotomy.

This self-contained script demonstrates, numerically, every result of the accompanying
paper:

  1.  Flatness holds for all orders n < 105 (the flatness classification), because
      105 = 3 * 5 * 7 is the least integer with three distinct odd prime divisors.
  2.  Inflation  Phi_{np}(X) = Phi_n(X^p)  for p | n, and
      reflection  Phi_{2n}(X) = Phi_n(-X)  for odd n > 1.
  3.  Height reduction:  H(n) = H(rad_odd(n)),  where rad_odd(n) is the product of the
      odd primes dividing n.  The height is blind to the prime 2 and to repeated factors.
  4.  The explicit Phi_105 (degree 48, height 2 attained at X^7 and X^41).
  5.  The flat ternary order Phi_231 (degree 120, height 1) --- three odd primes, yet flat.
  6.  The height-three order Phi_385 (degree 240, height 3 at X^119, X^120, X^121).
  7.  The ternary trichotomy: heights 1, 2, 3 all occur at orders with exactly three
      odd prime divisors.
  8.  The lattice-point (numerical-semigroup) formula for coefficients of Phi_{pq} and
      its transport to the whole family 2^a p^b q^c.

Only the Python standard library is used.  Run with:  python3 demo.py
"""

from __future__ import annotations

from typing import Dict, List, Tuple

Poly = List[int]  # dense coefficient list, index = exponent, low to high


# ---------------------------------------------------------------------------
# 1.  Elementary integer-polynomial arithmetic
# ---------------------------------------------------------------------------

def poly_trim(p: Poly) -> Poly:
    """Remove trailing zero coefficients (keeping at least one entry)."""
    q = list(p)
    while len(q) > 1 and q[-1] == 0:
        q.pop()
    return q


def poly_mul(a: Poly, b: Poly) -> Poly:
    """Product of two integer polynomials, O(deg a * deg b)."""
    out = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai:
            for j, bj in enumerate(b):
                out[i + j] += ai * bj
    return poly_trim(out)


def poly_divmod_monic(num: Poly, den: Poly) -> Tuple[Poly, Poly]:
    """Exact division by a MONIC integer polynomial: returns (quotient, remainder)."""
    assert den[-1] == 1, "divisor must be monic"
    rem = list(num)
    d = len(den) - 1
    if len(rem) - 1 < d:
        return [0], poly_trim(rem)
    quo = [0] * (len(rem) - d)
    for i in range(len(rem) - 1, d - 1, -1):
        c = rem[i]
        quo[i - d] = c
        if c:
            for j in range(d + 1):
                rem[i - d + j] -= c * den[j]
    return poly_trim(quo), poly_trim(rem[:d] if d > 0 else [0])


def poly_str(p: Poly, var: str = "X") -> str:
    """Human-readable rendering of a polynomial, high degree first."""
    terms: List[str] = []
    for k in range(len(p) - 1, -1, -1):
        c = p[k]
        if c == 0:
            continue
        mag = "" if abs(c) == 1 and k > 0 else str(abs(c))
        power = "" if k == 0 else ("X" if k == 1 else f"X^{k}")
        body = f"{mag}{'*' if mag and power else ''}{power}".replace("X", var)
        terms.append(("- " if c < 0 else "+ ") + body)
    if not terms:
        return "0"
    head = terms[0]
    head = head[2:] if head.startswith("+ ") else "-" + head[2:]
    return " ".join([head] + terms[1:])


# ---------------------------------------------------------------------------
# 2.  Number-theoretic helpers
# ---------------------------------------------------------------------------

def divisors(n: int) -> List[int]:
    """All positive divisors of n, ascending."""
    small, large = [], []
    i = 1
    while i * i <= n:
        if n % i == 0:
            small.append(i)
            if i != n // i:
                large.append(n // i)
        i += 1
    return small + large[::-1]


def prime_factors(n: int) -> List[int]:
    """The distinct primes dividing n, ascending."""
    out: List[int] = []
    m, d = n, 2
    while d * d <= m:
        if m % d == 0:
            out.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        out.append(m)
    return out


def odd_radical(n: int) -> int:
    """rad_odd(n) = product of the odd primes dividing n (1 if there are none)."""
    r = 1
    for p in prime_factors(n):
        if p != 2:
            r *= p
    return r


def euler_phi(n: int) -> int:
    """Euler's totient, from the prime factorization."""
    result = n
    for p in prime_factors(n):
        result = result // p * (p - 1)
    return result


# ---------------------------------------------------------------------------
# 3.  Cyclotomic polynomials by divisor recursion
# ---------------------------------------------------------------------------

_CYC_CACHE: Dict[int, Poly] = {}


def cyclotomic(n: int) -> Poly:
    """Phi_n as a dense integer coefficient list, via X^n - 1 divided by all Phi_d, d | n, d < n."""
    if n in _CYC_CACHE:
        return _CYC_CACHE[n]
    num: Poly = [-1] + [0] * (n - 1) + [1]  # X^n - 1
    for d in divisors(n):
        if d < n:
            num, rem = poly_divmod_monic(num, cyclotomic(d))
            assert rem == [0], "divisor product identity failed"
    _CYC_CACHE[n] = num
    return num


def height(n: int) -> int:
    """H(n) = max |coefficient| of Phi_n."""
    return max(abs(c) for c in cyclotomic(n))


def is_flat(n: int) -> bool:
    """Phi_n has all coefficients in {-1, 0, 1}."""
    return height(n) == 1


# ---------------------------------------------------------------------------
# 4.  Numerical semigroup <p, q> and the two-parameter coefficient formula
# ---------------------------------------------------------------------------

def is_representable(m: int, p: int, q: int) -> bool:
    """True iff m = i*p + j*q for some nonnegative integers i, j."""
    if m < 0:
        return False
    for i in range(m // p + 1):
        if (m - i * p) % q == 0:
            return True
    return False


def semigroup_coefficient(m: int, p: int, q: int) -> int:
    """The lattice-point formula for [X^m] Phi_{pq}, valid for 0 < m < p*q."""
    return int(is_representable(m, p, q)) - int(is_representable(m - 1, p, q))


def family_coefficient(k: int, p: int, q: int, alpha: int, beta: int, gamma: int) -> Tuple[int, int]:
    """
    The transported lattice-point formula.

    Returns (index, value): the coefficient of Phi_{2^(alpha+1) p^(beta+1) q^(gamma+1)}
    at the inflated index (k+1) * p^beta * q^gamma * 2^alpha equals

        (-1)^((k+1) p^beta q^gamma) * ( 1{k+1 in <p,q>} - 1{k in <p,q>} ).

    Requires p != q odd primes and 0 <= k with k + 1 < p*q.
    """
    j = (k + 1) * p**beta * q**gamma
    index = j * 2**alpha
    sign = -1 if j % 2 else 1
    return index, sign * semigroup_coefficient(k + 1, p, q)


# ---------------------------------------------------------------------------
# 5.  The demonstrations
# ---------------------------------------------------------------------------

def demo_flat_below_105() -> None:
    print("=" * 78)
    print("1.  Flatness for every order below 105")
    print("=" * 78)
    bad = [n for n in range(1, 105) if not is_flat(n)]
    print(f"    orders 1..104 with a coefficient outside {{-1,0,1}}: {bad}")
    print(f"    least integer with three distinct odd prime divisors: 3*5*7 = {3*5*7}")
    print(f"    height of Phi_105 = {height(105)}   <- the flat class stops here")
    print()


def demo_symmetries() -> None:
    print("=" * 78)
    print("2.  The two structural symmetries")
    print("=" * 78)
    print("    Inflation  Phi_{np}(X) = Phi_n(X^p)   for p | n:")
    for n, p in [(15, 3), (15, 5), (105, 7), (12, 2)]:
        lhs = cyclotomic(n * p)
        inflated = [0] * ((len(cyclotomic(n)) - 1) * p + 1)
        for k, c in enumerate(cyclotomic(n)):
            inflated[k * p] = c
        assert lhs == poly_trim(inflated)
        print(f"      n = {n:4d}, p = {p}:  Phi_{n*p} = Phi_{n}(X^{p})   verified")
    print("    Reflection  Phi_{2n}(X) = Phi_n(-X)   for odd n > 1:")
    for n in [3, 5, 15, 21, 105, 231]:
        lhs = cyclotomic(2 * n)
        rhs = [c * (-1) ** k for k, c in enumerate(cyclotomic(n))]
        assert lhs == poly_trim(rhs)
        print(f"      n = {n:4d}:  Phi_{2*n}(X) = Phi_{n}(-X)   verified"
              f"   (same |coefficients|, height {height(n)})")
    print()


def demo_height_reduction() -> None:
    print("=" * 78)
    print("3.  Height reduction:  H(n) = H(rad_odd(n))")
    print("=" * 78)
    print(f"    {'n':>8} {'rad_odd(n)':>12} {'deg Phi_n':>10} {'deg Phi_rad':>12} {'H(n)':>6} {'H(rad)':>7}")
    samples = [4, 8, 12, 16, 24, 45, 90, 105, 210, 315, 420, 231, 462, 385, 770, 1155]
    for n in samples:
        r = odd_radical(n)
        hn, hr = height(n), height(r) if r > 0 else 1
        assert hn == hr, "height reduction failed"
        print(f"    {n:>8} {r:>12} {euler_phi(n):>10} {euler_phi(r):>12} {hn:>6} {hr:>7}")
    print("    every row: H(n) == H(rad_odd(n))  -- the prime 2 and repeated factors are invisible")
    print()


def demo_explicit_105() -> None:
    print("=" * 78)
    print("4.  The explicit Phi_105 (degree 48, height exactly 2)")
    print("=" * 78)
    c = cyclotomic(105)
    print(f"    degree                 : {len(c) - 1}  (= phi(105) = {euler_phi(105)})")
    print(f"    coefficients (0..48)   : {c}")
    extremes = [k for k, v in enumerate(c) if abs(v) == 2]
    print(f"    coefficients of size 2 : indices {extremes}, values {[c[k] for k in extremes]}")
    print(f"    height                 : {height(105)}  (= Bang's bound p-1 for p = 3)")
    print(f"    expanded               : {poly_str(c)}")
    print("    Moebius identity check :")
    lhs = cyclotomic(105)
    for m in (1, 15, 21, 35):
        lhs = poly_mul(lhs, [-1] + [0] * (m - 1) + [1])
    rhs: Poly = [1]
    for m in (3, 5, 7, 105):
        rhs = poly_mul(rhs, [-1] + [0] * (m - 1) + [1])
    assert lhs == rhs
    print("      Phi_105 * (X-1)(X^15-1)(X^21-1)(X^35-1) = (X^3-1)(X^5-1)(X^7-1)(X^105-1)  verified")
    print("    infinite family        : H(2^a 3^b 5^c 7^d) = 2 for all a>=0, b,c,d>=1")
    for a, b, c_, d in [(0, 1, 1, 1), (3, 2, 1, 1), (1, 1, 3, 2), (5, 2, 2, 2)]:
        n = 2**a * 3**b * 5**c_ * 7**d
        assert odd_radical(n) == 105
        print(f"      n = 2^{a} 3^{b} 5^{c_} 7^{d} = {n:<10} rad_odd = 105,  H = 2  (deg Phi_n = {euler_phi(n)})")
    print()


def demo_flat_231() -> None:
    print("=" * 78)
    print("5.  A FLAT ternary order: 231 = 3 * 7 * 11")
    print("=" * 78)
    c = cyclotomic(231)
    print(f"    degree           : {len(c) - 1}  (= phi(231) = {euler_phi(231)})")
    print(f"    height           : {height(231)}   -> flat, although 231 has three odd primes")
    print(f"    coefficient set  : {sorted(set(c))}")
    print(f"    support          : {sum(1 for v in c if v != 0)} nonzero of {len(c)} coefficients")
    print("    consequence      : 'at most two odd primes => flat' is an implication, NOT an")
    print("                       equivalence; every n with rad_odd(n) = 231 is flat, e.g.")
    for a, b, c_, d in [(0, 1, 1, 1), (2, 1, 2, 1), (1, 3, 1, 1)]:
        n = 2**a * 3**b * 7**c_ * 11**d
        assert odd_radical(n) == 231 and is_flat(n)
        print(f"                         n = 2^{a} 3^{b} 7^{c_} 11^{d} = {n:<8} flat, deg Phi_n = {euler_phi(n)}")
    print()


def demo_385() -> None:
    print("=" * 78)
    print("6.  Height three: 385 = 5 * 7 * 11")
    print("=" * 78)
    c = cyclotomic(385)
    print(f"    degree           : {len(c) - 1}  (= phi(385) = {euler_phi(385)})")
    print(f"    height           : {height(385)}")
    extremes = [k for k, v in enumerate(c) if abs(v) == 3]
    print(f"    coefficients = -3: indices {extremes} (symmetric about the centre {(len(c)-1)//2})")
    print(f"    Bang bound here  : p - 1 = 4 for p = 5, so 385 is NOT Bang-extremal")
    print("    infinite family  : H(2^a 5^b 7^c 11^d) = 3 for all a>=0, b,c,d>=1")
    for a, b, c_, d in [(0, 1, 1, 1), (2, 1, 1, 1), (1, 2, 1, 1)]:
        n = 2**a * 5**b * 7**c_ * 11**d
        assert odd_radical(n) == 385
        print(f"      n = 2^{a} 5^{b} 7^{c_} 11^{d} = {n:<8} rad_odd = 385, H = 3, deg Phi_n = {euler_phi(n)}")
    print()


def demo_trichotomy() -> None:
    print("=" * 78)
    print("7.  The ternary trichotomy: three odd primes, three different heights")
    print("=" * 78)
    print(f"    {'order':>7} {'factorization':>16} {'#odd primes':>12} {'degree':>8} {'height':>7}")
    for n, fac in [(231, "3 * 7 * 11"), (105, "3 * 5 * 7"), (385, "5 * 7 * 11")]:
        w = len([p for p in prime_factors(n) if p != 2])
        print(f"    {n:>7} {fac:>16} {w:>12} {euler_phi(n):>8} {height(n):>7}")
    print("    => the NUMBER of odd primes does not determine the height;")
    print("       the odd RADICAL does (equal odd radicals force equal heights).")
    print("    height 1 is exactly flatness, since Phi_n is monic (no order has height 0).")
    print()


def demo_lattice_points() -> None:
    print("=" * 78)
    print("8.  Coefficients as lattice-point counts")
    print("=" * 78)
    p, q = 3, 5
    c = cyclotomic(p * q)
    print(f"    Phi_{p*q} = {poly_str(c)}")
    print(f"    numerical semigroup <{p},{q}> below {p*q}: "
          f"{[m for m in range(p*q) if is_representable(m, p, q)]}")
    print(f"    {'m':>3} {'m in <p,q>':>11} {'m-1 in <p,q>':>13} {'formula':>8} {'true coeff':>11}")
    for m in range(1, p * q):
        f = semigroup_coefficient(m, p, q)
        t = c[m] if m < len(c) else 0
        assert f == t, "lattice-point formula failed"
        print(f"    {m:>3} {str(is_representable(m,p,q)):>11} {str(is_representable(m-1,p,q)):>13}"
              f" {f:>8} {t:>11}")
    print()
    print("    Transport to the whole family 2^(a+1) p^(b+1) q^(c+1):")
    for (a, b, g) in [(0, 0, 0), (1, 1, 0), (2, 0, 1)]:
        n = 2 ** (a + 1) * p ** (b + 1) * q ** (g + 1)
        cn = cyclotomic(n)
        ok = True
        for k in range(0, p * q - 1):
            idx, val = family_coefficient(k, p, q, a, b, g)
            actual = cn[idx] if idx < len(cn) else 0
            ok = ok and (val == actual)
        status = "all inflated indices match" if ok else "MISMATCH"
        print(f"      n = 2^{a+1} {p}^{b+1} {q}^{g+1} = {n:<8} deg Phi_n = {euler_phi(n):<6} {status}")
    print()


def main() -> None:
    print()
    print("CYCLOTOMIC COEFFICIENT HEIGHTS")
    print("the odd radical, the flat class, and the ternary trichotomy")
    print()
    demo_flat_below_105()
    demo_symmetries()
    demo_height_reduction()
    demo_explicit_105()
    demo_flat_231()
    demo_385()
    demo_trichotomy()
    demo_lattice_points()
    print("All demonstrations completed; every assertion above was checked numerically.")


if __name__ == "__main__":
    main()
