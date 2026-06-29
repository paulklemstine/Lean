"""
Generation Certificates for Matrix Groups -- numerical demonstrations.

This self-contained script illustrates the verified theorems:

  * Theorem 4.1 (Irreducible action): if charpoly(phi) is irreducible over F_p,
    then phi has no nontrivial invariant subspace.
  * Theorem 5.2 (Orbit spanning): the orbit of any nonzero vector spans the
    whole space when charpoly(phi) is irreducible.
  * Theorem 6.1 (No fixed proper projective subspace).
  * Theorem 7.2 (Positive certificate density) and the GL_n(F_q) statistics
    behind Conjecture A.

Everything is implemented from scratch over a prime field F_p using plain
Python integers; no external libraries are required.
"""

from __future__ import annotations

from itertools import product
from typing import List, Tuple, Iterable

Vector = Tuple[int, ...]
Matrix = List[List[int]]
Poly = List[int]  # coefficients low-degree first, over F_p


# --------------------------------------------------------------------------
# Field and polynomial arithmetic over F_p
# --------------------------------------------------------------------------

def inv_mod(a: int, p: int) -> int:
    """Multiplicative inverse of a (mod p), p prime."""
    return pow(a % p, p - 2, p)


def poly_trim(c: Poly, p: int) -> Poly:
    """Reduce mod p and drop leading zeros."""
    c = [x % p for x in c]
    while len(c) > 1 and c[-1] == 0:
        c.pop()
    return c


def poly_mul(a: Poly, b: Poly, p: int) -> Poly:
    res = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            res[i + j] = (res[i + j] + ai * bj) % p
    return poly_trim(res, p)


def poly_mod(a: Poly, b: Poly, p: int) -> Poly:
    """Remainder of a divided by b over F_p."""
    a = poly_trim(a[:], p)
    b = poly_trim(b[:], p)
    binv = inv_mod(b[-1], p)
    while len(a) >= len(b) and not (len(a) == 1 and a[0] == 0):
        coef = (a[-1] * binv) % p
        shift = len(a) - len(b)
        for i, bi in enumerate(b):
            a[i + shift] = (a[i + shift] - coef * bi) % p
        a = poly_trim(a, p)
        if len(a) == 1 and a[0] == 0:
            break
    return poly_trim(a, p)


def poly_gcd(a: Poly, b: Poly, p: int) -> Poly:
    a, b = poly_trim(a[:], p), poly_trim(b[:], p)
    while not (len(b) == 1 and b[0] == 0):
        a, b = b, poly_mod(a, b, p)
    # make monic
    inv = inv_mod(a[-1], p)
    return poly_trim([x * inv for x in a], p)


def poly_powmod(base: Poly, e: int, mod: Poly, p: int) -> Poly:
    result: Poly = [1]
    base = poly_mod(base, mod, p)
    while e > 0:
        if e & 1:
            result = poly_mod(poly_mul(result, base, p), mod, p)
        base = poly_mod(poly_mul(base, base, p), mod, p)
        e >>= 1
    return result


def is_irreducible(f: Poly, p: int) -> bool:
    """Rabin irreducibility test for a monic polynomial f over F_p."""
    f = poly_trim(f[:], p)
    n = len(f) - 1
    if n <= 0:
        return False
    if n == 1:
        return True
    # x^(p^n) == x  (mod f)
    xpn = poly_powmod([0, 1], p ** n, f, p)
    if poly_trim([(xpn[i] if i < len(xpn) else 0) - (1 if i == 1 else 0)
                  for i in range(max(len(xpn), 2))], p) != [0]:
        return False
    # for each prime divisor q of n: gcd(x^(p^(n/q)) - x, f) == 1
    for q in _prime_divisors(n):
        m = n // q
        xpm = poly_powmod([0, 1], p ** m, f, p)
        diff = poly_trim([(xpm[i] if i < len(xpm) else 0) - (1 if i == 1 else 0)
                          for i in range(max(len(xpm), 2))], p)
        if poly_gcd(diff, f, p) != [1]:
            return False
    return True


def _prime_divisors(n: int) -> List[int]:
    ds, d = [], 2
    while d * d <= n:
        if n % d == 0:
            ds.append(d)
            while n % d == 0:
                n //= d
        d += 1
    if n > 1:
        ds.append(n)
    return ds


# --------------------------------------------------------------------------
# Matrix arithmetic over F_p
# --------------------------------------------------------------------------

def mat_vec(M: Matrix, v: Vector, p: int) -> Vector:
    return tuple(sum(M[i][j] * v[j] for j in range(len(v))) % p
                 for i in range(len(M)))


