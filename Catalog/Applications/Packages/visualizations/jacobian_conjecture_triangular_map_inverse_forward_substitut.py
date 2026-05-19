"""
Algorithms for Polynomial Map Analysis
=======================================

Implements algorithms related to the Jacobian Conjecture:
- Jacobian matrix computation for polynomial maps
- Triangular map inverse by forward substitution
- Stable lift construction
- Drużkowski map evaluation and Jacobian analysis
"""

import numpy as np
from typing import List, Tuple, Callable, Optional
from dataclasses import dataclass
from functools import reduce


@dataclass
class PolynomialMap:
    """A polynomial map k^n -> k^n represented as a callable with metadata."""
    n: int
    evaluate: Callable[[np.ndarray], np.ndarray]
    name: str = "F"

    def __call__(self, x: np.ndarray) -> np.ndarray:
        return self.evaluate(x)


def numerical_jacobian(F: Callable, x: np.ndarray, eps: float = 1e-8) -> np.ndarray:
    """Compute the Jacobian matrix of F at x numerically.

    Uses central differences for O(eps^2) accuracy.

    Args:
        F: Polynomial map k^n -> k^n
        x: Point at which to evaluate the Jacobian
        eps: Step size for finite differences

    Returns:
        n×n Jacobian matrix J where J[i,j] = ∂F_i/∂x_j

    Time complexity: O(n) evaluations of F
    Space complexity: O(n²)
    """
    n = len(x)
    J = np.zeros((n, n))
    for j in range(n):
        e_j = np.zeros(n)
        e_j[j] = eps
        J[:, j] = (F(x + e_j) - F(x - e_j)) / (2 * eps)
    return J


def triangular_inverse(
    coeffs: List[float],
    lower_parts: List[Callable],
    x: np.ndarray
) -> np.ndarray:
    """Compute the inverse of a triangular polynomial map by forward substitution.

    For a triangular map F where F_i = a_i * x_i + P_i(x_0,...,x_{i-1}),
    the inverse is computed by solving for each x_i in order:
        x_i = (y_i - P_i(x_0,...,x_{i-1})) / a_i

    Args:
        coeffs: Diagonal coefficients [a_0, a_1, ..., a_{n-1}], all nonzero
        lower_parts: Functions P_i(x_0,...,x_{i-1}) for each component
        x: Input point (the "y" values from F(original_x) = y)

    Returns:
        The original point original_x such that F(original_x) = y

    Time complexity: O(n * T) where T = max time to evaluate any P_i
    Space complexity: O(n)

    Example:
        >>> # F(x,y) = (2x + 1, 3y + x^2)
        >>> coeffs = [2.0, 3.0]
        >>> lower_parts = [lambda v: 1.0, lambda v: v[0]**2]
        >>> y = np.array([7.0, 12.0])  # F(3, 1) = (7, 12)
        >>> triangular_inverse(coeffs, lower_parts, y)
        array([3., 1.])
    """
    n = len(coeffs)
    result = np.zeros(n)
    for i in range(n):
        p_val = lower_parts[i](result[:i]) if i > 0 else lower_parts[i](np.array([]))
        result[i] = (x[i] - p_val) / coeffs[i]
    return result


def stable_lift(
    F: Callable[[np.ndarray], np.ndarray],
    n: int,
    m: int
) -> Callable[[np.ndarray], np.ndarray]:
    """Construct the stable lift F↑m of a polynomial map F : k^n -> k^n.

    The stable lift appends m identity coordinates:
    F↑m(x_1,...,x_n, y_1,...,y_m) = (F(x_1,...,x_n), y_1,...,y_m)

    Args:
        F: Original polynomial map on k^n
        n: Dimension of original space
        m: Number of identity coordinates to append

    Returns:
        The lifted map on k^(n+m)

    Time complexity: O(T_F) where T_F = time to evaluate F
    Space complexity: O(n + m)

    Mathematical property (proved in our formalization):
    - F is invertible ⟺ F↑m is invertible
    - det(J(F↑m)) = det(J(F)) (as a polynomial)
    """
    def lifted(v: np.ndarray) -> np.ndarray:
        result = np.zeros(n + m)
        result[:n] = F(v[:n])
        result[n:] = v[n:]
        return result
    return lifted


