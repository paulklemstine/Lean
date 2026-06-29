#!/usr/bin/env python3
"""
Algorithms for Continuous Iteration Theory

Implements core algorithms for orbit computation, semiconjugacy verification,
and dynamical feature extraction based on the formally proved theorems.
"""

import numpy as np
from typing import Callable, List, Tuple, Optional


def iterate(f: Callable[[np.ndarray], np.ndarray], x: np.ndarray, n: int) -> np.ndarray:
    """
    Compute the n-th iterate f^[n](x).

    Based on: iterate_action_add (monoid action of ℕ).

    Time complexity: O(n * T_f) where T_f is the cost of one application of f.
    Space complexity: O(dim(x)).

    Args:
        f: A continuous self-map.
        x: Initial point.
        n: Number of iterations.

    Returns:
        f^[n](x)
    """
    for _ in range(n):
        x = f(x)
    return x


def orbit_vector(f: Callable[[np.ndarray], np.ndarray], x: np.ndarray, N: int) -> np.ndarray:
    """
    Compute the orbit vector (f^[0](x), f^[1](x), ..., f^[N-1](x)).

    Based on: continuous_orbit_vector — this is a continuous map into the
    product space when f is continuous.

    Time complexity: O(N * T_f).
    Space complexity: O(N * dim(x)).

    Args:
        f: A continuous self-map.
        x: Initial point (scalar or array).
        N: Length of orbit vector.

    Returns:
        Array of shape (N,) + x.shape containing the orbit segment.
    """
    x = np.asarray(x)
    result = np.empty((N,) + x.shape, dtype=x.dtype)
    result[0] = x
    for k in range(1, N):
        x = f(x)
        result[k] = x
    return result


def verify_semiconjugacy(
    h: Callable, f: Callable, g: Callable,
    test_points: np.ndarray, n_iters: int = 10, tol: float = 1e-10
) -> Tuple[bool, float]:
    """
    Verify semiconjugacy h ∘ f = g ∘ h numerically, then check orbit transfer.

    Based on: semiconj_iterate — if h ∘ f = g ∘ h, then h ∘ f^[n] = g^[n] ∘ h.

    Time complexity: O(|test_points| * n_iters * (T_f + T_g + T_h)).

    Args:
        h: The semiconjugacy map.
        f: Source dynamics.
        g: Target dynamics.
        test_points: Points to test.
        n_iters: Number of iterations to verify.
        tol: Numerical tolerance.

    Returns:
        (is_semiconjugate, max_error) tuple.
    """
    max_error = 0.0

    for x in test_points:
        for n in range(n_iters + 1):
            fn_x = iterate(f, x, n)
            gn_hx = iterate(g, h(x), n)

            h_fn_x = h(fn_x)
            error = abs(h_fn_x - gn_hx)
            max_error = max(max_error, float(np.max(error)))

    return max_error < tol, max_error


def detect_period(
    f: Callable, x: float, max_iter: int = 10000, tol: float = 1e-12
) -> Tuple[Optional[int], Optional[int]]:
    """
    Detect eventual periodicity of an orbit using Floyd's algorithm.

    Based on: semiconj_periodic_point — periodic points transfer through semiconjugacy.

    Time complexity: O(μ + λ) where μ is preperiod and λ is period.
    Space complexity: O(1).

    Args:
        f: Self-map.
        x: Initial point.
        max_iter: Maximum iterations before giving up.
        tol: Tolerance for equality.

    Returns:
        (preperiod, period) or (None, None) if no periodicity detected.
    """
    # Phase 1: Find a collision (tortoise and hare)
    tortoise = f(x)
    hare = f(f(x))
    steps = 0
    while abs(tortoise - hare) > tol and steps < max_iter:
        tortoise = f(tortoise)
        hare = f(f(hare))
        steps += 1

    if steps >= max_iter:
        return None, None

    # Phase 2: Find preperiod μ
    mu = 0
    tortoise = x
    while abs(tortoise - hare) > tol:
        tortoise = f(tortoise)
        hare = f(hare)
        mu += 1

    # Phase 3: Find period λ
    lam = 1
    hare = f(tortoise)
    while abs(tortoise - hare) > tol and lam < max_iter:
        hare = f(hare)
        lam += 1

    return mu, lam


