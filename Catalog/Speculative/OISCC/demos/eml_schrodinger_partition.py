#!/usr/bin/env python3
"""
EML Quantum Mechanics and Statistical Mechanics
=================================================
Numerical solutions of the Schrödinger equation with EML potential
and computation of the partition function.

The EML potential f(x) = exp(x) - ln(x) - 1 creates a confining
potential with bound states. The partition function Z(β) = ∫exp(-βf(x))dx
converges for all β > 0.
"""

import numpy as np
from scipy.integrate import quad, solve_bvp
from scipy.linalg import eigh_tridiagonal
from scipy.optimize import minimize_scalar
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def f_potential(x):
    """EML potential f(x) = exp(x) - ln(x) - 1."""
    return np.exp(x) - np.log(x) - 1


def solve_schrodinger(x_min=0.01, x_max=10, n_points=2000, n_states=5):
    """
    Solve the 1D Schrödinger equation -ψ'' + f(x)ψ = Eψ
    using finite differences.
    """
    x = np.linspace(x_min, x_max, n_points)
    dx = x[1] - x[0]

    # Build the Hamiltonian matrix (tridiagonal)
    V = f_potential(x)

    # Kinetic energy: -d²/dx² ≈ [-1, 2, -1]/dx²
    diagonal = 2 / dx**2 + V
    off_diagonal = -np.ones(n_points - 1) / dx**2

    # Solve eigenvalue problem
    energies, wavefunctions = eigh_tridiagonal(diagonal, off_diagonal)

    # Normalize wavefunctions
    for i in range(min(n_states, len(energies))):
        norm = np.sqrt(np.trapezoid(wavefunctions[:, i]**2, x))
        wavefunctions[:, i] /= norm

    return x, energies[:n_states], wavefunctions[:, :n_states]


def partition_function(beta, x_min=0.01, x_max=20):
    """Compute Z(β) = ∫exp(-βf(x))dx."""
    result, _ = quad(lambda x: np.exp(-beta * f_potential(x)), x_min, x_max)
    return result


def free_energy(beta, x_min=0.01, x_max=20):
    """Free energy F(β) = -ln(Z(β))/β."""
    Z = partition_function(beta, x_min, x_max)
    return -np.log(Z) / beta


def specific_heat(beta, x_min=0.01, x_max=20):
    """Specific heat C(β) = β² d²ln(Z)/dβ² (numerical)."""
    dbeta = beta * 0.01
    Z_minus = partition_function(beta - dbeta, x_min, x_max)
    Z_center = partition_function(beta, x_min, x_max)
    Z_plus = partition_function(beta + dbeta, x_min, x_max)
    logZ_minus = np.log(Z_minus)
    logZ_center = np.log(Z_center)
    logZ_plus = np.log(Z_plus)
    d2logZ = (logZ_plus - 2*logZ_center + logZ_minus) / dbeta**2
    return beta**2 * d2logZ


# ============================================================
# Figure 1: Quantum Mechanics of EML
# ============================================================
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Solve Schrödinger equation
x, energies, psi = solve_schrodinger(n_states=6)

# 1a: Potential and energy levels
ax = axes[0, 0]
ax.plot(x, f_potential(x), 'k-', linewidth=2, label='f(x)')
colors = plt.cm.tab10(np.linspace(0, 1, len(energies)))
for i, E in enumerate(energies):
    ax.axhline(y=E, color=colors[i], linestyle='--', alpha=0.7,
              label=f'E_{i} = {E:.3f}')
ax.set_xlabel('x')
ax.set_ylabel('Energy')
ax.set_title('EML Potential with Bound State Energies')
ax.legend(fontsize=7, loc='upper left')
ax.set_ylim(-0.5, max(energies[-1] + 1, 5))
ax.set_xlim(0, 6)
ax.grid(True, alpha=0.3)

# 1b: Wavefunctions
ax = axes[0, 1]
for i in range(min(4, len(energies))):
    offset = energies[i]
    scale = 0.3
    ax.plot(x, offset + scale * psi[:, i]**2, linewidth=1.5,
           label=f'|ψ_{i}|² (E={energies[i]:.2f})')
ax.plot(x, f_potential(x), 'k-', linewidth=1, alpha=0.3, label='f(x)')
ax.set_xlabel('x')
ax.set_ylabel('Probability density + offset')
ax.set_title('Bound State Wavefunctions')
ax.legend(fontsize=7)
ax.set_xlim(0, 5)
ax.grid(True, alpha=0.3)

