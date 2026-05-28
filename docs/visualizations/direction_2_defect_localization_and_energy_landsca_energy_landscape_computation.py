"""
Algorithms for Tropical Defect Localization and Energy Landscapes.

Implements the key algorithms from the research paper with full
documentation, type hints, complexity analysis, and correctness guarantees.
"""

import numpy as np
from typing import Tuple, List, Optional
from dataclasses import dataclass


@dataclass
class EnergyLandscape:
    """The energy landscape of a matrix's diagExSlack values.
    
    Attributes:
        W: The input matrix
        slack_values: All off-diagonal diagExSlack values
        sorted_values: Sorted slack values (ascending)
        pairs: List of (i,j) pairs corresponding to slack_values
        witness: The pair (i*, j*) achieving the minimum
        trop_margin: The tropical margin (minimum slack)
        spectral_gap: Gap between 2nd smallest and smallest slack
        first_excited: The 2nd smallest slack value
    """
    W: np.ndarray
    slack_values: np.ndarray
    sorted_values: np.ndarray
    pairs: List[Tuple[int, int]]
    witness: Tuple[int, int]
    trop_margin: float
    spectral_gap: float
    first_excited: float


def diag_ex_slack(W: np.ndarray, i: int, j: int) -> float:
    """Compute the diagonal exchange slack for pair (i, j).
    
    Definition: δ(i,j) = 2·W(i,j) - W(i,i) - W(j,j)
    
    This measures how far the off-diagonal entry W(i,j) deviates
    from the "diagonal average" (W(i,i) + W(j,j))/2.
    
    Time complexity: O(1)
    Space complexity: O(1)
    
    Args:
        W: An n×n real matrix
        i, j: Indices (should satisfy i ≠ j for meaningful results)
    
    Returns:
        The diagonal exchange slack value
    
    Example:
        >>> W = np.array([[3, 1], [1, 3]])
        >>> diag_ex_slack(W, 0, 1)  # 2*1 - 3 - 3 = -4
        -4.0
    """
    return float(2 * W[i, j] - W[i, i] - W[j, j])


def diag_ex_slack_matrix(W: np.ndarray) -> np.ndarray:
    """Compute the full diagExSlack matrix efficiently.
    
    For an n×n matrix W, returns the n×n matrix S where
    S[i,j] = 2·W[i,j] - W[i,i] - W[j,j].
    
    Time complexity: O(n²)
    Space complexity: O(n²)
    
    Args:
        W: An n×n real matrix
    
    Returns:
        The n×n diagExSlack matrix
    """
    n = W.shape[0]
    diag = np.diag(W)
    return 2 * W - diag[:, np.newaxis] - diag[np.newaxis, :]


def compute_energy_landscape(W: np.ndarray) -> EnergyLandscape:
    """Compute the complete energy landscape of a matrix.
    
    The energy landscape consists of all off-diagonal diagExSlack values,
    sorted in ascending order, with the spectral gap (difference between
    the two smallest values) explicitly computed.
    
    Time complexity: O(n² log n) (dominated by sorting)
    Space complexity: O(n²)
    
    Correctness guarantee: The returned trop_margin equals
    min_{i≠j} diagExSlack(W, i, j), and spectral_gap equals
    the difference between the 2nd smallest and smallest values.
    
    Args:
        W: An n×n real matrix with n ≥ 2
    
    Returns:
        An EnergyLandscape dataclass with all computed quantities
    """
    n = W.shape[0]
    assert n >= 2, "Matrix must be at least 2×2"
    
    # Compute full slack matrix efficiently
    S = diag_ex_slack_matrix(W)
    
    # Extract off-diagonal pairs
    pairs = [(i, j) for i in range(n) for j in range(n) if i != j]
    slacks = np.array([S[i, j] for i, j in pairs])
    
    # Sort
    sorted_indices = np.argsort(slacks)
    sorted_slacks = slacks[sorted_indices]
    
    # Extract key quantities
    min_idx = sorted_indices[0]
    witness = pairs[min_idx]
    trop_margin = sorted_slacks[0]
    first_excited = sorted_slacks[1] if len(sorted_slacks) > 1 else trop_margin
    spectral_gap = first_excited - trop_margin
    
    return EnergyLandscape(
        W=W,
        slack_values=slacks,
        sorted_values=sorted_slacks,
        pairs=pairs,
        witness=witness,
        trop_margin=trop_margin,
        spectral_gap=spectral_gap,
        first_excited=first_excited,
    )


def tropical_overlap(w1: Tuple[int, int], w2: Tuple[int, int]) -> float:
    """Compute the tropical overlap (Edwards-Anderson order parameter).
    
    This is 1 if w1 == w2, and 0 otherwise. It measures whether
    two matrix realizations share the same defect location.
    
    In the spin-glass analogy, this corresponds to the overlap
    between two replicas of the system.
    
    Time complexity: O(1)
    
    Args:
        w1, w2: Witness pairs (i, j)
    
    Returns:
        1.0 if w1 == w2, else 0.0
    """
    return 1.0 if w1 == w2 else 0.0