def orbit_feature_map(
    f: Callable, phi: Callable, N: int, x: np.ndarray
) -> float:
    """
    Compute a continuous feature from an orbit vector: φ(orbit_vector(f, x, N)).

    Based on: continuous_orbit_vector composed with continuous φ.

    This is the bridge to machine learning: orbit vectors become features.

    Args:
        f: Continuous self-map.
        phi: Continuous functional on orbit space (e.g., max, sum, norm).
        N: Orbit length.
        x: Initial point.

    Returns:
        Feature value φ(f^[0](x), ..., f^[N-1](x)).
    """
    ov = orbit_vector(f, x, N)
    return phi(ov)


def iterate_image_bounds(
    f: Callable, interval: Tuple[float, float], n: int, resolution: int = 10000
) -> Tuple[float, float]:
    """
    Estimate the image of a compact interval under n-fold iteration.

    Based on: iterate_image_compact — continuous image of compact is compact.
    In ℝ, compact connected = closed bounded interval.

    Args:
        f: Continuous self-map of ℝ.
        interval: (a, b) defining the initial compact set [a, b].
        n: Number of iterations.
        resolution: Number of sample points.

    Returns:
        (min, max) of the estimated image interval.
    """
    pts = np.linspace(interval[0], interval[1], resolution)
    for _ in range(n):
        pts = np.vectorize(f)(pts)
    return float(pts.min()), float(pts.max())


def commuting_orbit_transfer(
    f: Callable, g: Callable, x: float, n: int
) -> Tuple[float, float]:
    """
    Verify commutation transfer: g(f^[n](x)) should equal f^[n](g(x)).

    Based on: commute_iterate_apply and image_iterate_of_commute.

    Args:
        f, g: Commuting self-maps.
        x: Test point.
        n: Iteration count.

    Returns:
        (g(f^[n](x)), f^[n](g(x))) — should be equal if f,g commute.
    """
    fn_x = iterate(f, x, n)
    return g(fn_x), iterate(f, g(x), n)


# ===========================================================================
# Example usage
# ===========================================================================
if __name__ == "__main__":
    print("=== Orbit Vector Feature Map ===")
    f = lambda x: 0.9 * np.sin(x) + 0.1
    for x0 in [0.0, 1.0, 2.0, 3.0]:
        feature_max = orbit_feature_map(f, np.max, 20, x0)
        feature_mean = orbit_feature_map(f, np.mean, 20, x0)
        print(f"  x₀={x0:.1f}: max_feature={feature_max:.6f}, mean_feature={feature_mean:.6f}")

    print("\n=== Period Detection ===")
    # f(x) = 4x(1-x) has period-2 cycle at x ≈ 0.3455
    f_logistic = lambda x: 3.2 * x * (1 - x)
    x0 = 0.1
    mu, lam = detect_period(f_logistic, x0)
    print(f"  Logistic map r=3.2: preperiod={mu}, period={lam}")

    print("\n=== Semiconjugacy Verification ===")
    f_double = lambda x: 2 * x
    g_square = lambda x: x ** 2
    h_exp = lambda x: 2.0 ** x
    test_pts = np.linspace(-2, 2, 20)
    is_sc, err = verify_semiconjugacy(h_exp, f_double, g_square, test_pts, n_iters=5)
    print(f"  h=2^x, f=2x, g=x²: semiconjugate={is_sc}, max_error={err:.2e}")

    print("\n=== Image Bounds Under Iteration ===")
    f_sin = lambda x: 0.7 * np.sin(x) + 0.5
    for n in [0, 1, 5, 10, 20]:
        lo, hi = iterate_image_bounds(f_sin, (0, 3), n)
        print(f"  n={n:2d}: f^[n]([0,3]) ⊂ [{lo:.6f}, {hi:.6f}]")
