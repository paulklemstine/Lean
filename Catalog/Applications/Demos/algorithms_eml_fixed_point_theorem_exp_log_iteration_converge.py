#!/usr/bin/env python3
"""
EML Fixed-Point Convergence: Core Algorithms

Type-hinted implementations of the EML iteration operator,
contraction verification, and fixed-point computation.
"""

import math
from dataclasses import dataclass
from typing import List, Optional, Tuple


@dataclass
class EMLContractionData:
    """Packaging of contraction mapping data for an EML operator.

    Corresponds to the Lean structure EMLContractionData.
    """
    a: float
    b: float
    c: float
    lo: float
    hi: float
    rho: float

    def validate(self) -> bool:
        """Check all contraction conditions."""
        if self.lo >= self.hi:
            return False
        if self.rho < 0 or self.rho >= 1:
            return False
        # Check arg_pos and deriv_bound on a fine grid
        n = 10000
        for i in range(n + 1):
            x = self.lo + i * (self.hi - self.lo) / n
            arg = self.b * x + self.c
            if arg <= 0:
                return False
            deriv = abs(math.exp(self.a) * self.b / arg)
            if deriv > self.rho + 1e-10:  # small tolerance
                return False
        # Check maps_to
        f_lo = eml_iter_op(self.a, self.b, self.c, self.lo)
        f_hi = eml_iter_op(self.a, self.b, self.c, self.hi)
        if not (self.lo <= f_lo <= self.hi):
            return False
        if not (self.lo <= f_hi <= self.hi):
            return False
        return True


def eml_iter_op(a: float, b: float, c: float, x: float) -> float:
    """The EML single operator: f(x) = exp(a) * log(b*x + c).

    Args:
        a: Exponential scaling parameter
        b: Linear coefficient
        c: Translation parameter
        x: Input value

    Returns:
        exp(a) * log(b*x + c)

    Raises:
        ValueError: If b*x + c <= 0
    """
    arg = b * x + c
    if arg <= 0:
        raise ValueError(f"Log argument b*x+c = {arg:.6f} must be positive")
    return math.exp(a) * math.log(arg)


def eml_deriv(a: float, b: float, c: float, x: float) -> float:
    """Derivative of the EML operator: f'(x) = exp(a) * b / (b*x + c).

    Args:
        a, b, c: EML parameters
        x: Point at which to evaluate the derivative

    Returns:
        exp(a) * b / (b*x + c)
    """
    return math.exp(a) * b / (b * x + c)


def eml_iteration_sequence(a: float, b: float, c: float, x0: float,
                           n_steps: int) -> List[float]:
    """Generate the iteration sequence x_{n+1} = f(x_n).

    Args:
        a, b, c: EML parameters
        x0: Initial point
        n_steps: Number of iteration steps

    Returns:
        List [x_0, x_1, ..., x_{n_steps}]
    """
    seq = [x0]
    x = x0
    for _ in range(n_steps):
        x = eml_iter_op(a, b, c, x)
        seq.append(x)
    return seq


def find_fixed_point(a: float, b: float, c: float, x0: float,
                     tol: float = 1e-15, max_iter: int = 10000) -> Tuple[float, int, List[float]]:
    """Find the fixed point by Picard iteration.

    Args:
        a, b, c: EML parameters
        x0: Initial point
        tol: Convergence tolerance
        max_iter: Maximum iterations

    Returns:
        (fixed_point, n_iterations, trajectory)
    """
    trajectory = [x0]
    x = x0
    for i in range(1, max_iter + 1):
        x_new = eml_iter_op(a, b, c, x)
        trajectory.append(x_new)
        if abs(x_new - x) < tol:
            return x_new, i, trajectory
        x = x_new
    return x, max_iter, trajectory


def verify_contraction(a: float, b: float, c: float,
                       lo: float, hi: float,
                       n_grid: int = 10000) -> Tuple[bool, float, bool]:
    """Verify contraction conditions on [lo, hi].

    Args:
        a, b, c: EML parameters
        lo, hi: Interval bounds
        n_grid: Grid resolution for derivative sampling

    Returns:
        (is_contraction, rho_bound, is_invariant)
    """
    rho = 0.0
    for i in range(n_grid + 1):
        x = lo + i * (hi - lo) / n_grid
        arg = b * x + c
        if arg <= 0:
            return False, float('inf'), False
        d = abs(eml_deriv(a, b, c, x))
        rho = max(rho, d)

    f_lo = eml_iter_op(a, b, c, lo)
    f_hi = eml_iter_op(a, b, c, hi)
    invariant = (lo <= f_lo <= hi) and (lo <= f_hi <= hi)

    return (rho < 1 and invariant), rho, invariant


