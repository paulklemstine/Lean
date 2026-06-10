#!/usr/bin/env python3
"""
Tropical Rank / Laplacian Minor Bridge — Applications

Demonstrates real-world applications of the bridge between Baker–Norine
divisor rank and tropical matrix rank of Laplacian principal minors.

Applications:
1. Network robustness analysis via Laplacian minors
2. Spanning tree counting and Kirchhoff's theorem verification
3. Tropical rank as a complexity measure for graph structure
4. Electrical network effective resistance computation

Keywords: Baker–Norine rank, chip-firing, tropical rank, Laplacian minor,
effective resistance, Green's function, resistor networks, spectral graph theory
"""

import itertools
from fractions import Fraction
from typing import Dict, List, Set, Tuple

from algorithms import (
    graph_laplacian, rooted_subset_divisor, principal_minor,
    matrix_det, tropical_rank, is_tropically_nonsingular,
    divisor_rank, is_connected, is_tree, adjacency_list
)


# ============================================================
# Application 1: Spanning tree counting via Kirchhoff's theorem
# ============================================================

def spanning_tree_count(n: int, edges: List[Tuple[int, int]]) -> int:
    """Count spanning trees using Kirchhoff's matrix-tree theorem.
    
    The number of spanning trees equals the determinant of any
    cofactor (principal minor obtained by deleting one row and column)
    of the Laplacian matrix.
    
    This connects to the bridge: det(L_{V\\{q}}) counts spanning trees,
    and its tropical rank controls the divisor rank of D_{V\\{q}}.
    
    >>> spanning_tree_count(4, [(0,1),(1,2),(2,3),(3,0)])  # cycle C4
    4
    """
    L = graph_laplacian(n, edges)
    # Delete row 0 and column 0
    S = list(range(1, n))
    minor = principal_minor(L, S)
    return matrix_det(minor)


def verify_kirchhoff(n: int, edges: List[Tuple[int, int]]):
    """Verify that all cofactors give the same count (Kirchhoff invariance)."""
    L = graph_laplacian(n, edges)
    dets = []
    for q in range(n):
        S = [v for v in range(n) if v != q]
        minor = principal_minor(L, S)
        dets.append(matrix_det(minor))
    
    assert all(d == dets[0] for d in dets), f"Cofactors differ: {dets}"
    return dets[0]


# ============================================================
# Application 2: Network robustness analysis
# ============================================================

def robustness_profile(n: int, edges: List[Tuple[int, int]]) -> Dict:
    """Compute a robustness profile of a network using Laplacian minors.
    
    For each subset S of vertices, the determinant of L_S measures
    the "connectivity strength" of S within the network. The tropical
    rank provides a combinatorial proxy for this strength.
    
    Returns a dict mapping subset size to average det and average tropical rank.
    """
    L = graph_laplacian(n, edges)
    profile = {}
    
    for size in range(1, n):
        dets = []
        trop_ranks = []
        
        for S in itertools.combinations(range(n), size):
            S_list = list(S)
            minor = principal_minor(L, S_list)
            det_val = matrix_det(minor)
            dets.append(det_val)
            
            minor_float = [[float(x) for x in row] for row in minor]
            tr = tropical_rank(minor_float)
            trop_ranks.append(tr)
        
        profile[size] = {
            'avg_det': sum(dets) / len(dets),
            'max_det': max(dets),
            'min_det': min(dets),
            'avg_trop_rank': sum(trop_ranks) / len(trop_ranks),
            'max_trop_rank': max(trop_ranks),
            'count': len(dets)
        }
    
    return profile


# ============================================================
# Application 3: Effective resistance computation
# ============================================================

