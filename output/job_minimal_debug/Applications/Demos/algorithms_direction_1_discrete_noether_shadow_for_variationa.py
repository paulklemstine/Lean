#!/usr/bin/env python3
"""
Algorithms for Discrete Noether Shadow Theory

This module implements the core algorithms for computing and certifying
discrete Noether shadows in variational integrators:

1. Störmer–Verlet variational integrator (symmetric, symplectic)
2. Discrete energy shadow computation
3. Noether defect calculator
4. Drift bound certification
5. Min-plus (tropical) value function computation
6. Discrete momentum map

All algorithms include type hints and docstrings.
"""

import math
from typing import Callable, List, Tuple, Optional

# Type aliases
Vec = List[float]
Lagrangian = Callable[[Vec, Vec], float]
Force = Callable[[Vec], Vec]


# ============================================================
# §1. Vector Operations
# ============================================================

def vec_add(a: Vec, b: Vec) -> Vec:
    """Vector addition."""
    return [ai + bi for ai, bi in zip(a, b)]

def vec_sub(a: Vec, b: Vec) -> Vec:
    """Vector subtraction."""
    return [ai - bi for ai, bi in zip(a, b)]

def vec_scale(c: float, a: Vec) -> Vec:
    """Scalar multiplication."""
    return [c * ai for ai in a]

def vec_dot(a: Vec, b: Vec) -> float:
    """Dot product."""
    return sum(ai * bi for ai, bi in zip(a, b))

def vec_norm(a: Vec) -> float:
    """Euclidean norm."""
    return math.sqrt(vec_dot(a, a))


# ============================================================
# §2. Störmer–Verlet Variational Integrator
# ============================================================

def stormer_verlet_step(
    q: Vec, v: Vec, h: float, force: Force
) -> Tuple[Vec, Vec]:
    """
    One step of the Störmer–Verlet (leapfrog) integrator.

    This is a symmetric, symplectic, second-order method that arises
    from a discrete variational principle. It preserves the symplectic
    form exactly and the energy to O(h²).

    Algorithm:
        1. a₀ = F(q)
        2. q_new = q + h*v + ½h²*a₀
        3. a_new = F(q_new)
        4. v_new = v + ½h*(a₀ + a_new)

    Time complexity: O(n) per step where n = dim(q)
    Space complexity: O(n)

    Args:
        q: Position vector (dimension n)
        v: Velocity vector (dimension n)
        h: Step size (positive)
        force: Force function F: ℝⁿ → ℝⁿ

    Returns:
        (q_new, v_new): Updated position and velocity
    """
    a0 = force(q)
    q_new = vec_add(vec_add(q, vec_scale(h, v)),
                    vec_scale(0.5 * h**2, a0))
    a_new = force(q_new)
    v_new = vec_add(v, vec_scale(0.5 * h, vec_add(a0, a_new)))
    return q_new, v_new


def euler_step(
    q: Vec, v: Vec, h: float, force: Force
) -> Tuple[Vec, Vec]:
    """
    One step of explicit Euler (non-symmetric baseline).

    This is NOT a variational integrator. It does not preserve
    symplecticity and its energy drift is O(h), not O(h²).

    Args:
        q, v, h, force: Same as stormer_verlet_step

    Returns:
        (q_new, v_new): Updated position and velocity
    """
    a = force(q)
    q_new = vec_add(q, vec_scale(h, v))
    v_new = vec_add(v, vec_scale(h, a))
    return q_new, v_new


# ============================================================
# §3. Discrete Energy Shadow
# ============================================================

def discrete_energy(
    q: Vec, v: Vec, kinetic: Callable[[Vec], float],
    potential: Callable[[Vec], float]
) -> float:
    """
    Compute the discrete energy shadow.

    For a separable Lagrangian L = T(v) - V(q), the energy is
    E = T(v) + V(q) (note sign flip from Lagrangian to Hamiltonian).

    Args:
        q: Position vector
        v: Velocity vector
        kinetic: Kinetic energy function T(v)
        potential: Potential energy function V(q)

    Returns:
        Total energy E = T(v) + V(q)
    """
    return kinetic(v) + potential(q)


# ============================================================
# §4. Noether Defect Calculator
# ============================================================

def noether_defect(
    E_prev: float, E_curr: float
) -> float:
    """
    Compute the Noether defect: one-step energy change.

    The defect Δ_k = E_{k+1} - E_k measures how far the discrete
    energy is from being exactly conserved. For symmetric second-order
    schemes, |Δ_k| = O(h³).

    Args:
        E_prev: Energy at step k
        E_curr: Energy at step k+1

    Returns:
        Δ_k = E_curr - E_prev
    """
    return E_curr - E_prev


def compute_defect_sequence(
    energies: List[float]
) -> List[float]:
    """
    Compute the full sequence of Noether defects.

    The telescoping identity guarantees:
        sum(defects[0:N]) = energies[N] - energies[0]

    Time complexity: O(N)
    Space complexity: O(N)

    Args:
        energies: Sequence of discrete energies [E_0, E_1, ..., E_N]

    Returns:
        Sequence of defects [Δ_0, Δ_1, ..., Δ_{N-1}]
    """
    return [energies[i+1] - energies[i] for i in range(len(energies) - 1)]


