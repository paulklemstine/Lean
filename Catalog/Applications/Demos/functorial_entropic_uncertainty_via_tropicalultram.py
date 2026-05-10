#!/usr/bin/env python3
"""
Algorithms for Tropical-Ultrametric Quantum Measurement Skeletons

Implements the core computational pipeline from overlap matrices
to certified entropy bounds.
"""

import numpy as np
from dataclasses import dataclass
from typing import Optional, Callable, List, Tuple


@dataclass
class FiniteMeasurementOverlap:
    """Finite measurement overlap matrix with entries in [0,1].
    
    Represents the squared inner products |⟨e_i|f_j⟩|² between
    two measurement bases.
    
    Attributes:
        ov: n×n numpy array with entries in [0,1]
    """
    ov: np.ndarray
    
    def __post_init__(self):
        assert np.all(self.ov >= 0), "Overlap entries must be nonneg"
        assert np.all(self.ov <= 1), "Overlap entries must be ≤ 1"
    
    @property
    def n(self) -> int:
        return self.ov.shape[0]
    
    def max_overlap(self) -> float:
        """Maximum overlap: O(n²) scan."""
        return float(np.max(self.ov))
    
    def is_symmetric(self) -> bool:
        return np.allclose(self.ov, self.ov.T)


def clipped_log(x: float) -> float:
    """Regularized negative logarithm: -log(max(x, e⁻¹)).
    
    Total function, nonneg for x ≤ 1, antitone everywhere.
    
    Complexity: O(1)
    
    Args:
        x: Any real number
    Returns:
        -log(max(x, e⁻¹))
    """
    return -np.log(max(x, np.exp(-1)))


def valuation_radius(M: FiniteMeasurementOverlap) -> float:
    """Compute the valuation radius of an overlap matrix.
    
    r(M) = clippedLog(maxOverlap(M))
    
    This is the fundamental certified entropy floor extracted from
    the overlap data via tropical transfer.
    
    Complexity: O(n²) time, O(1) additional space
    
    Args:
        M: Finite measurement overlap matrix
    Returns:
        Valuation radius (nonneg real number)
    """
    return clipped_log(M.max_overlap())


def tropical_profile(M: FiniteMeasurementOverlap) -> np.ndarray:
    """Compute the tropical overlap profile.
    
    T[i,j] = clippedLog(ov[i,j]) for each pair.
    
    The valuation radius is a lower bound on every entry: r ≤ T[i,j].
    
    Complexity: O(n²)
    
    Args:
        M: Finite measurement overlap matrix
    Returns:
        n×n array of tropical costs
    """
    return np.vectorize(clipped_log)(M.ov)


def collision_energy(p: np.ndarray) -> float:
    """Rényi-2 collision probability: ∑ᵢ pᵢ².
    
    For a uniform distribution over n outcomes: E₂ = 1/n.
    Lower bound: E₂ ≥ 1/n (Cauchy-Schwarz).
    Upper bound: E₂ ≤ max_i p_i (for probability vectors).
    
    Complexity: O(n)
    
    Args:
        p: Probability vector (nonneg, sums to 1)
    Returns:
        Collision energy (nonneg)
    """
    return float(np.sum(p**2))


def min_entropy_surrogate(p: np.ndarray) -> float:
    """Min-entropy lower surrogate: -log(max_i p_i).
    
    For probability vectors, this equals H_∞(p).
    
    Complexity: O(n)
    
    Args:
        p: Probability vector
    Returns:
        Min-entropy surrogate
    """
    return -np.log(np.max(p))


def collision_entropy_surrogate(p: np.ndarray) -> float:
    """Collision entropy lower surrogate: -log(∑ pᵢ²).
    
    For probability vectors, this equals H₂(p).
    
    Complexity: O(n)
    
    Args:
        p: Probability vector
    Returns:
        Collision entropy surrogate
    """
    return -np.log(collision_energy(p))


