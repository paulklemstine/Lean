#!/usr/bin/env python3
"""
EML Fixed-Point Algorithms: Type-Hinted Implementations

Provides certified convergence algorithms for the EML operator
f(x) = exp(a) * log(b*x + c), including:
- Fixed-point iteration with a priori error bounds
- Adaptive step-size iteration
- Parameter sensitivity analysis
- Composition analysis for deep EML networks
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass
class EMLParams:
    """Parameters for the EML operator f(x) = exp(a) * log(b*x + c)."""
    a: float
    b: float
    c: float

    def eval(self, x: float) -> float:
        """Evaluate f(x) = exp(a) * log(b*x + c)."""
        return math.exp(self.a) * math.log(self.b * x + self.c)

    def deriv(self, x: float) -> float:
        """Evaluate f'(x) = exp(a) * b / (b*x + c)."""
        return math.exp(self.a) * self.b / (self.b * x + self.c)

    def contraction_ratio(self, lo: float, hi: float, n_samples: int = 1000) -> float:
        """Compute the maximum |f'(x)| on [lo, hi]."""
        max_d = 0.0
        for i in range(n_samples + 1):
            x = lo + (hi - lo) * i / n_samples
            max_d = max(max_d, abs(self.deriv(x)))
        return max_d


@dataclass
class ConvergenceResult:
    """Result of a fixed-point iteration."""
    fixed_point: float
    iterations: int
    error_bound: float
    contraction_ratio: float
    trajectory: List[float]


def banach_iteration(
    params: EMLParams,
    x0: float,
    lo: float,
    hi: float,
    tol: float = 1e-12,
    max_iter: int = 10000
) -> ConvergenceResult:
    """
    Banach fixed-point iteration with certified convergence.

    Algorithm:
    1. Verify contraction condition: max|f'| < 1 on [lo, hi]
    2. Iterate x_{n+1} = f(x_n)
    3. Use a priori bound: |x_n - x*| ≤ ρⁿ/(1-ρ) · |f(x₀) - x₀|
    4. Stop when bound < tol

    Args:
        params: EML operator parameters
        x0: Initial point in [lo, hi]
        lo, hi: Invariant interval
        tol: Desired accuracy
        max_iter: Maximum iterations

    Returns:
        ConvergenceResult with fixed point, iteration count, and error bound
    """
    rho = params.contraction_ratio(lo, hi)
    if rho >= 1.0:
        raise ValueError(f"Not a contraction: max|f'| = {rho:.6f} >= 1")

    trajectory = [x0]
    x = x0
    d0 = abs(params.eval(x0) - x0)

    for n in range(1, max_iter + 1):
        x = params.eval(x)
        trajectory.append(x)

        # A priori error bound: ρⁿ/(1-ρ) · |f(x₀) - x₀|
        error_bound = (rho ** n) / (1 - rho) * d0
        if error_bound < tol:
            return ConvergenceResult(
                fixed_point=x,
                iterations=n,
                error_bound=error_bound,
                contraction_ratio=rho,
                trajectory=trajectory
            )

    return ConvergenceResult(
        fixed_point=x,
        iterations=max_iter,
        error_bound=(rho ** max_iter) / (1 - rho) * d0,
        contraction_ratio=rho,
        trajectory=trajectory
    )


def parameter_sensitivity(
    base_params: EMLParams,
    delta_a: float,
    lo: float,
    hi: float
) -> Tuple[float, float, float]:
    """
    Compute the sensitivity of the fixed point to parameter perturbation.

    Uses the stability theorem: |x₁* - x₂*| ≤ δ/(1-ρ)
    where δ = max|f₁(x) - f₂(x)| on [lo, hi].

    Returns:
        (x_star_base, x_star_perturbed, stability_bound)
    """
    perturbed = EMLParams(base_params.a + delta_a, base_params.b, base_params.c)

    result_base = banach_iteration(base_params, (lo + hi) / 2, lo, hi)
    result_pert = banach_iteration(perturbed, (lo + hi) / 2, lo, hi)

    # Compute max|f1(x) - f2(x)| on the interval
    delta = 0.0
    n_samples = 1000
    for i in range(n_samples + 1):
        x = lo + (hi - lo) * i / n_samples
        delta = max(delta, abs(base_params.eval(x) - perturbed.eval(x)))

    rho = max(result_base.contraction_ratio, result_pert.contraction_ratio)
    stability_bound = delta / (1 - rho) if rho < 1 else float('inf')

    return result_base.fixed_point, result_pert.fixed_point, stability_bound


