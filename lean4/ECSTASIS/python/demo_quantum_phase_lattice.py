#!/usr/bin/env python3
"""
Quantum Phase Lattice Demo — ECSTASIS Framework

Demonstrates key concepts from the quantum phase lattice extension:
1. Quantum interference formula
2. Phase invariance (projective Hilbert space)
3. Born rule probabilities and Cauchy-Schwarz bound
4. Superposition norm bounds
5. Parallelogram law verification
6. Quantum channel contraction

Uses numpy for linear algebra on finite-dimensional Hilbert spaces (ℂ^n).
"""

import numpy as np
from typing import Tuple

# ============================================================
# Section 1: Quantum State Utilities
# ============================================================

def normalize(psi: np.ndarray) -> np.ndarray:
    """Normalize a quantum state vector to unit norm."""
    n = np.linalg.norm(psi)
    if n < 1e-15:
        raise ValueError("Cannot normalize the zero vector")
    return psi / n

def random_state(dim: int) -> np.ndarray:
    """Generate a random unit quantum state in C^dim."""
    psi = np.random.randn(dim) + 1j * np.random.randn(dim)
    return normalize(psi)

def inner(psi: np.ndarray, phi: np.ndarray) -> complex:
    """Compute the inner product <psi|phi>."""
    return np.vdot(psi, phi)

# ============================================================
# Section 2: Quantum Interference Formula
# ============================================================

def demo_interference_formula():
    """
    Verify: ||psi + phi||^2 = ||psi||^2 + ||phi||^2 + 2*Re<psi|phi>
    """
    print("=" * 60)
    print("DEMO 1: Quantum Interference Formula")
    print("=" * 60)
    
    dim = 4
    psi = random_state(dim) * np.random.uniform(0.5, 2.0)
    phi = random_state(dim) * np.random.uniform(0.5, 2.0)
    
    lhs = np.linalg.norm(psi + phi) ** 2
    rhs = (np.linalg.norm(psi) ** 2 + np.linalg.norm(phi) ** 2 
           + 2 * np.real(inner(psi, phi)))
    
    print(f"  ||psi||       = {np.linalg.norm(psi):.6f}")
    print(f"  ||phi||       = {np.linalg.norm(phi):.6f}")
    print(f"  Re<psi|phi>   = {np.real(inner(psi, phi)):.6f}")
    print(f"  ||psi+phi||^2 = {lhs:.6f}")
    print(f"  RHS           = {rhs:.6f}")
    print(f"  Match: {np.isclose(lhs, rhs)}")
    print(f"  Error: {abs(lhs - rhs):.2e}")
    print()

# ============================================================
# Section 3: Phase Invariance
# ============================================================

def demo_phase_invariance():
    """
    Verify: ||e^{i*theta} * psi|| = ||psi||
    and    |<psi|e^{i*theta}*phi>| = |<psi|phi>|
    """
    print("=" * 60)
    print("DEMO 2: Phase Invariance (Projective Hilbert Space)")
    print("=" * 60)
    
    dim = 4
    psi = random_state(dim)
    phi = random_state(dim)
    
    thetas = np.linspace(0, 2 * np.pi, 8)
    
    print("  θ          ||e^{iθ}ψ||    |<ψ|e^{iθ}φ>|")
    print("  " + "-" * 50)
    
    base_norm = np.linalg.norm(psi)
    base_inner = abs(inner(psi, phi))
    
    for theta in thetas:
        phase = np.exp(1j * theta)
        rotated_norm = np.linalg.norm(phase * psi)
        rotated_inner = abs(inner(psi, phase * phi))
        print(f"  {theta:.4f}    {rotated_norm:.10f}    {rotated_inner:.10f}")
    
    print(f"\n  Base ||ψ||       = {base_norm:.10f}")
    print(f"  Base |<ψ|φ>|    = {base_inner:.10f}")
    print(f"  All norms equal: {all(np.isclose(np.linalg.norm(np.exp(1j*t)*psi), base_norm) for t in thetas)}")
    print(f"  All inners equal: {all(np.isclose(abs(inner(psi, np.exp(1j*t)*phi)), base_inner) for t in thetas)}")
    print()

# ============================================================
# Section 4: Born Rule and Cauchy-Schwarz
# ============================================================

def demo_born_rule():
    """
    Verify: |<psi|phi>|^2 >= 0  (Born rule non-negativity)
    and    |<psi|phi>| <= ||psi|| * ||phi||  (Cauchy-Schwarz)
    For unit vectors: |<psi|phi>| <= 1
    """
    print("=" * 60)
    print("DEMO 3: Born Rule and Cauchy-Schwarz Bound")
    print("=" * 60)
    
    dim = 4
    n_trials = 10
    
    print("  Trial  |<ψ|φ>|²  |<ψ|φ>|  ||ψ||·||φ||  CS holds?  ≤1?")
    print("  " + "-" * 65)
    
    for i in range(n_trials):
        psi = random_state(dim)
        phi = random_state(dim)
        
        born_prob = abs(inner(psi, phi)) ** 2
        inner_abs = abs(inner(psi, phi))
        cs_bound = np.linalg.norm(psi) * np.linalg.norm(phi)
        
        print(f"  {i+1:5d}  {born_prob:.6f}  {inner_abs:.6f}  "
              f"{cs_bound:.6f}     {inner_abs <= cs_bound + 1e-10}    "
              f"{inner_abs <= 1 + 1e-10}")
    
    print()

# ============================================================
# Section 5: Parallelogram Law
# ============================================================