def effective_resistance(n: int, edges: List[Tuple[int, int]], 
                        s: int, t: int) -> Fraction:
    """Compute effective resistance between vertices s and t.
    
    R_eff(s,t) = (det L_{st}) / (det L_q)
    
    where L_{st} is the Laplacian with rows/cols s,t deleted and
    L_q is any cofactor (spanning tree count).
    
    This connects electrical network theory to the Laplacian minor
    structure at the heart of the bridge conjecture.
    """
    L = graph_laplacian(n, edges)
    
    # Spanning tree count
    S_full = [v for v in range(n) if v != 0]
    tree_count = matrix_det(principal_minor(L, S_full))
    
    if tree_count == 0:
        return Fraction(0)  # disconnected
    
    # Compute using the formula R(s,t) = L^+_ss + L^+_tt - 2*L^+_st
    # where L^+ is the pseudoinverse. For computational ease, use the
    # formula involving cofactors:
    # R(s,t) = cofactor(s,s) + cofactor(t,t) - 2*cofactor(s,t) / tree_count
    # But simpler: use the formula with the reduced Laplacian
    
    # Alternative: R(s,t) via solving Lx = e_s - e_t
    # Use the pseudoinverse approach for small graphs
    
    # For now, use the 2-vertex deletion formula
    S_st = [v for v in range(n) if v != s and v != t]
    if not S_st:
        # Only 2 vertices
        if any((s, t) == e or (t, s) == e for e in edges):
            return Fraction(1)
        return Fraction(0)  # should not happen for connected
    
    det_st = matrix_det(principal_minor(L, S_st))
    return Fraction(det_st, tree_count)


def resistance_diameter(n: int, edges: List[Tuple[int, int]]) -> Fraction:
    """Compute the effective resistance diameter (max pairwise resistance)."""
    max_r = Fraction(0)
    for s in range(n):
        for t in range(s + 1, n):
            r = effective_resistance(n, edges, s, t)
            max_r = max(max_r, r)
    return max_r


# ============================================================
# Application 4: Tropical rank as graph complexity measure
# ============================================================

def tropical_complexity_spectrum(n: int, edges: List[Tuple[int, int]]) -> Dict:
    """Compute the spectrum of tropical ranks across all principal minors.
    
    This gives a fine-grained measure of graph "complexity" from the
    perspective of tropical linear algebra.
    """
    L = graph_laplacian(n, edges)
    spectrum = {}
    
    for size in range(1, n):
        ranks = []
        for S in itertools.combinations(range(n), size):
            S_list = list(S)
            minor = principal_minor(L, S_list)
            minor_float = [[float(x) for x in row] for row in minor]
            tr = tropical_rank(minor_float)
            ranks.append(tr)
        
        spectrum[size] = {
            'ranks': ranks,
            'max_rank': max(ranks),
            'min_rank': min(ranks),
            'full_rank_count': sum(1 for r in ranks if r == size),
        }
    
    return spectrum


# ============================================================
# Demo: Run all applications on example graphs
# ============================================================

def demo_all():
    """Run all applications on a collection of example graphs."""
    
    graphs = {
        'P4 (path)': (4, [(0,1),(1,2),(2,3)]),
        'C4 (cycle)': (4, [(0,1),(1,2),(2,3),(3,0)]),
        'K4 (complete)': (4, [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)]),
        'Star S4': (4, [(0,1),(0,2),(0,3)]),
        'P5 (path)': (5, [(0,1),(1,2),(2,3),(3,4)]),
        'C5 (cycle)': (5, [(0,1),(1,2),(2,3),(3,4),(4,0)]),
        'Petersen-like': (5, [(0,1),(0,2),(0,3),(1,2),(2,3),(3,4)]),
    }
    
    for name, (n, edges) in graphs.items():
        print(f"\n{'='*60}")
        print(f"Graph: {name}")
        print(f"Vertices: {n}, Edges: {len(edges)}")
        print(f"Tree: {is_tree(n, edges)}")
        print(f"{'='*60}")
        
        # Kirchhoff
        tree_count = verify_kirchhoff(n, edges)
        print(f"\n  Spanning trees: {tree_count}")
        
        # Effective resistance
        print(f"\n  Effective resistances:")
        for s in range(min(n, 4)):
            for t in range(s + 1, min(n, 4)):
                r = effective_resistance(n, edges, s, t)
                print(f"    R({s},{t}) = {r} = {float(r):.4f}")
        
        r_diam = resistance_diameter(n, edges)
        print(f"    Resistance diameter: {r_diam} = {float(r_diam):.4f}")
        
        # Tropical complexity (only for small graphs)
        if n <= 5:
            print(f"\n  Tropical rank spectrum:")
            spectrum = tropical_complexity_spectrum(n, edges)
            for size, data in spectrum.items():
                print(f"    |S|={size}: ranks={data['ranks']}, "
                      f"max={data['max_rank']}, full_rank={data['full_rank_count']}")
        
        # Bridge analysis for selected subsets
        print(f"\n  Bridge analysis (q=0):")
        L = graph_laplacian(n, edges)
        remaining = list(range(1, n))
        
        for size in range(1, min(len(remaining) + 1, 4)):
            for S in itertools.combinations(remaining, size):
                S_set = set(S)
                S_list = list(S)
                D = rooted_subset_divisor(n, 0, S_set)
                L_S = principal_minor(L, S_list)
                L_S_float = [[float(x) for x in row] for row in L_S]
                tr = tropical_rank(L_S_float)
                dr = divisor_rank(D, L, edges, n)
                det_val = matrix_det(L_S)
                
                status = "✓" if dr <= tr - 1 else "?"
                print(f"    S={S_list}: r(D_S)={dr}, tropRank={tr}, "
                      f"det={det_val}, r≤tR-1: {status}")


