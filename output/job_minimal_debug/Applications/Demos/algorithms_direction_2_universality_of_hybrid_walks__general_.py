#!/usr/bin/env python3
"""
Algorithms for Hybrid Cayley Walk Spectral Analysis

Implements:
1. Cayley graph construction and spectral gap computation
2. Dirichlet energy computation and comparison bound verification
3. Local word simulation cost estimation
4. Congestion witness construction via canonical paths
"""

import numpy as np
from typing import List, Tuple, Dict, Callable, Optional


def build_cayley_adjacency(
    elements: list,
    generators: list,
    group_op: Callable
) -> np.ndarray:
    """Build adjacency matrix of a Cayley graph.

    Args:
        elements: List of group elements.
        generators: Symmetric generating set.
        group_op: Binary group operation.

    Returns:
        Adjacency matrix A where A[i,j] = number of generators mapping i to j.

    Complexity: O(|G| · |S|) time, O(|G|²) space.
    """
    n = len(elements)
    idx = {g: i for i, g in enumerate(elements)}
    A = np.zeros((n, n), dtype=int)
    for i, x in enumerate(elements):
        for s in generators:
            j = idx[group_op(x, s)]
            A[i, j] += 1
    return A


def cayley_transition_matrix(
    elements: list,
    generators: list,
    group_op: Callable
) -> np.ndarray:
    """Build transition matrix P = A / |S| for the random walk.

    Complexity: O(|G| · |S|) time.
    """
    A = build_cayley_adjacency(elements, generators, group_op)
    return A / len(generators)


def compute_spectral_gap(P: np.ndarray) -> float:
    """Compute spectral gap γ = 1 - λ₂ of transition matrix P.

    Uses full eigendecomposition.
    Complexity: O(n³) where n = |G|.

    Args:
        P: Stochastic transition matrix.

    Returns:
        Spectral gap (1 minus second-largest eigenvalue).
    """
    eigenvalues = np.sort(np.real(np.linalg.eigvals(P)))[::-1]
    return float(1.0 - eigenvalues[1])


def compute_dirichlet_energy(
    f: np.ndarray,
    elements: list,
    generators: list,
    group_op: Callable
) -> float:
    """Compute the Dirichlet energy E_S(f) = Σ_x Σ_{s∈S} (f(xs) - f(x))².

    Uses right multiplication convention.

    Args:
        f: Function values indexed by element position.
        elements: Group elements.
        generators: Generating set.
        group_op: Group operation.

    Returns:
        Dirichlet energy E_S(f).

    Complexity: O(|G| · |S|).
    """
    idx = {g: i for i, g in enumerate(elements)}
    energy = 0.0
    for i, x in enumerate(elements):
        for s in generators:
            j = idx[group_op(x, s)]
            energy += (f[j] - f[i]) ** 2
    return energy


def verify_dirichlet_comparison(
    elements: list,
    local_gens: list,
    global_gens: list,
    group_op: Callable,
    L: int,
    n_samples: int = 1000,
    seed: int = 42
) -> Tuple[bool, float]:
    """Verify the Dirichlet form comparison bound computationally.

    Tests: E_{S_L ∪ S_G}(f) ≤ (1 + |S_G| · L²) · E_{S_L}(f)
    for random functions f.

    Args:
        elements: Group elements.
        local_gens: Local generators S_L.
        global_gens: Global generators S_G.
        group_op: Group operation.
        L: Maximum local word length for global generators.
        n_samples: Number of random functions to test.
        seed: Random seed.

    Returns:
        (all_pass, worst_ratio) where worst_ratio = max E_H/E_L seen.
    """
    hybrid_gens = list(set(local_gens + global_gens))
    bound = 1 + len(global_gens) * L ** 2
    N = len(elements)

    rng = np.random.RandomState(seed)
    worst_ratio = 0.0
    all_pass = True

    for _ in range(n_samples):
        f = rng.randn(N)
        E_L = compute_dirichlet_energy(f, elements, local_gens, group_op)
        E_H = compute_dirichlet_energy(f, elements, hybrid_gens, group_op)

        if E_L > 1e-15:
            ratio = E_H / E_L
            worst_ratio = max(worst_ratio, ratio)
            if ratio > bound + 1e-10:
                all_pass = False

    return all_pass, worst_ratio


def estimate_word_length(
    g,
    generators: list,
    group_op: Callable,
    identity,
    max_depth: int = 20
) -> Optional[int]:
    """Estimate the word length of g over generators using BFS.

    Args:
        g: Target group element.
        generators: Generating set.
        group_op: Group operation.
        identity: Group identity element.
        max_depth: Maximum search depth.

    Returns:
        Word length or None if not found within max_depth.

    Complexity: O(|S|^max_depth) worst case.
    """
    if g == identity:
        return 0

    visited = {identity}
    frontier = [identity]

    for depth in range(1, max_depth + 1):
        new_frontier = []
        for x in frontier:
            for s in generators:
                y = group_op(x, s)
                if y == g:
                    return depth
                if y not in visited:
                    visited.add(y)
                    new_frontier.append(y)
        frontier = new_frontier
        if not frontier:
            break

    return None


def spectral_gap_ratio_analysis(
    group_family: Callable,
    local_gen_family: Callable,
    global_gen_family: Callable,
    group_op_family: Callable,
    ns: List[int]
) -> Dict:
    """Analyze spectral gap ratios across a family of groups.

    Args:
        group_family: n -> list of group elements
        local_gen_family: n -> local generators
        global_gen_family: n -> global generators
        group_op_family: n -> group operation
        ns: List of family indices to test

    Returns:
        Dictionary with gaps, ratios, and regression analysis.
    """
    results = {
        'ns': ns,
        'gaps_local': [],
        'gaps_hybrid': [],
        'ratios': [],
    }

    for n in ns:
        elts = group_family(n)
        S_L = local_gen_family(n)
        S_G = global_gen_family(n)
        S_H = list(set(S_L + S_G))
        op = group_op_family(n)

        P_L = cayley_transition_matrix(elts, S_L, op)
        P_H = cayley_transition_matrix(elts, S_H, op)

        g_L = compute_spectral_gap(P_L)
        g_H = compute_spectral_gap(P_H)

        results['gaps_local'].append(g_L)
        results['gaps_hybrid'].append(g_H)
        results['ratios'].append(g_H / g_L if g_L > 1e-15 else float('inf'))

    # Power-law regression: ratio ~ n^α
    log_ns = np.log(np.array(ns, dtype=float))
    log_ratios = np.log(np.array(results['ratios']))
    alpha, intercept = np.polyfit(log_ns, log_ratios, 1)

    results['alpha'] = float(alpha)
    results['intercept'] = float(intercept)
    results['universality'] = abs(alpha) < 0.1

    return results


if __name__ == '__main__':
    # Example: torus analysis
    def torus_elts(n):
        return [(i, j) for i in range(n) for j in range(n)]
    def torus_op(n):
        return lambda x, y: ((x[0]+y[0])%n, (x[1]+y[1])%n)
    def torus_local(n):
        return [(1,0), (n-1,0), (0,1), (0,n-1)]
    def torus_global(n):
        return [(1,1), (n-1,n-1)]

    results = spectral_gap_ratio_analysis(
        torus_elts, torus_local, torus_global, torus_op,
        list(range(3, 20))
    )
    print(f"Torus universality: α = {results['alpha']:.6f}, "
          f"universal = {results['universality']}")
    print(f"Ratio range: [{min(results['ratios']):.4f}, {max(results['ratios']):.4f}]")
