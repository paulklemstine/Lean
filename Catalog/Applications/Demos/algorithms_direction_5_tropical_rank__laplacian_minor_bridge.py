#!/usr/bin/env python3
"""
Tropical Rank / Laplacian Minor Bridge — Core Algorithms

Implements the computational machinery for exploring the bridge between
Baker–Norine divisor rank and tropical matrix rank of Laplacian minors.

Algorithms:
1. Graph Laplacian computation
2. Rooted subset divisor construction
3. Principal minor extraction
4. Tropical determinant and rank (Kapranov rank)
5. Baker–Norine divisor rank via Dhar's burning algorithm
6. Connected graph enumeration

Keywords: Baker–Norine rank, chip-firing, tropical rank, Laplacian minor,
matrix-tree theorem, principal minor, tropical linear algebra, graph Jacobian,
valuated matroid, effective resistance, discrete potential theory
"""

import itertools
from collections import defaultdict, deque
from fractions import Fraction
from typing import Dict, FrozenSet, List, Optional, Set, Tuple

INF = float('inf')


# ============================================================
# 1. Graph Laplacian — O(|V|² + |E|)
# ============================================================

def graph_laplacian(n: int, edges: List[Tuple[int, int]]) -> List[List[int]]:
    """Compute the combinatorial Laplacian matrix L of a graph.
    
    L[i][i] = deg(i)
    L[i][j] = -1 if {i,j} is an edge
    L[i][j] = 0  otherwise
    
    Time: O(|V|² + |E|)  Space: O(|V|²)
    
    >>> graph_laplacian(3, [(0,1), (1,2)])
    [[1, -1, 0], [-1, 2, -1], [0, -1, 1]]
    """
    L = [[0] * n for _ in range(n)]
    for i, j in edges:
        L[i][j] -= 1
        L[j][i] -= 1
        L[i][i] += 1
        L[j][j] += 1
    return L


# ============================================================
# 2. Rooted subset divisor — O(|V|)
# ============================================================

def rooted_subset_divisor(n: int, q: int, S: Set[int]) -> List[int]:
    """Compute the canonical degree-zero divisor D_S.
    
    D_S(v) = 1    if v ∈ S
    D_S(q) = -|S| (root absorbs all)
    D_S(v) = 0    otherwise
    
    Degree: Σ D_S(v) = |S| - |S| = 0 (certified in Lean)
    
    Time: O(|V|)  Space: O(|V|)
    
    >>> rooted_subset_divisor(4, 0, {1, 2})
    [-2, 1, 1, 0]
    """
    D = [0] * n
    for v in S:
        D[v] = 1
    D[q] = -len(S)
    return D


# ============================================================
# 3. Principal minor extraction — O(|S|²)
# ============================================================

def principal_minor(L: List[List[int]], S: List[int]) -> List[List[int]]:
    """Extract the |S| × |S| principal submatrix L_S.
    
    L_S[a][b] = L[S[a]][S[b]]
    
    Time: O(|S|²)  Space: O(|S|²)
    
    >>> L = graph_laplacian(3, [(0,1), (1,2)])
    >>> principal_minor(L, [1, 2])
    [[2, -1], [-1, 1]]
    """
    return [[L[i][j] for j in S] for i in S]


# ============================================================
# 4. Tropical arithmetic and rank — O(|S|! · |S|²)
# ============================================================

def tropical_det(M: List[List[float]]) -> Tuple[float, int]:
    """Compute tropical determinant and its multiplicity.
    
    trop_det(M) = min_{σ ∈ S_n} Σ_i M[i][σ(i)]
    
    Returns (value, count) where count is the number of
    permutations achieving the minimum.
    
    Time: O(n! · n)  Space: O(n!)
    """
    n = len(M)
    if n == 0:
        return (0.0, 1)
    
    best_val = INF
    best_count = 0
    
    for perm in itertools.permutations(range(n)):
        val = sum(M[i][perm[i]] for i in range(n))
        if val < best_val:
            best_val = val
            best_count = 1
        elif val == best_val:
            best_count += 1
    
    return (best_val, best_count)


def is_tropically_nonsingular(M: List[List[float]]) -> bool:
    """Check if a matrix is tropically nonsingular.
    
    A matrix is tropically nonsingular iff the minimum-weight
    permutation is achieved uniquely.
    
    Time: O(n! · n)
    """
    _, count = tropical_det(M)
    return count == 1


def tropical_rank(M: List[List[float]]) -> int:
    """Compute the Kapranov tropical rank.
    
    The tropical rank is the size of the largest tropically
    nonsingular square submatrix.
    
    Time: O(Σ_k C(n,k)² · k! · k)
    
    >>> M = [[0.0, 1.0], [1.0, 0.0]]
    >>> tropical_rank(M)
    2
    """
    n = len(M)
    if n == 0:
        return 0
    
    for k in range(n, 0, -1):
        for rows in itertools.combinations(range(n), k):
            for cols in itertools.combinations(range(n), k):
                sub = [[M[i][j] for j in cols] for i in rows]
                if is_tropically_nonsingular(sub):
                    return k
    return 0


