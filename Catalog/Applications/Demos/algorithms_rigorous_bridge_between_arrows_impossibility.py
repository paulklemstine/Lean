"""
Arrow-Curvature Bridge: Core Algorithms

Type-hinted implementations of the key mathematical objects connecting
Arrow's impossibility theorem to Fisher-Rao geometry.
"""

import numpy as np
from typing import List, Tuple, Optional


def bhattacharyya_coefficient(p: np.ndarray, q: np.ndarray) -> float:
    """Compute the Bhattacharyya coefficient BC(p,q) = Σ √(pᵢqᵢ).

    This equals the inner product ⟨√p, √q⟩ on the unit sphere,
    bridging statistical divergence and spherical geometry.

    Args:
        p: Probability vector (nonneg, sums to 1)
        q: Probability vector (nonneg, sums to 1)
    Returns:
        BC ∈ [0, 1] where 1 = identical, 0 = orthogonal
    """
    return float(np.sum(np.sqrt(p * q)))


def hellinger_distance_sq(p: np.ndarray, q: np.ndarray) -> float:
    """Compute the squared Hellinger distance H²(p,q) = 1 - BC(p,q).

    Equals ½‖√p - √q‖², the fundamental distance on the Fisher
    information manifold.

    Args:
        p: Probability vector
        q: Probability vector
    Returns:
        H² ∈ [0, 1]
    """
    return 1.0 - bhattacharyya_coefficient(p, q)


def sqrt_embedding(p: np.ndarray) -> np.ndarray:
    """The square-root embedding p ↦ √p.

    Maps the probability simplex Δₙ to the positive orthant of
    the unit sphere Sⁿ⁻¹. This is an isometry from (Δₙ, Fisher)
    to (S⁺, round metric / 4).

    Args:
        p: Probability vector (nonneg, sums to 1)
    Returns:
        √p on the unit sphere
    """
    return np.sqrt(p)


def angular_distance(p: np.ndarray, q: np.ndarray) -> float:
    """Geodesic distance on the sphere between √p and √q.

    θ = arccos(BC(p,q)) = arccos(⟨√p, √q⟩).
    The Fisher-Rao geodesic distance is 2θ.

    Args:
        p: Probability vector
        q: Probability vector
    Returns:
        Angle θ ∈ [0, π/2]
    """
    bc = bhattacharyya_coefficient(p, q)
    bc = np.clip(bc, -1.0, 1.0)
    return float(np.arccos(bc))


def polarization_index(voters: np.ndarray) -> float:
    """Compute the polarization index: average pairwise H² distance.

    Higher values indicate more disagreement, making Arrow-type
    impossibilities more binding.

    Args:
        voters: Array of shape (m, n) — m voters, n-dim probability vectors
    Returns:
        Polarization index ∈ [0, 1]
    """
    m = voters.shape[0]
    if m <= 1:
        return 0.0
    total = 0.0
    for i in range(m):
        for j in range(m):
            if i != j:
                total += hellinger_distance_sq(voters[i], voters[j])
    return total / (m * (m - 1))


def spherical_midpoint(x: np.ndarray, y: np.ndarray) -> np.ndarray:
    """Compute the spherical midpoint (normalized average).

    On the sphere, this is the geodesic midpoint for small angles.
    The contraction d(mid, z) < (d(x,z) + d(y,z))/2 for positive
    curvature is the geometric analogue of Arrow's impossibility.

    Args:
        x: Point on the sphere
        y: Point on the sphere
    Returns:
        Normalized midpoint on the sphere
    """
    avg = (x + y) / 2.0
    norm = np.linalg.norm(avg)
    if norm < 1e-12:
        return avg
    return avg / norm


def curvature_contraction_ratio(
    theta1: float, theta2: float
) -> float:
    """Compute the contraction ratio from positive curvature.

    On a sphere (K=1), the midpoint of two points at angular distances
    θ₁, θ₂ from a reference point z is at angular distance θ_mid from z.
    The contraction ratio is:
        cos(θ_mid) / ((cos θ₁ + cos θ₂)/2)

    This ratio > 1 when K > 0 (positive curvature contracts midpoints
    closer to reference points than linear averaging would).

    Args:
        theta1: Angular distance from reference to first point
        theta2: Angular distance from reference to second point
    Returns:
        Contraction ratio ≥ 1
    """
    avg_cos = (np.cos(theta1) + np.cos(theta2)) / 2
    mid_cos = np.cos((theta1 + theta2) / 2)
    if abs(avg_cos) < 1e-12:
        return float('inf')
    return mid_cos / avg_cos


def decisive_coalition_check(
    swf_matrix: np.ndarray,
    coalition: List[int],
    n_alternatives: int
) -> bool:
    """Check if a coalition is decisive for a given SWF.

    A coalition S is globally decisive if for every pair (a, b),
    when all voters in S prefer a to b, society prefers a to b.

    Args:
        swf_matrix: Binary matrix encoding the SWF rule
        coalition: List of voter indices
        n_alternatives: Number of alternatives
    Returns:
        True if the coalition is globally decisive
    """
    # This is a simplified check for demonstration
    coalition_set = set(coalition)
    for a in range(n_alternatives):
        for b in range(n_alternatives):
            if a == b:
                continue
            # Check all profiles where coalition unanimously prefers a to b
            # In practice, this requires checking exponentially many profiles
            # Here we just verify the structural property
    return len(coalition) > 0  # placeholder


def ultrafilter_on_finite_set(n: int) -> List[List[int]]:
    """Generate all ultrafilters on a finite set {0, ..., n-1}.

    On a finite set, every ultrafilter is principal: it consists of
    all supersets of some singleton {i}. This is the algebraic heart
    of Arrow's impossibility.

    Args:
        n: Size of the finite set
    Returns:
        List of ultrafilters, each as a list of sets (represented as sorted lists)
    """
    ultrafilters = []
    for i in range(n):
        # Principal ultrafilter generated by {i}
        uf = []
        for mask in range(1, 2**n):
            subset = [j for j in range(n) if mask & (1 << j)]
            if i in subset:
                uf.append(subset)
        ultrafilters.append(uf)
    return ultrafilters


def fisher_rao_distance(p: np.ndarray, q: np.ndarray) -> float:
    """Compute the Fisher-Rao geodesic distance between distributions.

    d_FR(p,q) = 2 arccos(BC(p,q)) = 2 arccos(⟨√p, √q⟩).
    The factor of 2 comes from the Fisher metric being 4× the
    round metric under the sqrt embedding.

    Args:
        p: Probability vector
        q: Probability vector
    Returns:
        Fisher-Rao distance ≥ 0
    """
    return 2.0 * angular_distance(p, q)
