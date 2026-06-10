"""
Algorithms for L₂ Certified Robustness via Quadratic Forms

Implements the core algorithms from the research paper:
- Local radius computation from operator norms
- Global radius assembly from local certificates
- Comparability constant verification
- Anisotropic perturbation set computation
"""

import numpy as np
from typing import List, Tuple, Optional


def operator_norm(A: np.ndarray) -> float:
    """Compute the operator norm (largest singular value) of a matrix.

    Args:
        A: An m×n matrix.

    Returns:
        ‖A‖ = σ_max(A), the largest singular value.

    Time complexity: O(min(m,n) * mn) via SVD.
    """
    if A.size == 0:
        return 0.0
    return np.linalg.norm(A, ord=2)


def local_certified_radius(A: np.ndarray, margin: float) -> float:
    """Compute the local certified L₂ radius for a single affine region.

    Given a linear operator A and a positive margin m, the certified
    radius is m / ‖A‖. Any perturbation v with ‖v‖ < r guarantees
    ‖Av‖ < m, hence the classifier prediction is preserved.

    Args:
        A: The linear part of the affine map on this region.
        margin: The classification margin (score gap) at the point. Must be > 0.

    Returns:
        The certified radius m / ‖A‖, or float('inf') if ‖A‖ = 0.

    Corresponds to Theorem A (norm_lt_margin_of_operator_bound).
    """
    assert margin > 0, "Margin must be positive"
    norm_A = operator_norm(A)
    if norm_A == 0.0:
        return float('inf')
    return margin / norm_A


def global_certified_radius(
    operators: List[np.ndarray],
    margins: List[float],
    region_membership: List[int]
) -> float:
    """Compute the global certified L₂ radius over all covering regions.

    For a point x belonging to regions specified by region_membership,
    computes the minimum local radius across all covering regions.

    Args:
        operators: List of linear operators A_i, one per region.
        margins: List of margins m_i(x), one per region.
        region_membership: Indices of regions containing the point x.

    Returns:
        The global certified radius min_i r_i(x).

    Corresponds to the main theorem
    (l2_certified_robustness_of_comparable_quadratic_local_sections).
    """
    assert len(region_membership) > 0, "Point must belong to at least one region"
    radii = []
    for i in region_membership:
        r = local_certified_radius(operators[i], margins[i])
        radii.append(r)
    return min(radii)


def verify_comparability(
    A: np.ndarray,
    B: np.ndarray,
    c: float
) -> bool:
    """Verify that Q_A ≤ c · Q_B, i.e., ‖Av‖² ≤ c‖Bv‖² for all v.

    This is equivalent to checking that A^T A - c B^T B is negative
    semidefinite (all eigenvalues ≤ 0).

    Args:
        A: First operator.
        B: Second operator.
        c: Comparability constant (must be ≥ 1).

    Returns:
        True if Q_A ≤ c · Q_B.

    Time complexity: O(n³) for eigendecomposition.
    """
    assert c >= 1.0, "Comparability constant must be ≥ 1"
    M = A.T @ A - c * B.T @ B
    eigenvalues = np.linalg.eigvalsh(M)
    return bool(np.all(eigenvalues <= 1e-10))  # numerical tolerance


def find_comparability_constant(A: np.ndarray, B: np.ndarray) -> float:
    """Find the smallest c ≥ 1 such that Q_A ≤ c · Q_B.

    This is the generalized eigenvalue problem: find the maximum
    of the Rayleigh quotient ‖Av‖²/‖Bv‖² over all v where Bv ≠ 0.

    Args:
        A: First operator.
        B: Second operator.

    Returns:
        The optimal comparability constant c*, or float('inf') if
        B has a nontrivial kernel not contained in ker(A).
    """
    AtA = A.T @ A
    BtB = B.T @ B

    # Solve generalized eigenvalue problem AtA v = λ BtB v
    try:
        eigenvalues = np.linalg.eigvalsh(np.linalg.solve(BtB, AtA))
        c = max(1.0, float(np.max(eigenvalues)))
        return c
    except np.linalg.LinAlgError:
        # B is singular; check if ker(B) ⊆ ker(A)
        _, s, Vt = np.linalg.svd(B)
        null_dim = np.sum(s < 1e-10)
        if null_dim > 0:
            null_space = Vt[-null_dim:]
            for v in null_space:
                if np.linalg.norm(A @ v) > 1e-10:
                    return float('inf')
        # Fall back to numerical optimization
        return _numerical_comparability(A, B)


