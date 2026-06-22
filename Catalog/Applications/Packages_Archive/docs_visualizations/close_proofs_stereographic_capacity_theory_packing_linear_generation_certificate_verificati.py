"""
Algorithm: Linear Generation Certificate Verification over GF(p).

Given a matrix M over a prime field GF(p), decide whether M is a valid
*linear generation certificate*: it must be invertible (det != 0) and its
characteristic polynomial must be irreducible over GF(p).  By Theorem 4.1 a
valid certificate guarantees that M has no proper nonzero invariant subspace,
and by Theorem 5.2 that the orbit of every nonzero vector spans the space.

Complexity: charpoly in O(n^3) field operations; Rabin irreducibility test in
O(n^3 log q).  Overall polynomial time in the matrix size and log of the field.
"""

from __future__ import annotations

Poly = list[int]
Matrix = list[list[int]]


def inv_mod(a: int, p: int) -> int:
    return pow(a % p, p - 2, p)


def poly_trim(c: Poly) -> Poly:
    while len(c) > 1 and c[-1] == 0:
        c.pop()
    return c


def poly_mul(a: Poly, b: Poly, p: int) -> Poly:
    r = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai:
            for j, bj in enumerate(b):
                r[i + j] = (r[i + j] + ai * bj) % p
    return poly_trim(r)


def poly_add(a: Poly, b: Poly, p: int) -> Poly:
    m = max(len(a), len(b))
    return poly_trim([((a[i] if i < len(a) else 0)
                       + (b[i] if i < len(b) else 0)) % p for i in range(m)])


def poly_mod(a: Poly, m: Poly, p: int) -> Poly:
    a = [x % p for x in a]
    m = poly_trim([x % p for x in m])
    dm, il = len(m) - 1, inv_mod(m[-1], p)
    while len(poly_trim(a)) - 1 >= dm and any(a):
        da = len(poly_trim(a)) - 1
        if da < dm:
            break
        cf, sh = (a[da] * il) % p, da - dm
        for i, mi in enumerate(m):
            a[i + sh] = (a[i + sh] - cf * mi) % p
        a = poly_trim(a)
    return poly_trim(a)


def poly_gcd(a: Poly, b: Poly, p: int) -> Poly:
    a, b = poly_trim(a[:]), poly_trim(b[:])
    while any(b):
        a, b = b, poly_mod(a, b, p)
    return poly_trim(a)


def poly_powmod(base: Poly, e: int, m: Poly, p: int) -> Poly:
    r: Poly = [1]
    base = poly_mod(base, m, p)
    while e > 0:
        if e & 1:
            r = poly_mod(poly_mul(r, base, p), m, p)
        base = poly_mod(poly_mul(base, base, p), m, p)
        e >>= 1
    return r


def prime_divisors(n: int) -> set[int]:
    out, d, m = set(), 2, n
    while d * d <= m:
        while m % d == 0:
            out.add(d)
            m //= d
        d += 1
    if m > 1:
        out.add(m)
    return out


def is_irreducible(f: Poly, p: int) -> bool:
    """Rabin's irreducibility test for monic f of degree n over GF(p)."""
    f = poly_trim([x % p for x in f])
    n = len(f) - 1
    if n <= 0:
        return False
    if n == 1:
        return True
    xp = poly_powmod([0, 1], p ** n, f, p)
    diff = xp[:] + [0] * (2 - len(xp))
    diff[1] = (diff[1] - 1) % p
    if poly_mod(diff, f, p) != [0]:
        return False
    for q in prime_divisors(n):
        xq = poly_powmod([0, 1], p ** (n // q), f, p)
        d = xq[:] + [0] * (2 - len(xq))
        d[1] = (d[1] - 1) % p
        if len(poly_trim(poly_gcd(f, d, p))) - 1 != 0:
            return False
    return True


def poly_mat_det(A: list[list[Poly]], p: int) -> Poly:
    n = len(A)
    if n == 1:
        return poly_trim([x % p for x in A[0][0]])
    total: Poly = [0]
    for j in range(n):
        minor = [[A[i][k] for k in range(n) if k != j] for i in range(1, n)]
        term = poly_mul(A[0][j], poly_mat_det(minor, p), p)
        if j % 2 == 1:
            term = [(-c) % p for c in term]
        total = poly_add(total, term, p)
    return poly_trim(total)


def charpoly(M: Matrix, p: int) -> Poly:
    """Characteristic polynomial det(X*I - M) over GF(p), low-degree first."""
    n = len(M)
    A = [[([(-M[i][j]) % p, 1] if i == j else [(-M[i][j]) % p])
          for j in range(n)] for i in range(n)]
    return poly_mat_det(A, p)


def determinant(M: Matrix, p: int) -> int:
    n = len(M)
    A = [row[:] for row in M]
    d = 1
    for c in range(n):
        piv = next((r for r in range(c, n) if A[r][c] % p), None)
        if piv is None:
            return 0
        if piv != c:
            A[c], A[piv] = A[piv], A[c]
            d = -d
        d = (d * A[c][c]) % p
        inv = inv_mod(A[c][c], p)
        for r in range(c + 1, n):
            fac = (A[r][c] * inv) % p
            A[r] = [(A[r][j] - fac * A[c][j]) % p for j in range(n)]
    return d % p


def verify_certificate(M: Matrix, p: int) -> dict[str, object]:
    """Return a structured verdict on whether M is a valid certificate."""
    d = determinant(M, p)
    cp = charpoly(M, p)
    irr = is_irreducible(cp, p)
    return {
        "invertible": d != 0,
        "determinant": d,
        "charpoly_low_to_high": cp,
        "charpoly_irreducible": irr,
        "is_valid_certificate": d != 0 and irr,
    }


if __name__ == "__main__":
    # X^2 + 1 over GF(3): irreducible -> valid certificate.
    M = [[0, 2], [1, 0]]
    print(verify_certificate(M, 3))
