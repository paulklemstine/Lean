"""
Algorithms for Cognitive Dynamical Systems Analysis

Implements algorithms for detecting periodic orbits, computing Lyapunov
exponents, and analyzing the Sharkovsky ordering in dynamical systems.

All algorithms come from the research paper on déjà vu as fixed points
in cognitive dynamics.
"""

from typing import Callable, Optional
import numpy as np


def detect_period(
    f: Callable[[float], float],
    x0: float,
    transient: int = 10000,
    max_period: int = 1000,
    tol: float = 1e-12
) -> tuple[int, list[float]]:
    """Detect the period of an orbit using Floyd's cycle detection adapted
    for continuous maps.

    Algorithm:
    1. Skip transient iterations to reach the attractor.
    2. Record states and check for ε-recurrence.
    3. Once recurrence found, verify by iterating the candidate period.

    Time complexity: O(transient + max_period²)
    Space complexity: O(max_period)

    Args:
        f: The dynamical system map
        x0: Initial state
        transient: Number of transient iterations to skip
        max_period: Maximum period to detect
        tol: Tolerance for equality comparison

    Returns:
        (period, cycle): The detected period and the periodic orbit states
    """
    # Phase 1: Skip transient
    x = x0
    for _ in range(transient):
        x = f(x)

    # Phase 2: Detect period via recurrence
    orbit = [x]
    for i in range(1, max_period + 1):
        x = f(x)
        for j, y in enumerate(orbit):
            if abs(x - y) < tol:
                candidate_period = i - j
                # Verify: check f^p(orbit[j]) ≈ orbit[j]
                z = orbit[j]
                for _ in range(candidate_period):
                    z = f(z)
                if abs(z - orbit[j]) < tol * 10:
                    return candidate_period, orbit[j:j + candidate_period]
        orbit.append(x)

    return 0, orbit  # No period detected


def lyapunov_exponent(
    f: Callable[[float], float],
    df: Callable[[float], float],
    x0: float,
    n_iter: int = 100000,
    transient: int = 10000
) -> float:
    """Compute the Lyapunov exponent of a one-dimensional map.

    The Lyapunov exponent λ measures the average rate of divergence of
    nearby trajectories:
        λ = lim_{n→∞} (1/n) Σ_{i=0}^{n-1} ln|f'(x_i)|

    λ > 0 indicates chaos (sensitive dependence on initial conditions).
    λ < 0 indicates convergence to a periodic orbit.
    λ = 0 indicates marginal stability.

    Time complexity: O(transient + n_iter)
    Space complexity: O(1)

    Args:
        f: The map
        df: The derivative of f
        x0: Initial condition
        n_iter: Number of iterations for the average
        transient: Transient iterations to skip

    Returns:
        The Lyapunov exponent
    """
    x = x0
    for _ in range(transient):
        x = f(x)

    lyap_sum = 0.0
    for _ in range(n_iter):
        deriv = abs(df(x))
        if deriv > 0:
            lyap_sum += np.log(deriv)
        else:
            lyap_sum += -100  # Effectively -infinity
        x = f(x)

    return lyap_sum / n_iter


def bifurcation_diagram(
    r_min: float = 2.5,
    r_max: float = 4.0,
    n_r: int = 1000,
    transient: int = 5000,
    n_plot: int = 200
) -> tuple[np.ndarray, np.ndarray]:
    """Compute the bifurcation diagram of the logistic map.

    For each parameter value r, compute the attractor by iterating
    past the transient and recording the subsequent orbit values.

    Time complexity: O(n_r * (transient + n_plot))
    Space complexity: O(n_r * n_plot)

    Args:
        r_min, r_max: Parameter range
        n_r: Number of r values
        transient: Transient iterations
        n_plot: Number of attractor points per r

    Returns:
        (r_values, x_values): Arrays for plotting
    """
    r_values = []
    x_values = []

    for r in np.linspace(r_min, r_max, n_r):
        x = 0.5
        for _ in range(transient):
            x = r * x * (1.0 - x)

        for _ in range(n_plot):
            x = r * x * (1.0 - x)
            r_values.append(r)
            x_values.append(x)

    return np.array(r_values), np.array(x_values)


