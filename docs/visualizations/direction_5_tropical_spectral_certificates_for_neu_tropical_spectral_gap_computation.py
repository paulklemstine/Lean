"""
Tropical Spectral Certificates — Core Algorithms

Implements the verified algorithms from the Lean formalization for computing
tropical spectral gaps and certified robustness radii.
"""

import numpy as np
from typing import Tuple, Optional


def tropical_spectral_gap(Q: np.ndarray) -> float:
    """Compute the tropical spectral gap (Gershgorin margin) of a matrix.

    For each row i, computes Q[i,i] - sum_{j≠i} |Q[i,j]|, then returns
    the minimum over all rows.

    This is the O(n²) combinatorial certificate that replaces O(n³) eigenvalue
    computation.

    Args:
        Q: A square matrix (n×n numpy array).

    Returns:
        The tropical spectral gap γ. If γ > 0, the matrix is strictly
        diagonally dominant and hence positive definite (when symmetric).

    Example:
        >>> Q = np.array([[5.0, 1.0], [1.0, 4.0]])
        >>> tropical_spectral_gap(Q)
        3.0
    """
    n = Q.shape[0]
    gaps = []
    for i in range(n):
        off_diag_sum = sum(abs(Q[i, j]) for j in range(n) if j != i)
        gaps.append(Q[i, i] - off_diag_sum)
    return min(gaps)


def certified_robust_radius(
    Q: np.ndarray,
    R: float,
    rho: float,
    use_eigenvalue: bool = False,
) -> Tuple[float, dict]:
    """Compute a certified robustness radius from a curvature surrogate matrix.

    Implements the verified algorithm:
    1. Compute tropical gap γ from matrix entries
    2. Use γ as coercivity constant α
    3. Solve 2R·r² ≤ α for the maximum valid r
    4. Return min(r, ρ)

    Args:
        Q: Symmetric curvature surrogate matrix (n×n).
        R: Upper bound on quartic remainder term.
        rho: Localization radius.
        use_eigenvalue: If True, also compute classical eigenvalue-based radius.

    Returns:
        Tuple of (certified_radius, info_dict) where info_dict contains:
        - 'gamma': the tropical spectral gap
        - 'alpha': the coercivity constant used
        - 'r_tropical': radius from tropical certificate
        - 'r_eigenvalue': radius from eigenvalue certificate (if computed)

    Example:
        >>> Q = np.array([[5.0, 1.0], [1.0, 4.0]])
        >>> r, info = certified_robust_radius(Q, R=0.1, rho=10.0)
        >>> print(f"Certified radius: {r:.4f}")
    """
    gamma = tropical_spectral_gap(Q)
    info = {'gamma': gamma}

    if gamma <= 0:
        info['alpha'] = 0.0
        info['r_tropical'] = 0.0
        if use_eigenvalue:
            eigvals = np.linalg.eigvalsh(Q)
            alpha_eig = float(eigvals.min())
            if alpha_eig > 0 and R > 0:
                info['r_eigenvalue'] = min(np.sqrt(alpha_eig / (2 * R)), rho)
            elif alpha_eig > 0:
                info['r_eigenvalue'] = rho
            else:
                info['r_eigenvalue'] = 0.0
        return 0.0, info

    alpha = gamma  # Bridge theorem: tropical gap = coercivity lower bound
    info['alpha'] = alpha

    if R > 0:
        r_tropical = min(np.sqrt(alpha / (2 * R)), rho)
    else:
        r_tropical = rho

    info['r_tropical'] = r_tropical

    if use_eigenvalue:
        eigvals = np.linalg.eigvalsh(Q)
        alpha_eig = float(eigvals.min())
        info['alpha_eigenvalue'] = alpha_eig
        if alpha_eig > 0 and R > 0:
            info['r_eigenvalue'] = min(np.sqrt(alpha_eig / (2 * R)), rho)
        elif alpha_eig > 0:
            info['r_eigenvalue'] = rho
        else:
            info['r_eigenvalue'] = 0.0

    return r_tropical, info