# ============================================================
# 5. Baker–Norine divisor rank — Dhar's burning algorithm
# ============================================================

def adjacency_list(n: int, edges: List[Tuple[int, int]]) -> Dict[int, Set[int]]:
    """Build adjacency list from edge list."""
    adj: Dict[int, Set[int]] = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    return adj


def dhars_burning(D: List[int], adj: Dict[int, Set[int]], q: int) -> Tuple[bool, List[int]]:
    """Dhar's burning algorithm to test if D is q-reduced.
    
    Starting from q, "burn" vertices: a vertex v burns if the number
    of burned neighbors exceeds D[v]. If all non-q vertices burn,
    D is q-reduced.
    
    Returns (is_reduced, burned_order).
    
    Time: O(|V| · |E|)
    """
    n = len(D)
    burned = {q}
    burned_order = [q]
    changed = True
    
    while changed:
        changed = False
        for v in range(n):
            if v in burned:
                continue
            # Count burned neighbors
            burned_nbrs = sum(1 for u in adj[v] if u in burned)
            if burned_nbrs > D[v]:
                burned.add(v)
                burned_order.append(v)
                changed = True
    
    return len(burned) == n, burned_order


def q_reduce(D: List[int], L: List[List[int]], adj: Dict[int, Set[int]], 
             q: int, max_iter: int = 100000) -> List[int]:
    """Compute the q-reduced divisor equivalent to D.
    
    Repeatedly fires vertices away from q until reaching the
    q-reduced representative.
    
    Time: O(max_iter · |V|²) worst case
    """
    n = len(D)
    D = list(D)
    
    for _ in range(max_iter):
        is_reduced, _ = dhars_burning(D, adj, q)
        if is_reduced:
            return D
        
        # Find a non-burned vertex to fire (superstable approach)
        # Fire all non-q vertices with D[v] ≥ deg(v) towards q
        fired = False
        for v in range(n):
            if v == q:
                continue
            deg_v = len(adj[v])
            if D[v] >= deg_v:
                # Fire v
                for u in adj[v]:
                    D[u] += 1
                D[v] -= deg_v
                fired = True
                break
        
        if not fired:
            # Try firing sets
            for v in range(n):
                if v == q and D[v] < 0:
                    continue
                if v != q and D[v] < 0:
                    # Anti-fire v (fire all others)
                    for u in range(n):
                        if u != v:
                            D[u] -= L[u][v]
                    D[v] -= L[v][v]
                    fired = True
                    break
            if not fired:
                break
    
    return D


def can_make_effective_fast(D: List[int], L: List[List[int]], 
                            adj: Dict[int, Set[int]], n: int) -> bool:
    """Check if D is linearly equivalent to an effective divisor.
    Uses q-reduction: D ~ effective iff the q-reduced form is effective at q.
    
    Time: O(deg(D) · |V|²) amortized
    """
    if all(d >= 0 for d in D):
        return True
    
    if sum(D) < 0:
        return False
    
    # Try each vertex as q
    for q in range(n):
        reduced = q_reduce(D, L, adj, q)
        if all(d >= 0 for d in reduced):
            return True
    
    return False


def divisor_rank(D: List[int], L: List[List[int]], 
                 edges: List[Tuple[int, int]], n: int) -> int:
    """Compute the Baker–Norine rank of divisor D.
    
    r(D) = max{r : ∀ effective E with deg(E) = r, D-E ~ effective}
    Returns -1 if D is not equivalent to any effective divisor.
    
    Uses q-reduction for efficiency.
    
    Time: O(C(|V|+r-1, r) · |V|² · r) for each test degree r
    """
    adj = adjacency_list(n, edges)
    
    if not can_make_effective_fast(D, L, adj, n):
        return -1
    
    deg_D = sum(D)
    r = 0
    
    while r < n:
        r_test = r + 1
        all_pass = True
        
        for E in effective_divisors_of_degree(n, r_test):
            D_minus_E = [D[i] - E[i] for i in range(n)]
            if not can_make_effective_fast(D_minus_E, L, adj, n):
                all_pass = False
                break
        
        if not all_pass:
            return r
        r += 1
    
    return r


def effective_divisors_of_degree(n: int, d: int):
    """Generate all effective divisors of degree d on n vertices."""
    if d < 0:
        return
    if n == 1:
        yield [d]
        return
    for k in range(d + 1):
        for rest in effective_divisors_of_degree(n - 1, d - k):
            yield [k] + rest