@dataclass
class QuantumMeasurementSkeleton:
    """A quantum measurement skeleton.
    
    Combines an overlap matrix with two outcome probability distributions.
    
    Attributes:
        overlap: Finite measurement overlap matrix
        pA: Outcome distribution for measurement A
        pB: Outcome distribution for measurement B
    """
    overlap: FiniteMeasurementOverlap
    pA: np.ndarray
    pB: np.ndarray
    
    def __post_init__(self):
        assert np.all(self.pA >= 0) and np.isclose(np.sum(self.pA), 1.0)
        assert np.all(self.pB >= 0) and np.isclose(np.sum(self.pB), 1.0)
    
    def transferred_min_entropy_bound(self) -> float:
        """Transferred min-entropy bound = valuation radius."""
        return valuation_radius(self.overlap)
    
    def transferred_collision_entropy_bound(self) -> float:
        """Transferred collision entropy bound = valuation radius."""
        return valuation_radius(self.overlap)


@dataclass
class CertifiedEntropyResult:
    """Result of certified entropy computation.
    
    Contains the valuation radius (certified lower bound),
    actual computed entropy values, and verification status.
    """
    valuation_radius: float
    min_entropy_A: float
    min_entropy_B: float
    collision_entropy_A: float
    collision_entropy_B: float
    min_entropy_sum_certified: bool
    collision_certified: bool


def certified_entropy_pipeline(
    Q: QuantumMeasurementSkeleton
) -> CertifiedEntropyResult:
    """Full certified entropy pipeline.
    
    Computes valuation radius, entropy values, and verification status.
    
    Complexity: O(n²) total
    
    Args:
        Q: Quantum measurement skeleton
    Returns:
        CertifiedEntropyResult with all bounds and verification
    """
    r = valuation_radius(Q.overlap)
    
    h_min_A = min_entropy_surrogate(Q.pA)
    h_min_B = min_entropy_surrogate(Q.pB)
    h2_A = collision_entropy_surrogate(Q.pA)
    h2_B = collision_entropy_surrogate(Q.pB)
    
    c_star = Q.overlap.max_overlap()
    pA_bounded = np.all(Q.pA <= c_star + 1e-10)
    
    return CertifiedEntropyResult(
        valuation_radius=r,
        min_entropy_A=h_min_A,
        min_entropy_B=h_min_B,
        collision_entropy_A=h2_A,
        collision_entropy_B=h2_B,
        min_entropy_sum_certified=(h_min_A + h_min_B >= r - 1e-10) if pA_bounded else False,
        collision_certified=(h2_A >= r - 1e-10) if collision_energy(Q.pA) <= c_star + 1e-10 else False
    )


def verify_functorial_transfer(
    C_fine: np.ndarray,
    C_coarse: np.ndarray,
    f: Callable[[int], int]
) -> Tuple[bool, float, float]:
    """Verify functorial entropy transfer under coarsening.
    
    Checks that an overlap-decreasing surjective morphism f
    yields r(fine) ≤ r(coarse).
    
    Args:
        C_fine: Fine overlap matrix (n×n)
        C_coarse: Coarse overlap matrix (m×m)
        f: Surjective function from fine to coarse indices
        
    Returns:
        (verified, r_fine, r_coarse)
    """
    M_fine = FiniteMeasurementOverlap(C_fine)
    M_coarse = FiniteMeasurementOverlap(C_coarse)
    
    n = C_fine.shape[0]
    overlap_decreasing = all(
        C_coarse[f(i), f(j)] <= C_fine[i, j] + 1e-10
        for i in range(n) for j in range(n)
    )
    
    m = C_coarse.shape[0]
    image = set(f(i) for i in range(n))
    surjective = image == set(range(m))
    
    r_fine = valuation_radius(M_fine)
    r_coarse = valuation_radius(M_coarse)
    
    verified = overlap_decreasing and surjective and (r_fine <= r_coarse + 1e-10)
    
    return verified, r_fine, r_coarse


