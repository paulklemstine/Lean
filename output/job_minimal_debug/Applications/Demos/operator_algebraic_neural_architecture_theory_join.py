#!/usr/bin/env python3
"""
Operator-Algebraic Deep Learning: Core Algorithms

Implements the certified robustness, GK-dimension, and spectral security
algorithms from the research paper with complete docstrings and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class CertifiedRobustnessResult:
    """Result of certified robustness computation.

    Attributes:
        rho_max: Maximum operator norm (joint spectral radius upper bound)
        lipschitz_constant: Global Lipschitz constant = rho_max^depth
        certified_radius: Adversarial robustness radius = margin / lipschitz
        depth: Network depth
        margin: Classification margin
    """
    rho_max: float
    lipschitz_constant: float
    certified_radius: float
    depth: int
    margin: float


@dataclass
class GKDimensionResult:
    """Result of GK-dimension estimation.

    Attributes:
        estimated_dim: Estimated GK-dimension
        growth_sequence: Sequence of growth function values dim(V^k)
        is_polynomial: Whether growth appears polynomial
        fitted_degree: Best-fit polynomial degree
    """
    estimated_dim: float
    growth_sequence: List[int]
    is_polynomial: bool
    fitted_degree: int


@dataclass
class SecurityCertificate:
    """Combined spectral-security certificate.

    Attributes:
        spectral_radius: Upper bound on JSR
        security_bits: Classical security parameter in bits
        quantum_security_bits: Post-quantum security parameter (Grover halving)
        lipschitz_constant: Global Lipschitz constant at given depth
        robustness_radius: Certified adversarial robustness radius
        is_contractive: Whether the system is contractive (ρ < 1)
    """
    spectral_radius: float
    security_bits: float
    quantum_security_bits: float
    lipschitz_constant: float
    robustness_radius: float
    is_contractive: bool


def compute_max_norm(weight_system: List[np.ndarray]) -> float:
    """Compute maximum operator norm ρ_max = max_{W ∈ 𝒜} ‖W‖₂.

    This is the trivial upper bound on the joint spectral radius.

    Args:
        weight_system: List of weight matrices

    Returns:
        Maximum spectral norm across all matrices

    Complexity: O(|𝒜| · n²) where n is matrix dimension
    """
    return max(np.linalg.norm(W, ord=2) for W in weight_system)


def certify_robustness(weight_system: List[np.ndarray],
                       depth: int,
                       margin: float) -> CertifiedRobustnessResult:
    """Compute certified adversarial robustness radius.

    Algorithm 1 from the paper:
    1. Compute ρ_max = max ‖W‖
    2. Compute L = ρ_max^d
    3. Return ε = margin / L

    Any perturbation δ with ‖δ‖ < ε is certified to not change classification.

    Args:
        weight_system: List of weight matrices
        depth: Network depth
        margin: Classification margin between classes

    Returns:
        CertifiedRobustnessResult with all computed quantities

    Complexity: O(|𝒜| · n²) for norm computation + O(1) arithmetic
    """
    rho = compute_max_norm(weight_system)
    lip = rho ** depth
    radius = margin / lip if lip > 0 else float('inf')

    return CertifiedRobustnessResult(
        rho_max=rho,
        lipschitz_constant=lip,
        certified_radius=radius,
        depth=depth,
        margin=margin
    )


def compute_convergence_depth(rho: float, epsilon: float) -> Optional[int]:
    """Compute minimum depth D such that ρ^D < ε.

    Algorithm 2 from the paper:
    1. Check ρ < 1 (contractive)
    2. Return D = ⌈log(ε) / log(ρ)⌉

    Args:
        rho: Spectral radius bound (must be < 1)
        epsilon: Target accuracy (must be > 0)

    Returns:
        Minimum depth D, or None if system is not contractive

    Complexity: O(1)
    """
    if rho >= 1 or rho <= 0 or epsilon <= 0:
        return None
    return int(np.ceil(np.log(epsilon) / np.log(rho)))


def estimate_gk_dimension(weight_system: List[np.ndarray],
                          max_k: int = 8) -> GKDimensionResult:
    """Estimate Gelfand-Kirillov dimension from growth of product spans.

    Algorithm 3 from the paper:
    1. For k = 1, ..., K: compute dim(V^k) = rank of span of products ≤ k
    2. Fit log(dim(V^k)) / log(k) for large k
    3. Return estimated GK-dimension

    Args:
        weight_system: List of weight matrices
        max_k: Maximum product length to consider

    Returns:
        GKDimensionResult with dimension estimate and growth sequence

    Complexity: O(K · m^K · n²) where m = |𝒜|, n = matrix size
    """
    n = weight_system[0].shape[0]
    m = len(weight_system)
    identity = np.eye(n)
    dims = []

    all_products = [identity]

    for k in range(1, max_k + 1):
        # Extend products by one more multiplication
        new_level = []
        # Only multiply the products from the previous level
        prev_level = all_products[-(m ** (k-1)) if k > 1 else 1:]
        for p in prev_level:
            for w in weight_system:
                new_level.append(p @ w)
        all_products.extend(new_level)

        # Compute dimension of span
        stacked = np.array([p.flatten() for p in all_products])
        rank = np.linalg.matrix_rank(stacked, tol=1e-8)
        dims.append(rank)

        # Early termination if dimension saturates
        if k >= 2 and dims[-1] == dims[-2]:
            break

    # Estimate GK-dimension from growth rate
    if len(dims) >= 3:
        log_dims = [np.log(max(d, 1)) for d in dims]
        log_ks = [np.log(k) for k in range(1, len(dims) + 1)]

        # Use last few points for stability
        slopes = []
        for i in range(max(0, len(log_dims) - 3), len(log_dims) - 1):
            if log_ks[i+1] - log_ks[i] > 0:
                s = (log_dims[i+1] - log_dims[i]) / (log_ks[i+1] - log_ks[i])
                slopes.append(s)
        gk_dim = np.mean(slopes) if slopes else 0.0
    else:
        gk_dim = 0.0

    # Determine if polynomial (check if growth saturates)
    is_poly = len(dims) >= 2 and dims[-1] == dims[-2]
    fitted_degree = int(round(gk_dim))

    return GKDimensionResult(
        estimated_dim=max(0, gk_dim),
        growth_sequence=dims,
        is_polynomial=is_poly,
        fitted_degree=fitted_degree
    )


def compute_security_certificate(weight_system: List[np.ndarray],
                                  depth: int,
                                  margin: float,
                                  lattice_dim: int) -> SecurityCertificate:
    """Compute combined robustness + post-quantum security certificate.

    Combines:
    - Lipschitz robustness: ‖P_d‖ ≤ ρ^d (Theorem 3.1)
    - Security parameter: ρ⁻ⁿ ≥ 1 for ρ < 1 (Theorem 6.1)
    - Quantum Grover: security halves under quantum attack

    Args:
        weight_system: List of weight matrices
        depth: Network depth for robustness computation
        margin: Classification margin
        lattice_dim: Lattice dimension for security computation

    Returns:
        SecurityCertificate with all quantities

    Complexity: O(|𝒜| · n²) + O(1)
    """
    rho = compute_max_norm(weight_system)
    lip = rho ** depth
    radius = margin / lip if lip > 0 else float('inf')

    is_contractive = rho < 1
    if is_contractive:
        sec_bits = lattice_dim * np.log2(1 / rho)
        q_bits = sec_bits / 2
    else:
        sec_bits = 0.0
        q_bits = 0.0

    return SecurityCertificate(
        spectral_radius=rho,
        security_bits=sec_bits,
        quantum_security_bits=q_bits,
        lipschitz_constant=lip,
        robustness_radius=radius,
        is_contractive=is_contractive
    )


def compute_entropy_rate(width: int, rho: float) -> float:
    """Compute thermodynamic entropy rate S = n · log(ρ).

    Args:
        width: Network width n
        rho: Spectral radius ρ (must be > 0)

    Returns:
        Entropy rate in nats

    Complexity: O(1)
    """
    if rho <= 0:
        return float('-inf')
    return width * np.log(rho)


def compute_landauer_energy(width: int, rho: float, kT: float = 4.11e-21) -> float:
    """Compute Landauer energy bound for contractive layer.

    Energy ≥ n · kT · ln(1/ρ) per forward pass (at temperature T).

    Args:
        width: Network width
        rho: Spectral radius (must be in (0, 1) for meaningful result)
        kT: Thermal energy kT in joules (default: room temperature ~300K)

    Returns:
        Minimum energy in joules per forward pass

    Complexity: O(1)
    """
    if rho <= 0 or rho >= 1:
        return 0.0
    return width * kT * np.log(1 / rho)


def residual_lipschitz_bound(epsilon: float, depth: int) -> Tuple[float, float]:
    """Compute residual network Lipschitz bounds.

    Returns both the exact bound (1+ε)^d and the exponential upper bound exp(εd).

    Args:
        epsilon: Per-layer perturbation bound
        depth: Number of residual layers

    Returns:
        Tuple of (exact_bound, exp_bound)

    Complexity: O(1)
    """
    exact = (1 + epsilon) ** depth
    exp_bound = np.exp(epsilon * depth)
    return exact, exp_bound


# ============================================================================
# Example usage
# ============================================================================
if __name__ == "__main__":
    np.random.seed(42)
    n = 5

    # Create weight system
    weights = [0.3 * np.random.randn(n, n) for _ in range(3)]
    for W in weights:
        norm = np.linalg.norm(W, ord=2)
        W *= 0.6 / max(norm, 0.6)

    # Robustness
    result = certify_robustness(weights, depth=10, margin=1.0)
    print(f"Robustness: ρ={result.rho_max:.4f}, L={result.lipschitz_constant:.4e}, "
          f"ε={result.certified_radius:.4e}")

    # GK-Dimension
    gk = estimate_gk_dimension(weights, max_k=5)
    print(f"GK-Dimension: {gk.estimated_dim:.2f}, growth={gk.growth_sequence}")

    # Security
    cert = compute_security_certificate(weights, depth=10, margin=1.0, lattice_dim=256)
    print(f"Security: {cert.security_bits:.1f} bits classical, "
          f"{cert.quantum_security_bits:.1f} bits quantum")

    # Entropy
    S = compute_entropy_rate(n, result.rho_max)
    E = compute_landauer_energy(n, result.rho_max)
    print(f"Entropy rate: {S:.4f} nats, Landauer energy: {E:.2e} J")


#!/usr/bin/env python3
"""
Operator-Algebraic Deep Learning: Real-World Applications