# ============================================================
# 6. Integer determinant — O(n³)
# ============================================================

def matrix_det(M: List[List[int]]) -> int:
    """Compute determinant via fraction-free Gaussian elimination.
    
    Time: O(n³)  Space: O(n²)
    """
    n = len(M)
    if n == 0:
        return 1
    A = [[Fraction(M[i][j]) for j in range(n)] for i in range(n)]
    sign = 1
    for col in range(n):
        pivot = None
        for row in range(col, n):
            if A[row][col] != 0:
                pivot = row
                break
        if pivot is None:
            return 0
        if pivot != col:
            A[col], A[pivot] = A[pivot], A[col]
            sign *= -1
        for row in range(col + 1, n):
            if A[row][col] != 0:
                factor = A[row][col] / A[col][col]
                for j in range(n):
                    A[row][j] -= factor * A[col][j]
    result = Fraction(sign)
    for i in range(n):
        result *= A[i][i]
    return int(result)


# ============================================================
# 7. Graph enumeration — connected graphs
# ============================================================

def is_connected(n: int, edges: List[Tuple[int, int]]) -> bool:
    """Check connectivity via BFS. Time: O(|V| + |E|)."""
    if n <= 1:
        return True
    adj = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    visited = set()
    stack = [0]
    while stack:
        v = stack.pop()
        if v not in visited:
            visited.add(v)
            for u in adj[v]:
                if u not in visited:
                    stack.append(u)
    return len(visited) == n


def enumerate_connected_graphs(n: int):
    """Enumerate connected simple graphs on n labeled vertices.
    
    Yields edge lists. For n ≤ 6, this is tractable.
    Does simple deduplication via adjacency matrix canonical form.
    """
    all_possible_edges = list(itertools.combinations(range(n), 2))
    seen = set()
    
    for num_edges in range(n - 1, len(all_possible_edges) + 1):
        for edge_set in itertools.combinations(all_possible_edges, num_edges):
            edges = list(edge_set)
            if is_connected(n, edges):
                adj_mat = tuple(tuple(
                    1 if (min(i,j), max(i,j)) in edge_set else 0
                    for j in range(n)
                ) for i in range(n))
                if adj_mat not in seen:
                    seen.add(adj_mat)
                    yield edges


def is_tree(n: int, edges: List[Tuple[int, int]]) -> bool:
    """A connected graph is a tree iff it has n-1 edges."""
    return len(edges) == n - 1


# ============================================================
# 8. Bridge analysis — full exploration
# ============================================================

def analyze_bridge(n: int, edges: List[Tuple[int, int]], 
                   q: int, S: Set[int]) -> dict:
    """Complete bridge analysis for a single (G, q, S) triple.
    
    Returns dict with all computed invariants.
    """
    L = graph_laplacian(n, edges)
    S_list = sorted(S)
    
    # Canonical divisor
    D = rooted_subset_divisor(n, q, S)
    assert sum(D) == 0, "Divisor not degree zero"
    
    # Principal minor
    L_S = principal_minor(L, S_list)
    
    # Classical determinant
    det_val = matrix_det(L_S) if S_list else 1
    
    # Tropical rank
    L_S_float = [[float(x) for x in row] for row in L_S]
    trop_rank = tropical_rank(L_S_float)
    
    # Divisor rank
    div_rank = divisor_rank(D, L, edges, n)
    
    # Gaps
    naive_gap = div_rank - (trop_rank - 1)  # naive: r ≥ tR - 1
    reverse_gap = (trop_rank - 1) - div_rank  # reverse: r ≤ tR - 1
    
    return {
        'n': n, 'edges': edges, 'q': q, 'S': S_list,
        'D': D, 'L_S': L_S, 'det': det_val,
        'trop_rank': trop_rank, 'div_rank': div_rank,
        'naive_gap': naive_gap,
        'reverse_gap': reverse_gap,
        'naive_holds': naive_gap >= 0,
        'reverse_holds': reverse_gap >= 0,
        'is_tree': is_tree(n, edges),
    }


if __name__ == '__main__':
    # Quick self-test
    print("=== Self-test ===")
    
    # Path P3
    L = graph_laplacian(3, [(0,1), (1,2)])
    print(f"P3 Laplacian: {L}")
    assert L == [[1,-1,0],[-1,2,-1],[0,-1,1]]
    
    D = rooted_subset_divisor(3, 0, {1, 2})
    print(f"D_{{1,2}} on P3 with q=0: {D}")
    assert sum(D) == 0
    
    PM = principal_minor(L, [1, 2])
    print(f"Principal minor L_{{1,2}}: {PM}")
    assert PM == [[2,-1],[-1,1]]
    
    det_val = matrix_det(PM)
    print(f"det(L_{{1,2}}) = {det_val}")
    assert det_val == 1
    
    print("\nAll self-tests passed!")
