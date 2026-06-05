#!/usr/bin/env python3
"""
EML Differential Equations: Core Algorithms

Type-hinted implementations of the key algorithms from the EML ODE theory.
"""

from typing import Callable, Tuple, List, Optional
import numpy as np
from dataclasses import dataclass


# Type aliases
RealFn = Callable[[float], float]


def wronskian(f: RealFn, fp: RealFn, g: RealFn, gp: RealFn, x: float) -> float:
    """Compute the Wronskian W(f,g)(x) = f(x)·g'(x) - f'(x)·g(x).

    Args:
        f: First function
        fp: Derivative of f
        g: Second function
        gp: Derivative of g
        x: Point of evaluation

    Returns:
        The Wronskian value at x
    """
    return f(x) * gp(x) - fp(x) * g(x)


def numerical_wronskian(f: RealFn, g: RealFn, x: float, h: float = 1e-7) -> float:
    """Compute the Wronskian using numerical differentiation.

    Args:
        f: First function
        g: Second function
        x: Point of evaluation
        h: Step size for numerical differentiation

    Returns:
        Approximate Wronskian value at x
    """
    fp = (f(x + h) - f(x - h)) / (2 * h)
    gp = (g(x + h) - g(x - h)) / (2 * h)
    return f(x) * gp - fp * g(x)


@dataclass
class LinODE2:
    """Second-order linear ODE: y'' + p(x)y' + q(x)y = 0."""
    p: RealFn
    q: RealFn

    def apply(self, y: RealFn, yp: RealFn, ypp: RealFn, x: float) -> float:
        """Apply the operator L[y] = y'' + p·y' + q·y at x."""
        return ypp(x) + self.p(x) * yp(x) + self.q(x) * y(x)

    def abel_wronskian(self, W0: float, x0: float, x: float,
                       n_steps: int = 1000) -> float:
        """Compute W(x) using Abel's identity: W(x) = W(x0)·exp(-∫p).

        Uses numerical integration (trapezoidal rule) for ∫p.
        """
        xs = np.linspace(x0, x, n_steps + 1)
        dx = (x - x0) / n_steps
        integral = np.trapezoid([self.p(t) for t in xs], dx=dx)
        return W0 * np.exp(-integral)


@dataclass
class LinODE1:
    """First-order linear ODE: y' + a(x)y = 0."""
    a: RealFn

    def apply(self, y: RealFn, yp: RealFn, x: float) -> float:
        """Apply L[y] = y' + a·y at x."""
        return yp(x) + self.a(x) * y(x)

    @staticmethod
    def compose(L1: 'LinODE1', L2: 'LinODE1',
                a2_deriv: RealFn) -> LinODE2:
        """Compose two first-order operators into a second-order operator.

        (D + a₁) ∘ (D + a₂) = D² + (a₁+a₂)D + (a₂'+a₁a₂)

        Args:
            L1: First operator (outer)
            L2: Second operator (inner)
            a2_deriv: Derivative of L2's coefficient

        Returns:
            The composed second-order operator
        """
        p: RealFn = lambda x: L1.a(x) + L2.a(x)
        q: RealFn = lambda x: a2_deriv(x) + L1.a(x) * L2.a(x)
        return LinODE2(p=p, q=q)


@dataclass
class EMLSolPair:
    """A pair of solutions to a common second-order linear ODE."""
    f: RealFn
    fp: RealFn
    g: RealFn
    gp: RealFn
    ode: LinODE2

    def wronskian_at(self, x: float) -> float:
        """Compute the Wronskian W(f,g)(x)."""
        return wronskian(self.f, self.fp, self.g, self.gp, x)

    def is_fundamental_at(self, x: float) -> bool:
        """Check if the pair is fundamental at x (W ≠ 0)."""
        return abs(self.wronskian_at(x)) > 1e-15

    def variation_of_parameters(self, r: RealFn, x0: float, x: float,
                                n_steps: int = 1000) -> float:
        """Compute particular solution via variation of parameters.

        y_p(x) = -f(x)∫(g·r/W) + g(x)∫(f·r/W)
        """
        ts = np.linspace(x0, x, n_steps + 1)
        dt = (x - x0) / n_steps

        integrand1 = [self.g(t) * r(t) / self.wronskian_at(t) for t in ts]
        integrand2 = [self.f(t) * r(t) / self.wronskian_at(t) for t in ts]

        int1 = np.trapezoid(integrand1, dx=dt)
        int2 = np.trapezoid(integrand2, dx=dt)

        return -self.f(x) * int1 + self.g(x) * int2