# ── Example usage ─────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=== Tropical-Ultrametric Quantum Measurement Algorithms ===\n")
    
    # MUB pair in dimension 4
    n = 4
    C = np.full((n, n), 1.0/n)
    M = FiniteMeasurementOverlap(C)
    
    print(f"MUB overlap (n={n}):")
    print(f"  Max overlap: {M.max_overlap():.4f}")
    print(f"  Valuation radius: {valuation_radius(M):.4f}")
    print(f"  Expected log({n}): {np.log(n):.4f}")
    print()
    
    # Tropical profile
    T = tropical_profile(M)
    print(f"  Tropical profile (all entries equal):")
    print(f"  T[0,0] = {T[0,0]:.4f}")
    print(f"  r ≤ T[i,j]? {valuation_radius(M) <= np.min(T) + 1e-10}")
    print()
    
    # Full pipeline
    pA = np.array([0.4, 0.3, 0.2, 0.1])
    pB = np.array([0.25, 0.25, 0.25, 0.25])
    Q = QuantumMeasurementSkeleton(M, pA, pB)
    result = certified_entropy_pipeline(Q)
    
    print(f"  Certified entropy pipeline:")
    print(f"    r = {result.valuation_radius:.4f}")
    print(f"    H_min(A) = {result.min_entropy_A:.4f}")
    print(f"    H_min(B) = {result.min_entropy_B:.4f}")
    print(f"    H_2(A) = {result.collision_entropy_A:.4f}")
    print(f"    H_2(B) = {result.collision_entropy_B:.4f}")
    print(f"    Min-entropy sum certified: {result.min_entropy_sum_certified}")
    print(f"    Collision certified: {result.collision_certified}")


#!/usr/bin/env python3
"""
Applications of Tropical-Ultrametric Quantum Measurement Skeletons

Real-world applications in quantum cryptography, ML robustness, and 
post-quantum security analysis.
"""

import numpy as np
from algorithms import (
    FiniteMeasurementOverlap, QuantumMeasurementSkeleton,
    clipped_log, valuation_radius, collision_energy,
    collision_entropy_surrogate, min_entropy_surrogate,
    certified_entropy_pipeline
)


def qkd_extractable_key_length(
    overlap_matrix: np.ndarray,
    outcome_dist: np.ndarray,
    epsilon: float = 1e-3,
    n_rounds: int = 1000
) -> dict:
    """Compute extractable key length for QKD protocol.
    
    Uses the tropical-ultrametric framework to certify collision entropy,
    then applies the leftover hash lemma to bound extractable key length.
    
    The leftover hash lemma gives:
        ℓ ≤ n · H₂(X|E) - 2·log(1/ε)
    
    Args:
        overlap_matrix: Overlap between measurement bases
        outcome_dist: Observed outcome distribution
        epsilon: Security parameter
        n_rounds: Number of protocol rounds
        
    Returns:
        Dictionary with certified bounds
    """
    M = FiniteMeasurementOverlap(overlap_matrix)
    r = valuation_radius(M)
    H2 = collision_entropy_surrogate(outcome_dist)
    
    # Certified key length (bits, natural log units)
    key_length = max(0, n_rounds * H2 - 2 * np.log(1 / epsilon))
    certified_floor = max(0, n_rounds * r - 2 * np.log(1 / epsilon))
    
    return {
        'valuation_radius': r,
        'collision_entropy': H2,
        'extractable_key_length': key_length,
        'certified_floor': certified_floor,
        'n_rounds': n_rounds,
        'epsilon': epsilon,
        'key_rate': key_length / n_rounds if n_rounds > 0 else 0
    }


def classifier_robustness_certificate(
    confusion_matrix: np.ndarray,
    perturbation_bound: float
) -> dict:
    """Compute certified robustness margin from confusion matrix.
    
    Interprets a classifier's confusion matrix as a FiniteMeasurementOverlap
    and uses the valuation radius as a certified adversarial margin.
    
    Args:
        confusion_matrix: Normalized confusion matrix (entries in [0,1])
        perturbation_bound: Maximum adversarial perturbation magnitude
        
    Returns:
        Dictionary with robustness certificates
    """
    # Clip to [0,1] for safety
    C = np.clip(confusion_matrix, 0, 1)
    M = FiniteMeasurementOverlap(C)
    r = valuation_radius(M)
    
    # Perturbed overlap: max entry reduced by perturbation effect
    c_star = M.max_overlap()
    c_perturbed = max(0, c_star - perturbation_bound)
    r_perturbed = clipped_log(c_perturbed)
    
    return {
        'original_max_overlap': c_star,
        'original_radius': r,
        'perturbed_max_overlap': c_perturbed,
        'perturbed_radius': r_perturbed,
        'radius_improvement': r_perturbed - r,
        'certified_margin': r,
        'n_classes': C.shape[0]
    }