def energy_barrier_height(
    alpha: float,
    R: float,
    r: float,
) -> float:
    """Compute the energy barrier height at radius r.

    From the energy barrier theorem:
    If R·r² ≤ α/4, then E(x+h) ≥ E(x) + (α/4)·r².

    Args:
        alpha: Coercivity constant.
        R: Remainder bound.
        r: Radius.

    Returns:
        The barrier height (α/4)·r² if the condition holds, else a weaker bound.
    """
    if R * r**2 <= alpha / 4:
        return (alpha / 4) * r**2
    else:
        # Weaker bound: (α/2)r² - R·r⁴
        return max(0.0, (alpha / 2) * r**2 - R * r**4)


def trust_region_margin(
    G: float,
    alpha: float,
) -> float:
    """Compute the trust-region worst-case margin.

    From the trust-region theorem:
    min_{s≥0} [-G·s + (α/2)·s²] = -G²/(2α)

    Args:
        G: Gradient norm bound.
        alpha: Coercivity constant.

    Returns:
        The worst-case margin -G²/(2α).
    """
    if alpha <= 0:
        return float('-inf')
    return -G**2 / (2 * alpha)


def exponential_certified_radius(
    Q: np.ndarray,
    C0: float,
    R: float,
    rho: float,
) -> Tuple[float, dict]:
    """Compute certified radius using exponential bridge.

    Uses the exponential bridge: α ≥ C₀·exp(γ).

    Args:
        Q: Symmetric curvature surrogate matrix.
        C0: Exponential bridge constant.
        R: Remainder bound.
        rho: Localization radius.

    Returns:
        Tuple of (certified_radius, info_dict).
    """
    gamma = tropical_spectral_gap(Q)
    alpha_exp = C0 * np.exp(gamma)
    info = {
        'gamma': gamma,
        'alpha_exp': alpha_exp,
        'C0': C0,
    }

    if alpha_exp <= 0 or R <= 0:
        r = rho if alpha_exp > 0 else 0.0
    else:
        r = min(np.sqrt(alpha_exp / (2 * R)), rho)

    info['r_exp'] = r
    return r, info


def lipschitz_certified_radius(
    L: float,
    margin: float,
) -> float:
    """Compute Lipschitz-based certified radius (baseline).

    Simple baseline: r = margin / L.

    Args:
        L: Lipschitz constant of the function.
        margin: Current function margin f(x).

    Returns:
        Certified radius margin/L.
    """
    if L <= 0:
        return float('inf') if margin > 0 else 0.0
    return max(0.0, margin / L)


def generate_diag_dominant_matrix(
    n: int,
    gap: float,
    off_diag_scale: float = 1.0,
    seed: int = 42,
) -> np.ndarray:
    """Generate a random symmetric diagonally dominant matrix with given gap.

    Args:
        n: Matrix dimension.
        gap: Target tropical spectral gap.
        off_diag_scale: Scale of off-diagonal entries.
        seed: Random seed.

    Returns:
        Symmetric n×n matrix with tropical gap ≈ gap.
    """
    rng = np.random.RandomState(seed)
    Q = off_diag_scale * rng.randn(n, n)
    Q = (Q + Q.T) / 2  # symmetrize

    # Set diagonal to ensure gap
    for i in range(n):
        off_sum = sum(abs(Q[i, j]) for j in range(n) if j != i)
        Q[i, i] = off_sum + gap

    return Q


if __name__ == "__main__":
    print("=== Tropical Spectral Certificates — Algorithm Demo ===\n")

    # Example 1: 3x3 matrix
    Q = generate_diag_dominant_matrix(3, gap=2.0, seed=42)
    print(f"Matrix Q (3×3):\n{Q}\n")

    gamma = tropical_spectral_gap(Q)
    print(f"Tropical spectral gap: γ = {gamma:.4f}")

    r, info = certified_robust_radius(Q, R=0.5, rho=5.0, use_eigenvalue=True)
    print(f"Certified radius (tropical): {r:.4f}")
    print(f"Certified radius (eigenvalue): {info.get('r_eigenvalue', 'N/A'):.4f}")
    print(f"Min eigenvalue: {info.get('alpha_eigenvalue', 'N/A'):.4f}")
    print()

    # Example 2: Energy barrier
    barrier = energy_barrier_height(gamma, R=0.5, r=1.0)
    print(f"Energy barrier at r=1.0: {barrier:.4f}")
    print()

    # Example 3: Trust region
    margin = trust_region_margin(G=1.0, alpha=gamma)
    print(f"Trust-region margin (G=1, α={gamma:.2f}): {margin:.4f}")
