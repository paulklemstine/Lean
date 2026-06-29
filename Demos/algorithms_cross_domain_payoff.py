#!/usr/bin/env python3
"""
Algorithms for Tropical Spectral Theory and Throughput Certification

Implements the core algorithms from the tropical Perron–Frobenius framework:
1. Karp's algorithm for maximum cycle mean computation
2. Howard's policy iteration for tropical eigenpair extraction
3. Collatz–Wielandt certification of eigenvalue bounds
4. Critical graph identification
5. Throughput analysis pipeline

All algorithms include complexity analysis, type hints, and worked examples.
"""

import numpy as np
from typing import Tuple, List, Optional, Dict, Set
from dataclasses import dataclass


@dataclass
class TropicalEigenpair:
    """A tropical eigenpair (λ, v) satisfying T_A(v) = λ + v."""
    eigenvalue: float      # λ: cycle time / inverse throughput
    eigenvector: np.ndarray # v: phase offset vector
    throughput: float      # 1/λ: jobs per unit time
    
    def verify(self, A: np.ndarray, tol: float = 1e-10) -> bool:
        """Verify the eigenpair: T_A(v) = λ + v."""
        Tv = trop_mat_vec(A, self.eigenvector)
        return np.allclose(Tv, self.eigenvalue + self.eigenvector, atol=tol)


@dataclass
class CycleInfo:
    """Information about a directed cycle in the precedence graph."""
    vertices: List[int]
    weight: float
    mean: float
    length: int


@dataclass
class CollatzWielandtCertificate:
    """A Collatz–Wielandt certificate bounding the tropical eigenvalue."""
    lower_bound: float
    upper_bound: float
    test_vector: np.ndarray
    gap: float
    
    def is_tight(self, tol: float = 1e-10) -> bool:
        return self.gap < tol


def trop_mat_vec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Max-plus matrix-vector product: (T_A x)_i = max_j (A_ij + x_j)
    
    Time complexity: O(n²)
    Space complexity: O(n)
    
    Parameters:
        A: n×n real matrix (system matrix / precedence weights)
        x: n-vector (current state / completion times)
    
    Returns:
        n-vector: next state under max-plus dynamics
    
    Example:
        >>> A = np.array([[0, 2], [3, 0]])
        >>> x = np.array([0, 0.5])
        >>> trop_mat_vec(A, x)  # [2.5, 3.0]
    """
    n = A.shape[0]
    return np.array([np.max(A[i, :] + x) for i in range(n)])


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Max-plus matrix multiplication: (A ⊗ B)_ij = max_k (A_ik + B_kj)
    
    Time complexity: O(n³)
    Space complexity: O(n²)
    """
    n = A.shape[0]
    C = np.empty((n, n))
    for i in range(n):
        for j in range(n):
            C[i, j] = np.max(A[i, :] + B[:, j])
    return C


def karp_max_cycle_mean(A: np.ndarray) -> Tuple[float, List[int]]:
    """
    Karp's Algorithm for Maximum Cycle Mean
    
    Computes the maximum cycle mean of the weighted digraph defined by A:
        λ* = max over all cycles C of (weight(C) / length(C))
    
    This equals the tropical eigenvalue for irreducible matrices.
    
    Algorithm:
        1. Compute D[k][i] = max weight of a walk of length k ending at i
        2. Apply Karp's formula: λ* = max_i min_{0≤k<n} (D[n][i] - D[k][i]) / (n-k)
    
    Time complexity: O(n³)  — n iterations of n×n matrix operations
    Space complexity: O(n²) — storing the D table
    
    Parameters:
        A: n×n real matrix (edge weights)
    
    Returns:
        (max_cycle_mean, critical_cycle_vertices)
    
    References:
        R. M. Karp, "A characterization of the minimum cycle mean in a digraph,"
        Discrete Mathematics, vol. 23, pp. 309–311, 1978.
    
    Example:
        >>> A = np.array([[0, 2], [3, 0]])
        >>> karp_max_cycle_mean(A)
        (2.5, [0, 1])
    """
    n = A.shape[0]
    
    # D[k][i] = max weight walk of length k ending at i
    D = np.full((n + 1, n), -np.inf)
    # Parent tracking for cycle reconstruction
    parent = np.full((n + 1, n), -1, dtype=int)
    
    D[0, :] = 0.0
    
    for k in range(1, n + 1):
        for i in range(n):
            best_j = -1
            best_val = -np.inf
            for j in range(n):
                val = D[k-1, j] + A[j, i]
                if val > best_val:
                    best_val = val
                    best_j = j
            D[k, i] = best_val
            parent[k, i] = best_j
    
    # Karp's formula
    result = -np.inf
    best_i = 0
    best_k = 0
    for i in range(n):
        min_val = np.inf
        min_k = 0
        for k in range(n):
            if D[n, i] > -np.inf and D[k, i] > -np.inf:
                val = (D[n, i] - D[k, i]) / (n - k)
                if val < min_val:
                    min_val = val
                    min_k = k
        if min_val > result:
            result = min_val
            best_i = i
            best_k = min_k
    
    # Reconstruct critical cycle
    cycle = [best_i]
    current = best_i
    for step in range(n, best_k, -1):
        current = parent[step, current]
        cycle.append(current)
    cycle.reverse()
    
    return result, cycle


