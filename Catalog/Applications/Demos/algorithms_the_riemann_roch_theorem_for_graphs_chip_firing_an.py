#!/usr/bin/env python3
"""
Chip-Firing Algorithms on Graphs
==================================

Type-hinted implementations of core chip-firing algorithms:
- Laplacian computation
- Chip-firing simulation
- Canonical divisor and complement
- Dhar's burning algorithm for q-reduced divisors
- Divisor rank computation (brute-force for small graphs)
"""

from typing import List, Set, Dict, Tuple, Optional
import itertools


class Graph:
    """Simple undirected graph represented by adjacency sets."""

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj: Dict[int, Set[int]] = {v: set() for v in range(n)}
        for u, v in edges:
            self.adj[u].add(v)
            self.adj[v].add(u)

    @classmethod
    def complete(cls, n: int) -> 'Graph':
        """Create the complete graph K_n."""
        edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
        return cls(n, edges)

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def num_edges(self) -> int:
        return sum(self.degree(v) for v in range(self.n)) // 2

    def genus(self) -> int:
        """Genus g = |E| - |V| + 1."""
        return self.num_edges() - self.n + 1


Divisor = List[int]


def canonical_divisor(G: Graph) -> Divisor:
    """K_G(v) = deg(v) - 2."""
    return [G.degree(v) - 2 for v in range(G.n)]


def canonical_complement(G: Graph, D: Divisor) -> Divisor:
    """K_G - D."""
    K = canonical_divisor(G)
    return [K[v] - D[v] for v in range(G.n)]


def deg(D: Divisor) -> int:
    """Total degree of divisor."""
    return sum(D)


def is_effective(D: Divisor) -> bool:
    """Check if D(v) >= 0 for all v."""
    return all(d >= 0 for d in D)


def chip_fire(G: Graph, D: Divisor, v: int) -> Divisor:
    """Fire vertex v: sends 1 chip to each neighbor."""
    result = D.copy()
    result[v] -= G.degree(v)
    for w in G.adj[v]:
        result[w] += 1
    return result


def subset_fire(G: Graph, D: Divisor, S: Set[int]) -> Divisor:
    """Fire all vertices in subset S simultaneously."""
    result = D.copy()
    for v in S:
        for w in G.adj[v]:
            if w not in S:
                result[v] -= 1
                result[w] += 1
    return result


def laplacian_apply(G: Graph, f: List[int]) -> Divisor:
    """Compute the Laplacian Δf."""
    result: Divisor = [0] * G.n
    for v in range(G.n):
        for w in G.adj[v]:
            result[v] += f[v] - f[w]
    return result


def dhars_burning(G: Graph, D: Divisor, q: int) -> Tuple[bool, Set[int]]:
    """
    Dhar's burning algorithm.

    Returns (is_q_reduced, unburned_set).
    If is_q_reduced is True, D is q-reduced.
    If False, unburned_set is a nonempty subset that should be fired.
    """
    burned: Set[int] = {q}
    changed = True
    while changed:
        changed = False
        for v in range(G.n):
            if v in burned:
                continue
            # Count edges from v to burned vertices
            edges_to_burned = len(G.adj[v] & burned)
            if D[v] < edges_to_burned:
                burned.add(v)
                changed = True

    unburned = set(range(G.n)) - burned
    return (len(unburned) == 0, unburned)


def q_reduce(G: Graph, D: Divisor, q: int, max_iter: int = 1000) -> Divisor:
    """
    Compute the q-reduced representative of D.

    Repeatedly fires subsets identified by Dhar's algorithm
    until the divisor is q-reduced.
    """
    result = D.copy()
    for _ in range(max_iter):
        is_reduced, S = dhars_burning(G, result, q)
        if is_reduced:
            return result
        result = subset_fire(G, result, S)
    raise RuntimeError("q-reduction did not converge")


