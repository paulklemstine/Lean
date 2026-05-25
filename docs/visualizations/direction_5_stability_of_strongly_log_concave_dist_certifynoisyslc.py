import math
"""
Algorithms for Certified Robust Sampling from Strongly Log-Concave Distributions

Implements the core algorithms from the robustness transfer theory:
1. CertifyNoisySLC: Certified robustness checker
2. GlauberDynamics: Markov chain sampler with certified mixing bounds
3. GibbsPerturbationBound: Energy-based model perturbation analysis
4. IteratedPerturbationTracker: Track gap degradation over multiple updates
"""

import numpy as np
from dataclasses import dataclass
from typing import Optional, List, Tuple
from enum import Enum


# ============================================================
# Data structures
# ============================================================

@dataclass
class RobustLorentzianData:
    """Reference distribution with certified spectral gap.
    
    Attributes:
        coeffs: Probability distribution (nonneg, sums to 1)
        gap: Certified spectral gap parameter ε > 0
        name: Human-readable description
    """
    coeffs: np.ndarray
    gap: float
    name: str = "unnamed"
    
    def __post_init__(self):
        assert np.all(self.coeffs >= -1e-12), "Coefficients must be nonneg"
        assert abs(self.coeffs.sum() - 1.0) < 1e-8, "Coefficients must sum to 1"
        assert self.gap > 0, "Gap must be positive"


class CertificationStatus(Enum):
    CERTIFIED = "certified"
    REJECTED = "rejected"


@dataclass
class CertificationResult:
    """Output of the robustness certification algorithm.
    
    Attributes:
        status: CERTIFIED or REJECTED
        coeff_distance: L1 distance between reference and perturbation
        threshold: Maximum allowable distance (gap/2)
        preserved_gap: Certified lower bound on preserved gap (if certified)
        mixing_time_bound: Certified upper bound on mixing time (if certified)
    """
    status: CertificationStatus
    coeff_distance: float
    threshold: float
    preserved_gap: Optional[float] = None
    mixing_time_bound: Optional[float] = None


@dataclass
class GapTracker:
    """Track spectral gap degradation over iterated perturbations.
    
    Attributes:
        initial_gap: Starting gap ε
        perturbation_bounds: List of δ_i for each perturbation step
        current_gap: Current preserved gap ε - Σδ_i
    """
    initial_gap: float
    perturbation_bounds: List[float]
    current_gap: float


# ============================================================
# Algorithm 1: CertifyNoisySLC
# ============================================================

def certify_noisy_slc(ref: RobustLorentzianData,
                      perturbed: np.ndarray,
                      state_space_size: Optional[int] = None,
                      target_tv: float = 0.1) -> CertificationResult:
    """Certified robustness checker for noisy SLC distributions.
    
    Given a reference distribution with certified gap and a candidate
    perturbation, determines whether the perturbation lies within the
    certified robustness radius.
    
    Algorithm:
        1. Compute L1 coefficient distance d = Σ|μ_i - ν_i|
        2. If d < ε/2, certify with preserved_gap = ε/2
        3. Otherwise, reject
    
    Complexity: O(N) time, O(1) additional space
    
    Args:
        ref: Reference distribution with certified gap
        perturbed: Candidate perturbed distribution
        state_space_size: Size of state space (for mixing time bound)
        target_tv: Target total variation distance for mixing bound
    
    Returns:
        CertificationResult with status, distances, and bounds
    
    Example:
        >>> ref = RobustLorentzianData(np.array([0.25, 0.5, 0.25]), gap=0.1)
        >>> result = certify_noisy_slc(ref, np.array([0.24, 0.52, 0.24]))
        >>> result.status
        CertificationStatus.CERTIFIED
    """
    # Step 1: Compute coefficient distance
    dist = float(np.sum(np.abs(ref.coeffs - perturbed)))
    threshold = ref.gap / 2.0
    
    # Step 2: Decision
    if dist < threshold:
        preserved_gap = ref.gap / 2.0
        
        # Step 3: Compute mixing time bound if state space size given
        mixing_bound = None
        if state_space_size is not None and target_tv > 0:
            mixing_bound = (1.0 / preserved_gap) * np.log(state_space_size / target_tv)
        
        return CertificationResult(
            status=CertificationStatus.CERTIFIED,
            coeff_distance=dist,
            threshold=threshold,
            preserved_gap=preserved_gap,
            mixing_time_bound=mixing_bound
        )
    else:
        return CertificationResult(
            status=CertificationStatus.REJECTED,
            coeff_distance=dist,
            threshold=threshold
        )


