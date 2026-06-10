"""
Spectral-Compression Complexity (SCC) Algorithms for Deep Network Generalization

Implements the key algorithms from the SCC framework:
1. Spectral profile computation from weight matrices
2. SCC computation
3. Generalization bound calculation
4. Compression gap estimation
"""

import math
from dataclasses import dataclass
from typing import List, Tuple

import numpy as np


@dataclass
class SpectralProfile:
    """Spectral profile of a deep neural network.

    Attributes:
        spectral_norms: Spectral norm (largest singular value) of each layer.
        frobenius_norms: Frobenius norm of each layer.
        margin: Classification margin (min gap between correct and next-best logit).
        depth: Number of layers.
    """
    spectral_norms: List[float]
    frobenius_norms: List[float]
    margin: float

    @property
    def depth(self) -> int:
        return len(self.spectral_norms)

    def validate(self) -> None:
        """Check that the profile satisfies all structural constraints."""
        assert len(self.spectral_norms) == len(self.frobenius_norms), \
            "spectral_norms and frobenius_norms must have the same length"
        assert all(s > 0 for s in self.spectral_norms), \
            "All spectral norms must be positive"
        assert all(f >= s for f, s in zip(self.frobenius_norms, self.spectral_norms)), \
            "Frobenius norm must be >= spectral norm for each layer"
        assert self.margin > 0, "Margin must be positive"


def compute_spectral_profile(weight_matrices: List[np.ndarray],
                              margin: float) -> SpectralProfile:
    """Compute the spectral profile from a list of weight matrices.

    Args:
        weight_matrices: List of 2D numpy arrays (layer weight matrices).
        margin: Classification margin.

    Returns:
        SpectralProfile with computed norms.

    Time complexity: O(sum_i d_i * d_{i+1} * min(d_i, d_{i+1})) for SVD.
    """
    spectral_norms: List[float] = []
    frobenius_norms: List[float] = []

    for W in weight_matrices:
        # Spectral norm = largest singular value
        s = np.linalg.svd(W, compute_uv=False)
        spectral_norms.append(float(s[0]))

        # Frobenius norm = sqrt(sum of squared entries)
        frobenius_norms.append(float(np.linalg.norm(W, 'fro')))

    return SpectralProfile(
        spectral_norms=spectral_norms,
        frobenius_norms=frobenius_norms,
        margin=margin
    )


def effective_rank(profile: SpectralProfile, layer: int) -> float:
    """Compute the effective rank of a specific layer.

    Effective rank = (Frobenius / spectral)^2.
    Always >= 1, equals 1 iff the weight matrix is rank-1.

    Args:
        profile: Spectral profile of the network.
        layer: Layer index (0-based).

    Returns:
        Effective rank (float >= 1).
    """
    ratio = profile.frobenius_norms[layer] / profile.spectral_norms[layer]
    return ratio ** 2


def total_effective_rank(profile: SpectralProfile) -> float:
    """Compute total effective rank across all layers.

    Always >= depth (number of layers).
    """
    return sum(effective_rank(profile, i) for i in range(profile.depth))


def spectral_complexity(profile: SpectralProfile) -> float:
    """Compute the spectral complexity: product of spectral norms / margin.

    This measures how much the network amplifies perturbations
    relative to its decision confidence.
    """
    prod = 1.0
    for s in profile.spectral_norms:
        prod *= s
    return prod / profile.margin


def spectral_compression_complexity(profile: SpectralProfile) -> float:
    """Compute the Spectral-Compression Complexity (SCC).

    SCC = L^2 * R_eff * C_spec^2

    where L is depth, R_eff is total effective rank,
    and C_spec is spectral complexity.
    """
    L = profile.depth
    R_eff = total_effective_rank(profile)
    C_spec = spectral_complexity(profile)
    return L**2 * R_eff * C_spec**2


def scc_generalization_bound(profile: SpectralProfile,
                              n: int,
                              delta: float) -> float:
    """Compute the SCC-based generalization bound.

    bound = sqrt(SCC * ln(2n) / n + ln(1/delta) / n)

    Args:
        profile: Spectral profile of the network.
        n: Number of training samples.
        delta: Confidence parameter (0 < delta < 1).

    Returns:
        Upper bound on the generalization gap.
    """
    scc = spectral_compression_complexity(profile)
    inner = scc * math.log(2 * n) / n + math.log(1 / delta) / n
    return math.sqrt(max(0, inner))


def compression_gap(k: int, n: int, delta: float) -> float:
    """Compute the compression-based generalization gap.

    gap = sqrt((k * ln(2) + ln(1/delta)) / (2n))

    Args:
        k: Number of compression bits.
        n: Number of training samples.
        delta: Confidence parameter (0 < delta < 1).

    Returns:
        Compression-based bound on the generalization gap.
    """
    inner = (k * math.log(2) + math.log(1 / delta)) / (2 * n)
    return math.sqrt(max(0, inner))


def double_descent_witness(gamma: float) -> Tuple[SpectralProfile, SpectralProfile]:
    """Construct the double descent witness profiles.

    Returns two profiles (P1, P2) where:
    - P1 has 2 layers, rank-1 matrices, totalEffectiveRank = 2
    - P2 has 1 layer, high effective rank = 100, totalEffectiveRank = 100
    - SCC(P2) < SCC(P1), demonstrating that more parameters can help

    Args:
        gamma: Classification margin (must be > 0).

    Returns:
        Tuple (P1, P2) of SpectralProfile.
    """
    # P1: 2-layer, rank-1, spectral norms = 10
    p1 = SpectralProfile(
        spectral_norms=[10.0, 10.0],
        frobenius_norms=[10.0, 10.0],
        margin=gamma
    )

    # P2: 1-layer, high effective rank
    p2 = SpectralProfile(
        spectral_norms=[1.0],
        frobenius_norms=[10.0],
        margin=gamma
    )

    return p1, p2


def scc_regularized_gradient(weight_matrices: List[np.ndarray],
                              gradients: List[np.ndarray],
                              margin: float,
                              lambda_reg: float) -> List[np.ndarray]:
    """Compute SCC-regularized gradient update.

    Returns g + lambda * grad_W(SCC) for each layer.

    Args:
        weight_matrices: Current weight matrices.
        gradients: Loss gradients for each layer.
        margin: Current classification margin.
        lambda_reg: Regularization strength.

    Returns:
        List of regularized gradients.
    """
    profile = compute_spectral_profile(weight_matrices, margin)
    scc = spectral_compression_complexity(profile)
    regularized: List[np.ndarray] = []

    for i, (W, g) in enumerate(zip(weight_matrices, gradients)):
        # Approximate gradient of SCC w.r.t. W_i
        # SCC = L^2 * R_eff * C_spec^2
        # Dominant term: gradient of spectral norm
        U, s, Vt = np.linalg.svd(W, full_matrices=False)
        # Gradient of spectral norm = u_1 * v_1^T
        grad_spectral = np.outer(U[:, 0], Vt[0, :])

        # Scale by chain rule factor
        C_spec = spectral_complexity(profile)
        R_eff = total_effective_rank(profile)
        L = profile.depth
        prod_others = C_spec * margin / profile.spectral_norms[i]
        chain_factor = 2 * L**2 * R_eff * C_spec * prod_others / margin

        regularized.append(g + lambda_reg * chain_factor * grad_spectral)

    return regularized
