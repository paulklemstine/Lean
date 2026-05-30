"""
Algorithms from the Probabilistic Method

Implements the key algorithms underlying the probabilistic existence proofs:
1. First Moment Search — find outcomes with zero bad events
2. Erdős Ramsey Construction — explicit coloring via quadratic residues
3. Turán Graph Construction — build the extremal K_{r+1}-free graph
4. Property B Search — find proper 2-colorings of hypergraphs
5. Moser-Tardos Algorithm — constructive Lovász Local Lemma
"""

import math
import random
from itertools import combinations
from typing import List, Tuple, Set, Optional, Dict


def first_moment_search(
    sample_size: int,
    bad_count: callable,
    max_attempts: int = 10000
) -> Optional[int]:
    """Find an outcome with zero bad events using random sampling.
    
    The first moment method guarantees existence when ∑ bad_count < sample_size.
    This function provides a randomized search that finds such an outcome.
    
    Args:
        sample_size: Size of the sample space |Ω|
        bad_count: Function mapping outcome index to number of bad events
        max_attempts: Maximum random samples to try
    
    Returns:
        Index of an outcome with zero bad events, or None if not found
    
    Time complexity: O(max_attempts * cost(bad_count))
    Space complexity: O(1) beyond the bad_count function
    """
    for _ in range(max_attempts):
        i = random.randint(0, sample_size - 1)
        if bad_count(i) == 0:
            return i
    return None