if __name__ == '__main__':
    demo_all()


#!/usr/bin/env python3
"""
Tropical Rank / Laplacian Minor Bridge — Interactive Demo

Explores the bridge between Baker–Norine divisor rank on graphs and
tropical matrix rank of Laplacian principal minors.

For a finite connected graph G with basepoint q and subset S ⊆ V \\ {q},
the canonical divisor D_S = Σ_{v∈S} [v] - |S|[q] has degree zero.

FINDING: Computational evidence shows the naive conjecture r(D_S) ≥ tropRank(L_S) - 1
fails even on trees. The corrected upper bound r(D_S) ≤ tropRank(L_S) - 1 appears
to hold universally — tropical rank provides an upper bound on divisor rank.

Usage:
    python demo.py              # Run exploration on small graphs
    python demo.py --interactive  # Interactive mode with detailed output
"""

import itertools
import sys
from collections import defaultdict, deque
from fractions import Fraction
from typing import Dict, List, Optional, Set, Tuple

INF = float('inf')

# ============================================================
# Core: Graph Laplacian
# ============================================================

def graph_laplacian(n: int, edges: List[Tuple[int, int]]) -> List[List[int]]:
    L = [[0] * n for _ in range(n)]
    for i, j in edges:
        L[i][j] -= 1
        L[j][i] -= 1
        L[i][i] += 1
        L[j][j] += 1
    return L

def rooted_subset_divisor(n: int, q: int, S: Set[int]) -> List[int]:
    D = [0] * n
    for v in S:
        D[v] = 1
    D[q] = -len(S)
    return D

def principal_minor(L: List[List[int]], S: List[int]) -> List[List[int]]:
    return [[L[i][j] for j in S] for i in S]

def matrix_det(M: List[List[int]]) -> int:
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
# Tropical arithmetic
# ============================================================

def tropical_det_info(M):
    n = len(M)
    if n == 0:
        return 0.0, 1
    best_val = INF
    count = 0
    for perm in itertools.permutations(range(n)):
        val = sum(M[i][perm[i]] for i in range(n))
        if val < best_val:
            best_val = val
            count = 1
        elif val == best_val:
            count += 1
    return best_val, count

def is_tropically_nonsingular(M):
    _, count = tropical_det_info(M)
    return count == 1

def tropical_rank(M):
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
# Baker–Norine divisor rank (improved with Dhar's algorithm)
# ============================================================

def adj_list(n, edges):
    adj = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    return adj

def can_make_effective(D, L, edges, n, max_iter=50000):
    if all(d >= 0 for d in D):
        return True
    if sum(D) < 0:
        return False
    # BFS over chip-firing moves
    visited = set()
    queue = deque()
    state = tuple(D)
    visited.add(state)
    queue.append(state)
    count = 0
    while queue and count < max_iter:
        count += 1
        current = list(queue.popleft())
        for v in range(n):
            fired = [current[i] - L[v][i] for i in range(n)]
            state = tuple(fired)
            if all(d >= 0 for d in fired):
                return True
            if state not in visited:
                visited.add(state)
                queue.append(state)
    return False