def mean_model(n: int, mu_diag: float, mu_off: float) -> np.ndarray:
    """Construct the mean model matrix.
    
    M[i,j] = mu_diag if i == j, mu_off otherwise.
    
    Time complexity: O(n²)
    """
    M = np.full((n, n), mu_off)
    np.fill_diagonal(M, mu_diag)
    return M


def critical_window_matrix(
    n: int, c: float, sigma: float = 1.0, rng: Optional[np.random.Generator] = None
) -> np.ndarray:
    """Sample a matrix from the critical window ensemble.
    
    W = meanModel(n, 0, c·σ·√(log n)) + σ·Z
    where Z has i.i.d. N(0,1) entries.
    
    The critical relation: μ_off - μ_diag = c·σ·√(log n).
    
    Args:
        n: Matrix size
        c: Critical window parameter (c > 1 for supercritical)
        sigma: Noise scale
        rng: Random number generator (for reproducibility)
    
    Returns:
        An n×n real matrix from the critical window ensemble
    """
    if rng is None:
        rng = np.random.default_rng()
    
    mu_off = c * sigma * np.sqrt(np.log(n))
    M = mean_model(n, 0.0, mu_off)
    N = sigma * rng.standard_normal((n, n))
    return M + N


def defect_identification_test(
    n: int, c: float, sigma: float = 1.0, n_samples: int = 1000,
    rng: Optional[np.random.Generator] = None
) -> dict:
    """Test the defect identification principle.
    
    For each sample, check whether the witness of W = meanModel + N
    equals the witness of N alone. By the defect identification theorem,
    these should always agree.
    
    Args:
        n: Matrix size
        c: Critical window parameter
        sigma: Noise scale
        n_samples: Number of Monte Carlo samples
        rng: Random number generator
    
    Returns:
        Dictionary with match fraction and detailed results
    """
    if rng is None:
        rng = np.random.default_rng(42)
    
    matches = 0
    for _ in range(n_samples):
        W = critical_window_matrix(n, c, sigma, rng)
        N = W - mean_model(n, 0.0, c * sigma * np.sqrt(np.log(n)))
        
        landscape_W = compute_energy_landscape(W)
        landscape_N = compute_energy_landscape(N)
        
        if landscape_W.witness == landscape_N.witness:
            matches += 1
    
    return {
        'n': n,
        'c': c,
        'match_fraction': matches / n_samples,
        'n_samples': n_samples,
    }


def spectral_gap_statistics(
    n_values: List[int], c: float, sigma: float = 1.0,
    n_samples: int = 1000, rng: Optional[np.random.Generator] = None
) -> dict:
    """Compute spectral gap statistics across matrix sizes.
    
    For each n, samples n_samples matrices and computes the
    median, mean, and std of the spectral gap.
    
    Args:
        n_values: List of matrix sizes to test
        c: Critical window parameter
        sigma: Noise scale
        n_samples: Number of samples per n
        rng: Random generator
    
    Returns:
        Dictionary mapping n to gap statistics
    """
    if rng is None:
        rng = np.random.default_rng(42)
    
    results = {}
    for n in n_values:
        gaps = []
        for _ in range(n_samples):
            W = critical_window_matrix(n, c, sigma, rng)
            landscape = compute_energy_landscape(W)
            gaps.append(landscape.spectral_gap)
        
        results[n] = {
            'median': np.median(gaps),
            'mean': np.mean(gaps),
            'std': np.std(gaps),
            'theoretical_prediction': 0.5 * sigma * np.sqrt(np.log(n)),
        }
    
    return results


# ─── Example Usage ───────────────────────────────────────────────────────────

if __name__ == '__main__':
    rng = np.random.default_rng(42)
    
    print("=== Algorithms for Tropical Defect Localization ===\n")
    
    # Example 1: Energy landscape computation
    n = 20
    W = critical_window_matrix(n, c=2.0, rng=rng)
    L = compute_energy_landscape(W)
    print(f"Energy landscape for n={n}, c=2.0:")
    print(f"  Witness: {L.witness}")
    print(f"  Tropical margin: {L.trop_margin:.4f}")
    print(f"  Spectral gap: {L.spectral_gap:.4f}")
    print(f"  First excited: {L.first_excited:.4f}")
    print()
    
    # Example 2: Defect identification
    result = defect_identification_test(n=30, c=2.0, n_samples=500, rng=rng)
    print(f"Defect identification (n={result['n']}, c={result['c']}):")
    print(f"  Match fraction: {result['match_fraction']:.4f}")
    print(f"  (Expected: 1.0 by the theorem)")
    print()
    
    # Example 3: Spectral gap statistics
    stats = spectral_gap_statistics([20, 50, 100], c=2.0, n_samples=500, rng=rng)
    print("Spectral gap statistics (c=2.0):")
    for n_val, s in stats.items():
        print(f"  n={n_val}: median={s['median']:.4f}, "
              f"theory={s['theoretical_prediction']:.4f}")
