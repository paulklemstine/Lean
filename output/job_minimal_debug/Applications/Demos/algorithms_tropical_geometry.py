"""
Tropical Legendre–Fenchel Duality: Algorithms
==============================================

Implements the core algorithms for tropical Legendre duality,
including numerical computation of the Legendre–Fenchel transform,
completing-the-square decomposition, and tropical optimization.
"""

import numpy as np
from typing import Callable, Tuple, Optional


def legendre_transform(f: Callable[[np.ndarray], np.ndarray],
                       y: float,
                       x_min: float = -100.0,
                       x_max: float = 100.0,
                       n_points: int = 100000) -> float:
    """
    Compute the Legendre–Fenchel transform of f at y.

    L[f](y) = sup_x (x·y - f(x))

    Uses dense grid evaluation. For smooth strictly convex f, the supremum
    is attained at x = (f')^{-1}(y).

    Parameters
    ----------
    f : callable
        The function to transform. Should accept numpy arrays.
    y : float
        The dual variable at which to evaluate the transform.
    x_min, x_max : float
        Search interval for the supremum.
    n_points : int
        Number of grid points for the search.

    Returns
    -------
    float
        The value L[f](y).

    Examples
    --------
    >>> legendre_transform(lambda x: x**2 / 2, 3.0)
    4.5
    """
    xs = np.linspace(x_min, x_max, n_points)
    return float(np.max(xs * y - f(xs)))


def legendre_transform_with_optimizer(f: Callable[[np.ndarray], np.ndarray],
                                      y: float,
                                      x_min: float = -100.0,
                                      x_max: float = 100.0,
                                      n_points: int = 100000) -> Tuple[float, float]:
    """
    Compute L[f](y) and the optimizer x* where the supremum is attained.

    Returns
    -------
    (value, optimizer) : tuple of float
        The transform value and the optimal x.
    """
    xs = np.linspace(x_min, x_max, n_points)
    vals = xs * y - f(xs)
    idx = np.argmax(vals)
    return float(vals[idx]), float(xs[idx])


def complete_the_square(x: float, y: float) -> dict:
    """
    Decompose x·y - x²/2 using the completing-the-square identity.

    x·y - x²/2 = y²/2 - (x-y)²/2

    Parameters
    ----------
    x, y : float
        The primal and dual variables.

    Returns
    -------
    dict with keys:
        'lhs': x·y - x²/2
        'sup_term': y²/2 (the supremum value)
        'gap_term': (x-y)²/2 (the duality gap)
        'rhs': y²/2 - (x-y)²/2

    Examples
    --------
    >>> complete_the_square(3.0, 3.0)
    {'lhs': 4.5, 'sup_term': 4.5, 'gap_term': 0.0, 'rhs': 4.5}
    """
    lhs = x * y - x**2 / 2
    sup = y**2 / 2
    gap = (x - y)**2 / 2
    return {
        'lhs': lhs,
        'sup_term': sup,
        'gap_term': gap,
        'rhs': sup - gap,
    }


def fenchel_young_gap(x: float, y: float) -> float:
    """
    Compute the Fenchel–Young gap: x²/2 + y²/2 - x·y = (x-y)²/2.

    This is always non-negative, and equals zero iff x = y.

    Parameters
    ----------
    x, y : float

    Returns
    -------
    float
        The non-negative gap.
    """
    return (x - y)**2 / 2


def tropical_infimum_quadratic(y: float,
                                x_min: float = -100.0,
                                x_max: float = 100.0,
                                n_points: int = 100000) -> Tuple[float, float]:
    """
    Compute the tropical (min-plus) Legendre dual:
        inf_x (x²/2 - x·y) = -(y²/2)

    Returns the infimum value and the optimizer.

    Parameters
    ----------
    y : float
        The dual variable.

    Returns
    -------
    (inf_value, optimizer) : tuple of float
    """
    xs = np.linspace(x_min, x_max, n_points)
    vals = xs**2 / 2 - xs * y
    idx = np.argmin(vals)
    return float(vals[idx]), float(xs[idx])


def finite_legendre_transform(weights: dict,
                               y: float) -> Tuple[float, float]:
    """
    Compute the finite tropical Legendre transform:
        F(y) = max_{x in S} (x·y - w(x))

    where S is a finite set with associated weights.

    Parameters
    ----------
    weights : dict
        Mapping x -> w(x) for the finite support set.
    y : float
        The dual variable.

    Returns
    -------
    (value, optimizer) : tuple of float
    """
    best_val = float('-inf')
    best_x = None
    for x, w in weights.items():
        val = x * y - w
        if val > best_val:
            best_val = val
            best_x = x
    return best_val, best_x


def hopf_lax_step(f: Callable[[float], float],
                  cost: Callable[[float], float],
                  x: float,
                  x_min: float = -100.0,
                  x_max: float = 100.0,
                  n_points: int = 10000) -> float:
    """
    One step of the Hopf–Lax semigroup:
        (Q_t f)(x) = inf_y [f(y) + t·c((x-y)/t)]

    For the quadratic cost c(z) = z²/2, this becomes:
        (Q_t f)(x) = inf_y [f(y) + (x-y)²/(2t)]

    Parameters
    ----------
    f : callable
        Initial data function.
    cost : callable
        The cost function c(z).
    x : float
        Point at which to evaluate.

    Returns
    -------
    float
        The value (Q f)(x).
    """
    ys = np.linspace(x_min, x_max, n_points)
    vals = np.array([f(yi) + cost(x - yi) for yi in ys])
    return float(np.min(vals))


# ── Example usage ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Legendre Transform Algorithm Demo ===\n")

    # Quadratic case
    f = lambda x: x**2 / 2
    for y in [-3, -1, 0, 1, 3]:
        val, opt = legendre_transform_with_optimizer(f, y)
        exact = y**2 / 2
        print(f"L[x²/2]({y:>3}) = {val:>8.4f}  (exact: {exact:.4f},"
              f" optimizer: x* ≈ {opt:.2f})")

    print("\n=== Completing the Square ===\n")
    for x, y in [(1, 2), (3, 3), (-1, 4)]:
        result = complete_the_square(x, y)
        print(f"x={x}, y={y}: lhs={result['lhs']:.2f}, sup={result['sup_term']:.2f},"
              f" gap={result['gap_term']:.2f}")

    print("\n=== Finite Tropical Legendre Transform ===\n")
    weights = {-2: 1.0, 0: 0.0, 1: 0.5, 3: 2.0}
    for y in np.linspace(-3, 3, 7):
        val, opt = finite_legendre_transform(weights, y)
        print(f"F({y:>5.1f}) = {val:>8.4f}  (optimizer: x* = {opt})")

    print("\n=== Hopf–Lax Step (Quadratic Cost) ===\n")
    initial = lambda x: abs(x)  # |x| as initial data
    cost = lambda z: z**2 / 2
    for x in np.linspace(-3, 3, 7):
        val = hopf_lax_step(initial, cost, x)
        print(f"(Q f)({x:>5.1f}) = {val:>8.4f}")
