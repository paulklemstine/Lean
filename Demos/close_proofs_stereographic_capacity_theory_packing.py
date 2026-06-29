"""
Generation Certificates for Matrix Groups — Numerical Demonstrations
====================================================================

Self-contained Python (standard library only) illustrating the results of
the package "Generation Certificates for Matrix Groups":

  * Theorem 4.1 (Irreducible action): an endomorphism whose characteristic
    polynomial is irreducible has no proper nonzero invariant subspace.
  * Theorem 5.2 (Orbit spanning): the orbit of any nonzero vector under such
    an endomorphism spans the whole space.
  * Theorem 6.1 (No fixed proper projective flat): the Singer-cycle property.
  * Theorem 7.1 (Positive certificate density): certified elements have
    positive density whenever they exist.

All arithmetic is performed over the prime field GF(p) = Z/pZ.  Matrices are
represented as tuples of tuples; polynomials as coefficient lists (low degree
first).  Everything is inlined; run `python demo.py`.
"""

from __future__ import annotations

from itertools import product
from typing import Iterable, Iterator


# ---------------------------------------------------------------------------
# Finite field GF(p) and polynomial arithmetic
# ---------------------------------------------------------------------------

def inv_mod(a: int, p: int) -> int:
    """Multiplicative inverse of a (mod p), p prime, a not divisible by p."""
    return pow(a % p, p - 2, p)


def poly_trim(c: list[int]) -> list[int]:
    """Drop trailing (high-degree) zero coefficients."""
    while len(c) > 1 and c[-1] == 0:
        c.pop()
    return c


def poly_mul(a: list[int], b: list[int], p: int) -> list[int]:
    """Multiply two polynomials over GF(p)."""
    res = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai:
            for j, bj in enumerate(b):
                res[i + j] = (res[i + j] + ai * bj) % p
    return poly_trim(res)


def poly_mod(a: list[int], m: list[int], p: int) -> list[int]:
    """Remainder of a modulo monic-or-general m over GF(p)."""
    a = [x % p for x in a]
    m = poly_trim([x % p for x in m])
    dm = len(m) - 1
    inv_lead = inv_mod(m[-1], p)
    a = a[:]
    while len(poly_trim(a)) - 1 >= dm and any(a):
        deg_a = len(poly_trim(a)) - 1
        if deg_a < dm:
            break
        coeff = (a[deg_a] * inv_lead) % p
        shift = deg_a - dm
        for i, mi in enumerate(m):
            a[i + shift] = (a[i + shift] - coeff * mi) % p
        a = poly_trim(a)
        if len(a) - 1 < dm:
            break
    return poly_trim(a)


def poly_gcd(a: list[int], b: list[int], p: int) -> list[int]:
    """Monic gcd of polynomials over GF(p)."""
    a, b = poly_trim(a[:]), poly_trim(b[:])
    while any(b):
        a, b = b, poly_mod(a, b, p)
    a = poly_trim(a)
    if any(a):
        inv_lead = inv_mod(a[-1], p)
        a = [(x * inv_lead) % p for x in a]
    return a


def poly_powmod(base: list[int], e: int, m: list[int], p: int) -> list[int]:
    """Compute base**e mod m over GF(p) by fast exponentiation."""
    result = [1]
    base = poly_mod(base, m, p)
    while e > 0:
        if e & 1:
            result = poly_mod(poly_mul(result, base, p), m, p)
        base = poly_mod(poly_mul(base, base, p), m, p)
        e >>= 1
    return result