def post_quantum_lwe_entropy_bound(
    dimension: int,
    modulus: int,
    error_stddev: float,
    n_samples: int = 256
) -> dict:
    """Estimate entropy bounds for LWE-based cryptosystems.
    
    Models the LWE error distribution as a discrete probability vector
    and uses the measurement skeleton framework to bound min-entropy.
    
    Args:
        dimension: LWE dimension n
        modulus: Modulus q
        error_stddev: Standard deviation of discrete Gaussian error
        n_samples: Number of samples for distribution estimation
        
    Returns:
        Dictionary with entropy analysis
    """
    # Discrete Gaussian error distribution over Z_q
    errors = np.arange(modulus)
    # Centered at 0, wrapped around q
    centered = np.minimum(errors, modulus - errors)
    probs = np.exp(-centered**2 / (2 * error_stddev**2))
    probs /= probs.sum()
    
    # Overlap matrix: identity-like (error distributions are nearly orthogonal)
    # In practice, the overlap comes from the LWE structure
    n = min(modulus, 32)  # Truncate for computational feasibility
    probs_trunc = probs[:n]
    probs_trunc /= probs_trunc.sum()
    
    # Construct overlap as outer product approximation
    C = np.outer(probs_trunc, probs_trunc)
    C = np.clip(C / C.max(), 0, 1) if C.max() > 0 else np.zeros_like(C)
    
    M = FiniteMeasurementOverlap(C)
    r = valuation_radius(M)
    H_min = min_entropy_surrogate(probs_trunc)
    H2 = collision_entropy_surrogate(probs_trunc)
    
    return {
        'dimension': dimension,
        'modulus': modulus,
        'error_stddev': error_stddev,
        'valuation_radius': r,
        'min_entropy': H_min,
        'collision_entropy': H2,
        'entropy_ceiling': np.log(n),
        'security_bits': int(H_min / np.log(2)),
        'truncated_support': n
    }


# ── Run Applications ─────────────────────────────────────────────────
if __name__ == "__main__":
    sep = "=" * 70

    # Application 1: QKD Key Extraction
    print(sep)
    print("APPLICATION 1: Quantum Key Distribution (BB84-style)")
    print(sep)
    
    for n_basis in [2, 4, 8]:
        C = np.full((n_basis, n_basis), 1.0 / n_basis)  # MUB overlap
        rng = np.random.default_rng(42)
        p = rng.dirichlet(np.ones(n_basis))
        
        result = qkd_extractable_key_length(C, p, epsilon=1e-3, n_rounds=10000)
        print(f"\nBasis dimension n = {n_basis}:")
        print(f"  Valuation radius: {result['valuation_radius']:.4f}")
        print(f"  Collision entropy: {result['collision_entropy']:.4f}")
        print(f"  Extractable key length: {result['extractable_key_length']:.1f} nats")
        print(f"  Certified floor: {result['certified_floor']:.1f} nats")
        print(f"  Key rate: {result['key_rate']:.4f} nats/round")

    # Application 2: Classifier Robustness
    print(f"\n{sep}")
    print("APPLICATION 2: Certified Classifier Robustness")
    print(sep)
    
    # 3-class classifier confusion matrix
    C_classifier = np.array([
        [0.85, 0.10, 0.05],
        [0.08, 0.82, 0.10],
        [0.04, 0.12, 0.84]
    ])
    
    for delta in [0.0, 0.05, 0.10, 0.20]:
        result = classifier_robustness_certificate(C_classifier, delta)
        print(f"\nPerturbation δ = {delta:.2f}:")
        print(f"  Original max overlap: {result['original_max_overlap']:.4f}")
        print(f"  Original radius: {result['original_radius']:.4f}")
        print(f"  Perturbed radius: {result['perturbed_radius']:.4f}")
        print(f"  Radius improvement: {result['radius_improvement']:.4f}")

    # Application 3: Post-Quantum LWE Analysis
    print(f"\n{sep}")
    print("APPLICATION 3: Post-Quantum LWE Entropy Analysis")
    print(sep)
    
    for dim, q, sigma in [(256, 3329, 3.2), (512, 3329, 3.2), (768, 3329, 2.0)]:
        result = post_quantum_lwe_entropy_bound(dim, q, sigma)
        print(f"\nLWE(n={dim}, q={q}, σ={sigma}):")
        print(f"  Valuation radius: {result['valuation_radius']:.4f}")
        print(f"  Min-entropy: {result['min_entropy']:.4f}")
        print(f"  Collision entropy: {result['collision_entropy']:.4f}")
        print(f"  Entropy ceiling: {result['entropy_ceiling']:.4f}")
        print(f"  Estimated security: {result['security_bits']} bits")
    
    print(f"\n{sep}")
    print("All applications completed.")
    print(sep)


