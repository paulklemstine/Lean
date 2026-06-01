#!/usr/bin/env python3
"""
Orbit Shadowing: Core Algorithms

Type-hinted implementations of the key algorithms from the orbit shadowing theory.
"""

from typing import Callable, List, Tuple, Optional
from dataclasses import dataclass
import math


@dataclass
class ShadowingCertificate:
    """A computational certificate that a pseudo-orbit is shadowed by a true orbit.

    Fields:
        pseudo: The pseudo-orbit (numerical approximation)
        shadow: The shadowing true orbit
        delta: Per-step pseudo-orbit error bound
        epsilon: Shadowing radius (delta / (1 - L))
        contraction: Lipschitz constant L of the map
    """
    pseudo: List[float]
    shadow: List[float]
    delta: float
    epsilon: float
    contraction: float

    def verify(self, f: Callable[[float], float], tol: float = 1e-10) -> bool:
        """Verify that this certificate is valid."""
        n = len(self.pseudo)
        if len(self.shadow) != n:
            return False
        # Check shadow is a true orbit
        for i in range(n - 1):
            if abs(self.shadow[i + 1] - f(self.shadow[i])) > tol:
                return False
        # Check pseudo is a δ-pseudo-orbit
        for i in range(n - 1):
            if abs(f(self.pseudo[i]) - self.pseudo[i + 1]) > self.delta + tol:
                return False
        # Check shadowing radius
        for i in range(n):
            if abs(self.shadow[i] - self.pseudo[i]) > self.epsilon + tol:
                return False
        return True

    def defect(self) -> float:
        """Compute the actual maximum shadowing distance."""
        return max(abs(s - p) for s, p in zip(self.shadow, self.pseudo))


def compute_true_orbit(f: Callable[[float], float], x0: float, n: int) -> List[float]:
    """Compute the true orbit f, f², f³, ... starting at x0.

    Algorithm: Simple forward iteration.
    Time complexity: O(n)
    Space complexity: O(n)
    """
    orbit: List[float] = [x0]
    x = x0
    for _ in range(n):
        x = f(x)
        orbit.append(x)
    return orbit


def compute_pseudo_orbit(
    f: Callable[[float], float],
    x0: float,
    n: int,
    noise: Callable[[], float]
) -> Tuple[List[float], float]:
    """Compute a pseudo-orbit with bounded noise.

    Returns:
        (pseudo_orbit, max_noise): The pseudo-orbit and the maximum noise magnitude.
    """
    orbit: List[float] = [x0]
    x = x0
    max_noise = 0.0
    for _ in range(n):
        e = noise()
        x = f(x) + e
        orbit.append(x)
        max_noise = max(max_noise, abs(e))
    return orbit, max_noise


def build_shadowing_certificate(
    f: Callable[[float], float],
    pseudo: List[float],
    delta: float,
    contraction: float
) -> ShadowingCertificate:
    """Build a shadowing certificate for a contraction map.

    Given a δ-pseudo-orbit of an L-contraction f, constructs the shadow
    (true orbit starting at pseudo[0]) and certifies the bound δ/(1-L).

    Algorithm:
        1. Start shadow at pseudo[0]
        2. Iterate f to get the true orbit
        3. Compute ε = δ/(1-L)
        4. Package into certificate

    Time complexity: O(n)
    """
    n = len(pseudo)
    shadow = compute_true_orbit(f, pseudo[0], n - 1)
    epsilon = delta / (1 - contraction) if contraction < 1 else float('inf')
    return ShadowingCertificate(
        pseudo=pseudo,
        shadow=shadow,
        delta=delta,
        epsilon=epsilon,
        contraction=contraction
    )


def compose_certificates(
    cert1: ShadowingCertificate,
    cert2: ShadowingCertificate
) -> Tuple[float, float]:
    """Compose two shadowing certificates and compute the boundary mismatch.

    Returns:
        (mismatch, bound): The actual mismatch at the boundary and the
        theoretical bound ε₁ + ε₂.
    """
    # Boundary point of cert1's shadow
    s1_end = cert1.shadow[-1]
    # Starting point of cert2's shadow
    s2_start = cert2.shadow[0]
    mismatch = abs(s1_end - s2_start)
    bound = cert1.epsilon + cert2.epsilon
    return mismatch, bound


def shadowing_defect_window(
    shadow: List[float],
    pseudo: List[float],
    start: int,
    end: int
) -> float:
    """Compute the shadowing defect over a window [start, end].

    Algorithm: Linear scan over the window.
    Time complexity: O(end - start)
    """
    return max(abs(shadow[i] - pseudo[i]) for i in range(start, min(end + 1, len(shadow))))


def gradient_descent_step(
    grad_f: Callable[[float], float],
    x: float,
    eta: float
) -> float:
    """One step of gradient descent: x - η·∇f(x)."""
    return x - eta * grad_f(x)


def sgd_pseudo_orbit(
    grad_f: Callable[[float], float],
    x0: float,
    eta: float,
    n: int,
    noise: Callable[[], float]
) -> Tuple[List[float], float]:
    """Compute an SGD trajectory as a pseudo-orbit of exact GD.

    Returns:
        (trajectory, max_noise): The SGD trajectory and maximum noise.
    """
    traj: List[float] = [x0]
    x = x0
    max_noise = 0.0
    for _ in range(n):
        e = noise()
        x = gradient_descent_step(grad_f, x, eta) + e
        traj.append(x)
        max_noise = max(max_noise, abs(e))
    return traj, max_noise


def optimal_pseudo_orbit(L: float, delta: float, n: int) -> List[float]:
    """Construct the optimal pseudo-orbit achieving the tight bound.

    x(k) = δ · Σ_{i<k} L^i = δ(1-L^k)/(1-L)

    This is a δ-pseudo-orbit of f(x) = Lx with the property that
    dist(trueOrbit(0, k), x(k)) → δ/(1-L) as k → ∞.
    """
    orbit: List[float] = []
    partial_sum = 0.0
    power = 1.0
    for k in range(n + 1):
        orbit.append(delta * partial_sum)
        partial_sum += power
        power *= L
    return orbit


def contraction_convergence_rate(
    L: float,
    d0: float,
    delta: float,
    n: int
) -> List[Tuple[int, float]]:
    """Compute the convergence rate L^n·d0 + δ/(1-L) for each step.

    Returns a list of (step, bound) pairs showing exponential decay
    to the noise floor δ/(1-L).
    """
    noise_floor = delta / (1 - L) if L < 1 else float('inf')
    return [(k, L**k * d0 + noise_floor) for k in range(n + 1)]


if __name__ == "__main__":
    import random
    random.seed(42)

    # Example: build and verify a certificate
    L = 0.5
    delta = 0.1
    f = lambda x: L * x

    # Build pseudo-orbit
    pseudo, actual_delta = compute_pseudo_orbit(
        f, 3.0, 100, lambda: random.uniform(-delta, delta)
    )

    # Build certificate
    cert = build_shadowing_certificate(f, pseudo, actual_delta, L)
    print(f"Certificate valid: {cert.verify(f)}")
    print(f"Theoretical ε = {cert.epsilon:.4f}")
    print(f"Actual defect = {cert.defect():.4f}")
    print(f"Bound holds: {cert.defect() <= cert.epsilon + 1e-10}")
