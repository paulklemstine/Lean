"""
Algorithms for Entropic Area Laws from Strong Log-Concavity

This module implements the core algorithms for computing:
1. Shannon entropy of probability distributions
2. Pair-mass gap (Lorentzian gap surrogate)
3. Marginal distributions and their entropies across bipartitions
4. Area-law diagnostics for quantum measurement distributions

All algorithms are direct implementations of the formally verified
mathematical framework.
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from itertools import combinations


def shannon_term(x: float) -> float:
    """Compute -x * log(x) with the convention 0 * log(0) = 0.
    
    This is the entropy contribution of a single probability atom.
    
    Args:
        x: A probability value in [0, 1].
        
    Returns:
        -x * log(x) if x > 0, else 0.
    """
    if x <= 0:
        return 0.0
    return -x * np.log(x)


def shannon_entropy(probs: np.ndarray) -> float:
    """Compute Shannon entropy H(μ) = Σ -μ(x) log μ(x).
    
    Args:
        probs: Array of probabilities (nonnegative, summing to 1).
        
    Returns:
        Shannon entropy in nats.
    """
    return sum(shannon_term(p) for p in probs)


def support_size(probs: np.ndarray, tol: float = 1e-12) -> int:
    """Count the number of atoms with nonzero probability.
    
    Args:
        probs: Array of probabilities.
        tol: Threshold below which a probability is considered zero.
        
    Returns:
        Number of support elements.
    """
    return int(np.sum(probs > tol))


def pair_mass_gap(probs: np.ndarray, tol: float = 1e-12) -> float:
    """Compute the pair-mass gap: minimum sum of masses of any two 
    distinct support atoms.
    
    This is the Lorentzian gap surrogate: a quantitative measure of how
    concentrated the distribution is. Higher gap = fewer significant atoms
    = lower entropy.
    
    Args:
        probs: Array of probabilities.
        tol: Threshold for support membership.
        
    Returns:
        Minimum pairwise mass sum, or infinity if < 2 support elements.
    """
    support_masses = probs[probs > tol]
    if len(support_masses) < 2:
        return float('inf')
    
    min_gap = float('inf')
    for i, j in combinations(range(len(support_masses)), 2):
        gap = support_masses[i] + support_masses[j]
        min_gap = min(min_gap, gap)
    
    return min_gap


def marginal_distribution(probs: np.ndarray, n: int, 
                          subset_indices: List[int]) -> np.ndarray:
    """Compute the marginal distribution over a subset of qubits.
    
    Given a distribution on {0,1}^n (represented as a 2^n array),
    compute the marginal on the specified qubit subset.
    
    Args:
        probs: Array of 2^n probabilities.
        n: Number of qubits.
        subset_indices: Indices of qubits in the subset A.
        
    Returns:
        Array of 2^|A| marginal probabilities.
    """
    k = len(subset_indices)
    marginal = np.zeros(2**k)
    
    for x in range(2**n):
        # Extract bits at subset positions
        bits = tuple((x >> (n - 1 - i)) & 1 for i in subset_indices)
        marginal_idx = sum(b << (k - 1 - j) for j, b in enumerate(bits))
        marginal[marginal_idx] += probs[x]
    
    return marginal


def marginal_shannon_entropy(probs: np.ndarray, n: int,
                              subset_indices: List[int]) -> float:
    """Compute Shannon entropy of the marginal distribution on subset A.
    
    This is the bipartition surrogate entropy, which upper-bounds the
    quantum entanglement entropy across the cut.
    
    Args:
        probs: Array of 2^n probabilities.
        n: Number of qubits.
        subset_indices: Indices of qubits in the subset.
        
    Returns:
        Shannon entropy of the marginal in nats.
    """
    marg = marginal_distribution(probs, n, subset_indices)
    return shannon_entropy(marg)


def all_interval_cuts(n: int) -> List[List[int]]:
    """Generate all interval cuts {0, 1, ..., k-1} for k = 1, ..., n-1.
    
    Args:
        n: Number of qubits.
        
    Returns:
        List of interval cuts (each a list of qubit indices).
    """
    return [list(range(k)) for k in range(1, n)]


def entropy_bound_from_gap(delta: float) -> float:
    """Compute the theoretical entropy upper bound log(2/δ) from the gap.
    
    This is the main theorem: if all pairs of distinct support atoms have
    mass sum ≥ δ, then H(μ) ≤ log(2/δ).
    
    Args:
        delta: Pair-mass gap parameter.
        
    Returns:
        log(2/δ) — the theoretical entropy bound.
    """
    if delta <= 0:
        return float('inf')
    return np.log(2.0 / delta)


def area_law_diagnostic(probs: np.ndarray, n: int) -> Dict:
    """Run the full area-law diagnostic on a measurement distribution.
    
    Computes the pair-mass gap, theoretical entropy bound, and actual
    entropies across all interval cuts. Reports whether the area-law
    bound is satisfied.
    
    Args:
        probs: Array of 2^n measurement probabilities.
        n: Number of qubits.
        
    Returns:
        Dictionary with diagnostic results.
    """
    delta = pair_mass_gap(probs)
    bound = entropy_bound_from_gap(delta) if delta < float('inf') else float('inf')
    global_entropy = shannon_entropy(probs)
    
    cuts = all_interval_cuts(n)
    cut_results = []
    
    for cut in cuts:
        k = len(cut)
        marginal_ent = marginal_shannon_entropy(probs, n, cut)
        cut_results.append({
            'cut_size': k,
            'cut_indices': cut,
            'marginal_entropy': marginal_ent,
            'bound': bound,
            'satisfied': marginal_ent <= bound + 1e-10,
        })
    
    return {
        'n': n,
        'support_size': support_size(probs),
        'global_entropy': global_entropy,
        'pair_mass_gap': delta,
        'entropy_bound': bound,
        'global_bound_satisfied': global_entropy <= bound + 1e-10,
        'cuts': cut_results,
        'all_cuts_satisfied': all(c['satisfied'] for c in cut_results),
    }


def fit_scaling(deltas: np.ndarray, entropies: np.ndarray) -> Dict:
    """Fit logarithmic vs polynomial scaling of entropy against gap.
    
    Tests whether S(A) scales as log(1/δ) (area law) or as 1/δ (volume law).
    
    Args:
        deltas: Array of gap values.
        entropies: Array of corresponding entropy values.
        
    Returns:
        Dictionary with fit parameters and R² values.
    """
    # Filter valid data
    valid = (deltas > 0) & (entropies > 0) & np.isfinite(deltas) & np.isfinite(entropies)
    d = deltas[valid]
    s = entropies[valid]
    
    if len(d) < 2:
        return {'log_r2': 0.0, 'poly_r2': 0.0, 'verdict': 'insufficient_data'}
    
    # Logarithmic fit: S = a * log(1/δ) + b
    log_inv_d = np.log(1.0 / d)
    A_log = np.vstack([log_inv_d, np.ones(len(d))]).T
    coeffs_log, residuals_log, _, _ = np.linalg.lstsq(A_log, s, rcond=None)
    ss_res_log = np.sum((s - A_log @ coeffs_log)**2)
    ss_tot = np.sum((s - np.mean(s))**2)
    r2_log = 1 - ss_res_log / ss_tot if ss_tot > 0 else 0.0
    
    # Polynomial fit: S = a * (1/δ) + b
    inv_d = 1.0 / d
    A_poly = np.vstack([inv_d, np.ones(len(d))]).T
    coeffs_poly, residuals_poly, _, _ = np.linalg.lstsq(A_poly, s, rcond=None)
    ss_res_poly = np.sum((s - A_poly @ coeffs_poly)**2)
    r2_poly = 1 - ss_res_poly / ss_tot if ss_tot > 0 else 0.0
    
    verdict = 'logarithmic' if r2_log >= r2_poly else 'polynomial'
    
    return {
        'log_coeffs': coeffs_log.tolist(),
        'log_r2': r2_log,
        'poly_coeffs': coeffs_poly.tolist(),
        'poly_r2': r2_poly,
        'verdict': verdict,
    }


if __name__ == '__main__':
    # Example: uniform distribution on 4 qubits
    n = 4
    probs = np.ones(2**n) / (2**n)
    result = area_law_diagnostic(probs, n)
    print(f"Uniform distribution on {n} qubits:")
    print(f"  Support size: {result['support_size']}")
    print(f"  Global entropy: {result['global_entropy']:.4f}")
    print(f"  Pair-mass gap: {result['pair_mass_gap']:.4f}")
    print(f"  Entropy bound log(2/δ): {result['entropy_bound']:.4f}")
    print(f"  Area-law satisfied: {result['all_cuts_satisfied']}")
    
    # Example: peaked distribution
    probs2 = np.zeros(2**n)
    probs2[0] = 0.9
    probs2[1] = 0.1
    result2 = area_law_diagnostic(probs2, n)
    print(f"\nPeaked distribution on {n} qubits:")
    print(f"  Support size: {result2['support_size']}")
    print(f"  Global entropy: {result2['global_entropy']:.4f}")
    print(f"  Pair-mass gap: {result2['pair_mass_gap']:.4f}")
    print(f"  Entropy bound log(2/δ): {result2['entropy_bound']:.4f}")
    print(f"  Area-law satisfied: {result2['all_cuts_satisfied']}")
