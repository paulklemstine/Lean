#!/usr/bin/env python3
"""
Algorithms for Tropical Life Bifurcation Analysis
===================================================
Implementations of core algorithms for computing periodic orbits,
period spectra, critical birth sizes, and pullback maps.
"""

import numpy as np
from typing import Optional
from collections import defaultdict


# ---------------------------------------------------------------------------
# Core Tropical Life Engine
# ---------------------------------------------------------------------------

def tropical_threshold(s: int, lo: int, hi: int) -> int:
    """
    Tropical threshold indicator.

    Returns 1 if lo <= s <= hi, else 0.
    Implemented via min/max (tropical primitives).

    Time: O(1)
    """
    return min(1, max(0, s + 1 - lo)) * min(1, max(0, hi + 1 - s))


def tropical_life_step(config: np.ndarray) -> np.ndarray:
    """
    One step of the tropical Life automaton on a torus.

    Args:
        config: m x n integer array (configuration on the torus)

    Returns:
        New m x n configuration after one step

    Time: O(m * n) where m, n are torus dimensions
    Space: O(m * n)
    """
    m, n = config.shape
    new = np.zeros_like(config)
    for i in range(m):
        for j in range(n):
            s = 0
            for di in (-1, 0, 1):
                for dj in (-1, 0, 1):
                    if di == 0 and dj == 0:
                        continue
                    s += config[(i + di) % m, (j + dj) % n]
            alive = min(1, config[i, j])
            new[i, j] = (
                alive * tropical_threshold(s, 2, 3)
                + (1 - alive) * tropical_threshold(s, 3, 3)
            )
    return new


# ---------------------------------------------------------------------------
# Pullback Map (Torus Covering)
# ---------------------------------------------------------------------------

def pullback_config(config: np.ndarray, M: int, N: int) -> np.ndarray:
    """
    Pullback of a configuration along a torus covering.

    Given config on m x n torus and M, N with m|M, n|N,
    produces the tiled configuration on M x N torus.

    Args:
        config: m x n configuration
        M, N: dimensions of the larger torus

    Returns:
        M x N configuration where big[i,j] = config[i%m, j%n]

    Time: O(M * N)
    Space: O(M * N)
    """
    m, n = config.shape
    assert M % m == 0 and N % n == 0
    big = np.empty((M, N), dtype=config.dtype)
    for i in range(M):
        for j in range(N):
            big[i, j] = config[i % m, j % n]
    return big


# ---------------------------------------------------------------------------
# Period Detection Algorithms
# ---------------------------------------------------------------------------

def detect_period_brent(config: np.ndarray, max_iter: int = 10000) -> Optional[int]:
    """
    Detect the period of a configuration using Brent's cycle detection.

    This is more efficient than naive iteration for long pre-periods.

    Args:
        config: Initial configuration
        max_iter: Maximum iterations before giving up

    Returns:
        Minimal period, or None if not found within max_iter

    Time: O(mu + lambda) where mu is pre-period, lambda is period
    Space: O(m * n) for storing configurations
    """
    power = 1
    lam = 1
    tortoise = config.copy()
    hare = tropical_life_step(config)

    iterations = 0
    while not np.array_equal(tortoise, hare):
        if iterations >= max_iter:
            return None
        if power == lam:
            tortoise = hare.copy()
            power *= 2
            lam = 0
        hare = tropical_life_step(hare)
        lam += 1
        iterations += 1

    # Find the start of the cycle
    tortoise = config.copy()
    hare = config.copy()
    for _ in range(lam):
        hare = tropical_life_step(hare)

    mu = 0
    while not np.array_equal(tortoise, hare):
        tortoise = tropical_life_step(tortoise)
        hare = tropical_life_step(hare)
        mu += 1

    # Find the minimal period
    hare = tropical_life_step(tortoise)
    period = 1
    while not np.array_equal(tortoise, hare):
        hare = tropical_life_step(hare)
        period += 1

    return period


def detect_period_naive(config: np.ndarray, max_iter: int = 1000) -> Optional[int]:
    """
    Detect period by storing all iterates (simple but memory-intensive).

    Time: O(max_iter * m * n)
    Space: O(max_iter * m * n)
    """
    current = config.copy()
    for p in range(1, max_iter + 1):
        current = tropical_life_step(current)
        if np.array_equal(current, config):
            return p
    return None


def find_preperiod_and_period(
    config: np.ndarray, max_iter: int = 1000
) -> tuple[int, int]:
    """
    Find both the pre-period (mu) and period (lambda) of an orbit.

    Returns (mu, lambda) where:
    - mu: number of steps before entering the cycle
    - lambda: length of the cycle

    Time: O(max_iter * m * n)
    Space: O(max_iter * m * n)
    """
    history = [config.copy()]
    current = config.copy()
    for step in range(1, max_iter + 1):
        current = tropical_life_step(current)
        for mu, past in enumerate(history):
            if np.array_equal(current, past):
                return mu, step - mu
        history.append(current.copy())
    return -1, -1  # Not found


# ---------------------------------------------------------------------------
# Period Spectrum Computation
# ---------------------------------------------------------------------------