def mat_mul(A: Matrix, B: Matrix, p: int) -> Matrix:
    n = len(A)
    return [[sum(A[i][k] * B[k][j] for k in range(n)) % p for j in range(n)]
            for i in range(n)]


def det_mod(M: Matrix, p: int) -> int:
    """Determinant over F_p via Gaussian elimination."""
    n = len(M)
    A = [row[:] for row in M]
    det = 1
    for col in range(n):
        piv = next((r for r in range(col, n) if A[r][col] % p != 0), None)
        if piv is None:
            return 0
        if piv != col:
            A[col], A[piv] = A[piv], A[col]
            det = (-det) % p
        det = (det * A[col][col]) % p
        inv = inv_mod(A[col][col], p)
        for r in range(col + 1, n):
            f = (A[r][col] * inv) % p
            if f:
                A[r] = [(A[r][k] - f * A[col][k]) % p for k in range(n)]
    return det % p


def charpoly(M: Matrix, p: int) -> Poly:
    """Characteristic polynomial of M over F_p via Faddeev-LeVerrier."""
    n = len(M)
    I = [[1 if i == j else 0 for j in range(n)] for i in range(n)]
    Mk = [row[:] for row in I]
    coeffs = [0] * (n + 1)
    coeffs[n] = 1
    c = 1
    for k in range(1, n + 1):
        Mk = mat_mul(M, Mk, p)
        trace = sum(Mk[i][i] for i in range(n)) % p
        c = (-trace * inv_mod(k, p)) % p
        coeffs[n - k] = c
        for i in range(n):
            Mk[i][i] = (Mk[i][i] + c) % p
    return poly_trim(coeffs, p)


def companion_matrix(f: Poly, p: int) -> Matrix:
    """Companion matrix of monic polynomial f = x^n + c_{n-1}x^{n-1} + ... + c_0."""
    f = poly_trim(f[:], p)
    n = len(f) - 1
    M = [[0] * n for _ in range(n)]
    for i in range(1, n):
        M[i][i - 1] = 1
    for i in range(n):
        M[i][n - 1] = (-f[i]) % p
    return M


# --------------------------------------------------------------------------
# Subspaces, orbits, invariance
# --------------------------------------------------------------------------

def row_reduce(vectors: Iterable[Vector], p: int) -> List[Vector]:
    """Return a basis (row echelon) of the span of the given vectors over F_p."""
    basis: List[Vector] = []
    pivots: List[int] = []
    for v in vectors:
        w = list(v)
        for b, pc in zip(basis, pivots):
            if w[pc] % p:
                f = w[pc] * inv_mod(b[pc], p) % p
                w = [(w[k] - f * b[k]) % p for k in range(len(w))]
        pc = next((k for k in range(len(w)) if w[k] % p), None)
        if pc is not None:
            basis.append(tuple(x % p for x in w))
            pivots.append(pc)
    return basis


def subspace_dim(vectors: Iterable[Vector], p: int) -> int:
    return len(row_reduce(vectors, p))


def orbit(M: Matrix, v: Vector, p: int, steps: int) -> List[Vector]:
    out = [v]
    cur = v
    for _ in range(steps):
        cur = mat_vec(M, cur, p)
        out.append(cur)
    return out


def all_proper_invariant_subspaces(M: Matrix, p: int) -> List[List[Vector]]:
    """
    Brute-force search for proper nonzero invariant subspaces of M over F_p
    (feasible only for tiny n and p). Returns a basis for each one found,
    deduplicated by the set of points they contain.
    """
    n = len(M)
    all_vecs = [tuple(v) for v in product(range(p), repeat=n)]
    nonzero = [v for v in all_vecs if any(v)]
    found = {}
    # enumerate spans of all subsets of size <= n-1 of basis-like vectors
    # (cheap heuristic: spans generated by 1..n-1 vectors)
    from itertools import combinations
    for r in range(1, n):
        for combo in combinations(nonzero, r):
            basis = row_reduce(combo, p)
            d = len(basis)
            if d == 0 or d >= n:
                continue
            # closure check: M maps each basis vector into the span
            images = [mat_vec(M, b, p) for b in basis]
            if subspace_dim(list(basis) + images, p) == d:
                # canonical key = frozenset of all points of the subspace
                points = frozenset(
                    tuple(sum(coeff[k] * basis[k][j] for k in range(d)) % p
                          for j in range(n))
                    for coeff in product(range(p), repeat=d))
                found[points] = basis
    return list(found.values())


