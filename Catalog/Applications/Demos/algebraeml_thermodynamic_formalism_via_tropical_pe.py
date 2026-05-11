#!/usr/bin/env python3
"""
Algorithms for Tropical Pressure and Maximum Cycle Mean

Implements the core algorithms from the tropical thermodynamic formalism:

1. Karp's Algorithm — O(n³) computation of maximum cycle mean
2. Howard's Policy Iteration — typically faster convergence
3. Subeigenvector Computation via Bellman-Ford relaxation
4. Quotient Matrix Construction
5. Tropical Matrix Powers (max-plus semiring)

All algorithms include full docstrings, type hints, and example usage.
"""

import numpy as np
from typing import Optional, Tuple, List, Dict
from dataclasses import dataclass

NEG_INF = float('-inf')


# ═════════════════════════════════════════════════════════
# Data Structures
# ═════════════════════════════════════════════════════════

@dataclass
class CycleInfo:
    """Information about a cycle in a weighted directed graph."""
    nodes: List[int]
    total_weight: float
    length: int
    mean: float


@dataclass
class SubeigenvectorCertificate:
    """A Collatz–Wielandt certificate (μ, u) proving that the
    maximum cycle mean is at most μ."""
    mu: float
    u: np.ndarray
    is_tight: bool  # True if μ equals the max cycle mean


# ═════════════════════════════════════════════════════════
# Algorithm 1: Karp's Algorithm
# ═════════════════════════════════════════════════════════

def karp_algorithm(A: np.ndarray) -> Tuple[float, np.ndarray]:
    """
    Karp's Algorithm for Maximum Cycle Mean.

    Computes the maximum cycle mean λ* of a weighted directed graph
    represented by adjacency matrix A, where A[i][j] = weight of edge
    i→j, or -∞ if no edge exists.

    Algorithm:
        1. Compute dp[k][i] = max weight of a path of exactly k edges
           ending at node i, for k = 0, 1, ..., n.
        2. Apply Karp's formula:
           λ* = max_i min_{0≤k<n} (dp[n][i] - dp[k][i]) / (n - k)

    Complexity: O(n³) time, O(n²) space.

    Args:
        A: n×n numpy array, adjacency matrix with -inf for missing edges.

    Returns:
        (lambda_star, dp_table) where lambda_star is the max cycle mean
        and dp_table is the (n+1)×n dynamic programming table.

    Example:
        >>> A = np.array([[NEG_INF, 3], [2, NEG_INF]])
        >>> lam, dp = karp_algorithm(A)
        >>> print(f"Max cycle mean: {lam}")  # 2.5
    """
    n = A.shape[0]
    dp = np.full((n + 1, n), NEG_INF)
    dp[0, :] = 0

    for k in range(1, n + 1):
        for j in range(n):
            for i in range(n):
                if A[i, j] != NEG_INF and dp[k-1, i] != NEG_INF:
                    dp[k, j] = max(dp[k, j], dp[k-1, i] + A[i, j])

    result = NEG_INF
    for i in range(n):
        if dp[n, i] == NEG_INF:
            continue
        min_val = float('inf')
        for k in range(n):
            if dp[k, i] != NEG_INF:
                val = (dp[n, i] - dp[k, i]) / (n - k)
                min_val = min(min_val, val)
        if min_val != float('inf'):
            result = max(result, min_val)

    return (result if result != NEG_INF else 0.0), dp


# ═════════════════════════════════════════════════════════
# Algorithm 2: Howard's Policy Iteration
# ═════════════════════════════════════════════════════════

def howard_policy_iteration(A: np.ndarray, max_iter: int = 1000) -> Tuple[float, np.ndarray]:
    """
    Howard's Policy Iteration for Maximum Cycle Mean.

    Typically converges much faster than Karp's algorithm in practice,
    though worst-case is also O(n³).

    Algorithm:
        1. Start with an arbitrary policy π (choosing one successor per node).
        2. Evaluate the policy: find the maximum cycle mean under π.
        3. Improve the policy greedily.
        4. Repeat until convergence.

    Args:
        A: n×n adjacency matrix with -inf for missing edges.
        max_iter: maximum number of iterations.

    Returns:
        (lambda_star, policy) where policy[i] is the optimal successor of i.

    Example:
        >>> A = np.array([[NEG_INF, 3, 1], [NEG_INF, NEG_INF, 4], [2, NEG_INF, NEG_INF]])
        >>> lam, pi = howard_policy_iteration(A)
    """
    n = A.shape[0]

    # Initialize policy: pick the best outgoing edge for each node
    policy = np.full(n, -1, dtype=int)
    for i in range(n):
        best_j = -1
        best_w = NEG_INF
        for j in range(n):
            if A[i, j] > best_w:
                best_w = A[i, j]
                best_j = j
        policy[i] = best_j

    for iteration in range(max_iter):
        # Evaluate current policy: find cycle means
        # Follow policy to find cycles
        visited = np.full(n, -1, dtype=int)
        cycle_mean = NEG_INF

        for start in range(n):
            if policy[start] == -1:
                continue
            path = []
            node = start
            step = 0
            while visited[node] == -1 and node != -1:
                visited[node] = step
                path.append(node)
                next_node = policy[node]
                if next_node == -1:
                    break
                node = next_node
                step += 1

            if node != -1 and visited[node] >= 0 and node in path:
                # Found a cycle
                idx = path.index(node)
                cycle_nodes = path[idx:]
                weight = sum(A[cycle_nodes[k], cycle_nodes[(k+1) % len(cycle_nodes)]]
                           for k in range(len(cycle_nodes)))
                mean = weight / len(cycle_nodes)
                cycle_mean = max(cycle_mean, mean)

        # Reset visited
        visited[:] = -1

        if cycle_mean == NEG_INF:
            return 0.0, policy

        # Policy improvement
        improved = False
        lam = cycle_mean

        # Compute potential u via Bellman relaxation with current λ
        u = np.zeros(n)
        for _ in range(n):
            for i in range(n):
                for j in range(n):
                    if A[i, j] != NEG_INF:
                        needed = A[i, j] + u[j] - lam
                        if needed > u[i] + 1e-10:
                            u[i] = needed

        # Improve policy
        for i in range(n):
            best_j = policy[i]
            best_val = NEG_INF
            for j in range(n):
                if A[i, j] != NEG_INF:
                    val = A[i, j] + u[j]
                    if val > best_val + 1e-10:
                        best_val = val
                        if j != policy[i]:
                            improved = True
                        best_j = j
            policy[i] = best_j

        if not improved:
            return lam, policy

    return cycle_mean, policy