Demonstrates practical applications of the certified robustness,
GK-dimension, and spectral security framework.
"""

import numpy as np
from algorithms import (
    certify_robustness,
    estimate_gk_dimension,
    compute_security_certificate,
    compute_entropy_rate,
    residual_lipschitz_bound,
    compute_convergence_depth,
)


def application_autonomous_vehicle():
    """Application 1: Certified Robustness for Autonomous Vehicle Perception.

    Scenario: A stop sign classifier must be certified against adversarial
    perturbations (e.g., stickers, graffiti, weather degradation).

    We compute the certified robustness radius — the maximum L2 perturbation
    that is guaranteed not to change the classification.
    """
    print("=" * 70)
    print("APPLICATION 1: Autonomous Vehicle Stop Sign Certification")
    print("=" * 70)

    np.random.seed(42)
    n = 50  # Feature dimension

    # Simulate a 5-layer classifier with controlled Lipschitz constants
    depths = [5, 10, 20]
    margin = 2.5  # Classification margin (stop sign vs speed limit)

    print(f"\nFeature dimension: {n}")
    print(f"Classification margin: {margin}")

    for rho_target in [0.5, 0.8, 0.95, 1.05]:
        weights = []
        for _ in range(3):
            W = np.random.randn(n, n)
            W *= rho_target / np.linalg.norm(W, ord=2)
            weights.append(W)

        print(f"\n--- Target ρ = {rho_target} ---")
        for depth in depths:
            result = certify_robustness(weights, depth, margin)
            status = "✓ SAFE" if result.certified_radius > 0.1 else "⚠ MARGINAL" if result.certified_radius > 0.01 else "✗ UNSAFE"
            print(f"  Depth {depth:2d}: radius = {result.certified_radius:.4e}, "
                  f"Lipschitz = {result.lipschitz_constant:.4e} [{status}]")


def application_model_compression():
    """Application 2: Certified Neural Network Pruning via GK-Dimension.

    Scenario: A large language model needs to be compressed for edge deployment.
    GK-dimension identifies the true complexity, distinguishing architectures
    that look similar by parameter count but differ in expressive power.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Model Compression via GK-Dimension Analysis")
    print("=" * 70)

    np.random.seed(123)
    n = 4  # Small dimension for tractability

    # Architecture A: Commuting weight matrices (low complexity)
    D = [np.diag(np.random.randn(n)) for _ in range(3)]

    # Architecture B: Generic weight matrices (high complexity)
    G = [np.random.randn(n, n) for _ in range(3)]

    # Architecture C: Low-rank weight matrices (medium complexity)
    L = []
    for _ in range(3):
        u = np.random.randn(n, 2)
        v = np.random.randn(2, n)
        L.append(u @ v)

    architectures = [
        ("Diagonal (commuting)", D),
        ("Low-rank (rank 2)", L),
        ("Generic (full rank)", G),
    ]

    print(f"\nAll architectures: {len(D)} matrices of size {n}×{n}")
    print(f"Parameters per matrix: {n*n}")

    for name, weights in architectures:
        gk = estimate_gk_dimension(weights, max_k=5)
        total_params = sum(W.size for W in weights)
        print(f"\n{name}:")
        print(f"  Total parameters: {total_params}")
        print(f"  GK-dimension: {gk.estimated_dim:.2f}")
        print(f"  Growth sequence: {gk.growth_sequence}")
        print(f"  Polynomial growth: {gk.is_polynomial}")
        print(f"  → Effective complexity: {'LOW' if gk.estimated_dim < 1.5 else 'MEDIUM' if gk.estimated_dim < 3 else 'HIGH'}")


