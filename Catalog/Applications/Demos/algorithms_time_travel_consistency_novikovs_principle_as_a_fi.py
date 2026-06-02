#!/usr/bin/env python3
"""
Algorithms for Novikov Self-Consistency via Fixed-Point Iteration

Type-hinted implementations of the core algorithms from the formalization.
"""

from typing import Callable, Tuple, Optional, List
import math


def banach_iterate(
    f: Callable[[float], float],
    x0: float,
    K: float,
    tol: float = 1e-12,
    max_iter: int = 10000,
) -> Tuple[float, int, List[float]]:
    """
    Find the fixed point of a contraction mapping f with Lipschitz constant K < 1.

    Uses the Banach iteration x_{n+1} = f(x_n).

    Args:
        f: The contracting map.
        x0: Initial guess.
        K: Lipschitz constant (must be < 1).
        tol: Convergence tolerance.
        max_iter: Maximum iterations.

    Returns:
        (fixed_point, iterations, trajectory) where trajectory is the
        sequence of iterates.

    Raises:
        ValueError: If K >= 1.
    """
    if K >= 1.0:
        raise ValueError(f"Lipschitz constant K={K} must be < 1 for contraction")

    trajectory: List[float] = [x0]
    x = x0
    for n in range(max_iter):
        x_new = f(x)
        trajectory.append(x_new)
        if abs(x_new - x) < tol * (1 - K):
            return x_new, n + 1, trajectory
        x = x_new

    return x, max_iter, trajectory


def affine_fixed_point(a: float, b: float) -> float:
    """
    Compute the exact fixed point of f(x) = ax + b with |a| < 1.

    The fixed point is x* = b / (1 - a).

    Args:
        a: Slope coefficient with |a| < 1.
        b: Intercept.

    Returns:
        The unique fixed point b / (1 - a).

    Raises:
        ValueError: If |a| >= 1.
    """
    if abs(a) >= 1.0:
        raise ValueError(f"|a| = {abs(a)} must be < 1")
    return b / (1.0 - a)


def compose_causal_maps(
    f1: Callable[[float], float],
    K1: float,
    f2: Callable[[float], float],
    K2: float,
) -> Tuple[Callable[[float], float], float]:
    """
    Compose two causal maps and compute the composed Lipschitz constant.

    Args:
        f1: First causal map.
        K1: Lipschitz constant of f1.
        f2: Second causal map.
        K2: Lipschitz constant of f2.

    Returns:
        (f2 ∘ f1, K1 * K2) — the composed map and its Lipschitz constant.

    Raises:
        ValueError: If K1 * K2 >= 1.
    """
    K_composed = K1 * K2
    if K_composed >= 1.0:
        raise ValueError(
            f"Composed Lipschitz constant K1*K2 = {K_composed} must be < 1"
        )

    def composed(x: float) -> float:
        return f2(f1(x))

    return composed, K_composed


def convergence_bound(K: float, initial_dist: float, n: int) -> float:
    """
    Compute the stability/convergence bound K^n * d(x, y).

    After n iterations of a K-contraction, two trajectories starting
    distance d apart are at most K^n * d apart.

    Args:
        K: Contraction constant (0 <= K < 1).
        initial_dist: Initial distance between trajectories.
        n: Number of iterations.

    Returns:
        Upper bound on distance after n iterations.
    """
    return (K ** n) * initial_dist


def iterations_to_precision(K: float, diameter: float, epsilon: float) -> int:
    """
    Compute the number of iterations needed to achieve precision epsilon.

    Args:
        K: Contraction constant.
        diameter: Diameter of the initial search region.
        epsilon: Desired precision.

    Returns:
        Minimum number of iterations n such that K^n * diameter <= epsilon.
    """
    if K <= 0 or K >= 1:
        raise ValueError(f"K = {K} must be in (0, 1)")
    if epsilon <= 0:
        raise ValueError("epsilon must be positive")
    if diameter <= 0:
        return 0
    return math.ceil(math.log(epsilon / diameter) / math.log(K))


def polynomial_contraction_check(
    coeffs: List[float],
    domain: Tuple[float, float],
    num_samples: int = 1000,
) -> Tuple[bool, float]:
    """
    Check if a polynomial is a contraction on a given domain.

    Estimates the maximum |p'(x)| on the domain by sampling.

    Args:
        coeffs: Polynomial coefficients [a_0, a_1, ..., a_n] for
                p(x) = a_0 + a_1*x + ... + a_n*x^n.
        domain: (lo, hi) interval.
        num_samples: Number of sample points.

    Returns:
        (is_contraction, max_derivative) — whether |p'| < 1 on the domain,
        and the estimated maximum value of |p'|.
    """
    lo, hi = domain
    max_deriv = 0.0

    # Derivative coefficients
    deriv_coeffs = [coeffs[k] * k for k in range(1, len(coeffs))]

    for i in range(num_samples + 1):
        x = lo + (hi - lo) * i / num_samples
        # Evaluate derivative at x using Horner's method
        val = 0.0
        for c in reversed(deriv_coeffs):
            val = val * x + c
        max_deriv = max(max_deriv, abs(val))

    return max_deriv < 1.0, max_deriv


def novikov_solve(
    f: Callable[[float], float],
    K: float,
    x0: float = 0.0,
    tol: float = 1e-12,
) -> Optional[float]:
    """
    Find the self-consistent solution (Novikov fixed point) of a causal map.

    This is the main entry point: given a causal evolution map f with
    contraction constant K < 1, find x* such that f(x*) = x*.

    Args:
        f: The causal evolution map (must be a K-contraction).
        K: Lipschitz constant, must be < 1.
        x0: Initial guess (any value works due to contraction).
        tol: Convergence tolerance.

    Returns:
        The unique fixed point x*, or None if iteration did not converge.
    """
    result, iters, _ = banach_iterate(f, x0, K, tol)
    return result


if __name__ == "__main__":
    # Example: affine causal map
    a, b = 0.3, 700.0
    exact = affine_fixed_point(a, b)
    print(f"Affine map f(x) = {a}x + {b}")
    print(f"Exact fixed point: {exact}")

    numerical = novikov_solve(lambda x: a * x + b, abs(a))
    print(f"Numerical fixed point: {numerical}")
    print(f"Match: {abs(exact - numerical) < 1e-10}")

    # Example: polynomial causal map
    coeffs = [2.0, -0.3, 0.1]  # 2 - 0.3x + 0.1x²
    is_contr, max_d = polynomial_contraction_check(coeffs, (-1.0, 3.0))
    print(f"\nPolynomial 2 - 0.3x + 0.1x²")
    print(f"Contraction on [-1, 3]: {is_contr} (max |p'| = {max_d:.4f})")

    if is_contr:
        fp = novikov_solve(
            lambda x: 0.1 * x**2 - 0.3 * x + 2, max_d, x0=0.0
        )
        print(f"Fixed point: {fp}")