# ═════════════════════════════════════════════════════════
# Algorithm 3: Subeigenvector Computation
# ═════════════════════════════════════════════════════════

def compute_subeigenvector(A: np.ndarray, mu: float) -> Optional[SubeigenvectorCertificate]:
    """
    Compute a tropical subeigenvector for parameter μ.

    A vector u is a subeigenvector for (A, μ) if:
        A[i][j] + u[j] ≤ μ + u[i]  for all admissible edges (i,j).

    This is equivalent to the Bellman feasibility condition.

    Algorithm: Bellman-Ford relaxation on the difference constraint system.

    Args:
        A: adjacency matrix
        mu: candidate eigenvalue parameter

    Returns:
        SubeigenvectorCertificate if μ ≥ λ*, None if μ < λ*.
    """
    n = A.shape[0]
    u = np.zeros(n)

    for iteration in range(n + 1):
        updated = False
        for i in range(n):
            for j in range(n):
                if A[i, j] != NEG_INF:
                    needed = A[i, j] + u[j] - mu
                    if needed > u[i] + 1e-10:
                        u[i] = needed
                        updated = True
        if not updated:
            break
    else:
        # Final check for negative cycle
        for i in range(n):
            for j in range(n):
                if A[i, j] != NEG_INF:
                    if A[i, j] + u[j] - mu > u[i] + 1e-10:
                        return None

    lam, _ = karp_algorithm(A)
    is_tight = abs(mu - lam) < 1e-10

    return SubeigenvectorCertificate(mu=mu, u=u, is_tight=is_tight)


# ═════════════════════════════════════════════════════════
# Algorithm 4: Quotient Matrix
# ═════════════════════════════════════════════════════════

def build_quotient_matrix(A: np.ndarray, partition: List[int]) -> Tuple[np.ndarray, Dict[int, int]]:
    """
    Build the quotient tropical matrix under a partition.

    Given a partition q: nodes → class labels, the quotient matrix Q is:
        Q[b][c] = max over all (i,j) with q[i]=b, q[j]=c of A[i][j]

    This is the tropical analogue of the classical quotient construction
    for Markov chains.

    Args:
        A: n×n adjacency matrix
        partition: list of class labels, partition[i] = class of node i

    Returns:
        (Q, class_map) where Q is the quotient matrix and class_map
        maps class labels to indices in Q.
    """
    classes = sorted(set(partition))
    m = len(classes)
    class_map = {c: idx for idx, c in enumerate(classes)}

    Q = np.full((m, m), NEG_INF)
    n = A.shape[0]

    for i in range(n):
        for j in range(n):
            bi = class_map[partition[i]]
            cj = class_map[partition[j]]
            Q[bi, cj] = max(Q[bi, cj], A[i, j])

    return Q, class_map


# ═════════════════════════════════════════════════════════
# Algorithm 5: Tropical Matrix Operations
# ═════════════════════════════════════════════════════════