def application_post_quantum_security():
    """Application 3: Post-Quantum Security Assessment.

    Scenario: A lattice-based cryptographic system uses weight matrices
    derived from lattice bases. The spectral radius determines the
    security level against quantum adversaries.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Post-Quantum Security Assessment")
    print("=" * 70)

    np.random.seed(456)

    print(f"\n{'Lattice Dim':>11} | {'ρ':>6} | {'Classical':>10} | {'Quantum':>10} | {'Status':>10}")
    print("-" * 60)

    for lattice_dim in [128, 192, 256, 512]:
        for rho_target in [0.3, 0.5, 0.7, 0.9]:
            n = min(lattice_dim, 10)  # Simulate with smaller matrices
            weights = []
            for _ in range(2):
                W = np.random.randn(n, n)
                W *= rho_target / np.linalg.norm(W, ord=2)
                weights.append(W)

            cert = compute_security_certificate(
                weights, depth=10, margin=1.0, lattice_dim=lattice_dim
            )

            status = ("NIST-3+" if cert.quantum_security_bits >= 192
                      else "NIST-1" if cert.quantum_security_bits >= 128
                      else "WEAK" if cert.quantum_security_bits >= 64
                      else "BROKEN")
            print(f"{lattice_dim:11d} | {rho_target:6.2f} | "
                  f"{cert.security_bits:10.1f} | "
                  f"{cert.quantum_security_bits:10.1f} | {status:>10}")


def application_resnet_analysis():
    """Application 4: ResNet Lipschitz Analysis.

    Scenario: Analyzing the Lipschitz constant of a residual network
    to determine training stability and certified robustness.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Residual Network Lipschitz Analysis")
    print("=" * 70)

    print(f"\n{'ε (per-layer)':>14} | {'Depth':>6} | {'Exact Lip':>12} | {'Exp Bound':>12} | {'Tightness':>10}")
    print("-" * 62)

    for eps in [0.001, 0.01, 0.05, 0.1, 0.5]:
        for depth in [10, 50, 100, 500]:
            exact, exp_b = residual_lipschitz_bound(eps, depth)
            tightness = exact / exp_b
            print(f"{eps:14.3f} | {depth:6d} | {exact:12.4f} | {exp_b:12.4f} | {tightness:10.6f}")

    # Convergence depth analysis
    print(f"\nConvergence depth for contractive residuals (ρ = 0.99):")
    rho = 0.99
    for eps in [0.1, 0.01, 0.001, 1e-6]:
        D = compute_convergence_depth(rho, eps)
        print(f"  ε = {eps:.0e}: D = {D} layers")


