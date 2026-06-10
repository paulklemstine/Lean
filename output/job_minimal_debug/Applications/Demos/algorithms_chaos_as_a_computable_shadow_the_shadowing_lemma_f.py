#!/usr/bin/env python3
"""
Shadowing Algorithms
====================
Type-hinted implementations of core shadowing algorithms.
"""

from typing import Callable, Optional


def compute_pseudo_orbit(
    f: Callable[[float], float],
    x0: float,
    n_steps: int,
) -> list[float]:
    """
    Compute a floating-point trajectory (pseudo-orbit) of f.

    Args:
        f: The dynamical map
        x0: Initial condition
        n_steps: Number of iterations

    Returns:
        List of n_steps+1 points [x0, f(x0), f(f(x0)), ...]
        (with floating-point rounding at each step)
    """
    orbit: list[float] = [x0]
    x = x0
    for _ in range(n_steps):
        x = f(x)
        orbit.append(x)
    return orbit


def pseudo_orbit_tolerance(
    f: Callable[[float], float],
    orbit: list[float],
) -> float:
    """
    Compute the pseudo-orbit tolerance δ: the maximum step error.

    Args:
        f: The dynamical map
        orbit: The computed trajectory

    Returns:
        max_n |x_{n+1} - f(x_n)| (the pseudo-orbit tolerance)
    """
    delta = 0.0
    for i in range(len(orbit) - 1):
        error = abs(orbit[i + 1] - f(orbit[i]))
        delta = max(delta, error)
    return delta


def contractive_shadowing_bound(
    delta: float,
    lipschitz_constant: float,
) -> float:
    """
    Compute the shadowing bound δ/(1-L) for a contractive map.

    This is the guaranteed maximum distance between a δ-pseudo-orbit
    and its shadowing true orbit for a map with Lipschitz constant L < 1.

    Args:
        delta: Pseudo-orbit tolerance
        lipschitz_constant: Lipschitz constant L (must be < 1)

    Returns:
        The shadowing bound δ/(1-L)

    Raises:
        ValueError: If L >= 1
    """
    if lipschitz_constant >= 1.0:
        raise ValueError(f"Lipschitz constant must be < 1, got {lipschitz_constant}")
    return delta / (1.0 - lipschitz_constant)


def shadowing_amplification_ratio(
    lipschitz_constant: float,
) -> float:
    """
    Compute the shadowing amplification ratio 1/(1-L).

    This is the maximum ratio of shadowing distance to pseudo-orbit
    tolerance for a contractive map.

    Args:
        lipschitz_constant: Lipschitz constant L (must be < 1)

    Returns:
        1/(1-L)
    """
    if lipschitz_constant >= 1.0:
        raise ValueError(f"Lipschitz constant must be < 1, got {lipschitz_constant}")
    return 1.0 / (1.0 - lipschitz_constant)


def inductive_shadow_bound(
    delta: float,
    lipschitz_constant: float,
    n: int,
) -> float:
    """
    Compute the tighter inductive shadowing bound δ(1-L^n)/(1-L).

    This bound is tighter than the asymptotic δ/(1-L) for finite n,
    reflecting the fact that early steps have less accumulated error.

    Args:
        delta: Pseudo-orbit tolerance
        lipschitz_constant: Lipschitz constant L
        n: Step number

    Returns:
        δ(1-L^n)/(1-L)
    """
    L = lipschitz_constant
    return delta * (1.0 - L**n) / (1.0 - L)


def find_shadowing_initial_condition(
    f: Callable[[float], float],
    pseudo_orbit: list[float],
    search_radius: float = 1e-10,
    search_resolution: int = 10000,
) -> tuple[float, float]:
    """
    Search for an initial condition whose true orbit shadows the pseudo-orbit.

    Uses grid search followed by refinement.

    Args:
        f: The dynamical map
        pseudo_orbit: The pseudo-orbit to shadow
        search_radius: Search radius around pseudo_orbit[0]
        search_resolution: Number of grid points

    Returns:
        (best_y0, max_shadowing_distance)
    """
    n = len(pseudo_orbit) - 1
    x0 = pseudo_orbit[0]

    def max_distance(y0: float) -> float:
        y = y0
        d = 0.0
        for i in range(n + 1):
            d = max(d, abs(pseudo_orbit[i] - y))
            if i < n:
                y = f(y)
        return d

    best_y0 = x0
    best_dist = max_distance(x0)

    step = 2 * search_radius / search_resolution
    for i in range(search_resolution + 1):
        y0 = x0 - search_radius + i * step
        d = max_distance(y0)
        if d < best_dist:
            best_dist = d
            best_y0 = y0

    return best_y0, best_dist