def is_irreducible(f: list[int], p: int) -> bool:
    """Rabin irreducibility test for monic f of degree n over GF(p)."""
    f = poly_trim([x % p for x in f])
    n = len(f) - 1
    if n <= 0:
        return False
    if n == 1:
        return True
    # X^(p^n) ≡ X  (mod f)
    xp = poly_powmod([0, 1], p ** n, f, p)
    diff = xp[:] + [0] * (2 - len(xp))
    diff[1] = (diff[1] - 1) % p
    if poly_mod(diff, f, p) != [0]:
        return False
    # gcd(X^(p^(n/q)) - X, f) = 1 for each prime q | n
    for q in _prime_divisors(n):
        xpq = poly_powmod([0, 1], p ** (n // q), f, p)
        diff = xpq[:] + [0] * (2 - len(xpq))
        diff[1] = (diff[1] - 1) % p
        g = poly_gcd(f, diff, p)
        if len(poly_trim(g)) - 1 != 0:
            return False
    return True


def _prime_divisors(n: int) -> set[int]:
    out: set[int] = set()
    d = 2
    m = n
    while d * d <= m:
        while m % d == 0:
            out.add(d)
            m //= d
        d += 1
    if m > 1:
        out.add(m)
    return out


# ---------------------------------------------------------------------------
# Matrices over GF(p)
# ---------------------------------------------------------------------------

Vector = tuple[int, ...]
Matrix = tuple[tuple[int, ...], ...]


def mat_vec(M: Matrix, v: Vector, p: int) -> Vector:
    n = len(M)
    return tuple(sum(M[i][j] * v[j] for j in range(n)) % p for i in range(n))


def mat_mul(A: Matrix, B: Matrix, p: int) -> Matrix:
    n = len(A)
    return tuple(
        tuple(sum(A[i][k] * B[k][j] for k in range(n)) % p for j in range(n))
        for i in range(n)
    )


def identity(n: int) -> Matrix:
    return tuple(tuple(1 if i == j else 0 for j in range(n)) for i in range(n))


def det(M: Matrix, p: int) -> int:
    """Determinant over GF(p) via Gaussian elimination."""
    n = len(M)
    A = [list(row) for row in M]
    d = 1
    for col in range(n):
        piv = next((r for r in range(col, n) if A[r][col] % p != 0), None)
        if piv is None:
            return 0
        if piv != col:
            A[col], A[piv] = A[piv], A[col]
            d = (-d) % p
        inv = inv_mod(A[col][col], p)
        d = (d * A[col][col]) % p
        for r in range(col + 1, n):
            factor = (A[r][col] * inv) % p
            if factor:
                A[r] = [(A[r][j] - factor * A[col][j]) % p for j in range(n)]
    return d % p


def poly_add(a: list[int], b: list[int], p: int) -> list[int]:
    m = max(len(a), len(b))
    return poly_trim([((a[i] if i < len(a) else 0)
                       + (b[i] if i < len(b) else 0)) % p for i in range(m)])


def poly_mat_det(A: list[list[list[int]]], p: int) -> list[int]:
    """Determinant of a matrix whose entries are polynomials over GF(p),
    by recursive cofactor (Laplace) expansion.  Division-free, hence valid
    in any characteristic."""
    n = len(A)
    if n == 1:
        return poly_trim([x % p for x in A[0][0]])
    total: list[int] = [0]
    for j in range(n):
        minor = [[A[i][k] for k in range(n) if k != j] for i in range(1, n)]
        term = poly_mul(A[0][j], poly_mat_det(minor, p), p)
        if j % 2 == 1:
            term = [(-c) % p for c in term]
        total = poly_add(total, term, p)
    return poly_trim(total)


def charpoly(M: Matrix, p: int) -> list[int]:
    """
    Characteristic polynomial det(X*I - M) over GF(p), returned low-degree
    first.  Computed as a polynomial determinant, valid for every prime p
    (including p <= n).
    """
    n = len(M)
    A: list[list[list[int]]] = []
    for i in range(n):
        row: list[list[int]] = []
        for j in range(n):
            if i == j:
                row.append([(-M[i][j]) % p, 1])   # X - M[i][i]
            else:
                row.append([(-M[i][j]) % p])      # -M[i][j]
        A.append(row)
    return poly_mat_det(A, p)


# ---------------------------------------------------------------------------
# Subspaces, invariance, orbits
# ---------------------------------------------------------------------------

def all_vectors(n: int, p: int) -> Iterator[Vector]:
    yield from (tuple(v) for v in product(range(p), repeat=n))


def span(vectors: Iterable[Vector], n: int, p: int) -> frozenset[Vector]:
    """All linear combinations of the given vectors over GF(p)."""
    basis = list(vectors)
    elems: set[Vector] = {tuple([0] * n)}
    for v in basis:
        new = set()
        for w in elems:
            for c in range(p):
                new.add(tuple((w[i] + c * v[i]) % p for i in range(n)))
        elems |= new
    return frozenset(elems)


def enumerate_subspaces(n: int, p: int) -> set[frozenset[Vector]]:
    """All subspaces of GF(p)^n (feasible only for tiny n, p)."""
    vecs = [v for v in all_vectors(n, p) if any(v)]
    subspaces: set[frozenset[Vector]] = {frozenset({tuple([0] * n)})}
    # Greedily build by adding vectors; closure under span dedupes.
    frontier = list(subspaces)
    while frontier:
        S = frontier.pop()
        for v in vecs:
            if v in S:
                continue
            T = span(list(S) + [v], n, p)
            if T not in subspaces:
                subspaces.add(T)
                frontier.append(T)
    return subspaces


def is_invariant(M: Matrix, S: frozenset[Vector], p: int) -> bool:
    return all(mat_vec(M, v, p) in S for v in S)


def orbit_span(M: Matrix, v: Vector, p: int) -> frozenset[Vector]:
    n = len(M)
    iterates = [v]
    cur = v
    for _ in range(n):  # n iterates always suffice to reach the cyclic span
        cur = mat_vec(M, cur, p)
        iterates.append(cur)
    return span(iterates, n, p)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def companion(coeffs_monic: list[int], p: int) -> Matrix:
    """
    Companion matrix of monic polynomial X^n + c_{n-1}X^{n-1} + ... + c0,
    given coeffs low-degree first as [c0, c1, ..., c_{n-1}, 1].
    Its characteristic polynomial equals the given polynomial.
    """
    n = len(coeffs_monic) - 1
    M = [[0] * n for _ in range(n)]
    for i in range(1, n):
        M[i][i - 1] = 1
    for i in range(n):
        M[i][n - 1] = (-coeffs_monic[i]) % p
    return tuple(tuple(row) for row in M)


def demo_irreducible_action() -> None:
    print("=" * 70)
    print("Theorem 4.1 — Irreducible action: no proper nonzero invariant subspace")
    print("=" * 70)
    p, n = 3, 2
    # X^2 + 1 is irreducible over GF(3) (no root: 0,1,2 -> 1,2,2).
    f = [1, 0, 1]  # 1 + 0*X + X^2
    M = companion(f, p)
    cp = charpoly(M, p)
    print(f"Field GF({p}), dimension {n}")
    print(f"Companion matrix M = {M}")
    print(f"charpoly(M) = {cp}  (low-degree first), irreducible? "
          f"{is_irreducible(cp, p)}")
    subs = enumerate_subspaces(n, p)
    full = span(list(all_vectors(n, p)), n, p)
    zero = frozenset({tuple([0] * n)})
    invariant = [S for S in subs if is_invariant(M, S, p)]
    proper_nonzero = [S for S in invariant if S != full and S != zero]
    print(f"Total subspaces of GF({p})^{n}: {len(subs)}")
    print(f"Invariant subspaces: {len(invariant)} "
          f"(expect exactly 2: zero and full)")
    print(f"Proper nonzero invariant subspaces: {len(proper_nonzero)} "
          f"(expect 0)  ==> {'PASS' if not proper_nonzero else 'FAIL'}")
    print()


def demo_reducible_contrast() -> None:
    print("=" * 70)
    print("Contrast — a REDUCIBLE charpoly DOES admit invariant subspaces")
    print("=" * 70)
    p, n = 3, 2
    # X^2 - 1 = (X-1)(X+1) is reducible over GF(3).
    f = [-1 % 3, 0, 1]
    M = companion(f, p)
    cp = charpoly(M, p)
    print(f"Companion matrix M = {M}")
    print(f"charpoly(M) = {cp}, irreducible? {is_irreducible(cp, p)}")
    subs = enumerate_subspaces(n, p)
    full = span(list(all_vectors(n, p)), n, p)
    zero = frozenset({tuple([0] * n)})
    proper_nonzero = [
        S for S in subs
        if is_invariant(M, S, p) and S != full and S != zero
    ]
    print(f"Proper nonzero invariant subspaces: {len(proper_nonzero)} "
          f"(expect > 0)  ==> {'PASS' if proper_nonzero else 'FAIL'}")
    print()


def demo_orbit_spanning() -> None:
    print("=" * 70)
    print("Theorem 5.2 — Orbit spanning: orbit of any nonzero v fills the space")
    print("=" * 70)
    p, n = 3, 2
    f = [1, 0, 1]  # irreducible X^2+1 over GF(3)
    M = companion(f, p)
    full = span(list(all_vectors(n, p)), n, p)
    ok = True
    for v in all_vectors(n, p):
        if not any(v):
            continue
        U = orbit_span(M, v, p)
        spans = (U == full)
        ok = ok and spans
        print(f"v = {v}: orbit span has {len(U)} vectors, "
              f"spans whole space? {spans}")
    print(f"All nonzero vectors span ==> {'PASS' if ok else 'FAIL'}")
    print()


def demo_singer_no_fixed_flat() -> None:
    print("=" * 70)
    print("Theorem 6.1 — Singer cycle: no fixed proper projective flat")
    print("=" * 70)
    p, n = 2, 3
    # X^3 + X + 1 is a primitive (hence irreducible) polynomial over GF(2).
    f = [1, 1, 0, 1]
    M = companion(f, p)
    cp = charpoly(M, p)
    print(f"Field GF({p}), dimension {n}, companion of X^3+X+1")
    print(f"charpoly(M) = {cp}, irreducible? {is_irreducible(cp, p)}")
    # order of M: should be 2^3 - 1 = 7  (Singer cycle)
    order = matrix_order(M, p)
    print(f"Order of M = {order} (Singer cycle has order 2^3 - 1 = 7)")
    # The 7 projective points (nonzero vectors up to scaling; over GF(2) scaling
    # is trivial) form a single orbit under M.
    pts = [v for v in all_vectors(n, p) if any(v)]
    start = pts[0]
    orbit = []
    cur = start
    for _ in range(order):
        orbit.append(cur)
        cur = mat_vec(M, cur, p)
    single_orbit = (set(orbit) == set(pts))
    print(f"M permutes all {len(pts)} projective points in a single orbit? "
          f"{single_orbit}  ==> {'PASS' if single_orbit else 'FAIL'}")
    print()


def matrix_order(M: Matrix, p: int) -> int:
    n = len(M)
    I = identity(n)
    cur = M
    k = 1
    while cur != I:
        cur = mat_mul(cur, M, p)
        k += 1
        if k > p ** (n * n):
            raise RuntimeError("matrix not invertible / order too large")
    return k


def demo_certificate_density() -> None:
    print("=" * 70)
    print("Theorem 7.1 — Positive certificate density in GL_n(GF(p))")
    print("=" * 70)
    p, n = 2, 2
    total = 0
    certified = 0
    for entries in product(range(p), repeat=n * n):
        M = tuple(tuple(entries[i * n + j] for j in range(n)) for i in range(n))
        if det(M, p) == 0:
            continue
        total += 1
        cp = charpoly(M, p)
        if is_irreducible(cp, p):
            certified += 1
    print(f"|GL_{n}(GF({p}))| = {total}")
    print(f"Certified elements (irreducible charpoly) = {certified}")
    print(f"certificateDensity = {certified}/{total} = {certified / total:.4f}")
    print(f"Density > 0 ? {'PASS' if certified > 0 else 'FAIL'}")
    print()


def main() -> None:
    demo_irreducible_action()
    demo_reducible_contrast()
    demo_orbit_spanning()
    demo_singer_no_fixed_flat()
    demo_certificate_density()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
