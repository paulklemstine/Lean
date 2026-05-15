#!/usr/bin/env python3
"""
Algorithms for Tropical Horizon Stability on Weighted Graphs

Implements the core computational algorithms from the research paper:
1. Min-cut horizon computation (exact, for small graphs)
2. Perturbation stability certification
3. Einstein-Maxwell effective weight computation
4. Horizon gap estimation
5. Microstate enumeration and entropy computation

All algorithms include complexity analysis and type annotations.
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Set, Dict, Optional
from dataclasses import dataclass
import heapq


@dataclass
class HorizonResult:
    """Result of a horizon computation."""
    value: float
    minimizer: Set[int]
    all_cut_weights: Dict[frozenset, float]
    gap: float
    num_microstates: int
    entropy_bits: float


@dataclass 
class StabilityCertificate:
    """Certificate of combinatorial stability."""
    is_stable: bool
    epsilon_threshold: float
    lipschitz_constant: float
    gap: float
    message: str


def compute_cut_weight(W: np.ndarray, S: Set[int]) -> float:
    """
    Compute the cut weight of vertex subset S.
    
    The cut weight is defined as:
        cutWeight(w, S) = Σ_{i ∈ S, j ∉ S} w(i,j)
    
    Parameters:
        W: n×n weight matrix (W[i,j] = weight of edge i→j)
        S: subset of vertices {0, ..., n-1}
    
    Returns:
        The cut weight (sum of edges crossing from S to V\S)
    
    Time complexity: O(n²)
    Space complexity: O(1)
    """
    n = W.shape[0]
    V = set(range(n))
    complement = V - S
    return sum(W[i, j] for i in S for j in complement)


def enumerate_separating_cuts(n: int, s: int, t: int) -> List[Set[int]]:
    """
    Enumerate all subsets S ⊆ V with s ∈ S and t ∉ S.
    
    These are the "separating cuts" in the tropical horizon framework.
    
    Parameters:
        n: number of vertices
        s: source terminal
        t: sink terminal
    
    Returns:
        List of all separating cuts
    
    Time complexity: O(2^(n-2)) — exponential in vertices minus terminals
    Space complexity: O(2^(n-2) · n)
    """
    others = [v for v in range(n) if v != s and v != t]
    cuts = []
    for r in range(len(others) + 1):
        for combo in combinations(others, r):
            cuts.append({s} | set(combo))
    return cuts


def compute_horizon(W: np.ndarray, s: int, t: int) -> HorizonResult:
    """
    Compute the tropical horizon: minimum cut value, minimizer, gap, and entropy.
    
    This is the main algorithm. For a graph with n vertices, it:
    1. Enumerates all 2^(n-2) separating cuts
    2. Computes cut weight for each
    3. Identifies the minimum (horizon value)
    4. Computes the gap to the second-best cut
    5. Counts microstates and computes entropy
    
    Parameters:
        W: n×n weight matrix
        s: source terminal (s ∈ S for all cuts)
        t: sink terminal (t ∉ S for all cuts)
    
    Returns:
        HorizonResult with all computed quantities
    
    Time complexity: O(2^n · n²)
    Space complexity: O(2^n)
    
    Note: This is exact but exponential. For large graphs, use
    max-flow/min-cut algorithms (e.g., Ford-Fulkerson) instead.
    """
    n = W.shape[0]
    cuts = enumerate_separating_cuts(n, s, t)
    
    # Compute all cut weights
    cut_weights = {}
    for S in cuts:
        key = frozenset(S)
        cut_weights[key] = compute_cut_weight(W, S)
    
    # Find minimum
    sorted_items = sorted(cut_weights.items(), key=lambda x: x[1])
    min_key, min_val = sorted_items[0]
    
    # Compute gap
    if len(sorted_items) >= 2:
        gap = sorted_items[1][1] - sorted_items[0][1]
    else:
        gap = 0.0
    
    # Entropy
    num_microstates = len(cuts)
    entropy = np.log2(num_microstates) if num_microstates > 0 else 0.0
    
    return HorizonResult(
        value=min_val,
        minimizer=set(min_key),
        all_cut_weights=cut_weights,
        gap=gap,
        num_microstates=num_microstates,
        entropy_bits=entropy
    )


def certify_stability(
    W: np.ndarray, s: int, t: int, epsilon: float
) -> StabilityCertificate:
    """
    Certify whether the horizon minimizer is stable under ε-perturbation.
    
    Uses the gap-based stability theorem:
        If 2 · C · ε < δ (the gap), then the minimizer is preserved.
    
    Parameters:
        W: weight matrix
        s, t: terminals
        epsilon: perturbation bound
    
    Returns:
        StabilityCertificate with stability status and threshold
    
    Time complexity: O(2^n · n²) (dominated by horizon computation)
    """
    n = W.shape[0]
    C = n ** 2  # Lipschitz constant
    
    result = compute_horizon(W, s, t)
    gap = result.gap
    threshold = gap / (2 * C) if C > 0 else float('inf')
    
    is_stable = 2 * C * epsilon < gap
    
    if is_stable:
        msg = (f"STABLE: ε={epsilon:.6f} < threshold={threshold:.6f}. "
               f"Minimizer {sorted(result.minimizer)} is preserved.")
    else:
        msg = (f"UNSTABLE: ε={epsilon:.6f} ≥ threshold={threshold:.6f}. "
               f"Minimizer may change.")
    
    return StabilityCertificate(
        is_stable=is_stable,
        epsilon_threshold=threshold,
        lipschitz_constant=C,
        gap=gap,
        message=msg
    )


def einstein_maxwell_effective_weight(
    g: np.ndarray, A: np.ndarray, lam: float
) -> np.ndarray:
    """
    Compute the Einstein-Maxwell effective weight matrix.
    
    W_eff[i,j] = g[i,j] + λ · |A[i,j]|
    
    Parameters:
        g: gravitational/metric weight matrix
        A: gauge potential matrix
        lam: coupling constant (λ ≥ 0)
    
    Returns:
        Effective weight matrix
    
    Time complexity: O(n²)
    """
    return g + lam * np.abs(A)


def einstein_maxwell_stability_bound(
    n: int, eps_g: float, eps_A: float, lam: float
) -> float:
    """
    Compute the Lipschitz bound for Einstein-Maxwell horizon perturbation.
    
    |H(g₁,A₁) - H(g₂,A₂)| ≤ |V|² · (εg + λ · εA)
    
    Parameters:
        n: number of vertices
        eps_g: max perturbation of g
        eps_A: max perturbation of A
        lam: coupling constant
    
    Returns:
        Upper bound on horizon value change
    """
    C = n ** 2
    return C * (eps_g + lam * eps_A)


def perturbation_scan(
    W: np.ndarray, s: int, t: int,
    epsilons: np.ndarray,
    num_trials: int = 50,
    seed: int = 42
) -> Dict[str, np.ndarray]:
    """
    Scan perturbation magnitudes and compute statistics.
    
    For each epsilon value, generates random perturbations and tracks:
    - Mean and max horizon value change
    - Fraction of trials where minimizer changes
    - Theoretical Lipschitz bound
    
    Parameters:
        W: base weight matrix
        s, t: terminals
        epsilons: array of epsilon values to scan
        num_trials: number of random trials per epsilon
        seed: random seed for reproducibility
    
    Returns:
        Dictionary with arrays of statistics
    
    Time complexity: O(|epsilons| · num_trials · 2^n · n²)
    """
    n = W.shape[0]
    C = n ** 2
    base_result = compute_horizon(W, s, t)
    
    mean_diffs = []
    max_diffs = []
    change_fracs = []
    bounds = []
    
    for eps in epsilons:
        diffs = []
        changes = 0
        for trial in range(num_trials):
            rng = np.random.RandomState(seed + trial + int(eps * 10000))
            P = rng.uniform(-eps, eps, (n, n))
            P = (P + P.T) / 2
            np.fill_diagonal(P, 0)
            
            W2 = W + P
            result2 = compute_horizon(W2, s, t)
            diffs.append(abs(base_result.value - result2.value))
            if result2.minimizer != base_result.minimizer:
                changes += 1
        
        mean_diffs.append(np.mean(diffs))
        max_diffs.append(np.max(diffs))
        change_fracs.append(changes / num_trials)
        bounds.append(C * eps)
    
    return {
        'epsilons': epsilons,
        'mean_diffs': np.array(mean_diffs),
        'max_diffs': np.array(max_diffs),
        'change_fracs': np.array(change_fracs),
        'bounds': np.array(bounds),
        'gap': base_result.gap,
        'threshold': base_result.gap / (2 * C) if C > 0 else float('inf')
    }


def horizon_entropy_bound(n: int) -> float:
    """
    Compute the maximum entropy of horizon microstates for n vertices.
    
    Since the number of separating cuts ≤ 2^n, the entropy satisfies:
        H ≤ log₂(2^n) = n bits
    
    This is the discrete Bekenstein-Hawking bound.
    
    Parameters:
        n: number of vertices
    
    Returns:
        Maximum entropy in bits
    """
    return float(n)


if __name__ == "__main__":
    # Example usage
    print("=== Horizon Computation Example ===\n")
    
    W = np.array([
        [0, 2, 5, 8],
        [2, 0, 3, 6],
        [5, 3, 0, 2],
        [8, 6, 2, 0]
    ], dtype=float)
    
    result = compute_horizon(W, 0, 3)
    print(f"Horizon value: {result.value}")
    print(f"Minimizer: {sorted(result.minimizer)}")
    print(f"Gap: {result.gap}")
    print(f"Microstates: {result.num_microstates}")
    print(f"Entropy: {result.entropy_bits:.2f} bits")
    
    print("\n=== Stability Certification ===\n")
    cert = certify_stability(W, 0, 3, 0.1)
    print(cert.message)
    
    print("\n=== Einstein-Maxwell Example ===\n")
    g = W.copy()
    A = np.array([
        [0, 1, -1, 2],
        [-1, 0, 1, -1],
        [1, -1, 0, 1],
        [-2, 1, -1, 0]
    ], dtype=float)
    
    W_eff = einstein_maxwell_effective_weight(g, A, lam=0.5)
    result_em = compute_horizon(W_eff, 0, 3)
    print(f"Effective horizon value: {result_em.value}")
    print(f"Bound for εg=0.1, εA=0.2, λ=0.5: "
          f"{einstein_maxwell_stability_bound(4, 0.1, 0.2, 0.5)}")
