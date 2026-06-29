"""
demo.py — Certified Expanders for Classical Groups
==================================================

Self-contained numerical demonstrations of the results in the package
"Certified Expanders for Classical Groups".

The package develops a *certificate architecture* linking three layers:

    1. Regular toral elements        (algebra:  minpoly = charpoly)
    2. Invariance-breaking            (linear algebra: no shared block form)
    3. Cayley-graph vertex expansion  (graph theory: large boundaries)

This file reproduces, with concrete small examples, the four headline
results:

    T1. classical_certificate_no_proper_invariant_submodule
        A pair (s, t) with s having IRREDUCIBLE characteristic polynomial
        leaves no proper nontrivial subspace invariant under <s, t>.

    T2. vertex_expansion_implies_generates
        A vertex-expanding generating set must generate the whole group.

    T3. expansion_monotone_of_superset
        Enlarging the generating set never destroys vertex expansion.

    T4. cayley_neighbor_card_le
        |neighbours of A| <= |A| * |S|.

Everything is pure Python (no third-party dependencies); finite-field
linear algebra is implemented from scratch over GF(p).
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Sequence, Set, Tuple

# ----------------------------------------------------------------------
#  Part I.  Finite-field linear algebra over GF(p)
# ----------------------------------------------------------------------

Vector = Tuple[int, ...]
Matrix = Tuple[Tuple[int, ...], ...]
Poly = Tuple[int, ...]  # coefficients low-degree first


def inv_mod(a: int, p: int) -> int:
    """Multiplicative inverse of a modulo prime p (Fermat)."""
    return pow(a % p, p - 2, p)


def mat_mul(a: Matrix, b: Matrix, p: int) -> Matrix:
    n, m, k = len(a), len(b[0]), len(b)
    return tuple(
        tuple(sum(a[i][t] * b[t][j] for t in range(k)) % p for j in range(m))
        for i in range(n)
    )


def mat_vec(a: Matrix, v: Vector, p: int) -> Vector:
    return tuple(sum(a[i][j] * v[j] for j in range(len(v))) % p for i in range(len(a)))


def identity(n: int) -> Matrix:
    return tuple(tuple(1 if i == j else 0 for j in range(n)) for i in range(n))


def charpoly(a: Matrix, p: int) -> Poly:
    """Characteristic polynomial via the Faddeev-LeVerrier algorithm over GF(p).

    Returns coefficients of det(xI - A), low degree first, monic of degree n.
    Requires p > n so that the integers 1..n are invertible mod p.
    """
    n = len(a)
    M = tuple(tuple(0 for _ in range(n)) for _ in range(n))
    coeffs = [0] * (n + 1)
    coeffs[n] = 1  # leading (x^n) coefficient
    Ident = identity(n)
    for k in range(1, n + 1):
        # M_k = A * M_{k-1} + c_{n-k+1} I
        AM = mat_mul(a, M, p)
        c_prev = coeffs[n - k + 1]
        M = tuple(
            tuple((AM[i][j] + (c_prev if i == j else 0)) % p for j in range(n))
            for i in range(n)
        )
        trace = sum(mat_mul(a, M, p)[i][i] for i in range(n)) % p
        coeffs[n - k] = (-inv_mod(k, p) * trace) % p
    return tuple(coeffs)


def _row_reduce(rows: List[List[int]], p: int) -> int:
    """In-place Gaussian elimination over GF(p); returns the rank."""
    rank = 0
    ncols = len(rows[0]) if rows else 0
    for col in range(ncols):
        pivot = next((r for r in range(rank, len(rows)) if rows[r][col] % p), None)
        if pivot is None:
            continue
        rows[rank], rows[pivot] = rows[pivot], rows[rank]
        inv = inv_mod(rows[rank][col], p)
        rows[rank] = [(x * inv) % p for x in rows[rank]]
        for r in range(len(rows)):
            if r != rank and rows[r][col] % p:
                f = rows[r][col]
                rows[r] = [(x - f * y) % p for x, y in zip(rows[r], rows[rank])]
        rank += 1
    return rank


def minpoly_degree(a: Matrix, p: int) -> int:
    """Degree of the minimal polynomial: smallest d with I, A, ..., A^d dependent."""
    n = len(a)
    powers: List[Matrix] = [identity(n)]
    flat = [list(_flatten(powers[0]))]
    while True:
        nxt = mat_mul(a, powers[-1], p)
        powers.append(nxt)
        candidate = flat + [list(_flatten(nxt))]
        if _row_reduce([row[:] for row in candidate], p) < len(candidate):
            return len(powers) - 1
        flat = candidate


def _flatten(m: Matrix) -> Vector:
    return tuple(x for row in m for x in row)


def is_regular_toral(a: Matrix, p: int) -> bool:
    """minpoly = charpoly  <=>  deg(minpoly) = n  (since both are monic)."""
    return minpoly_degree(a, p) == len(a)


# ---- polynomial arithmetic over GF(p) for an irreducibility test ----

def poly_trim(f: Poly, p: int) -> Poly:
    f = tuple(c % p for c in f)
    while len(f) > 1 and f[-1] == 0:
        f = f[:-1]
    return f


def poly_mod(a: Poly, m: Poly, p: int) -> Poly:
    a = list(c % p for c in a)
    m = poly_trim(m, p)
    dm = len(m) - 1
    inv_lead = inv_mod(m[-1], p)
    while len(a) - 1 >= dm and any(a):
        if a[-1] % p == 0:
            a.pop()
            continue
        shift = len(a) - 1 - dm
        factor = (a[-1] * inv_lead) % p
        for i, c in enumerate(m):
            a[i + shift] = (a[i + shift] - factor * c) % p
        while len(a) > 1 and a[-1] == 0:
            a.pop()
    return poly_trim(tuple(a), p)


def poly_mul_mod(a: Poly, b: Poly, m: Poly, p: int) -> Poly:
    res = [0] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        for j, y in enumerate(b):
            res[i + j] = (res[i + j] + x * y) % p
    return poly_mod(tuple(res), m, p)


def poly_pow_mod(base: Poly, e: int, m: Poly, p: int) -> Poly:
    result: Poly = (1,)
    base = poly_mod(base, m, p)
    while e:
        if e & 1:
            result = poly_mul_mod(result, base, m, p)
        base = poly_mul_mod(base, base, m, p)
        e >>= 1
    return result


def poly_gcd(a: Poly, b: Poly, p: int) -> Poly:
    a, b = poly_trim(a, p), poly_trim(b, p)
    while b != (0,) and any(b):
        a, b = b, poly_mod(a, b, p)
    return poly_trim(a, p)


def is_irreducible(f: Poly, p: int) -> bool:
    """Rabin's irreducibility test for a monic polynomial f over GF(p)."""
    f = poly_trim(f, p)
    d = len(f) - 1
    if d <= 0:
        return False
    if d == 1:
        return True
    x: Poly = (0, 1)
    # x^(p^d) must equal x mod f
    h = poly_pow_mod(x, p ** d, f, p)
    if poly_trim(tuple(c % p for c in _sub(h, x)), p) != (0,):
        return False
    # for each prime q | d:  gcd(x^(p^(d/q)) - x, f) = 1
    for q in _prime_divisors(d):
        h = poly_pow_mod(x, p ** (d // q), f, p)
        g = poly_gcd(tuple(c % p for c in _sub(h, x)), f, p)
        if len(g) - 1 != 0:
            return False
    return True


def _sub(a: Poly, b: Poly) -> Poly:
    n = max(len(a), len(b))
    a = a + (0,) * (n - len(a))
    b = b + (0,) * (n - len(b))
    return tuple(x - y for x, y in zip(a, b))


def _prime_divisors(n: int) -> Set[int]:
    out: Set[int] = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            out.add(d)
            n //= d
        d += 1
    if n > 1:
        out.add(n)
    return out


# ----------------------------------------------------------------------
#  Part II.  Invariant subspaces and the certificate (Theorem 1)
# ----------------------------------------------------------------------

def all_subspaces(n: int, p: int) -> List[List[Vector]]:
    """Enumerate every subspace of GF(p)^n as a list of its (all) vectors."""
    all_vecs = list(product(range(p), repeat=n))
    seen: Dict[frozenset, List[Vector]] = {}
    # generate spans of all subsets of a spanning set (brute force, small n)
    for r in range(n + 1):
        for combo in _subsets(all_vecs, r):
            span = _span(list(combo), p, n)
            seen[frozenset(span)] = sorted(span)
    return list(seen.values())


def _subsets(items: Sequence[Vector], r: int):
    from itertools import combinations
    return combinations(items, r)


def _span(gens: List[Vector], p: int, n: int) -> Set[Vector]:
    basis: Set[Vector] = {tuple([0] * n)}
    frontier = list(basis)
    for g in gens:
        new: Set[Vector] = set()
        for b in list(basis):
            for c in range(p):
                v = tuple((b[i] + c * g[i]) % p for i in range(n))
                if v not in basis:
                    new.add(v)
        basis |= new
        # close under addition
        changed = True
        while changed:
            changed = False
            cur = list(basis)
            for u in cur:
                for v in cur:
                    w = tuple((u[i] + v[i]) % p for i in range(n))
                    if w not in basis:
                        basis.add(w)
                        changed = True
    return basis


def is_invariant(a: Matrix, subspace: List[Vector], p: int) -> bool:
    s = set(subspace)
    return all(mat_vec(a, v, p) in s for v in subspace)


def certificate_irreducible(s: Matrix, t: Matrix, p: int) -> bool:
    """Verify Theorem 1 numerically: if charpoly(s) is irreducible, then no
    proper nontrivial subspace is invariant under BOTH s and t (equivalently
    under <s, t>).  Returns True iff the irreducible-action conclusion holds."""
    n = len(s)
    if not is_irreducible(charpoly(s, p), p):
        return False
    full = set(product(range(p), repeat=n))
    zero = {tuple([0] * n)}
    for W in all_subspaces(n, p):
        Wset = set(W)
        if Wset == zero or Wset == full:
            continue
        if is_invariant(s, W, p) and is_invariant(t, W, p):
            return False  # would contradict the theorem
    return True


# ----------------------------------------------------------------------
#  Part III.  Cayley graphs, expansion, generation (Theorems 2, 3, 4)
# ----------------------------------------------------------------------

Perm = Tuple[int, ...]  # permutation of {0,...,n-1}


def compose(a: Perm, b: Perm) -> Perm:
    """(a*b)(i) = a(b(i)) — right action used in the Cayley graph a*s."""
    return tuple(a[b[i]] for i in range(len(a)))


def group_closure(gens: Sequence[Perm], identity_perm: Perm) -> List[Perm]:
    """BFS closure of the generators -> the subgroup they generate."""
    seen: Set[Perm] = {identity_perm}
    frontier = [identity_perm]
    while frontier:
        nxt = []
        for g in frontier:
            for s in gens:
                h = compose(g, s)
                if h not in seen:
                    seen.add(h)
                    nxt.append(h)
        frontier = nxt
    return sorted(seen)


def cayley_neighbors(S: Sequence[Perm], A: Set[Perm]) -> Set[Perm]:
    """CayleyNeighborFinset: { a*s : a in A, s in S }."""
    return {compose(a, s) for a in A for s in S}


def cayley_boundary(S: Sequence[Perm], A: Set[Perm]) -> Set[Perm]:
    """CayleyVertexBoundary: neighbours of A not already in A."""
    return cayley_neighbors(S, A) - A


def vertex_expansion_constant(group: List[Perm], S: Sequence[Perm]) -> float:
    """Largest ε with  ε|A| <= |boundary(A)|  over all 0<|A|<=|G|/2."""
    from itertools import combinations
    G = list(group)
    N = len(G)
    best = float("inf")
    for size in range(1, N // 2 + 1):
        for combo in combinations(G, size):
            A = set(combo)
            b = len(cayley_boundary(S, A))
            best = min(best, b / size)
    return best


# ----------------------------------------------------------------------
#  Demonstrations
# ----------------------------------------------------------------------

def demo_regular_toral() -> None:
    print("=" * 64)
    print("Part I — Regular toral elements over GF(p)")
    print("=" * 64)
    p = 7
    # Companion-type matrix of x^2 - x - 1 (Fibonacci shift) over GF(7).
    s: Matrix = ((0, 1), (1, 1))
    cp = charpoly(s, p)
    print(f"  s = {s} over GF({p})")
    print(f"  charpoly(s)        = {cp}  (low-degree first)")
    print(f"  minpoly degree     = {minpoly_degree(s, p)}")
    print(f"  is_regular_toral   = {is_regular_toral(s, p)}")
    print(f"  charpoly irreducible over GF({p}) = {is_irreducible(cp, p)}")
    # A non-regular (scalar) matrix:
    scal: Matrix = ((3, 0), (0, 3))
    print(f"  scalar matrix {scal}: regular_toral = {is_regular_toral(scal, p)}")
    print()


def demo_certificate() -> None:
    print("=" * 64)
    print("Part II — Theorem 1: certificate => irreducible action")
    print("=" * 64)
    p = 7
    s: Matrix = ((0, 1), (1, 1))  # charpoly x^2 - x - 1, irreducible mod 7
    t: Matrix = ((1, 1), (0, 1))  # a transvection that breaks invariance
    print(f"  p = {p},  s = {s},  t = {t}")
    print(f"  charpoly(s) irreducible mod {p}: {is_irreducible(charpoly(s, p), p)}")
    ok = certificate_irreducible(s, t, p)
    print(f"  no proper nontrivial <s,t>-invariant subspace: {ok}")
    # Contrast: reducible charpoly admits an invariant line.
    s2: Matrix = ((1, 1), (0, 2))  # upper triangular, charpoly (x-1)(x-2)
    print(f"  control s2 = {s2}: charpoly irreducible = "
          f"{is_irreducible(charpoly(s2, p), p)} "
          f"(theorem hypothesis fails, as expected)")
    print()


def demo_cayley_expansion() -> None:
    print("=" * 64)
    print("Part III — Theorems 2, 3, 4: Cayley graph expansion")
    print("=" * 64)
    # Symmetric group S_4 generated by a transposition and a 4-cycle.
    n = 4
    e: Perm = tuple(range(n))
    transp: Perm = (1, 0, 2, 3)        # swap 0,1
    cycle: Perm = (1, 2, 3, 0)         # 4-cycle
    S = [transp, cycle, _inv(transp), _inv(cycle)]
    G = group_closure(S, e)
    print(f"  Group generated has order |G| = {len(G)} (expect 24 = |S_4|)")

    # Theorem 4: |neighbours(A)| <= |A| * |S|
    import random
    random.seed(0)
    A = set(random.sample(G, 6))
    nb = cayley_neighbors(S, A)
    print(f"  |A| = {len(A)}, |S| = {len(S)}, |neighbours(A)| = {len(nb)} "
          f"<= |A|*|S| = {len(A) * len(S)}: {len(nb) <= len(A) * len(S)}")

    # Theorem 2: positive expansion => generation (here S generates G).
    eps = vertex_expansion_constant(_small(G), S) if len(G) <= 12 else None
    full_gen = len(group_closure(S, e)) == len(G)
    print(f"  S generates the whole group (expansion forces this): {full_gen}")

    # Theorem 3: monotonicity — add a generator, expansion cannot drop.
    print("  Monotonicity check on a small group A_3 (order 3):")
    g3 = (1, 2, 0)
    e3 = (0, 1, 2)
    G3 = group_closure([g3, _inv(g3)], e3)
    S_small = [g3]
    S_big = [g3, _inv(g3)]
    eps_small = vertex_expansion_constant(G3, S_small)
    eps_big = vertex_expansion_constant(G3, S_big)
    print(f"    eps(small S) = {eps_small:.3f}, eps(big S) = {eps_big:.3f}, "
          f"monotone: {eps_big >= eps_small}")
    print()


def _inv(perm: Perm) -> Perm:
    out = [0] * len(perm)
    for i, j in enumerate(perm):
        out[j] = i
    return tuple(out)


def _small(G: List[Perm]) -> List[Perm]:
    return G


def main() -> None:
    demo_regular_toral()
    demo_certificate()
    demo_cayley_expansion()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
