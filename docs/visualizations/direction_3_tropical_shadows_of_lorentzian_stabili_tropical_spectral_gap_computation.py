"""
Algorithms for Tropical Shadows of Lorentzian Stability

Implements the core computational methods from the theory:
1. Tropical spectral gap computation
2. Gap certificate generation
3. Stability radius estimation
4. Weighted rescaling analysis

All algorithms operate on symmetric weight matrices W where
W[i][j] = log(a[i][j]) for original positive coefficients a[i][j].
"""

import numpy as np
from typing import Tuple, List, Optional, Dict
from dataclasses import dataclass


@dataclass
class TropicalQuadraticWeight:
    """A symmetric weight matrix representing tropicalized coefficients.
    
    Attributes:
        weight: n×n symmetric matrix with W[i,j] = log(a[i,j])
    """
    weight: np.ndarray
    
    def __post_init__(self):
        assert self.weight.ndim == 2
        assert self.weight.shape[0] == self.weight.shape[1]
        # Symmetrize
        self.weight = (self.weight + self.weight.T) / 2
    
    @property
    def n(self) -> int:
        return self.weight.shape[0]
    
    @classmethod
    def from_coefficients(cls, A: np.ndarray) -> 'TropicalQuadraticWeight':
        """Create tropical weight from positive coefficient matrix."""
        assert np.all(A > 0), "All coefficients must be positive"
        return cls(weight=np.log(A))
    
    @classmethod
    def uniform(cls, n: int, d: float, c: float) -> 'TropicalQuadraticWeight':
        """Create uniform weight: diagonal d, off-diagonal c."""
        W = np.full((n, n), c)
        np.fill_diagonal(W, d)
        return cls(weight=W)


def diagonal_minor_gap(w: TropicalQuadraticWeight, i: int, j: int) -> float:
    """Compute the diagonal minor gap Δ(i,j) = W[i,i] + W[j,j] - 2·W[i,j].
    
    This is the tropical analogue of log(a[i,i]·a[j,j] / a[i,j]²).
    
    Time complexity: O(1)
    """
    return w.weight[i, i] + w.weight[j, j] - 2 * w.weight[i, j]


def exchange_defect(w: TropicalQuadraticWeight, i: int, j: int,
                    k: int, l: int) -> float:
    """Compute exchange defect δ(i,j,k,l) = W[i,j] + W[k,l] - W[i,k] - W[j,l].
    
    The diagonal minor gap is the special case δ(i,i,j,j).
    
    Time complexity: O(1)
    """
    return w.weight[i, j] + w.weight[k, l] - w.weight[i, k] - w.weight[j, l]


@dataclass
class TropicalGapCertificate:
    """Certificate for the tropical spectral gap.
    
    Attributes:
        witness_i, witness_j: Indices achieving the minimum gap
        value: The tropical spectral gap value
        all_gaps: Optional dict of all pairwise gaps
    """
    witness_i: int
    witness_j: int
    value: float
    all_gaps: Optional[Dict[Tuple[int, int], float]] = None


def tropical_spectral_gap(w: TropicalQuadraticWeight,
                          return_certificate: bool = False
                          ) -> float | Tuple[float, TropicalGapCertificate]:
    """Compute the tropical spectral gap: min_{i≠j} Δ(i,j).
    
    This is the key tropical invariant controlling Lorentzian stability.
    
    Time complexity: O(n²)
    Space complexity: O(n²) if return_certificate, O(1) otherwise
    
    Args:
        w: Tropical quadratic weight
        return_certificate: If True, also return a gap certificate
    
    Returns:
        The tropical spectral gap, optionally with certificate
    """
    n = w.n
    assert n >= 2, "Need at least 2 indices"
    
    min_gap = float('inf')
    min_i, min_j = -1, -1
    all_gaps = {} if return_certificate else None
    
    for i in range(n):
        for j in range(n):
            if i == j:
                continue
            gap = diagonal_minor_gap(w, i, j)
            if return_certificate:
                all_gaps[(i, j)] = gap
            if gap < min_gap:
                min_gap = gap
                min_i, min_j = i, j
    
    if return_certificate:
        cert = TropicalGapCertificate(
            witness_i=min_i,
            witness_j=min_j,
            value=min_gap,
            all_gaps=all_gaps
        )
        return min_gap, cert
    return min_gap