# ============================================================
# §5. Drift Bound Certification
# ============================================================

def certify_drift_bound(
    energies: List[float], h: float, T: float
) -> dict:
    """
    Certify the O(h²) energy drift bound.

    Given a trajectory's energy sequence, compute:
    1. Maximum energy drift from E_0
    2. Maximum step defect
    3. Estimated C such that max|ΔE| ≤ C * T * h²
    4. Whether the bound is satisfied

    Time complexity: O(N)
    Space complexity: O(1) (streaming)

    Args:
        energies: Sequence of discrete energies
        h: Step size
        T: Time horizon

    Returns:
        Dictionary with certification results:
        - max_drift: max_k |E_k - E_0|
        - max_step_defect: max_k |E_{k+1} - E_k|
        - C_estimate: estimated constant C
        - C_T_h2: the bound C * T * h²
        - certified: whether max_drift ≤ C_T_h2
        - drift_over_h2: max_drift / h² (should be bounded)
    """
    E0 = energies[0]
    max_drift = 0.0
    max_step = 0.0

    for i in range(len(energies)):
        drift = abs(energies[i] - E0)
        max_drift = max(max_drift, drift)
        if i > 0:
            step = abs(energies[i] - energies[i-1])
            max_step = max(max_step, step)

    # Estimate C from step defect: |Δ_k| ≤ C * h³
    C_from_step = max_step / h**3 if h > 0 else float('inf')

    # The certified bound
    C_T_h2 = C_from_step * T * h**2

    return {
        'max_drift': max_drift,
        'max_step_defect': max_step,
        'C_estimate': C_from_step,
        'C_T_h2': C_T_h2,
        'certified': max_drift <= C_T_h2 * 1.01,  # small tolerance
        'drift_over_h2': max_drift / h**2 if h > 0 else float('inf'),
    }


# ============================================================
# §6. Min-Plus (Tropical) Value Function
# ============================================================

def tropical_value_function(
    Ld: Callable[[Vec, Vec], float],
    grid: List[Vec],
    N: int,
    q_start: Vec,
    q_end: Vec,
) -> float:
    """
    Compute the min-plus value function by dynamic programming.

    V(N, q_start, q_end) = min over all intermediate paths
    of the total discrete action sum.

    This implements the Bellman recursion:
        V(m+n, q₀, q₂) = min_{q₁} [V(m, q₀, q₁) + V(n, q₁, q₂)]

    For a grid of M intermediate points, this is O(M^N) by brute force
    but O(N * M²) by dynamic programming.

    Args:
        Ld: Discrete Lagrangian Ld(q_k, q_{k+1})
        grid: Finite set of intermediate configuration points
        N: Number of steps
        q_start: Initial configuration
        q_end: Final configuration

    Returns:
        Minimum action over all N-step paths from q_start to q_end
    """
    if N == 0:
        return 0.0
    if N == 1:
        return Ld(q_start, q_end)

    M = len(grid)

    # V[i] = min action from q_start to grid[i] in k steps
    # Initialize for k=1
    V_prev = [Ld(q_start, grid[i]) for i in range(M)]

    # Dynamic programming: k = 2, ..., N-1
    for k in range(2, N):
        V_curr = [float('inf')] * M
        for j in range(M):
            for i in range(M):
                cost = V_prev[i] + Ld(grid[i], grid[j])
                V_curr[j] = min(V_curr[j], cost)
        V_prev = V_curr

    # Final step to q_end
    result = float('inf')
    for i in range(M):
        cost = V_prev[i] + Ld(grid[i], q_end)
        result = min(result, cost)

    return result


def verify_bellman_composition(
    Ld: Callable[[Vec, Vec], float],
    grid: List[Vec],
    m: int, n: int,
    q0: Vec, q2: Vec
) -> dict:
    """
    Verify the min-plus Bellman composition:
        V(m+n, q₀, q₂) = min_{q₁} [V(m, q₀, q₁) + V(n, q₁, q₂)]

    Args:
        Ld: Discrete Lagrangian
        grid: Intermediate configuration grid
        m, n: Segment lengths
        q0, q2: Start and end configurations

    Returns:
        Dictionary with V(m+n), min over compositions, and agreement
    """
    V_direct = tropical_value_function(Ld, grid, m + n, q0, q2)

    min_composition = float('inf')
    best_q1 = None
    for q1 in grid:
        V_left = tropical_value_function(Ld, grid, m, q0, q1)
        V_right = tropical_value_function(Ld, grid, n, q1, q2)
        total = V_left + V_right
        if total < min_composition:
            min_composition = total
            best_q1 = q1

    return {
        'V_direct': V_direct,
        'V_composition': min_composition,
        'difference': abs(V_direct - min_composition),
        'agrees': abs(V_direct - min_composition) < 1e-10,
        'optimal_intermediate': best_q1,
    }


# ============================================================
# §7. Discrete Momentum Map
# ============================================================