# 1c: Ground state probability density
ax = axes[1, 0]
ax.fill_between(x, 0, psi[:, 0]**2, alpha=0.4, color='blue',
               label=f'|ψ₀|² (E₀ = {energies[0]:.4f})')
ax.plot(x, psi[:, 0]**2, 'b-', linewidth=2)
# Mark the critical point x₀ = W(1)
res = minimize_scalar(f_potential, bounds=(0.1, 2), method='bounded')
x_min_f = res.x
ax.axvline(x=x_min_f, color='r', linestyle=':', alpha=0.7,
          label=f'x₀ = W(1) ≈ {x_min_f:.3f}')
peak_idx = np.argmax(psi[:, 0]**2)
ax.axvline(x=x[peak_idx], color='g', linestyle='--', alpha=0.7,
          label=f'ψ₀ peak at {x[peak_idx]:.3f}')
ax.set_xlabel('x')
ax.set_ylabel('|ψ₀(x)|²')
ax.set_title('Ground State Concentrated Near x₀ = W(1)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# 1d: Energy level spacing
ax = axes[1, 1]
spacings = np.diff(energies)
ax.bar(range(len(spacings)), spacings, color='steelblue', alpha=0.8)
ax.set_xlabel('Level gap index (E_{n+1} - E_n)')
ax.set_ylabel('Energy spacing')
ax.set_title('Energy Level Spacings')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Speculative/OISCC/demos/fig9_quantum_mechanics.png', dpi=150)
plt.close()
print("Figure 9 saved: fig9_quantum_mechanics.png")


# ============================================================
# Figure 2: Statistical Mechanics
# ============================================================
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# 2a: Partition function Z(β)
ax = axes[0]
betas = np.linspace(0.1, 5, 50)
Zs = [partition_function(b) for b in betas]
ax.semilogy(betas, Zs, 'b-o', linewidth=2, markersize=3)
ax.set_xlabel('β (inverse temperature)')
ax.set_ylabel('Z(β)')
ax.set_title('Partition Function Z(β)')
ax.grid(True, alpha=0.3)

# 2b: Free energy F(β)
ax = axes[1]
Fs = [free_energy(b) for b in betas]
ax.plot(betas, Fs, 'r-o', linewidth=2, markersize=3)
ax.axhline(y=energies[0], color='blue', linestyle='--', alpha=0.7,
          label=f'E₀ = {energies[0]:.3f} (T→0 limit)')
ax.set_xlabel('β (inverse temperature)')
ax.set_ylabel('F(β)')
ax.set_title('Free Energy F(β) = -ln(Z)/β')
ax.legend()
ax.grid(True, alpha=0.3)

# 2c: Specific heat
ax = axes[2]
betas_ch = np.linspace(0.2, 4.5, 40)
Cs = [specific_heat(b) for b in betas_ch]
ax.plot(betas_ch, Cs, 'g-o', linewidth=2, markersize=3)
ax.set_xlabel('β (inverse temperature)')
ax.set_ylabel('C(β)')
ax.set_title('Specific Heat C(β) = β² d²ln(Z)/dβ²')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Speculative/OISCC/demos/fig10_statistical_mechanics.png', dpi=150)
plt.close()
print("Figure 10 saved: fig10_statistical_mechanics.png")


# ============================================================
# Print Summary
# ============================================================
print("\n" + "="*60)
print("QUANTUM/STATISTICAL MECHANICS SUMMARY")
print("="*60)
print(f"\nGround state energy: E₀ = {energies[0]:.6f}")
print(f"First excited state: E₁ = {energies[1]:.6f}")
print(f"Spectral gap: ΔE = E₁ - E₀ = {energies[1] - energies[0]:.6f}")
print(f"Potential minimum: f(x₀) = {f_potential(x_min_f):.6f} at x₀ ≈ {x_min_f:.6f}")
print(f"E₀ > f_min? {energies[0] > f_potential(x_min_f)} (zero-point energy)")
print(f"\nEnergy levels:")
for i, E in enumerate(energies):
    print(f"  E_{i} = {E:.6f}")
print(f"\nPartition function Z(β=1) = {partition_function(1.0):.6f}")
print(f"Free energy F(β=1) = {free_energy(1.0):.6f}")