def tropical_matrix_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (max-plus) matrix multiplication.

    (A ⊗ B)[i][j] = max_k (A[i][k] + B[k][j])

    This replaces (×, +) with (+, max) in the standard matrix product.
    """
    n, m = A.shape[0], B.shape[1]
    p = A.shape[1]
    C = np.full((n, m), NEG_INF)
    for i in range(n):
        for j in range(m):
            for k in range(p):
                if A[i, k] != NEG_INF and B[k, j] != NEG_INF:
                    C[i, j] = max(C[i, j], A[i, k] + B[k, j])
    return C


def tropical_closure(A: np.ndarray) -> np.ndarray:
    """
    Tropical Kleene star (transitive closure): A* = I ⊕ A ⊕ A² ⊕ ...

    For graphs without positive cycles, this converges in n steps.
    Returns the matrix of maximum-weight paths between all pairs.
    """
    n = A.shape[0]
    # Floyd-Warshall style
    D = A.copy()
    for i in range(n):
        D[i, i] = max(D[i, i], 0)

    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i, k] != NEG_INF and D[k, j] != NEG_INF:
                    D[i, j] = max(D[i, j], D[i, k] + D[k, j])

    return D


# ═════════════════════════════════════════════════════════
# Convenience: From Closure Operator to Matrix
# ═════════════════════════════════════════════════════════

def closure_operator_to_matrix(
    n: int,
    step: Dict[int, List[int]],
    weight: Dict[Tuple[int, int], float]
) -> np.ndarray:
    """
    Convert a finitary closure correspondence operator to a tropical matrix.

    Args:
        n: number of states
        step: dictionary mapping each state to its admissible successors
        weight: dictionary mapping (source, target) pairs to edge weights

    Returns:
        n×n tropical matrix A where A[i][j] = weight[(i,j)] if j ∈ step[i],
        and A[i][j] = -∞ otherwise.
    """
    A = np.full((n, n), NEG_INF)
    for i, successors in step.items():
        for j in successors:
            A[i, j] = weight.get((i, j), 0)
    return A


# ═════════════════════════════════════════════════════════
# Example Usage
# ═════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Algorithm Examples")
    print("=" * 50)

    # Example 1: Karp's algorithm
    A = np.array([
        [NEG_INF, 6, NEG_INF],
        [NEG_INF, NEG_INF, 4],
        [2, NEG_INF, NEG_INF]
    ])

    lam, dp = karp_algorithm(A)
    print(f"\n1. Karp's Algorithm: λ* = {lam:.4f}")
    print(f"   Expected: (6+4+2)/3 = {12/3:.4f}")

    # Example 2: Howard's policy iteration
    lam2, policy = howard_policy_iteration(A)
    print(f"\n2. Howard's Policy Iteration: λ* = {lam2:.4f}")
    print(f"   Optimal policy: {policy}")

    # Example 3: Subeigenvector
    cert = compute_subeigenvector(A, lam)
    if cert:
        print(f"\n3. Subeigenvector Certificate:")
        print(f"   μ = {cert.mu:.4f}, u = {cert.u}")
        print(f"   Tight: {cert.is_tight}")

    # Example 4: Quotient
    A4 = np.array([
        [NEG_INF, NEG_INF, 5, 5],
        [NEG_INF, NEG_INF, 5, 5],
        [3, 3, NEG_INF, NEG_INF],
        [3, 3, NEG_INF, NEG_INF]
    ])
    Q, cmap = build_quotient_matrix(A4, [0, 0, 1, 1])
    print(f"\n4. Quotient Matrix:")
    print(f"   Original λ* = {karp_algorithm(A4)[0]:.4f}")
    print(f"   Quotient λ* = {karp_algorithm(Q)[0]:.4f}")

    # Example 5: Closure operator
    step = {0: [1, 2], 1: [0, 2], 2: [0]}
    weight = {(0,1): 3, (0,2): 1, (1,0): 2, (1,2): 4, (2,0): 5}
    A5 = closure_operator_to_matrix(3, step, weight)
    lam5, _ = karp_algorithm(A5)
    print(f"\n5. Closure Operator → Tropical Matrix:")
    print(f"   Closure pressure = {lam5:.4f}")


#!/usr/bin/env python3
"""
Applications of Tropical Pressure Theory

Demonstrates real-world applications of the tropical thermodynamic formalism:

1. Network Throughput Analysis — critical path in communication networks
2. Scheduling Optimization — makespan bounds for job scheduling
3. Autonomous System Routing — BGP-style optimal path computation
4. Biological Network Analysis — gene regulatory circuit pressure
5. Compression Certificate — information-theoretic bounds from tropical eigenvalue
"""

import numpy as np
from typing import Dict, List, Tuple

NEG_INF = float('-inf')


def karp_max_cycle_mean(A: np.ndarray) -> float:
    """Karp's algorithm for maximum cycle mean."""
    n = A.shape[0]
    dp = np.full((n + 1, n), NEG_INF)
    dp[0, :] = 0
    for k in range(1, n + 1):
        for j in range(n):
            for i in range(n):
                if A[i, j] != NEG_INF and dp[k-1, i] != NEG_INF:
                    dp[k, j] = max(dp[k, j], dp[k-1, i] + A[i, j])
    result = NEG_INF
    for i in range(n):
        if dp[n, i] == NEG_INF:
            continue
        min_val = float('inf')
        for k in range(n):
            if dp[k, i] != NEG_INF:
                val = (dp[n, i] - dp[k, i]) / (n - k)
                min_val = min(min_val, val)
        if min_val != float('inf'):
            result = max(result, min_val)
    return result if result != NEG_INF else 0.0


# ═════════════════════════════════════════════════════════
# Application 1: Network Throughput Analysis
# ═════════════════════════════════════════════════════════