def application_energy_efficiency():
    """Application 5: Thermodynamic Energy Analysis.

    Scenario: Computing the fundamental energy cost of neural network
    inference using Landauer's principle and the spectral radius.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 5: Thermodynamic Energy Analysis (Landauer Bound)")
    print("=" * 70)

    kT_room = 4.11e-21  # kT at room temperature (300K) in joules
    kT_ln2 = kT_room * np.log(2)

    print(f"\nRoom temperature kT = {kT_room:.2e} J")
    print(f"Landauer limit: {kT_ln2:.2e} J per bit erased")

    print(f"\n{'Width':>6} | {'ρ':>6} | {'Entropy (nats)':>15} | {'Bits erased':>12} | {'Energy (J)':>12} | {'W at 1GHz':>10}")
    print("-" * 75)

    for width in [100, 1000, 10000]:
        for rho in [0.1, 0.5, 0.9]:
            S = compute_entropy_rate(width, rho)
            bits_erased = -S / np.log(2)  # Convert nats to bits
            energy_per_pass = bits_erased * kT_ln2
            power_1ghz = energy_per_pass * 1e9  # Power at 1 GHz inference

            print(f"{width:6d} | {rho:6.2f} | {S:15.4f} | {bits_erased:12.2f} | "
                  f"{energy_per_pass:12.2e} | {power_1ghz:10.2e}")


if __name__ == "__main__":
    application_autonomous_vehicle()
    application_model_compression()
    application_post_quantum_security()
    application_resnet_analysis()
    application_energy_efficiency()
    print("\n" + "=" * 70)
    print("All applications complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Operator-Algebraic Deep Learning: Demonstrations

Concrete numerical examples demonstrating the certified robustness,
GK-dimension complexity, and spectral-cryptographic bridge theorems.
"""

import numpy as np
from typing import List, Tuple

