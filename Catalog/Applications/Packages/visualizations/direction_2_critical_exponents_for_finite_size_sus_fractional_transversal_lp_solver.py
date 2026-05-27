"""
Algorithms for Finite-Size Susceptibility of Random Hypergraph Optimization.

Implements the computational pipeline for measuring susceptibility observables
of fractional transversal numbers in random d-uniform hypergraphs.

Key algorithms:
  - Fractional transversal number computation via LP
  - Edge insertion delta measurement
  - Susceptibility profile scanning
  - Pseudocritical density estimation
  - Finite-size scaling exponent fitting
"""

import numpy as np
from scipy.optimize import linprog
from itertools import combinations
from typing import Optional
import warnings


def compute_frac_transversal_num(n: int, edges: list[tuple[int, ...]]) -> float:
    """Compute the fractional transversal number τ*(H) via linear programming.

    Solves: min Σ x_v subject to x_v ≥ 0, Σ_{v∈e} x_v ≥ 1 for all e.

    Args:
        n: Number of vertices (labeled 0..n-1).
        edges: List of edges, each a tuple of vertex indices.

    Returns:
        The fractional transversal number τ*(H).
    """
    if not edges:
        return 0.0

    c = np.ones(n)  # minimize sum of x_v
    # Constraints: -Σ_{v∈e} x_v ≤ -1 (i.e., Σ ≥ 1)
    A_ub = np.zeros((len(edges), n))
    b_ub = -np.ones(len(edges))
    for i, e in enumerate(edges):
        for v in e:
            A_ub[i, v] = -1.0

    bounds = [(0, None)] * n
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')

    if result.success:
        return result.fun
    else:
        return float('inf')


def edge_insertion_delta(n: int, edges: list[tuple[int, ...]], new_edge: tuple[int, ...]) -> float:
    """Compute Δτ*(H, e) = τ*(H ∪ {e}) - τ*(H).

    Args:
        n: Number of vertices.
        edges: Current edge list.
        new_edge: Edge to insert.

    Returns:
        The insertion delta (nonneg by monotonicity, at most 1 by Lipschitz).
    """
    tau_before = compute_frac_transversal_num(n, edges)
    tau_after = compute_frac_transversal_num(n, edges + [new_edge])
    return tau_after - tau_before


def generate_random_hypergraph(n: int, m: int, d: int, rng: np.random.Generator = None) -> list[tuple[int, ...]]:
    """Generate a random d-uniform hypergraph on n vertices with m edges.

    Edges are sampled uniformly without replacement from all C(n,d) possible d-edges.

    Args:
        n: Number of vertices.
        m: Number of edges.
        d: Uniformity parameter.
        rng: Random number generator.

    Returns:
        List of edges (tuples of vertex indices).
    """
    if rng is None:
        rng = np.random.default_rng()

    all_edges = list(combinations(range(n), d))
    if m > len(all_edges):
        m = len(all_edges)

    indices = rng.choice(len(all_edges), size=m, replace=False)
    return [all_edges[i] for i in indices]


def susceptibility_max(n: int, edges: list[tuple[int, ...]], d: int,
                       sample_size: int = 50, rng: np.random.Generator = None) -> float:
    """Estimate χ_max(H) = max_e |Δτ*(H, e)| by sampling candidate edges.

    Args:
        n: Number of vertices.
        edges: Current edge list.
        d: Edge uniformity.
        sample_size: Number of candidate edges to test.
        rng: Random number generator.

    Returns:
        Estimated maximum insertion susceptibility.
    """
    if rng is None:
        rng = np.random.default_rng()

    all_edges = list(combinations(range(n), d))
    edge_set = set(edges)
    candidates = [e for e in all_edges if e not in edge_set]

    if not candidates:
        return 0.0

    sample = [candidates[i] for i in rng.choice(len(candidates),
              size=min(sample_size, len(candidates)), replace=False)]

    deltas = [abs(edge_insertion_delta(n, edges, e)) for e in sample]
    return max(deltas) if deltas else 0.0


def susceptibility_avg(n: int, edges: list[tuple[int, ...]], d: int,
                       sample_size: int = 50, rng: np.random.Generator = None) -> float:
    """Estimate χ_avg(H) = mean_e |Δτ*(H, e)| by sampling candidate edges.

    Args:
        n: Number of vertices.
        edges: Current edge list.
        d: Edge uniformity.
        sample_size: Number of candidate edges to test.
        rng: Random number generator.

    Returns:
        Estimated mean insertion susceptibility.
    """
    if rng is None:
        rng = np.random.default_rng()

    all_edges = list(combinations(range(n), d))
    edge_set = set(edges)
    candidates = [e for e in all_edges if e not in edge_set]

    if not candidates:
        return 0.0

    sample = [candidates[i] for i in rng.choice(len(candidates),
              size=min(sample_size, len(candidates)), replace=False)]

    deltas = [abs(edge_insertion_delta(n, edges, e)) for e in sample]
    return np.mean(deltas) if deltas else 0.0


def quadratic_susceptibility_profile(n: int, d: int, m_values: list[int],
                                     samples: int = 20, rng: np.random.Generator = None) -> dict:
    """Compute the quadratic susceptibility profile χ²(n,m,d) over a range of m.

    For each m, generates `samples` random hypergraphs and estimates variance
    of τ* as the quadratic susceptibility.

    Args:
        n: Number of vertices.
        d: Uniformity parameter.
        m_values: List of edge counts to scan.
        samples: Number of hypergraph samples per m value.
        rng: Random number generator.

    Returns:
        Dictionary with keys 'densities', 'chi2', 'tau_mean', 'tau_std'.
    """
    if rng is None:
        rng = np.random.default_rng(42)

    densities = []
    chi2_values = []
    tau_means = []
    tau_stds = []

    for m in m_values:
        taus = []
        for _ in range(samples):
            edges = generate_random_hypergraph(n, m, d, rng)
            tau = compute_frac_transversal_num(n, edges)
            taus.append(tau)

        taus = np.array(taus)
        densities.append(m / n)
        chi2_values.append(np.var(taus))
        tau_means.append(np.mean(taus))
        tau_stds.append(np.std(taus))

    return {
        'densities': np.array(densities),
        'chi2': np.array(chi2_values),
        'tau_mean': np.array(tau_means),
        'tau_std': np.array(tau_stds),
        'm_values': np.array(m_values),
    }