def network_throughput_analysis():
    """
    Analyze the asymptotic throughput of a communication network.

    The tropical eigenvalue gives the maximum sustainable data rate
    per time step through the network's bottleneck cycle.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Throughput Analysis")
    print("=" * 60)

    # Network: 4 routers with bandwidth weights (log-scale)
    # Higher weight = higher bandwidth
    labels = ["Router A", "Router B", "Router C", "Router D"]
    A = np.array([
        [NEG_INF, 8, NEG_INF, 3],
        [NEG_INF, NEG_INF, 6, NEG_INF],
        [4, NEG_INF, NEG_INF, 7],
        [NEG_INF, 5, NEG_INF, NEG_INF]
    ])

    print("\nNetwork topology (log-bandwidth weights):")
    for i in range(4):
        for j in range(4):
            if A[i, j] != NEG_INF:
                print(f"  {labels[i]} → {labels[j]}: {A[i, j]:.0f}")

    mcm = karp_max_cycle_mean(A)
    print(f"\nMaximum sustainable throughput rate: {mcm:.4f} per hop")
    print(f"  This means the dominant cycle can sustain {mcm:.2f} units")
    print(f"  of data per time step asymptotically.")
    print()


# ═════════════════════════════════════════════════════════
# Application 2: Job Scheduling Makespan
# ═════════════════════════════════════════════════════════

def scheduling_optimization():
    """
    Compute the critical cycle in a cyclic job-shop scheduling problem.

    The maximum cycle mean gives the minimum achievable cycle time
    (makespan) for a repeating production schedule.
    """
    print("=" * 60)
    print("APPLICATION 2: Cyclic Job Scheduling")
    print("=" * 60)

    # 3 machines, cyclic production: each job visits machines in order
    # Weights = processing times
    labels = ["Machine 1", "Machine 2", "Machine 3"]
    A = np.array([
        [NEG_INF, 12, NEG_INF],
        [NEG_INF, NEG_INF, 8],
        [5, NEG_INF, NEG_INF]
    ])

    print("\nCyclic production schedule (processing times):")
    for i in range(3):
        for j in range(3):
            if A[i, j] != NEG_INF:
                print(f"  {labels[i]} → {labels[j]}: {A[i, j]:.0f} time units")

    mcm = karp_max_cycle_mean(A)
    cycle_time = (12 + 8 + 5) / 3  # the only cycle

    print(f"\nMinimum cycle time (tropical eigenvalue): {mcm:.4f}")
    print(f"Total cycle processing time: {12+8+5}")
    print(f"Average per machine: {cycle_time:.4f}")
    print(f"\n→ Production rate: 1 unit every {mcm:.2f} time steps")
    print()


# ═════════════════════════════════════════════════════════
# Application 3: BGP-Style Routing
# ═════════════════════════════════════════════════════════

def routing_analysis():
    """
    Analyze routing stability in an autonomous system network.

    The tropical eigenvalue determines whether the routing protocol
    will converge (negative) or oscillate (positive cycle mean).
    """
    print("=" * 60)
    print("APPLICATION 3: Routing Stability Analysis")
    print("=" * 60)

    # 5 autonomous systems with preference weights
    labels = ["AS1", "AS2", "AS3", "AS4", "AS5"]
    A = np.array([
        [NEG_INF, 2, NEG_INF, -1, NEG_INF],
        [NEG_INF, NEG_INF, 3, NEG_INF, NEG_INF],
        [-2, NEG_INF, NEG_INF, 1, NEG_INF],
        [NEG_INF, NEG_INF, NEG_INF, NEG_INF, 4],
        [1, NEG_INF, NEG_INF, NEG_INF, NEG_INF]
    ])

    print("\nAS routing preferences (weights):")
    for i in range(5):
        for j in range(5):
            if A[i, j] != NEG_INF:
                print(f"  {labels[i]} → {labels[j]}: {A[i, j]:+.0f}")

    mcm = karp_max_cycle_mean(A)
    print(f"\nMaximum cycle mean: {mcm:.4f}")
    if mcm > 0:
        print(f"  ⚠ UNSTABLE: Positive cycle mean → routing may oscillate")
    elif mcm == 0:
        print(f"  ○ MARGINAL: Zero cycle mean → borderline stability")
    else:
        print(f"  ✓ STABLE: Negative cycle mean → routing converges")
    print()


# ═════════════════════════════════════════════════════════
# Application 4: Gene Regulatory Network
# ═════════════════════════════════════════════════════════

def gene_regulatory_analysis():
    """
    Analyze a gene regulatory network for dominant feedback loops.

    The tropical eigenvalue identifies the strongest feedback cycle,
    which determines the asymptotic behavior of the regulatory system.
    """
    print("=" * 60)
    print("APPLICATION 4: Gene Regulatory Network Analysis")
    print("=" * 60)

    genes = ["Gene A", "Gene B", "Gene C", "Gene D"]
    # Weights represent log-fold regulatory effects
    # Positive = activation, negative = repression
    A = np.array([
        [NEG_INF, 3, NEG_INF, -2],
        [-1, NEG_INF, 4, NEG_INF],
        [NEG_INF, NEG_INF, NEG_INF, 2],
        [1, NEG_INF, NEG_INF, NEG_INF]
    ])

    print("\nGene regulatory interactions (log-fold effects):")
    for i in range(4):
        for j in range(4):
            if A[i, j] != NEG_INF:
                effect = "activates" if A[i, j] > 0 else "represses"
                print(f"  {genes[i]} → {genes[j]}: {effect} "
                      f"(strength {abs(A[i, j]):.0f})")

    mcm = karp_max_cycle_mean(A)
    print(f"\nDominant feedback strength (tropical eigenvalue): {mcm:.4f}")
    if mcm > 0:
        print(f"  → The network has a net-positive feedback loop")
        print(f"  → Predicts oscillatory or bistable behavior")
    else:
        print(f"  → The network is dominated by negative feedback")
        print(f"  → Predicts stable steady-state behavior")
    print()


# ═════════════════════════════════════════════════════════
# Application 5: Compression Certificate
# ═════════════════════════════════════════════════════════

def compression_certificate():
    """
    Derive a compression certificate from tropical pressure.

    The tropical eigenvalue gives an upper bound on the asymptotic
    per-symbol encoding cost for trajectories in the system.
    """
    print("=" * 60)
    print("APPLICATION 5: Compression Certificate")
    print("=" * 60)

    # Symbolic dynamics: 3-state system representing a data source
    states = ["Low", "Medium", "High"]
    # Weights = log-probability (negative → rare, positive → common)
    A = np.array([
        [2, 1, NEG_INF],
        [0, 1, 3],
        [NEG_INF, 2, 1]
    ])

    print("\nData source model (log-probability weights):")
    for i in range(3):
        for j in range(3):
            if A[i, j] != NEG_INF:
                print(f"  {states[i]} → {states[j]}: weight {A[i, j]:.0f}")

    mcm = karp_max_cycle_mean(A)
    print(f"\nTropical eigenvalue (closure pressure): {mcm:.4f}")
    print(f"Compression certificate:")
    print(f"  → Any encoding of length-n trajectories requires")
    print(f"     at least n × {mcm:.4f} = {mcm:.4f}n bits asymptotically")
    print(f"  → This bound is achievable by following the dominant cycle")

    # Show the dominant cycle
    print(f"\nDominant trajectories are those staying in high-weight cycles.")

    # Compute normalized max path weights for increasing lengths
    n = A.shape[0]
    Ak = np.full((n, n), NEG_INF)
    np.fill_diagonal(Ak, 0)
    print(f"\n  {'Length':>6s}  {'Max weight/length':>18s}  {'Gap to λ*':>12s}")
    for k in range(1, 16):
        Ak_new = np.full((n, n), NEG_INF)
        for i in range(n):
            for j in range(n):
                for l in range(n):
                    if Ak[i, l] != NEG_INF and A[l, j] != NEG_INF:
                        Ak_new[i, j] = max(Ak_new[i, j], Ak[i, l] + A[l, j])
        Ak = Ak_new
        max_w = Ak.max()
        if max_w != NEG_INF:
            normalized = max_w / k
            gap = abs(normalized - mcm)
            print(f"  {k:6d}  {normalized:18.6f}  {gap:12.8f}")

    print()


if __name__ == "__main__":
    network_throughput_analysis()
    scheduling_optimization()
    routing_analysis()
    gene_regulatory_analysis()
    compression_certificate()

    print("=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Tropical Pressure and Maximum Cycle Mean Computation

Demonstrates the core concepts of the tropical thermodynamic formalism
for closure dynamics:
  - Tropical (max-plus) matrix operations
  - Maximum cycle mean computation
  - Karp's algorithm for finding the tropical eigenvalue
  - Subeigenvector (Bellman certificate) verification
  - Quotient invariance under closure congruence

Each example uses concrete numerical data to illustrate the theory.
"""