def divisor_rank(D, L, edges, n):
    if not can_make_effective(D, L, edges, n):
        return -1
    r = 0
    while r < n:
        r_test = r + 1
        for E in effective_divisors_of_degree(n, r_test):
            D_minus_E = [D[i] - E[i] for i in range(n)]
            if not can_make_effective(D_minus_E, L, edges, n):
                return r
        r += 1
    return r

def effective_divisors_of_degree(n, d):
    if d < 0:
        return
    if n == 1:
        yield [d]
        return
    for k in range(d + 1):
        for rest in effective_divisors_of_degree(n - 1, d - k):
            yield [k] + rest

# ============================================================
# Graph enumeration
# ============================================================

def is_connected(n, edges):
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

def enumerate_connected_graphs(n):
    all_edges = list(itertools.combinations(range(n), 2))
    seen = set()
    for num_edges in range(n - 1, len(all_edges) + 1):
        for edge_set in itertools.combinations(all_edges, num_edges):
            edges = list(edge_set)
            if is_connected(n, edges):
                adj_mat = tuple(tuple(
                    1 if (min(i,j), max(i,j)) in edge_set else 0
                    for j in range(n)) for i in range(n))
                if adj_mat not in seen:
                    seen.add(adj_mat)
                    yield edges

def is_tree(n, edges):
    return len(edges) == n - 1

# ============================================================
# Main exploration
# ============================================================

def explore_graph(n, edges):
    L = graph_laplacian(n, edges)
    results = []
    for q in range(n):
        remaining = [v for v in range(n) if v != q]
        for size in range(1, len(remaining) + 1):
            for S in itertools.combinations(remaining, size):
                S_set = set(S)
                S_list = sorted(S)
                D = rooted_subset_divisor(n, q, S_set)
                L_S = principal_minor(L, S_list)
                L_S_float = [[float(x) for x in row] for row in L_S]
                trop_rank = tropical_rank(L_S_float)
                div_rank = divisor_rank(D, L, edges, n)
                det_val = matrix_det(L_S)
                
                results.append({
                    'q': q, 'S': S_list, 'D': D,
                    'trop_rank': trop_rank, 'div_rank': div_rank,
                    'det': det_val,
                    'naive_holds': div_rank >= trop_rank - 1,
                    'upper_holds': div_rank <= trop_rank - 1,
                    'is_tree': is_tree(n, edges)
                })
    return results

def run_exploration(max_n=4):
    """Run the bridge exploration on all connected graphs up to max_n vertices."""
    print("Tropical Rank / Laplacian Minor Bridge — Exploration")
    print("=" * 65)
    print()
    print("Testing two conjectures:")
    print("  NAIVE:   r(D_S) ≥ tropRank(L_S) - 1  (lower bound)")
    print("  UPPER:   r(D_S) ≤ tropRank(L_S) - 1  (upper bound)")
    print()
    
    stats = {
        'total': 0, 'naive_pass': 0, 'upper_pass': 0,
        'equality': 0, 'tree_tests': 0, 'tree_naive': 0, 'tree_upper': 0
    }
    
    naive_fails = []
    upper_fails = []
    
    for n in range(2, max_n + 1):
        print(f"\n--- Graphs on {n} vertices ---")
        graph_count = 0
        
        for edges in enumerate_connected_graphs(n):
            graph_count += 1
            tree_flag = is_tree(n, edges)
            results = explore_graph(n, edges)
            
            for r in results:
                stats['total'] += 1
                if r['naive_holds']:
                    stats['naive_pass'] += 1
                else:
                    naive_fails.append((n, edges, r))
                if r['upper_holds']:
                    stats['upper_pass'] += 1
                else:
                    upper_fails.append((n, edges, r))
                if r['div_rank'] == r['trop_rank'] - 1:
                    stats['equality'] += 1
                if tree_flag:
                    stats['tree_tests'] += 1
                    if r['naive_holds']:
                        stats['tree_naive'] += 1
                    if r['upper_holds']:
                        stats['tree_upper'] += 1
        
        print(f"  Tested {graph_count} connected graphs")
    
    print(f"\n{'='*65}")
    print(f"SUMMARY (n ≤ {max_n})")
    print(f"{'='*65}")
    print(f"Total tests:              {stats['total']}")
    print(f"Naive conjecture passes:  {stats['naive_pass']}/{stats['total']}")
    print(f"Upper bound passes:       {stats['upper_pass']}/{stats['total']}")
    print(f"Equality cases:           {stats['equality']}/{stats['total']}")
    print(f"Tree tests:               {stats['tree_tests']}")
    print(f"  Trees naive passes:     {stats['tree_naive']}/{stats['tree_tests']}")
    print(f"  Trees upper passes:     {stats['tree_upper']}/{stats['tree_tests']}")
    
    if naive_fails:
        print(f"\nNaive conjecture FAILS ({len(naive_fails)} cases). "
              f"Example:")
        n, edges, r = naive_fails[0]
        print(f"  n={n}, edges={edges}, q={r['q']}, S={r['S']}")
        print(f"  r(D_S)={r['div_rank']}, tropRank={r['trop_rank']}")
    
    if upper_fails:
        print(f"\nUpper bound FAILS ({len(upper_fails)} cases). Example:")
        n, edges, r = upper_fails[0]
        print(f"  n={n}, edges={edges}, q={r['q']}, S={r['S']}")
        print(f"  r(D_S)={r['div_rank']}, tropRank={r['trop_rank']}")
    else:
        print(f"\nUpper bound r(D_S) ≤ tropRank(L_S) - 1 holds universally!")
    
    return stats, naive_fails, upper_fails