def howard_policy_iteration(A: np.ndarray, max_iter: int = 100) -> TropicalEigenpair:
    """
    Howard's Policy Iteration for Tropical Eigenpair Extraction
    
    Finds (λ, v) such that T_A(v) = λ + v by iterating over policies
    (argmax choices in the tropical product).
    
    Algorithm:
        1. Initialize policy π(i) = 0 for all i
        2. Solve the linear system: v_i - v_{π(i)} = A_{i,π(i)} - λ
           with the constraint that λ = average cycle weight under π
        3. Update policy: π(i) = argmax_j (A_{ij} + v_j)
        4. Repeat until policy stabilizes
    
    Time complexity: O(n³) per iteration, at most O(n!) iterations
                     (typically converges in O(n) iterations)
    Space complexity: O(n²)
    
    Parameters:
        A: n×n real matrix (irreducible)
        max_iter: maximum number of policy iterations
    
    Returns:
        TropicalEigenpair with eigenvalue, eigenvector, and throughput
    
    Example:
        >>> A = np.array([[0, 2], [3, 0]])
        >>> result = howard_policy_iteration(A)
        >>> result.eigenvalue  # 2.5
        >>> result.eigenvector  # [0, 0.5] (normalized)
    """
    n = A.shape[0]
    
    # Initialize policy: each node points to its best successor
    policy = np.zeros(n, dtype=int)
    for i in range(n):
        policy[i] = np.argmax(A[i, :])
    
    for iteration in range(max_iter):
        # Step 1: Evaluate current policy
        # Find cycle in policy graph and compute its mean
        visited = np.full(n, -1, dtype=int)
        cycle_node = -1
        node = 0
        step = 0
        
        while visited[node] == -1:
            visited[node] = step
            node = policy[node]
            step += 1
        
        # Found cycle starting at 'node'
        cycle_start = node
        cycle_weight = 0.0
        cycle_length = 0
        current = node
        while True:
            next_node = policy[current]
            cycle_weight += A[current, next_node]
            cycle_length += 1
            current = next_node
            if current == cycle_start:
                break
        
        lam = cycle_weight / cycle_length
        
        # Step 2: Compute eigenvector by solving v_i = A_{i,π(i)} + v_{π(i)} - λ
        # with v[cycle_start] = 0
        v = np.zeros(n)
        # BFS/DFS from cycle to compute potentials
        computed = np.full(n, False)
        
        # First, set v along the cycle
        current = cycle_start
        computed[current] = True
        while True:
            next_node = policy[current]
            if not computed[next_node]:
                v[next_node] = A[current, next_node] + v[current] - lam
                computed[next_node] = True
            current = next_node
            if current == cycle_start:
                break
        
        # Then propagate to non-cycle nodes
        changed = True
        while changed:
            changed = False
            for i in range(n):
                if not computed[i]:
                    pi = policy[i]
                    if computed[pi]:
                        v[i] = A[i, pi] + v[pi] - lam + lam  # v[i] s.t. T_A(v)_i = lam + v[i]
                        # Actually: we want A[i, pi] + v[pi] = lam + v[i]
                        # => v[i] = A[i, pi] + v[pi] - lam
                        v[i] = A[i, pi] + v[pi] - lam
                        computed[i] = True
                        changed = True
        
        # Step 3: Update policy
        new_policy = np.zeros(n, dtype=int)
        for i in range(n):
            new_policy[i] = np.argmax(A[i, :] + v)
        
        if np.array_equal(new_policy, policy):
            break
        policy = new_policy
    
    # Normalize eigenvector
    v -= v[0]
    
    throughput = 1.0 / lam if lam > 0 else float('inf')
    
    return TropicalEigenpair(
        eigenvalue=lam,
        eigenvector=v,
        throughput=throughput
    )