# ============================================================
# Algorithm 2: Glauber Dynamics with Certified Mixing
# ============================================================

def glauber_dynamics(coeffs: np.ndarray,
                     n_samples: int,
                     burnin: Optional[int] = None,
                     thin: int = 1,
                     initial_state: Optional[int] = None,
                     rng: Optional[np.random.Generator] = None) -> np.ndarray:
    """Glauber dynamics (Metropolis-Hastings) sampler for discrete distributions.
    
    Implements a single-site flip chain that proposes moves to neighboring
    states and accepts with the Metropolis ratio.
    
    The chain is reversible with respect to the target distribution and
    has spectral gap bounded below by the preserved Lorentzian gap.
    
    Complexity: O(n_samples * (burnin + thin)) time per sample
    
    Args:
        coeffs: Target probability distribution
        n_samples: Number of samples to generate
        burnin: Burn-in period (default: 10 * len(coeffs))
        thin: Thinning interval
        initial_state: Starting state (default: 0)
        rng: Random number generator
    
    Returns:
        Array of n_samples states from the target distribution
    
    Example:
        >>> coeffs = np.array([0.1, 0.3, 0.4, 0.2])
        >>> samples = glauber_dynamics(coeffs, 1000)
        >>> empirical = np.bincount(samples, minlength=4) / 1000
    """
    if rng is None:
        rng = np.random.default_rng()
    
    n = len(coeffs) - 1
    if burnin is None:
        burnin = 10 * (n + 1)
    if initial_state is None:
        initial_state = 0
    
    state = initial_state
    samples = np.zeros(n_samples, dtype=int)
    
    total_steps = burnin + n_samples * thin
    sample_idx = 0
    
    for step in range(total_steps):
        # Propose: move to adjacent state
        if state == 0:
            proposal = 1
        elif state == n:
            proposal = n - 1
        else:
            proposal = state + (1 if rng.random() < 0.5 else -1)
        
        # Metropolis acceptance
        if coeffs[proposal] > 0:
            ratio = coeffs[proposal] / max(coeffs[state], 1e-300)
            if rng.random() < min(1.0, ratio):
                state = proposal
        
        # Collect sample after burn-in
        if step >= burnin and (step - burnin) % thin == 0 and sample_idx < n_samples:
            samples[sample_idx] = state
            sample_idx += 1
    
    return samples


# ============================================================
# Algorithm 3: Gibbs Perturbation Bound
# ============================================================

def gibbs_perturbation_bound(beta: float,
                             energy_ref: np.ndarray,
                             energy_pert: np.ndarray) -> Tuple[float, float, float]:
    """Compute the coefficient distance bound for Gibbs distributions.
    
    For two energy functions E_1, E_2 with ||E_1 - E_2||_∞ ≤ Δ,
    the ratio of Gibbs weights is bounded by e^{βΔ}.
    
    The L1 coefficient distance is bounded by 2(e^{2βΔ} - 1).
    
    Args:
        beta: Inverse temperature
        energy_ref: Reference energy function
        energy_pert: Perturbed energy function
    
    Returns:
        (energy_linf_dist, coeff_dist_bound, actual_coeff_dist)
    
    Example:
        >>> E1 = np.array([0.0, 1.0, 4.0])
        >>> E2 = np.array([0.1, 0.9, 4.1])
        >>> bound = gibbs_perturbation_bound(1.0, E1, E2)
    """
    # L∞ energy distance
    delta = float(np.max(np.abs(energy_ref - energy_pert)))
    
    # Theoretical coefficient distance bound
    coeff_bound = 2.0 * (np.exp(2 * beta * delta) - 1)
    
    # Actual coefficient distance
    w_ref = np.exp(-beta * energy_ref)
    w_pert = np.exp(-beta * energy_pert)
    c_ref = w_ref / w_ref.sum()
    c_pert = w_pert / w_pert.sum()
    actual_dist = float(np.sum(np.abs(c_ref - c_pert)))
    
    return delta, coeff_bound, actual_dist


