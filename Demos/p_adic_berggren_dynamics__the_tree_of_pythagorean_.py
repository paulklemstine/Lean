"""
p-adic Berggren dynamics — numerical demonstrations.
=====================================================

The Berggren (Barning--Hall) moves are the three integer matrices

    B1 = [[ 1,-2, 2],      B2 = [[ 1, 2, 2],      B3 = [[-1, 2, 2],
          [ 2,-1, 2],            [ 2, 1, 2],            [-2, 1, 2],
          [ 2,-2, 3]]            [ 2, 2, 3]]            [-2, 2, 3]]

acting on column vectors (a, b, c).  Starting from the root triple (3, 4, 5)
they generate, without repetition, every primitive Pythagorean triple exactly
once: the ternary Berggren tree.  All three matrices preserve the Lorentz form

    q(a, b, c) = a^2 + b^2 - c^2,

so the tree lives entirely on the null cone q = 0.

This script demonstrates, by direct computation, the results of the
accompanying paper on the reduction of this dynamical system modulo p^k:

  1. Lorentz invariance and invertibility of the three moves.
  2. Unipotence:  B1 = I + N1 with N1^3 = 0, and N1^2 = 0 exactly when 4 = 0.
  3. Exact order:  ord(B1 mod p^k) = p^k for every odd prime p.
  4. Hyperbolic block:  B2 is conjugate to diag(-1) (+) [[3,2],[4,3]],
     the matrix of the unit 3 + 2*sqrt(2).
  5. The split/inert dichotomy:  ord(B2 mod p) | p - 1 when p = +-1 (mod 8),
     and ord(B2 mod p) | p + 1 when p = +-3 (mod 8); always | p^2 - 1.
  6. Null-cone census:  the cone q = 0 in (Z/p)^3 has exactly p^2 points.
  7. Fixed-point dichotomy:  B1 fixes p points (a whole isotropic line),
     B2 fixes only the origin.
  8. Non-transitivity:  every B2-orbit has at most p + 1 points, hence at
     least p - 1 orbits on the p^2 - 1 nonzero null vectors.
  9. Hensel lifting:  B2^((p^2 - 1) p^k) = I mod p^(k+1), with the p-part of
     the order generically gaining exactly one factor of p per digit.
 10. Collapse at p = 2:  all three generators reduce to the identity, so the
     whole tree is congruent to (1, 0, 1) mod 2.
 11. Collapse of the boundary: the tree collides massively modulo any fixed
     level, so no p-adic Cantor set survives at finite depth.
 12. Exceptional primes:  p = 13 and p = 31 are the only primes below 3000 at
     which the period of the boost fails to grow at the first extra p-adic
     digit -- a Wieferich-type phenomenon for the unit 3 + sqrt(8).

Pure standard library; no dependencies.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Sequence, Set, Tuple

Matrix = Tuple[Tuple[int, ...], ...]
Vector = Tuple[int, ...]

# ---------------------------------------------------------------------------
# The generators
# ---------------------------------------------------------------------------

B1: Matrix = ((1, -2, 2), (2, -1, 2), (2, -2, 3))
B2: Matrix = ((1, 2, 2), (2, 1, 2), (2, 2, 3))
B3: Matrix = ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3))

C1: Matrix = ((1, 2, -2), (-2, -1, 2), (-2, -2, 3))   # inverse of B1
C2: Matrix = ((1, 2, -2), (2, 1, -2), (-2, -2, 3))    # inverse of B2
C3: Matrix = ((-1, -2, 2), (2, 1, -2), (-2, -2, 3))   # inverse of B3

IDENTITY: Matrix = ((1, 0, 0), (0, 1, 0), (0, 0, 1))
ROOT: Vector = (3, 4, 5)


# ---------------------------------------------------------------------------
# Basic linear algebra modulo m  (m = 0 means "over the integers")
# ---------------------------------------------------------------------------

def reduce_matrix(a: Matrix, m: int) -> Matrix:
    """Entrywise reduction modulo m (m = 0 leaves the matrix unchanged)."""
    if m == 0:
        return a
    return tuple(tuple(x % m for x in row) for row in a)


def mat_mul(a: Matrix, b: Matrix, m: int = 0) -> Matrix:
    """Matrix product, optionally reduced modulo m."""
    n = len(a)
    out = [[sum(a[i][k] * b[k][j] for k in range(n)) for j in range(n)] for i in range(n)]
    if m:
        out = [[x % m for x in row] for row in out]
    return tuple(tuple(row) for row in out)


def mat_vec(a: Matrix, v: Vector, m: int = 0) -> Vector:
    """Matrix acting on a column vector, optionally reduced modulo m."""
    out = tuple(sum(a[i][k] * v[k] for k in range(len(v))) for i in range(len(v)))
    if m:
        out = tuple(x % m for x in out)
    return out


def mat_pow(a: Matrix, e: int, m: int = 0) -> Matrix:
    """Fast exponentiation by squaring, optionally modulo m."""
    result = reduce_matrix(IDENTITY, m)
    base = reduce_matrix(a, m)
    while e:
        if e & 1:
            result = mat_mul(result, base, m)
        base = mat_mul(base, base, m)
        e >>= 1
    return result


def mat_sub(a: Matrix, b: Matrix) -> Matrix:
    return tuple(tuple(x - y for x, y in zip(ra, rb)) for ra, rb in zip(a, b))


def lorentz(v: Sequence[int], m: int = 0) -> int:
    """The Lorentz form a^2 + b^2 - c^2 (reduced mod m when m > 0)."""
    q = v[0] ** 2 + v[1] ** 2 - v[2] ** 2
    return q % m if m else q


def matrix_order(a: Matrix, m: int) -> int:
    """Multiplicative order of a in GL_3(Z/m), found by iteration."""
    ident = reduce_matrix(IDENTITY, m)
    cur = reduce_matrix(a, m)
    k = 1
    while cur != ident:
        cur = mat_mul(cur, reduce_matrix(a, m), m)
        k += 1
        if k > 10 ** 7:
            raise RuntimeError("no finite order found")
    return k


def is_square_mod(a: int, p: int) -> bool:
    return any((x * x - a) % p == 0 for x in range(p))


def primes_up_to(n: int) -> List[int]:
    sieve = [True] * (n + 1)
    sieve[0:2] = [False, False]
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, n + 1, i):
                sieve[j] = False
    return [i for i, b in enumerate(sieve) if b]


def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


# ---------------------------------------------------------------------------
# 1. Lorentz invariance, invertibility, and the tree itself
# ---------------------------------------------------------------------------

def demo_tree_and_invariance(depth: int = 3) -> None:
    banner("1.  The Berggren tree and the Lorentz form")
    level: List[Vector] = [ROOT]
    print(f"  depth 0: {level}")
    for d in range(1, depth + 1):
        level = [mat_vec(g, v) for v in level for g in (B1, B2, B3)]
        assert all(lorentz(v) == 0 for v in level)
        shown = level[:6]
        tail = " ..." if len(level) > 6 else ""
        print(f"  depth {d}: {len(level):3d} triples, all with a^2+b^2=c^2; "
              f"e.g. {shown}{tail}")
    for name, g, ginv in (("B1", B1, C1), ("B2", B2, C2), ("B3", B3, C3)):
        assert mat_mul(g, ginv) == IDENTITY and mat_mul(ginv, g) == IDENTITY
        print(f"  {name} is invertible over Z (its inverse has integer entries) -> "
              f"each move is a bijection of the null cone")


# ---------------------------------------------------------------------------
# 2. Unipotence of B1 and B3
# ---------------------------------------------------------------------------

def demo_unipotence() -> None:
    banner("2.  Unipotent structure:  B1 = I + N1,  N1^3 = 0")
    N1 = mat_sub(B1, IDENTITY)
    N3 = mat_sub(B3, IDENTITY)
    print(f"  N1      = {N1}")
    print(f"  N1^2    = {mat_mul(N1, N1)}")
    print(f"  N1^3    = {mat_mul(mat_mul(N1, N1), N1)}   (zero)")
    assert mat_mul(mat_mul(N1, N1), N1) == tuple(tuple([0] * 3) for _ in range(3))
    assert mat_mul(mat_mul(N3, N3), N3) == tuple(tuple([0] * 3) for _ in range(3))
    print("  every entry of N1^2 is a multiple of 4, so N1^2 = 0 modulo 2 and "
          "modulo 4:")
    for m in (2, 4, 8, 3, 9):
        sq = reduce_matrix(mat_mul(N1, N1), m)
        zero = all(x == 0 for row in sq for x in row)
        print(f"    mod {m:2d}: N1^2 {'= 0  (nilpotency index 2)' if zero else '!= 0 (nilpotency index 3)'}")


# ---------------------------------------------------------------------------
# 3. Exact order of the unipotent generator modulo p^k
# ---------------------------------------------------------------------------

def demo_unipotent_order(primes: Sequence[int] = (3, 5, 7, 11), kmax: int = 3) -> None:
    banner("3.  ord(B1 mod p^k) = p^k exactly  (pure p-power: 'pro-p' behaviour)")
    print(f"  {'p':>3} {'k':>2} {'p^k':>7} {'ord(B1)':>9} {'ord(B3)':>9}  match")
    for p in primes:
        for k in range(1, kmax + 1):
            m = p ** k
            o1 = matrix_order(B1, m)
            o3 = matrix_order(B3, m)
            assert o1 == m and o3 == m
            print(f"  {p:>3} {k:>2} {m:>7} {o1:>9} {o3:>9}   yes")
    print("  and sharpness: B1^(p^k) != I modulo p^(k+1):")
    for p in (3, 5, 7):
        for k in (1, 2):
            got = mat_pow(B1, p ** k, p ** (k + 1))
            assert got != reduce_matrix(IDENTITY, p ** (k + 1))
            print(f"    p={p}, k={k}: B1^{p**k} = I mod {p**k} but != I mod {p**(k+1)}")


# ---------------------------------------------------------------------------
# 4. The hyperbolic block of B2
# ---------------------------------------------------------------------------

def demo_hyperbolic_block() -> None:
    banner("4.  B2 is conjugate to diag(-1) (+) U,  U = [[3,2],[4,3]] = 3 + 2*sqrt(2)")
    W: Matrix = ((1, 1, 0), (-1, 1, 0), (0, 0, 1))     # columns: eigenvectors
    S: Matrix = ((-1, 0, 0), (0, 1, 0), (0, 0, 1))
    embU: Matrix = ((1, 0, 0), (0, 3, 2), (0, 4, 3))
    lhs = mat_mul(B2, W)
    rhs = mat_mul(W, mat_mul(S, embU))
    print(f"  B2 * W          = {lhs}")
    print(f"  W * (S * emb U) = {rhs}")
    assert lhs == rhs
    print("  so B2 acts as -1 on (1,-1,0) and as U on the plane spanned by "
          "(1,1,0), (0,0,1).")
    J: Matrix = ((0, 1), (2, 0))
    JJ = tuple(tuple(sum(J[i][k] * J[k][j] for k in range(2)) for j in range(2))
               for i in range(2))
    print(f"  with J = {J},  J^2 = {JJ} = 2*I, i.e. J plays the role of sqrt(2);")
    print("  U = 3 + 2J has determinant 9 - 8 = 1: the square of the fundamental "
          "unit 1 + sqrt(2).")
    print(f"  characteristic polynomial of U:  x^2 - 6x + 1, roots 3 +- 2*sqrt(2) "
          f"= {3 + 2 * 2 ** 0.5:.6f}, {3 - 2 * 2 ** 0.5:.6f}")


# ---------------------------------------------------------------------------
# 5. The split/inert dichotomy modulo p
# ---------------------------------------------------------------------------

def demo_split_inert(limit: int = 60) -> None:
    banner("5.  Split/inert dichotomy:  ord(B2 mod p) | p-1 iff p = +-1 (mod 8)")
    print(f"  {'p':>4} {'p mod 8':>8} {'2 a square?':>12} {'ord(B2)':>8} "
          f"{'divides':>10} {'| p^2-1':>8}")
    for p in primes_up_to(limit):
        if p == 2:
            continue
        o = matrix_order(B2, p)
        sq = is_square_mod(2, p)
        expected = p - 1 if sq else p + 1
        assert expected % o == 0
        assert (p * p - 1) % o == 0
        print(f"  {p:>4} {p % 8:>8} {str(sq):>12} {o:>8} "
              f"{('p-1' if sq else 'p+1'):>10} {'yes':>8}")
    print("  in every case the order divides p^2 - 1, and 2 is a square exactly "
          "when p = 1 or 7 (mod 8).")


# ---------------------------------------------------------------------------
# 6. Census of the null cone modulo p
# ---------------------------------------------------------------------------

def null_cone(p: int) -> List[Vector]:
    """All v in (Z/p)^3 with v0^2 + v1^2 - v2^2 = 0."""
    return [v for v in product(range(p), repeat=3) if lorentz(v, p) == 0]


def demo_null_cone(primes: Sequence[int] = (3, 5, 7, 11, 13)) -> None:
    banner("6.  The null cone modulo p has exactly p^2 points")
    print(f"  {'p':>4} {'|cone|':>8} {'p^2':>8} {'|cone|-1':>10} {'(p-1)(p+1)':>12}")
    for p in primes:
        cone = null_cone(p)
        assert len(cone) == p * p
        print(f"  {p:>4} {len(cone):>8} {p * p:>8} {len(cone) - 1:>10} "
              f"{(p - 1) * (p + 1):>12}")
    print("  fibring by the light-cone coordinate u = c - a: every one of the p "
          "fibres has exactly p points,")
    print("  including the degenerate fibre u = 0, which is the isotropic line "
          "(s, 0, s).")
    p = 7
    for u in range(p):
        fibre = [v for v in null_cone(p) if (v[2] - v[0]) % p == u]
        assert len(fibre) == p
    print(f"  (checked for p = {p}: all {p} fibres have {p} points)")


# ---------------------------------------------------------------------------
# 7. Fixed-point dichotomy
# ---------------------------------------------------------------------------

def demo_fixed_points(primes: Sequence[int] = (3, 5, 7, 11)) -> None:
    banner("7.  Fixed points: B1 fixes an isotropic line (p points), B2 only 0")
    print(f"  {'p':>4} {'#fix(B1)':>10} {'#fix(B2)':>10} {'#fix(B3)':>10}")
    for p in primes:
        f1 = [v for v in product(range(p), repeat=3) if mat_vec(B1, v, p) == v]
        f2 = [v for v in product(range(p), repeat=3) if mat_vec(B2, v, p) == v]
        f3 = [v for v in product(range(p), repeat=3) if mat_vec(B3, v, p) == v]
        assert len(f1) == p and len(f2) == 1 and len(f3) == p
        assert all(v[0] == 0 and v[1] == v[2] for v in f1)   # the line (0, t, t)
        assert all(lorentz(v, p) == 0 for v in f1)           # and it is isotropic
        print(f"  {p:>4} {len(f1):>10} {len(f2):>10} {len(f3):>10}")
    print("  fix(B1) = {(0,t,t)} and fix(B3) = {(t,0,t)}: null lines, i.e. "
          "boundary points of the light cone.")
    print("  the hyperbolic generator fixes nothing but the origin.")


# ---------------------------------------------------------------------------
# 8. Orbit structure and non-transitivity of the hyperbolic generator
# ---------------------------------------------------------------------------

def b2_orbits(p: int) -> Dict[int, int]:
    """Orbit-length histogram of B2 acting on the nonzero null cone mod p."""
    cone: Set[Vector] = {v for v in null_cone(p) if any(v)}
    seen: Set[Vector] = set()
    hist: Dict[int, int] = {}
    for v in sorted(cone):
        if v in seen:
            continue
        orbit = [v]
        seen.add(v)
        w = mat_vec(B2, v, p)
        while w != v:
            orbit.append(w)
            seen.add(w)
            w = mat_vec(B2, w, p)
        hist[len(orbit)] = hist.get(len(orbit), 0) + 1
    return hist


def demo_orbits(primes: Sequence[int] = (3, 5, 7, 11, 13, 17)) -> None:
    banner("8.  Orbits of the hyperbolic generator: short, hence never transitive")
    print(f"  {'p':>4} {'|cone*|':>8} {'ord(B2)':>8} {'#orbits':>8} "
          f"{'longest':>8}  orbit-length histogram")
    for p in primes:
        hist = b2_orbits(p)
        o = matrix_order(B2, p)
        n_orb = sum(hist.values())
        longest = max(hist)
        assert longest <= p + 1
        assert n_orb >= p - 1
        pretty = ", ".join(f"{L}^{c}" for L, c in sorted(hist.items()))
        print(f"  {p:>4} {p * p - 1:>8} {o:>8} {n_orb:>8} {longest:>8}  {pretty}")
    print("  every orbit length divides ord(B2) <= p + 1 < p^2 - 1, so at least "
          "p - 1 orbits are needed:")
    print("  the reduced Berggren dynamics is never ergodic on the null cone.")


# ---------------------------------------------------------------------------
# 9. Hensel lifting: periodicity to any p-adic precision
# ---------------------------------------------------------------------------

def demo_hensel(primes: Sequence[int] = (3, 5, 7), kmax: int = 3) -> None:
    banner("9.  Hensel lift:  B2^((p^2-1) p^k) = I mod p^(k+1);  order gains one "
           "factor of p per digit")
    print(f"  {'p':>4} {'k':>2} {'modulus':>9} {'(p^2-1)p^k':>12} "
          f"{'= I ?':>7} {'true order':>11} {'ord/ord(mod p)':>15}")
    for p in primes:
        o1 = matrix_order(B2, p)
        for k in range(0, kmax):
            m = p ** (k + 1)
            e = (p * p - 1) * p ** k
            ok = mat_pow(B2, e, m) == reduce_matrix(IDENTITY, m)
            assert ok
            o = matrix_order(B2, m)
            assert e % o == 0
            print(f"  {p:>4} {k:>2} {m:>9} {e:>12} {'yes':>7} {o:>11} "
                  f"{o // o1:>15}")
    print("  the true order modulo p^(k+1) is exactly ord(B2 mod p) * p^k in "
          "every case computed here.")
    print("  p-adic contraction: |B2^N v - v|_p <= p^-(k+1) with N = (p^2-1)p^k, "
          "for every integer vector v:")
    p, k = 5, 2
    N = (p * p - 1) * p ** k
    v = (3, 4, 5)
    w = mat_vec(mat_pow(B2, N), v)
    diff = tuple(x - y for x, y in zip(w, v))

    def val(x: int, q: int) -> int:
        e = 0
        while x % q == 0:
            x //= q
            e += 1
        return e

    vals = tuple(val(d, p) for d in diff)
    assert all(e >= k + 1 for e in vals)
    print(f"    p={p}, k={k}, N={N}, v={v}: the entries of B2^N v - v have "
          f"{len(str(diff[0]))} digits and p-adic valuations {vals},")
    print(f"    all at least k+1 = {k + 1}, i.e. |B2^N v - v|_p <= "
          f"{p}^-{k + 1}.")


# ---------------------------------------------------------------------------
# 10. The prime 2: total collapse, and the parity of the tree
# ---------------------------------------------------------------------------

def demo_prime_two(depth: int = 5) -> None:
    banner("10.  At p = 2 the system collapses: every generator is the identity")
    for name, g in (("B1", B1), ("B2", B2), ("B3", B3)):
        red = reduce_matrix(g, 2)
        assert red == IDENTITY
        print(f"  {name} mod 2 = {red}  (the identity)")
    level: List[Vector] = [ROOT]
    for _ in range(depth):
        level = [mat_vec(g, v) for v in level for g in (B1, B2, B3)]
    residues = {tuple(x % 2 for x in v) for v in level}
    assert residues == {(1, 0, 1)}
    print(f"  all {len(level)} triples at depth {depth} are congruent to "
          f"{residues.pop()} mod 2:")
    print("  odd leg, even leg, odd hypotenuse. No vertex of the tree ever has "
          "two odd legs.")


# ---------------------------------------------------------------------------
# 11. Collapse of the boundary: collisions modulo a fixed level
# ---------------------------------------------------------------------------

def demo_boundary_collapse(p: int = 5, depth: int = 4) -> None:
    banner("11.  The boundary of the tree does not survive reduction")
    words = list(product((B1, B2, B3), repeat=depth))
    images: Dict[Vector, int] = {}
    collisions = 0
    for w in words:
        v: Vector = ROOT
        for g in reversed(w):
            v = mat_vec(g, v, p)
        if v in images:
            collisions += 1
        images[v] = images.get(v, 0) + 1
    print(f"  p = {p}, depth = {depth}: {3 ** depth} words, "
          f"{len(images)} distinct images mod {p}")
    print(f"  {collisions} collisions -- forced, since the whole tree lies on the "
          f"null cone, which has only p^2 = {p * p} points,")
    print(f"  while the tree has 3^{depth} = {3 ** depth} vertices at this depth.")
    print("  So no fixed finite level Z/p^k can hold a faithful copy of the "
          "boundary; what survives is the")
    print("  inverse-limit statement: each generator is periodic to any "
          "prescribed p-adic precision.")


# ---------------------------------------------------------------------------
# 12. Exceptional ("Wieferich-type") primes for the hyperbolic generator
# ---------------------------------------------------------------------------

def divisors(n: int) -> List[int]:
    """All positive divisors of n, in increasing order."""
    small = [d for d in range(1, int(n ** 0.5) + 1) if n % d == 0]
    return sorted(small + [n // d for d in small if d * d != n])


def is_square_mod_fast(a: int, p: int) -> bool:
    """Euler's criterion."""
    return pow(a % p, (p - 1) // 2, p) == 1


def order_by_divisors(a: Matrix, m: int, bound: int) -> int:
    """Least divisor d of bound with a^d = I modulo m."""
    ident = reduce_matrix(IDENTITY, m)
    return min(d for d in divisors(bound) if mat_pow(a, d, m) == ident)


def demo_wieferich(limit: int = 3000) -> None:
    banner("12.  Exceptional primes: when the period does NOT grow at the first "
           "p-adic digit")
    print("  generically ord(B2 mod p^2) = p * ord(B2 mod p); the exceptions are the primes")
    print("  for which the eigenvalue 3 + 2*sqrt(2) is already trivial to two p-adic digits:")
    exceptional: List[Tuple[int, int]] = []
    for p in primes_up_to(limit):
        if p == 2:
            continue
        bound = p - 1 if is_square_mod_fast(2, p) else p + 1
        o1 = order_by_divisors(B2, p, bound)
        if mat_pow(B2, o1, p * p) == reduce_matrix(IDENTITY, p * p):
            exceptional.append((p, o1))
    for p, o in exceptional:
        o2 = order_by_divisors(B2, p * p, (p * p - 1) * p)
        o3 = order_by_divisors(B2, p ** 3, (p * p - 1) * p * p)
        print(f"    p = {p}: ord mod p = {o}, ord mod p^2 = {o2}, ord mod p^3 = {o3} "
              f"-- growth delayed by exactly one digit")
    print(f"  exceptional primes below {limit}: "
          f"{[p for p, _ in exceptional]}  (all others gain a factor of p per digit)")
    assert [p for p, _ in exceptional] == [13, 31]


def main() -> None:
    print(__doc__)
    demo_tree_and_invariance()
    demo_unipotence()
    demo_unipotent_order()
    demo_hyperbolic_block()
    demo_split_inert()
    demo_null_cone()
    demo_fixed_points()
    demo_orbits()
    demo_hensel()
    demo_prime_two()
    demo_boundary_collapse()
    demo_wieferich()
    print("\nAll assertions passed.\n")


if __name__ == "__main__":
    main()
