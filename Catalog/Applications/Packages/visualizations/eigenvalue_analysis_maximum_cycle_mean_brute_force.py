#!/usr/bin/env python3
"""
Tropical Spectral Dynamics — Algorithms

Implements the core algorithms from the research:
1. Maximum cycle mean computation (tropical eigenvalue)
2. Critical cycle detection with gap certification
3. Tropical entropy computation
4. Max-plus power iteration with convergence detection
5. Transient phase analysis
"""

import numpy as np
from itertools import product as iprod
from typing import List, Tuple, Optional
from dataclasses import dataclass


# ─────────────────────────────────────────────────────────────
# Data Structures
# ─────────────────────────────────────────────────────────────

@dataclass
class CycleInfo:
    """Information about a closed walk / cycle."""
    vertices: Tuple[int, ...]
    length: int
    weight: float
    mean: float


@dataclass
class CycleGapResult:
    """Result of cycle gap analysis."""
    critical_cycle: CycleInfo
    gap: float
    is_unique: bool
    all_cycles: List[CycleInfo]
    runner_up: Optional[CycleInfo]


@dataclass
class TransientAnalysis:
    """Analysis of the transient phase before periodic locking."""
    eigenvalue: float
    convergence_time: int
    growth_rates: List[float]
    entropy_per_step: List[float]


# ─────────────────────────────────────────────────────────────
# Algorithm 1: Closed Walk Weight and Mean
# ─────────────────────────────────────────────────────────────

def closed_walk_weight(A: np.ndarray, walk: Tuple[int, ...]) -> float:
    """
    Compute the weight of a closed walk in a weighted directed graph.

    The closed walk c(0) → c(1) → ... → c(k-1) → c(0) has weight
    equal to the sum of edge weights along the walk, including the
    closing edge from the last vertex back to the first.

    Time complexity: O(k) where k = len(walk)
    Space complexity: O(1)

    Args:
        A: n×n weight matrix of the directed graph
        walk: tuple of vertex indices defining the closed walk

    Returns:
        Total weight of the closed walk
    """
    k = len(walk)
    return sum(A[walk[i], walk[(i + 1) % k]] for i in range(k))


def closed_walk_mean(A: np.ndarray, walk: Tuple[int, ...]) -> float:
    """
    Compute the mean weight (cycle mean) of a closed walk.

    The cycle mean is the total weight divided by the number of edges,
    which equals the walk length. This is the key quantity for
    tropical eigenvalue computation.

    Time complexity: O(k)
    Space complexity: O(1)

    Args:
        A: n×n weight matrix
        walk: tuple of vertex indices

    Returns:
        Mean weight of the closed walk
    """
    k = len(walk)
    if k == 0:
        return 0.0
    return closed_walk_weight(A, walk) / k


# ─────────────────────────────────────────────────────────────
# Algorithm 2: Maximum Cycle Mean (Tropical Eigenvalue)
# ─────────────────────────────────────────────────────────────

def max_cycle_mean_brute(A: np.ndarray, max_length: Optional[int] = None) -> CycleGapResult:
    """
    Compute the maximum cycle mean by brute-force enumeration.

    Enumerates all closed walks of length 1 to max_length and finds
    the one with the highest mean weight. Also computes the cycle gap.

    Time complexity: O(sum_{k=1}^{L} n^k · k) where L = max_length
    Space complexity: O(n^L) for storing walks

    For small matrices (n ≤ 4, L ≤ n), this is practical.
    For larger matrices, use Karp's algorithm instead.

    Args:
        A: n×n weight matrix
        max_length: maximum walk length to consider (default: n)

    Returns:
        CycleGapResult with critical cycle, gap, and all cycles
    """
    n = A.shape[0]
    if max_length is None:
        max_length = n

    all_cycles = []
    for k in range(1, max_length + 1):
        for walk in iprod(range(n), repeat=k):
            w = closed_walk_weight(A, walk)
            m = w / k
            all_cycles.append(CycleInfo(
                vertices=walk, length=k, weight=w, mean=m
            ))

    all_cycles.sort(key=lambda c: -c.mean)
    critical = all_cycles[0]

    if len(all_cycles) > 1:
        runner_up = all_cycles[1]
        gap = critical.mean - runner_up.mean
    else:
        runner_up = None
        gap = float('inf')

    return CycleGapResult(
        critical_cycle=critical,
        gap=gap,
        is_unique=(gap > 0),
        all_cycles=all_cycles,
        runner_up=runner_up
    )


