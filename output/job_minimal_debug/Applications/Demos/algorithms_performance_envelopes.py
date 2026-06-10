#!/usr/bin/env python3
"""
Tropical Performance Envelopes — Algorithms

Implements the core algorithms from the research paper:
1. Envelope computation from drift bounds
2. Max-plus recursion simulation with envelope tracking
3. Network calculus backlog analysis
4. Throughput estimation with certified bounds
"""

from typing import Tuple, List, Optional
from dataclasses import dataclass


@dataclass
class PerformanceEnvelope:
    """A two-sided tropical performance envelope.

    Represents the certified band:
        k * lam_min + v_min <= x(k) <= k * lam_max + v_max

    Attributes:
        lam_min: Minimum drift rate (min-plus certificate slope)
        lam_max: Maximum drift rate (max-plus certificate slope)
        v_min: Lower intercept
        v_max: Upper intercept
    """
    lam_min: float
    lam_max: float
    v_min: float
    v_max: float

    def lower(self, k: int) -> float:
        """Lower bound at time k."""
        return k * self.lam_min + self.v_min

    def upper(self, k: int) -> float:
        """Upper bound at time k."""
        return k * self.lam_max + self.v_max

    def contains(self, k: int, value: float, tol: float = 1e-10) -> bool:
        """Check if value is within the envelope at time k."""
        return self.lower(k) - tol <= value <= self.upper(k) + tol

    def width(self, k: int) -> float:
        """Width of the envelope at time k."""
        return self.upper(k) - self.lower(k)

    def throughput_interval(self, k: int) -> Tuple[float, float]:
        """Throughput bounds at time k (for k > 0).

        Returns (lam_min + v_min/k, lam_max + v_max/k).

        Complexity: O(1)
        """
        if k <= 0:
            raise ValueError("k must be positive for throughput bounds")
        return (self.lam_min + self.v_min / k,
                self.lam_max + self.v_max / k)


def envelope_from_drift_bounds(
    x0: float, lam_min: float, lam_max: float
) -> PerformanceEnvelope:
    """Compute the performance envelope from one-step drift bounds.

    Implements Theorem: affine_envelope_of_step_bounds

    Given lam_min <= x(n+1) - x(n) <= lam_max for all n,
    returns the envelope x(0) + k*lam_min <= x(k) <= x(0) + k*lam_max.

    Args:
        x0: Initial value x(0)
        lam_min: Minimum one-step drift
        lam_max: Maximum one-step drift

    Returns:
        PerformanceEnvelope with slopes lam_min, lam_max and intercepts x0.

    Complexity: O(1) time, O(1) space
    """
    return PerformanceEnvelope(
        lam_min=lam_min,
        lam_max=lam_max,
        v_min=x0,
        v_max=x0
    )


def envelope_from_maxplus_recursion(
    x0: float, a: float, dmin: float, dmax: float
) -> PerformanceEnvelope:
    """Compute the performance envelope for a max-plus recursion.

    Implements Theorem: maxplus_recursion_envelope

    Given x(n+1) = max(x(n) + a, c(n)) with dmin <= c(n) - x(n) <= dmax,
    returns the envelope with slopes min(a, dmin) and max(a, dmax).

    Args:
        x0: Initial value x(0)
        a: Fixed increment in the recursion
        dmin: Minimum disturbance (c(n) - x(n) >= dmin)
        dmax: Maximum disturbance (c(n) - x(n) <= dmax)

    Returns:
        PerformanceEnvelope with appropriate slopes.

    Complexity: O(1) time, O(1) space
    """
    return PerformanceEnvelope(
        lam_min=min(a, dmin),
        lam_max=max(a, dmax),
        v_min=x0,
        v_max=x0
    )


def simulate_maxplus_recursion(
    x0: float, a: float, c: List[float], n_steps: int
) -> List[float]:
    """Simulate a max-plus recursion x(n+1) = max(x(n) + a, c(n)).

    Args:
        x0: Initial value
        a: Fixed increment
        c: External input sequence (length >= n_steps)
        n_steps: Number of steps to simulate

    Returns:
        List of trajectory values [x(0), x(1), ..., x(n_steps)]

    Complexity: O(n_steps) time, O(n_steps) space
    """
    x = [x0]
    for i in range(n_steps):
        x.append(max(x[-1] + a, c[i]))
    return x


