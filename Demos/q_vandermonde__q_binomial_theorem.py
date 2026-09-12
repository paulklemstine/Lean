"""
Gaussian binomial coefficients: numerical demonstrations
========================================================

Self-contained numerical companion to the results on the q-Pascal recurrences,
Rothe's q-binomial theorem, the q-Vandermonde convolution and their corollaries
(Gauss product formula, symmetry, Gauss' alternating sum, Galois numbers and the
Goldman-Rota recurrence, the Rogers-Szego ladder, Cauchy's reciprocal q-binomial
theorem, the q-Lucas theorem, and the Grassmannian interpretation).

Everything is exact: a polynomial in q with integer coefficients is represented
as a tuple of integers, index i holding the coefficient of q^i.  No external
dependencies are used.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Sequence, Tuple

Poly = Tuple[int, ...]  # index i  <->  coefficient of q^i

# ----------------------------------------------------------------------------
# Minimal exact polynomial arithmetic over Z[q]
# ----------------------------------------------------------------------------

ZERO: Poly = ()
ONE: Poly = (1,)


def trim(p: Sequence[int]) -> Poly:
    """Strip trailing zero coefficients so that equality is structural."""
    out = list(p)
    while out and out[-1] == 0:
        out.pop()
    return tuple(out)


def padd(p: Poly, r: Poly) -> Poly:
    """Sum of two polynomials."""
    n = max(len(p), len(r))
    return trim([(p[i] if i < len(p) else 0) + (r[i] if i < len(r) else 0) for i in range(n)])


def psub(p: Poly, r: Poly) -> Poly:
    """Difference of two polynomials."""
    n = max(len(p), len(r))
    return trim([(p[i] if i < len(p) else 0) - (r[i] if i < len(r) else 0) for i in range(n)])


def pmul(p: Poly, r: Poly) -> Poly:
    """Product of two polynomials."""
    if not p or not r:
        return ZERO
    out = [0] * (len(p) + len(r) - 1)
    for i, a in enumerate(p):
        if a:
            for j, b in enumerate(r):
                out[i + j] += a * b
    return trim(out)


def pscale(c: int, p: Poly) -> Poly:
    """Multiply a polynomial by an integer constant."""
    return trim([c * a for a in p])


def qpow(e: int) -> Poly:
    """The monomial q^e."""
    return tuple([0] * e + [1])


def peval(p: Poly, q: int) -> int:
    """Evaluate a polynomial at an integer point (Horner)."""
    acc = 0
    for a in reversed(p):
        acc = acc * q + a
    return acc


def pstr(p: Poly) -> str:
    """Human-readable rendering of a polynomial in q."""
    if not p:
        return "0"
    parts: List[str] = []
    for i, a in enumerate(p):
        if a == 0:
            continue
        mono = "" if i == 0 else ("q" if i == 1 else f"q^{i}")
        if mono == "":
            parts.append(str(a))
        elif a == 1:
            parts.append(mono)
        elif a == -1:
            parts.append("-" + mono)
        else:
            parts.append(f"{a}{mono}")
    return " + ".join(parts).replace("+ -", "- ")


# ----------------------------------------------------------------------------
# Gaussian binomial coefficients via the first q-Pascal recurrence
# ----------------------------------------------------------------------------

_QB_CACHE: Dict[Tuple[int, int], Poly] = {}


def qbinom(n: int, k: int) -> Poly:
    """The Gaussian binomial coefficient [n, k]_q as an element of Z[q].

    Defined by the division-free recursion
        [n, 0] = 1,        [0, k+1] = 0,
        [n+1, k+1] = [n, k] + q^{k+1} [n, k+1].
    """
    if k < 0 or n < 0:
        return ZERO
    if k == 0:
        return ONE
    if n == 0:
        return ZERO
    key = (n, k)
    if key not in _QB_CACHE:
        _QB_CACHE[key] = padd(qbinom(n - 1, k - 1), pmul(qpow(k), qbinom(n - 1, k)))
    return _QB_CACHE[key]


def qpoch(m: int) -> Poly:
    """The q-Pochhammer symbol (q; q)_m = prod_{i=1..m} (1 - q^i)."""
    out = ONE
    for i in range(1, m + 1):
        out = pmul(out, psub(ONE, qpow(i)))
    return out


def binom(n: int, k: int) -> int:
    """Ordinary binomial coefficient."""
    if k < 0 or k > n:
        return 0
    num, den = 1, 1
    for i in range(k):
        num *= n - i
        den *= i + 1
    return num // den


def c2(k: int) -> int:
    """The triangular exponent k(k-1)/2."""
    return k * (k - 1) // 2


# ----------------------------------------------------------------------------
# Reporting helpers
# ----------------------------------------------------------------------------

FAILURES: List[str] = []


def check(label: str, lhs, rhs) -> None:
    """Assert an exact identity and print the outcome."""
    ok = lhs == rhs
    if not ok:
        FAILURES.append(label)
    print(f"  [{'OK ' if ok else 'BAD'}] {label}")


def banner(title: str) -> None:
    print("\n" + title)
    print("-" * len(title))


# ----------------------------------------------------------------------------
# 1.  The Gaussian triangle and the two q-Pascal recurrences
# ----------------------------------------------------------------------------

def demo_triangle(nmax: int = 6) -> None:
    banner("1. The Gaussian triangle  [n,k]_q  (rows n = 0..%d)" % nmax)
    for n in range(nmax + 1):
        row = "   ".join(pstr(qbinom(n, k)) for k in range(n + 1))
        print(f"  n={n}:  {row}")

    banner("1b. Both q-Pascal recurrences")
    for n in range(7):
        for k in range(7):
            check_a = padd(qbinom(n, k), pmul(qpow(k + 1), qbinom(n, k + 1)))
            check_b = padd(pmul(qpow(max(n - k, 0)), qbinom(n, k)), qbinom(n, k + 1))
            if qbinom(n + 1, k + 1) != check_a or qbinom(n + 1, k + 1) != check_b:
                FAILURES.append(f"q-Pascal at (n,k)=({n},{k})")
    print("  [OK ] [n+1,k+1] = [n,k] + q^{k+1}[n,k+1]        for 0 <= n,k <= 6")
    print("  [OK ] [n+1,k+1] = q^{n-k}[n,k] + [n,k+1]        for 0 <= n,k <= 6")
    print("  [OK ] degree of [n,k]_q equals k(n-k), leading coefficient 1:")
    for (n, k) in [(4, 2), (5, 2), (6, 3), (7, 3)]:
        p = qbinom(n, k)
        assert len(p) - 1 == k * (n - k) and p[-1] == 1 and all(a >= 0 for a in p)
        print(f"        [{n},{k}]_q = {pstr(p)}   (degree {len(p) - 1} = {k}*{n - k})")


# ----------------------------------------------------------------------------
# 2.  Rothe's q-binomial theorem
# ----------------------------------------------------------------------------

def rothe_lhs(n: int) -> List[Poly]:
    """Coefficients in x of prod_{i<n} (1 + q^i x); entry k is a polynomial in q."""
    coeffs: List[Poly] = [ONE]
    for i in range(n):
        new: List[Poly] = [ZERO] * (len(coeffs) + 1)
        for k, c in enumerate(coeffs):
            new[k] = padd(new[k], c)
            new[k + 1] = padd(new[k + 1], pmul(qpow(i), c))
        coeffs = new
    return coeffs


def demo_rothe(nmax: int = 7) -> None:
    banner("2. Rothe's q-binomial theorem:  prod_{i<n}(1+q^i x) = sum_k q^{k(k-1)/2} [n,k]_q x^k")
    for n in range(nmax + 1):
        lhs = rothe_lhs(n)
        rhs = [pmul(qpow(c2(k)), qbinom(n, k)) for k in range(n + 1)]
        check(f"n = {n}", lhs, rhs)
    print("  Example n = 4, coefficient of x^2:",
          pstr(rothe_lhs(4)[2]), "=  q^1 * (", pstr(qbinom(4, 2)), ")")


# ----------------------------------------------------------------------------
# 3.  The q-Vandermonde convolution
# ----------------------------------------------------------------------------

def qvandermonde_rhs(m: int, n: int, k: int) -> Poly:
    """sum_{j<=k} q^{(m-j)(k-j)} [m,j]_q [n,k-j]_q  (truncated subtraction m-j)."""
    total: Poly = ZERO
    for j in range(k + 1):
        term = pmul(qpow(max(m - j, 0) * (k - j)), pmul(qbinom(m, j), qbinom(n, k - j)))
        total = padd(total, term)
    return total


def qvandermonde_reflected(m: int, n: int, k: int) -> Poly:
    """The reflected form  sum_{j<=k} q^{j(n-(k-j))} [m,j]_q [n,k-j]_q."""
    total: Poly = ZERO
    for j in range(k + 1):
        e = j * max(n - (k - j), 0)
        total = padd(total, pmul(qpow(e), pmul(qbinom(m, j), qbinom(n, k - j))))
    return total


def demo_vandermonde(bound: int = 6) -> None:
    banner("3. q-Vandermonde:  [m+n,k]_q = sum_j q^{(m-j)(k-j)} [m,j]_q [n,k-j]_q")
    bad = 0
    for m in range(bound + 1):
        for n in range(bound + 1):
            for k in range(m + n + 2):
                if qbinom(m + n, k) != qvandermonde_rhs(m, n, k):
                    bad += 1
    check(f"all 0 <= m,n <= {bound} and 0 <= k <= m+n+1", bad, 0)

    bad = 0
    for m in range(bound + 1):
        for n in range(bound + 1):
            for k in range(m + n + 2):
                if qbinom(m + n, k) != qvandermonde_reflected(m, n, k):
                    bad += 1
    check("reflected form  q^{j(n-(k-j))}", bad, 0)

    print("  Worked example  m = n = 2, k = 2:")
    for j in range(3):
        print(f"    j={j}:  q^{max(2 - j, 0) * (2 - j)} * [2,{j}]_q * [2,{2 - j}]_q"
              f"  =  {pstr(pmul(qpow(max(2 - j, 0) * (2 - j)), pmul(qbinom(2, j), qbinom(2, 2 - j))))}")
    print("    sum  =", pstr(qvandermonde_rhs(2, 2, 2)), " =  [4,2]_q =", pstr(qbinom(4, 2)))

    banner("3b. q = 1 degenerates to the classical Vandermonde convolution")
    bad = 0
    for m in range(8):
        for n in range(8):
            for k in range(m + n + 1):
                if binom(m + n, k) != sum(binom(m, j) * binom(n, k - j) for j in range(k + 1)):
                    bad += 1
    check("C(m+n,k) = sum_j C(m,j) C(n,k-j)", bad, 0)

    banner("3c. q-analogue of  sum_j C(n,j)^2 = C(2n,n)")
    for n in range(7):
        rhs = ZERO
        for j in range(n + 1):
            rhs = padd(rhs, pmul(qpow((n - j) ** 2), pmul(qbinom(n, j), qbinom(n, j))))
        check(f"[2n,n]_q = sum_j q^{{(n-j)^2}} [n,j]_q^2   (n = {n})", qbinom(2 * n, n), rhs)


# ----------------------------------------------------------------------------
# 4.  Gauss product formula, symmetry, alternating sum
# ----------------------------------------------------------------------------

def demo_gauss() -> None:
    banner("4. Division-free Gauss product formula:  [n,k]_q (q;q)_k (q;q)_{n-k} = (q;q)_n")
    bad = 0
    for n in range(8):
        for k in range(n + 1):
            if pmul(pmul(qbinom(n, k), qpoch(k)), qpoch(n - k)) != qpoch(n):
                bad += 1
    check("all 0 <= k <= n <= 7", bad, 0)

    banner("4b. Symmetry  [n,k]_q = [n,n-k]_q")
    bad = sum(1 for n in range(9) for k in range(n + 1) if qbinom(n, k) != qbinom(n, n - k))
    check("all 0 <= k <= n <= 8", bad, 0)

    banner("4c. Gauss' alternating sum:  sum_k (-1)^k q^{k(k-1)/2} [n,k]_q = 0  for n >= 1")
    for n in range(1, 9):
        s: Poly = ZERO
        for k in range(n + 1):
            s = padd(s, pscale((-1) ** k, pmul(qpow(c2(k)), qbinom(n, k))))
        check(f"n = {n}", s, ZERO)


# ----------------------------------------------------------------------------
# 5.  Galois numbers, Rogers-Szego ladder, Gauss' evaluations at x = -1
# ----------------------------------------------------------------------------

def qgalois(n: int) -> Poly:
    """The Galois number G_n = sum_{k<=n} [n,k]_q."""
    out: Poly = ZERO
    for k in range(n + 1):
        out = padd(out, qbinom(n, k))
    return out


def qrs_at(x: int, n: int) -> Poly:
    """The Rogers-Szego polynomial H_n(x) = sum_k [n,k]_q x^k evaluated at integer x."""
    out: Poly = ZERO
    for k in range(n + 1):
        out = padd(out, pscale(x ** k, qbinom(n, k)))
    return out


def demo_galois() -> None:
    banner("5. Galois numbers G_n = sum_k [n,k]_q  (total subspace counts)")
    for n in range(6):
        g = qgalois(n)
        print(f"  G_{n}(q) = {pstr(g)}     G_{n}(2) = {peval(g, 2)}   G_{n}(3) = {peval(g, 3)}")

    banner("5b. Goldman-Rota recurrence:  G_{n+2} = 2 G_{n+1} + (q^{n+1} - 1) G_n")
    for n in range(7):
        rhs = padd(pscale(2, qgalois(n + 1)), pmul(psub(qpow(n + 1), ONE), qgalois(n)))
        check(f"n = {n}", qgalois(n + 2), rhs)

    banner("5c. Rogers-Szego ladder:  H_{n+2}(x) = (1+x)H_{n+1}(x) + (q^{n+1}-1) x H_n(x)")
    for x in (-1, 1, 2, 5):
        bad = 0
        for n in range(7):
            lhs = qrs_at(x, n + 2)
            rhs = padd(pscale(1 + x, qrs_at(x, n + 1)),
                       pmul(psub(qpow(n + 1), ONE), pscale(x, qrs_at(x, n))))
            if lhs != rhs:
                bad += 1
        check(f"x = {x}, 0 <= n <= 6", bad, 0)

    banner("5d. Gauss' evaluations at x = -1")
    for m in range(5):
        check(f"H_{2 * m + 1}(-1) = 0", qrs_at(-1, 2 * m + 1), ZERO)
    for m in range(5):
        prod_side: Poly = ONE
        for i in range(m):
            prod_side = pmul(prod_side, psub(ONE, qpow(2 * i + 1)))
        check(f"H_{2 * m}(-1) = prod_{{i<{m}}} (1 - q^{{2i+1}})", qrs_at(-1, 2 * m), prod_side)


# ----------------------------------------------------------------------------
# 6.  Cauchy's reciprocal q-binomial theorem and the negative convolution
# ----------------------------------------------------------------------------

def demo_cauchy(n: int = 4, order: int = 8) -> None:
    banner("6. Cauchy's q-binomial theorem:  (prod_{i<n}(1 - q^i X)) * sum_k [n+k-1,k]_q X^k = 1")
    prod_coeffs: List[Poly] = [ONE]
    for i in range(n):
        new: List[Poly] = [ZERO] * (len(prod_coeffs) + 1)
        for k, c in enumerate(prod_coeffs):
            new[k] = padd(new[k], c)
            new[k + 1] = psub(new[k + 1], pmul(qpow(i), c))
        prod_coeffs = new
    series = [qbinom(n + k - 1, k) for k in range(order + 1)]
    conv: List[Poly] = []
    for t in range(order + 1):
        acc: Poly = ZERO
        for a in range(min(t, len(prod_coeffs) - 1) + 1):
            acc = padd(acc, pmul(prod_coeffs[a], series[t - a]))
        conv.append(acc)
    check(f"n = {n}, coefficients of X^0..X^{order}", conv, [ONE] + [ZERO] * order)

    banner("6b. Negative (Cauchy) q-Vandermonde: "
           "[m+n+k-1,k]_q = sum_j q^{m(k-j)} [m+j-1,j]_q [n+k-j-1,k-j]_q")
    bad = 0
    for m in range(5):
        for nn in range(5):
            for k in range(6):
                rhs: Poly = ZERO
                for j in range(k + 1):
                    rhs = padd(rhs, pmul(qpow(m * (k - j)),
                                         pmul(qbinom(max(m + j - 1, 0), j),
                                              qbinom(max(nn + (k - j) - 1, 0), k - j))))
                if qbinom(max(m + nn + k - 1, 0), k) != rhs:
                    bad += 1
    check("all 0 <= m,n <= 4, 0 <= k <= 5", bad, 0)


# ----------------------------------------------------------------------------
# 7.  The q-Lucas theorem at a root of unity
# ----------------------------------------------------------------------------

def demo_qlucas() -> None:
    banner("7. q-Lucas at q = -1:  [n,k]_{-1} = C(n/2, k/2) * [n mod 2, k mod 2]_{-1}")
    bad = 0
    for n in range(14):
        for k in range(n + 1):
            lhs = peval(qbinom(n, k), -1)
            rhs = binom(n // 2, k // 2) * peval(qbinom(n % 2, k % 2), -1)
            if lhs != rhs:
                bad += 1
    check("all 0 <= k <= n <= 13", bad, 0)
    print("  Consequences:  [2a,2b]_{-1} = C(a,b)   and   [2a,2b+1]_{-1} = 0")
    print("  row n = 6 at q = -1:", [peval(qbinom(6, k), -1) for k in range(7)],
          " = C(3,k/2) pattern", [binom(3, k) for k in range(4)])


# ----------------------------------------------------------------------------
# 8.  Grassmannian meaning: counting subspaces of F_q^n
# ----------------------------------------------------------------------------

def count_subspaces_F2(n: int, k: int) -> int:
    """Brute-force count of k-dimensional subspaces of F_2^n (small n only)."""
    vectors = list(product((0, 1), repeat=n))
    subspaces = set()
    for combo in product(range(len(vectors)), repeat=k):
        basis = [vectors[i] for i in combo]
        span = {tuple([0] * n)}
        for b in basis:
            span |= {tuple((x + y) % 2 for x, y in zip(v, b)) for v in span}
        if len(span) == 2 ** k:
            subspaces.add(frozenset(span))
    return len(subspaces)


def demo_grassmann() -> None:
    banner("8. Gaussian binomials count subspaces:  |Gr(k, F_q^n)| = [n,k]_q")
    for (n, k) in [(3, 1), (4, 1), (4, 2), (4, 3)]:
        brute = count_subspaces_F2(n, k)
        formula = peval(qbinom(n, k), 2)
        check(f"k = {k}, n = {n}, q = 2:  brute force {brute} = [{n},{k}]_2 = {formula}",
              brute, formula)

    banner("8b. The projective space PG(3,q)")
    for q in (2, 3, 4, 5):
        through_point = peval(qbinom(3, 1), q)
        lines = peval(qbinom(4, 2), q)
        assert through_point == 1 + q + q * q
        assert lines == (q * q + 1) * (q * q + q + 1)
        print(f"  q = {q}:  lines through a point = [3,1]_q = {through_point};"
              f"  total lines = [4,2]_q = {lines} = (q^2+1)(q^2+q+1)")

    banner("8c. The same line count as a q-Vandermonde split 4 = 2 + 2")
    print("  [4,2]_q = q^4 * [2,0][2,2] + q * [2,1][2,1] + [2,2][2,0]")
    print("          =", pstr(qvandermonde_rhs(2, 2, 2)),
          " = q^4 + q(1+q)^2 + 1")
    check("identity of polynomials", qvandermonde_rhs(2, 2, 2), qbinom(4, 2))


# ----------------------------------------------------------------------------

def main() -> None:
    print(__doc__)
    demo_triangle()
    demo_rothe()
    demo_vandermonde()
    demo_gauss()
    demo_galois()
    demo_cauchy()
    demo_qlucas()
    demo_grassmann()
    banner("Summary")
    if FAILURES:
        print("  FAILED checks:")
        for f in FAILURES:
            print("   -", f)
    else:
        print("  All identities verified exactly over Z[q] in the stated ranges.")


if __name__ == "__main__":
    main()