def karp_max_cycle_mean(A: np.ndarray) -> float:
    """
    Karp's algorithm for maximum cycle mean.

    Computes the tropical eigenvalue in O(n³) time and O(n²) space
    using dynamic programming on path weights.

    The algorithm computes D(k, v) = max weight of a walk of length k
    ending at vertex v, starting from a fixed source. Then:
        λ* = max_v min_k (D(n,v) - D(k,v)) / (n - k)

    Time complexity: O(n³)
    Space complexity: O(n²)

    Args:
        A: n×n weight matrix (use -inf for missing edges)

    Returns:
        Maximum cycle mean (tropical eigenvalue)
    """
    n = A.shape[0]

    # D[k][v] = max weight of walk of length k from source 0 to v
    D = np.full((n + 1, n), -np.inf)
    D[0, 0] = 0.0  # start at vertex 0

    for k in range(1, n + 1):
        for v in range(n):
            for u in range(n):
                if D[k-1, u] > -np.inf:
                    D[k, v] = max(D[k, v], D[k-1, u] + A[u, v])

    # Karp's formula
    lambda_star = -np.inf
    for v in range(n):
        if D[n, v] > -np.inf:
            min_ratio = np.inf
            for k in range(n):
                if D[k, v] > -np.inf:
                    ratio = (D[n, v] - D[k, v]) / (n - k)
                    min_ratio = min(min_ratio, ratio)
            if min_ratio < np.inf:
                lambda_star = max(lambda_star, min_ratio)

    return lambda_star


# ─────────────────────────────────────────────────────────────
# Algorithm 3: Tropical Entropy
# ─────────────────────────────────────────────────────────────

def tropical_entropy(probs: np.ndarray) -> float:
    """
    Compute the tropical entropy H_⊕(p) = -log(min p).

    The tropical entropy measures worst-case search complexity:
    exp(H_⊕) = 1/min(p) is the number of trials needed in the
    worst case to find the element with minimum probability.

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        probs: array of positive probabilities summing to 1

    Returns:
        Tropical entropy value

    Raises:
        ValueError: if any probability is non-positive
    """
    if np.any(probs <= 0):
        raise ValueError("All probabilities must be positive")
    return -np.log(np.min(probs))


def tropical_kl_divergence(p: np.ndarray, q: np.ndarray) -> float:
    """
    Tropical KL divergence: D_⊕(p || q) = max_x log(p(x)/q(x)).

    Time complexity: O(n)
    Space complexity: O(1)
    """
    if np.any(q <= 0):
        raise ValueError("q must be strictly positive")
    return np.max(np.log(p / q))


# ─────────────────────────────────────────────────────────────
# Algorithm 4: Max-Plus Matrix Operations
# ─────────────────────────────────────────────────────────────

def maxplus_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Max-plus matrix product: C[i,j] = max_k(A[i,k] + B[k,j]).

    This is the tropical semiring multiplication, where addition
    is replaced by max and multiplication by +.

    Time complexity: O(n³)
    Space complexity: O(n²)
    """
    n = A.shape[0]
    C = np.full((n, n), -np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = max(C[i, j], A[i, k] + B[k, j])
    return C


def maxplus_mulvec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Max-plus matrix-vector product: y[i] = max_j(A[i,j] + x[j]).

    Time complexity: O(n²)
    Space complexity: O(n)
    """
    n = A.shape[0]
    return np.array([max(A[i, j] + x[j] for j in range(n)) for i in range(n)])


def maxplus_power(A: np.ndarray, t: int) -> np.ndarray:
    """
    Compute A^⊗t (t-fold max-plus product).

    Time complexity: O(n³ · t)
    Space complexity: O(n²)
    """
    n = A.shape[0]
    result = np.zeros((n, n))  # identity in max-plus: 0 on diagonal, -inf elsewhere
    for i in range(n):
        for j in range(n):
            result[i, j] = 0.0 if i == j else -np.inf
    for _ in range(t):
        result = maxplus_mul(result, A)
    return result


# ─────────────────────────────────────────────────────────────
# Algorithm 5: Transient Phase Analysis
# ─────────────────────────────────────────────────────────────

def analyze_transient(A: np.ndarray, x0: Optional[np.ndarray] = None,
                      max_iter: int = 50, tol: float = 1e-10) -> TransientAnalysis:
    """
    Analyze the transient phase of max-plus power iteration.

    Starting from x₀, iterates x_{t+1} = A ⊗ x_t and tracks:
    - Growth rate: max_i(x_{t+1}(i) - x_t(i)) ≈ λ* for large t
    - Entropy: tropical entropy of the normalized growth distribution
    - Convergence time: first t where growth rate stabilizes

    Time complexity: O(n² · max_iter)
    Space complexity: O(n · max_iter)

    Args:
        A: n×n weight matrix
        x0: initial vector (default: zero vector)
        max_iter: maximum number of iterations
        tol: convergence tolerance

    Returns:
        TransientAnalysis with eigenvalue, convergence time, etc.
    """
    n = A.shape[0]
    if x0 is None:
        x0 = np.zeros(n)

    x = x0.copy()
    growth_rates = []
    entropy_per_step = []

    for t in range(max_iter):
        x_new = maxplus_mulvec(A, x)
        diffs = x_new - x

        growth = np.max(diffs)
        growth_rates.append(growth)

        # Normalize diffs to a probability distribution for entropy
        if np.max(diffs) > np.min(diffs):
            shifted = diffs - np.min(diffs) + 1e-10
            probs = shifted / np.sum(shifted)
            entropy_per_step.append(tropical_entropy(probs))
        else:
            entropy_per_step.append(0.0)

        x = x_new

    # Detect convergence
    convergence_time = max_iter
    for t in range(1, len(growth_rates)):
        if abs(growth_rates[t] - growth_rates[t-1]) < tol:
            convergence_time = t
            break

    return TransientAnalysis(
        eigenvalue=growth_rates[-1] if growth_rates else 0.0,
        convergence_time=convergence_time,
        growth_rates=growth_rates,
        entropy_per_step=entropy_per_step
    )