def backlog_bound(
    x0: float, y0: float, rho: float, sigma: float, k: int
) -> float:
    """Compute the backlog bound at time k.

    Implements Theorem: network_calculus_backlog_bound

    Args:
        x0: Initial cumulative arrivals
        y0: Initial cumulative departures
        rho: Maximum arrival rate
        sigma: Minimum service rate
        k: Time step

    Returns:
        Upper bound on backlog x(k) - y(k)

    Complexity: O(1)
    """
    return (x0 - y0) + k * (rho - sigma)


def schedulability_window(
    x0: float, y0: float,
    rho_min: float, rho_max: float,
    sigma_min: float, sigma_max: float,
    k: int
) -> Tuple[float, float]:
    """Compute the schedulability window at time k.

    Implements Theorem: schedulability_window

    Args:
        x0, y0: Initial values
        rho_min, rho_max: Arrival rate bounds
        sigma_min, sigma_max: Service rate bounds
        k: Time step

    Returns:
        (lower_bound, upper_bound) on x(k) - y(k)

    Complexity: O(1)
    """
    lower = (x0 - y0) + k * (rho_min - sigma_max)
    upper = (x0 - y0) + k * (rho_max - sigma_min)
    return (lower, upper)


def dualize_envelope(env: PerformanceEnvelope) -> PerformanceEnvelope:
    """Dualize an envelope via negation.

    Implements Theorem: envelope_dualization

    If env bounds x, the returned envelope bounds -x.

    Args:
        env: Envelope for x

    Returns:
        Envelope for -x with negated and swapped parameters

    Complexity: O(1)
    """
    return PerformanceEnvelope(
        lam_min=-env.lam_max,
        lam_max=-env.lam_min,
        v_min=-env.v_max,
        v_max=-env.v_min
    )


def verify_envelope(
    x: List[float], env: PerformanceEnvelope, tol: float = 1e-10
) -> Tuple[bool, Optional[int]]:
    """Verify that a trajectory satisfies an envelope.

    Args:
        x: Trajectory values [x(0), x(1), ..., x(N)]
        env: Performance envelope
        tol: Numerical tolerance

    Returns:
        (is_valid, first_violation_index)
        If is_valid is True, first_violation_index is None.

    Complexity: O(len(x))
    """
    for k, val in enumerate(x):
        if not env.contains(k, val, tol):
            return (False, k)
    return (True, None)


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=== Tropical Performance Envelope Algorithms ===\n")

    # Example 1: Simple drift bounds
    env = envelope_from_drift_bounds(x0=0.0, lam_min=0.5, lam_max=1.5)
    print(f"Drift envelope: [{env.lam_min}, {env.lam_max}]")
    print(f"  At k=10: [{env.lower(10):.1f}, {env.upper(10):.1f}]")
    print(f"  At k=100: [{env.lower(100):.1f}, {env.upper(100):.1f}]")
    print(f"  Width at k=100: {env.width(100):.1f}")
    print(f"  Throughput at k=100: {env.throughput_interval(100)}")

    # Example 2: Max-plus recursion
    env2 = envelope_from_maxplus_recursion(x0=10.0, a=0.5, dmin=-0.2, dmax=0.8)
    print(f"\nMax-plus recursion envelope: slopes [{env2.lam_min}, {env2.lam_max}]")

    # Example 3: Dualization
    dual = dualize_envelope(env)
    print(f"\nDual envelope for -x: [{dual.lam_min}, {dual.lam_max}]")
    print(f"  v_min={dual.v_min}, v_max={dual.v_max}")

    # Example 4: Backlog bound
    bb = backlog_bound(x0=0, y0=0, rho=3.0, sigma=3.5, k=100)
    print(f"\nBacklog bound at k=100 (ρ=3, σ=3.5): {bb:.1f}")
    print(f"  (negative = system has drained)")

    # Example 5: Schedulability
    sw = schedulability_window(0, 0, 2.0, 4.0, 2.5, 3.5, k=50)
    print(f"\nSchedulability window at k=50: [{sw[0]:.1f}, {sw[1]:.1f}]")