def max_norm(weight_system: List[np.ndarray]) -> float:
    """Compute ρ_max = max_{W ∈ 𝒜} ‖W‖."""
    return max(np.linalg.norm(W, ord=2) for W in weight_system)

def certified_robustness_radius(weight_system: List[np.ndarray],
                                 depth: int, margin: float) -> float:
    """Compute certified adversarial robustness radius ε = margin / ρ_max^d."""
    rho = max_norm(weight_system)
    lipschitz = rho ** depth
    return margin / lipschitz

def convergence_depth(rho: float, epsilon: float) -> int:
    """Compute minimum depth D such that ρ^D < ε."""
    if rho >= 1 or epsilon <= 0:
        return -1  # Not contractive or invalid
    return int(np.ceil(np.log(epsilon) / np.log(rho)))

def gk_dimension_estimate(weight_system: List[np.ndarray],
                           max_k: int = 10) -> float:
    """Estimate GK-dimension from growth of product spans."""
    n = weight_system[0].shape[0]
    identity = np.eye(n)
    dims = []

    for k in range(1, max_k + 1):
        # Generate all products of length ≤ k
        products = [identity]
        current = [identity]
        for _ in range(k):
            new_products = []
            for p in current:
                for w in weight_system:
                    new_products.append(p @ w)
            current = new_products
            products.extend(current)

        # Stack and compute rank
        stacked = np.array([p.flatten() for p in products])
        rank = np.linalg.matrix_rank(stacked, tol=1e-8)
        dims.append(rank)

    # Fit log(dim) / log(k) for large k
    log_dims = [np.log(max(d, 1)) for d in dims]
    log_ks = [np.log(k) for k in range(1, max_k + 1)]

    if len(log_ks) >= 3:
        slope = (log_dims[-1] - log_dims[-3]) / (log_ks[-1] - log_ks[-3])
        return max(0, slope)
    return 0.0

def entropy_rate(width: int, rho: float) -> float:
    """Compute thermodynamic entropy rate S = n · log(ρ)."""
    if rho <= 0:
        return float('-inf')
    return width * np.log(rho)

def security_parameter(rho: float, n: int) -> float:
    """Compute log₂ of security parameter = n · log₂(1/ρ)."""
    if rho <= 0 or rho >= 1:
        return 0.0
    return n * np.log2(1 / rho)

# ============================================================================
# DEMO 1: Certified Robustness for Contractive Networks
# ============================================================================
print("=" * 70)
print("DEMO 1: Certified Adversarial Robustness")
print("=" * 70)

np.random.seed(42)
n = 5  # Matrix dimension

# Create a contractive weight system (all norms < 1)
W1 = 0.3 * np.random.randn(n, n)
W2 = 0.4 * np.random.randn(n, n)
W3 = 0.2 * np.random.randn(n, n)

# Scale to ensure contractive
for W in [W1, W2, W3]:
    norm = np.linalg.norm(W, ord=2)
    W *= 0.7 / max(norm, 0.7)

weight_system = [W1, W2, W3]
rho_max = max_norm(weight_system)

print(f"\nWeight system: 3 matrices of size {n}×{n}")
print(f"Individual norms: {[f'{np.linalg.norm(W, ord=2):.4f}' for W in weight_system]}")
print(f"Maximum norm (ρ_max): {rho_max:.4f}")

margin = 1.0
print(f"\nClassification margin: {margin}")
print(f"\n{'Depth':>6} | {'Lipschitz':>12} | {'Cert. Radius':>12} | {'ρ^d':>12}")
print("-" * 52)

for depth in [1, 2, 5, 10, 20, 50, 100]:
    lip = rho_max ** depth
    radius = margin / lip
    print(f"{depth:6d} | {lip:12.6e} | {radius:12.6e} | {rho_max**depth:12.6e}")

# Verify with actual random products
print(f"\nVerification: random products vs ρ_max^d bound")
for depth in [5, 10, 20]:
    norms = []
    for _ in range(1000):
        product = np.eye(n)
        for _ in range(depth):
            W = weight_system[np.random.randint(3)]
            product = W @ product
        norms.append(np.linalg.norm(product, ord=2))
    print(f"  Depth {depth:3d}: max observed = {max(norms):.6e}, "
          f"bound = {rho_max**depth:.6e}, "
          f"ratio = {max(norms)/rho_max**depth:.4f}")

# ============================================================================
# DEMO 2: Contractive Convergence Rate
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 2: Contractive Convergence (ε-close in D layers)")
print("=" * 70)

for epsilon in [0.1, 0.01, 0.001, 1e-6, 1e-10]:
    D = convergence_depth(rho_max, epsilon)
    print(f"  ε = {epsilon:.0e}: need D = {D:4d} layers, "
          f"ρ^D = {rho_max**D:.2e}")

