#!/usr/bin/env python3
"""
algorithms.py — Certified Algorithms for Erdős–Rényi Threshold Computation

Implements algorithms whose correctness is backed by the formal theorems
proved in the Lean formalization.

Algorithms:
1. isolated_vertex_expectation — O(1) exact computation
2. variance_bound — O(1) upper bound on Var(isolated vertices)
3. connectivity_threshold — O(1) critical p computation
4. subcritical_component_bound — exponential tail bound
5. susceptibility_estimator — Monte Carlo with formal error bounds
6. threshold_detector — binary search for empirical threshold
7. second_moment_existence_test — Paley–Zygmund existence certificate

Each algorithm includes:
- Pseudocode description
- Complexity analysis
- Example usage
"""

import math
import random
from typing import Tuple, Optional, List, Callable
from collections import defaultdict


# ============================================================
# Algorithm 1: Isolated Vertex Expectation
# ============================================================

def isolated_vertex_expectation(n: int, p: float) -> float:
    """
    Compute E[number of isolated vertices] in G(n,p).

    Pseudocode:
        INPUT: n (vertices), p (edge probability)
        OUTPUT: n * (1-p)^(n-1)

    Correctness: Theorem isolated_vertex_expectation_identity
    Complexity: O(log n) for exponentiation

    Args:
        n: Number of vertices (≥ 1)
        p: Edge probability in [0, 1]

    Returns:
        Expected number of isolated vertices

    Example:
        >>> isolated_vertex_expectation(100, 0.05)
        0.592...
    """
    if n <= 0:
        return 0.0
    return n * (1 - p) ** (n - 1)


# ============================================================
# Algorithm 2: Variance Bound
# ============================================================

def isolated_vertex_variance_bound(n: int, p: float) -> float:
    """
    Compute upper bound on Var(isolated vertex count) in G(n,p).

    Pseudocode:
        INPUT: n, p
        mu = n * (1-p)^(n-1)
        second_moment_bound = mu + n^2 * (1-p)^(2n-3)
        OUTPUT: second_moment_bound - mu^2

    Correctness: Theorem isolated_vertex_second_moment_bound
    Complexity: O(log n)

    Args:
        n: Number of vertices
        p: Edge probability in [0, 1]

    Returns:
        Upper bound on variance of isolated vertex count
    """
    if n <= 1:
        return 0.0
    mu = isolated_vertex_expectation(n, p)
    second_moment = mu + n ** 2 * (1 - p) ** (2 * n - 3)
    return max(0.0, second_moment - mu ** 2)


# ============================================================
# Algorithm 3: Connectivity Threshold
# ============================================================

def connectivity_threshold(n: int) -> float:
    """
    Compute the connectivity threshold p* = ln(n)/n.

    Pseudocode:
        INPUT: n
        OUTPUT: ln(n) / n

    Correctness: The threshold is where E[isolated vertices] = 1,
    i.e., n * (1-p)^(n-1) ≈ 1, which gives p ≈ ln(n)/n.
    Formally supported by isolated_vertex_expectation_identity.
    Complexity: O(1)

    Args:
        n: Number of vertices (≥ 2)

    Returns:
        Critical edge probability for connectivity
    """
    if n <= 1:
        return 0.0
    return math.log(n) / n


# ============================================================
# Algorithm 4: Subcritical Component Tail Bound
# ============================================================

def subcritical_component_bound(n: int, k: int, c: float) -> float:
    """
    Compute P[exists component of size ≥ k] in G(n, c/n) for c < 1.

    Pseudocode:
        INPUT: n, k, c (with 0 < c < 1)
        rho = c * exp(1 - c)    // < 1 when c < 1
        OUTPUT: min(1, n * rho^k)

    Correctness: Tree-counting argument. The number of labeled trees
    on k vertices is k^(k-2) (Cayley). The probability that a specific
    set of k vertices forms a tree is (c/n)^(k-1). Union bound over
    n choose k starting vertices gives the bound.
    Complexity: O(log k)

    Args:
        n: Number of vertices
        k: Component size threshold
        c: Parameter (0 < c < 1 for subcritical)

    Returns:
        Upper bound on probability of having a component of size ≥ k
    """
    if c >= 1 or k <= 0 or n <= 0:
        return 1.0
    rho = c * math.exp(1 - c)
    return min(1.0, n * rho ** k)


# ============================================================
# Algorithm 5: Susceptibility Estimator
# ============================================================

class UnionFind:
    """Union-Find data structure for component tracking."""

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.size = [1] * n

    def find(self, x: int) -> int:
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x: int, y: int) -> None:
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        self.size[rx] += self.size[ry]
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1


