#!/usr/bin/env python3
"""
Noether's Theorem: Algorithms for Symmetry-to-Conservation-Law Pipeline

This module implements the core computational algorithms for:
1. Computing Noether charges from symmetry generators
2. Verifying conservation along numerically integrated trajectories
3. Symplectic integration for Lagrangian systems

These algorithms mirror the formally verified Lean theorems:
- noether_conservation: J = Σ (∂L/∂vᵢ)ξᵢ is conserved when symmetry holds
- energy_conserved: E = Σ vᵢpᵢ - L is conserved for autonomous systems
- angular_momentum_conserved_of_central_force: L = q×v conserved for central forces
"""

import numpy as np
from typing import Callable, Tuple, List, Optional, Dict


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Noether Charge Computation
# ─────────────────────────────────────────────────────────────────────

def compute_noether_charge(
    dL_dv: Callable[[np.ndarray, np.ndarray], np.ndarray],
    xi: Callable[[np.ndarray], np.ndarray],
    q: np.ndarray,
    v: np.ndarray
) -> float:
    """
    Compute the Noether charge J(q, v) = Σᵢ (∂L/∂vᵢ)(q, v) · ξᵢ(q).
    
    This is the certified algorithm: given a Lagrangian's velocity gradient
    and a symmetry generator, compute the conserved quantity.
    
    Complexity: O(n) where n = dim(q).
    
    Parameters
    ----------
    dL_dv : callable
        Maps (q, v) -> array of ∂L/∂vᵢ (conjugate momenta)
    xi : callable
        Maps q -> array ξ(q) (infinitesimal symmetry generator)
    q : np.ndarray, shape (n,)
        Configuration point
    v : np.ndarray, shape (n,)
        Velocity vector
        
    Returns
    -------
    float
        J(q, v) = Σᵢ pᵢ ξᵢ
    """
    p = dL_dv(q, v)
    xi_val = xi(q)
    return float(np.dot(p, xi_val))


def compute_energy(
    L: Callable[[np.ndarray, np.ndarray], float],
    dL_dv: Callable[[np.ndarray, np.ndarray], np.ndarray],
    q: np.ndarray,
    v: np.ndarray
) -> float:
    """
    Compute the energy E(q,v) = Σᵢ vᵢ (∂L/∂vᵢ) - L(q,v).
    
    For autonomous Lagrangians, this is the Noether charge associated
    to time-translation symmetry.
    
    Complexity: O(n).
    """
    p = dL_dv(q, v)
    return float(np.dot(v, p) - L(q, v))


def compute_angular_momentum(q: np.ndarray, v: np.ndarray) -> np.ndarray:
    """
    Compute classical angular momentum L = q × v for 3D systems.
    
    Components: L₀ = q₁v₂ - q₂v₁, L₁ = q₂v₀ - q₀v₂, L₂ = q₀v₁ - q₁v₀.
    
    This matches the Lean definition ClassicalAngularMomentum.
    
    Complexity: O(1).
    """
    assert len(q) == 3 and len(v) == 3, "Angular momentum requires 3D vectors"
    return np.cross(q, v)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Symmetry Verification
# ─────────────────────────────────────────────────────────────────────

def verify_infinitesimal_symmetry(
    dL_dq: Callable[[np.ndarray, np.ndarray], np.ndarray],
    dL_dv: Callable[[np.ndarray, np.ndarray], np.ndarray],
    xi: Callable[[np.ndarray], np.ndarray],
    D_xi: Callable[[np.ndarray, np.ndarray], np.ndarray],
    q_samples: List[np.ndarray],
    v_samples: List[np.ndarray],
    tol: float = 1e-8
) -> Tuple[bool, float]:
    """
    Verify the infinitesimal symmetry condition:
        Σᵢ (∂L/∂qᵢ) ξᵢ + Σᵢ (∂L/∂vᵢ) (Dξ·v)ᵢ = 0
    at sampled phase space points.
    
    Parameters
    ----------
    dL_dq, dL_dv : partial derivative functions
    xi : symmetry generator
    D_xi : Jacobian action (q, v) -> Dξ(q)·v
    q_samples, v_samples : test points
    tol : tolerance for zero check
    
    Returns
    -------
    (is_symmetric, max_residual)
    """
    max_res = 0.0
    for q, v in zip(q_samples, v_samples):
        term1 = np.dot(dL_dq(q, v), xi(q))
        term2 = np.dot(dL_dv(q, v), D_xi(q, v))
        res = abs(term1 + term2)
        max_res = max(max_res, res)
    
    return max_res < tol, max_res


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: Symplectic Integration (Störmer-Verlet)
# ─────────────────────────────────────────────────────────────────────