def find_pseudocritical_density(profile: dict) -> dict:
    """Find the pseudocritical density c*(n,d) where χ² is maximized.

    Args:
        profile: Output of quadratic_susceptibility_profile.

    Returns:
        Dictionary with 'pseudocritical_m', 'pseudocritical_density',
        'peak_chi2', 'peak_index'.
    """
    idx = np.argmax(profile['chi2'])
    return {
        'pseudocritical_m': profile['m_values'][idx],
        'pseudocritical_density': profile['densities'][idx],
        'peak_chi2': profile['chi2'][idx],
        'peak_index': idx,
    }


def estimate_scaling_exponent(n_values: list[int], d: int,
                              m_fractions: np.ndarray = None,
                              samples: int = 20,
                              rng: np.random.Generator = None) -> dict:
    """Estimate the critical exponent γ(d) from peak heights at different n.

    The conjecture predicts max_m χ²(n,m,d) ~ n^γ.
    Fits log(peak_χ²) vs log(n) to estimate γ.

    Args:
        n_values: List of system sizes to test.
        d: Uniformity parameter.
        m_fractions: Density grid as fractions of n.
        samples: Samples per (n, m) pair.
        rng: Random number generator.

    Returns:
        Dictionary with 'gamma', 'peaks', 'pseudocritical_densities', etc.
    """
    if rng is None:
        rng = np.random.default_rng(42)

    if m_fractions is None:
        m_fractions = np.linspace(0.1, 3.0, 30)

    peaks = []
    pc_densities = []

    for n in n_values:
        m_values = [max(1, int(c * n)) for c in m_fractions]
        m_values = sorted(set(m_values))
        profile = quadratic_susceptibility_profile(n, d, m_values, samples, rng)
        pc = find_pseudocritical_density(profile)
        peaks.append(pc['peak_chi2'])
        pc_densities.append(pc['pseudocritical_density'])

    # Fit gamma: log(peak) = gamma * log(n) + const
    log_n = np.log(np.array(n_values, dtype=float))
    log_peaks = np.log(np.array(peaks) + 1e-10)

    if len(n_values) >= 2:
        coeffs = np.polyfit(log_n, log_peaks, 1)
        gamma = coeffs[0]
    else:
        gamma = float('nan')

    return {
        'gamma': gamma,
        'n_values': n_values,
        'peaks': np.array(peaks),
        'pseudocritical_densities': np.array(pc_densities),
        'log_n': log_n,
        'log_peaks': log_peaks,
    }


def insertion_response_profile(n: int, d: int, edges: list[tuple[int, ...]],
                               sample_size: int = 30,
                               rng: np.random.Generator = None) -> dict:
    """Compute the distribution of insertion deltas for a given hypergraph.

    Args:
        n: Number of vertices.
        d: Edge uniformity.
        edges: Current edge list.
        sample_size: Number of candidate edges to sample.
        rng: Random number generator.

    Returns:
        Dictionary with 'deltas', 'chi_max', 'chi_avg', 'chi_var'.
    """
    if rng is None:
        rng = np.random.default_rng()

    all_edges = list(combinations(range(n), d))
    edge_set = set(edges)
    candidates = [e for e in all_edges if e not in edge_set]

    if not candidates:
        return {'deltas': np.array([]), 'chi_max': 0.0, 'chi_avg': 0.0, 'chi_var': 0.0}

    sample = [candidates[i] for i in rng.choice(len(candidates),
              size=min(sample_size, len(candidates)), replace=False)]

    deltas = np.array([edge_insertion_delta(n, edges, e) for e in sample])

    return {
        'deltas': deltas,
        'chi_max': float(np.max(np.abs(deltas))),
        'chi_avg': float(np.mean(np.abs(deltas))),
        'chi_var': float(np.var(deltas)),
    }


if __name__ == "__main__":
    print("=== Finite-Size Susceptibility Algorithms ===\n")

    # Example: small hypergraph
    n, d = 12, 3
    rng = np.random.default_rng(42)
    edges = generate_random_hypergraph(n, 8, d, rng)
    tau = compute_frac_transversal_num(n, edges)
    print(f"τ*(H) for n={n}, m=8, d={d}: {tau:.4f}")

    # Insertion response
    profile = insertion_response_profile(n, d, edges, sample_size=20, rng=rng)
    print(f"χ_max = {profile['chi_max']:.4f}")
    print(f"χ_avg = {profile['chi_avg']:.4f}")
    print(f"Verified: χ_max ≤ 1? {profile['chi_max'] <= 1.0001}")
    print(f"Verified: χ_avg ≤ χ_max? {profile['chi_avg'] <= profile['chi_max'] + 0.0001}")
    print()

    # Susceptibility profile
    m_values = list(range(1, 25))
    prof = quadratic_susceptibility_profile(n, d, m_values, samples=30, rng=rng)
    pc = find_pseudocritical_density(prof)
    print(f"Pseudocritical density c* ≈ {pc['pseudocritical_density']:.3f}")
    print(f"Peak χ² = {pc['peak_chi2']:.4f}")