def collatz_wielandt_certify(
    A: np.ndarray,
    x: np.ndarray
) -> CollatzWielandtCertificate:
    """
    Collatz–Wielandt Certification of Eigenvalue Bounds
    
    Given any test vector x, certifies:
        min_i (T_A(x)_i - x_i) ≤ λ ≤ max_i (T_A(x)_i - x_i)
    
    This provides rigorous bounds on the throughput without computing
    the exact eigenpair.
    
    Time complexity: O(n²) — one tropical matrix-vector product
    Space complexity: O(n)
    
    Parameters:
        A: n×n real matrix
        x: n-vector (test vector for bound computation)
    
    Returns:
        CollatzWielandtCertificate with lower/upper bounds and gap
    
    Example:
        >>> A = np.array([[0, 2], [3, 0]])
        >>> cert = collatz_wielandt_certify(A, np.zeros(2))
        >>> cert.lower_bound  # 2.0
        >>> cert.upper_bound  # 3.0
    """
    Tx = trop_mat_vec(A, x)
    gaps = Tx - x
    lo = float(np.min(gaps))
    hi = float(np.max(gaps))
    
    return CollatzWielandtCertificate(
        lower_bound=lo,
        upper_bound=hi,
        test_vector=x.copy(),
        gap=hi - lo
    )


def find_critical_graph(A: np.ndarray, lam: float, tol: float = 1e-10) -> Dict:
    """
    Identify the Critical Graph
    
    The critical graph consists of edges (i,j) where A_ij + v_j = λ + v_i,
    i.e., edges that are "active" in the eigenpair equation.
    
    These edges form the bottleneck cycles that determine system throughput.
    
    Time complexity: O(n²)
    Space complexity: O(n²)
    
    Returns:
        Dictionary with 'edges', 'nodes', and 'cycles' of the critical graph
    """
    n = A.shape[0]
    v = find_eigenvector_iterative(A, lam)
    
    critical_edges = []
    critical_nodes: Set[int] = set()
    
    for i in range(n):
        for j in range(n):
            if abs(A[i, j] + v[j] - (lam + v[i])) < tol:
                critical_edges.append((i, j))
                critical_nodes.add(i)
                critical_nodes.add(j)
    
    return {
        'edges': critical_edges,
        'nodes': sorted(critical_nodes),
        'eigenvector': v,
        'eigenvalue': lam
    }


def find_eigenvector_iterative(A: np.ndarray, lam: float, max_iter: int = 1000) -> np.ndarray:
    """Find eigenvector by iterating T_{A-λI}."""
    n = A.shape[0]
    B = A - lam * np.eye(n)
    v = np.zeros(n)
    for _ in range(max_iter):
        v_new = trop_mat_vec(B, v)
        v_new -= v_new[0]
        if np.allclose(v, v_new, atol=1e-12):
            break
        v = v_new
    return v


def enumerate_simple_cycles(A: np.ndarray) -> List[CycleInfo]:
    """
    Enumerate All Simple Cycles and Their Means
    
    For small matrices, enumerate all simple cycles and compute their means.
    The maximum cycle mean equals the tropical eigenvalue.
    
    Time complexity: O(n! · n) — exponential, only for small n
    Space complexity: O(n!)
    
    Parameters:
        A: n×n real matrix (n ≤ 8 recommended)
    
    Returns:
        List of CycleInfo objects sorted by mean (descending)
    """
    n = A.shape[0]
    cycles = []
    
    # Self-loops
    for i in range(n):
        cycles.append(CycleInfo(
            vertices=[i],
            weight=A[i, i],
            mean=A[i, i],
            length=1
        ))
    
    # Cycles of length ≥ 2
    def dfs(start: int, current: int, path: List[int], weight: float, visited: Set[int]):
        for next_node in range(n):
            edge_weight = A[current, next_node]
            if next_node == start and len(path) >= 2:
                # Found a cycle back to start
                total_weight = weight + edge_weight
                cycle_length = len(path)
                cycles.append(CycleInfo(
                    vertices=list(path),
                    weight=total_weight,
                    mean=total_weight / cycle_length,
                    length=cycle_length
                ))
            elif next_node not in visited and next_node > start:
                # Continue DFS (only visit nodes > start to avoid duplicates)
                visited.add(next_node)
                path.append(next_node)
                dfs(start, next_node, path, weight + edge_weight, visited)
                path.pop()
                visited.discard(next_node)
    
    for start in range(n):
        dfs(start, start, [start], 0.0, {start})
    
    cycles.sort(key=lambda c: c.mean, reverse=True)
    return cycles