def log_deriv(f: RealFn, fp: RealFn, x: float) -> float:
    """Compute the logarithmic derivative δ(f)(x) = f'(x)/f(x).

    Args:
        f: Function
        fp: Derivative of f
        x: Point of evaluation

    Returns:
        f'(x)/f(x)

    Raises:
        ZeroDivisionError: if f(x) = 0
    """
    return fp(x) / f(x)


def softplus(x: float) -> float:
    """The softplus function: log(1 + exp(x))."""
    # Numerically stable version
    if x > 20:
        return x
    return np.log(1 + np.exp(x))


def sigmoid(x: float) -> float:
    """The sigmoid function: exp(x)/(1 + exp(x)).

    This is the derivative of softplus (proved in the Lean formalization).
    """
    if x > 20:
        return 1.0
    if x < -20:
        return 0.0
    return np.exp(x) / (1 + np.exp(x))


def kovacic_case1_check(r: RealFn, x: float, h: float = 1e-5) -> Optional[float]:
    """Check Kovacic Case 1: seek ω such that ω' + ω² = r(x).

    For constant r, the solution is ω = ±√r (when r > 0).
    Returns ω if a constant solution exists, None otherwise.

    This is a simplified version for constant-coefficient equations.
    """
    r_val = r(x)
    r_deriv = (r(x + h) - r(x - h)) / (2 * h)

    if abs(r_deriv) < 1e-8:  # r is approximately constant
        if r_val > 0:
            omega = np.sqrt(r_val)
            # Verify: ω' + ω² ≈ r
            if abs(omega**2 - r_val) < 1e-10:
                return omega
    return None


# Canonical examples

def make_harmonic_pair() -> EMLSolPair:
    """Create the canonical EML solution pair for y'' - y = 0.

    Solutions: exp(x) and exp(-x), Wronskian = -2.
    """
    return EMLSolPair(
        f=np.exp,
        fp=np.exp,
        g=lambda x: np.exp(-x),
        gp=lambda x: -np.exp(-x),
        ode=LinODE2(p=lambda x: 0.0, q=lambda x: -1.0)
    )


def make_airy_ode() -> LinODE2:
    """Create the Airy operator: y'' - xy = 0 (i.e., y'' + 0·y' + (-x)·y = 0)."""
    return LinODE2(p=lambda x: 0.0, q=lambda x: -x)


if __name__ == "__main__":
    # Quick self-test
    pair = make_harmonic_pair()
    x = 1.0
    print(f"Harmonic pair Wronskian at x=1: {pair.wronskian_at(x):.6f} (expected: -2)")
    print(f"Is fundamental: {pair.is_fundamental_at(x)}")

    # Test variation of parameters for y'' - y = exp(2x)
    r = lambda x: np.exp(2*x)
    yp = pair.variation_of_parameters(r, 0, 1, n_steps=10000)
    print(f"Particular solution of y''-y=exp(2x) at x=1: {yp:.6f}")
    print(f"Exact: exp(2)/3 = {np.exp(2)/3:.6f}")

    # Test log derivative
    print(f"\nLog derivative of exp at x=1: {log_deriv(np.exp, np.exp, 1.0):.6f} (expected: 1)")

    # Test softplus/sigmoid
    print(f"\nSoftplus'(0) ≈ {(softplus(0.001) - softplus(-0.001))/0.002:.6f}")
    print(f"Sigmoid(0) = {sigmoid(0):.6f} (expected: 0.5)")