def sharkovsky_chain(max_n: int = 20) -> list[int]:
    """Generate the Sharkovsky ordering of natural numbers.

    The Sharkovsky ordering is:
    3 ◁ 5 ◁ 7 ◁ 9 ◁ ... ◁ 2·3 ◁ 2·5 ◁ 2·7 ◁ ... ◁ 4·3 ◁ 4·5 ◁ ...
    ◁ ... ◁ 2³ ◁ 2² ◁ 2 ◁ 1

    If f has a point of period m, then f has a point of period n for all
    n that come after m in the Sharkovsky ordering.

    Time complexity: O(max_n * log(max_n))
    Space complexity: O(max_n)

    Args:
        max_n: Generate ordering up to this number

    Returns:
        List of integers in Sharkovsky order
    """
    # Classify each number by its Sharkovsky level
    def sharkovsky_key(n: int) -> tuple[int, int, int]:
        if n == 1:
            return (float('inf'), 0, 0)

        # Factor out powers of 2
        k = 0
        m = n
        while m % 2 == 0:
            k += 1
            m //= 2

        if m == 1:
            # Pure power of 2: these come at the end, larger powers first
            return (1, -k, 0)
        else:
            # 2^k * odd: ordered by k first (ascending), then odd part
            return (0, k, m)

    numbers = list(range(1, max_n + 1))
    numbers.sort(key=sharkovsky_key)
    return numbers


def deja_vu_frequency_model(
    r: float,
    x0: float = 0.5,
    n_iter: int = 100000,
    epsilon: float = 0.01
) -> dict:
    """Model déjà vu frequency for the logistic map at parameter r.

    Computes the fraction of cognitive states that are ε-close to a
    previously visited state, modeling the déjà vu experience rate.

    Time complexity: O(n_iter * window_size)
    Space complexity: O(window_size)

    Args:
        r: Logistic map parameter
        x0: Initial cognitive state
        n_iter: Number of cognitive transitions to simulate
        epsilon: Recognition threshold (how close states must be
                 to trigger déjà vu)

    Returns:
        Dictionary with frequency, period, and Lyapunov exponent
    """
    f = lambda x: r * x * (1.0 - x)
    df = lambda x: r * (1.0 - 2.0 * x)

    # Detect period
    period, cycle = detect_period(f, x0)

    # Compute Lyapunov exponent
    lyap = lyapunov_exponent(f, df, x0)

    # Compute déjà vu frequency
    x = x0
    for _ in range(10000):  # transient
        x = f(x)

    window = []
    window_size = 100
    deja_vu_count = 0

    for i in range(n_iter):
        x = f(x)
        is_deja_vu = any(abs(x - w) < epsilon for w in window)
        if is_deja_vu:
            deja_vu_count += 1

        window.append(x)
        if len(window) > window_size:
            window.pop(0)

    return {
        "r": r,
        "period": period,
        "lyapunov": lyap,
        "deja_vu_frequency": deja_vu_count / n_iter,
        "cycle": cycle[:min(5, len(cycle))] if cycle else []
    }


# Example usage
if __name__ == "__main__":
    print("Sharkovsky ordering (first 20):")
    chain = sharkovsky_chain(20)
    print(" ◁ ".join(str(n) for n in chain))
    print()

    print("Déjà vu frequency across logistic map parameters:")
    print(f"{'r':>6s}  {'Period':>6s}  {'λ':>8s}  {'DV freq':>8s}")
    print(f"{'─'*6}  {'─'*6}  {'─'*8}  {'─'*8}")

    for r in [2.5, 3.0, 3.2, 3.5, 3.56995, 3.8284, 3.9, 4.0]:
        result = deja_vu_frequency_model(r, n_iter=50000, epsilon=0.01)
        print(f"{r:6.4f}  {result['period']:6d}  {result['lyapunov']:8.4f}  "
              f"{result['deja_vu_frequency']:8.4f}")