# ============================================================================
# DEMO 3: GK-Dimension Comparison
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 3: GK-Dimension — Commuting vs Generic Matrices")
print("=" * 70)

n_gk = 3

# Commuting system: diagonal matrices
D1 = np.diag([1, 2, 3])
D2 = np.diag([4, 5, 6])
commuting_system = [D1.astype(float), D2.astype(float)]

# Generic system: random matrices
G1 = np.random.randn(n_gk, n_gk)
G2 = np.random.randn(n_gk, n_gk)
generic_system = [G1, G2]

gk_comm = gk_dimension_estimate(commuting_system, max_k=6)
gk_gen = gk_dimension_estimate(generic_system, max_k=6)

print(f"\nCommuting (diagonal) matrices:")
print(f"  GK-dimension estimate: {gk_comm:.2f}")
print(f"  Expected: ~1 (commutative algebra)")

print(f"\nGeneric (random) matrices:")
print(f"  GK-dimension estimate: {gk_gen:.2f}")
print(f"  Expected: ~2 (free algebra on 2 generators)")

# ============================================================================
# DEMO 4: Spectral-Crypto Security Bridge
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 4: Post-Quantum Security from Spectral Radius")
print("=" * 70)

print(f"\n{'ρ':>8} | {'n':>4} | {'Security bits':>14} | {'Quantum bits':>12} | {'Status':>10}")
print("-" * 60)

for rho in [0.5, 0.7, 0.9, 0.99]:
    for n_sec in [128, 256]:
        sec_bits = security_parameter(rho, n_sec)
        q_bits = sec_bits / 2  # Grover speedup
        status = "SECURE" if sec_bits >= 128 else "WEAK" if sec_bits >= 64 else "BROKEN"
        print(f"{rho:8.2f} | {n_sec:4d} | {sec_bits:14.1f} | {q_bits:12.1f} | {status:>10}")

# ============================================================================
# DEMO 5: Thermodynamic Entropy Rate
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 5: Thermodynamic Entropy Rate")
print("=" * 70)

width = 100
print(f"\nWidth n = {width}")
print(f"\n{'ρ':>8} | {'Entropy Rate':>14} | {'Regime':>12} | {'Landauer (kT)':>14}")
print("-" * 58)

for rho in [0.1, 0.5, 1.0, 1.5, 2.0]:
    S = entropy_rate(width, rho)
    regime = "Contractive" if rho < 1 else "Critical" if rho == 1 else "Expansive"
    landauer = -S if S < 0 else 0  # Energy cost = |S| for contractive
    print(f"{rho:8.2f} | {S:14.4f} | {regime:>12} | {landauer:14.4f}")

# ============================================================================
# DEMO 6: Residual Network Lipschitz Bounds
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 6: Residual Network (1+ε)^d vs exp(εd)")
print("=" * 70)

print(f"\n{'ε':>8} | {'d':>4} | {'(1+ε)^d':>14} | {'exp(εd)':>14} | {'Ratio':>8}")
print("-" * 56)

for eps in [0.01, 0.05, 0.1]:
    for d in [10, 50, 100]:
        exact = (1 + eps) ** d
        bound = np.exp(eps * d)
        print(f"{eps:8.3f} | {d:4d} | {exact:14.6f} | {bound:14.6f} | {exact/bound:8.4f}")

# Deep residual Euler limit
print(f"\nEuler limit (1+1/d)^d → e = {np.e:.6f}:")
for d in [1, 2, 5, 10, 100, 1000, 10000]:
    val = (1 + 1/d) ** d
    print(f"  d = {d:5d}: (1+1/d)^d = {val:.6f}, ratio to e = {val/np.e:.6f}")

print("\n" + "=" * 70)
print("All demonstrations complete.")
print("=" * 70)