def divisor_rank_bruteforce(G: Graph, D: Divisor,
                            max_rank: int = 20) -> int:
    """
    Compute r(D) by brute force.

    r(D) = -1 if D is not equivalent to any effective divisor.
    Otherwise, r(D) is the max k such that for all effective E
    with deg(E) = k, D - E is equivalent to an effective divisor.

    Uses q-reduction to check effective equivalence.
    """
    q = 0  # distinguished vertex

    # First check if D is equivalent to any effective divisor
    D_red = q_reduce(G, D, q)
    if not all(D_red[v] >= 0 for v in range(G.n) if v != q):
        return -1

    for k in range(1, min(max_rank + 1, deg(D) + 2)):
        # Check all effective divisors of degree k
        # (up to a reasonable limit)
        all_pass = True
        for combo in _effective_divisors_of_degree(G.n, k, max_count=500):
            E = list(combo)
            DmE = [D[v] - E[v] for v in range(G.n)]
            DmE_red = q_reduce(G, DmE, q)
            if not all(DmE_red[v] >= 0 for v in range(G.n) if v != q):
                all_pass = False
                break
        if not all_pass:
            return k - 1

    return max_rank


def _effective_divisors_of_degree(n: int, k: int,
                                   max_count: int = 500) -> List[Tuple[int, ...]]:
    """Generate effective divisors of degree k on n vertices."""
    # For small k and n, enumerate all compositions
    results = []
    for combo in itertools.combinations_with_replacement(range(n), k):
        D = [0] * n
        for v in combo:
            D[v] += 1
        results.append(tuple(D))
        if len(results) >= max_count:
            break
    return results


def verify_complement_duality(n: int) -> bool:
    """Verify complement firing duality on K_n."""
    G = Graph.complete(n)
    for v in range(n):
        f = [0 if i == v else 1 for i in range(n)]
        result = laplacian_apply(G, f)
        expected = [-(n - 1) if i == v else 1 for i in range(n)]
        if result != expected:
            return False
    return True


def verify_canonical_involution(n: int) -> bool:
    """Verify K - (K - D) = D for random divisors on K_n."""
    G = Graph.complete(n)
    import random
    for _ in range(100):
        D = [random.randint(-10, 10) for _ in range(n)]
        KmD = canonical_complement(G, D)
        KmKmD = canonical_complement(G, KmD)
        if D != KmKmD:
            return False
    return True


if __name__ == "__main__":
    print("=== Algorithm Tests ===")

    # Test 1: Complete graph properties
    for n in [3, 4, 5, 6]:
        G = Graph.complete(n)
        print(f"\nK_{n}: |V|={G.n}, |E|={G.num_edges()}, g={G.genus()}")
        K = canonical_divisor(G)
        print(f"  K = {K}, deg(K) = {deg(K)}, 2g-2 = {2*G.genus()-2}")

    # Test 2: Complement duality
    for n in [3, 4, 5, 6]:
        ok = verify_complement_duality(n)
        print(f"  Complement duality K_{n}: {'✓' if ok else '✗'}")

    # Test 3: Canonical involution
    for n in [3, 4, 5]:
        ok = verify_canonical_involution(n)
        print(f"  Canonical involution K_{n}: {'✓' if ok else '✗'}")

    # Test 4: Rank computation
    for n in [3, 4, 5]:
        G = Graph.complete(n)
        K = canonical_divisor(G)
        r_K = divisor_rank_bruteforce(G, K)
        expected = G.genus() - 1
        print(f"  K_{n}: r(K) = {r_K}, g-1 = {expected}  "
              f"{'✓' if r_K == expected else '✗'}")

    # Test 5: Zero divisor rank
    for n in [3, 4, 5]:
        G = Graph.complete(n)
        D_zero = [0] * n
        r_zero = divisor_rank_bruteforce(G, D_zero)
        print(f"  K_{n}: r(0) = {r_zero}  {'✓' if r_zero == 0 else '✗'}")
