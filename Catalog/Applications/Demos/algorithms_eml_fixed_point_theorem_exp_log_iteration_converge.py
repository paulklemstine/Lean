#!/usr/bin/env python3
"""
EML Fixed-Point Algorithms: Type-hinted implementations of the EML iteration
convergence machinery, including contraction analysis and certified bounds.
"""

import math
from typing import Tuple, List, Optional, Callable


def eml_operator(a: float, b: float, c: float) -> Callable[[float], float]:
    """Create an EML operator f(x) = exp(a) * log(b*x + c).

    Args:
        a: Exponential scaling parameter
        b: Linear coefficient inside log
        c: Constant offset inside log

    Returns:
        The EML function as a callable
    """
    exp_a = math.exp(a)
    def f(x: float) -> float:
        return exp_a * math.log(b * x + c)
    return f


def eml_derivative(a: float, b: float, c: float) -> Callable[[float], float]:
    """Create the derivative f'(x) = exp(a) * b / (b*x + c).

    Args:
        a, b, c: EML parameters

    Returns:
        The derivative function as a callable
    """
    exp_a = math.exp(a)
    def fprime(x: float) -> float:
        return exp_a * b / (b * x + c)
    return fprime


def contraction_constant(a: float, b: float, c: float, L: float) -> float:
    """Compute the Lipschitz/contraction constant on [L, +inf).

    The contraction constant is rho = exp(a) * b / (b*L + c), which is
    the supremum of |f'(x)| on [L, +inf) since f' is decreasing.

    Args:
        a, b, c: EML parameters
        L: Left endpoint of the interval

    Returns:
        The contraction constant rho
    """
    return math.exp(a) * b / (b * L + c)


def verify_contraction(a: float, b: float, c: float, L: float) -> Tuple[bool, float]:
    """Check whether the EML operator is a contraction on [L, +inf).

    Returns:
        (is_contraction, rho) where is_contraction is True iff rho < 1
    """
    rho = contraction_constant(a, b, c, L)
    return rho < 1, rho


def find_invariant_interval(a: float, b: float, c: float,
                            L_init: float = 1.0, U_init: float = 100.0,
                            tol: float = 1e-10) -> Optional[Tuple[float, float]]:
    """Find an invariant interval [L, U] for the EML operator.

    An interval is invariant if f([L,U]) ⊆ [L,U], which requires:
    - L ≤ exp(a)*log(b*L + c)
    - exp(a)*log(b*U + c) ≤ U

    Uses bisection to find tight bounds.

    Args:
        a, b, c: EML parameters
        L_init, U_init: Initial search bounds
        tol: Tolerance for bisection

    Returns:
        (L, U) if found, None otherwise
    """
    f = eml_operator(a, b, c)

    # Find L: smallest x where f(x) >= x (lower boundary of invariant set)
    lo, hi = tol, U_init
    for _ in range(100):
        mid = (lo + hi) / 2
        if b * mid + c <= 0:
            lo = mid
            continue
        if f(mid) >= mid:
            hi = mid
        else:
            lo = mid
        if hi - lo < tol:
            break
    L = hi

    # Find U: largest x where f(x) <= x
    lo, hi = L, U_init
    for _ in range(100):
        mid = (lo + hi) / 2
        if f(mid) <= mid:
            lo = mid
        else:
            hi = mid
        if hi - lo < tol:
            break
    U = lo

    if L <= U and f(L) >= L and f(U) <= U:
        return (L, U)
    return None


def certified_iteration(a: float, b: float, c: float, x0: float,
                        L: float, max_iter: int = 1000,
                        tol: float = 1e-15) -> Tuple[float, List[float], List[float]]:
    """Run the EML iteration with certified convergence bounds.

    At each step, computes both the iterate and the a priori error bound
    rho^n * |x0 - x*|, where rho is the contraction constant.

    Args:
        a, b, c: EML parameters
        x0: Starting point
        L: Left endpoint for contraction constant computation
        max_iter: Maximum iterations
        tol: Convergence tolerance

    Returns:
        (fixed_point, iterates, error_bounds)
    """
    f = eml_operator(a, b, c)
    rho = contraction_constant(a, b, c, L)

    iterates = [x0]
    x = x0

    # First pass: find approximate fixed point
    for _ in range(max_iter):
        x_new = f(x)
        iterates.append(x_new)
        if abs(x_new - x) < tol:
            break
        x = x_new

    xstar = iterates[-1]
    d0 = abs(x0 - xstar)

    # Compute certified bounds
    error_bounds = [rho**n * d0 for n in range(len(iterates))]

    return xstar, iterates, error_bounds


def eml_composition_rate(params_list: List[Tuple[float, float, float]],
                         L: float) -> float:
    """Compute the contraction rate of a composition of EML layers.

    For a sequence of EML operators f_1, f_2, ..., f_n, the composition
    f_1 ∘ f_2 ∘ ... ∘ f_n has contraction constant rho_1 * rho_2 * ... * rho_n.

    Args:
        params_list: List of (a, b, c) parameter tuples
        L: Left endpoint for contraction constant computation

    Returns:
        The product contraction rate
    """
    rate = 1.0
    for a, b, c in params_list:
        rate *= contraction_constant(a, b, c, L)
    return rate


def fixed_point_sensitivity(a: float, b: float, c: float,
                            da: float = 1e-6) -> Tuple[float, float]:
    """Estimate the sensitivity of the fixed point to parameter a.

    Uses finite differences to approximate dx*/da.

    Args:
        a, b, c: EML parameters
        da: Step size for finite difference

    Returns:
        (x_star, dx_star_da) - fixed point and its derivative w.r.t. a
    """
    x1, _, _ = certified_iteration(a, b, c, 3.0, 1.0)
    x2, _, _ = certified_iteration(a + da, b, c, 3.0, 1.0)
    return x1, (x2 - x1) / da


if __name__ == "__main__":
    # Example: certified iteration for a=0.5, b=1, c=1
    xstar, iterates, bounds = certified_iteration(0.5, 1.0, 1.0, 3.0, 1.0)
    print(f"Fixed point: {xstar:.15f}")
    print(f"Iterations needed: {len(iterates)-1}")
    print(f"Final certified bound: {bounds[-1]:.2e}")

    # Composition rate for 3-layer EML network
    layers = [(0.3, 1.0, 2.0), (0.2, 1.0, 3.0), (0.1, 1.0, 4.0)]
    rate = eml_composition_rate(layers, 1.0)
    print(f"\n3-layer EML composition rate: {rate:.6f}")

    # Sensitivity analysis
    xstar, dxda = fixed_point_sensitivity(0.5, 1.0, 1.0)
    print(f"\nFixed point at a=0.5: {xstar:.10f}")
    print(f"Sensitivity dx*/da: {dxda:.6f}")
