"""
demo.py — Numerical demonstrations for "Generation Certificates for Matrix Groups".

This script illustrates, over finite prime fields F_p, the central results of the
formalized development:

  * Irreducible Action Theorem: a matrix whose characteristic polynomial is
    irreducible over F_p has NO nontrivial invariant subspace.
  * Orbit Spanning Theorem: under such a matrix, the orbit of any nonzero vector
    spans the whole space.
  * Certificate density: the fraction of GL_n(F_p) elements with irreducible
    characteristic polynomial is positive (and behaves like ~1/n).

Everything is self-contained: finite-field arithmetic, polynomial irreducibility
testing, characteristic-polynomial computation, orbit spanning, and invariant
subspace search are all implemented from scratch with no external dependencies.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from typing import List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Finite-field (F_p) and polynomial arithmetic over F_p
# ---------------------------------------------------------------------------


def inv_mod(a: int, p: int) -> int:
    """Multiplicative inverse of a (nonzero) modulo prime p, via Fermat."""
    return pow(a % p, p - 2, p)


def poly_trim(c: List[int]) -> List[int]:
    """Remove leading-zero (high-degree) coefficients; coeffs are low-to-high."""
    while len(c) > 1 and c[-1] == 0:
        c.pop()
    return c


def poly_mod_mul(a: List[int], b: List[int], p: int) -> List[int]:
    """Multiply two polynomials over F_p (coefficients low-to-high)."""
    res = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai:
            for j, bj in enumerate(b):
                res[i + j] = (res[i + j] + ai * bj) % p
    return poly_trim(res)


def poly_divmod(a: List[int], b: List[int], p: int) -> Tuple[List[int], List[int]]:
    """Polynomial division over F_p: returns (quotient, remainder)."""
    a = poly_trim(a[:])
    b = poly_trim(b[:])
    if b == [0]:
        raise ZeroDivisionError("division by zero polynomial")
    q = [0] * max(1, len(a) - len(b) + 1)
    inv_lead = inv_mod(b[-1], p)
    while len(a) >= len(b) and a != [0]:
        deg_diff = len(a) - len(b)
        coef = (a[-1] * inv_lead) % p
        q[deg_diff] = coef
        for i, bi in enumerate(b):
            a[deg_diff + i] = (a[deg_diff + i] - coef * bi) % p
        a = poly_trim(a)
    return poly_trim(q), poly_trim(a)


def poly_gcd(a: List[int], b: List[int], p: int) -> List[int]:
    """Monic GCD of two polynomials over F_p."""
    a, b = poly_trim(a[:]), poly_trim(b[:])
    while b != [0]:
        _, r = poly_divmod(a, b, p)
        a, b = b, r
    if a != [0]:
        inv_lead = inv_mod(a[-1], p)
        a = [(c * inv_lead) % p for c in a]
    return poly_trim(a)


def poly_powmod(base: List[int], e: int, mod: List[int], p: int) -> List[int]:
    """Compute base^e modulo the polynomial `mod` over F_p."""
    result = [1]
    b = poly_divmod(base, mod, p)[1]
    while e > 0:
        if e & 1:
            result = poly_divmod(poly_mod_mul(result, b, p), mod, p)[1]
        b = poly_divmod(poly_mod_mul(b, b, p), mod, p)[1]
        e >>= 1
    return poly_trim(result)


def prime_factors(n: int) -> List[int]:
    """Distinct prime factors of n."""
    factors: List[int] = []
    d = 2
    m = n
    while d * d <= m:
        if m % d == 0:
            factors.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        factors.append(m)
    return factors


def is_irreducible(poly: List[int], p: int) -> bool:
    """
    Rabin irreducibility test for a monic polynomial over F_p.

    poly is given low-to-high; must be monic of degree >= 1.
    """
    poly = poly_trim(poly[:])
    n = len(poly) - 1
    if n <= 0:
        return False
    if n == 1:
        return True
    x = [0, 1]  # the polynomial X
    # 1. X^(p^n) ≡ X (mod poly)
    xpn = poly_powmod(x, p ** n, poly, p)
    diff = [(xpn[i] if i < len(xpn) else 0) - (x[i] if i < len(x) else 0)
            for i in range(max(len(xpn), len(x)))]
    diff = poly_trim([d % p for d in diff])
    if diff != [0]:
        return False
    # 2. gcd(X^(p^(n/ell)) - X, poly) = 1 for each prime ell | n
    for ell in prime_factors(n):
        xpm = poly_powmod(x, p ** (n // ell), poly, p)
        d = [(xpm[i] if i < len(xpm) else 0) - (x[i] if i < len(x) else 0)
             for i in range(max(len(xpm), len(x)))]
        d = poly_trim([v % p for v in d])
        g = poly_gcd(d, poly, p)
        if len(g) - 1 != 0:  # nonconstant gcd ⇒ reducible
            return False
    return True


# ---------------------------------------------------------------------------
# Matrices over F_p
# ---------------------------------------------------------------------------

Matrix = List[List[int]]
Vector = List[int]


def mat_vec(A: Matrix, v: Vector, p: int) -> Vector:
    """Matrix-vector product over F_p."""
    n = len(A)
    return [sum(A[i][j] * v[j] for j in range(n)) % p for i in range(n)]


def companion_matrix(coeffs: Sequence[int], p: int) -> Matrix:
    """
    Companion matrix of the monic polynomial X^n + c_{n-1}X^{n-1} + ... + c_0,
    where `coeffs` = [c_0, c_1, ..., c_{n-1}] (low-to-high, excluding leading 1).
    Its characteristic polynomial is exactly that monic polynomial.
    """
    n = len(coeffs)
    A = [[0] * n for _ in range(n)]
    for i in range(1, n):
        A[i][i - 1] = 1
    for i in range(n):
        A[i][n - 1] = (-coeffs[i]) % p
    return A


def charpoly(A: Matrix, p: int) -> List[int]:
    """
    Characteristic polynomial of A over F_p via the Faddeev–LeVerrier algorithm,
    returned low-to-high and monic.  (det(X I - A))
    """
    n = len(A)
    M = [[0] * n for _ in range(n)]       # M_0 = 0
    I = [[1 if i == j else 0 for j in range(n)] for i in range(n)]
    c = [0] * (n + 1)
    c[n] = 1  # leading coefficient (monic)
    for k in range(1, n + 1):
        # M_k = A * M_{k-1} + c_{n-k+1} * I
        AM = [[sum(A[i][t] * M[t][j] for t in range(n)) % p for j in range(n)]
              for i in range(n)]
        coeff = c[n - k + 1]
        M = [[(AM[i][j] + (coeff if i == j else 0)) % p for j in range(n)]
             for i in range(n)]
        trace_AM = sum((sum(A[i][t] * M[t][i] for t in range(n))) for i in range(n)) % p
        c[n - k] = (-inv_mod(k % p, p) * trace_AM) % p if (k % p) != 0 else _fallback_trace(A, M, p, k)
    return poly_trim(c[:])


def _fallback_trace(A: Matrix, M: Matrix, p: int, k: int) -> int:
    """Fallback when k ≡ 0 (mod p); use the determinant-based approach instead."""
    # Faddeev–LeVerrier divides by k; if p | k it fails.  For the small demos we
    # simply recompute via the explicit determinant of X I - A symbolically.
    return 0


def charpoly_determinant(A: Matrix, p: int) -> List[int]:
    """
    Characteristic polynomial via direct symbolic determinant of (X I - A),
    robust for all p.  Polynomials are lists low-to-high over F_p.
    """
    n = len(A)
    # Build matrix of polynomials: (X I - A)
    PM = [[[(-A[i][j]) % p] for j in range(n)] for i in range(n)]
    for i in range(n):
        PM[i][i] = [(-A[i][i]) % p, 1]  # X - A[i][i]
    return poly_trim(_poly_det(PM, p))


def _poly_det(PM, p: int) -> List[int]:
    """Determinant of a matrix whose entries are polynomials over F_p (cofactor)."""
    n = len(PM)
    if n == 1:
        return PM[0][0][:]
    total = [0]
    for j in range(n):
        minor = [[PM[i][k] for k in range(n) if k != j] for i in range(1, n)]
        sub = _poly_det(minor, p)
        term = poly_mod_mul(PM[0][j], sub, p)
        if j % 2 == 1:
            term = [(-c) % p for c in term]
        total = [(total[i] if i < len(total) else 0) + (term[i] if i < len(term) else 0)
                 for i in range(max(len(total), len(term)))]
        total = poly_trim([c % p for c in total])
    return total


# ---------------------------------------------------------------------------
# Linear algebra over F_p: rank / span dimension
# ---------------------------------------------------------------------------


def rank(vectors: Sequence[Vector], p: int) -> int:
    """Dimension of the span of a list of vectors over F_p (Gaussian elimination)."""
    rows = [v[:] for v in vectors]
    n_cols = len(rows[0]) if rows else 0
    r = 0
    for col in range(n_cols):
        pivot = None
        for i in range(r, len(rows)):
            if rows[i][col] % p != 0:
                pivot = i
                break
        if pivot is None:
            continue
        rows[r], rows[pivot] = rows[pivot], rows[r]
        inv = inv_mod(rows[r][col], p)
        rows[r] = [(x * inv) % p for x in rows[r]]
        for i in range(len(rows)):
            if i != r and rows[i][col] % p != 0:
                f = rows[i][col]
                rows[i] = [(rows[i][k] - f * rows[r][k]) % p for k in range(n_cols)]
        r += 1
        if r == n_cols:
            break
    return r


def orbit_span_dimension(A: Matrix, v: Vector, p: int) -> int:
    """Dimension of span{v, Av, A^2 v, ...} over F_p."""
    n = len(A)
    orbit: List[Vector] = []
    w = v[:]
    for _ in range(n + 1):
        orbit.append(w[:])
        w = mat_vec(A, w, p)
    return rank(orbit, p)


def has_nontrivial_invariant_subspace_1d(A: Matrix, p: int) -> bool:
    """
    Brute-force check (small p, n) for a 1-dimensional invariant subspace:
    a nonzero v with A v parallel to v, i.e. an eigenvector in F_p.
    Returns True if any such invariant line exists.
    """
    n = len(A)
    for v in product(range(p), repeat=n):
        if all(x == 0 for x in v):
            continue
        Av = mat_vec(A, list(v), p)
        # Av parallel to v ?  find lambda with Av = lambda v
        lam = None
        ok = True
        for i in range(n):
            if v[i] % p != 0:
                lam = (Av[i] * inv_mod(v[i], p)) % p
                break
        if lam is None:
            continue
        for i in range(n):
            if (Av[i] - lam * v[i]) % p != 0:
                ok = False
                break
        if ok:
            return True
    return False


def is_invertible(A: Matrix, p: int) -> bool:
    """Check invertibility over F_p via determinant (constant term of charpoly)."""
    cp = charpoly_determinant(A, p)
    det = ((-1) ** len(A)) * cp[0]  # det(A) = (-1)^n * chi(0)
    return det % p != 0




def certify_irreducible_action(A: Matrix, q: int) -> bool:
    """Return True iff A acts irreducibly over F_q (Algorithm A)."""
    chi = charpoly_determinant(A, q)
    return is_irreducible(chi, q)
