#!/usr/bin/env python3
"""
Tropical Amortized Analysis: Core Algorithms

Implements the main algorithms from the research paper:
1. Amortized charge computation
2. Credit balance tracking
3. Optimal potential synthesis via Bellman-Ford
4. Min-plus convolution (standard and fast)
5. Bellman value iteration
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


# ============================================================
# Data Structures
# ============================================================

@dataclass
class AmortizedAnalysis:
    """Result of an amortized analysis computation."""
    costs: List[float]
    potentials: List[float]
    amortized_charges: List[float]
    credit_balance: List[float]
    total_actual: float
    total_amortized: float
    max_amortized: float
    telescoping_gap: float


@dataclass
class TransitionSystem:
    """A finite-state transition system with costs."""
    n_states: int
    weights: np.ndarray  # n x n matrix, inf for no transition
    state_names: Optional[List[str]] = None


# ============================================================
# Algorithm 1: Amortized Charge Computation
# ============================================================

def compute_amortized_analysis(
    costs: List[float],
    potentials: List[float]
) -> AmortizedAnalysis:
    """Compute complete amortized analysis given costs and potential values.
    
    Implements the potential method:
        amortized[i] = cost[i] + Φ[i+1] - Φ[i]
    
    Verifies the telescoping identity:
        sum(amortized) = sum(costs) + Φ[n] - Φ[0]
    
    Args:
        costs: Actual operation costs, length n
        potentials: Potential values at each state, length n+1
    
    Returns:
        AmortizedAnalysis with all computed quantities
    
    Time complexity: O(n)
    Space complexity: O(n)
    """
    n = len(costs)
    assert len(potentials) == n + 1, "Need n+1 potential values for n operations"
    
    # Compute amortized charges
    amortized = [costs[i] + potentials[i+1] - potentials[i] for i in range(n)]
    
    # Compute credit balance
    balance = [0.0] * (n + 1)
    for i in range(n):
        balance[i+1] = balance[i] + amortized[i] - costs[i]
    
    total_actual = sum(costs)
    total_amortized = sum(amortized)
    gap = potentials[-1] - potentials[0]
    
    # Verify telescoping (should hold exactly)
    assert abs(total_amortized - (total_actual + gap)) < 1e-10, \
        f"Telescoping identity violated: {total_amortized} != {total_actual} + {gap}"
    
    return AmortizedAnalysis(
        costs=costs,
        potentials=potentials,
        amortized_charges=amortized,
        credit_balance=balance,
        total_actual=total_actual,
        total_amortized=total_amortized,
        max_amortized=max(amortized) if amortized else 0,
        telescoping_gap=gap,
    )


# ============================================================
# Algorithm 2: Optimal Potential via Bellman-Ford
# ============================================================

def optimal_potential_bellman_ford(
    system: TransitionSystem,
    target_bound: Optional[float] = None
) -> Tuple[Optional[np.ndarray], float]:
    """Find the optimal potential function using Bellman-Ford.
    
    Solves the shortest-path problem on the constraint graph to find
    a potential Φ such that the maximum reduced cost
        max_{(s,s')} (w(s,s') + Φ(s') - Φ(s))
    is minimized.
    
    If target_bound is given, checks feasibility of amortized bound ≤ target_bound.
    Otherwise, finds the tightest achievable bound.
    
    Args:
        system: TransitionSystem with transition costs
        target_bound: Optional target amortized bound
    
    Returns:
        (potential, bound) where potential is the optimal Φ and bound
        is the tightest achievable amortized bound, or (None, inf) if infeasible.
    
    Time complexity: O(|S|² · |E|)
    Space complexity: O(|S|)
    """
    n = system.n_states
    W = system.weights
    
    # Binary search for optimal bound if not given
    if target_bound is None:
        # The optimal bound is between min and max finite edge weight
        finite_weights = W[W < float('inf')]
        if len(finite_weights) == 0:
            return np.zeros(n), 0.0
        
        lo, hi = float(finite_weights.min()), float(finite_weights.max())
        best_phi = None
        best_bound = float('inf')
        
        for _ in range(100):  # binary search iterations
            mid = (lo + hi) / 2
            phi, feasible = _check_feasibility(W, n, mid)
            if feasible:
                best_phi = phi
                best_bound = mid
                hi = mid
            else:
                lo = mid
            if hi - lo < 1e-10:
                break
        
        return best_phi, best_bound
    else:
        phi, feasible = _check_feasibility(W, n, target_bound)
        if feasible:
            return phi, target_bound
        else:
            return None, float('inf')


def _check_feasibility(
    W: np.ndarray, n: int, bound: float
) -> Tuple[Optional[np.ndarray], bool]:
    """Check if amortized bound is feasible using Bellman-Ford.
    
    Constraint: w(s,s') + Φ(s') - Φ(s) ≤ bound for all edges
    Equivalently: Φ(s) - Φ(s') ≤ bound - w(s,s')
    This is a difference constraint system, solvable by shortest paths.
    """
    INF = float('inf')
    
    # Distance from virtual source (index n) to each node
    dist = np.full(n + 1, INF)
    dist[n] = 0  # virtual source
    
    # Build edge list for constraint graph
    edges = []
    # Virtual source to all nodes (weight 0)
    for i in range(n):
        edges.append((n, i, 0.0))
    # Constraint edges: s → s' with weight bound - w(s,s')
    for s in range(n):
        for sp in range(n):
            if W[s][sp] < INF:
                # Φ(s) - Φ(s') ≤ bound - w(s,s')
                # Edge from s' to s with weight bound - w(s,s')
                edges.append((sp, s, bound - W[s][sp]))
    
    # Bellman-Ford
    for iteration in range(n + 1):
        updated = False
        for u, v, w in edges:
            if dist[u] < INF and dist[u] + w < dist[v] - 1e-12:
                dist[v] = dist[u] + w
                updated = True
        if not updated:
            break
    
    # Check for negative cycles
    for u, v, w in edges:
        if dist[u] < INF and dist[u] + w < dist[v] - 1e-12:
            return None, False  # Negative cycle = infeasible
    
    # Potential = -distance
    phi = -dist[:n]
    return phi, True


# ============================================================
# Algorithm 3: Min-Plus Convolution
# ============================================================

def tropical_convolution(f: List[float], g: List[float]) -> List[float]:
    """Compute min-plus convolution of two cost profiles.
    
    (f ⋆ g)(n) = min_{0 ≤ k ≤ n} (f(k) + g(n-k))
    
    Args:
        f: First cost profile, length m+1
        g: Second cost profile, length p+1
    
    Returns:
        Convolution result, length m+p+1
    
    Time complexity: O(m·p)
    Space complexity: O(m+p)
    """
    m = len(f) - 1
    p = len(g) - 1
    result = []
    
    for n in range(m + p + 1):
        best = float('inf')
        for k in range(max(0, n - p), min(m, n) + 1):
            best = min(best, f[k] + g[n - k])
        result.append(best)
    
    return result


def tropical_matrix_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Min-plus matrix multiplication.
    
    (A ⊗ B)[i][j] = min_k (A[i][k] + B[k][j])
    
    This is the tropical analog of standard matrix multiplication.
    Used in all-pairs shortest paths (Floyd-Warshall is repeated squaring).
    
    Time complexity: O(n³)
    """
    n = A.shape[0]
    C = np.full((n, n), float('inf'))
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] = min(C[i][j], A[i][k] + B[k][j])
    return C


# ============================================================
# Algorithm 4: Bellman Value Iteration
# ============================================================

def bellman_value_iteration(
    system: TransitionSystem,
    T: int
) -> np.ndarray:
    """Compute optimal cost-to-go via Bellman iteration.
    
    V[0][s] = 0 for all s
    V[t+1][s] = min_{s'} (w(s,s') + V[t][s'])
    
    Args:
        system: TransitionSystem with transition costs
        T: Number of time steps
    
    Returns:
        V: (T+1) x n matrix of optimal costs
    
    Time complexity: O(T · |S|²)
    Space complexity: O(T · |S|)
    """
    n = system.n_states
    V = np.zeros((T + 1, n))
    
    for t in range(T):
        for s in range(n):
            V[t+1][s] = min(
                system.weights[s][sp] + V[t][sp]
                for sp in range(n)
            )
    
    return V


# ============================================================
# Algorithm 5: Accounting-Potential Equivalence
# ============================================================

def construct_canonical_potential(
    costs: List[float],
    charges: List[float]
) -> List[float]:
    """Construct the canonical potential from prefix sums.
    
    Φ(n) = sum_{i<n} a(i) - sum_{i<n} c(i)
    
    This is the constructive witness from the accounting-potential
    equivalence theorem.
    
    Args:
        costs: Actual costs
        charges: Assigned amortized charges
    
    Returns:
        Potential values [Φ(0), Φ(1), ..., Φ(n)]
    """
    n = len(costs)
    phi = [0.0] * (n + 1)
    for i in range(n):
        phi[i+1] = phi[i] + charges[i] - costs[i]
    return phi


def verify_accounting_potential_equivalence(
    costs: List[float],
    charges: List[float]
) -> Dict:
    """Verify the accounting-potential equivalence theorem.
    
    Checks:
    1. Prefix domination: for all n, sum_{i<n} c(i) <= sum_{i<n} a(i)
    2. Canonical potential: Φ(0) = 0, Φ(n) >= 0, c(i) + ΔΦ(i) = a(i)
    """
    n = len(costs)
    phi = construct_canonical_potential(costs, charges)
    
    # Check prefix domination
    prefix_dominated = True
    for k in range(n + 1):
        if sum(costs[:k]) > sum(charges[:k]) + 1e-10:
            prefix_dominated = False
            break
    
    # Check potential properties
    phi_zero = abs(phi[0]) < 1e-10
    phi_nonneg = all(p >= -1e-10 for p in phi)
    
    # Check step identity
    step_identity = True
    for i in range(n):
        expected = charges[i]
        actual = costs[i] + phi[i+1] - phi[i]
        if abs(expected - actual) > 1e-10:
            step_identity = False
            break
    
    return {
        "prefix_dominated": prefix_dominated,
        "phi_zero_at_origin": phi_zero,
        "phi_nonneg": phi_nonneg,
        "step_identity": step_identity,
        "canonical_potential": phi,
        "equivalence_holds": prefix_dominated and phi_zero and phi_nonneg and step_identity,
    }


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Amortized Analysis: Algorithm Examples")
    print("=" * 60)
    
    # Example 1: Simple amortized analysis
    print("\n1. Amortized Analysis of Binary Counter (5 increments)")
    costs = [1, 2, 1, 4, 1]  # costs for 5 increments
    potentials = [0, 1, 1, 2, 1, 2]  # 1-bit counts
    analysis = compute_amortized_analysis(costs, potentials)
    print(f"   Costs:     {analysis.costs}")
    print(f"   Potentials: {analysis.potentials}")
    print(f"   Amortized: {analysis.amortized_charges}")
    print(f"   Credit:    {analysis.credit_balance}")
    print(f"   Total actual: {analysis.total_actual}, amortized: {analysis.total_amortized}")
    
    # Example 2: Optimal potential via Bellman-Ford
    print("\n2. Optimal Potential via Bellman-Ford")
    W = np.array([
        [2, 5, float('inf')],
        [float('inf'), 1, 3],
        [4, float('inf'), 2],
    ])
    system = TransitionSystem(3, W, ["A", "B", "C"])
    phi, bound = optimal_potential_bellman_ford(system)
    if phi is not None:
        print(f"   Optimal potential: {phi}")
        print(f"   Optimal amortized bound: {bound:.4f}")
        print("   Reduced costs:")
        for s in range(3):
            for sp in range(3):
                if W[s][sp] < float('inf'):
                    rc = W[s][sp] + phi[sp] - phi[s]
                    print(f"     {system.state_names[s]}→{system.state_names[sp]}: {rc:.4f}")
    
    # Example 3: Min-plus convolution
    print("\n3. Min-Plus Convolution")
    f = [0, 3, 5, 8]
    g = [0, 2, 7, 9]
    conv = tropical_convolution(f, g)
    print(f"   f = {f}")
    print(f"   g = {g}")
    print(f"   f ⋆ g = {conv}")
    
    # Example 4: Accounting-potential equivalence
    print("\n4. Accounting-Potential Equivalence")
    costs = [3, 1, 4, 1, 5]
    charges = [4, 2, 4, 2, 5]
    result = verify_accounting_potential_equivalence(costs, charges)
    print(f"   Costs:   {costs}")
    print(f"   Charges: {charges}")
    print(f"   Canonical potential: {result['canonical_potential']}")
    print(f"   Equivalence holds: {result['equivalence_holds']}")
    
    print("\n" + "=" * 60)
    print("All algorithm examples completed.")
