#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Modified Log-Sobolev Analysis on Finite Markov Chains

Implements:
1. Transition matrix construction for the hybrid walk
2. Modified log-Sobolev constant estimation via optimization
3. Entropy decay simulation
4. Mixing time estimation from MLSI bounds

All algorithms operate on finite reversible Markov chains represented
as transition matrices with uniform stationary measure.
"""

import numpy as np
from itertools import permutations
from math import factorial, log


# ============================================================
# Algorithm 1: Hybrid Walk Construction
# ============================================================

def build_hybrid_walk(n: int) -> tuple:
    """
    Construct the hybrid walk on S_n.

    Parameters
    ----------
    n : int
        Size of the symmetric group (n >= 2).

    Returns
    -------
    P : np.ndarray
        Transition matrix of shape (n!, n!).
    perms : list of tuples
        List of all permutations.
    perm_index : dict
        Mapping from permutation tuple to index.

    Time complexity: O(n! * n)
    Space complexity: O((n!)^2)
    """
    perms = list(permutations(range(n)))
    perm_index = {p: i for i, p in enumerate(perms)}
    N = len(perms)

    # Build generators
    gens = []
    for i in range(n - 1):
        g = list(range(n))
        g[i], g[i + 1] = g[i + 1], g[i]
        gens.append(tuple(g))
    # Long cycle and inverse
    cycle = tuple((i + 1) % n for i in range(n))
    cycle_inv = tuple((i - 1) % n for i in range(n))
    gens.append(cycle)
    gens.append(cycle_inv)

    num_gens = len(gens)
    P = np.zeros((N, N))

    for i, sigma in enumerate(perms):
        for g in gens:
            tau = tuple(g[sigma[j]] for j in range(n))
            j = perm_index[tau]
            P[i, j] += 1.0 / num_gens

    return P, perms, perm_index


# ============================================================
# Algorithm 2: MLSI Constant Estimation
# ============================================================

def estimate_mls_constant(P: np.ndarray, num_trials: int = 10000,
                          seed: int = 42) -> dict:
    """
    Estimate the modified log-Sobolev constant of a reversible chain.

    Algorithm:
    1. Sample random positive functions f
    2. Compute E(f, log f) / Ent(f) for each
    3. Return the minimum as an upper bound on rho

    Parameters
    ----------
    P : np.ndarray
        Transition matrix (N x N), assumed reversible w.r.t. uniform.
    num_trials : int
        Number of random functions to sample.
    seed : int
        Random seed.

    Returns
    -------
    dict with keys:
        'rho_estimate' : float  — estimated MLSI constant (upper bound)
        'spectral_gap' : float  — spectral gap of P
        'all_ratios' : np.ndarray — all computed MLS ratios
    """
    N = P.shape[0]
    mu = np.ones(N) / N
    rng = np.random.RandomState(seed)

    # Spectral gap
    eigs = np.linalg.eigvalsh(P)
    eigs.sort()
    spectral_gap = 1 - eigs[-2]

    min_ratio = float('inf')
    ratios = []

    for trial in range(num_trials):
        # Diverse sampling strategies
        strategy = trial % 5
        if strategy == 0:
            f = np.exp(rng.randn(N) * 0.5)
        elif strategy == 1:
            f = 1.0 + rng.randn(N) * 0.1
            f = np.maximum(f, 0.01)
        elif strategy == 2:
            f = np.ones(N) * 0.1
            k = rng.randint(1, max(2, N // 3))
            idx = rng.choice(N, k, replace=False)
            f[idx] = rng.exponential(5.0, k)
        elif strategy == 3:
            f = rng.exponential(1.0, N)
            f = np.maximum(f, 1e-6)
        else:
            # Eigenvector perturbation
            f = 1.0 + 0.3 * rng.randn(N)
            f = np.maximum(f, 0.01)

        logf = np.log(f)
        ef = np.dot(mu, f)
        ent = np.dot(mu, f * logf) - ef * np.log(ef)

        if ent < 1e-15:
            continue

        df = f[:, None] - f[None, :]
        dlogf = logf[:, None] - logf[None, :]
        dirichlet = 0.5 * np.sum(mu[:, None] * P * df * dlogf)

        if dirichlet < 0:
            continue

        ratio = dirichlet / ent
        ratios.append(ratio)
        if ratio < min_ratio:
            min_ratio = ratio

    return {
        'rho_estimate': min_ratio,
        'spectral_gap': spectral_gap,
        'all_ratios': np.array(ratios)
    }


# ============================================================
# Algorithm 3: Entropy Decay Simulation
# ============================================================

def simulate_entropy_decay(P: np.ndarray, f0: np.ndarray,
                           num_steps: int = 100) -> dict:
    """
    Simulate entropy decay under iterated application of P.

    Parameters
    ----------
    P : np.ndarray
        Transition matrix.
    f0 : np.ndarray
        Initial positive function.
    num_steps : int
        Number of steps to simulate.

    Returns
    -------
    dict with keys:
        'entropies' : np.ndarray — entropy at each step
        'steps' : np.ndarray — step indices
    """
    N = P.shape[0]
    mu = np.ones(N) / N

    f = f0.copy()
    entropies = []

    for t in range(num_steps):
        ef = np.dot(mu, f)
        if ef > 0 and np.all(f > 0):
            ent = np.dot(mu, f * np.log(f)) - ef * np.log(ef)
        else:
            ent = 0.0
        entropies.append(ent)
        f = P.T @ f  # Apply Markov operator: (Pf)(x) = sum_y P(x,y) f(y)

    return {
        'entropies': np.array(entropies),
        'steps': np.arange(num_steps)
    }


# ============================================================
# Algorithm 4: Mixing Time Bound
# ============================================================

def compute_mixing_time_bound(rho: float, N: int, epsilon: float = 0.25) -> float:
    """
    Compute mixing time bound from MLSI constant.

    t_mix(epsilon) <= (1/(2*rho)) * (log(N) + log(1/epsilon))

    Parameters
    ----------
    rho : float
        Modified log-Sobolev constant.
    N : int
        State space size.
    epsilon : float
        Total variation threshold.

    Returns
    -------
    float : upper bound on mixing time.
    """
    if rho <= 0:
        return float('inf')
    return (1.0 / (2 * rho)) * (np.log(N) + np.log(1.0 / epsilon))


def transposition_word_length(n: int, i: int, j: int) -> int:
    """
    Compute the word length of transposition (i,j) in hybrid generators.

    Uses the bubble-sort decomposition:
    (i,j) with i < j decomposes into 2(j-i)-1 adjacent transpositions.

    Parameters
    ----------
    n : int
        Group size.
    i, j : int
        Indices of the transposition (0-indexed).

    Returns
    -------
    int : word length in hybrid generators.
    """
    if i == j:
        return 0
    d = abs(i - j)
    return 2 * d - 1


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  Algorithms for Modified Log-Sobolev Analysis")
    print("=" * 60)

    for n in [3, 4, 5]:
        print(f"\n--- S_{n} ---")
        P, perms, _ = build_hybrid_walk(n)
        result = estimate_mls_constant(P, num_trials=3000)
        print(f"  rho estimate: {result['rho_estimate']:.6f}")
        print(f"  spectral gap: {result['spectral_gap']:.6f}")
        print(f"  rho * n^2:    {result['rho_estimate'] * n**2:.6f}")

        # Entropy decay from a peaked initial condition
        N = len(perms)
        f0 = np.ones(N) * 0.5
        f0[0] = N * 0.5
        decay = simulate_entropy_decay(P, f0, num_steps=50)
        print(f"  Entropy at t=0: {decay['entropies'][0]:.4f}")
        print(f"  Entropy at t=10: {decay['entropies'][10]:.4f}")
        print(f"  Entropy at t=30: {decay['entropies'][min(30, len(decay['entropies'])-1)]:.4f}")

        # Mixing time bound
        tmix = compute_mixing_time_bound(result['rho_estimate'], N)
        print(f"  Mixing time bound: {tmix:.2f}")

        # Word lengths
        max_word = max(transposition_word_length(n, i, j)
                       for i in range(n) for j in range(n) if i != j)
        print(f"  Max transposition word length: {max_word}")
