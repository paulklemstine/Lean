#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for Recurrence Spectrum analysis

Type-hinted implementations of the key computational methods underlying
the Recurrence Spectrum theory of dynamical systems.
"""

from typing import List, Dict, Tuple, Optional, Callable, Set
import math


def logistic_map(r: float, x: float) -> float:
    """The logistic map f(x) = r·x·(1-x).
    
    Args:
        r: The bifurcation parameter (typically 0 ≤ r ≤ 4).
        x: The current state (typically in [0,1]).
    
    Returns:
        The next state r·x·(1-x).
    """
    return r * x * (1.0 - x)


def iterate(f: Callable[[float], float], x: float, n: int) -> float:
    """Compute f^n(x) by iterating f exactly n times.
    
    Args:
        f: The map to iterate.
        x: The starting point.
        n: Number of iterations (must be ≥ 0).
    
    Returns:
        f^n(x) = f(f(...f(x)...)) applied n times.
    """
    for _ in range(n):
        x = f(x)
    return x


def orbit(f: Callable[[float], float], x: float, length: int) -> List[float]:
    """Compute the orbit [x, f(x), f²(x), ..., f^(length-1)(x)].
    
    Args:
        f: The dynamical map.
        x: The starting point.
        length: Number of orbit points to compute.
    
    Returns:
        List of orbit points.
    """
    result = [x]
    for _ in range(length - 1):
        x = f(x)
        result.append(x)
    return result


def detect_period(f: Callable[[float], float], x: float,
                  max_period: int = 1000, tol: float = 1e-10) -> Optional[int]:
    """Detect the minimal period of x under f, if periodic.
    
    Uses Floyd's cycle detection adapted for floating-point dynamics.
    
    Args:
        f: The dynamical map.
        x: The point to test.
        max_period: Maximum period to check.
        tol: Tolerance for floating-point comparison.
    
    Returns:
        The minimal period if found, None otherwise.
    """
    for p in range(1, max_period + 1):
        y = iterate(f, x, p)
        if abs(y - x) < tol:
            return p
    return None


def sharkovsky_rank(n: int) -> Tuple[int, int, int]:
    """Compute the Sharkovsky rank of a positive integer n.
    
    Decomposes n = 2^k · m where m is odd, and returns (class, k, m) where:
    - class 0: n is a power of 2 (weakest in Sharkovsky ordering)
    - class 1: n has both even and odd parts (middle)
    - class 2: n is odd and ≥ 3 (strongest in Sharkovsky ordering)
    
    The Sharkovsky ordering is:
    3 ◁ 5 ◁ 7 ◁ ... ◁ 2·3 ◁ 2·5 ◁ ... ◁ 4·3 ◁ ... ◁ 8 ◁ 4 ◁ 2 ◁ 1
    
    Args:
        n: A positive integer.
    
    Returns:
        Tuple (sharkovsky_class, two_adic_valuation, odd_part).
    """
    if n <= 0:
        raise ValueError("n must be positive")
    
    k = 0
    m = n
    while m % 2 == 0:
        k += 1
        m //= 2
    
    if m == 1:
        return (0, k, 1)  # Power of 2
    elif k == 0:
        return (2, 0, m)  # Odd number
    else:
        return (1, k, m)  # Mixed


def sharkovsky_le(n: int, m: int) -> bool:
    """Check if n ◁_S m in the Sharkovsky ordering.
    
    Returns True iff period-n forces period-m, i.e., any continuous
    interval map with a period-n point must also have a period-m point.
    
    Args:
        n: First period (must be positive).
        m: Second period (must be positive).
    
    Returns:
        True if n Sharkovsky-dominates m.
    """
    if n <= 0 or m <= 0:
        return False
    
    cn, kn, on_ = sharkovsky_rank(n)
    cm, km, om = sharkovsky_rank(m)
    
    if cn > cm:
        return True  # Higher class dominates
    elif cn < cm:
        return False
    else:
        # Same class
        if cn == 0:
            # Both powers of 2: larger dominates
            return n >= m
        elif cn == 2:
            # Both odd: smaller odd number dominates
            return on_ <= om
        else:
            # Both mixed: compare 2-adic valuation first, then odd part
            if kn < km:
                return True
            elif kn > km:
                return False
            else:
                return on_ <= om


def compute_recurrence_spectrum(
    f: Callable[[float], float],
    x_range: Tuple[float, float] = (0.01, 0.99),
    n_samples: int = 500,
    n_transient: int = 500,
    max_period: int = 20,
    tol: float = 1e-8
) -> Dict[int, List[float]]:
    """Compute the recurrence spectrum of a map on an interval.
    
    The recurrence spectrum is the set of minimal periods realized by
    periodic orbits, together with representative periodic points.
    
    Args:
        f: The dynamical map.
        x_range: Range to sample initial conditions from.
        n_samples: Number of initial conditions to test.
        n_transient: Transient iterations to discard.
        max_period: Maximum period to detect.
        tol: Tolerance for period detection.
    
    Returns:
        Dictionary mapping period -> list of periodic points.
    """
    import numpy as np
    
    spectrum: Dict[int, List[float]] = {}
    x_lo, x_hi = x_range
    
    for x0 in np.linspace(x_lo, x_hi, n_samples):
        x = float(x0)
        for _ in range(n_transient):
            x = f(x)
        
        period = detect_period(f, x, max_period, tol)
        if period is not None:
            if period not in spectrum:
                spectrum[period] = []
            if not any(abs(x - p) < tol for p in spectrum[period]):
                spectrum[period].append(x)
    
    return {k: sorted(v) for k, v in sorted(spectrum.items())}


def sharkovsky_closure(periods: Set[int]) -> Set[int]:
    """Compute the Sharkovsky closure of a set of periods.
    
    Given a set of periods, returns all periods that must also exist
    by Sharkovsky's theorem.
    
    Args:
        periods: Set of known periods.
    
    Returns:
        The Sharkovsky closure — all forced periods up to some bound.
    """
    max_check = max(periods) * 4 if periods else 1
    closure = set(periods)
    
    for n in periods:
        for m in range(1, max_check + 1):
            if sharkovsky_le(n, m):
                closure.add(m)
    
    return closure


def spectral_entropy_estimate(
    f: Callable[[float], float],
    max_n: int = 15,
    n_samples: int = 1000,
    tol: float = 1e-8
) -> float:
    """Estimate the spectral entropy from periodic point growth.
    
    The spectral entropy h(f) measures the exponential growth rate of
    the number of period-n points: |Fix(f^n)| ~ e^(nh(f)).
    
    Args:
        f: The dynamical map.
        max_n: Maximum period to check.
        n_samples: Number of sample points.
        tol: Tolerance for periodicity detection.
    
    Returns:
        Estimated spectral entropy.
    """
    import numpy as np
    
    counts = []
    for n in range(1, max_n + 1):
        count = 0
        for x0 in np.linspace(0.01, 0.99, n_samples):
            x = float(x0)
            for _ in range(200):
                x = f(x)
            y = iterate(f, x, n)
            if abs(y - x) < tol:
                count += 1
        counts.append(max(count, 1))
    
    # Linear regression on log(count) vs n
    ns = np.arange(1, max_n + 1, dtype=float)
    log_counts = np.log(np.array(counts, dtype=float))
    
    # Least squares: h = slope of log(count) vs n
    n_mean = ns.mean()
    lc_mean = log_counts.mean()
    slope = np.sum((ns - n_mean) * (log_counts - lc_mean)) / np.sum((ns - n_mean)**2)
    
    return max(slope, 0.0)


def bifurcation_diagram(
    r_range: Tuple[float, float] = (2.5, 4.0),
    n_r: int = 1000,
    n_transient: int = 500,
    n_plot: int = 200,
    x0: float = 0.5
) -> Tuple[List[float], List[float]]:
    """Compute the bifurcation diagram of the logistic map.
    
    Args:
        r_range: Range of r values.
        n_r: Number of r values to sample.
        n_transient: Transient iterations.
        n_plot: Number of post-transient points to record.
        x0: Initial condition.
    
    Returns:
        Tuple of (r_values, x_values) for plotting.
    """
    import numpy as np
    
    r_values = []
    x_values = []
    
    for r in np.linspace(r_range[0], r_range[1], n_r):
        x = x0
        for _ in range(n_transient):
            x = logistic_map(float(r), x)
        for _ in range(n_plot):
            x = logistic_map(float(r), x)
            r_values.append(float(r))
            x_values.append(x)
    
    return r_values, x_values


if __name__ == "__main__":
    # Quick self-test
    print("Sharkovsky ordering test:")
    print(f"  3 ◁ 5: {sharkovsky_le(3, 5)}")
    print(f"  3 ◁ 1: {sharkovsky_le(3, 1)}")
    print(f"  3 ◁ 2: {sharkovsky_le(3, 2)}")
    print(f"  5 ◁ 3: {sharkovsky_le(5, 3)}")
    print(f"  2 ◁ 1: {sharkovsky_le(2, 1)}")
    print(f"  4 ◁ 2: {sharkovsky_le(4, 2)}")
    
    print("\nSharkovsky closure of {3}:")
    print(f"  {sorted(sharkovsky_closure({3}))}")
    
    print("\nRecurrence spectrum at r=3.83:")
    f = lambda x: logistic_map(3.83, x)
    spec = compute_recurrence_spectrum(f, max_period=8)
    for period, pts in spec.items():
        print(f"  Period {period}: {len(pts)} point(s)")