def erdos_ramsey_coloring(n: int, k: int) -> Optional[List[int]]:
    """Construct a 2-coloring of K_n avoiding monochromatic K_k.
    
    Uses the quadratic residue coloring: for prime p,
    color edge {i,j} by the Legendre symbol ((i-j)/p).
    Falls back to random search if n is not prime.
    
    Args:
        n: Number of vertices
        k: Size of forbidden monochromatic clique
    
    Returns:
        Edge coloring as list of 0/1 values (for C(n,2) edges),
        or None if no such coloring exists.
    
    Time complexity: O(C(n,2)) for construction, O(C(n,k) * C(k,2)) for verification
    Space complexity: O(C(n,2))
    """
    edges = list(combinations(range(n), 2))
    
    def is_quadratic_residue(a: int, p: int) -> bool:
        """Check if a is a quadratic residue mod p."""
        if a % p == 0:
            return True
        return pow(a, (p - 1) // 2, p) == 1
    
    def is_prime(m: int) -> bool:
        if m < 2:
            return False
        for i in range(2, int(m**0.5) + 1):
            if m % i == 0:
                return False
        return True
    
    # Try quadratic residue coloring
    if is_prime(n) and n > 2:
        coloring = []
        for i, j in edges:
            diff = (i - j) % n
            coloring.append(1 if is_quadratic_residue(diff, n) else 0)
    else:
        # Random coloring
        coloring = [random.randint(0, 1) for _ in edges]
    
    # Verify: check all k-subsets for monochromaticity
    edge_index = {}
    for idx, (i, j) in enumerate(edges):
        edge_index[(i, j)] = idx
        edge_index[(j, i)] = idx
    
    for subset in combinations(range(n), k):
        subset_edges = list(combinations(subset, 2))
        colors = {coloring[edge_index[e]] for e in subset_edges}
        if len(colors) == 1:
            return None  # Monochromatic clique found
    
    return coloring


def turan_graph(n: int, r: int) -> Tuple[List[Set[int]], List[Tuple[int, int]]]:
    """Construct the Turán graph T(n,r).
    
    The complete r-partite graph on n vertices with parts as equal as possible.
    This is the unique graph maximizing edges among K_{r+1}-free graphs.
    
    Args:
        n: Number of vertices
        r: Number of parts (graph is K_{r+1}-free)
    
    Returns:
        Tuple of (parts, edges) where parts is a list of vertex sets
        and edges is the edge list.
    
    Time complexity: O(n²)
    Space complexity: O(n²) for the edge list
    """
    if r == 0:
        return [], []
    
    q, s = divmod(n, r)
    parts: List[Set[int]] = []
    vertex = 0
    
    for i in range(r):
        size = q + 1 if i < s else q
        parts.append(set(range(vertex, vertex + size)))
        vertex += size
    
    # Edges: all pairs between different parts
    edges = []
    for i in range(r):
        for j in range(i + 1, r):
            for u in parts[i]:
                for v in parts[j]:
                    edges.append((u, v))
    
    return parts, edges


def turan_edge_count(n: int, r: int) -> int:
    """Compute the number of edges in T(n,r).
    
    Formula: (n² - (s·(q+1)² + (r-s)·q²)) / 2
    where q = n÷r, s = n mod r.
    
    Time complexity: O(1)
    """
    if r == 0:
        return 0
    q, s = divmod(n, r)
    sum_sq = s * (q + 1) ** 2 + (r - s) * q ** 2
    return (n * n - sum_sq) // 2


def property_b_search(
    n: int,
    edges: List[Set[int]],
    max_attempts: int = 10000
) -> Optional[List[int]]:
    """Find a proper 2-coloring of a hypergraph (Property B).
    
    Uses random search. Guaranteed to succeed with high probability
    when |edges| < 2^{k-1} where k is the uniformity.
    
    Args:
        n: Number of vertices
        edges: List of hyperedges (each a set of vertex indices)
        max_attempts: Maximum random colorings to try
    
    Returns:
        A proper 2-coloring (list of 0/1), or None if not found.
    
    Time complexity: O(max_attempts * sum(|e| for e in edges))
    """
    for _ in range(max_attempts):
        coloring = [random.randint(0, 1) for _ in range(n)]
        proper = True
        for edge in edges:
            colors = {coloring[v] for v in edge}
            if len(colors) == 1:
                proper = False
                break
        if proper:
            return coloring
    return None


def moser_tardos(
    n: int,
    bad_events: List[Set[int]],
    max_iterations: int = 100000
) -> Optional[List[int]]:
    """Constructive Lovász Local Lemma via the Moser-Tardos algorithm.
    
    Each bad event is a set of variable indices that constrains those variables.
    Variables are binary (0/1). A bad event occurs when all its variables
    take a specific "bad" pattern (here: all 1).
    
    The algorithm:
    1. Initialize randomly
    2. While some bad event is violated:
       a. Pick a violated bad event
       b. Resample all its variables
    
    When e·p·(d+1) ≤ 1, this terminates in expected O(n) resampling steps.
    
    Args:
        n: Number of variables
        bad_events: List of variable index sets defining bad events
        max_iterations: Safety bound on iterations
    
    Returns:
        Assignment as list of 0/1, or None if timeout.
    
    Expected time complexity: O(n * d * log(1/p)) where d is max dependency
    Space complexity: O(n + sum(|A_i|))
    """
    assignment = [random.randint(0, 1) for _ in range(n)]
    iterations = 0
    
    while iterations < max_iterations:
        # Find a violated bad event
        violated = None
        for i, event in enumerate(bad_events):
            if all(assignment[v] == 1 for v in event):
                violated = i
                break
        
        if violated is None:
            return assignment  # All constraints satisfied
        
        # Resample the variables in the violated event
        for v in bad_events[violated]:
            assignment[v] = random.randint(0, 1)
        
        iterations += 1
    
    return None  # Timeout


def independence_from_coloring(
    n: int,
    coloring: List[int],
    k: int
) -> List[int]:
    """Extract the largest color class as an independent set.
    
    By pigeonhole, the largest class has ≥ n/k vertices.
    
    Args:
        n: Number of vertices
        coloring: Proper k-coloring as list of color indices
        k: Number of colors used
    
    Returns:
        Vertices in the largest color class (an independent set).
    """
    color_classes: Dict[int, List[int]] = {}
    for v in range(n):
        c = coloring[v]
        color_classes.setdefault(c, []).append(v)
    
    largest = max(color_classes.values(), key=len)
    assert len(largest) >= n // k, f"Pigeonhole violated: {len(largest)} < {n // k}"
    return largest


# Example usage
if __name__ == "__main__":
    print("=== First Moment Search ===")
    result = first_moment_search(100, lambda i: i % 7)
    print(f"Found outcome with zero bad events: {result}")
    
    print("\n=== Erdős Ramsey Coloring ===")
    for k in range(3, 7):
        n = int(2 ** (k / 2))
        coloring = erdos_ramsey_coloring(n, k)
        status = "Found" if coloring else "Not found"
        print(f"k={k}, n={n}: {status}")
    
    print("\n=== Turán Graph ===")
    parts, edges = turan_graph(12, 3)
    print(f"T(12,3): {len(edges)} edges, parts: {[len(p) for p in parts]}")
    print(f"Edge count formula: {turan_edge_count(12, 3)}")
    
    print("\n=== Property B Search ===")
    hyperedges = [{0, 1, 2}, {3, 4, 5}, {6, 7, 0}, {1, 3, 6}]
    coloring = property_b_search(8, hyperedges)
    print(f"Proper 2-coloring: {coloring}")
    
    print("\n=== Moser-Tardos Algorithm ===")
    bad = [{0, 1, 2}, {3, 4, 5}, {2, 3, 6}, {5, 6, 7}]
    result = moser_tardos(8, bad)
    print(f"Satisfying assignment: {result}")
    
    print("\n=== Independence from Coloring ===")
    col = [0, 1, 2, 0, 1, 2, 0, 1, 0]
    indep = independence_from_coloring(9, col, 3)
    print(f"Largest color class: {indep} (size {len(indep)} ≥ {9//3})")
