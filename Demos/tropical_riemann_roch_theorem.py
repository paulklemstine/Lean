"""
Numerical demonstrations of Riemann-Roch theory for finite graphs
(Baker-Norine chip-firing theory).

This script is fully self-contained: it implements divisors, the chip-firing
(Laplacian) action, linear equivalence, the canonical divisor, the Baker-Norine
rank, and verifies:

  1. Degree invariance under chip-firing            (degree_invariance)
  2. The canonical degree identity  deg K = 2g - 2  (deg_canonical)
  3. Riemann-Roch in genus zero (trees)             (riemann_roch_genus_zero)
  4. The genus-one obstruction on the 2-edge banana (cycleTwo_hsurj_fails)

A graph is represented by a vertex count n and a symmetric adjacency-multiplicity
matrix A (A[i][j] = number of edges between i and j; no self-loops, A[i][i] = 0).
Divisors are integer vectors of length n.
"""

from __future__ import annotations

from itertools import product
from typing import List, Tuple

Matrix = List[List[int]]
Divisor = Tuple[int, ...]


# --------------------------------------------------------------------------
# Basic graph quantities
# --------------------------------------------------------------------------

def num_edges(adj: Matrix) -> int:
    """Total number of edges = (1/2) * sum of all adjacency multiplicities."""
    n = len(adj)
    return sum(adj[i][j] for i in range(n) for j in range(n)) // 2


def vertex_degree(adj: Matrix, v: int) -> int:
    """Degree of vertex v: number of edge-ends meeting v."""
    return sum(adj[v])


def genus(adj: Matrix) -> int:
    """First Betti number g = |E| - |V| + 1 (assumes connected)."""
    return num_edges(adj) - len(adj) + 1


def degree(D: Divisor) -> int:
    """Degree of a divisor: total chip count."""
    return sum(D)


def is_effective(D: Divisor) -> bool:
    """A divisor is effective if no vertex is in debt."""
    return all(c >= 0 for c in D)


# --------------------------------------------------------------------------
# Chip-firing: principal divisors and linear equivalence
# --------------------------------------------------------------------------

def prin(adj: Matrix, f: List[int]) -> Divisor:
    """Principal divisor of firing vector f:  prin(f)(v) = sum_w A[v][w]*(f[w]-f[v])."""
    n = len(adj)
    return tuple(
        sum(adj[v][w] * (f[w] - f[v]) for w in range(n))
        for v in range(n)
    )


def canonical(adj: Matrix) -> Divisor:
    """Canonical divisor K(v) = deg(v) - 2."""
    return tuple(vertex_degree(adj, v) - 2 for v in range(len(adj)))


def _firing_vectors(n: int, bound: int) -> List[List[int]]:
    """All firing vectors with entries in [-bound, bound], first coordinate fixed
    to 0 (firing the all-ones vector does nothing, so we may normalize f[0]=0)."""
    rng = range(-bound, bound + 1)
    return [[0] + list(rest) for rest in product(rng, repeat=n - 1)]


def linearly_equivalent(adj: Matrix, D: Divisor, E: Divisor, bound: int = 6) -> bool:
    """Search for a firing vector f (bounded) with D - E = prin(f).
    For small graphs this bounded search is complete enough to certify
    equivalence; non-equivalence is certified analytically in the demos below."""
    n = len(adj)
    target = tuple(D[i] - E[i] for i in range(n))
    if degree(target) != 0:
        return False
    for f in _firing_vectors(n, bound):
        if prin(adj, f) == target:
            return True
    return False


def is_winnable(adj: Matrix, D: Divisor, bound: int = 6) -> bool:
    """True if D is linearly equivalent to some effective divisor.

    On a tree (genus 0) winnability is equivalent to deg D >= 0, which we use as
    the certified criterion; for the small graphs here the bounded firing search
    confirms it directly."""
    if degree(D) < 0:
        return False
    # Try to fire D to an effective configuration via bounded search.
    n = len(adj)
    for f in _firing_vectors(n, bound):
        cand = tuple(D[i] + prin(adj, f)[i] for i in range(n))
        if is_effective(cand):
            return True
    return False


# --------------------------------------------------------------------------
# Baker-Norine rank
# --------------------------------------------------------------------------

def effective_divisors_of_degree(n: int, k: int) -> List[Divisor]:
    """All effective divisors on n vertices with total degree k (k >= 0)."""
    if k < 0:
        return []
    result: List[Divisor] = []
    for combo in product(range(k + 1), repeat=n):
        if sum(combo) == k:
            result.append(combo)
    return result


def satisfies_rank(adj: Matrix, D: Divisor, k: int, bound: int = 6) -> bool:
    """D satisfies rank k: for every effective E of degree k, D - E is winnable."""
    n = len(adj)
    for E in effective_divisors_of_degree(n, k):
        diff = tuple(D[i] - E[i] for i in range(n))
        if not is_winnable(adj, diff, bound):
            return False
    return True