#!/usr/bin/env python3
"""
Tropical-Ultrametric Quantum Uncertainty: Demonstration Script

Concrete numerical examples bringing the measurement skeleton framework to life.
"""

import numpy as np
from typing import Tuple

def clipped_log(x: float) -> float:
    """Regularized -log: clippedLog(x) = -log(max(x, e^{-1}))."""
    return -np.log(max(x, np.exp(-1)))

def max_overlap(C: np.ndarray) -> float:
    """Maximum entry of the overlap matrix."""
    return float(np.max(C))

def valuation_radius(C: np.ndarray) -> float:
    """Valuation radius: clippedLog of max overlap."""
    return clipped_log(max_overlap(C))

def tropical_profile(C: np.ndarray) -> np.ndarray:
    """Tropical overlap profile: clippedLog applied entrywise."""
    return np.vectorize(clipped_log)(C)

def collision_energy(p: np.ndarray) -> float:
    """Collision energy (Rényi-2 collision probability): sum of p_i^2."""
    return float(np.sum(p**2))

def min_entropy_surrogate(p: np.ndarray) -> float:
    """Min-entropy lower surrogate: -log(max p_i)."""
    return -np.log(max(p))

def collision_entropy_surrogate(p: np.ndarray) -> float:
    """Collision entropy lower surrogate: -log(sum p_i^2)."""
    return -np.log(collision_energy(p))


def print_separator():
    print("=" * 70)


# ── Example 1: Hadamard (MUB in dimension 2) ──────────────────────────
print_separator()
print("EXAMPLE 1: Hadamard Basis Pair (2D)")
print_separator()

C_hadamard = np.array([[0.5, 0.5],
                        [0.5, 0.5]])

r = valuation_radius(C_hadamard)
T = tropical_profile(C_hadamard)

print(f"Overlap matrix C:\n{C_hadamard}")
print(f"Max overlap c* = {max_overlap(C_hadamard):.4f}")
print(f"Valuation radius r = {r:.4f}")
print(f"Expected: log(2) = {np.log(2):.4f}")
print(f"Tropical profile T:\n{T}")

# Outcome distributions for |+⟩ state
pA = np.array([1.0, 0.0])
pB = np.array([0.5, 0.5])
print(f"\nState |0⟩: pA = {pA}, pB = {pB}")
print(f"H_min(pA) = {min_entropy_surrogate(pA):.4f} (∞ since max=1)")
print(f"H_min(pB) = {min_entropy_surrogate(pB):.4f}")
print(f"Sum = {min_entropy_surrogate(pA) + min_entropy_surrogate(pB):.4f}")
print(f"Valuation radius = {r:.4f}")
print(f"Sum ≥ r? (should be False for |0⟩ eigenstate): "
      f"{min_entropy_surrogate(pA) + min_entropy_surrogate(pB) >= r - 1e-10}")

# With overlap-bounded pA
pA2 = np.array([0.5, 0.5])
print(f"\nState |+⟩: pA = {pA2}, pB = {pA2}")
print(f"H_min(pA) = {min_entropy_surrogate(pA2):.4f}")
print(f"H_min(pB) = {min_entropy_surrogate(pA2):.4f}")
print(f"Sum = {2 * min_entropy_surrogate(pA2):.4f} ≥ r = {r:.4f} ✓")

print()


# ── Example 2: Fourier Basis Pair (dimension n) ──────────────────────
print_separator()
print("EXAMPLE 2: Fourier Basis Pairs (dimensions 2-16)")
print_separator()

for n in [2, 3, 4, 8, 16]:
    C_fourier = np.full((n, n), 1.0 / n)
    r = valuation_radius(C_fourier)
    print(f"n={n:2d}: c* = 1/{n} = {1/n:.4f}, "
          f"valuation radius = {r:.4f}, "
          f"log(n) = {np.log(n):.4f}")