import numpy as np
from itertools import permutations
from typing import Optional

# ─────────────────────────────────────────────────────────
# Core: Tropical (Max-Plus) Matrix Arithmetic
# ─────────────────────────────────────────────────────────

NEG_INF = float('-inf')  # ⊥ in tropical semiring


def trop_add(a: float, b: float) -> float:
    """Tropical addition = max."""
    return max(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication = ordinary addition."""
    if a == NEG_INF or b == NEG_INF:
        return NEG_INF
    return a + b


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: (A ⊗ B)_{ij} = max_k (A_{ik} + B_{kj})."""
    n = A.shape[0]
    C = np.full((n, n), NEG_INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = trop_add(C[i, j], trop_mul(A[i, k], B[k, j]))
    return C


def trop_mat_pow(A: np.ndarray, p: int) -> np.ndarray:
    """Tropical matrix power A^{⊗p}."""
    n = A.shape[0]
    result = np.full((n, n), NEG_INF)
    np.fill_diagonal(result, 0)  # tropical identity
    for _ in range(p):
        result = trop_mat_mul(result, A)
    return result


# ─────────────────────────────────────────────────────────
# Maximum Cycle Mean via Enumeration (small graphs)
# ─────────────────────────────────────────────────────────

def all_simple_cycles(A: np.ndarray):
    """Enumerate all simple cycles in the graph induced by A.
    Yields (cycle_nodes, total_weight, length)."""
    n = A.shape[0]
    for length in range(1, n + 1):
        for perm in permutations(range(n), length):
            # Check if this forms a valid cycle
            valid = True
            weight = 0.0
            for idx in range(length):
                i = perm[idx]
                j = perm[(idx + 1) % length]
                if A[i, j] == NEG_INF:
                    valid = False
                    break
                weight += A[i, j]
            if valid:
                yield list(perm), weight, length


def max_cycle_mean_enumerate(A: np.ndarray) -> float:
    """Compute maximum cycle mean by enumerating all simple cycles."""
    best = NEG_INF
    for nodes, weight, length in all_simple_cycles(A):
        mean = weight / length
        if mean > best:
            best = mean
    return best if best != NEG_INF else 0.0


# ─────────────────────────────────────────────────────────
# Karp's Algorithm for Maximum Cycle Mean
# ─────────────────────────────────────────────────────────

def karp_max_cycle_mean(A: np.ndarray) -> float:
    """Karp's algorithm: compute the maximum cycle mean in O(n³).

    λ* = max_i min_{0≤k<n} (d_n(i) - d_k(i)) / (n - k)

    where d_k(i) = max weight of a path of length k ending at i.
    """
    n = A.shape[0]
    # dp[k][i] = max weight of a path of exactly k edges ending at i
    dp = np.full((n + 1, n), NEG_INF)
    dp[0, :] = 0  # length-0 paths: weight 0 at each node

    for k in range(1, n + 1):
        for j in range(n):
            for i in range(n):
                if A[i, j] != NEG_INF and dp[k-1, i] != NEG_INF:
                    dp[k, j] = max(dp[k, j], dp[k-1, i] + A[i, j])

    # Karp's formula
    result = NEG_INF
    for i in range(n):
        if dp[n, i] == NEG_INF:
            continue
        min_val = float('inf')
        for k in range(n):
            if dp[k, i] != NEG_INF:
                val = (dp[n, i] - dp[k, i]) / (n - k)
                min_val = min(min_val, val)
        if min_val != float('inf'):
            result = max(result, min_val)

    return result if result != NEG_INF else 0.0


# ─────────────────────────────────────────────────────────
# Subeigenvector Verification
# ─────────────────────────────────────────────────────────

def verify_subeigenvector(A: np.ndarray, mu: float, u: np.ndarray) -> bool:
    """Check if (μ, u) is a tropical subeigenvector pair:
    A_{ij} + u_j ≤ μ + u_i for all admissible edges (i,j)."""
    n = A.shape[0]
    for i in range(n):
        for j in range(n):
            if A[i, j] != NEG_INF:
                if A[i, j] + u[j] > mu + u[i] + 1e-10:
                    return False
    return True


def find_subeigenvector(A: np.ndarray, mu: float) -> Optional[np.ndarray]:
    """Find a subeigenvector u for parameter μ using shortest-path relaxation.
    Returns None if μ < max cycle mean (negative cycle in Bellman-Ford)."""
    n = A.shape[0]
    # Solve: u_i ≥ A_{ij} + u_j - μ for all admissible (i,j)
    # Equivalently: u_i - u_j ≥ A_{ij} - μ
    # This is a system of difference constraints → Bellman-Ford
    u = np.zeros(n)
    for _ in range(n):
        updated = False
        for i in range(n):
            for j in range(n):
                if A[i, j] != NEG_INF:
                    needed = A[i, j] + u[j] - mu
                    if needed > u[i] + 1e-10:
                        u[i] = needed
                        updated = True
        if not updated:
            break
    else:
        # Check for negative cycle (μ too small)
        for i in range(n):
            for j in range(n):
                if A[i, j] != NEG_INF:
                    if A[i, j] + u[j] - mu > u[i] + 1e-10:
                        return None
    return u


# ─────────────────────────────────────────────────────────
# Quotient Construction
# ─────────────────────────────────────────────────────────

def quotient_matrix(A: np.ndarray, q: list) -> np.ndarray:
    """Construct the quotient tropical matrix under partition q.
    q[i] = class label for state i.
    Entry (b,c) = max over all (i,j) with q[i]=b, q[j]=c of A[i][j]."""
    classes = sorted(set(q))
    m = len(classes)
    class_idx = {c: idx for idx, c in enumerate(classes)}
    Q = np.full((m, m), NEG_INF)
    n = A.shape[0]
    for i in range(n):
        for j in range(n):
            bi = class_idx[q[i]]
            cj = class_idx[q[j]]
            Q[bi, cj] = max(Q[bi, cj], A[i, j])
    return Q


# ═════════════════════════════════════════════════════════
# DEMONSTRATIONS
# ═════════════════════════════════════════════════════════

def demo1_basic_cycle_mean():
    """Demo 1: Basic max cycle mean computation on a 3-node graph."""
    print("=" * 60)
    print("DEMO 1: Maximum Cycle Mean — 3-Node Graph")
    print("=" * 60)

    # Graph:  0 →(3)→ 1 →(1)→ 2 →(2)→ 0
    #         0 →(4)→ 2 (shortcut)
    A = np.array([
        [NEG_INF, 3, 4],
        [NEG_INF, NEG_INF, 1],
        [2, NEG_INF, NEG_INF]
    ])

    print("\nTropical transition matrix A:")
    for i in range(3):
        row = []
        for j in range(3):
            row.append("⊥" if A[i, j] == NEG_INF else f"{A[i, j]:.0f}")
        print(f"  [{', '.join(row)}]")

    mcm_enum = max_cycle_mean_enumerate(A)
    mcm_karp = karp_max_cycle_mean(A)

    print(f"\nMax cycle mean (enumeration): {mcm_enum:.4f}")
    print(f"Max cycle mean (Karp):        {mcm_karp:.4f}")

    # Show cycles
    print("\nAll simple cycles:")
    for nodes, weight, length in all_simple_cycles(A):
        mean = weight / length
        print(f"  {' → '.join(map(str, nodes))} → {nodes[0]}: "
              f"weight={weight:.0f}, length={length}, mean={mean:.4f}")

    # Verify subeigenvector
    u = find_subeigenvector(A, mcm_karp)
    if u is not None:
        print(f"\nSubeigenvector for μ={mcm_karp:.4f}: u = {u}")
        print(f"  Verified: {verify_subeigenvector(A, mcm_karp, u)}")

    print()


def demo2_quotient_invariance():
    """Demo 2: Quotient invariance of tropical semantics."""
    print("=" * 60)
    print("DEMO 2: Quotient Invariance")
    print("=" * 60)

    # 4-state system with 2 equivalence classes: {0,1} and {2,3}
    A = np.array([
        [NEG_INF, NEG_INF, 5, 5],
        [NEG_INF, NEG_INF, 5, 5],
        [3, 3, NEG_INF, NEG_INF],
        [3, 3, NEG_INF, NEG_INF]
    ])
    q = [0, 0, 1, 1]  # partition

    print("\nOriginal 4-state matrix A (states 0,1 equivalent; 2,3 equivalent):")
    for i in range(4):
        row = []
        for j in range(4):
            row.append("⊥" if A[i, j] == NEG_INF else f"{A[i, j]:.0f}")
        print(f"  [{', '.join(row)}]")

    Q = quotient_matrix(A, q)
    print(f"\nQuotient 2-state matrix Q:")
    for i in range(2):
        row = []
        for j in range(2):
            row.append("⊥" if Q[i, j] == NEG_INF else f"{Q[i, j]:.0f}")
        print(f"  [{', '.join(row)}]")

    mcm_orig = karp_max_cycle_mean(A)
    mcm_quot = karp_max_cycle_mean(Q)
    print(f"\nMax cycle mean (original):  {mcm_orig:.4f}")
    print(f"Max cycle mean (quotient):  {mcm_quot:.4f}")
    print(f"Invariant under quotient:   {abs(mcm_orig - mcm_quot) < 1e-10}")
    print()


def demo3_karp_convergence():
    """Demo 3: Convergence of normalized max path weight to cycle mean."""
    print("=" * 60)
    print("DEMO 3: Closure Pressure Convergence")
    print("=" * 60)

    A = np.array([
        [NEG_INF, 7, NEG_INF, NEG_INF],
        [NEG_INF, NEG_INF, 2, NEG_INF],
        [NEG_INF, NEG_INF, NEG_INF, 5],
        [1, NEG_INF, NEG_INF, NEG_INF]
    ])
    n = A.shape[0]

    mcm = karp_max_cycle_mean(A)
    print(f"\nMax cycle mean (tropical eigenvalue): {mcm:.4f}")
    print(f"\nNormalized max path weight convergence:")
    print(f"  {'k':>4s}  {'max_weight/k':>14s}  {'|diff|':>10s}")
    print(f"  {'─'*4}  {'─'*14}  {'─'*10}")

    Ak = np.full((n, n), NEG_INF)
    np.fill_diagonal(Ak, 0)

    for k in range(1, 21):
        Ak = trop_mat_mul(Ak, A)
        max_w = max(Ak.max(), 0)
        normalized = max_w / k if max_w > NEG_INF else 0
        diff = abs(normalized - mcm)
        print(f"  {k:4d}  {normalized:14.4f}  {diff:10.6f}")

    print()


def demo4_subeigenvector_certificate():
    """Demo 4: Collatz–Wielandt duality — subeigenvector certificates."""
    print("=" * 60)
    print("DEMO 4: Collatz–Wielandt Subeigenvector Certificates")
    print("=" * 60)

    A = np.array([
        [NEG_INF, 6, NEG_INF],
        [NEG_INF, NEG_INF, 4],
        [2, NEG_INF, NEG_INF]
    ])
    n = A.shape[0]

    mcm = karp_max_cycle_mean(A)
    print(f"\nMax cycle mean λ* = {mcm:.4f}")

    # Try various μ values
    test_mus = [mcm - 1, mcm - 0.5, mcm, mcm + 0.5, mcm + 1]
    print(f"\nSubeigenvector existence for various μ:")
    print(f"  {'μ':>8s}  {'exists?':>8s}  {'u':>24s}")
    for mu in test_mus:
        u = find_subeigenvector(A, mu)
        exists = u is not None
        u_str = str(np.round(u, 3)) if u is not None else "N/A"
        print(f"  {mu:8.4f}  {str(exists):>8s}  {u_str:>24s}")

    print(f"\n  → λ* = inf{{μ : subeigenvector exists}} = {mcm:.4f}")
    print()


def demo5_closure_operator():
    """Demo 5: From closure operator to tropical matrix and pressure."""
    print("=" * 60)
    print("DEMO 5: Closure Operator → Tropical Pressure")
    print("=" * 60)

    # Finitary closure correspondence on 3 states
    step = {
        0: [1, 2],
        1: [0, 2],
        2: [0]
    }
    weight = {
        (0, 1): 3, (0, 2): 1,
        (1, 0): 2, (1, 2): 4,
        (2, 0): 5
    }

    n = 3
    A = np.full((n, n), NEG_INF)
    for (i, j), w in weight.items():
        A[i, j] = w

    print("\nClosure operator transitions:")
    for i in range(n):
        succs = step[i]
        weights = [f"{i}→{j} (w={weight[(i,j)]})" for j in succs]
        print(f"  State {i}: {', '.join(weights)}")

    print(f"\nInduced tropical matrix:")
    for i in range(n):
        row = []
        for j in range(n):
            row.append("⊥" if A[i, j] == NEG_INF else f"{A[i, j]:.0f}")
        print(f"  [{', '.join(row)}]")

    mcm = karp_max_cycle_mean(A)
    print(f"\nClosure pressure (= tropical eigenvalue) = {mcm:.4f}")

    # Show dominant cycle
    best_cycle = None
    best_mean = NEG_INF
    for nodes, w, l in all_simple_cycles(A):
        mean = w / l
        if mean > best_mean:
            best_mean = mean
            best_cycle = nodes

    if best_cycle:
        print(f"Dominant cycle: {' → '.join(map(str, best_cycle))} → {best_cycle[0]}")
        print(f"  Mean weight: {best_mean:.4f}")

    print()


if __name__ == "__main__":
    demo1_basic_cycle_mean()
    demo2_quotient_invariance()
    demo3_karp_convergence()
    demo4_subeigenvector_certificate()
    demo5_closure_operator()

    print("=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Tropical Pressure Theory

Generates publication-quality figures illustrating:
1. Convergence of normalized path weight to tropical eigenvalue
2. Collatz–Wielandt subeigenvector landscape
3. Tropical matrix power evolution
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO

NEG_INF = float('-inf')


def karp_max_cycle_mean(A):
    n = A.shape[0]
    dp = np.full((n + 1, n), NEG_INF)
    dp[0, :] = 0
    for k in range(1, n + 1):
        for j in range(n):
            for i in range(n):
                if A[i, j] != NEG_INF and dp[k-1, i] != NEG_INF:
                    dp[k, j] = max(dp[k, j], dp[k-1, i] + A[i, j])
    result = NEG_INF
    for i in range(n):
        if dp[n, i] == NEG_INF:
            continue
        min_val = float('inf')
        for k in range(n):
            if dp[k, i] != NEG_INF:
                val = (dp[n, i] - dp[k, i]) / (n - k)
                min_val = min(min_val, val)
        if min_val != float('inf'):
            result = max(result, min_val)
    return result if result != NEG_INF else 0.0


def trop_mat_mul(A, B):
    n = A.shape[0]
    C = np.full((n, n), NEG_INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if A[i, k] != NEG_INF and B[k, j] != NEG_INF:
                    C[i, j] = max(C[i, j], A[i, k] + B[k, j])
    return C


def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


def visualization1_convergence():
    """Convergence of normalized max path weight to tropical eigenvalue."""
    A = np.array([
        [NEG_INF, 7, NEG_INF, NEG_INF],
        [NEG_INF, NEG_INF, 2, NEG_INF],
        [NEG_INF, NEG_INF, NEG_INF, 5],
        [1, NEG_INF, NEG_INF, NEG_INF]
    ])
    n = A.shape[0]
    mcm = karp_max_cycle_mean(A)

    lengths = list(range(1, 31))
    normalized = []
    Ak = np.full((n, n), NEG_INF)
    np.fill_diagonal(Ak, 0)

    for k in lengths:
        Ak = trop_mat_mul(Ak, A)
        max_w = Ak.max()
        normalized.append(max_w / k if max_w != NEG_INF else 0)

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(lengths, normalized, 'o-', color='#2196F3', markersize=5, label='Normalized max path weight')
    ax.axhline(y=mcm, color='#F44336', linestyle='--', linewidth=2, label=f'Tropical eigenvalue λ* = {mcm:.2f}')
    ax.fill_between(lengths, mcm - 0.1, mcm + 0.1, alpha=0.1, color='#F44336')
    ax.set_xlabel('Path length n', fontsize=14)
    ax.set_ylabel('Max weight / n', fontsize=14)
    ax.set_title('Closure Pressure Convergence to Tropical Eigenvalue', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(mcm - 2, max(normalized) + 1)

    fig.savefig('/workspace/request-project/viz_convergence.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def visualization2_collatz_wielandt():
    """Collatz–Wielandt: subeigenvector feasibility as function of μ."""
    A = np.array([
        [NEG_INF, 6, NEG_INF],
        [NEG_INF, NEG_INF, 4],
        [2, NEG_INF, NEG_INF]
    ])
    n = A.shape[0]
    mcm = karp_max_cycle_mean(A)

    mus = np.linspace(mcm - 2, mcm + 3, 200)
    violations = []

    for mu in mus:
        u = np.zeros(n)
        for _ in range(2 * n):
            for i in range(n):
                for j in range(n):
                    if A[i, j] != NEG_INF:
                        needed = A[i, j] + u[j] - mu
                        u[i] = max(u[i], needed)
        # Count max violation
        max_viol = 0
        for i in range(n):
            for j in range(n):
                if A[i, j] != NEG_INF:
                    viol = A[i, j] + u[j] - mu - u[i]
                    max_viol = max(max_viol, viol)
        violations.append(max_viol)

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(mus, violations, '-', color='#9C27B0', linewidth=2)
    ax.axvline(x=mcm, color='#F44336', linestyle='--', linewidth=2, label=f'λ* = {mcm:.2f}')
    ax.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)
    ax.fill_between(mus, 0, [max(0, v) for v in violations], alpha=0.15, color='#F44336', label='Infeasible region')
    ax.fill_between(mus, [min(0, v) for v in violations], 0, alpha=0.15, color='#4CAF50', label='Feasible region')
    ax.set_xlabel('Candidate eigenvalue μ', fontsize=14)
    ax.set_ylabel('Max constraint violation', fontsize=14)
    ax.set_title('Collatz–Wielandt Duality: Subeigenvector Feasibility', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    fig.savefig('/workspace/request-project/viz_collatz_wielandt.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def visualization3_tropical_power():
    """Evolution of tropical matrix power entries."""
    A = np.array([
        [NEG_INF, 3, 1],
        [2, NEG_INF, 4],
        [5, NEG_INF, NEG_INF]
    ])
    n = A.shape[0]
    mcm = karp_max_cycle_mean(A)

    max_k = 15
    diag_entries = {i: [] for i in range(n)}
    Ak = np.full((n, n), NEG_INF)
    np.fill_diagonal(Ak, 0)

    for k in range(1, max_k + 1):
        Ak = trop_mat_mul(Ak, A)
        for i in range(n):
            diag_entries[i].append(Ak[i, i] if Ak[i, i] != NEG_INF else None)

    fig, ax = plt.subplots(figsize=(10, 6))
    colors = ['#2196F3', '#F44336', '#4CAF50']
    labels_state = ['State 0', 'State 1', 'State 2']

    ks = list(range(1, max_k + 1))
    for i in range(n):
        vals = diag_entries[i]
        valid_k = [k for k, v in zip(ks, vals) if v is not None]
        valid_v = [v / k for k, v in zip(ks, vals) if v is not None]
        ax.plot(valid_k, valid_v, 'o-', color=colors[i], markersize=5, label=labels_state[i])

    ax.axhline(y=mcm, color='black', linestyle='--', linewidth=2, label=f'λ* = {mcm:.4f}')
    ax.set_xlabel('Power k', fontsize=14)
    ax.set_ylabel('A^k[i,i] / k', fontsize=14)
    ax.set_title('Tropical Matrix Power Diagonal Convergence', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    fig.savefig('/workspace/request-project/viz_tropical_power.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = visualization1_convergence()
    print(f"  viz_convergence.png generated ({len(b64_1)} chars base64)")
    b64_2 = visualization2_collatz_wielandt()
    print(f"  viz_collatz_wielandt.png generated ({len(b64_2)} chars base64)")
    b64_3 = visualization3_tropical_power()
    print(f"  viz_tropical_power.png generated ({len(b64_3)} chars base64)")
    print("Done.")