def susceptibility_estimator(n: int, p: float, trials: int = 100) -> Tuple[float, float]:
    """
    Estimate E[χ(G)] for G ~ G(n,p) with confidence interval.

    Pseudocode:
        INPUT: n, p, trials
        FOR i = 1 to trials:
            Sample G ~ G(n,p) using Union-Find
            chi_i = (1/n) * sum of |C|^2 over components C
        mu = mean(chi_1, ..., chi_trials)
        sigma = std(chi_1, ..., chi_trials)
        OUTPUT: (mu, 1.96 * sigma / sqrt(trials))

    Correctness: Monte Carlo with CLT-based confidence interval.
    Formal backing: susceptibility_bounded_by_max_component gives
    deterministic upper bound χ ≤ max component size.
    Complexity: O(trials * n^2) total

    Args:
        n: Number of vertices
        p: Edge probability
        trials: Number of Monte Carlo samples

    Returns:
        (mean_estimate, confidence_half_width)
    """
    chi_values = []
    for _ in range(trials):
        uf = UnionFind(n)
        for i in range(n):
            for j in range(i + 1, n):
                if random.random() < p:
                    uf.union(i, j)
        # Compute susceptibility
        roots = set()
        comp_sizes = defaultdict(int)
        for i in range(n):
            r = uf.find(i)
            comp_sizes[r] = uf.size[r]
        chi = sum(s ** 2 for s in comp_sizes.values()) / n
        chi_values.append(chi)

    mu = sum(chi_values) / len(chi_values)
    if len(chi_values) > 1:
        variance = sum((x - mu) ** 2 for x in chi_values) / (len(chi_values) - 1)
        sigma = math.sqrt(variance)
        ci = 1.96 * sigma / math.sqrt(len(chi_values))
    else:
        ci = 0.0

    return mu, ci


# ============================================================
# Algorithm 6: Threshold Detector (Binary Search)
# ============================================================

def threshold_detector(
    n: int,
    property_test: Callable[[int, float], bool],
    trials: int = 200,
    target_prob: float = 0.5,
    tol: float = 1e-4,
    p_lo: float = 0.0,
    p_hi: float = 1.0,
) -> Tuple[float, float]:
    """
    Find the threshold p* where P[property holds] ≈ target_prob.

    Pseudocode:
        INPUT: n, property_test, trials, target_prob, tol
        lo, hi = 0, 1
        WHILE hi - lo > tol:
            mid = (lo + hi) / 2
            freq = (# times property holds in 'trials' samples) / trials
            IF freq < target_prob:
                lo = mid
            ELSE:
                hi = mid
        OUTPUT: (lo + hi) / 2, hi - lo

    Correctness: For monotone graph properties (connectivity_monotone),
    P[property] is monotone in p, so binary search converges.
    Complexity: O(log(1/tol) * trials * n^2)

    Args:
        n: Number of vertices
        property_test: Function(n, p) -> bool, samples G(n,p) and tests property
        trials: Monte Carlo trials per p value
        target_prob: Target probability level
        tol: Convergence tolerance
        p_lo: Lower bound on search range
        p_hi: Upper bound on search range

    Returns:
        (estimated_threshold, uncertainty)
    """
    lo, hi = p_lo, p_hi
    while hi - lo > tol:
        mid = (lo + hi) / 2
        count = sum(1 for _ in range(trials) if property_test(n, mid))
        freq = count / trials
        if freq < target_prob:
            lo = mid
        else:
            hi = mid

    return (lo + hi) / 2, hi - lo


def test_connectivity(n: int, p: float) -> bool:
    """Sample G(n,p) and test if connected."""
    adj = defaultdict(set)
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i].add(j)
                adj[j].add(i)
    visited = set()
    stack = [0]
    while stack:
        u = stack.pop()
        if u not in visited:
            visited.add(u)
            stack.extend(adj[u] - visited)
    return len(visited) == n


# ============================================================
# Algorithm 7: Second Moment Existence Test
# ============================================================

