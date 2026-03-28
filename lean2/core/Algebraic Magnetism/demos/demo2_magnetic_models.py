#!/usr/bin/env python3
"""
Demo 2: Magnetic Models as Algebraic Quotients
===============================================

This script demonstrates the central theorem of the Algebraic Theory of Magnetism:
all standard magnetic models (Ising, XY, Heisenberg, Kitaev) arise as quotients
or projections of the universal magnetic algebra.

We visualize:
1. The exchange tensor decomposition
2. Energy spectra of different models on small clusters
3. How varying algebraic parameters interpolates between models
4. The algebraic phase diagram

Author: The Oracle Council
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import matplotlib.gridspec as gridspec
from itertools import product
from demo1_spin_algebra import spin_operators

# ============================================================================
# Part 1: Building Magnetic Hamiltonians from the Exchange Tensor
# ============================================================================

def exchange_tensor(J_iso=0, J_xy=0, J_z=0, D_vec=None, J_aniso=None):
    """
    Construct the 3×3 exchange tensor Jᵅᵝ.
    
    The exchange tensor decomposes as:
        J = J_iso · I₃ + J_DM · ε + J_sym
    
    Parameters
    ----------
    J_iso : float - Isotropic Heisenberg coupling
    J_xy : float - XY plane coupling (adds to Jxx, Jyy)
    J_z : float - Ising coupling (adds to Jzz)
    D_vec : array-like - Dzyaloshinskii-Moriya vector
    J_aniso : ndarray - Additional symmetric anisotropic exchange
    """
    J = np.zeros((3, 3))
    
    # Isotropic part
    J += J_iso * np.eye(3)
    
    # XY part
    J[0, 0] += J_xy
    J[1, 1] += J_xy
    
    # Ising part  
    J[2, 2] += J_z
    
    # DM interaction (antisymmetric)
    if D_vec is not None:
        D = np.array(D_vec)
        J[0, 1] += D[2]
        J[1, 0] -= D[2]
        J[0, 2] -= D[1]
        J[2, 0] += D[1]
        J[1, 2] += D[0]
        J[2, 1] -= D[0]
    
    # Symmetric anisotropic
    if J_aniso is not None:
        J += J_aniso
    
    return J


def build_two_site_hamiltonian(s, J_tensor, h_field=None):
    """
    Build the Hamiltonian for two coupled spins.
    
    H = Σ_{αβ} J^{αβ} S₁^α S₂^β + h · (S₁ + S₂)
    
    This lives in the universal enveloping algebra U(𝔰𝔲(2) ⊗ 𝔰𝔲(2)).
    """
    dim = int(2*s + 1)
    Sx, Sy, Sz = spin_operators(s)
    S = [Sx, Sy, Sz]
    I = np.eye(dim)
    
    dim2 = dim * dim
    H = np.zeros((dim2, dim2), dtype=complex)
    
    # Exchange interaction
    for a in range(3):
        for b in range(3):
            if abs(J_tensor[a, b]) > 1e-15:
                H += J_tensor[a, b] * np.kron(S[a], S[b])
    
    # Zeeman term
    if h_field is not None:
        h = np.array(h_field)
        for a in range(3):
            if abs(h[a]) > 1e-15:
                H += h[a] * (np.kron(S[a], I) + np.kron(I, S[a]))
    
    return H


def build_chain_hamiltonian(N, s, J_tensor, periodic=True):
    """
    Build the Hamiltonian for an N-site spin chain.
    
    H = Σᵢ Σ_{αβ} J^{αβ} Sᵢ^α S_{i+1}^β
    """
    dim1 = int(2*s + 1)
    dim_total = dim1**N
    Sx, Sy, Sz = spin_operators(s)
    S = [Sx, Sy, Sz]
    
    H = np.zeros((dim_total, dim_total), dtype=complex)
    
    n_bonds = N if periodic else N - 1
    
    for i in range(n_bonds):
        j = (i + 1) % N
        for a in range(3):
            for b in range(3):
                if abs(J_tensor[a, b]) > 1e-15:
                    # Build Sᵢ^α ⊗ S_{i+1}^β in the full Hilbert space
                    op = np.eye(1)
                    for k in range(N):
                        if k == i:
                            op = np.kron(op, S[a])
                        elif k == j:
                            op = np.kron(op, S[b])
                        else:
                            op = np.kron(op, np.eye(dim1))
                    H += J_tensor[a, b] * op
    
    return H


# ============================================================================
# Part 2: Visualization
# ============================================================================

def plot_exchange_tensor_decomposition():
    """Visualize how the exchange tensor classifies magnetic models."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Exchange Tensor Decomposition — Classification of Magnetic Models',
                 fontsize=15, fontweight='bold')
    
    models = [
        ('Ising', exchange_tensor(J_z=1.0), 'ℤ₂ symmetry'),
        ('XY', exchange_tensor(J_xy=1.0), 'U(1) symmetry'),
        ('Heisenberg', exchange_tensor(J_iso=1.0), 'SU(2) symmetry'),
        ('XXZ', exchange_tensor(J_xy=1.0, J_z=0.5), 'U(1) ⊂ SU(2)'),
        ('DM Interaction', exchange_tensor(J_iso=1.0, D_vec=[0, 0, 0.3]), 'Broken inversion'),
        ('Compass', exchange_tensor(J_aniso=np.diag([1, 0, 0])), 'Bond-dependent'),
    ]
    
    for ax, (name, J, sym) in zip(axes.flat, models):
        im = ax.imshow(J, cmap='RdBu_r', vmin=-1.5, vmax=1.5, aspect='equal')
        ax.set_title(f'{name}\n({sym})', fontsize=11, fontweight='bold')
        ax.set_xticks([0, 1, 2])
        ax.set_yticks([0, 1, 2])
        ax.set_xticklabels(['x', 'y', 'z'])
        ax.set_yticklabels(['x', 'y', 'z'])
        
        # Annotate values
        for i in range(3):
            for j in range(3):
                val = J[i, j]
                if abs(val) > 1e-10:
                    ax.text(j, i, f'{val:.1f}', ha='center', va='center',
                           fontsize=12, fontweight='bold',
                           color='white' if abs(val) > 0.8 else 'black')
        
        plt.colorbar(im, ax=ax, shrink=0.8)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/exchange_tensors.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved exchange_tensors.png")


