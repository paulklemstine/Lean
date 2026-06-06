#!/usr/bin/env python3
"""
EML Fixed-Point Algorithms
===========================

Type-hinted implementations of the core algorithms from the EML fixed-point theory.
"""

import math
from typing import Callable, Tuple, Optional, List
from dataclasses import dataclass


@dataclass
class ContractionScheme:
    """A contraction scheme: function + invariant interval + contraction constant.

    Packages a function f : R -> R with an invariant interval [lo, hi] and a
    contraction constant rho in [0, 1), together with the certificate that
    f maps the interval to itself and is rho-Lipschitz.
    """
    f: Callable[[float], float]
    lo: float
    hi: float
    rho: float

    def validate(self, x: float) -> bool:
        """Check if x is in the invariant interval."""
        return self.lo <= x <= self.hi

    def iterate(self, x0: float, n: int) -> List[float]:
        """Run n iterations starting from x0."""
        assert self.validate(x0), f"x0={x0} not in [{self.lo}, {self.hi}]"
        seq = [x0]
        x = x0
        for _ in range(n):
            x = self.f(x)
            seq.append(x)
        return seq

    def find_fixed_point(self, x0: float, tol: float = 1e-15,
                         max_iter: int = 10000) -> Tuple[float, int]:
        """Find the fixed point by iteration."""
        assert self.validate(x0), f"x0={x0} not in [{self.lo}, {self.hi}]"
        x = x0
        for i in range(max_iter):
            x_new = self.f(x)
            if abs(x_new - x) < tol:
                return x_new, i + 1
            x = x_new
        return x, max_iter

    def error_bound(self, x0: float, n: int, xstar: float) -> float:
        """A priori error bound: rho^n * |x0 - xstar|."""
        return self.rho ** n * abs(x0 - xstar)

    def compose(self, other: 'ContractionScheme') -> 'ContractionScheme':
        """Compose two contraction schemes on the same interval."""
        assert abs(self.lo - other.lo) < 1e-10 and abs(self.hi - other.hi) < 1e-10
        return ContractionScheme(
            f=lambda x, s=self, o=other: s.f(o.f(x)),
            lo=self.lo,
            hi=self.hi,
            rho=self.rho * other.rho
        )


def eml_operator(a: float, b: float, c: float) -> Callable[[float], float]:
    """Create an EML operator f(x) = exp(a) * log(b*x + c)."""
    ea = math.exp(a)
    return lambda x: ea * math.log(b * x + c)


def eml_derivative(a: float, b: float, c: float) -> Callable[[float], float]:
    """Create the derivative of the EML operator: f'(x) = exp(a) * b / (b*x + c)."""
    ea = math.exp(a)
    return lambda x: ea * b / (b * x + c)


def eml_spectral_rate(a: float, b: float, c: float, xstar: float) -> float:
    """Compute the spectral contraction rate |f'(x*)| at the fixed point."""
    return abs(math.exp(a) * b / (b * xstar + c))


def eml_contraction_scheme(
    a: float, b: float, c: float,
    lo: float, hi: float
) -> Optional[ContractionScheme]:
    """Try to construct an EML contraction scheme on [lo, hi].

    Returns None if the contraction condition fails.
    """
    f = eml_operator(a, b, c)
    fp = eml_derivative(a, b, c)

    # Check positivity of log argument
    if b * lo + c <= 0:
        return None

    # Compute supremum of |f'| on [lo, hi]
    # f'(x) = exp(a) * b / (b*x + c) is monotonically decreasing when b > 0
    # so the supremum is at lo
    if b > 0:
        rho = abs(fp(lo))
    elif b < 0:
        rho = abs(fp(hi))
    else:
        rho = 0.0

    if rho >= 1:
        return None

    # Check maps_to: f([lo, hi]) ⊆ [lo, hi]
    # Check at endpoints and a few interior points
    test_points = [lo, hi, (lo + hi) / 2]
    for x in test_points:
        fx = f(x)
        if fx < lo - 1e-10 or fx > hi + 1e-10:
            return None

    return ContractionScheme(f=f, lo=lo, hi=hi, rho=rho)


def parameter_sweep(
    b: float, c: float,
    a_values: List[float],
    x0: float = 1.0
) -> List[Tuple[float, Optional[float], Optional[float]]]:
    """Sweep over parameter a, finding fixed points and contraction rates.

    Returns list of (a, xstar_or_None, rho_or_None).
    """
    results = []
    for a in a_values:
        f = eml_operator(a, b, c)
        try:
            # Simple iteration to find fixed point
            x = x0
            for _ in range(10000):
                x_new = f(x)
                if abs(x_new - x) < 1e-15:
                    break
                x = x_new
            xstar = x
            rho = eml_spectral_rate(a, b, c, xstar)
            results.append((a, xstar, rho))
        except (ValueError, OverflowError):
            results.append((a, None, None))
    return results


def lyapunov_trajectory(
    scheme: ContractionScheme,
    x0: float,
    xstar: float,
    n: int
) -> List[Tuple[float, float, float]]:
    """Track the Lyapunov function V(x) = (x - x*)² along the iteration.

    Returns list of (x_n, V(x_n), V(x_n)/V(x_{n-1})).
    """
    trajectory = []
    x = x0
    v = (x - xstar) ** 2
    trajectory.append((x, v, float('nan')))
    for _ in range(n):
        v_prev = v
        x = scheme.f(x)
        v = (x - xstar) ** 2
        ratio = v / v_prev if v_prev > 1e-30 else float('nan')
        trajectory.append((x, v, ratio))
    return trajectory


if __name__ == "__main__":
    # Example: EML with a=0.5, b=1, c=2
    scheme = eml_contraction_scheme(0.5, 1.0, 2.0, 0.5, 5.0)
    if scheme:
        xstar, iters = scheme.find_fixed_point(1.0)
        print(f"Fixed point: {xstar:.15f} (found in {iters} iterations)")
        print(f"Contraction rate: {scheme.rho:.10f}")
        print(f"Error after 10 iters: {scheme.error_bound(1.0, 10, xstar):.2e}")

        # Lyapunov trajectory
        traj = lyapunov_trajectory(scheme, 3.0, xstar, 10)
        print("\nLyapunov trajectory:")
        for i, (x, v, r) in enumerate(traj):
            print(f"  n={i}: x={x:.10f}, V={v:.2e}, ratio={r:.6f}")