def rank(adj: Matrix, D: Divisor, bound: int = 6) -> int:
    """Baker-Norine rank: -1 if D not winnable, else max k with satisfies_rank."""
    if not is_winnable(adj, D, bound):
        return -1
    k = 0
    while satisfies_rank(adj, D, k + 1, bound):
        k += 1
    return k


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def path_graph(n: int) -> Matrix:
    """Path on n vertices (a tree, genus 0)."""
    adj = [[0] * n for _ in range(n)]
    for i in range(n - 1):
        adj[i][i + 1] = adj[i + 1][i] = 1
    return adj


def star_graph(n: int) -> Matrix:
    """Star with center 0 and n-1 leaves (a tree, genus 0)."""
    adj = [[0] * n for _ in range(n)]
    for i in range(1, n):
        adj[0][i] = adj[i][0] = 1
    return adj


def banana_graph() -> Matrix:
    """Two vertices joined by two parallel edges (genus 1)."""
    return [[0, 2], [2, 0]]


def demo_degree_invariance() -> None:
    print("=" * 70)
    print("1. DEGREE INVARIANCE UNDER CHIP-FIRING")
    print("=" * 70)
    adj = path_graph(4)
    D = (3, -1, 2, 0)
    for f in ([0, 1, 0, 0], [0, 2, -1, 3], [1, 1, 1, 1]):
        Dp = tuple(D[i] + prin(adj, f)[i] for i in range(4))
        print(f"  fire {f}: {D} -> {Dp}   deg {degree(D)} -> {degree(Dp)}")
        assert degree(D) == degree(Dp)
    print("  OK: degree is preserved by every firing.\n")


def demo_canonical_degree() -> None:
    print("=" * 70)
    print("2. CANONICAL DEGREE IDENTITY  deg K = 2g - 2")
    print("=" * 70)
    for name, adj in [
        ("path P4", path_graph(4)),
        ("star S5", star_graph(5)),
        ("banana B2", banana_graph()),
    ]:
        K = canonical(adj)
        g = genus(adj)
        print(f"  {name:10s}: K = {K}, deg K = {degree(K)}, "
              f"g = {g}, 2g-2 = {2 * g - 2}")
        assert degree(K) == 2 * g - 2
    print("  OK: deg K = 2g - 2 for every graph.\n")


def demo_riemann_roch_genus_zero() -> None:
    print("=" * 70)
    print("3. RIEMANN-ROCH IN GENUS ZERO:  r(D) - r(K-D) = deg D + 1")
    print("=" * 70)
    adj = star_graph(4)          # tree, genus 0
    K = canonical(adj)
    n = len(adj)
    test_divisors = [(0, 0, 0, 0), (2, 0, 0, 0), (1, 1, 0, 0),
                     (-1, 0, 0, 0), (3, -1, 1, 0), (-2, -1, 0, 0)]
    for D in test_divisors:
        KmD = tuple(K[i] - D[i] for i in range(n))
        lhs = rank(adj, D) - rank(adj, KmD)
        rhs = degree(D) + 1
        print(f"  D={D}: r(D)={rank(adj, D):2d}, r(K-D)={rank(adj, KmD):2d}, "
              f"LHS={lhs:2d}, deg D + 1={rhs:2d}")
        assert lhs == rhs
    print("  OK: genus-0 Riemann-Roch holds for every tested divisor.\n")


def demo_genus_one_obstruction() -> None:
    print("=" * 70)
    print("4. GENUS-ONE OBSTRUCTION (the 2-edge banana)")
    print("=" * 70)
    adj = banana_graph()
    print("  All principal divisors prin(s,t) on B2:")
    seen = set()
    for s in range(-3, 4):
        for t in range(-3, 4):
            seen.add(prin(adj, [s, t]))
    print("   {", ", ".join(map(str, sorted(seen))), "}")
    print("  Note: the first coordinate is always EVEN.")
    D1, D0 = (1, -1), (0, 0)
    equiv = linearly_equivalent(adj, D1, D0, bound=8)
    print(f"  deg(1,-1) = {degree(D1)} = deg(0,0) = {degree(D0)}, "
          f"yet (1,-1) ~ (0,0)? {equiv}")
    assert not equiv
    print("  Reason: equivalence would force 2*(t-s) = 1, impossible over Z.")
    print("  => equal-degree divisors need NOT be equivalent when g = 1.")
    print("  => Jacobian Pic^0(B2) = Z/2Z (= number of spanning trees).\n")


def main() -> None:
    demo_degree_invariance()
    demo_canonical_degree()
    demo_riemann_roch_genus_zero()
    demo_genus_one_obstruction()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
