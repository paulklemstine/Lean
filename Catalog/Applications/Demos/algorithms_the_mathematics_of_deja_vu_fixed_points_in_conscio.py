#!/usr/bin/env python3
"""
Algorithms for Dynamical Spectrum Analysis

Type-hinted implementations of the core algorithms used in the
Dynamical Spectrum Theory framework.
"""

from typing import List, Tuple, Optional, Set, Callable
import math


def logistic_map(r: float, x: float) -> float:
    """
    The logistic map f_r(x) = r·x·(1 - x).
    
    Args:
        r: The bifurcation parameter (typically 0 < r ≤ 4)
        x: Current state (typically in [0, 1])
    
    Returns:
        The next state f_r(x)
    
    Complexity: O(1)
    """
    return r * x * (1.0 - x)


def iterate_map(f: Callable[[float], float], x: float, n: int) -> float:
    """
    Compute the n-th iterate f^[n](x).
    
    Args:
        f: The dynamical map
        x: Initial state
        n: Number of iterations
    
    Returns:
        f^[n](x)
    
    Complexity: O(n)
    """
    for _ in range(n):
        x = f(x)
    return x


def compute_orbit(f: Callable[[float], float], x0: float, 
                  length: int) -> List[float]:
    """
    Compute the forward orbit of x0 under f.
    
    Args:
        f: The dynamical map
        x0: Initial state
        length: Number of iterates to compute
    
    Returns:
        [x0, f(x0), f²(x0), ..., f^length(x0)]
    
    Complexity: O(length)
    """
    orbit = [x0]
    x = x0
    for _ in range(length):
        x = f(x)
        orbit.append(x)
    return orbit


def detect_period_floyd(f: Callable[[float], float], x0: float,
                       tol: float = 1e-10) -> Tuple[int, int]:
    """
    Detect periodicity using Floyd's cycle detection algorithm.
    
    Returns (mu, lambda) where:
    - mu: length of the pre-periodic (transient) part
    - lambda: period of the cycle
    
    This is O(mu + lambda) in time and O(1) in space.
    
    Args:
        f: The dynamical map
        x0: Initial state
        tol: Tolerance for equality comparison
    
    Returns:
        (mu, lambda): pre-period and period
    """
    # Phase 1: Find meeting point of tortoise and hare
    tortoise = f(x0)
    hare = f(f(x0))
    max_iter = 100000
    
    count = 0
    while abs(tortoise - hare) > tol and count < max_iter:
        tortoise = f(tortoise)
        hare = f(f(hare))
        count += 1
    
    if count >= max_iter:
        return (-1, -1)  # No period detected
    
    # Phase 2: Find mu (start of cycle)
    mu = 0
    tortoise = x0
    while abs(tortoise - hare) > tol and mu < max_iter:
        tortoise = f(tortoise)
        hare = f(hare)
        mu += 1
    
    # Phase 3: Find lambda (period)
    lam = 1
    hare = f(tortoise)
    while abs(tortoise - hare) > tol and lam < max_iter:
        hare = f(hare)
        lam += 1
    
    return (mu, lam)


def sharkovsky_order(a: int, b: int) -> bool:
    """
    Determine if a ◁ b in the Sharkovsky ordering.
    
    The Sharkovsky ordering is:
    3 ◁ 5 ◁ 7 ◁ ... ◁ 2·3 ◁ 2·5 ◁ ... ◁ 2²·3 ◁ ... ◁ 2³ ◁ 2² ◁ 2 ◁ 1
    
    Returns True if a forces b (a ◁ b), meaning any continuous map
    with a period-a orbit must also have a period-b orbit.
    
    Args:
        a: First period
        b: Second period
    
    Returns:
        True if a ◁ b in Sharkovsky ordering
    """
    if a <= 0 or b <= 0:
        return False
    
    def decompose(n: int) -> Tuple[int, int]:
        """Return (2-adic valuation, odd part)."""
        v = 0
        while n % 2 == 0:
            v += 1
            n //= 2
        return (v, n)
    
    va, oa = decompose(a)
    vb, ob = decompose(b)
    
    # Case 1: Both are pure powers of 2
    if oa == 1 and ob == 1:
        return va > vb  # Higher powers force lower
    
    # Case 2: a is power of 2, b is not (or vice versa)
    if oa == 1 and ob > 1:
        return False  # Powers of 2 don't force odd multiples
    if oa > 1 and ob == 1:
        return True  # Non-power-of-2 forces all powers of 2
    
    # Case 3: Both have odd parts > 1
    if va < vb:
        return True  # Lower 2-adic valuation forces higher
    if va > vb:
        return False
    
    # Same 2-adic valuation: compare odd parts
    return oa < ob