# ============================================================
# Algorithm 4: Iterated Perturbation Tracker
# ============================================================

def create_gap_tracker(initial_gap: float) -> GapTracker:
    """Create a new gap tracker with initial gap ε.
    
    Args:
        initial_gap: Starting spectral gap ε > 0
    
    Returns:
        GapTracker with full initial gap
    """
    return GapTracker(
        initial_gap=initial_gap,
        perturbation_bounds=[],
        current_gap=initial_gap
    )


def apply_perturbation(tracker: GapTracker,
                       perturbation_bound: float) -> Tuple[bool, float]:
    """Apply a perturbation and update the gap tracker.
    
    The gap degrades by the perturbation bound: ε' = ε - δ.
    If the gap would become negative, the perturbation is rejected.
    
    Args:
        tracker: Current gap tracker
        perturbation_bound: Upper bound δ on the perturbation
    
    Returns:
        (accepted, new_gap)
    """
    new_gap = tracker.current_gap - perturbation_bound
    
    if new_gap > 0:
        tracker.perturbation_bounds.append(perturbation_bound)
        tracker.current_gap = new_gap
        return True, new_gap
    else:
        return False, tracker.current_gap


# ============================================================
# Algorithm 5: Estimate Hessian Gap (Log-Concavity Margin)
# ============================================================

def estimate_hessian_gap(coeffs: np.ndarray) -> float:
    """Estimate the Hessian gap (log-concavity margin) of a distribution.
    
    For coefficients a_0, ..., a_n, the ultra-log-concavity condition is:
        a_k^2 ≥ a_{k-1} * a_{k+1}  for all k
    
    The gap is min_k (a_k^2 / (a_{k-1} * a_{k+1}) - 1), measuring how
    strictly the inequality holds.
    
    Args:
        coeffs: Distribution coefficients
    
    Returns:
        Estimated gap (0 if not log-concave)
    """
    n = len(coeffs)
    if n < 3:
        return float('inf')
    
    min_gap = float('inf')
    for k in range(1, n - 1):
        if coeffs[k - 1] > 1e-15 and coeffs[k + 1] > 1e-15 and coeffs[k] > 1e-15:
            ratio = coeffs[k] ** 2 / (coeffs[k - 1] * coeffs[k + 1])
            gap = ratio - 1.0
            min_gap = min(min_gap, gap)
    
    return max(min_gap, 0.0)


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    rng = np.random.default_rng(42)
    
    # Create reference distribution: Binomial(10, k) / 2^10
    n = 10
    coeffs = np.array([float(math.comb(n, k)) for k in range(n + 1)])
    coeffs /= coeffs.sum()
    
    gap = estimate_hessian_gap(coeffs)
    ref = RobustLorentzianData(coeffs, gap=gap, name=f"Binomial({n})")
    
    print(f"Reference: {ref.name}")
    print(f"Gap: {gap:.6f}")
    
    # Test certification
    noisy = coeffs + 0.005 * rng.standard_normal(n + 1)
    noisy = np.maximum(noisy, 0)
    noisy /= noisy.sum()
    
    result = certify_noisy_slc(ref, noisy, state_space_size=n + 1)
    print(f"\nCertification: {result.status.value}")
    print(f"Distance: {result.coeff_distance:.6f}")
    print(f"Threshold: {result.threshold:.6f}")
    if result.preserved_gap:
        print(f"Preserved gap: {result.preserved_gap:.6f}")
    if result.mixing_time_bound:
        print(f"Mixing time bound: {result.mixing_time_bound:.2f}")
    
    # Test Glauber dynamics
    samples = glauber_dynamics(coeffs, 5000, rng=rng)
    empirical = np.bincount(samples, minlength=n + 1) / len(samples)
    tv_dist = 0.5 * np.sum(np.abs(empirical - coeffs))
    print(f"\nGlauber dynamics TV distance after 5000 samples: {tv_dist:.4f}")
    
    # Test iterated perturbation
    tracker = create_gap_tracker(gap)
    print(f"\nIterated perturbation tracking:")
    for i in range(5):
        delta = 0.005
        accepted, new_gap = apply_perturbation(tracker, delta)
        print(f"  Step {i+1}: δ={delta:.4f}, accepted={accepted}, gap={new_gap:.6f}")