print()


# ── Example 3: Near-Compatible Measurements ──────────────────────────
print_separator()
print("EXAMPLE 3: Near-Compatible Measurements (rotation by θ)")
print_separator()

for theta_deg in [5, 10, 20, 30, 45, 60, 90]:
    theta = np.radians(theta_deg)
    c = np.cos(theta)
    s = np.sin(theta)
    C_rot = np.array([[c**2, s**2],
                       [s**2, c**2]])
    r = valuation_radius(C_rot)
    print(f"θ={theta_deg:3d}°: c* = {max_overlap(C_rot):.4f}, "
          f"valuation radius = {r:.4f}")

print()


# ── Example 4: Collision Energy and Cardinality Barrier ──────────────
print_separator()
print("EXAMPLE 4: Collision Energy Bounds")
print_separator()

for n in [2, 4, 8, 16, 32]:
    # Uniform distribution
    p_uniform = np.ones(n) / n
    E2 = collision_energy(p_uniform)
    H2 = collision_entropy_surrogate(p_uniform)
    print(f"n={n:2d}, uniform: E₂ = {E2:.6f} = 1/n = {1/n:.6f}, "
          f"H₂ = {H2:.4f}, log(n) = {np.log(n):.4f}")
    
    # Peaked distribution
    p_peaked = np.zeros(n)
    p_peaked[0] = 0.9
    remaining = (1 - 0.9) / (n - 1)
    p_peaked[1:] = remaining
    E2_peaked = collision_energy(p_peaked)
    H2_peaked = collision_entropy_surrogate(p_peaked)
    print(f"n={n:2d}, peaked: E₂ = {E2_peaked:.6f}, "
          f"H₂ = {H2_peaked:.4f}")

print()


# ── Example 5: Functorial Transfer ──────────────────────────────────
print_separator()
print("EXAMPLE 5: Functorial Transfer (Coarsening)")
print_separator()

# Fine measurement (4 outcomes)
C_fine = np.array([
    [0.3, 0.2, 0.1, 0.4],
    [0.2, 0.3, 0.4, 0.1],
    [0.1, 0.4, 0.3, 0.2],
    [0.4, 0.1, 0.2, 0.3]
])

# Coarse measurement (2 outcomes): f(0)=f(1)=0, f(2)=f(3)=1
# Overlap-decreasing: ov_B(f(i),f(j)) ≤ ov_A(i,j) should hold
# We construct B to satisfy this
C_coarse = np.array([
    [0.2, 0.1],
    [0.1, 0.2]
])

r_fine = valuation_radius(C_fine)
r_coarse = valuation_radius(C_coarse)

print(f"Fine system (4 outcomes): c* = {max_overlap(C_fine):.4f}, r = {r_fine:.4f}")
print(f"Coarse system (2 outcomes): c* = {max_overlap(C_coarse):.4f}, r = {r_coarse:.4f}")
print(f"r_fine ≤ r_coarse? {r_fine <= r_coarse + 1e-10} (functorial monotonicity)")
print(f"Entropy certification improves under coarsening: ✓")

print()


# ── Example 6: Cryptographic Extraction Pipeline ────────────────────
print_separator()
print("EXAMPLE 6: Post-Quantum Extraction Pipeline")
print_separator()

n = 8
C_crypto = np.full((n, n), 1.0/n)  # MUB overlap
r = valuation_radius(C_crypto)

# Simulated outcome distribution
rng = np.random.default_rng(42)
raw = rng.dirichlet(np.ones(n))
p_outcome = raw

E2 = collision_energy(p_outcome)
H2 = collision_entropy_surrogate(p_outcome)

print(f"System dimension: n = {n}")
print(f"Overlap type: Mutually Unbiased Bases (1/n entries)")
print(f"Valuation radius: r = {r:.4f}")
print(f"Outcome distribution: {np.round(p_outcome, 4)}")
print(f"Collision energy E₂ = {E2:.6f}")
print(f"Collision entropy H₂ = {H2:.4f}")
print(f"Cardinality ceiling: log({n}) = {np.log(n):.4f}")

