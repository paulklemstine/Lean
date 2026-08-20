"""
The two-parameter pm-frame: coefficients of binary cyclotomic polynomials
as lattice points in a balance box.

This self-contained script demonstrates, numerically, every result of the
accompanying paper:

  1. Phi_p = 1 + X + ... + X^{p-1}  (one-parameter case: coefficients in {0,1}).
  2. Coefficients of the frame geometry
        G_{p,q}(X) = (sum_{i<q} X^{ip}) * (sum_{j<p} X^{jq})
     count lattice points (i,j) of the balance box [0,q) x [0,p)
     on the line i*p + j*q = n, and equal 0 or 1 when gcd(p,q) = 1.
  3. The closed formula  Phi_{pq}(X) * (X^{pq} - 1) = (X - 1) * G_{p,q}(X).
  4. Migotti's theorem: every coefficient of Phi_{pq} lies in {-1, 0, 1}.
  5. Exact sign pattern: Phi_{pq}[n+1] = 1[n+1 in <p,q>] - 1[n in <p,q>].
  6. Sharpness: Phi_{pq}[0] = 1 and Phi_{pq}[1] = -1 for every semiprime;
     e.g. Phi_15[7] = -1.
  7. Balance: the coefficients of Phi_{pq} sum to 1.
  8. Sylvester symmetry and the gap count (p-1)(q-1)/2.
  9. Palindromicity: Phi_{pq}[k] = Phi_{pq}[D - k], D = (p-1)(q-1).
 10. The coprimality boundary: with steps 2 and 4 the line 2i + 4j = 4 meets
     the box [0,4) x [0,2) twice, so the frame geometry acquires a 2.
 11. The three-parameter breakdown: Phi_105 has the coefficient -2.

Run with:  python3 demo.py
Only the standard library is used.
"""

from __future__ import annotations

from typing import Dict, List, Tuple

Poly = List[int]  # dense coefficient list, index = exponent


# --------------------------------------------------------------------------
# Minimal integer polynomial arithmetic
# --------------------------------------------------------------------------


def poly_trim(a: Poly) -> Poly:
    """Remove trailing zero coefficients (keeping at least [0])."""
    b = list(a)
    while len(b) > 1 and b[-1] == 0:
        b.pop()
    return b


def poly_mul(a: Poly, b: Poly) -> Poly:
    """Multiply two integer polynomials given as dense coefficient lists."""
    out: Poly = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai == 0:
            continue
        for j, bj in enumerate(b):
            out[i + j] += ai * bj
    return poly_trim(out)


def poly_sub(a: Poly, b: Poly) -> Poly:
    """Subtract integer polynomials."""
    n = max(len(a), len(b))
    out = [0] * n
    for i in range(n):
        out[i] = (a[i] if i < len(a) else 0) - (b[i] if i < len(b) else 0)
    return poly_trim(out)


def poly_divexact(a: Poly, b: Poly) -> Poly:
    """Exact division of integer polynomials (b must divide a, b monic-ish)."""
    a = poly_trim(a)
    b = poly_trim(b)
    if b == [0]:
        raise ZeroDivisionError("division by the zero polynomial")
    quotient: Poly = [0] * max(1, len(a) - len(b) + 1)
    rem = list(a)
    lead = b[-1]
    for shift in range(len(a) - len(b), -1, -1):
        num = rem[shift + len(b) - 1]
        if num == 0:
            continue
        if num % lead != 0:
            raise ValueError("division is not exact")
        c = num // lead
        quotient[shift] = c
        for i, bi in enumerate(b):
            rem[shift + i] -= c * bi
    if any(r != 0 for r in rem):
        raise ValueError("division is not exact (nonzero remainder)")
    return poly_trim(quotient)


def poly_str(a: Poly, var: str = "X") -> str:
    """Human-readable rendering of a dense integer polynomial."""
    terms: List[str] = []
    for k in range(len(a) - 1, -1, -1):
        c = a[k]
        if c == 0:
            continue
        if k == 0:
            body = str(abs(c))
        elif k == 1:
            body = var if abs(c) == 1 else f"{abs(c)}{var}"
        else:
            body = f"{var}^{k}" if abs(c) == 1 else f"{abs(c)}{var}^{k}"
        sign = "-" if c < 0 else "+"
        terms.append(f" {sign} {body}")
    if not terms:
        return "0"
    s = "".join(terms).strip()
    return s[2:] if s.startswith("+ ") else s


# --------------------------------------------------------------------------
# Cyclotomic polynomials by the divisor factorisation X^n - 1 = prod_{d|n} Phi_d
# --------------------------------------------------------------------------


def divisors(n: int) -> List[int]:
    """All positive divisors of n, ascending."""
    return [d for d in range(1, n + 1) if n % d == 0]