def plot_two_site_spectra():
    """
    Compare energy spectra of two coupled s=1/2 spins for different models.
    
    This demonstrates how different algebraic quotients produce different
    spectral structures.
    """
    fig, axes = plt.subplots(1, 4, figsize=(16, 5))
    fig.suptitle('Two-Spin Energy Spectra — Algebraic Quotients of 𝔰𝔲(2)⊗𝔰𝔲(2)',
                 fontsize=14, fontweight='bold')
    
    s = 0.5
    models = [
        ('Ising\nH = Jz·Sz₁Sz₂', exchange_tensor(J_z=-1.0)),
        ('XY\nH = Jxy·(Sx₁Sx₂+Sy₁Sy₂)', exchange_tensor(J_xy=-1.0)),
        ('Heisenberg\nH = J·S₁·S₂', exchange_tensor(J_iso=-1.0)),
        ('DM + Heisenberg\nH = J·S₁·S₂ + D·(S₁×S₂)', 
         exchange_tensor(J_iso=-1.0, D_vec=[0, 0, 0.5])),
    ]
    
    for ax, (name, J) in zip(axes, models):
        H = build_two_site_hamiltonian(s, J)
        eigenvalues = np.linalg.eigvalsh(H.real)
        
        # Group degenerate eigenvalues
        unique_E = []
        degeneracies = []
        for E in eigenvalues:
            found = False
            for i, uE in enumerate(unique_E):
                if abs(E - uE) < 1e-10:
                    degeneracies[i] += 1
                    found = True
                    break
            if not found:
                unique_E.append(E)
                degeneracies.append(1)
        
        # Plot energy levels
        for i, (E, deg) in enumerate(zip(unique_E, degeneracies)):
            width = 0.3 * deg
            ax.plot([-width, width], [E, E], 'b-', linewidth=3)
            ax.text(width + 0.05, E, f'deg={deg}', fontsize=10, va='center')
        
        ax.set_title(name, fontsize=10)
        ax.set_ylabel('Energy' if ax == axes[0] else '')
        ax.set_xlim(-0.8, 0.8)
        ax.set_xticks([])
        ax.grid(True, axis='y', alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/two_site_spectra.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved two_site_spectra.png")


def plot_algebraic_phase_diagram():
    """
    Plot the phase diagram in algebraic parameter space.
    
    Varying the exchange tensor components traces out the space of 
    magnetic models. Phase boundaries occur where the ground state
    representation changes.
    """
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Algebraic Phase Diagram — Ground State Representations',
                 fontsize=14, fontweight='bold')
    
    # Phase diagram 1: XXZ model (Jxy vs Jz)
    N_points = 80
    Jxy_range = np.linspace(-2, 2, N_points)
    Jz_range = np.linspace(-2, 2, N_points)
    
    ground_state_spin = np.zeros((N_points, N_points))
    
    s = 0.5
    for i, Jz in enumerate(Jz_range):
        for j, Jxy in enumerate(Jxy_range):
            J = exchange_tensor(J_xy=Jxy, J_z=Jz)
            H = build_two_site_hamiltonian(s, J)
            eigenvalues, eigenvectors = np.linalg.eigh(H.real)
            
            # Compute total spin of ground state
            Sx, Sy, Sz = spin_operators(s)
            I = np.eye(2)
            S_total_z = np.kron(Sz, I) + np.kron(I, Sz)
            S2_total = sum(
                (np.kron(Si, I) + np.kron(I, Si)) @ (np.kron(Si, I) + np.kron(I, Si))
                for Si in [Sx, Sy, Sz]
            )
            
            gs = eigenvectors[:, 0]
            s_total = np.real(gs.conj() @ S2_total @ gs)
            ground_state_spin[i, j] = s_total
    
    im1 = ax1.pcolormesh(Jxy_range, Jz_range, ground_state_spin, 
                          cmap='viridis', shading='auto')
    ax1.set_xlabel('J_xy (XY coupling)', fontsize=12)
    ax1.set_ylabel('J_z (Ising coupling)', fontsize=12)
    ax1.set_title('⟨S²_total⟩ of Ground State\n(XXZ Model, 2 sites)', fontsize=12)
    
    # Mark special models
    ax1.plot(0, 1, 'w*', markersize=15, label='Ising')
    ax1.plot(1, 0, 'r*', markersize=15, label='XY')
    ax1.plot(1, 1, 'y*', markersize=15, label='Heisenberg')
    ax1.legend(fontsize=10, loc='upper left')
    
    plt.colorbar(im1, ax=ax1, label='⟨S²_total⟩')
    
    # Phase diagram 2: Heisenberg + DM (J vs D)
    J_range = np.linspace(-2, 2, N_points)
    D_range = np.linspace(0, 2, N_points)
    
    gap = np.zeros((N_points, N_points))
    
    for i, D in enumerate(D_range):
        for j, J in enumerate(J_range):
            Jt = exchange_tensor(J_iso=J, D_vec=[0, 0, D])
            H = build_two_site_hamiltonian(s, Jt)
            eigenvalues = np.sort(np.linalg.eigvalsh(H.real))
            gap[i, j] = eigenvalues[1] - eigenvalues[0]
    
    im2 = ax2.pcolormesh(J_range, D_range, gap, cmap='magma', shading='auto')
    ax2.set_xlabel('J (Heisenberg coupling)', fontsize=12)
    ax2.set_ylabel('|D| (DM interaction)', fontsize=12)
    ax2.set_title('Energy Gap Δ = E₁ - E₀\n(Heisenberg + DM, 2 sites)', fontsize=12)
    plt.colorbar(im2, ax=ax2, label='Gap Δ')
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/algebraic_phase_diagram.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved algebraic_phase_diagram.png")