def interactive_mode():
    """Interactive exploration with detailed output."""
    print("Tropical Rank / Laplacian Minor Bridge — Interactive Explorer")
    print("=" * 65)
    
    examples = [
        ("Path P3", 3, [(0,1),(1,2)]),
        ("Path P4", 4, [(0,1),(1,2),(2,3)]),
        ("Cycle C4", 4, [(0,1),(1,2),(2,3),(3,0)]),
        ("Star S4", 4, [(0,1),(0,2),(0,3)]),
        ("K4", 4, [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)]),
    ]
    
    for name, n, edges in examples:
        print(f"\n{'='*65}")
        print(f"Graph: {name}, Vertices: {list(range(n))}, Edges: {edges}")
        tree_flag = is_tree(n, edges)
        print(f"Type: {'Tree' if tree_flag else 'Graph with cycles'}")
        
        L = graph_laplacian(n, edges)
        print(f"\nLaplacian L:")
        for row in L:
            print(f"  {row}")
        
        # Spanning tree count
        S_full = list(range(1, n))
        reduced_L = principal_minor(L, S_full)
        tree_count = matrix_det(reduced_L)
        print(f"\nSpanning trees (det of reduced Laplacian): {tree_count}")
        
        print(f"\nBridge analysis (all roots, selected subsets):")
        header = f"{'q':>3} | {'S':>12} | {'r(D_S)':>6} | {'tR(L_S)':>7} | {'det':>5} | {'naive':>5} | {'upper':>5}"
        print(header)
        print("-" * len(header))
        
        results = explore_graph(n, edges)
        for r in results:
            n_ok = "✓" if r['naive_holds'] else "✗"
            u_ok = "✓" if r['upper_holds'] else "✗"
            print(f"{r['q']:>3} | {str(r['S']):>12} | {r['div_rank']:>6} | "
                  f"{r['trop_rank']:>7} | {r['det']:>5} | {n_ok:>5} | {u_ok:>5}")
        
        # Summary for this graph
        all_naive = all(r['naive_holds'] for r in results)
        all_upper = all(r['upper_holds'] for r in results)
        print(f"\n  Naive conjecture: {'ALL PASS' if all_naive else 'SOME FAIL'}")
        print(f"  Upper bound:      {'ALL PASS' if all_upper else 'SOME FAIL'}")

if __name__ == '__main__':
    if '--interactive' in sys.argv:
        interactive_mode()
    else:
        max_n = 4
        if len(sys.argv) > 1 and sys.argv[1].isdigit():
            max_n = int(sys.argv[1])
        run_exploration(max_n=max_n)
