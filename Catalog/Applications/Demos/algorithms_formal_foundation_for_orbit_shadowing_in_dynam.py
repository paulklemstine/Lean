"""
Orbit Shadowing Algorithms

Type-hinted implementations of core shadowing algorithms for dynamical systems.
"""

from typing import Callable, List, Tuple, Optional
import math


def is_pseudo_orbit(
    f: Callable[[float], float],
    x: List[float],
    delta: float,
) -> bool:
    """Check if sequence x is a δ-pseudo-orbit of f.

    A sequence (x_0, x_1, ..., x_N) is a δ-pseudo-orbit if
    |f(x_n) - x_{n+1}| ≤ δ for all n.

    Args:
        f: The dynamical system map.
        x: The candidate pseudo-orbit sequence.
        delta: The error tolerance.

    Returns:
        True if x is a δ-pseudo-orbit of f.
    """
    for n in range(len(x) - 1):
        if abs(f(x[n]) - x[n + 1]) > delta:
            return False
    return True


def compute_true_orbit(
    f: Callable[[float], float],
    x0: float,
    length: int,
) -> List[float]:
    """Compute the true orbit of f starting at x0.

    Args:
        f: The dynamical system map.
        x0: The initial point.
        length: Number of iterates to compute.

    Returns:
        List [x0, f(x0), f²(x0), ..., f^{length-1}(x0)].
    """
    orbit = [x0]
    for _ in range(length - 1):
        orbit.append(f(orbit[-1]))
    return orbit


def shadowing_certificate(
    f: Callable[[float], float],
    pseudo_orbit: List[float],
    lipschitz_const: float,
    delta: float,
) -> dict:
    """Construct a shadowing certificate from the contractive shadowing lemma.

    Given an L-contraction (L < 1) and a δ-pseudo-orbit, constructs the
    true orbit starting at x_0 and certifies shadowing within δ/(1-L).

    Args:
        f: The dynamical system map (must be L-Lipschitz with L < 1).
        pseudo_orbit: A δ-pseudo-orbit of f.
        lipschitz_const: The Lipschitz constant L < 1.
        delta: The pseudo-orbit error bound.

    Returns:
        Dictionary with keys: pseudo, shadow, delta, epsilon, max_error.
    """
    if lipschitz_const >= 1:
        raise ValueError(f"Lipschitz constant must be < 1, got {lipschitz_const}")

    shadow = compute_true_orbit(f, pseudo_orbit[0], len(pseudo_orbit))
    epsilon = delta / (1 - lipschitz_const)
    max_error = max(abs(s - p) for s, p in zip(shadow, pseudo_orbit))

    return {
        "pseudo": pseudo_orbit,
        "shadow": shadow,
        "delta": delta,
        "epsilon": epsilon,
        "theoretical_bound": epsilon,
        "actual_max_error": max_error,
        "bound_satisfied": max_error <= epsilon + 1e-12,
        "length": len(pseudo_orbit),
    }


def shadowing_defect(
    y: List[float],
    x: List[float],
) -> float:
    """Compute the shadowing defect: max |y_n - x_n|.

    Args:
        y: The candidate shadow orbit.
        x: The pseudo-orbit.

    Returns:
        Maximum pointwise distance.
    """
    return max(abs(yi - xi) for yi, xi in zip(y, x))


def generate_pseudo_orbit(
    f: Callable[[float], float],
    x0: float,
    length: int,
    noise_amplitude: float,
) -> Tuple[List[float], float]:
    """Generate a pseudo-orbit by adding bounded noise to each step.

    Args:
        f: The dynamical system map.
        x0: Initial point.
        length: Orbit length.
        noise_amplitude: Maximum per-step noise.

    Returns:
        Tuple of (pseudo-orbit, actual max step error).
    """
    import random
    pseudo = [x0]
    max_error = 0.0
    for _ in range(length - 1):
        exact_next = f(pseudo[-1])
        noise = random.uniform(-noise_amplitude, noise_amplitude)
        noisy_next = exact_next + noise
        step_error = abs(noise)
        max_error = max(max_error, step_error)
        pseudo.append(noisy_next)
    return pseudo, max_error


def verify_expansive_uniqueness(
    f: Callable[[float], float],
    x: List[float],
    y1_start: float,
    y2_start: float,
    expansivity_const: float,
    epsilon: float,
    steps: int,
) -> dict:
    """Numerically verify shadowing uniqueness for an expansive map.

    Args:
        f: The dynamical system.
        x: The pseudo-orbit.
        y1_start, y2_start: Starting points of two candidate shadows.
        expansivity_const: The expansivity constant c.
        epsilon: The shadowing radius.
        steps: Number of steps to check.

    Returns:
        Dictionary with verification results.
    """
    y1 = compute_true_orbit(f, y1_start, steps)
    y2 = compute_true_orbit(f, y2_start, steps)

    y1_shadows = all(abs(y1[n] - x[n]) <= epsilon + 1e-10 for n in range(min(steps, len(x))))
    y2_shadows = all(abs(y2[n] - x[n]) <= epsilon + 1e-10 for n in range(min(steps, len(x))))

    max_orbit_dist = max(abs(y1[n] - y2[n]) for n in range(steps))
    orbits_close = max_orbit_dist <= expansivity_const

    return {
        "y1_shadows": y1_shadows,
        "y2_shadows": y2_shadows,
        "max_orbit_distance": max_orbit_dist,
        "orbits_within_c": orbits_close,
        "2eps_le_c": 2 * epsilon <= expansivity_const,
        "uniqueness_holds": abs(y1_start - y2_start) < 1e-10 if (y1_shadows and y2_shadows and 2 * epsilon <= expansivity_const) else None,
    }


def contraction_convergence_rate(
    f: Callable[[float], float],
    lipschitz_const: float,
    x: float,
    y: float,
    steps: int,
) -> List[Tuple[int, float, float]]:
    """Track the exponential convergence of two orbits under contraction.

    Args:
        f: The contraction map.
        lipschitz_const: The Lipschitz constant L < 1.
        x, y: Initial points.
        steps: Number of steps.

    Returns:
        List of (step, actual_dist, theoretical_bound) triples.
    """
    results = []
    d0 = abs(x - y)
    xn, yn = x, y
    for n in range(steps):
        actual = abs(xn - yn)
        bound = lipschitz_const ** n * d0
        results.append((n, actual, bound))
        xn = f(xn)
        yn = f(yn)
    return results


if __name__ == "__main__":
    # Example: f(x) = 0.5x (L = 0.5 contraction)
    L = 0.5
    f = lambda x: L * x

    print("=== Shadowing Certificate Demo ===")
    pseudo, delta = generate_pseudo_orbit(f, 1.0, 20, 0.1)
    cert = shadowing_certificate(f, pseudo, L, delta)
    print(f"Pseudo-orbit length: {cert['length']}")
    print(f"Per-step error δ: {cert['delta']:.6f}")
    print(f"Theoretical bound δ/(1-L): {cert['theoretical_bound']:.6f}")
    print(f"Actual max error: {cert['actual_max_error']:.6f}")
    print(f"Bound satisfied: {cert['bound_satisfied']}")