def cyclotomic(n: int, cache: Dict[int, Poly] | None = None) -> Poly:
    """The n-th cyclotomic polynomial Phi_n, as a dense coefficient list."""
    if cache is None:
        cache = {}
    if n in cache:
        return cache[n]
    xn_minus_1: Poly = [0] * n + [1]
    xn_minus_1[0] = -1
    prod: Poly = [1]
    for d in divisors(n):
        if d < n:
            prod = poly_mul(prod, cyclotomic(d, cache))
    result = poly_divexact(xn_minus_1, prod)
    cache[n] = result
    return result


def coeff(a: Poly, k: int) -> int:
    """Coefficient of X^k, with zeros beyond the degree."""
    return a[k] if 0 <= k < len(a) else 0


# --------------------------------------------------------------------------
# The balance box and the frame geometry
# --------------------------------------------------------------------------


def rep_pairs(p: int, q: int, n: int) -> List[Tuple[int, int]]:
    """Lattice points (i,j) of the box [0,q) x [0,p) with i*p + j*q = n."""
    return [(i, j) for i in range(q) for j in range(p) if i * p + j * q == n]


def lattice_count(p: int, q: int, n: int) -> int:
    """g_{p,q}(n): the number of balance-box lattice points on i*p + j*q = n."""
    return len(rep_pairs(p, q, n))


def frame_geom(p: int, q: int) -> Poly:
    """G_{p,q}(X) = (sum_{i<q} X^{ip}) * (sum_{j<p} X^{jq})."""
    left: Poly = [0] * ((q - 1) * p + 1) if q > 0 else [0]
    for i in range(q):
        left[i * p] += 1
    right: Poly = [0] * ((p - 1) * q + 1) if p > 0 else [0]
    for j in range(p):
        right[j * q] += 1
    return poly_mul(poly_trim(left), poly_trim(right))


