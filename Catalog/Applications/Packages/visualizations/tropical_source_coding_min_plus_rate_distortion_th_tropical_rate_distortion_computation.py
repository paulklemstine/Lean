"""
Tropical Rate-Distortion Algorithms

Implements the core computational procedures from the tropical rate-distortion
theory, including optimal code computation, dual transform evaluation,
and tropical Blahut-Arimoto style iteration.
"""

from typing import List, Tuple, Optional
import itertools


def tropical_distortion_profile(
    phi: List[float],
    d: List[List[float]],
    y: int
) -> float:
    """
    Compute the tropical distortion profile at reproduction symbol y.

    ψ(y) = max_x (φ(x) - d(x, y))

    This is the worst-case net cost when encoding to symbol y.

    Args:
        phi: Source potential φ : α → ℝ (list of length |α|)
        d: Distortion kernel d : α × β → ℝ (|α| × |β| matrix)
        y: Reproduction symbol index

    Returns:
        The profile value ψ(y)

    Time complexity: O(|α|)
    Space complexity: O(1)

    >>> tropical_distortion_profile([3.0, 1.0], [[0, 2], [2, 0]], 0)
    3.0
    >>> tropical_distortion_profile([3.0, 1.0], [[0, 2], [2, 0]], 1)
    1.0
    """
    n_alpha = len(phi)
    return max(phi[x] - d[x][y] for x in range(n_alpha))


def tropical_rate_distortion(
    phi: List[float],
    d: List[List[float]],
    D: float
) -> float:
    """
    Compute the tropical rate-distortion function.

    R(D) = min_y ψ(y) - D = min_y max_x (φ(x) - d(x,y)) - D

    Args:
        phi: Source potential
        d: Distortion kernel
        D: Distortion budget

    Returns:
        The rate-distortion value R(D)

    Time complexity: O(|α| × |β|)
    Space complexity: O(|β|)

    >>> tropical_rate_distortion([3.0, 1.0], [[0, 2], [2, 0]], 0)
    1.0
    """
    n_beta = len(d[0])
    profiles = [tropical_distortion_profile(phi, d, y) for y in range(n_beta)]
    return min(profiles) - D


def optimal_reproduction_symbol(
    phi: List[float],
    d: List[List[float]]
) -> Tuple[int, float]:
    """
    Find the optimal reproduction symbol y* that minimizes ψ(y).

    y* = argmin_y max_x (φ(x) - d(x, y))

    This is the symbol that achieves the rate-distortion bound.

    Args:
        phi: Source potential
        d: Distortion kernel

    Returns:
        Tuple of (optimal y index, profile value ψ(y*))

    Time complexity: O(|α| × |β|)

    >>> optimal_reproduction_symbol([3.0, 1.0], [[0, 2], [2, 0]])
    (1, 1.0)
    """
    n_beta = len(d[0])
    best_y = 0
    best_val = tropical_distortion_profile(phi, d, 0)
    for y in range(1, n_beta):
        val = tropical_distortion_profile(phi, d, y)
        if val < best_val:
            best_val = val
            best_y = y
    return best_y, best_val


def tropical_feasible_check(
    phi: List[float],
    d: List[List[float]],
    D: float,
    r: float
) -> Optional[int]:
    """
    Check if rate r is feasible at distortion budget D.

    A rate r is feasible if ∃ y : ∀ x, φ(x) - r ≤ d(x,y) + D.

    Args:
        phi: Source potential
        d: Distortion kernel
        D: Distortion budget
        r: Rate to check

    Returns:
        Index of witnessing y if feasible, None otherwise.

    Time complexity: O(|α| × |β|)

    >>> tropical_feasible_check([3.0, 1.0], [[0, 2], [2, 0]], 0, 1.0)
    1
    """
    n_alpha = len(phi)
    n_beta = len(d[0])
    for y in range(n_beta):
        if all(phi[x] - r <= d[x][y] + D + 1e-12 for x in range(n_alpha)):
            return y
    return None


