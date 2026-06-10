#!/usr/bin/env python3
"""
Algorithms for Cognitive Dynamics and Periodic Orbit Analysis

Type-hinted implementations of the core algorithms used in the
déjà vu dynamics research.
"""

from typing import List, Tuple, Optional, Set, Dict
import numpy as np


def logistic_map(r: float, x: float) -> float:
    """The logistic map f(x) = r * x * (1 - x)."""
    return r * x * (1.0 - x)


def iterate_map(f, x0: float, n: int) -> float:
    """Compute f^n(x0) — the n-th iterate of f at x0."""
    x = x0
    for _ in range(n):
        x = f(x)
    return x


def compute_orbit(f, x0: float, length: int) -> List[float]:
    """Compute the orbit [x0, f(x0), f²(x0), ..., f^length(x0)]."""
    orbit: List[float] = [x0]
    x = x0
    for _ in range(length):
        x = f(x)
        orbit.append(x)
    return orbit


def detect_period(orbit: List[float], tol: float = 1e-8) -> Optional[int]:
    """
    Detect the minimal period of a (pre-periodic) orbit.

    Algorithm: For each candidate period p from 1 to len(orbit)//2,
    check if the tail of the orbit repeats with period p.
    """
    n = len(orbit)
    # Use the last half of the orbit (after transient)
    start = n // 2
    tail = orbit[start:]

    for p in range(1, len(tail) // 2 + 1):
        is_periodic = True
        for i in range(p, len(tail)):
            if abs(tail[i] - tail[i - p]) > tol:
                is_periodic = False
                break
        if is_periodic:
            return p
    return None


def find_periodic_orbits(r: float, max_period: int = 10,
                         num_samples: int = 5000,
                         warmup: int = 1000,
                         tol: float = 1e-8) -> Dict[int, List[List[float]]]:
    """
    Find all periodic orbits of the logistic map up to given period.

    Returns a dictionary mapping period → list of orbits, where each
    orbit is a list of points in the cycle.

    Algorithm:
    1. Sample initial conditions uniformly in (0,1)
    2. Iterate to remove transients
    3. Detect period of the attractor
    4. Record the orbit, deduplicating
    """
    orbits_by_period: Dict[int, List[List[float]]] = {}

    for x0 in np.linspace(0.01, 0.99, num_samples):
        # Warmup: iterate to approach attractor
        x = x0
        for _ in range(warmup):
            x = logistic_map(r, x)

        # Detect period
        orbit = compute_orbit(lambda y: logistic_map(r, y), x, max_period * 3)
        period = detect_period(orbit, tol)

        if period is not None and period <= max_period:
            # Extract one cycle
            cycle = sorted(orbit[-period:])

            # Check if this orbit is already known
            if period not in orbits_by_period:
                orbits_by_period[period] = []

            is_new = True
            for known_cycle in orbits_by_period[period]:
                if len(known_cycle) == len(cycle):
                    if all(abs(a - b) < 1e-4 for a, b in zip(known_cycle, cycle)):
                        is_new = False
                        break

            if is_new:
                orbits_by_period[period].append(cycle)

    return orbits_by_period


def covering_check(f, a: float, b: float, c: float, d: float,
                   num_samples: int = 1000) -> bool:
    """
    Numerically verify the covering relation f([a,b]) ⊇ [c,d].

    Checks that the image of [a,b] under f contains [c,d] by sampling.
    """
    xs = np.linspace(a, b, num_samples)
    ys = [f(x) for x in xs]
    return min(ys) <= c + 1e-10 and max(ys) >= d - 1e-10


def lyapunov_exponent(r: float, x0: float = 0.5,
                      n_iter: int = 10000,
                      n_warmup: int = 1000) -> float:
    """
    Compute the Lyapunov exponent of the logistic map at parameter r.

    λ = lim (1/n) Σ log|f'(xₖ)|

    For the logistic map, f'(x) = r(1 - 2x).
    """
    x = x0
    for _ in range(n_warmup):
        x = logistic_map(r, x)

    lyap_sum = 0.0
    for _ in range(n_iter):
        deriv = abs(r * (1.0 - 2.0 * x))
        if deriv > 0:
            lyap_sum += np.log(deriv)
        x = logistic_map(r, x)

    return lyap_sum / n_iter


def topological_entropy_estimate(r: float, max_n: int = 15) -> float:
    """
    Estimate topological entropy via growth rate of periodic points.

    h_top ≈ (1/n) log |Fix(f^n)| as n → ∞

    For the logistic map at r=4, this should approach log(2) ≈ 0.693.
    """
    counts = []
    for n in range(1, max_n + 1):
        pts = 0
        for x0 in np.linspace(0.001, 0.999, 10000):
            x = x0
            for _ in range(n):
                x = logistic_map(r, x)
            if abs(x - x0) < 1e-6:
                pts += 1
        if pts > 0:
            counts.append(np.log(pts) / n)

    return np.mean(counts[-5:]) if len(counts) >= 5 else (counts[-1] if counts else 0.0)


def recurrence_spectrum(f, domain: Tuple[float, float],
                        max_period: int = 20,
                        num_samples: int = 5000,
                        tol: float = 1e-6) -> Set[int]:
    """
    Compute the recurrence spectrum: the set of periods n for which
    f has a period-n point in the given domain.
    """
    spectrum: Set[int] = set()
    a, b = domain

    for n in range(1, max_period + 1):
        for x0 in np.linspace(a + 0.001, b - 0.001, num_samples):
            x = x0
            for _ in range(n):
                x = f(x)
            if abs(x - x0) < tol:
                # Verify it's exactly period n (not a divisor)
                is_exact = True
                for d in range(1, n):
                    if n % d == 0:
                        y = x0
                        for _ in range(d):
                            y = f(y)
                        if abs(y - x0) < tol:
                            is_exact = False
                            break
                if is_exact or n == 1:
                    spectrum.add(n)
                    break

    return spectrum


def conjugacy_transform(x: float) -> float:
    """
    The semiconjugacy between logistic map (r=4) and tent map:
    h(x) = sin²(πx/2)

    This transforms the chaotic logistic dynamics into the
    piecewise-linear tent map dynamics.
    """
    return np.sin(np.pi * x / 2.0) ** 2


def verify_conjugacy(n_points: int = 100, tol: float = 1e-10) -> float:
    """
    Numerically verify that h ∘ tent = logistic ∘ h
    where h(x) = sin²(πx/2), tent(x) = 1 - |2x - 1|, logistic(x) = 4x(1-x).

    Returns maximum error.
    """
    max_err = 0.0
    for x in np.linspace(0.01, 0.99, n_points):
        # h(tent(x))
        tent_x = 1.0 - abs(2.0 * x - 1.0)
        h_tent_x = conjugacy_transform(tent_x)

        # logistic(h(x))
        h_x = conjugacy_transform(x)
        log_h_x = logistic_map(4.0, h_x)

        err = abs(h_tent_x - log_h_x)
        max_err = max(max_err, err)

    return max_err


if __name__ == "__main__":
    # Test the algorithms
    print("=== Algorithm Tests ===\n")

    # Test period detection
    r = 3.83
    orbit = compute_orbit(lambda x: logistic_map(r, x), 0.5, 2000)
    period = detect_period(orbit)
    print(f"Detected period at r={r}: {period}")

    # Test covering check
    f = lambda x: logistic_map(3.83, x)
    print(f"\nCovering f([0.15, 0.5]) ⊇ [0.5, 0.96]: "
          f"{covering_check(f, 0.15, 0.5, 0.5, 0.96)}")

    # Test Lyapunov exponent
    for r in [2.5, 3.5, 3.83, 4.0]:
        lam = lyapunov_exponent(r)
        print(f"Lyapunov exponent at r={r}: {lam:.4f}")

    # Test conjugacy
    err = verify_conjugacy()
    print(f"\nConjugacy verification max error: {err:.2e}")

    # Test recurrence spectrum
    spectrum = recurrence_spectrum(lambda x: logistic_map(3.83, x), (0, 1))
    print(f"\nRecurrence spectrum at r=3.83: {sorted(spectrum)}")