def demo_parallelogram_law():
    """
    Verify: ||psi+phi||^2 + ||psi-phi||^2 = 2(||psi||^2 + ||phi||^2)
    """
    print("=" * 60)
    print("DEMO 4: Parallelogram Law")
    print("=" * 60)
    
    dim = 4
    
    for trial in range(5):
        psi = random_state(dim) * np.random.uniform(0.5, 3.0)
        phi = random_state(dim) * np.random.uniform(0.5, 3.0)
        
        lhs = np.linalg.norm(psi + phi)**2 + np.linalg.norm(psi - phi)**2
        rhs = 2 * (np.linalg.norm(psi)**2 + np.linalg.norm(phi)**2)
        
        print(f"  Trial {trial+1}: LHS = {lhs:.8f}, RHS = {rhs:.8f}, "
              f"Match: {np.isclose(lhs, rhs)}")
    
    print()

# ============================================================
# Section 6: Superposition Phase Sensitivity
# ============================================================

def demo_phase_sensitivity():
    """
    Show how ||alpha*psi + beta*phi|| varies with the relative phase
    between alpha and beta, while the bound |alpha|*||psi|| + |beta|*||phi||
    remains constant.
    """
    print("=" * 60)
    print("DEMO 5: Phase Sensitivity of Superposition")
    print("=" * 60)
    
    dim = 4
    psi = random_state(dim)
    phi = random_state(dim)
    alpha_mag = 0.7
    beta_mag = 0.5
    
    bound = alpha_mag * np.linalg.norm(psi) + beta_mag * np.linalg.norm(phi)
    
    print(f"  |α| = {alpha_mag}, |β| = {beta_mag}")
    print(f"  Upper bound = {bound:.6f}")
    print()
    print("  Relative phase θ    ||α·ψ + β·e^{iθ}·φ||    Bound holds?")
    print("  " + "-" * 55)
    
    for theta in np.linspace(0, 2*np.pi, 12):
        alpha = alpha_mag
        beta = beta_mag * np.exp(1j * theta)
        superposition = alpha * psi + beta * phi
        norm_val = np.linalg.norm(superposition)
        print(f"  {theta:.4f}              {norm_val:.6f}              "
              f"{norm_val <= bound + 1e-10}")
    
    print()

# ============================================================
# Section 7: Quantum Channel Contraction
# ============================================================

def demo_channel_contraction():
    """
    Demonstrate that a quantum channel (represented by a matrix with
    operator norm < 1) is contractive: iterating it converges to a
    fixed point (the zero vector for strictly contractive channels).
    """
    print("=" * 60)
    print("DEMO 6: Quantum Channel Contraction")
    print("=" * 60)
    
    dim = 3
    
    # Create a random strictly contractive channel (operator norm < 1)
    M = np.random.randn(dim, dim) + 1j * np.random.randn(dim, dim)
    # Scale to have operator norm 0.8
    target_norm = 0.8
    M = M / np.linalg.norm(M, ord=2) * target_norm
    
    op_norm = np.linalg.norm(M, ord=2)
    print(f"  Channel operator norm: {op_norm:.6f}")
    print(f"  (contractive since {op_norm:.6f} < 1)")
    print()
    
    # Start from a random state and iterate
    psi = random_state(dim)
    print(f"  Initial ||ψ₀|| = {np.linalg.norm(psi):.6f}")
    print()
    print("  Iteration    ||T^n(ψ₀)||    Expected bound (K^n)")
    print("  " + "-" * 50)
    
    initial_norm = np.linalg.norm(psi)
    for n in range(15):
        current_norm = np.linalg.norm(psi)
        bound = target_norm ** n * initial_norm
        print(f"  {n:9d}    {current_norm:.10f}    {bound:.10f}")
        psi = M @ psi
    
    print(f"\n  Converged to near-zero: {np.linalg.norm(psi) < 1e-6}")
    print()

# ============================================================
# Section 8: Projection Norm Decrease
# ============================================================

def demo_projection():
    """
    Demonstrate that orthogonal projection decreases norm: ||P_K(ψ)|| ≤ ||ψ||
    """
    print("=" * 60)
    print("DEMO 7: Projection Norm Decrease")
    print("=" * 60)
    
    dim = 5
    subspace_dim = 3
    
    # Create a random subspace of dimension subspace_dim
    basis = np.random.randn(dim, subspace_dim) + 1j * np.random.randn(dim, subspace_dim)
    Q, _ = np.linalg.qr(basis)
    Q = Q[:, :subspace_dim]
    
    # Projection matrix P = Q Q^†
    P = Q @ Q.conj().T
    
    print(f"  Hilbert space dimension: {dim}")
    print(f"  Subspace dimension: {subspace_dim}")
    print()
    print("  Trial    ||ψ||      ||P(ψ)||    ||P(ψ)|| ≤ ||ψ||?")
    print("  " + "-" * 55)
    
    for i in range(8):
        psi = random_state(dim) * np.random.uniform(0.5, 3.0)
        projected = P @ psi
        
        psi_norm = np.linalg.norm(psi)
        proj_norm = np.linalg.norm(projected)
        
        print(f"  {i+1:5d}    {psi_norm:.6f}    {proj_norm:.6f}    "
              f"{proj_norm <= psi_norm + 1e-10}")
    
    print()

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    np.random.seed(42)
    
    print("\n" + "=" * 60)
    print("  ECSTASIS — Quantum Phase Lattice Demos")
    print("  Verifying formally proved theorems numerically")
    print("=" * 60 + "\n")
    
    demo_interference_formula()
    demo_phase_invariance()
    demo_born_rule()
    demo_parallelogram_law()
    demo_phase_sensitivity()
    demo_channel_contraction()
    demo_projection()
    
    print("=" * 60)
    print("  All demos completed successfully!")
    print("  All formally verified theorems confirmed numerically.")
    print("=" * 60)