def compute_period_spectrum(
    L: int,
    max_period: int = 50,
    num_random: int = 500,
    include_structured: bool = True,
) -> set[int]:
    """
    Compute (approximate) period spectrum of the L x L torus.

    Uses both random sampling and structured initial configurations.

    Args:
        L: Torus side length
        max_period: Maximum period to search for
        num_random: Number of random configurations to test
        include_structured: Also test structured configs (all-0, all-1, etc.)

    Returns:
        Set of observed periods

    Time: O((num_random + structured) * max_period * L^2)
    """
    periods = set()

    # Zero config is always period 1
    periods.add(1)

    # Structured configurations
    if include_structured:
        configs = [
            np.zeros((L, L), dtype=int),
            np.ones((L, L), dtype=int),
        ]
        # Single cell alive
        if L >= 1:
            c = np.zeros((L, L), dtype=int)
            c[0, 0] = 1
            configs.append(c)
        # Checkerboard
        c = np.zeros((L, L), dtype=int)
        for i in range(L):
            for j in range(L):
                c[i, j] = (i + j) % 2
        configs.append(c)

        for c in configs:
            p = detect_period_naive(c, max_period)
            if p is not None:
                periods.add(p)

    # Random sampling
    for _ in range(num_random):
        c = np.random.randint(0, 2, size=(L, L))
        p = detect_period_brent(c, max_period * 2)
        if p is not None:
            periods.add(p)

    return periods


def compute_critical_sizes(
    max_period: int = 15, max_L: int = 12, num_samples: int = 300
) -> dict[int, int]:
    """
    Compute critical birth sizes: smallest L at which each period appears.

    Args:
        max_period: Maximum period to search for
        max_L: Maximum torus size to check
        num_samples: Random samples per torus size

    Returns:
        Dict mapping period -> critical size

    Time: O(max_L * num_samples * max_period * max_L^2)
    """
    critical = {}
    for L in range(1, max_L + 1):
        sp = compute_period_spectrum(L, max_period, num_samples)
        for p in sp:
            if p not in critical:
                critical[p] = L
    return critical


# ---------------------------------------------------------------------------
# Bifurcation Diagram Construction
# ---------------------------------------------------------------------------

def bifurcation_diagram(
    max_L: int = 15, max_period: int = 30, num_samples: int = 200
) -> dict[int, set[int]]:
    """
    Build a bifurcation diagram: for each torus size L, compute period spectrum.

    Returns:
        Dict mapping L -> set of periods

    Time: O(max_L * num_samples * max_period * max_L^2)
    """
    diagram = {}
    for L in range(1, max_L + 1):
        diagram[L] = compute_period_spectrum(L, max_period, num_samples)
    return diagram


def verify_spectrum_monotonicity(
    diagram: dict[int, set[int]]
) -> list[tuple[int, int, set[int]]]:
    """
    Check period spectrum monotonicity: L | M => spectrum(L) ⊆ spectrum(M).

    Returns list of violations (L, M, missing_periods).
    """
    violations = []
    sizes = sorted(diagram.keys())
    for L in sizes:
        for M in sizes:
            if M > L and M % L == 0:
                missing = diagram[L] - diagram[M]
                if missing:
                    violations.append((L, M, missing))
    return violations


# ---------------------------------------------------------------------------
# Period Counting and Zeta Function
# ---------------------------------------------------------------------------

def count_periodic_points(
    L: int, period: int, num_samples: int = 1000
) -> int:
    """
    Estimate the number of period-p points on the L x L torus.
    (Lower bound from random sampling.)
    """
    count = 0
    for _ in range(num_samples):
        c = np.random.randint(0, 2, size=(L, L))
        current = c.copy()
        for _ in range(period):
            current = tropical_life_step(current)
        if np.array_equal(current, c):
            count += 1
    return count


def tropical_zeta_coefficients(
    L: int, max_period: int = 10, num_samples: int = 500
) -> list[int]:
    """
    Estimate coefficients for the tropical dynamical zeta function.

    The zeta function is formally: Z(t) = exp(sum_{n>=1} |Fix(f^n)| * t^n / n)

    Returns estimated |Fix(f^n)| for n = 1, ..., max_period.
    """
    coeffs = []
    for n in range(1, max_period + 1):
        coeffs.append(count_periodic_points(L, n, num_samples))
    return coeffs


if __name__ == "__main__":
    np.random.seed(42)

    print("Computing bifurcation diagram...")
    diagram = bifurcation_diagram(max_L=10, max_period=20, num_samples=100)
    for L, sp in sorted(diagram.items()):
        print(f"  L={L:2d}: {sorted(sp)}")

    print("\nChecking monotonicity...")
    violations = verify_spectrum_monotonicity(diagram)
    if not violations:
        print("  All divisibility-monotonicity checks passed! ✓")
    else:
        for L, M, missing in violations:
            print(f"  Violation: {L}|{M}, missing periods: {missing}")

    print("\nCritical birth sizes:")
    critical = compute_critical_sizes(max_period=10, max_L=10, num_samples=100)
    for p, L in sorted(critical.items()):
        print(f"  Period {p:2d}: first at L = {L}")