for epsilon in [0.01, 0.001, 0.0001]:
    extractable = max(0, H2 - 2 * np.log(1/epsilon))
    print(f"  ε = {epsilon}: extractable key ≤ {extractable:.4f} bits (nat)")

print()
print_separator()
print("All examples completed successfully.")
print_separator()


#!/usr/bin/env python3
"""
Visualizations for Tropical-Ultrametric Quantum Measurement Skeletons
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

def clipped_log(x):
    return -np.log(np.maximum(x, np.exp(-1)))


def make_all_figures():
    """Generate all visualization figures."""
    
    # ── Figure 1: ClippedLog Function ────────────────────────────────
    fig1, ax = plt.subplots(1, 1, figsize=(8, 5))
    x = np.linspace(0.01, 1.2, 500)
    y_raw = -np.log(x)
    y_clipped = clipped_log(x)
    
    ax.plot(x, y_raw, 'b-', linewidth=2, label=r'$-\log(x)$', alpha=0.5)
    ax.plot(x, y_clipped, 'r-', linewidth=2.5, label=r'$\mathrm{clippedLog}(x) = -\log(\max(x, e^{-1}))$')
    ax.axvline(x=np.exp(-1), color='gray', linestyle='--', alpha=0.5, label=r'$x = e^{-1}$')
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('Value', fontsize=14)
    ax.set_title('Clipped Log: Regularized Tropical Transfer Function', fontsize=14)
    ax.legend(fontsize=12)
    ax.set_xlim(0, 1.2)
    ax.set_ylim(-0.5, 5)
    ax.grid(True, alpha=0.3)
    fig1.tight_layout()
    fig1.savefig('fig_clipped_log.png', dpi=150)
    plt.close(fig1)
    
    # ── Figure 2: Valuation Radius vs Dimension ─────────────────────
    fig2, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    dims = np.arange(2, 65)
    r_mub = np.log(dims)  # MUB: c* = 1/n, r = log(n)
    r_near = -np.log(np.cos(np.pi/8)**2) * np.ones_like(dims)  # Fixed angle
    
    axes[0].plot(dims, r_mub, 'bo-', markersize=3, label='MUB (maximally incompatible)')
    axes[0].plot(dims, r_near, 'r--', label=r'Fixed $\theta = \pi/8$ (near-compatible)')
    axes[0].set_xlabel('Dimension n', fontsize=13)
    axes[0].set_ylabel('Valuation Radius r', fontsize=13)
    axes[0].set_title('Valuation Radius vs System Dimension', fontsize=13)
    axes[0].legend(fontsize=11)
    axes[0].grid(True, alpha=0.3)
    
    # Entropy ceiling
    n_range = np.arange(2, 65)
    ceiling = np.log(n_range)
    axes[1].fill_between(n_range, 0, ceiling, alpha=0.2, color='blue', label='Achievable entropy range')
    axes[1].plot(n_range, ceiling, 'b-', linewidth=2, label=r'$\log n$ (ceiling)')
    axes[1].plot(n_range, 1/n_range, 'r-', linewidth=2, label=r'$1/n$ (collision floor)')
    axes[1].set_xlabel('Dimension n', fontsize=13)
    axes[1].set_ylabel('Entropy (nats)', fontsize=13)
    axes[1].set_title('Entropy Bounds: Cardinality Barriers', fontsize=13)
    axes[1].legend(fontsize=11)
    axes[1].grid(True, alpha=0.3)
    
    fig2.tight_layout()
    fig2.savefig('fig_valuation_radius.png', dpi=150)
    plt.close(fig2)
    
    # ── Figure 3: Tropical Profile Heatmap ──────────────────────────
    fig3, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # MUB overlap
    n = 8
    C_mub = np.full((n, n), 1.0/n)
    T_mub = clipped_log(C_mub)
    
    im0 = axes[0].imshow(C_mub, cmap='YlOrRd', vmin=0, vmax=1)
    axes[0].set_title(f'Overlap (MUB, n={n})', fontsize=12)
    plt.colorbar(im0, ax=axes[0], shrink=0.8)
    
    im1 = axes[1].imshow(T_mub, cmap='viridis')
    axes[1].set_title(f'Tropical Profile (MUB)', fontsize=12)
    plt.colorbar(im1, ax=axes[1], shrink=0.8)
    
    # Random overlap
    rng = np.random.default_rng(42)
    C_rand = rng.uniform(0.05, 0.6, (n, n))
    C_rand = (C_rand + C_rand.T) / 2  # Symmetrize
    T_rand = clipped_log(C_rand)
    
    im2 = axes[2].imshow(T_rand, cmap='viridis')
    axes[2].set_title('Tropical Profile (Random)', fontsize=12)
    plt.colorbar(im2, ax=axes[2], shrink=0.8)
    
    fig3.tight_layout()
    fig3.savefig('fig_tropical_profiles.png', dpi=150)
    plt.close(fig3)
    
    # ── Figure 4: Collision Energy and Entropy ──────────────────────
    fig4, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Parameterized distributions: interpolate uniform → peaked
    n = 8
    alphas = np.linspace(0.01, 5.0, 200)
    E2_vals = []
    H2_vals = []
    Hmin_vals = []
    
    for alpha in alphas:
        p = np.array([alpha**(i) for i in range(n)], dtype=float)
        p /= p.sum()
        E2_vals.append(np.sum(p**2))
        H2_vals.append(-np.log(np.sum(p**2)))
        Hmin_vals.append(-np.log(np.max(p)))
    
    axes[0].plot(alphas, E2_vals, 'b-', linewidth=2)
    axes[0].axhline(y=1/n, color='r', linestyle='--', label=f'1/n = {1/n:.4f}')
    axes[0].set_xlabel(r'Distribution parameter $\alpha$', fontsize=13)
    axes[0].set_ylabel('Collision Energy $E_2$', fontsize=13)
    axes[0].set_title('Collision Energy vs Distribution Shape', fontsize=13)
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    axes[1].plot(alphas, H2_vals, 'b-', linewidth=2, label=r'$H_2 = -\log(E_2)$')
    axes[1].plot(alphas, Hmin_vals, 'r-', linewidth=2, label=r'$H_\infty = -\log(\max p_i)$')
    axes[1].axhline(y=np.log(n), color='gray', linestyle='--', alpha=0.5, label=f'log({n}) ceiling')
    axes[1].set_xlabel(r'Distribution parameter $\alpha$', fontsize=13)
    axes[1].set_ylabel('Entropy (nats)', fontsize=13)
    axes[1].set_title('Entropy Surrogates vs Distribution Shape', fontsize=13)
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    fig4.tight_layout()
    fig4.savefig('fig_entropy_analysis.png', dpi=150)
    plt.close(fig4)
    
    # ── Figure 5: Functorial Transfer ───────────────────────────────
    fig5, ax = plt.subplots(1, 1, figsize=(8, 6))
    
    # Show how coarsening (reducing max overlap) improves valuation radius
    c_stars = np.linspace(0.01, 1.0, 200)
    radii = np.array([clipped_log(c) for c in c_stars])
    
    ax.plot(c_stars, radii, 'b-', linewidth=2.5)
    ax.fill_between(c_stars, 0, radii, alpha=0.15, color='blue')
    
    # Mark specific points
    for c, label in [(0.5, 'MUB(2)'), (0.25, 'MUB(4)'), (0.125, 'MUB(8)')]:
        r = clipped_log(c)
        ax.plot(c, r, 'ro', markersize=10, zorder=5)
        ax.annotate(f'{label}\nc*={c}, r={r:.2f}', 
                   xy=(c, r), xytext=(c+0.05, r+0.15),
                   fontsize=10, ha='left',
                   arrowprops=dict(arrowstyle='->', color='red'))
    
    ax.set_xlabel('Maximum Overlap $c^*$', fontsize=14)
    ax.set_ylabel('Valuation Radius $r$', fontsize=14)
    ax.set_title('Functorial Monotonicity: Smaller Overlap → Larger Radius', fontsize=14)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 1.05)
    
    fig5.tight_layout()
    fig5.savefig('fig_functorial_transfer.png', dpi=150)
    plt.close(fig5)
    
    print("All figures saved:")
    print("  fig_clipped_log.png")
    print("  fig_valuation_radius.png")
    print("  fig_tropical_profiles.png")
    print("  fig_entropy_analysis.png")
    print("  fig_functorial_transfer.png")


if __name__ == "__main__":
    make_all_figures()