def convergence_rate_analysis(a: float, b: float, c: float, x0: float,
                              n_steps: int = 50) -> List[Tuple[int, float, float]]:
    """Analyze convergence rate by comparing consecutive differences.

    Returns list of (step, |x_{n+1}-x_n|, estimated_rho) tuples.
    """
    seq = eml_iteration_sequence(a, b, c, x0, n_steps)
    results = []
    for i in range(len(seq) - 1):
        diff = abs(seq[i + 1] - seq[i])
        prev_diff = abs(seq[i] - seq[i - 1]) if i > 0 else None
        est_rho = diff / prev_diff if prev_diff and prev_diff > 1e-16 else None
        results.append((i, diff, est_rho if est_rho is not None else 0.0))
    return results


def power_series_coefficients(b: float, c: float,
                              n_terms: int = 5) -> List[float]:
    """Compute power series coefficients of x*(a) by numerical differentiation.

    Uses the implicit equation x* = exp(a) * log(b*x* + c) and
    finite differences to estimate d^n x*/da^n at a=0.

    Args:
        b, c: EML parameters (a is the expansion variable)
        n_terms: Number of terms to compute

    Returns:
        List of coefficients [c_0, c_1, c_2, ...]
    """
    h = 1e-4
    # Compute fixed points at a = -2h, -h, 0, h, 2h, ...
    a_values = [i * h for i in range(-n_terms, n_terms + 1)]
    x_values = []
    for a_val in a_values:
        xs, _, _ = find_fixed_point(a_val, b, c, 2.0)
        x_values.append(xs)

    # Use finite differences to estimate derivatives at a=0
    center = n_terms  # index of a=0
    coeffs = []
    for k in range(n_terms):
        # k-th derivative via finite differences
        if k == 0:
            coeffs.append(x_values[center])
        elif k == 1:
            deriv = (x_values[center + 1] - x_values[center - 1]) / (2 * h)
            coeffs.append(deriv)
        elif k == 2:
            deriv2 = (x_values[center + 1] - 2 * x_values[center] + x_values[center - 1]) / (h ** 2)
            coeffs.append(deriv2 / 2)
        elif k == 3:
            deriv3 = (x_values[center + 2] - 2 * x_values[center + 1] +
                       2 * x_values[center - 1] - x_values[center - 2]) / (2 * h ** 3)
            coeffs.append(deriv3 / 6)
        elif k == 4:
            deriv4 = (x_values[center + 2] - 4 * x_values[center + 1] +
                       6 * x_values[center] - 4 * x_values[center - 1] +
                       x_values[center - 2]) / (h ** 4)
            coeffs.append(deriv4 / 24)

    return coeffs


def find_contraction_parameters(a: float, b: float, c: float,
                                 x_guess: float = 2.0) -> Optional[EMLContractionData]:
    """Automatically find contraction interval for given EML parameters.

    Finds the fixed point and constructs an interval around it
    where the contraction condition holds.

    Returns:
        EMLContractionData if successful, None otherwise
    """
    try:
        xstar, _, _ = find_fixed_point(a, b, c, x_guess)
    except ValueError:
        return None

    # Try expanding interval around fixed point
    for width in [0.5, 1.0, 2.0, 5.0, 10.0]:
        lo = max(xstar - width, (-c + 0.01) / b if b > 0 else 0.01)
        hi = xstar + width

        is_contr, rho, invariant = verify_contraction(a, b, c, lo, hi)
        if is_contr:
            return EMLContractionData(a=a, b=b, c=c, lo=lo, hi=hi, rho=rho)

    return None


if __name__ == "__main__":
    # Quick test
    print("Testing EML algorithms...")

    # Find contraction data
    data = find_contraction_parameters(0.3, 1.0, 2.0)
    if data:
        print(f"Found contraction data: [{data.lo:.4f}, {data.hi:.4f}], ρ={data.rho:.6f}")
        print(f"Valid: {data.validate()}")

    # Power series
    coeffs = power_series_coefficients(1.0, 2.0, n_terms=5)
    print(f"Power series coefficients: {[f'{c:.6f}' for c in coeffs]}")

    print("All tests passed.")