def _numerical_comparability(A: np.ndarray, B: np.ndarray, n_samples: int = 1000) -> float:
    """Estimate comparability constant numerically via random sampling."""
    n = A.shape[1]
    max_ratio = 1.0
    for _ in range(n_samples):
        v = np.random.randn(n)
        v = v / np.linalg.norm(v)
        Av_norm_sq = np.linalg.norm(A @ v) ** 2
        Bv_norm_sq = np.linalg.norm(B @ v) ** 2
        if Bv_norm_sq > 1e-15:
            ratio = Av_norm_sq / Bv_norm_sq
            max_ratio = max(max_ratio, ratio)
    return max_ratio


def anisotropic_perturbation_volume(A: np.ndarray, margin: float) -> float:
    """Compute the volume of the anisotropic perturbation set {v : ‖Av‖ < m}.

    The set is an ellipsoid with semi-axes m/σ_i where σ_i are singular
    values of A. Its volume is proportional to ∏(m/σ_i).

    Args:
        A: Linear operator.
        margin: Classification margin.

    Returns:
        The volume of the ellipsoidal perturbation set (up to the
        volume of the unit ball constant).

    Returns float('inf') if A has zero singular values.
    """
    _, s, _ = np.linalg.svd(A)
    if np.any(s < 1e-15):
        return float('inf')
    # Volume proportional to product of semi-axes
    semi_axes = margin / s
    return float(np.prod(semi_axes))


def isotropic_perturbation_volume(A: np.ndarray, margin: float, n: int) -> float:
    """Compute the volume of the isotropic (spherical) perturbation set.

    The isotropic radius is m/‖A‖ = m/σ_max. The volume is proportional
    to (m/σ_max)^n.

    Args:
        A: Linear operator.
        margin: Classification margin.
        n: Dimension.

    Returns:
        Volume proportional to (m/σ_max)^n.
    """
    norm_A = operator_norm(A)
    if norm_A == 0:
        return float('inf')
    return (margin / norm_A) ** n


def volume_gain_ratio(A: np.ndarray, margin: float) -> float:
    """Compute the ratio of anisotropic to isotropic perturbation volume.

    This measures how much larger the ellipsoidal certificate is compared
    to the spherical certificate. The ratio equals ∏(σ_max/σ_i).

    Args:
        A: Linear operator.
        margin: Classification margin.

    Returns:
        The volume gain ratio ≥ 1.
    """
    _, s, _ = np.linalg.svd(A)
    s = s[s > 1e-15]  # remove zero singular values
    if len(s) == 0:
        return 1.0
    return float(np.prod(s[0] / s))


if __name__ == "__main__":
    # Example usage
    np.random.seed(42)
    n = 3

    # Create a random operator with condition number ~10
    U, _, Vt = np.linalg.svd(np.random.randn(n, n))
    singular_values = np.array([10.0, 3.0, 1.0])
    A = U @ np.diag(singular_values) @ Vt

    margin = 2.0

    print("=== Local Certificate Example ===")
    print(f"Operator norm: {operator_norm(A):.4f}")
    print(f"Singular values: {singular_values}")
    print(f"Margin: {margin}")
    print(f"Isotropic radius: {local_certified_radius(A, margin):.4f}")
    print(f"Anisotropic volume / isotropic volume: {volume_gain_ratio(A, margin):.4f}")

    # Create a second operator for comparability test
    B = U @ np.diag([8.0, 4.0, 1.5]) @ Vt
    c = find_comparability_constant(A, B)
    print(f"\nComparability constant c(A,B): {c:.4f}")
    print(f"Verified c-comparable: {verify_comparability(A, B, c + 0.01)}")