def composition_analysis(
    params_list: List[EMLParams],
    lo: float,
    hi: float,
    x0: float
) -> Tuple[float, float, float]:
    """
    Analyze the composition of multiple EML operators.

    Returns:
        (fixed_point, product_ratio, actual_convergence_rate)
    """
    product_ratio = 1.0
    for p in params_list:
        product_ratio *= p.contraction_ratio(lo, hi)

    # Iterate the composition
    x = x0
    prev_x = x
    for _ in range(10000):
        for p in params_list:
            x = p.eval(x)
        if abs(x - prev_x) < 1e-15:
            break
        prev_x = x

    # Measure actual convergence rate
    y = x0
    errors = []
    for _ in range(50):
        for p in params_list:
            y = p.eval(y)
        errors.append(abs(y - x))

    actual_rate = 0.0
    if len(errors) > 2 and errors[-2] > 1e-16:
        actual_rate = errors[-1] / errors[-2]

    return x, product_ratio, actual_rate


def find_invariant_interval(
    params: EMLParams,
    x_guess: float = 1.0,
    expand_factor: float = 2.0,
    max_expand: int = 20
) -> Optional[Tuple[float, float]]:
    """
    Find an invariant interval [lo, hi] for the EML operator.

    Strategy: Start from a guess near the fixed point,
    expand the interval until f maps it to itself.
    """
    # First find approximate fixed point
    x = x_guess
    for _ in range(1000):
        try:
            x_new = params.eval(x)
            if abs(x_new - x) < 1e-12:
                break
            x = x_new
        except (ValueError, OverflowError):
            return None

    xstar = x

    # Expand around fixed point
    radius = 0.1
    for _ in range(max_expand):
        lo = xstar - radius
        hi = xstar + radius

        # Check: f maps [lo, hi] to itself
        maps_ok = True
        for i in range(101):
            xi = lo + (hi - lo) * i / 100
            try:
                fxi = params.eval(xi)
                if fxi < lo or fxi > hi:
                    maps_ok = False
                    break
            except (ValueError, OverflowError):
                maps_ok = False
                break

        if maps_ok:
            # Check contraction
            rho = params.contraction_ratio(lo, hi)
            if rho < 1:
                return lo, hi

        radius *= expand_factor

    return None


if __name__ == "__main__":
    # Example usage
    params = EMLParams(a=0.5, b=1.0, c=2.0)
    result = banach_iteration(params, 1.0, 0.5, 3.0)
    print(f"Fixed point: {result.fixed_point:.15f}")
    print(f"Iterations: {result.iterations}")
    print(f"Error bound: {result.error_bound:.2e}")
    print(f"Contraction ratio: {result.contraction_ratio:.10f}")

    # Sensitivity
    x_base, x_pert, bound = parameter_sensitivity(params, 0.01, 0.5, 3.0)
    print(f"\nSensitivity: Δa = 0.01")
    print(f"  x*(a) = {x_base:.12f}")
    print(f"  x*(a+Δa) = {x_pert:.12f}")
    print(f"  Actual |Δx*| = {abs(x_base - x_pert):.2e}")
    print(f"  Stability bound = {bound:.2e}")

    # Find invariant interval
    interval = find_invariant_interval(params)
    if interval:
        print(f"\nInvariant interval: [{interval[0]:.6f}, {interval[1]:.6f}]")