def druzkowski_map(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Evaluate a Drużkowski map F(x) = x + (Ax)^{[3]}.

    Here (v)^{[3]} denotes coordinatewise cubing: (v_1^3, ..., v_n^3).

    Args:
        A: n×n matrix defining the Drużkowski map
        x: Input point

    Returns:
        F(x) = x + (Ax)^{[3]}

    Time complexity: O(n²) for matrix multiply + O(n) for cubing
    Space complexity: O(n)
    """
    Ax = A @ x
    return x + Ax**3


def druzkowski_jacobian(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Compute the exact Jacobian of a Drużkowski map.

    J(F)(x) = I + 3 * diag((Ax)^2) * A

    Args:
        A: n×n matrix defining the Drużkowski map
        x: Point at which to evaluate

    Returns:
        The Jacobian matrix

    Time complexity: O(n²)
    Space complexity: O(n²)
    """
    n = len(x)
    Ax = A @ x
    return np.eye(n) + 3 * np.diag(Ax**2) @ A


def check_keller_condition(
    F: Callable,
    n: int,
    num_samples: int = 100,
    tol: float = 1e-6
) -> Tuple[bool, float]:
    """Check whether a polynomial map satisfies the Keller condition numerically.

    The Keller condition states that det(JF) is a nonzero constant.

    Args:
        F: Polynomial map to check
        n: Dimension
        num_samples: Number of random points to sample
        tol: Tolerance for constant-ness check

    Returns:
        (is_keller, det_value): Whether the condition appears to hold,
        and the constant determinant value

    Note: This is a heuristic check. A passing result does not constitute
    a proof of the Keller condition.
    """
    dets = []
    for _ in range(num_samples):
        x = np.random.randn(n)
        J = numerical_jacobian(F, x)
        dets.append(np.linalg.det(J))

    dets = np.array(dets)
    mean_det = np.mean(dets)
    is_constant = np.std(dets) < tol * abs(mean_det) if abs(mean_det) > tol else np.std(dets) < tol
    is_nonzero = abs(mean_det) > tol

    return is_constant and is_nonzero, mean_det


def compose_polynomial_maps(
    F: Callable[[np.ndarray], np.ndarray],
    G: Callable[[np.ndarray], np.ndarray]
) -> Callable[[np.ndarray], np.ndarray]:
    """Compose two polynomial maps: (F ∘ G)(x) = F(G(x)).

    Args:
        F, G: Polynomial maps

    Returns:
        The composition F ∘ G

    Mathematical property (proved in our formalization):
    - Composition is associative: (F ∘ G) ∘ H = F ∘ (G ∘ H)
    - If F and G are automorphisms, so is F ∘ G
    """
    return lambda x: F(G(x))


if __name__ == "__main__":
    # Example: triangular map inverse
    print("=== Triangular Map Inverse ===")
    coeffs = [2.0, 3.0, 1.0]
    lower_parts = [
        lambda v: 1.0,        # P_0 = 1 (constant)
        lambda v: v[0]**2,     # P_1 = x_0^2
        lambda v: v[0]*v[1],   # P_2 = x_0 * x_1
    ]

    original = np.array([3.0, 1.0, 5.0])
    # F(3, 1, 5) = (2*3+1, 3*1+9, 5+3*1) = (7, 12, 8)
    forward = np.array([
        coeffs[0]*original[0] + 1.0,
        coeffs[1]*original[1] + original[0]**2,
        coeffs[2]*original[2] + original[0]*original[1],
    ])
    recovered = triangular_inverse(coeffs, lower_parts, forward)
    print(f"Original: {original}")
    print(f"F(original): {forward}")
    print(f"Inverse(F(original)): {recovered}")
    print(f"Error: {np.linalg.norm(original - recovered):.2e}")

    # Example: Keller condition check
    print("\n=== Keller Condition Check ===")
    A = np.array([[0., 1.], [0., 0.]])  # Nilpotent
    F_druz = lambda x: druzkowski_map(A, x)
    is_keller, det_val = check_keller_condition(F_druz, 2)
    print(f"Drużkowski map with nilpotent A: Keller = {is_keller}, det ≈ {det_val:.4f}")