def throughput_analysis(A: np.ndarray, station_names: Optional[List[str]] = None) -> Dict:
    """
    Complete Throughput Analysis Pipeline
    
    Performs a full analysis of a discrete-event system:
    1. Computes the maximum cycle mean (cycle time)
    2. Finds the tropical eigenpair
    3. Identifies the critical graph (bottleneck)
    4. Provides Collatz–Wielandt certification
    5. Reports throughput with confidence
    
    Parameters:
        A: n×n real matrix (system precedence/timing matrix)
        station_names: optional names for the stations/nodes
    
    Returns:
        Dictionary with complete analysis results
    """
    n = A.shape[0]
    if station_names is None:
        station_names = [f"Station {i+1}" for i in range(n)]
    
    # Step 1: Compute eigenvalue
    lam, critical_cycle = karp_max_cycle_mean(A)
    
    # Step 2: Find eigenvector
    eigenpair = howard_policy_iteration(A)
    
    # Step 3: Verify
    verified = eigenpair.verify(A)
    
    # Step 4: Collatz–Wielandt certificate
    cert = collatz_wielandt_certify(A, eigenpair.eigenvector)
    
    # Step 5: Critical graph
    crit_graph = find_critical_graph(A, lam)
    
    # Step 6: Enumerate cycles (if small enough)
    all_cycles = enumerate_simple_cycles(A) if n <= 8 else None
    
    return {
        'eigenvalue': lam,
        'eigenpair': eigenpair,
        'verified': verified,
        'certificate': cert,
        'critical_graph': crit_graph,
        'all_cycles': all_cycles,
        'throughput': eigenpair.throughput,
        'station_names': station_names,
        'matrix': A
    }


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("TROPICAL SPECTRAL ALGORITHMS — DEMONSTRATIONS")
    print("=" * 60)
    print()
    
    # Example 1: 2×2 Manufacturing Cell
    print("--- Example 1: 2×2 Manufacturing Cell ---")
    A = np.array([[0, 2], [3, 0]], dtype=float)
    result = throughput_analysis(A, ["Machine A", "Machine B"])
    print(f"Eigenvalue (cycle time): {result['eigenvalue']}")
    print(f"Eigenvector: {result['eigenpair'].eigenvector}")
    print(f"Throughput: {result['throughput']:.4f}")
    print(f"Verified: {result['verified']}")
    print(f"CW Certificate: [{result['certificate'].lower_bound:.4f}, "
          f"{result['certificate'].upper_bound:.4f}]")
    if result['all_cycles']:
        print(f"All cycles (sorted by mean):")
        for c in result['all_cycles'][:5]:
            print(f"  {c.vertices} → weight={c.weight:.1f}, mean={c.mean:.4f}")
    print()
    
    # Example 2: Karp's algorithm detail
    print("--- Example 2: Karp's Algorithm ---")
    A = np.array([[1, 5, 3], [2, 0, 4], [6, 1, 2]], dtype=float)
    lam, cycle = karp_max_cycle_mean(A)
    print(f"Matrix:\n{A}")
    print(f"Max cycle mean: {lam:.4f}")
    print(f"Critical cycle: {cycle}")
    print()
    
    # Example 3: Howard's policy iteration
    print("--- Example 3: Howard's Policy Iteration ---")
    ep = howard_policy_iteration(A)
    print(f"Eigenvalue: {ep.eigenvalue:.4f}")
    print(f"Eigenvector: {ep.eigenvector}")
    print(f"Throughput: {ep.throughput:.4f}")
    print(f"Verified: {ep.verify(A)}")
    print()
    
    # Example 4: Collatz–Wielandt convergence
    print("--- Example 4: Collatz–Wielandt Convergence ---")
    x = np.zeros(3)
    for k in range(8):
        cert = collatz_wielandt_certify(A, x)
        print(f"  k={k}: [{cert.lower_bound:.4f}, {cert.upper_bound:.4f}] "
              f"gap={cert.gap:.4f}")
        x = trop_mat_vec(A, x)
        x -= x[0]