# ─────────────────────────────────────────────────────────────
# Algorithm 6: Cycle Gap Certification
# ─────────────────────────────────────────────────────────────

def certify_cycle_gap(A: np.ndarray, max_walk_length: Optional[int] = None) -> dict:
    """
    Certify the cycle gap of a tropical matrix.

    Computes the critical cycle, the cycle gap, and produces a
    certificate that can be checked: the gap value ε such that
    all non-critical cycles have mean weight ≤ critical mean - ε.

    Time complexity: O(sum_{k=1}^{L} n^k · k)
    Space complexity: O(total number of walks)

    Args:
        A: n×n weight matrix
        max_walk_length: max walk length to consider

    Returns:
        Dictionary with certification data
    """
    result = max_cycle_mean_brute(A, max_walk_length)

    certificate = {
        'matrix_size': A.shape[0],
        'critical_cycle': result.critical_cycle,
        'critical_mean': result.critical_cycle.mean,
        'gap': result.gap,
        'is_unique': result.is_unique,
        'num_cycles_checked': len(result.all_cycles),
        'runner_up': result.runner_up,
    }

    if result.is_unique:
        certificate['certificate_valid'] = True
        certificate['certificate_statement'] = (
            f"All non-critical cycles have mean weight ≤ "
            f"{result.critical_cycle.mean:.6f} - {result.gap:.6f} = "
            f"{result.critical_cycle.mean - result.gap:.6f}"
        )
    else:
        certificate['certificate_valid'] = False
        certificate['certificate_statement'] = (
            "Multiple cycles achieve the maximum mean weight; "
            "no strict gap exists."
        )

    return certificate


# ─────────────────────────────────────────────────────────────
# Main: Run all algorithms on example matrices
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("TROPICAL SPECTRAL DYNAMICS — ALGORITHM DEMONSTRATIONS")
    print("=" * 70)

    # Example 1: 3×3 matrix with unique critical cycle
    A1 = np.array([
        [5.0, 1.0, 2.0],
        [3.0, 7.0, 1.0],
        [2.0, 4.0, 3.0]
    ])
    print("\n--- Example 1: 3×3 Matrix ---")
    print(f"A = \n{A1}")

    # Karp's algorithm
    lambda_karp = karp_max_cycle_mean(A1)
    print(f"\nKarp's algorithm: λ* = {lambda_karp:.4f}")

    # Brute force with certification
    cert = certify_cycle_gap(A1)
    print(f"Brute force: λ* = {cert['critical_mean']:.4f}")
    print(f"Critical cycle: {cert['critical_cycle'].vertices}")
    print(f"Cycle gap: {cert['gap']:.4f}")
    print(f"Unique: {cert['is_unique']}")
    print(f"Certificate: {cert['certificate_statement']}")

    # Transient analysis
    ta = analyze_transient(A1, max_iter=15)
    print(f"\nTransient analysis:")
    print(f"  Convergence time: {ta.convergence_time}")
    print(f"  Final growth rate: {ta.eigenvalue:.4f}")
    print(f"  Growth rates: {[f'{g:.3f}' for g in ta.growth_rates[:8]]}")

    # Example 2: 2×2 with large cycle gap
    A2 = np.array([
        [1.0, 10.0],
        [10.0, 1.0]
    ])
    print("\n\n--- Example 2: 2×2 Matrix with Cycle Structure ---")
    print(f"A = \n{A2}")

    cert2 = certify_cycle_gap(A2)
    print(f"Critical cycle: {cert2['critical_cycle'].vertices} "
          f"(mean = {cert2['critical_mean']:.4f})")
    print(f"Gap: {cert2['gap']:.4f}, Unique: {cert2['is_unique']}")

    ta2 = analyze_transient(A2, max_iter=10)
    print(f"Eigenvalue: {ta2.eigenvalue:.4f}")
    print(f"Convergence: step {ta2.convergence_time}")

    # Example 3: Entropy comparison
    print("\n\n--- Entropy Comparison ---")
    sizes = [2, 3, 5, 10, 100]
    for s in sizes:
        p_unif = np.ones(s) / s
        H = tropical_entropy(p_unif)
        print(f"  Uniform on {s:3d} elements: H_⊕ = {H:.4f} "
              f"(= log {s} = {np.log(s):.4f}), "
              f"search complexity = {np.exp(H):.1f}")

    print("\n" + "=" * 70)
    print("All algorithm demonstrations complete.")
    print("=" * 70)