def stormer_verlet(
    q0: np.ndarray,
    v0: np.ndarray,
    accel: Callable[[np.ndarray], np.ndarray],
    dt: float,
    n_steps: int
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Symplectic Störmer-Verlet (leapfrog) integrator.
    
    This is a second-order symplectic method that exactly preserves
    the symplectic structure, leading to excellent long-term energy
    conservation (bounded drift, no secular growth).
    
    Complexity: O(n_steps × n) per integration.
    
    Parameters
    ----------
    q0 : initial position, shape (n,)
    v0 : initial velocity, shape (n,)
    accel : q -> acceleration
    dt : time step
    n_steps : number of steps
    
    Returns
    -------
    ts, qs, vs : arrays of shape (n_steps+1,) and (n_steps+1, n)
    """
    n = len(q0)
    qs = np.zeros((n_steps + 1, n))
    vs = np.zeros((n_steps + 1, n))
    ts = np.linspace(0, n_steps * dt, n_steps + 1)
    
    qs[0] = q0.copy()
    vs[0] = v0.copy()
    
    for k in range(n_steps):
        a = accel(qs[k])
        v_half = vs[k] + 0.5 * dt * a
        qs[k+1] = qs[k] + dt * v_half
        a_new = accel(qs[k+1])
        vs[k+1] = v_half + 0.5 * dt * a_new
    
    return ts, qs, vs


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: Conservation Law Verification Pipeline
# ─────────────────────────────────────────────────────────────────────

def verify_conservation(
    observable: Callable[[np.ndarray, np.ndarray], float],
    qs: np.ndarray,
    vs: np.ndarray,
    name: str = "Q"
) -> Dict[str, float]:
    """
    Verify conservation of an observable along a numerical trajectory.
    
    Parameters
    ----------
    observable : (q, v) -> scalar
    qs, vs : trajectory arrays, shape (N, n)
    name : name of the observable
    
    Returns
    -------
    dict with keys: initial_value, max_drift, relative_drift, mean_value, std
    """
    values = np.array([observable(qs[k], vs[k]) for k in range(len(qs))])
    val0 = values[0]
    drift = np.max(np.abs(values - val0))
    rel = drift / (np.abs(val0) + 1e-15)
    
    return {
        "name": name,
        "initial_value": val0,
        "max_drift": drift,
        "relative_drift": rel,
        "mean": np.mean(values),
        "std": np.std(values),
        "values": values
    }


def full_noether_pipeline(
    L: Callable,
    dL_dq: Callable,
    dL_dv: Callable,
    accel: Callable,
    symmetries: Dict[str, Callable],
    q0: np.ndarray,
    v0: np.ndarray,
    dt: float = 0.001,
    n_steps: int = 50000
) -> Dict[str, Dict]:
    """
    Full Noether symmetry-to-conservation pipeline.
    
    1. Integrate the trajectory
    2. For each symmetry generator, compute the Noether charge
    3. Also compute energy
    4. Verify conservation of all quantities
    
    Parameters
    ----------
    L : Lagrangian function (q, v) -> scalar
    dL_dq : partial derivatives w.r.t. q
    dL_dv : partial derivatives w.r.t. v (conjugate momenta)
    accel : acceleration function q -> a
    symmetries : dict mapping name -> symmetry generator ξ(q)
    q0, v0 : initial conditions
    dt : time step
    n_steps : number of integration steps
    
    Returns
    -------
    dict of conservation results
    """
    # Integrate
    ts, qs, vs = stormer_verlet(q0, v0, accel, dt, n_steps)
    
    results = {}
    
    # Energy conservation
    E_fn = lambda q, v: compute_energy(L, dL_dv, q, v)
    results["energy"] = verify_conservation(E_fn, qs, vs, "Energy")
    
    # Noether charges for each symmetry
    for name, xi in symmetries.items():
        J_fn = lambda q, v, xi=xi: compute_noether_charge(dL_dv, xi, q, v)
        results[name] = verify_conservation(J_fn, qs, vs, f"J_{name}")
    
    return results


# ─────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Noether Charge Algorithm — Example Usage")
    print("=" * 50)
    
    # Kepler problem
    m, mu = 1.0, 1.0
    L = lambda q, v: 0.5 * m * np.dot(v, v) + mu / np.linalg.norm(q)
    dL_dq = lambda q, v: -mu * q / np.linalg.norm(q)**3
    dL_dv = lambda q, v: m * v
    accel = lambda q: -(mu / (m * np.linalg.norm(q)**3)) * q
    
    symmetries = {
        "p_x": lambda q: np.array([1, 0, 0]),
        "p_y": lambda q: np.array([0, 1, 0]),
        "p_z": lambda q: np.array([0, 0, 1]),
        "L_z": lambda q: np.array([-q[1], q[0], 0]),
    }
    
    q0 = np.array([1.0, 0.0, 0.0])
    v0 = np.array([0.0, 0.9, 0.1])
    
    results = full_noether_pipeline(L, dL_dq, dL_dv, accel, symmetries, q0, v0)
    
    for name, r in results.items():
        print(f"\n{r['name']}:")
        print(f"  Initial: {r['initial_value']:.8f}")
        print(f"  Max drift: {r['max_drift']:.2e}")
        print(f"  Relative: {r['relative_drift']:.2e}")
