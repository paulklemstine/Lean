#!/usr/bin/env python3
"""
Algorithms for EML Differential Operator Theory

Type-hinted implementations of key algorithms from the EML differential
operator framework.
"""

from typing import Callable, Tuple, List, Optional
import numpy as np
from dataclasses import dataclass


@dataclass
class EMLDiffOperator:
    """Second-order linear ODE: y'' + p(x)y' + q(x)y = 0."""
    p: Callable[[float], float]
    q: Callable[[float], float]

    def discriminant(self, x: float) -> float:
        """Local discriminant Δ(x) = p(x)² - 4q(x)."""
        return self.p(x) ** 2 - 4 * self.q(x)

    def gauge_transform_q(self, x: float, dp: Optional[Callable[[float], float]] = None) -> float:
        """Gauge-transformed potential Q(x) = q - p'/2 - p²/4.
        Requires p'(x); if not provided, computes numerically."""
        if dp is None:
            h = 1e-8
            dp_val = (self.p(x + h) - self.p(x - h)) / (2 * h)
        else:
            dp_val = dp(x)
        return self.q(x) - dp_val / 2 - self.p(x) ** 2 / 4


def eml(x: float, y: float) -> float:
    """The EML function: eml(x, y) = exp(x) - log(y)."""
    return np.exp(x) - np.log(y)


def eml_diag(z: float) -> float:
    """Diagonal EML: d(z) = exp(z) - log(z)."""
    return np.exp(z) - np.log(z)


def compute_wronskian(
    y1: Callable[[float], float],
    y2: Callable[[float], float],
    x: float,
    h: float = 1e-8
) -> float:
    """Compute the Wronskian W(y₁, y₂)(x) numerically.

    W = y₁(x) · y₂'(x) - y₂(x) · y₁'(x)
    """
    dy1 = (y1(x + h) - y1(x - h)) / (2 * h)
    dy2 = (y2(x + h) - y2(x - h)) / (2 * h)
    return y1(x) * dy2 - y2(x) * dy1


def abel_wronskian_formula(
    W0: float,
    p: Callable[[float], float],
    x0: float,
    x: float,
    n_steps: int = 1000
) -> float:
    """Compute W(x) = W(x₀) · exp(-∫_{x₀}^{x} p(t) dt) via Abel's identity.

    Uses trapezoidal rule for numerical integration.
    """
    t = np.linspace(x0, x, n_steps + 1)
    dt = (x - x0) / n_steps
    p_vals = np.array([p(ti) for ti in t])
    integral = np.trapz(p_vals, dx=dt)
    return W0 * np.exp(-integral)


def solve_second_order_ode(
    L: EMLDiffOperator,
    y0: float,
    yp0: float,
    x_span: Tuple[float, float],
    n_steps: int = 10000
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Solve y'' + p(x)y' + q(x)y = 0 with RK4.

    Returns (x_array, y_array, yp_array).
    """
    x0, x1 = x_span
    h = (x1 - x0) / n_steps
    xs = np.linspace(x0, x1, n_steps + 1)
    ys = np.zeros(n_steps + 1)
    yps = np.zeros(n_steps + 1)
    ys[0] = y0
    yps[0] = yp0

    def f(x: float, y: float, yp: float) -> Tuple[float, float]:
        return yp, -L.p(x) * yp - L.q(x) * y

    for i in range(n_steps):
        xi = xs[i]
        yi, ypi = ys[i], yps[i]

        k1_y, k1_yp = f(xi, yi, ypi)
        k2_y, k2_yp = f(xi + h/2, yi + h*k1_y/2, ypi + h*k1_yp/2)
        k3_y, k3_yp = f(xi + h/2, yi + h*k2_y/2, ypi + h*k2_yp/2)
        k4_y, k4_yp = f(xi + h, yi + h*k3_y, ypi + h*k3_yp)

        ys[i+1] = yi + h * (k1_y + 2*k2_y + 2*k3_y + k4_y) / 6
        yps[i+1] = ypi + h * (k1_yp + 2*k2_yp + 2*k3_yp + k4_yp) / 6

    return xs, ys, yps


def find_zeros(x: np.ndarray, y: np.ndarray) -> List[float]:
    """Find approximate zeros of y by linear interpolation."""
    zeros = []
    for i in range(len(y) - 1):
        if y[i] * y[i+1] < 0:
            # Linear interpolation
            x_zero = x[i] - y[i] * (x[i+1] - x[i]) / (y[i+1] - y[i])
            zeros.append(x_zero)
        elif y[i] == 0:
            zeros.append(x[i])
    return zeros


def verify_sturm_separation(
    L: EMLDiffOperator,
    ic1: Tuple[float, float],
    ic2: Tuple[float, float],
    x_span: Tuple[float, float],
    n_steps: int = 50000
) -> Tuple[List[float], List[float], bool]:
    """Verify Sturm separation: zeros of two linearly independent solutions interlace.

    Returns (zeros_1, zeros_2, interlacing_holds).
    """
    xs, y1, _ = solve_second_order_ode(L, ic1[0], ic1[1], x_span, n_steps)
    _, y2, _ = solve_second_order_ode(L, ic2[0], ic2[1], x_span, n_steps)

    z1 = find_zeros(xs, y1)
    z2 = find_zeros(xs, y2)

    # Check interlacing: between any two consecutive zeros of y1,
    # there should be exactly one zero of y2
    interlacing = True
    for i in range(len(z1) - 1):
        count = sum(1 for z in z2 if z1[i] < z < z1[i+1])
        if count != 1:
            interlacing = False
            break

    return z1, z2, interlacing


def classify_behavior(L: EMLDiffOperator, x: float) -> str:
    """Classify local behavior of ODE solutions using the discriminant.

    Δ > 0: exponential behavior (two real characteristic roots)
    Δ = 0: critical (repeated root)
    Δ < 0: oscillatory behavior (complex conjugate roots)
    """
    disc = L.discriminant(x)
    if disc > 1e-10:
        return "exponential"
    elif disc < -1e-10:
        return "oscillatory"
    else:
        return "critical"


# ── Prebuilt operators ───────────────────────────────────────────────

AIRY_OPERATOR = EMLDiffOperator(p=lambda x: 0, q=lambda x: -x)
EXP_OPERATOR = EMLDiffOperator(p=lambda x: 0, q=lambda x: -np.exp(x))

def eml_operator(c: float) -> EMLDiffOperator:
    """ODE: y'' + eml(x, c) y' = 0."""
    return EMLDiffOperator(p=lambda x: eml(x, c), q=lambda x: 0)


if __name__ == "__main__":
    # Demo: Airy equation Sturm separation
    z1, z2, ok = verify_sturm_separation(
        AIRY_OPERATOR, (1.0, 0.0), (0.0, 1.0), (-15, 0), 100000
    )
    print(f"Airy equation zeros (sol 1): {[f'{z:.3f}' for z in z1[:6]]}")
    print(f"Airy equation zeros (sol 2): {[f'{z:.3f}' for z in z2[:6]]}")
    print(f"Interlacing holds: {ok}")

    # Demo: Airy discriminant sign change
    for x_val in [-5, -1, 0, 1, 5]:
        print(f"Airy discriminant at x={x_val}: Δ={AIRY_OPERATOR.discriminant(x_val):.1f} "
              f"→ {classify_behavior(AIRY_OPERATOR, x_val)}")