def plot_model_interpolation():
    """
    Animate (static frames) the interpolation between magnetic models
    by continuously varying the exchange tensor.
    """
    fig, axes = plt.subplots(2, 4, figsize=(16, 8))
    fig.suptitle('Interpolating Between Magnetic Models via Exchange Tensor',
                 fontsize=14, fontweight='bold')
    
    s = 0.5
    
    # Top row: Ising → Heisenberg interpolation
    alphas = np.linspace(0, 1, 4)
    for ax, alpha in zip(axes[0], alphas):
        J = exchange_tensor(J_xy=alpha, J_z=1.0)
        H = build_two_site_hamiltonian(s, J)
        eigenvalues = np.sort(np.linalg.eigvalsh(H.real))
        
        colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
        for i, E in enumerate(eigenvalues):
            ax.barh(i, E, color=colors[i], alpha=0.8, height=0.6)
            ax.text(E + 0.05 * np.sign(E), i, f'{E:.3f}', va='center', fontsize=9)
        
        ax.set_title(f'α = {alpha:.2f}\nIsing{"→Heis." if alpha > 0 else ""}', fontsize=10)
        ax.set_yticks(range(4))
        ax.set_yticklabels([f'E_{i}' for i in range(4)])
        ax.set_xlim(-1.5, 1.5)
        ax.axvline(x=0, color='gray', linestyle='--', alpha=0.3)
    
    # Bottom row: Heisenberg + increasing DM
    D_values = [0, 0.3, 0.7, 1.5]
    for ax, D in zip(axes[1], D_values):
        J = exchange_tensor(J_iso=1.0, D_vec=[0, 0, D])
        H = build_two_site_hamiltonian(s, J)
        eigenvalues = np.sort(np.linalg.eigvalsh(H.real))
        
        colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
        for i, E in enumerate(eigenvalues):
            ax.barh(i, E, color=colors[i], alpha=0.8, height=0.6)
            ax.text(E + 0.05 * np.sign(E), i, f'{E:.3f}', va='center', fontsize=9)
        
        ax.set_title(f'D = {D:.1f}\nHeis.+DM', fontsize=10)
        ax.set_yticks(range(4))
        ax.set_yticklabels([f'E_{i}' for i in range(4)])
        ax.set_xlim(-2, 2)
        ax.axvline(x=0, color='gray', linestyle='--', alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/model_interpolation.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved model_interpolation.png")


# ============================================================================
# Main
# ============================================================================

if __name__ == '__main__':
    print("=" * 70)
    print("ALGEBRAIC THEORY OF MAGNETISM — Demo 2: Magnetic Models")
    print("=" * 70)
    
    # Exchange tensor examples
    print("\n--- Exchange Tensor Decomposition ---")
    models = {
        'Ising': exchange_tensor(J_z=1.0),
        'XY': exchange_tensor(J_xy=1.0),
        'Heisenberg': exchange_tensor(J_iso=1.0),
        'XXZ (Δ=0.5)': exchange_tensor(J_xy=1.0, J_z=0.5),
        'Heisenberg+DM': exchange_tensor(J_iso=1.0, D_vec=[0, 0, 0.3]),
    }
    
    for name, J in models.items():
        # Decompose into symmetric + antisymmetric
        J_sym = 0.5 * (J + J.T)
        J_anti = 0.5 * (J - J.T)
        trace = np.trace(J_sym) / 3
        J_traceless = J_sym - trace * np.eye(3)
        
        print(f"\n  {name}:")
        print(f"    Isotropic part:     {trace:.3f}")
        print(f"    DM vector:          [{J_anti[1,2]:.3f}, {J_anti[2,0]:.3f}, {J_anti[0,1]:.3f}]")
        print(f"    Anisotropy norm:    {np.linalg.norm(J_traceless):.3f}")
    
    # Two-site spectra
    print("\n--- Two-Site Spectra (s=1/2) ---")
    s = 0.5
    for name, J in models.items():
        H = build_two_site_hamiltonian(s, J)
        eigenvalues = np.sort(np.linalg.eigvalsh(H.real))
        print(f"  {name}: E = {eigenvalues}")
    
    # Generate figures
    print("\n--- Generating Figures ---")
    plot_exchange_tensor_decomposition()
    plot_two_site_spectra()
    plot_algebraic_phase_diagram()
    plot_model_interpolation()
    
    print("\n✓ Demo 2 complete!")