# --------------------------------------------------------------------------
# GL_n(F_q) statistics (certificate density)
# --------------------------------------------------------------------------

def gl_order(n: int, q: int) -> int:
    order = 1
    for i in range(n):
        order *= (q ** n - q ** i)
    return order


def count_irreducible_monic(n: int, q: int) -> int:
    """Number of monic irreducible polynomials of degree n over F_q (Mobius)."""
    def mobius(m: int) -> int:
        if m == 1:
            return 1
        res, mm = 1, m
        d = 2
        while d * d <= mm:
            if mm % d == 0:
                mm //= d
                if mm % d == 0:
                    return 0
                res = -res
            d += 1
        if mm > 1:
            res = -res
        return res
    total = sum(mobius(d) * q ** (n // d) for d in range(1, n + 1) if n % d == 0)
    return total // n


def singer_certificate_density(n: int, q: int) -> float:
    """
    Fraction of GL_n(F_q) with irreducible characteristic polynomial.
    Each irreducible monic of degree n contributes one conjugacy class of
    size |GL_n| / (q^n - 1) (the companion matrix and its conjugates).
    """
    classes = count_irreducible_monic(n, q)
    class_size = gl_order(n, q) // (q ** n - 1)
    return classes * class_size / gl_order(n, q)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_irreducible_action(p: int = 5) -> None:
    print("=" * 68)
    print(f"Theorem 4.1: irreducible charpoly  =>  no proper invariant subspace")
    print("=" * 68)
    # x^2 + x + 1 over F_5: irreducible? (no roots in F_5)
    f = [1, 1, 1]  # 1 + x + x^2
    M = companion_matrix(f, p)
    cp = charpoly(M, p)
    print(f"Field F_{p}, companion matrix of f = x^2 + x + 1")
    print(f"  charpoly(M)  = {cp}  (low-degree first)")
    print(f"  irreducible? = {is_irreducible(cp, p)}")
    subs = all_proper_invariant_subspaces(M, p)
    print(f"  proper nonzero invariant subspaces found: {len(subs)}  (expect 0)")

    # A reducible example for contrast: diagonal matrix.
    D = [[2, 0], [0, 3]]
    cpD = charpoly(D, p)
    print(f"\nContrast: diagonal M = diag(2,3) over F_{p}")
    print(f"  charpoly(M)  = {cpD}")
    print(f"  irreducible? = {is_irreducible(cpD, p)}")
    subsD = all_proper_invariant_subspaces(D, p)
    print(f"  proper nonzero invariant subspaces found: {len(subsD)}  (expect 2)")


def demo_orbit_spanning(p: int = 7) -> None:
    print("\n" + "=" * 68)
    print("Theorem 5.2: orbit of a nonzero vector spans the whole space")
    print("=" * 68)
    f = [1, 0, 0, 1]  # x^3 + 1? check irreducibility; pick a good one below
    # find an irreducible cubic over F_p
    f = None
    for c0, c1, c2 in product(range(p), repeat=3):
        cand = [c0, c1, c2, 1]
        if c0 != 0 and is_irreducible(cand, p):
            f = cand
            break
    assert f is not None
    M = companion_matrix(f, p)
    n = len(f) - 1
    v = tuple([1] + [0] * (n - 1))
    orb = orbit(M, v, p, steps=n - 1)
    d = subspace_dim(orb, p)
    print(f"Field F_{p}, irreducible charpoly f = {f}, n = {n}")
    print(f"  seed v          = {v}")
    print(f"  orbit v..M^{n-1}v : dim of span = {d}  (expect {n})")
    print(f"  spans whole space? {d == n}")


def demo_certificate_density() -> None:
    print("\n" + "=" * 68)
    print("Theorem 7.2 / Conjecture A: certificate density in GL_n(F_q)")
    print("=" * 68)
    print(f"{'n':>3} {'q':>3} {'irr. polys':>12} {'density':>12} {'1/n':>10}")
    for q in (2, 3, 5):
        for n in (2, 3, 4, 5):
            dens = singer_certificate_density(n, q)
            print(f"{n:>3} {q:>3} {count_irreducible_monic(n, q):>12} "
                  f"{dens:>12.6f} {1.0/n:>10.6f}")
    print("\nObserve: density ~ 1/n, matching the conjectured lower bound c_q/n.")


def main() -> None:
    demo_irreducible_action(p=5)
    demo_orbit_spanning(p=7)
    demo_certificate_density()


if __name__ == "__main__":
    main()