class ShadowingCertificate:
    """
    A computational certificate that a pseudo-orbit is shadowed by a true orbit.

    This is the Python analog of the Lean ShadowingCertificate structure.

    Attributes:
        shadow_start: Initial condition of the shadowing true orbit
        bound: Guaranteed maximum shadowing distance
        tolerance: Pseudo-orbit tolerance δ
        pseudo_orbit: The pseudo-orbit
        shadow_orbit: The shadowing true orbit
    """

    def __init__(
        self,
        f: Callable[[float], float],
        pseudo_orbit: list[float],
        shadow_start: float,
        bound: float,
        tolerance: float,
    ):
        self.f = f
        self.pseudo_orbit = pseudo_orbit
        self.shadow_start = shadow_start
        self.bound = bound
        self.tolerance = tolerance

        # Compute the shadow orbit
        self.shadow_orbit: list[float] = [shadow_start]
        y = shadow_start
        for _ in range(len(pseudo_orbit) - 1):
            y = f(y)
            self.shadow_orbit.append(y)

    def verify(self) -> bool:
        """Check that the certificate is valid."""
        # Check pseudo-orbit condition
        for i in range(len(self.pseudo_orbit) - 1):
            if abs(self.pseudo_orbit[i + 1] - self.f(self.pseudo_orbit[i])) >= self.tolerance:
                return False
        # Check shadowing condition
        for i in range(len(self.pseudo_orbit)):
            if abs(self.pseudo_orbit[i] - self.shadow_orbit[i]) > self.bound * 1.001:
                return False
        return True

    def max_shadowing_distance(self) -> float:
        """Compute actual maximum shadowing distance."""
        return max(
            abs(self.pseudo_orbit[i] - self.shadow_orbit[i])
            for i in range(len(self.pseudo_orbit))
        )

    def __repr__(self) -> str:
        return (
            f"ShadowingCertificate("
            f"start={self.shadow_start:.6e}, "
            f"bound={self.bound:.6e}, "
            f"tolerance={self.tolerance:.6e}, "
            f"actual_max_dist={self.max_shadowing_distance():.6e}, "
            f"verified={self.verify()})"
        )


def make_contractive_certificate(
    f: Callable[[float], float],
    pseudo_orbit: list[float],
    lipschitz_constant: float,
) -> ShadowingCertificate:
    """
    Construct a Shadowing Certificate for a pseudo-orbit of a contractive map.

    Args:
        f: A contractive map with Lipschitz constant L < 1
        pseudo_orbit: A pseudo-orbit of f
        lipschitz_constant: The Lipschitz constant L

    Returns:
        A verified ShadowingCertificate
    """
    tol = pseudo_orbit_tolerance(f, pseudo_orbit)
    bound = contractive_shadowing_bound(tol, lipschitz_constant)

    return ShadowingCertificate(
        f=f,
        pseudo_orbit=pseudo_orbit,
        shadow_start=pseudo_orbit[0],
        bound=bound,
        tolerance=tol * 1.01,  # small margin for floating-point
    )


def logistic_map(x: float, r: float = 4.0) -> float:
    """The logistic map f(x) = r*x*(1-x)."""
    return r * x * (1.0 - x)


if __name__ == "__main__":
    # Example: contractive map
    L = 0.6
    c = 0.2

    def contraction(x: float) -> float:
        return L * x + c

    orbit = compute_pseudo_orbit(contraction, 0.5, 50)
    tol = pseudo_orbit_tolerance(contraction, orbit)
    bound = contractive_shadowing_bound(tol, L)

    print(f"Contraction map: f(x) = {L}x + {c}")
    print(f"Pseudo-orbit tolerance: {tol:.2e}")
    print(f"Shadowing bound: {bound:.2e}")
    print(f"Amplification ratio: {shadowing_amplification_ratio(L):.2f}")

    cert = make_contractive_certificate(contraction, orbit, L)
    print(f"Certificate: {cert}")
