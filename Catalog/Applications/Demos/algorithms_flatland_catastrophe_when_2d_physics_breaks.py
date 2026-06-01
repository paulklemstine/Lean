#!/usr/bin/env python3
"""
Algorithms for Flatland Gravity Analysis

Type-hinted implementations of the core computational methods
for analyzing 2D gravitational dynamics.
"""

import math
from typing import Tuple, List, Optional
from dataclasses import dataclass


@dataclass
class GravitySystem:
    """A 2D gravitational system with central mass."""
    G: float  # Gravitational constant
    M: float  # Central mass
    m: float  # Orbiting mass
    L: float  # Angular momentum

    @property
    def k(self) -> float:
        """Gravitational coupling constant."""
        return self.G * self.M * self.m

    def circular_orbit_radius(self) -> float:
        """Radius of the circular orbit: r₀ = |L|/√(mk)."""
        return abs(self.L) / math.sqrt(self.m * self.k)

    def effective_potential(self, r: float) -> float:
        """Effective potential: V_eff(r) = k·ln(r) + L²/(2mr²)."""
        return self.k * math.log(r) + self.L**2 / (2 * self.m * r**2)

    def radial_acceleration(self, r: float) -> float:
        """Radial acceleration: a_r = -k/r + L²/(mr³)."""
        return -self.k / r + self.L**2 / (self.m * r**3)

    def angular_velocity(self, r: float) -> float:
        """Angular velocity: ω = L/(mr²)."""
        return self.L / (self.m * r**2)


def apsidal_angle_ratio(force_exponent: float) -> float:
    """Compute the apsidal angle ratio for a power-law force F ∝ r^α.
    
    Returns 1/√(3+α). For closed orbits, this must be rational.
    
    Args:
        force_exponent: The exponent α in F ∝ r^α
        
    Returns:
        The apsidal angle ratio, or inf if 3+α ≤ 0
    """
    discriminant = 3 + force_exponent
    if discriminant <= 0:
        return float('inf')  # No stable oscillation
    return 1.0 / math.sqrt(discriminant)


def bertrand_parameter(dimension: int) -> int:
    """Compute the Bertrand stability parameter for n-dimensional gravity.
    
    For n-dimensional gravity, the force law is F ∝ r^(1-n),
    so the Bertrand parameter is 3 + (1-n) = 4-n.
    
    Orbits are stable iff 4-n > 0 (i.e., n < 4).
    Orbits close iff √(4-n) is rational.
    """
    return 4 - dimension


def is_goldilocks_dimension(n: int) -> bool:
    """Check if dimension n supports both stable AND closed orbits.
    
    Requires:
    1. stabilityDiscriminant = 4-n > 0  (stable circular orbits)
    2. bertrandParameter = 4-n is a perfect square  (closed orbits)
    
    Only n=3 satisfies both conditions.
    """
    bp = bertrand_parameter(n)
    if bp <= 0:
        return False
    sqrt_bp = math.isqrt(bp)
    return sqrt_bp * sqrt_bp == bp


@dataclass
class OrbitState:
    """State of a particle in radial coordinates."""
    r: float      # Radial distance
    rdot: float   # Radial velocity
    theta: float  # Angle
    t: float      # Time


def integrate_orbit(sys: GravitySystem, initial: OrbitState,
                    dt: float, n_steps: int) -> List[OrbitState]:
    """Integrate the equations of motion for 2D gravity using Störmer-Verlet.
    
    The equations of motion in polar coordinates are:
    - r̈ = -k/r + L²/(mr³)  (radial)
    - θ̇ = L/(mr²)           (angular)
    
    Args:
        sys: The gravitational system
        initial: Initial state
        dt: Time step
        n_steps: Number of integration steps
        
    Returns:
        List of orbit states
    """
    states = [initial]
    r = initial.r
    rdot = initial.rdot
    theta = initial.theta
    t = initial.t

    for _ in range(n_steps):
        # Current acceleration
        a_r = sys.radial_acceleration(r)

        # Position update (Verlet)
        r_new = r + rdot * dt + 0.5 * a_r * dt**2
        r_new = max(r_new, 1e-6)  # Prevent collision

        # New acceleration
        a_r_new = sys.radial_acceleration(r_new)

        # Velocity update
        rdot_new = rdot + 0.5 * (a_r + a_r_new) * dt

        # Angular update
        omega = sys.angular_velocity(r)
        theta_new = theta + omega * dt

        # Time update
        t_new = t + dt

        state = OrbitState(r_new, rdot_new, theta_new, t_new)
        states.append(state)

        r, rdot, theta, t = r_new, rdot_new, theta_new, t_new

    return states


def find_apsides(states: List[OrbitState]) -> List[Tuple[int, float, float]]:
    """Find periapsis and apoapsis points in an orbit.
    
    Returns list of (index, radius, angle) for each apsis.
    """
    apsides = []
    for i in range(1, len(states) - 1):
        r_prev = states[i-1].r
        r_curr = states[i].r
        r_next = states[i+1].r

        if (r_curr <= r_prev and r_curr <= r_next) or \
           (r_curr >= r_prev and r_curr >= r_next):
            apsides.append((i, r_curr, states[i].theta))

    return apsides


def compute_apsidal_angles(apsides: List[Tuple[int, float, float]]) -> List[float]:
    """Compute successive apsidal angles from a list of apsides.
    
    The apsidal angle is the angular difference between successive apsides.
    For 2D gravity, this should be approximately π/√2 ≈ 2.2214.
    """
    angles = []
    for i in range(1, len(apsides)):
        d_theta = apsides[i][2] - apsides[i-1][2]
        angles.append(d_theta)
    return angles


def dimensional_analysis() -> List[dict]:
    """Analyze all dimensions from 1 to 7 for gravitational orbit properties."""
    results = []
    for n in range(1, 8):
        bp = bertrand_parameter(n)
        force_exp = 1 - n
        if bp > 0:
            ratio = apsidal_angle_ratio(float(force_exp))
            stable = True
            # Check if ratio is "close to rational" (approximate test)
            # True rationality is proven in the Lean formalization
            close_to_rational = abs(ratio - round(ratio * 10) / 10) < 0.001
        else:
            ratio = None
            stable = False
            close_to_rational = False

        results.append({
            'dimension': n,
            'force_exponent': force_exp,
            'bertrand_parameter': bp,
            'stable': stable,
            'apsidal_ratio': ratio,
            'goldilocks': is_goldilocks_dimension(n),
        })
    return results


if __name__ == "__main__":
    # Example usage
    sys = GravitySystem(G=1.0, M=1.0, m=1.0, L=1.0)
    r0 = sys.circular_orbit_radius()
    print(f"Circular orbit radius: {r0:.6f}")

    # Integrate orbit starting slightly outside circular orbit
    initial = OrbitState(r=r0 * 1.3, rdot=0.0, theta=0.0, t=0.0)
    states = integrate_orbit(sys, initial, dt=0.005, n_steps=20000)

    # Find apsides
    apsides = find_apsides(states)
    print(f"Found {len(apsides)} apsides")

    if len(apsides) > 2:
        angles = compute_apsidal_angles(apsides)
        mean_angle = sum(angles) / len(angles)
        print(f"Mean apsidal angle: {mean_angle:.6f} (theory: {math.pi/math.sqrt(2):.6f})")

    # Dimensional analysis
    print("\nDimensional Analysis:")
    for r in dimensional_analysis():
        print(f"  dim={r['dimension']}: stable={r['stable']}, "
              f"goldilocks={r['goldilocks']}, ratio={r['apsidal_ratio']}")
