"""
Numerical demonstration of Sun's truncated Legendre-symbol determinant identity.

For a prime p >= 7 with p == 3 (mod 4), let m = (p - 5) // 2 and let

    C[j][k] = legendre(j - k, p)            (the Legendre-difference matrix)
    A[j][k] = X + legendre(j - k, p)        (polynomial deformation over Z[X])

We illustrate, with exact integer arithmetic only, the three structural facts:

  1. Affine collapse        : det A = det C + (det(C + J) - det C) * X      (degree 1)
  2. Vanishing constant term: det C = 0    (antisymmetry of C, since p == 3 mod 4)
  3. Closed coefficient     : det(C + J) = floor((p - 2) / 3) ** 2

so that det A = floor((p - 2) / 3) ** 2 * X.

Here J is the all-ones matrix.  All functions are inlined and self-contained;
the script depends only on the Python standard library.
"""
from __future__ import annotations

from fractions import Fraction
from typing import List, Tuple


# --------------------------------------------------------------------------- #
# Number theory: primality and the Legendre symbol via Euler's criterion       #
# --------------------------------------------------------------------------- #
def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def legendre(a: int, p: int) -> int:
    """Legendre symbol (a | p) in {-1, 0, 1} via Euler's criterion a^((p-1)/2) mod p."""
    a %= p
    if a == 0:
        return 0
    r = pow(a, (p - 1) // 2, p)
    return 1 if r == 1 else -1


# --------------------------------------------------------------------------- #
# Linear algebra: exact integer determinant via Bareiss elimination            #
# --------------------------------------------------------------------------- #
def det_int(matrix: List[List[int]]) -> int:
    """Exact determinant of an integer matrix (Bareiss fraction-free elimination)."""
    n = len(matrix)
    if n == 0:
        return 1
    a = [row[:] for row in matrix]
    sign = 1
    prev = 1
    for i in range(n - 1):
        if a[i][i] == 0:
            swap = next((r for r in range(i + 1, n) if a[r][i] != 0), None)
            if swap is None:
                return 0
            a[i], a[swap] = a[swap], a[i]
            sign = -sign
        for r in range(i + 1, n):
            for c in range(i + 1, n):
                a[r][c] = (a[r][c] * a[i][i] - a[r][i] * a[i][c]) // prev
        prev = a[i][i]
    return sign * a[n - 1][n - 1]


# --------------------------------------------------------------------------- #
# Polynomial determinant over Z[X] (dense list of integer coefficients)        #
# --------------------------------------------------------------------------- #
Poly = List[int]  # coefficients low-to-high: [c0, c1, c2, ...]


def p_add(u: Poly, v: Poly) -> Poly:
    n = max(len(u), len(v))
    return [(u[i] if i < len(u) else 0) + (v[i] if i < len(v) else 0) for i in range(n)]


def p_mul(u: Poly, v: Poly) -> Poly:
    if not u or not v:
        return [0]
    out = [0] * (len(u) + len(v) - 1)
    for i, ui in enumerate(u):
        for j, vj in enumerate(v):
            out[i + j] += ui * vj
    return out


def p_trim(u: Poly) -> Poly:
    k = len(u)
    while k > 1 and u[k - 1] == 0:
        k -= 1
    return u[:k]


def det_poly(matrix: List[List[Poly]]) -> Poly:
    """Determinant of a matrix of polynomials by Laplace cofactor expansion."""
    n = len(matrix)
    if n == 1:
        return p_trim(matrix[0][0])
    acc: Poly = [0]
    for c in range(n):
        minor = [[matrix[r][cc] for cc in range(n) if cc != c] for r in range(1, n)]
        term = p_mul(matrix[0][c], det_poly(minor))
        acc = p_add(acc, term) if c % 2 == 0 else p_add(acc, p_mul([-1], term))
    return p_trim(acc)


# --------------------------------------------------------------------------- #
# Builders for C, C + J, and the polynomial matrix A                           #
# --------------------------------------------------------------------------- #
def build_C(p: int) -> List[List[int]]:
    m = (p - 5) // 2
    return [[legendre(j - k, p) for k in range(m)] for j in range(m)]


def build_C_plus_J(p: int) -> List[List[int]]:
    return [[1 + x for x in row] for row in build_C(p)]


def build_A_poly(p: int) -> List[List[Poly]]:
    """A[j][k] = X + legendre(j-k, p) as the polynomial [legendre, 1]."""
    m = (p - 5) // 2
    return [[[legendre(j - k, p), 1] for k in range(m)] for j in range(m)]


def expected_coeff(p: int) -> int:
    return ((p - 2) // 3) ** 2


# --------------------------------------------------------------------------- #
# Verification driver                                                          #
# --------------------------------------------------------------------------- #
def verify_prime(p: int) -> Tuple[int, int, int, Poly]:
    """Return (m, det C, det(C+J), det A as polynomial) and assert the identity.

    The polynomial determinant det A is obtained from the proven affine structure
    det A = det C + (det(C+J) - det C) * X.  For small dimensions (m <= 5) we also
    cross-check this against a direct cofactor expansion of A over Z[X].
    """
    m = (p - 5) // 2
    detC = det_int(build_C(p))
    detCJ = det_int(build_C_plus_J(p))
    detA = p_trim([detC, detCJ - detC])  # affine form: constant detC, slope detCJ-detC

    coeff = expected_coeff(p)
    assert detC == 0, f"p={p}: det C should be 0, got {detC}"
    assert detCJ == coeff, f"p={p}: det(C+J)={detCJ} != floor((p-2)/3)^2={coeff}"
    assert detA == p_trim([0, coeff]), f"p={p}: det A = {detA} != {coeff}*X"
    if m <= 5:  # direct symbolic cross-check on small matrices
        assert det_poly(build_A_poly(p)) == detA, f"p={p}: symbolic det A mismatch"
    return m, detC, detCJ, detA


def poly_str(u: Poly) -> str:
    terms = []
    for i, c in enumerate(u):
        if c == 0:
            continue
        if i == 0:
            terms.append(f"{c}")
        elif i == 1:
            terms.append(f"{c}*X")
        else:
            terms.append(f"{c}*X^{i}")
    return " + ".join(terms) if terms else "0"


def main() -> None:
    primes = [p for p in range(7, 32) if is_prime(p) and p % 4 == 3]
    print("Sun's truncated Legendre-symbol determinant:  det A = floor((p-2)/3)^2 * X")
    print("=" * 78)
    header = f"{'p':>4} {'m':>4} {'det C':>7} {'det(C+J)':>10} {'floor((p-2)/3)^2':>18}  det A"
    print(header)
    print("-" * 78)
    for p in primes:
        m, detC, detCJ, detA = verify_prime(p)
        print(f"{p:>4} {m:>4} {detC:>7} {detCJ:>10} {expected_coeff(p):>18}  {poly_str(detA)}")
    print("-" * 78)
    print("All identities verified with exact integer arithmetic.")

    # Showcase the affine structure explicitly for one prime.
    p = 11
    print()
    print(f"Affine structure for p = {p}:")
    C = build_C(p)
    print("  C =", C, "  (antisymmetric, det C = 0)")
    print("  C+J =", build_C_plus_J(p))
    print(f"  det A = det C + (det(C+J) - det C) * X = {det_int(C)} + "
          f"{det_int(build_C_plus_J(p)) - det_int(C)} * X")


if __name__ == "__main__":
    main()