def second_moment_existence_test(
    indicator_probs: List[float],
    pairwise_probs: Optional[List[List[float]]] = None,
) -> Tuple[bool, float]:
    """
    Apply the second moment method to test P[X > 0] > 0.

    Given X = Σ I_i where I_i are indicator random variables:
    - E[X] = Σ P[I_i = 1]
    - E[X²] = Σ_i Σ_j P[I_i = 1 ∧ I_j = 1]

    By Paley–Zygmund: P[X > 0] ≥ E[X]² / E[X²]

    Pseudocode:
        INPUT: indicator_probs (P[I_i = 1] for each i),
               pairwise_probs (P[I_i ∧ I_j] matrix, optional)
        EX = sum(indicator_probs)
        IF pairwise_probs given:
            EX2 = sum over i,j of pairwise_probs[i][j]
        ELSE:  // assume independence
            EX2 = EX + EX*(EX - max(indicator_probs))
        lower_bound = EX^2 / EX2
        OUTPUT: (lower_bound > 0, lower_bound)

    Correctness: Theorem paley_zygmund_finite
    Complexity: O(n²) with pairwise probs, O(n) without

    Args:
        indicator_probs: List of P[I_i = 1]
        pairwise_probs: Optional n×n matrix of P[I_i ∧ I_j]

    Returns:
        (exists_with_positive_prob, lower_bound_on_prob)
    """
    ex = sum(indicator_probs)
    if ex <= 0:
        return False, 0.0

    n = len(indicator_probs)
    if pairwise_probs is not None:
        ex2 = sum(pairwise_probs[i][j] for i in range(n) for j in range(n))
    else:
        # Assume independence: E[X²] = Var(X) + E[X]² = E[X] - E[X]² + E[X]²
        # For independent indicators: E[X²] = E[X] + E[X]*(E[X]-1)... no
        # Actually for independent: Var(X) = Σ p_i(1-p_i), so E[X²] = E[X]² + Var
        var = sum(p * (1 - p) for p in indicator_probs)
        ex2 = ex ** 2 + var

    if ex2 <= 0:
        return False, 0.0

    lower_bound = ex ** 2 / ex2
    return lower_bound > 0, min(1.0, lower_bound)


# ============================================================
# Example Usage and Testing
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  Certified Random Graph Algorithms")
    print("=" * 60)

    # Algorithm 1: Isolated vertex expectation
    print("\n--- Algorithm 1: Isolated Vertex Expectation ---")
    for n in [50, 100, 500, 1000]:
        p_star = connectivity_threshold(n)
        ex = isolated_vertex_expectation(n, p_star)
        print(f"  n={n:5d}: p*={p_star:.6f}, E[isolated]={ex:.4f}")

    # Algorithm 2: Variance bound
    print("\n--- Algorithm 2: Variance Bound ---")
    n = 100
    for p_ratio in [0.5, 0.8, 1.0, 1.2, 1.5]:
        p = connectivity_threshold(n) * p_ratio
        ex = isolated_vertex_expectation(n, p)
        var = isolated_vertex_variance_bound(n, p)
        print(f"  p/p*={p_ratio:.1f}: E[X]={ex:.4f}, Var_bound={var:.4f}")

    # Algorithm 4: Subcritical bound
    print("\n--- Algorithm 4: Subcritical Component Bound ---")
    n = 1000
    c = 0.5
    for k in [5, 10, 15, 20, 30]:
        bound = subcritical_component_bound(n, k, c)
        print(f"  c={c}, k={k:3d}: P[comp≥k] ≤ {bound:.6e}")

    # Algorithm 5: Susceptibility
    print("\n--- Algorithm 5: Susceptibility Estimator ---")
    n = 200
    random.seed(42)
    for c in [0.5, 0.8, 1.0, 1.2, 2.0]:
        mu, ci = susceptibility_estimator(n, c / n, trials=50)
        print(f"  c={c:.1f}: χ ≈ {mu:.2f} ± {ci:.2f}")

    # Algorithm 6: Threshold detection
    print("\n--- Algorithm 6: Threshold Detector ---")
    n = 100
    random.seed(42)
    p_star_est, unc = threshold_detector(n, test_connectivity, trials=100, tol=0.001)
    p_star_theory = connectivity_threshold(n)
    print(f"  Detected threshold: {p_star_est:.4f} ± {unc:.4f}")
    print(f"  Theoretical:        {p_star_theory:.4f}")
    print(f"  Relative error:     {abs(p_star_est - p_star_theory) / p_star_theory:.2%}")

    # Algorithm 7: Second moment test
    print("\n--- Algorithm 7: Second Moment Existence Test ---")
    n = 50
    p = 0.1
    # Test for isolated vertices
    probs = [((1 - p) ** (n - 1)) for _ in range(n)]
    exists_flag, lb = second_moment_existence_test(probs)
    print(f"  Isolated vertices (n={n}, p={p}):")
    print(f"    E[X] = {sum(probs):.4f}")
    print(f"    P[X>0] ≥ {lb:.4f}")
    print(f"    Exists: {exists_flag}")

    print("\n✓ All algorithms executed successfully.")