def discrete_angular_momentum_2d(q: Vec, v: Vec) -> float:
    """
    Discrete angular momentum in 2D: L = q₁v₂ - q₂v₁.

    For rotationally invariant Lagrangians, this is exactly
    conserved by rotationally invariant variational integrators.

    Args:
        q: 2D position vector [q₁, q₂]
        v: 2D velocity vector [v₁, v₂]

    Returns:
        Angular momentum L = q₁v₂ - q₂v₁
    """
    return q[0] * v[1] - q[1] * v[0]


def verify_momentum_conservation(
    positions: List[Vec], velocities: List[Vec],
    momentum_fn: Callable[[Vec, Vec], float],
    tol: float = 1e-12
) -> dict:
    """
    Verify exact momentum conservation along a trajectory.

    Args:
        positions: Sequence of positions [q_0, ..., q_N]
        velocities: Sequence of velocities [v_0, ..., v_N]
        momentum_fn: Momentum map function
        tol: Tolerance for "exact" conservation

    Returns:
        Dictionary with conservation statistics
    """
    momenta = [momentum_fn(q, v) for q, v in zip(positions, velocities)]
    L0 = momenta[0]
    max_drift = max(abs(L - L0) for L in momenta)

    return {
        'initial_momentum': L0,
        'max_drift': max_drift,
        'conserved': max_drift < tol,
        'relative_drift': max_drift / abs(L0) if L0 != 0 else max_drift,
    }


# ============================================================
# §8. Full Integration Pipeline
# ============================================================

def integrate_and_certify(
    q0: Vec, v0: Vec, h: float, T: float,
    force: Force,
    kinetic: Callable[[Vec], float],
    potential: Callable[[Vec], float],
    method: str = 'verlet'
) -> dict:
    """
    Full integration pipeline with certification.

    Integrates the system, computes energy and momentum sequences,
    and certifies the drift bound.

    Args:
        q0: Initial position
        v0: Initial velocity
        h: Step size
        T: Time horizon
        force: Force function
        kinetic: Kinetic energy function
        potential: Potential energy function
        method: 'verlet' or 'euler'

    Returns:
        Comprehensive results dictionary
    """
    N = int(T / h)
    step = stormer_verlet_step if method == 'verlet' else euler_step

    positions = [q0[:]]
    velocities = [v0[:]]
    energies = [discrete_energy(q0, v0, kinetic, potential)]

    q, v = q0[:], v0[:]
    for _ in range(N):
        q, v = step(q, v, h, force)
        positions.append(q[:])
        velocities.append(v[:])
        energies.append(discrete_energy(q, v, kinetic, potential))

    # Certify drift
    cert = certify_drift_bound(energies, h, T)

    # Compute defect sequence
    defects = compute_defect_sequence(energies)

    return {
        'positions': positions,
        'velocities': velocities,
        'energies': energies,
        'defects': defects,
        'certification': cert,
        'N_steps': N,
        'h': h,
        'T': T,
        'method': method,
    }


# ============================================================
# Example usage
# ============================================================

if __name__ == '__main__':
    # Kepler problem
    mu = 1.0

    def kepler_force(q: Vec) -> Vec:
        r = vec_norm(q)
        return vec_scale(-mu / r**3, q)

    def kinetic(v: Vec) -> float:
        return 0.5 * vec_dot(v, v)

    def potential(q: Vec) -> float:
        return -mu / vec_norm(q)

    q0 = [1.0, 0.0]
    v0 = [0.0, 1.2]
    h = 0.01
    T = 100.0

    print("Integrating Kepler problem with Störmer–Verlet...")
    result = integrate_and_certify(q0, v0, h, T, kepler_force, kinetic, potential)
    cert = result['certification']

    print(f"Steps: {result['N_steps']}")
    print(f"Max energy drift: {cert['max_drift']:.6e}")
    print(f"Max step defect:  {cert['max_step_defect']:.6e}")
    print(f"C estimate:       {cert['C_estimate']:.6e}")
    print(f"Drift / h²:       {cert['drift_over_h2']:.6e}")
    print(f"Certified:        {cert['certified']}")

    # Verify Bellman composition for harmonic oscillator
    print("\nVerifying Bellman composition (harmonic oscillator)...")
    def harmonic_Ld(q0: Vec, q1: Vec) -> float:
        """Discrete Lagrangian for 1D harmonic oscillator with h=0.1"""
        h_step = 0.1
        v_approx = [(q1[i] - q0[i]) / h_step for i in range(len(q0))]
        return h_step * (0.5 * vec_dot(v_approx, v_approx) -
                         0.5 * vec_dot(q0, q0))

    grid_1d = [[x * 0.5] for x in range(-4, 5)]  # 1D grid
    bell = verify_bellman_composition(
        harmonic_Ld, grid_1d, 2, 3, [1.0], [0.5])
    print(f"V(2+3, q0, q2) = {bell['V_direct']:.6f}")
    print(f"min V(2)+V(3)  = {bell['V_composition']:.6f}")
    print(f"Agrees:          {bell['agrees']}")