def in_semigroup(p: int, q: int, n: int) -> bool:
    """Is n representable as i*p + j*q with i, j >= 0?  (Apery-set test.)"""
    if n < 0:
        return False
    for j in range(0, n // q + 1):
        if (n - j * q) % p == 0:
            return True
    return False


def frobenius_number(p: int, q: int) -> int:
    """The Frobenius number pq - p - q of the coprime pair (p, q)."""
    return p * q - p - q


# --------------------------------------------------------------------------
# Algorithms from the paper
# --------------------------------------------------------------------------


def frame_coeffs_by_sieve(p: int, q: int) -> Poly:
    """Algorithm A: coefficients of Phi_{pq} in O(pq) by a semigroup sieve.

    Uses  Phi_{pq}[0] = 1  and  Phi_{pq}[k] = 1[k in <p,q>] - 1[k-1 in <p,q>].
    """
    n = p * q
    reachable = [False] * n
    reachable[0] = True
    for m in range(n):
        if not reachable[m]:
            continue
        if m + p < n:
            reachable[m + p] = True
        if m + q < n:
            reachable[m + q] = True
    degree = (p - 1) * (q - 1)
    out: Poly = [0] * (degree + 1)
    out[0] = 1 if reachable[0] else 0
    for k in range(1, degree + 1):
        out[k] = (1 if reachable[k] else 0) - (1 if reachable[k - 1] else 0)
    return out


def frame_coeff_query(p: int, q: int, k: int) -> int:
    """Algorithm B: a single coefficient of Phi_{pq} via semigroup membership."""
    if k < 0 or k > (p - 1) * (q - 1):
        return 0
    if k == 0:
        return 1
    return int(in_semigroup(p, q, k)) - int(in_semigroup(p, q, k - 1))


def frame_coeff_certificate(p: int, q: int, k: int) -> Tuple[int, List, List]:
    """Algorithm C: coefficient together with its lattice-point witnesses."""
    hi = rep_pairs(p, q, k)
    lo = rep_pairs(p, q, k - 1) if k >= 1 else []
    return len(hi) - len(lo), hi, lo


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def demo_one_parameter() -> None:
    print("=" * 74)
    print("1. ONE-PARAMETER CASE:  Phi_p = 1 + X + ... + X^{p-1}")
    print("=" * 74)
    for p in (2, 3, 5, 7, 11):
        c = cyclotomic(p)
        assert all(x in (0, 1) for x in c), "coefficients must be 0 or 1"
        assert c == [1] * p
        print(f"  Phi_{p:<3} = {poly_str(c)}")
    print("  All coefficients lie in {0,1}; in particular all are >= -1.\n")


def demo_lattice_counts() -> None:
    print("=" * 74)
    print("2. FRAME GEOMETRY COEFFICIENTS COUNT BALANCE-BOX LATTICE POINTS")
    print("=" * 74)
    p, q = 3, 5
    g = frame_geom(p, q)
    print(f"  p = {p}, q = {q}; balance box [0,{q}) x [0,{p}); G has degree {len(g)-1}")
    print("     n | [X^n] G | lattice points (i,j) with i*p + j*q = n")
    print("  -----+---------+----------------------------------------")
    for n in range(len(g)):
        pts = rep_pairs(p, q, n)
        assert coeff(g, n) == len(pts)
        assert len(pts) <= 1, "coprime lines meet the box at most once"
        print(f"  {n:4d} | {coeff(g,n):7d} | {pts}")
    print("  Every count is 0 or 1: the line is too steep to hit the box twice.\n")


def demo_closed_formula() -> None:
    print("=" * 74)
    print("3. CLOSED FORMULA:  Phi_pq (X^pq - 1) = (X - 1) G_{p,q}")
    print("=" * 74)
    for p, q in ((3, 5), (5, 7), (3, 11), (7, 11)):
        n = p * q
        xn: Poly = [0] * n + [1]
        xn[0] = -1
        lhs = poly_mul(cyclotomic(n), xn)
        rhs = poly_mul([-1, 1], frame_geom(p, q))
        assert lhs == rhs, (p, q)
        print(f"  p={p:2d}, q={q:2d}:  identity verified (degree {len(lhs)-1})")
    print()


def demo_migotti() -> None:
    print("=" * 74)
    print("4. MIGOTTI'S THEOREM:  coefficients of Phi_pq lie in {-1,0,1}")
    print("=" * 74)
    primes = [2, 3, 5, 7, 11, 13]
    worst = 0
    for a in range(len(primes)):
        for b in range(a + 1, len(primes)):
            p, q = primes[a], primes[b]
            c = cyclotomic(p * q)
            worst = min(worst, min(c))
            assert all(abs(x) <= 1 for x in c), (p, q, c)
    print(f"  Checked all products of two distinct primes from {primes}.")
    print(f"  Every coefficient lies in {{-1,0,1}}; minimum observed = {worst}.")
    print(f"  Phi_15 = {poly_str(cyclotomic(15))}")
    print(f"  Phi_35 = {poly_str(cyclotomic(35))}\n")


def demo_sign_pattern() -> None:
    print("=" * 74)
    print("5. EXACT SIGN PATTERN:  a discrete derivative of a semigroup")
    print("=" * 74)
    p, q = 3, 5
    c = cyclotomic(p * q)
    print(f"  p = {p}, q = {q}; semigroup <p,q> = payable amounts with coins {p},{q}")
    print("     k | k in <p,q> | k-1 in <p,q> | difference | Phi_15[k]")
    print("  -----+------------+--------------+------------+----------")
    for k in range(0, (p - 1) * (q - 1) + 1):
        hi = in_semigroup(p, q, k)
        lo = in_semigroup(p, q, k - 1) if k >= 1 else False
        diff = int(hi) - int(lo) if k >= 1 else 1
        assert diff == coeff(c, k)
        print(f"  {k:4d} | {str(hi):>10} | {str(lo):>12} | {diff:10d} | {coeff(c,k):9d}")
    F = frobenius_number(p, q)
    print(f"  The Frobenius number is {F}; indeed Phi_15[{F}] = {coeff(c,F)} "
          f"and Phi_15[{F-1}] = {coeff(c,F-1)}.\n")


def demo_sharpness() -> None:
    print("=" * 74)
    print("6. SHARPNESS FOR EVERY SEMIPRIME:  Phi_pq[0] = 1 and Phi_pq[1] = -1")
    print("=" * 74)
    primes = [2, 3, 5, 7, 11, 13, 17]
    for a in range(len(primes)):
        for b in range(a + 1, len(primes)):
            p, q = primes[a], primes[b]
            c = cyclotomic(p * q)
            assert coeff(c, 0) == 1 and coeff(c, 1) == -1, (p, q)
    print(f"  Verified for all pairs from {primes}:")
    print("  the amount 0 is always payable and 1 never is, so the linear")
    print("  coefficient is 0 - 1 = -1.  Hence -1 is the least coefficient value.")
    print(f"  Highlighted case:  Phi_15[7] = {coeff(cyclotomic(15), 7)}\n")


def demo_balance() -> None:
    print("=" * 74)
    print("7. BALANCE LAW:  the coefficients of Phi_pq sum to 1")
    print("=" * 74)
    for p, q in ((3, 5), (5, 7), (3, 11), (11, 13)):
        c = cyclotomic(p * q)
        plus = sum(1 for x in c if x == 1)
        minus = sum(1 for x in c if x == -1)
        assert sum(c) == 1 and plus - minus == 1
        print(f"  p={p:2d}, q={q:2d}:  #(+1) = {plus:3d}, #(-1) = {minus:3d}, "
              f"sum = {sum(c)}")
    print()


def demo_sylvester() -> None:
    print("=" * 74)
    print("8. SYLVESTER SYMMETRY AND THE GAP COUNT")
    print("=" * 74)
    for p, q in ((3, 5), (5, 7), (3, 11), (7, 11)):
        F = frobenius_number(p, q)
        for n in range(F + 1):
            assert lattice_count(p, q, n) + lattice_count(p, q, F - n) == 1
        D = (p - 1) * (q - 1)
        gaps = [n for n in range(D) if lattice_count(p, q, n) == 0]
        assert 2 * len(gaps) == D
        print(f"  p={p:2d}, q={q:2d}:  F = {F:3d}, D = {D:3d}, "
              f"gaps = {len(gaps):3d} = D/2")
    print("  For 3,5 the gaps below D = 8 are "
          f"{[n for n in range(8) if lattice_count(3,5,n)==0]}\n")


def demo_palindromicity() -> None:
    print("=" * 74)
    print("9. PALINDROMICITY:  Phi_pq[k] = Phi_pq[D - k]")
    print("=" * 74)
    for p, q in ((3, 5), (5, 7), (3, 13), (11, 13)):
        c = cyclotomic(p * q)
        D = (p - 1) * (q - 1)
        assert all(coeff(c, k) == coeff(c, D - k) for k in range(D + 1))
        print(f"  p={p:2d}, q={q:2d}:  self-reciprocal of degree {D}")
    print(f"  Phi_15 coefficient vector: {cyclotomic(15)}\n")


def demo_algorithms() -> None:
    print("=" * 74)
    print("10. ALGORITHMS:  sieve, O(1) query, and lattice-point certificate")
    print("=" * 74)
    p, q = 7, 11
    exact = cyclotomic(p * q)
    sieved = frame_coeffs_by_sieve(p, q)
    assert sieved == exact
    print(f"  Sieve reproduces Phi_{p*q} exactly (degree {(p-1)*(q-1)}).")
    for k in (0, 1, 7, 11, 18, 30, 59, 60):
        assert frame_coeff_query(p, q, k) == coeff(exact, k)
    print("  Direct queries agree with the full computation.")
    val, hi, lo = frame_coeff_certificate(3, 5, 7)
    print(f"  Certificate for Phi_15[7]: points on 3i+5j=7 in the box: {hi}; "
          f"on 3i+5j=6: {lo};")
    print(f"  coefficient = |{len(hi)}| - |{len(lo)}| = {val}\n")


def demo_coprimality_boundary() -> None:
    print("=" * 74)
    print("11. THE COPRIMALITY BOUNDARY:  steps 2 and 4")
    print("=" * 74)
    pts = rep_pairs(2, 4, 4)
    g = frame_geom(2, 4)
    assert len(pts) == 2 and coeff(g, 4) == 2
    print(f"  Lattice points of [0,4) x [0,2) on 2i + 4j = 4:  {pts}")
    print(f"  Hence [X^4] G_(2,4) = {coeff(g,4)} -- the multiplicity bound fails")
    print("  as soon as the two steps are not coprime.\n")


def demo_three_parameters() -> None:
    print("=" * 74)
    print("12. THREE PARAMETERS:  the bound breaks at 105 = 3 * 5 * 7")
    print("=" * 74)
    c105 = cyclotomic(105)
    lo = min(c105)
    where = [k for k, x in enumerate(c105) if x == lo]
    assert lo == -2
    print(f"  Phi_105 has degree {len(c105)-1} and minimum coefficient {lo}")
    print(f"  attained at exponents {where}.")
    for n in (3, 5, 7, 15, 21, 35, 105, 165, 195, 231, 385):
        c = cyclotomic(n)
        print(f"    n = {n:4d}:  min coeff = {min(c):3d},  max coeff = {max(c):3d}")
    print("  Two coprime steps give a line in a rectangle (multiplicity 1);")
    print("  three give a plane in a box, where multiplicity 1 is not forced.\n")


def main() -> None:
    print()
    print("#" * 74)
    print("#  THE TWO-PARAMETER PM-FRAME: LATTICE POINTS IN A BALANCE BOX")
    print("#" * 74)
    print()
    demo_one_parameter()
    demo_lattice_counts()
    demo_closed_formula()
    demo_migotti()
    demo_sign_pattern()
    demo_sharpness()
    demo_balance()
    demo_sylvester()
    demo_palindromicity()
    demo_algorithms()
    demo_coprimality_boundary()
    demo_three_parameters()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