#!/usr/bin/env python3
"""
Operator-Algebraic Deep Learning: Visualizations

Generates charts showing key mathematical structures, convergence behavior,
and cross-domain connections.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

def plot_convergence_rates():
    """Plot exponential decay for different spectral radii."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    depths = np.arange(0, 50)
    rhos = [0.3, 0.5, 0.7, 0.9, 0.95, 0.99]
    colors = plt.cm.viridis(np.linspace(0, 0.9, len(rhos)))

    for rho, color in zip(rhos, colors):
        norms = rho ** depths
        ax1.semilogy(depths, norms, color=color, label=f'ρ = {rho}', linewidth=2)

    ax1.set_xlabel('Depth d', fontsize=12)
    ax1.set_ylabel('‖P_d‖ bound (ρ^d)', fontsize=12)
    ax1.set_title('Certified Norm Decay vs Depth', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='‖P‖ = 1')

    # Plot certified robustness radius
    margin = 1.0
    for rho, color in zip(rhos, colors):
        radii = margin / (rho ** depths)
        radii[radii > 1e10] = 1e10
        ax2.semilogy(depths, radii, color=color, label=f'ρ = {rho}', linewidth=2)

    ax2.set_xlabel('Depth d', fontsize=12)
    ax2.set_ylabel('Certified Radius (M/ρ^d)', fontsize=12)
    ax2.set_title('Certified Robustness Radius vs Depth', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('convergence_rates.png', dpi=150, bbox_inches='tight')
    plt.savefig('convergence_rates.svg', bbox_inches='tight')
    plt.close()
    print("Saved: convergence_rates.png/svg")


def plot_gk_dimension():
    """Plot growth functions for different GK-dimensions."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ks = np.arange(1, 20)

    # Growth functions for different GK-dimensions
    growths = {
        'GK-dim 0 (finite)': np.minimum(5 * np.ones_like(ks), 5),
        'GK-dim 1 (linear)': 3 * ks,
        'GK-dim 2 (quadratic)': 2 * ks ** 2,
        'GK-dim 3 (cubic)': ks ** 3,
        'Exponential': 2 ** ks,
    }

    colors = ['#2ecc71', '#3498db', '#9b59b6', '#e74c3c', '#e67e22']
    for (name, growth), color in zip(growths.items(), colors):
        ax1.plot(ks, growth, 'o-', color=color, label=name, linewidth=2, markersize=4)

    ax1.set_xlabel('Product Length k', fontsize=12)
    ax1.set_ylabel('dim(V^k)', fontsize=12)
    ax1.set_title('Growth Functions by GK-Dimension', fontsize=14)
    ax1.legend(fontsize=9)
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3)

    # Log-log plot for slope estimation
    for (name, growth), color in zip(growths.items(), colors):
        if 'Exponential' not in name:
            ax2.plot(np.log(ks), np.log(growth), 'o-', color=color,
                    label=name, linewidth=2, markersize=4)

    ax2.set_xlabel('log(k)', fontsize=12)
    ax2.set_ylabel('log(dim(V^k))', fontsize=12)
    ax2.set_title('Log-Log Growth (slope = GK-dimension)', fontsize=14)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('gk_dimension.png', dpi=150, bbox_inches='tight')
    plt.savefig('gk_dimension.svg', bbox_inches='tight')
    plt.close()
    print("Saved: gk_dimension.png/svg")


def plot_security_landscape():
    """Plot post-quantum security landscape."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    rhos = np.linspace(0.01, 0.99, 100)

    # Security bits vs lattice dimension
    for n in [64, 128, 192, 256, 512]:
        sec_bits = n * np.log2(1 / rhos)
        ax1.plot(rhos, sec_bits, linewidth=2, label=f'n = {n}')

    ax1.axhline(y=128, color='red', linestyle='--', alpha=0.7, label='NIST Level 1 (128 bits)')
    ax1.axhline(y=192, color='orange', linestyle='--', alpha=0.7, label='NIST Level 3 (192 bits)')
    ax1.axhline(y=256, color='green', linestyle='--', alpha=0.7, label='NIST Level 5 (256 bits)')

    ax1.set_xlabel('Spectral Radius ρ', fontsize=12)
    ax1.set_ylabel('Classical Security (bits)', fontsize=12)
    ax1.set_title('Post-Quantum Security vs Spectral Radius', fontsize=14)
    ax1.legend(fontsize=8, loc='upper right')
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(0, 600)

    # Entropy rate
    widths = [10, 50, 100, 500]
    rhos_ent = np.linspace(0.01, 3.0, 200)

    for width in widths:
        S = width * np.log(rhos_ent)
        ax2.plot(rhos_ent, S, linewidth=2, label=f'width = {width}')

    ax2.axhline(y=0, color='black', linestyle='-', alpha=0.5)
    ax2.axvline(x=1, color='red', linestyle='--', alpha=0.7, label='ρ = 1 (critical)')
    ax2.fill_between(rhos_ent, -500, 0, where=rhos_ent < 1,
                     alpha=0.1, color='blue', label='Contractive')
    ax2.fill_between(rhos_ent, 0, 500, where=rhos_ent > 1,
                     alpha=0.1, color='red', label='Expansive')

    ax2.set_xlabel('Spectral Radius ρ', fontsize=12)
    ax2.set_ylabel('Entropy Rate S = n·log(ρ)', fontsize=12)
    ax2.set_title('Thermodynamic Entropy Rate', fontsize=14)
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(-200, 200)

    plt.tight_layout()
    plt.savefig('security_landscape.png', dpi=150, bbox_inches='tight')
    plt.savefig('security_landscape.svg', bbox_inches='tight')
    plt.close()
    print("Saved: security_landscape.png/svg")


def plot_residual_bounds():
    """Plot residual network Lipschitz bounds."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    depths = np.arange(1, 101)

    # (1+ε)^d vs exp(εd)
    for eps in [0.01, 0.05, 0.1, 0.2]:
        exact = (1 + eps) ** depths
        exp_bound = np.exp(eps * depths)
        ax1.plot(depths, exact, '-', linewidth=2, label=f'(1+{eps})^d')
        ax1.plot(depths, exp_bound, '--', linewidth=1.5, alpha=0.7, label=f'exp({eps}d)')

    ax1.set_xlabel('Depth d', fontsize=12)
    ax1.set_ylabel('Lipschitz Constant', fontsize=12)
    ax1.set_title('Residual Lipschitz: Exact vs Exponential Bound', fontsize=14)
    ax1.legend(fontsize=8, ncol=2)
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3)

    # Euler limit (1+1/d)^d → e
    ds = np.arange(1, 1001)
    euler_vals = (1 + 1/ds) ** ds
    ax2.plot(ds, euler_vals, 'b-', linewidth=2, label='(1+1/d)^d')
    ax2.axhline(y=np.e, color='red', linestyle='--', linewidth=2, label=f'e ≈ {np.e:.4f}')
    ax2.set_xlabel('Depth d', fontsize=12)
    ax2.set_ylabel('(1+1/d)^d', fontsize=12)
    ax2.set_title('Deep Residual Euler Limit', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_xscale('log')

    plt.tight_layout()
    plt.savefig('residual_bounds.png', dpi=150, bbox_inches='tight')
    plt.savefig('residual_bounds.svg', bbox_inches='tight')
    plt.close()
    print("Saved: residual_bounds.png/svg")


def plot_cross_domain_bridge():
    """Create a comprehensive cross-domain bridge diagram."""
    fig, ax = plt.subplots(figsize=(12, 8))

    # Domains as circles
    domains = {
        'Operator\nAlgebra': (0.2, 0.8),
        'Certified\nRobustness': (0.8, 0.8),
        'Post-Quantum\nSecurity': (0.8, 0.2),
        'Thermodynamic\nEntropy': (0.2, 0.2),
        'GK-Dimension\nComplexity': (0.5, 0.5),
    }

    colors = ['#3498db', '#2ecc71', '#e74c3c', '#9b59b6', '#f39c12']

    for (name, pos), color in zip(domains.items(), colors):
        circle = plt.Circle(pos, 0.12, color=color, alpha=0.3)
        ax.add_patch(circle)
        ax.text(pos[0], pos[1], name, ha='center', va='center',
               fontsize=10, fontweight='bold')

    # Bridges
    bridges = [
        ('Operator\nAlgebra', 'Certified\nRobustness', 'JSR ≤ ρ^d', '#2c3e50'),
        ('Operator\nAlgebra', 'Post-Quantum\nSecurity', 'ρ⁻ⁿ ≥ 1', '#c0392b'),
        ('Operator\nAlgebra', 'Thermodynamic\nEntropy', 'S = n·log(ρ)', '#8e44ad'),
        ('Certified\nRobustness', 'GK-Dimension\nComplexity', 'dim(A⊗B)', '#27ae60'),
        ('Post-Quantum\nSecurity', 'GK-Dimension\nComplexity', 'Growth bound', '#e67e22'),
        ('Thermodynamic\nEntropy', 'GK-Dimension\nComplexity', 'Morita inv.', '#2980b9'),
    ]

    for src, tgt, label, color in bridges:
        p1 = domains[src]
        p2 = domains[tgt]
        mid = ((p1[0]+p2[0])/2, (p1[1]+p2[1])/2)
        ax.annotate('', xy=p2, xytext=p1,
                   arrowprops=dict(arrowstyle='->', color=color,
                                 linewidth=2, alpha=0.7))
        ax.text(mid[0], mid[1]+0.03, label, ha='center', va='center',
               fontsize=8, color=color, fontweight='bold',
               bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8))

    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 1.05)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Cross-Domain Bridge Structure', fontsize=16, fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('cross_domain_bridge.png', dpi=150, bbox_inches='tight')
    plt.savefig('cross_domain_bridge.svg', bbox_inches='tight')
    plt.close()
    print("Saved: cross_domain_bridge.png/svg")


if __name__ == "__main__":
    print("Generating visualizations...")
    plot_convergence_rates()
    plot_gk_dimension()
    plot_security_landscape()
    plot_residual_bounds()
    plot_cross_domain_bridge()
    print("All visualizations generated.")