def tropical_stability_radius(w: TropicalQuadraticWeight) -> float:
    """Compute the tropical stability radius: gap/4.
    
    This is the maximum entry-wise perturbation (in log-space)
    that provably preserves tropical PSD.
    
    Time complexity: O(n²)
    """
    gap = tropical_spectral_gap(w)
    return gap / 4


def is_tropically_psd(w: TropicalQuadraticWeight) -> bool:
    """Check if the weight is tropically PSD.
    
    Equivalent to: tropical spectral gap ≥ 0.
    
    Time complexity: O(n²)
    """
    return tropical_spectral_gap(w) >= -1e-12  # numerical tolerance


def perturb_weight(w: TropicalQuadraticWeight,
                   delta: np.ndarray) -> TropicalQuadraticWeight:
    """Perturb a tropical weight by symmetric delta."""
    delta_sym = (delta + delta.T) / 2
    return TropicalQuadraticWeight(weight=w.weight + delta_sym)


def weighted_rescale(w: TropicalQuadraticWeight,
                     omega: np.ndarray,
                     t: float) -> TropicalQuadraticWeight:
    """Weighted rescaling: W'[i,j] = W[i,j] + (ω_i + ω_j)·log(t).
    
    This implements Maslov dequantization scaling.
    """
    n = w.n
    log_t = np.log(t)
    shift = np.outer(omega, np.ones(n)) + np.outer(np.ones(n), omega)
    return TropicalQuadraticWeight(weight=w.weight + shift * log_t)


def stability_radius_empirical(w: TropicalQuadraticWeight,
                               num_trials: int = 1000,
                               seed: int = 42) -> float:
    """Estimate the true stability radius by random perturbation.
    
    Binary search for the maximum perturbation size that preserves
    tropical PSD across random trials.
    
    Time complexity: O(num_trials · n² · log(1/precision))
    """
    rng = np.random.RandomState(seed)
    n = w.n
    
    lo, hi = 0.0, tropical_spectral_gap(w) / 2
    if hi <= 0:
        return 0.0
    
    for _ in range(50):  # binary search iterations
        mid = (lo + hi) / 2
        destroyed = False
        for _ in range(num_trials):
            delta = rng.uniform(-mid, mid, size=(n, n))
            delta = (delta + delta.T) / 2
            w_perturbed = perturb_weight(w, delta)
            if not is_tropically_psd(w_perturbed):
                destroyed = True
                break
        if destroyed:
            hi = mid
        else:
            lo = mid
    
    return lo


def maslov_limit_estimate(w: TropicalQuadraticWeight,
                          omega: np.ndarray,
                          t_values: np.ndarray
                          ) -> np.ndarray:
    """Estimate log(stabilityRadius(rescale(w,ω,t))) / log(t).
    
    Used to test the Maslov dequantization conjecture.
    """
    results = []
    for t in t_values:
        w_rescaled = weighted_rescale(w, omega, t)
        gap = tropical_spectral_gap(w_rescaled)
        radius = gap / 4
        if radius > 0 and t > 1:
            results.append(np.log(radius) / np.log(t))
        else:
            results.append(np.nan)
    return np.array(results)


# Example usage
if __name__ == "__main__":
    # Uniform weight example
    n = 5
    w = TropicalQuadraticWeight.uniform(n, d=2.0, c=1.0)
    gap, cert = tropical_spectral_gap(w, return_certificate=True)
    print(f"Uniform weight (d=2, c=1, n={n}):")
    print(f"  Tropical spectral gap: {gap}")
    print(f"  Expected: 2*(d-c) = {2*(2.0-1.0)}")
    print(f"  Certificate witness: ({cert.witness_i}, {cert.witness_j})")
    print(f"  Stability radius: {tropical_stability_radius(w)}")
    print()
    
    # Random positive definite matrix
    rng = np.random.RandomState(123)
    A = rng.rand(4, 4)
    A = A @ A.T + 2 * np.eye(4)
    w2 = TropicalQuadraticWeight.from_coefficients(A)
    gap2, cert2 = tropical_spectral_gap(w2, return_certificate=True)
    print(f"Random PD matrix (n=4):")
    print(f"  Tropical spectral gap: {gap2:.6f}")
    print(f"  Certificate: ({cert2.witness_i}, {cert2.witness_j})")
    print(f"  Stability radius: {tropical_stability_radius(w2):.6f}")
