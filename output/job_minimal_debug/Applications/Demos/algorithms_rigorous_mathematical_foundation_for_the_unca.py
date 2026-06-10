#!/usr/bin/env python3
"""
Epistemic Valley Theory — Core Algorithms

Type-hinted implementations of the key algorithms from the epistemic valley theory.
"""

import math
from typing import Callable, Optional


def suspicion(r: float) -> float:
    """Standard suspicion function S(r) = r²(1-r).
    
    Models the probability that a proof at rigor level r contains a subtle error.
    Peaks at r = 2/3 with value 4/27.
    """
    return r ** 2 * (1.0 - r)


def trust(alpha: float, r: float) -> float:
    """Trust function U(α, r) = r - α·S(r).
    
    Net epistemic value of a proof at rigor level r for a reader
    with suspicion sensitivity α.
    """
    return r - alpha * suspicion(r)


def trust_derivative(alpha: float, r: float) -> float:
    """Derivative dU/dr = 1 - 2αr + 3αr².
    
    Used for finding critical points and gradient flow analysis.
    """
    return 1.0 - 2.0 * alpha * r + 3.0 * alpha * r ** 2


def critical_sensitivity() -> float:
    """The critical sensitivity α* = 4.
    
    Below this, trust is non-negative on [0,1].
    Above this, an uncanny valley opens.
    """
    return 4.0


def valley_boundaries(alpha: float) -> Optional[tuple[float, float]]:
    """Compute valley boundaries for the standard model.
    
    For α > 4, returns (a, b) where trust is zero at a and b,
    and negative on (a, b). Returns None if α ≤ 4.
    
    Algorithm: Solve αr² - αr + 1 = 0 via quadratic formula.
    Discriminant: α² - 4α = α(α - 4).
    """
    discriminant = alpha * (alpha - 4.0)
    if discriminant <= 0:
        return None
    sqrt_d = math.sqrt(discriminant)
    a = (alpha - sqrt_d) / (2.0 * alpha)
    b = (alpha + sqrt_d) / (2.0 * alpha)
    return (a, b)


def valley_depth(alpha: float) -> float:
    """Maximum depth of the uncanny valley.
    
    Returns max(0, α/8 - 1/2), which is the negative of the minimum
    trust value at r = 1/2.
    """
    return max(0.0, alpha / 8.0 - 0.5)


def valley_width(alpha: float) -> float:
    """Width of the uncanny valley (distance between boundaries).
    
    Returns b - a where a, b are the valley boundaries.
    Returns 0 if α ≤ 4.
    """
    bounds = valley_boundaries(alpha)
    if bounds is None:
        return 0.0
    return bounds[1] - bounds[0]


def general_critical_sensitivity(
    S: Callable[[float], float],
    n_samples: int = 10000
) -> float:
    """Compute critical sensitivity for a general admissible suspicion function.
    
    Uses the Epistemic Barrier Theorem: α* = inf { c / S(c) : c ∈ (0,1), S(c) > 0 }.
    
    Args:
        S: Suspicion function satisfying S(0) = S(1) = 0, S(c) > 0 for some c ∈ (0,1).
        n_samples: Number of sample points for numerical optimization.
    
    Returns:
        Approximate critical sensitivity.
    """
    alpha_star = float('inf')
    for i in range(1, n_samples):
        r = i / n_samples
        s = S(r)
        if s > 0:
            alpha_star = min(alpha_star, r / s)
    return alpha_star


def optimal_rigor(alpha: float, n_samples: int = 10000) -> float:
    """Find the rigor level that maximizes trust for a given sensitivity.
    
    For α ≤ ~3, the optimum is at r = 1.
    For α > ~3, a local maximum appears before the valley.
    
    Returns the rigor level r* ∈ [0, 1] maximizing trust(α, r).
    """
    best_r = 0.0
    best_t = trust(alpha, 0.0)
    for i in range(n_samples + 1):
        r = i / n_samples
        t = trust(alpha, r)
        if t > best_t:
            best_t = t
            best_r = r
    return best_r


def gradient_flow_trajectory(
    alpha: float,
    r0: float,
    dt: float = 0.001,
    n_steps: int = 10000
) -> list[float]:
    """Simulate gradient flow dr/dt = dU/dr on the trust landscape.
    
    Models the natural evolution of a proof's rigor level under the
    epistemic energy landscape.
    
    Args:
        alpha: Suspicion sensitivity.
        r0: Initial rigor level.
        dt: Time step.
        n_steps: Number of integration steps.
    
    Returns:
        List of rigor values along the trajectory.
    """
    trajectory = [r0]
    r = r0
    for _ in range(n_steps):
        dr = trust_derivative(alpha, r)
        r = r + dt * dr
        r = max(0.0, min(1.0, r))  # Clamp to [0, 1]
        trajectory.append(r)
    return trajectory


def multi_dimensional_trust(
    alpha: float,
    v: list[float]
) -> float:
    """Multi-dimensional trust for a rigor vector.
    
    trust_n(α, v) = mean(v) - α · ∏ᵢ S(vᵢ)
    
    Args:
        alpha: Suspicion sensitivity.
        v: Rigor vector (each component in [0, 1]).
    
    Returns:
        Multi-dimensional trust value.
    """
    n = len(v)
    if n == 0:
        return 0.0
    mean_rigor = sum(v) / n
    compound_suspicion = 1.0
    for vi in v:
        compound_suspicion *= suspicion(vi)
    return mean_rigor - alpha * compound_suspicion


if __name__ == "__main__":
    # Quick self-test
    assert abs(trust(4.0, 0.5)) < 1e-10, "Critical point test failed"
    assert trust(5.0, 0.5) < 0, "Supercritical test failed"
    assert trust(3.0, 0.5) > 0, "Subcritical test failed"
    bounds = valley_boundaries(8.0)
    assert bounds is not None, "Valley boundaries test failed"
    a, b = bounds
    assert 0 < a < 0.5 < b < 1, "Valley boundary positions test failed"
    print("All self-tests passed.")
