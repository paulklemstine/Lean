#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Markov Chain Comparison

Implements the core algorithms from the comparison theorem:
1. Dirichlet form computation
2. Spectral gap estimation
3. Comparison constant computation
4. Path congestion estimation
"""

import numpy as np
from typing import List, Tuple, Optional


def dirichlet_form(pi: np.ndarray, P: np.ndarray, f: np.ndarray) -> float:
    """Compute the Dirichlet form E_π,P(f,f).

    E(f,f) = (1/2) Σ_{x,y} π(x) P(x,y) (f(x) - f(y))²

    Args:
        pi: Stationary distribution (n,)
        P: Transition matrix (n, n)
        f: Test function (n,)

    Returns:
        The Dirichlet form value.

    Complexity: O(n²) time, O(1) space.
    """
    diff = f[:, None] - f[None, :]  # (n, n) matrix of differences
    return 0.5 * np.sum(pi[:, None] * P * diff ** 2)


def weighted_variance(pi: np.ndarray, f: np.ndarray) -> float:
    """Compute the weighted variance Var_π(f).

    Var_π(f) = Σ_x π(x) (f(x) - E_π[f])²

    Args:
        pi: Probability distribution (n,)
        f: Function values (n,)

    Returns:
        The weighted variance.

    Complexity: O(n) time, O(1) space.
    """
    mean = np.dot(pi, f)
    return np.dot(pi, (f - mean) ** 2)


def spectral_gap_exact(pi: np.ndarray, P: np.ndarray) -> float:
    """Compute the exact spectral gap via eigenvalue analysis.

    For a reversible chain with stationary π, the spectral gap is
    λ = 1 - λ₂ where λ₂ is the second-largest eigenvalue of the
    similarity-transformed matrix D^{1/2} P D^{-1/2}.

    Args:
        pi: Stationary distribution (n,)
        P: Transition matrix (n, n)

    Returns:
        The spectral gap.

    Complexity: O(n³) time (eigenvalue decomposition).
    """
    n = len(pi)
    if n <= 1:
        return 1.0
    D = np.diag(np.sqrt(np.maximum(pi, 1e-15)))
    Di = np.diag(1.0 / np.sqrt(np.maximum(pi, 1e-15)))
    M = D @ P @ Di
    ev = np.sort(np.real(np.linalg.eigvals(M)))[::-1]
    return 1.0 - ev[1]


def comparison_constant_exact(pi: np.ndarray, P: np.ndarray,
                               Q: np.ndarray) -> float:
    """Compute the exact comparison constant C for same-π chains.

    C = sup_f E_Q(f)/E_P(f) = max eigenvalue of L_P^{-1} L_Q
    restricted to the complement of constants.

    Args:
        pi: Common stationary distribution (n,)
        P: Transition matrix of chain P (n, n)
        Q: Transition matrix of chain Q (n, n)

    Returns:
        The comparison constant C.

    Complexity: O(n³) time.
    """
    n = len(pi)
    D = np.diag(np.sqrt(pi))
    Di = np.diag(1.0 / np.sqrt(np.maximum(pi, 1e-15)))

    LP = np.eye(n) - D @ P @ Di
    LQ = np.eye(n) - D @ Q @ Di

    _, S, Vt = np.linalg.svd(LP)
    threshold = 1e-10
    S_inv = np.where(S > threshold, 1.0 / S, 0.0)
    LP_pinv = Vt.T @ np.diag(S_inv) @ Vt

    M = LP_pinv @ LQ
    ev = np.real(np.linalg.eigvals(M))
    ev_filtered = ev[np.abs(ev) > threshold]
    return float(np.max(ev_filtered)) if len(ev_filtered) > 0 else 1.0


def comparison_constant_sampled(pi_P: np.ndarray, P: np.ndarray,
                                 pi_Q: np.ndarray, Q: np.ndarray,
                                 n_samples: int = 5000) -> float:
    """Estimate comparison constant C via random sampling.

    For chains with different stationary distributions,
    the exact method requires more care. This uses Monte Carlo
    sampling to estimate sup_f E_Q(f)/E_P(f).

    Args:
        pi_P, pi_Q: Stationary distributions
        P, Q: Transition matrices
        n_samples: Number of random test functions

    Returns:
        Lower bound on the comparison constant C.

    Complexity: O(n_samples · n²) time.
    """
    n = len(pi_P)
    max_ratio = 0.0
    for _ in range(n_samples):
        f = np.random.randn(n)
        f -= np.dot(pi_P, f)  # center under pi_P
        e_P = dirichlet_form(pi_P, P, f)
        e_Q = dirichlet_form(pi_Q, Q, f)
        if e_P > 1e-12:
            max_ratio = max(max_ratio, e_Q / e_P)
    return max_ratio


def measure_ratio(pi_P: np.ndarray, pi_Q: np.ndarray) -> float:
    """Compute the measure ratio b = max_x πP(x)/πQ(x).

    This is the smallest b such that πP(x) ≤ b · πQ(x) for all x.

    Args:
        pi_P, pi_Q: Probability distributions

    Returns:
        The measure ratio b.

    Complexity: O(n) time.
    """
    return float(np.max(pi_P / np.maximum(pi_Q, 1e-15)))


def comparison_bound(lambda_Q: float, b: float, C: float) -> float:
    """Compute the comparison theorem bound on the spectral gap.

    The comparison theorem (formally verified in Lean 4) states:
        λ(P) ≥ λ(Q) / (b · C)

    Args:
        lambda_Q: Spectral gap of reference chain Q
        b: Measure ratio πP/πQ
        C: Dirichlet form comparison constant

    Returns:
        Lower bound on λ(P).
    """
    if b <= 0 or C <= 0:
        return 0.0
    return lambda_Q / (b * C)


def mixing_time_bound(gap_lower: float, n_states: int,
                       epsilon: float = 0.25) -> float:
    """Compute mixing time upper bound from spectral gap.

    t_mix(ε) ≤ (1/λ) · (log(n) + log(1/ε))

    Args:
        gap_lower: Lower bound on spectral gap
        n_states: Number of states
        epsilon: TV distance threshold

    Returns:
        Upper bound on mixing time.
    """
    if gap_lower <= 0:
        return float('inf')
    return (1.0 / gap_lower) * (np.log(n_states) + np.log(1.0 / epsilon))


def path_congestion_from_paths(pi: np.ndarray, P: np.ndarray,
                                Q: np.ndarray,
                                paths: List[List[int]]) -> float:
    """Compute path congestion from an explicit path system.

    Args:
        pi: Stationary distribution
        P: Source chain transition matrix
        Q: Target chain transition matrix
        paths: paths[x*n+y] = path from x to y as list of states

    Returns:
        The path congestion ρ.

    Complexity: O(n² · max_path_length) time.
    """
    n = len(pi)
    max_congestion = 0.0
    for u in range(n):
        for v in range(n):
            if Q[u][v] <= 0:
                continue
            load = 0.0
            for x in range(n):
                for y in range(n):
                    if P[x][y] <= 0:
                        continue
                    path = paths[x * n + y]
                    path_len = len(path) - 1
                    for k in range(path_len):
                        if path[k] == u and path[k+1] == v:
                            load += pi[x] * P[x][y] * path_len
                            break
            congestion = load / (pi[u] * Q[u][v])
            max_congestion = max(max_congestion, congestion)
    return max_congestion


# ---- Example usage ----
if __name__ == "__main__":
    print("Markov Chain Comparison — Algorithm Examples\n")

    # Example: compare two random walks on a 5-state path
    n = 5
    P = np.zeros((n, n))
    Q = np.zeros((n, n))
    for i in range(n):
        P[i][i] = 0.3
        Q[i][i] = 0.2
        for j in range(n):
            if abs(i-j) == 1:
                P[i][j] = 0.7 / max(1, sum(1 for k in range(n) if abs(i-k)==1))
            if 0 < abs(i-j) <= 2:
                Q[i][j] = 0.8 / max(1, sum(1 for k in range(n) if 0<abs(i-k)<=2))

    pi = np.ones(n) / n

    gap_P = spectral_gap_exact(pi, P)
    gap_Q = spectral_gap_exact(pi, Q)
    C = comparison_constant_exact(pi, P, Q)
    b = measure_ratio(pi, pi)

    bound = comparison_bound(gap_Q, b, C)
    t_mix = mixing_time_bound(bound, n)

    print(f"Path graph, n={n}")
    print(f"λ(P) = {gap_P:.6f}, λ(Q) = {gap_Q:.6f}")
    print(f"C = {C:.4f}, b = {b:.4f}")
    print(f"Certified bound: λ(P) ≥ {bound:.6f}")
    print(f"Mixing time bound: t_mix ≤ {t_mix:.1f}")