def lyapunov_exponent(f: Callable[[float], float],
                      df: Callable[[float], float],
                      x0: float, n: int = 10000) -> float:
    """
    Compute the Lyapunov exponent of f at x0.
    
    λ = lim_{n→∞} (1/n) Σ log|f'(f^k(x0))|
    
    Positive λ indicates chaos; negative indicates stability.
    
    Args:
        f: The dynamical map
        df: The derivative of f
        x0: Initial state
        n: Number of iterations
    
    Returns:
        Estimated Lyapunov exponent
    """
    x = x0
    total = 0.0
    for _ in range(n):
        d = abs(df(x))
        if d > 0:
            total += math.log(d)
        x = f(x)
    return total / n


def ivt_fixed_point_bisection(f: Callable[[float], float],
                              a: float, b: float,
                              tol: float = 1e-12,
                              max_iter: int = 100) -> float:
    """
    Find a fixed point of f in [a,b] using bisection on g(x) = f(x) - x.
    
    Assumes f maps [a,b] to [a,b] (so f(a) ≥ a and f(b) ≤ b).
    
    This is the computational realization of the IVT fixed point theorem:
    g(a) = f(a) - a ≥ 0 and g(b) = f(b) - b ≤ 0,
    so by IVT there exists c with g(c) = 0, i.e., f(c) = c.
    
    Args:
        f: Continuous function mapping [a,b] to [a,b]
        a: Left endpoint
        b: Right endpoint
        tol: Tolerance for convergence
        max_iter: Maximum iterations
    
    Returns:
        Approximate fixed point
    """
    ga = f(a) - a
    gb = f(b) - b
    
    for _ in range(max_iter):
        mid = (a + b) / 2
        gmid = f(mid) - mid
        
        if abs(gmid) < tol or (b - a) < tol:
            return mid
        
        if ga * gmid <= 0:
            b = mid
            gb = gmid
        else:
            a = mid
            ga = gmid
    
    return (a + b) / 2


def dynamical_spectrum(f: Callable[[float], float],
                       x_samples: List[float],
                       max_period: int = 100) -> Set[int]:
    """
    Estimate the dynamical spectrum by sampling orbits.
    
    For each sample point, detect its period and add to the spectrum.
    
    Args:
        f: The dynamical map
        x_samples: Sample initial conditions
        max_period: Maximum period to detect
    
    Returns:
        Set of detected periods
    """
    periods: Set[int] = set()
    
    for x0 in x_samples:
        mu, lam = detect_period_floyd(f, x0)
        if 0 < lam <= max_period:
            periods.add(lam)
    
    return periods


def cognitive_state_classifier(
    f: Callable[[float], float],
    x0: float,
    n_settle: int = 1000,
    n_test: int = 1000,
    tol: float = 1e-8
) -> str:
    """
    Classify a cognitive trajectory as:
    - "fixed": converges to fixed point (deja vu = permanent)
    - "periodic": enters a cycle (deja vu = recurring pattern)
    - "chaotic": aperiodic (deja vu = fleeting/illusory)
    
    Args:
        f: Cognitive dynamics map
        x0: Initial cognitive state
        n_settle: Iterations to let orbit settle
        n_test: Iterations to test for periodicity
        tol: Tolerance
    
    Returns:
        Classification string
    """
    # Settle the orbit
    x = x0
    for _ in range(n_settle):
        x = f(x)
    
    anchor = x
    
    # Test for fixed point
    x_next = f(x)
    if abs(x_next - x) < tol:
        return "fixed"
    
    # Test for periodicity
    x = x_next
    for period in range(1, n_test):
        if abs(x - anchor) < tol:
            return f"periodic(period={period})"
        x = f(x)
    
    return "chaotic"


if __name__ == '__main__':
    # Example: Sharkovsky ordering verification
    print("Sharkovsky ordering examples:")
    print(f"  3 ◁ 5: {sharkovsky_order(3, 5)}")
    print(f"  3 ◁ 1: {sharkovsky_order(3, 1)}")
    print(f"  5 ◁ 3: {sharkovsky_order(5, 3)}")
    print(f"  2 ◁ 1: {sharkovsky_order(2, 1)}")
    print(f"  4 ◁ 2: {sharkovsky_order(4, 2)}")
    print(f"  6 ◁ 3: {sharkovsky_order(6, 3)}")
    
    # Dynamical spectrum of logistic map
    print("\nDynamical spectrum at various r values:")
    for r in [2.5, 3.2, 3.5, 3.83, 4.0]:
        f = lambda x, r=r: logistic_map(r, x)
        samples = [i/100 for i in range(1, 100)]
        spectrum = dynamical_spectrum(f, samples)
        print(f"  r = {r}: periods = {sorted(spectrum)}")
    
    # IVT fixed point
    print("\nIVT fixed point bisection:")
    for r in [2.5, 3.0, 3.5, 4.0]:
        f = lambda x, r=r: logistic_map(r, x)
        fp = ivt_fixed_point_bisection(f, 0.01, 0.99)
        print(f"  r = {r}: fixed point ≈ {fp:.10f}, "
              f"theoretical = {(r-1)/r:.10f}")