def tropical_dual_functional(
    phi: List[float],
    d: List[List[float]],
    mu: float
) -> float:
    """
    Compute the tropical dual functional.

    F(μ) = min_y max_x (φ(x) - μ · d(x, y))

    This is the Lagrangian relaxation of the rate-distortion problem.

    Args:
        phi: Source potential
        d: Distortion kernel
        mu: Dual variable (Lagrange multiplier)

    Returns:
        The dual functional value F(μ)

    Time complexity: O(|α| × |β|)
    """
    n_alpha = len(phi)
    n_beta = len(d[0])
    return min(
        max(phi[x] - mu * d[x][y] for x in range(n_alpha))
        for y in range(n_beta)
    )


def tropical_legendre_fenchel(
    phi: List[float],
    d: List[List[float]],
    D: float,
    mu_values: List[float]
) -> float:
    """
    Compute the tropical rate-distortion via Legendre-Fenchel transform.

    R_LF(D) = max_μ (F(μ) - μ · D)

    where F(μ) = min_y max_x (φ(x) - μ · d(x,y)).

    Args:
        phi: Source potential
        d: Distortion kernel
        D: Distortion budget
        mu_values: Set of dual parameters to optimize over

    Returns:
        The Legendre-Fenchel transform value

    Time complexity: O(|μ_values| × |α| × |β|)
    """
    return max(
        tropical_dual_functional(phi, d, mu) - mu * D
        for mu in mu_values
    )


def tropical_covering_radius(
    phi: List[float],
    d: List[List[float]],
    y: int
) -> float:
    """
    Compute the covering radius of reproduction symbol y.

    This is the minimum D such that y is a feasible code at rate 0:
    D_cover(y) = max_x (φ(x) - d(x, y))

    Equivalently, this is the distortion profile ψ(y).

    Args:
        phi: Source potential
        d: Distortion kernel
        y: Reproduction symbol index

    Returns:
        The covering radius

    >>> tropical_covering_radius([3.0, 1.0], [[0, 2], [2, 0]], 1)
    1.0
    """
    return tropical_distortion_profile(phi, d, y)


def tropical_rate_distortion_curve(
    phi: List[float],
    d: List[List[float]],
    D_values: List[float]
) -> List[Tuple[float, float, int]]:
    """
    Compute the full rate-distortion curve with optimal witnesses.

    For each D, returns (D, R(D), y*) where y* is the optimal symbol.

    Args:
        phi: Source potential
        d: Distortion kernel
        D_values: List of distortion budgets to evaluate

    Returns:
        List of (D, R(D), optimal_y) tuples
    """
    results = []
    for D in D_values:
        y_star, psi_star = optimal_reproduction_symbol(phi, d)
        R = psi_star - D
        results.append((D, R, y_star))
    return results


# =============================================================================
# Demonstration
# =============================================================================
if __name__ == "__main__":
    print("Tropical Rate-Distortion Algorithms")
    print("=" * 50)

    # Binary example
    phi = [3.0, 1.0]
    d = [[0.0, 2.0], [2.0, 0.0]]

    y_star, psi_star = optimal_reproduction_symbol(phi, d)
    print(f"\nBinary source: optimal y* = {y_star}, ψ(y*) = {psi_star}")

    # Verify Legendre-Fenchel
    mus = [i * 0.1 for i in range(0, 51)]
    for D in [0.0, 0.5, 1.0, 2.0]:
        R_primal = tropical_rate_distortion(phi, d, D)
        R_lf = tropical_legendre_fenchel(phi, d, D, mus)
        print(f"  D={D}: R_primal={R_primal:.4f}, R_LF={R_lf:.4f}")

    # Feasibility check
    print("\nFeasibility checks:")
    for r in [2.0, 1.0, 0.5, 0.0, -1.0]:
        witness = tropical_feasible_check(phi, d, 0, r)
        print(f"  r={r:5.1f}, D=0: feasible={witness is not None}"
              + (f" (witness y={witness})" if witness is not None else ""))
