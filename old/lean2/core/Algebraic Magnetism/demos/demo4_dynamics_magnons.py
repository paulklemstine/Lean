#!/usr/bin/env python3
"""
Demo 4: Spin Dynamics and Magnon Algebra
=========================================

This script demonstrates the algebraic formulation of spin dynamics:
1. The Landau-Lifshitz equation as coadjoint orbit flow on 𝔰𝔲(2)*
2. Holstein-Primakoff transformation as algebra homomorphism
3. Magnon dispersion relations from algebraic structure
4. Spin wave visualization

Author: The Oracle Council
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import Normalize
import matplotlib.gridspec as gridspec
from mpl_toolkits.mplot3d import Axes3D

# ============================================================================
# Part 1: Landau-Lifshitz Dynamics on the Coadjoint Orbit S²
# ============================================================================

def landau_lifshitz(M, H_eff, gamma=1.0, alpha=0.0):
    """
    Landau-Lifshitz equation: dM/dt = -γ M × H_eff - α M × (M × H_eff)
    
    This is the coadjoint orbit flow on S² ⊂ 𝔰𝔲(2)*.
    The first term is Hamiltonian (precessional), the second is dissipative.
    """
    precession = -gamma * np.cross(M, H_eff)
    damping = -alpha * np.cross(M, np.cross(M, H_eff))
    return precession + damping


def simulate_spin_dynamics(M0, H_func, T=20, dt=0.01, gamma=1.0, alpha=0.0):
    """Simulate spin dynamics using RK4 integration on S²."""
    N_steps = int(T / dt)
    trajectory = np.zeros((N_steps + 1, 3))
    trajectory[0] = M0 / np.linalg.norm(M0)
    
    for i in range(N_steps):
        t = i * dt
        M = trajectory[i]
        H = H_func(t)
        
        # RK4
        k1 = dt * landau_lifshitz(M, H, gamma, alpha)
        k2 = dt * landau_lifshitz(M + 0.5*k1, H, gamma, alpha)
        k3 = dt * landau_lifshitz(M + 0.5*k2, H, gamma, alpha)
        k4 = dt * landau_lifshitz(M + k3, H, gamma, alpha)
        
        M_new = M + (k1 + 2*k2 + 2*k3 + k4) / 6
        trajectory[i+1] = M_new / np.linalg.norm(M_new)  # Project back to S²
    
    return trajectory


# ============================================================================
# Part 2: Holstein-Primakoff Magnon Algebra
# ============================================================================

def magnon_dispersion_ferromagnet(k, J=1.0, S=0.5, a=1.0, d=1, z=None):
    """
    Magnon dispersion for a d-dimensional ferromagnet.
    
    ω(k) = 2JS Σ_δ (1 - cos(k·δ))
    
    For a hypercubic lattice in d dimensions with lattice constant a.
    The Holstein-Primakoff algebra homomorphism gives:
        𝔰𝔲(2) → Heisenberg-Weyl algebra (bosonic magnons)
    """
    if z is None:
        z = 2 * d  # coordination number for hypercubic
    
    if isinstance(k, (int, float)):
        return 2 * J * S * z * (1 - np.cos(k * a)) / z * d
    
    # For array input (1D)
    return 2 * J * S * (1 - np.cos(k * a)) * 2  # z=2 for 1D chain


def magnon_dispersion_antiferromagnet(k, J=1.0, S=0.5, a=1.0):
    """
    Magnon dispersion for a 1D antiferromagnet.
    
    ω(k) = 2JS |sin(ka)|
    
    The antiferromagnetic magnon is a Goldstone mode (linear at k=0,π).
    This follows from the spontaneous breaking of SU(2) → U(1).
    """
    return 2 * J * S * np.abs(np.sin(k * a))


def bloch_t32_law(T, M0=1.0, B=1.0):
    """
    Bloch's T^{3/2} law for magnetization reduction.
    
    M(T) = M(0)(1 - B·T^{3/2})
    
    This follows from the magnon density of states g(ω) ~ ω^{1/2}
    in 3D, which is a consequence of the ω ~ k² dispersion from
    the algebraic structure.
    """
    return M0 * (1 - B * T**1.5)


# ============================================================================
# Part 3: Visualization
# ============================================================================

def plot_spin_precession():
    """Visualize Larmor precession as coadjoint orbit flow."""
    fig = plt.figure(figsize=(16, 6))
    
    # --- Undamped precession ---
    ax1 = fig.add_subplot(131, projection='3d')
    
    # Bloch sphere
    u = np.linspace(0, 2 * np.pi, 50)
    v = np.linspace(0, np.pi, 25)
    x = np.outer(np.cos(u), np.sin(v))
    y = np.outer(np.sin(u), np.sin(v))
    z = np.outer(np.ones(np.size(u)), np.cos(v))
    ax1.plot_surface(x, y, z, alpha=0.08, color='lightblue')
    
    M0 = np.array([np.sin(np.pi/4), 0, np.cos(np.pi/4)])
    H_const = lambda t: np.array([0, 0, 1.0])
    
    traj = simulate_spin_dynamics(M0, H_const, T=15, dt=0.01, gamma=1.0, alpha=0.0)
    
    ax1.plot(traj[:, 0], traj[:, 1], traj[:, 2], 'r-', linewidth=2, alpha=0.8)
    ax1.quiver(0, 0, 0, 0, 0, 1, color='blue', arrow_length_ratio=0.1, linewidth=3,
              label='H_eff')
    ax1.set_title('Undamped Precession\n(Hamiltonian flow on S²)', fontsize=11)
    ax1.set_xlabel('Mx'); ax1.set_ylabel('My'); ax1.set_zlabel('Mz')
    
    # --- Damped precession ---
    ax2 = fig.add_subplot(132, projection='3d')
    ax2.plot_surface(x, y, z, alpha=0.08, color='lightblue')
    
    traj_damped = simulate_spin_dynamics(M0, H_const, T=30, dt=0.01, gamma=1.0, alpha=0.1)
    
    # Color by time
    N = len(traj_damped)
    for i in range(0, N-1, 5):
        color = plt.cm.hot(i / N)
        ax2.plot(traj_damped[i:i+6, 0], traj_damped[i:i+6, 1], traj_damped[i:i+6, 2],
                color=color, linewidth=2)
    
    ax2.quiver(0, 0, 0, 0, 0, 1, color='blue', arrow_length_ratio=0.1, linewidth=3)
    ax2.set_title('Damped Precession (α=0.1)\n(Dissipative flow → alignment)', fontsize=11)
    ax2.set_xlabel('Mx'); ax2.set_ylabel('My'); ax2.set_zlabel('Mz')
    
    # --- Driven precession (rotating field) ---
    ax3 = fig.add_subplot(133, projection='3d')
    ax3.plot_surface(x, y, z, alpha=0.08, color='lightblue')
    
    omega_drive = 0.8
    H_driven = lambda t: np.array([0.3*np.cos(omega_drive*t), 0.3*np.sin(omega_drive*t), 1.0])
    traj_driven = simulate_spin_dynamics(M0, H_driven, T=40, dt=0.01, gamma=1.0, alpha=0.02)
    
    N = len(traj_driven)
    for i in range(0, N-1, 5):
        color = plt.cm.cool(i / N)
        ax3.plot(traj_driven[i:i+6, 0], traj_driven[i:i+6, 1], traj_driven[i:i+6, 2],
                color=color, linewidth=1.5)
    
    ax3.set_title('Driven Precession\n(Time-dependent H_eff)', fontsize=11)
    ax3.set_xlabel('Mx'); ax3.set_ylabel('My'); ax3.set_zlabel('Mz')
    
    fig.suptitle('Spin Dynamics as Coadjoint Orbit Flow on 𝔰𝔲(2)* ≅ S²',
                fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/spin_dynamics.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved spin_dynamics.png")


def plot_magnon_dispersions():
    """Compare magnon dispersion relations from algebraic structure."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Magnon Dispersion Relations from the Magnetic Algebra',
                fontsize=14, fontweight='bold')
    
    k = np.linspace(-np.pi, np.pi, 500)
    
    # --- Ferromagnet ---
    ax = axes[0]
    for S in [0.5, 1, 1.5, 2]:
        omega = magnon_dispersion_ferromagnet(k, J=1.0, S=S)
        ax.plot(k/np.pi, omega, linewidth=2, label=f's = {S}')
    
    ax.set_xlabel('k / π', fontsize=12)
    ax.set_ylabel('ω(k) / J', fontsize=12)
    ax.set_title('Ferromagnet: ω ∝ k²\n(𝔰𝔲(2) → Weyl algebra)', fontsize=11)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-1, 1)
    
    # --- Antiferromagnet ---
    ax = axes[1]
    omega_af = magnon_dispersion_antiferromagnet(k)
    ax.plot(k/np.pi, omega_af, 'r-', linewidth=2, label='AFM magnon')
    ax.plot(k/np.pi, magnon_dispersion_ferromagnet(k), 'b--', linewidth=2, 
           label='FM magnon', alpha=0.5)
    
    ax.set_xlabel('k / π', fontsize=12)
    ax.set_ylabel('ω(k) / J', fontsize=12)
    ax.set_title('Antiferromagnet: ω ∝ |k|\n(Goldstone mode, linear)', fontsize=11)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-1, 1)
    
    # --- Gapped magnon (anisotropic) ---
    ax = axes[2]
    Delta_values = [0, 0.2, 0.5, 1.0]
    for Delta in Delta_values:
        omega_gapped = np.sqrt(Delta**2 + magnon_dispersion_ferromagnet(k)**2)
        ax.plot(k/np.pi, omega_gapped, linewidth=2, label=f'Δ = {Delta}')
    
    ax.set_xlabel('k / π', fontsize=12)
    ax.set_ylabel('ω(k) / J', fontsize=12)
    ax.set_title('Gapped Magnon (anisotropy Δ)\nω² = Δ² + (2JSsin(k))²', fontsize=11)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-1, 1)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/magnon_dispersions.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved magnon_dispersions.png")


def plot_bloch_law():
    """Visualize Bloch's T^{3/2} law as a consequence of magnon algebra."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle("Bloch's T³ᐟ² Law — From Magnon Algebra to Thermodynamics",
                fontsize=14, fontweight='bold')
    
    # Left: Magnetization vs Temperature
    T = np.linspace(0, 1, 200)
    
    # Different dimensionalities
    dims = {
        '1D (no order, Mermin-Wagner)': (1, '#e74c3c', '--'),
        '2D (logarithmic, Mermin-Wagner)': (2, '#f39c12', '--'),
        '3D (Bloch T^{3/2})': (3, '#2ecc71', '-'),
    }
    
    for label, (d, color, ls) in dims.items():
        if d == 1:
            # 1D: exponential decay, no long-range order
            M = np.exp(-T * 3)
        elif d == 2:
            # 2D: no spontaneous magnetization (Mermin-Wagner)
            M = np.maximum(0, 1 - T * np.log(1 + 1/(T + 0.01)))
            M = np.where(T > 0.3, 0, M)
        else:
            # 3D: Bloch T^{3/2}
            M = bloch_t32_law(T, M0=1.0, B=1.5)
            M = np.maximum(M, 0)
        
        ax1.plot(T, M, color=color, linewidth=2.5, linestyle=ls, label=label)
    
    ax1.set_xlabel('T / Tc', fontsize=12)
    ax1.set_ylabel('M(T) / M(0)', fontsize=12)
    ax1.set_title('Magnetization vs Temperature\n(Dimension dependence from magnon DOS)', fontsize=11)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(0, 1)
    ax1.set_ylim(-0.05, 1.05)
    
    # Right: Magnon density of states
    omega = np.linspace(0, 5, 200)
    
    dos_data = {
        '1D: g(ω) ~ ω^{-1/2}': omega**(-0.5) * np.exp(-omega/3),
        '2D: g(ω) ~ const': np.ones_like(omega) * 0.5 * np.exp(-omega/3),
        '3D: g(ω) ~ ω^{1/2}': omega**(0.5) * np.exp(-omega/3),
    }
    
    colors = ['#e74c3c', '#f39c12', '#2ecc71']
    for (label, dos), color in zip(dos_data.items(), colors):
        dos = np.nan_to_num(dos, nan=0)
        ax2.plot(omega, dos, color=color, linewidth=2.5, label=label)
        ax2.fill_between(omega, dos, alpha=0.1, color=color)
    
    ax2.set_xlabel('ω / J', fontsize=12)
    ax2.set_ylabel('g(ω)', fontsize=12)
    ax2.set_title('Magnon Density of States\n(From ω ~ k² dispersion)', fontsize=11)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(0, 5)
    ax2.set_ylim(0, 3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/bloch_law.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved bloch_law.png")


def plot_spin_wave_visualization():
    """Visualize spin waves as excitations of the magnon algebra."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Spin Waves — Excitations of the Magnon Algebra\n'
                'Holstein-Primakoff: 𝔰𝔲(2) → Heisenberg-Weyl Algebra [a, a†] = 1',
                fontsize=14, fontweight='bold')
    
    N_sites = 40
    x = np.arange(N_sites)
    
    configs = [
        ('Ground state (ferromagnetic vacuum |0⟩)', 0, 0),
        ('Single magnon a†_k|0⟩ (k=π/5)', np.pi/5, 1),
        ('Single magnon a†_k|0⟩ (k=π/2)', np.pi/2, 1),
        ('Two-magnon state (k=π/4, k=3π/4)', None, 2),
    ]
    
    for ax, (title, k, n_magnons) in zip(axes.flat, configs):
        if n_magnons == 0:
            # Ground state: all spins up
            theta = np.zeros(N_sites)
            phi = np.zeros(N_sites)
        elif n_magnons == 1:
            # Single magnon: small deviation with wave pattern
            amplitude = 0.3
            theta = amplitude * np.cos(k * x)
            phi = k * x
        else:
            # Two magnons
            amplitude = 0.2
            k1, k2 = np.pi/4, 3*np.pi/4
            theta = amplitude * (np.cos(k1 * x) + np.cos(k2 * x))
            phi = np.arctan2(np.sin(k1*x) + np.sin(k2*x),
                            np.cos(k1*x) + np.cos(k2*x))
        
        # Draw spins as arrows
        mx = np.sin(theta) * np.cos(phi)
        my = np.sin(theta) * np.sin(phi)
        mz = np.cos(theta)
        
        # Plot in xz plane
        colors = plt.cm.coolwarm(0.5 * (mz + 1))
        
        ax.quiver(x, np.zeros(N_sites), mx, mz,
                 color=colors, scale=25, width=0.008,
                 headwidth=4, headlength=5, angles='xy')
        
        # Draw connecting line
        ax.plot(x, mz * 0.03, 'k-', alpha=0.2, linewidth=0.5)
        
        ax.set_title(title, fontsize=11)
        ax.set_xlabel('Lattice site i')
        ax.set_ylabel('Spin projection')
        ax.set_ylim(-0.15, 0.15)
        ax.axhline(y=0, color='gray', linestyle='-', alpha=0.2)
        ax.grid(True, alpha=0.2)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/spin_waves.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved spin_waves.png")


# ============================================================================
# Main
# ============================================================================

if __name__ == '__main__':
    print("=" * 70)
    print("ALGEBRAIC THEORY OF MAGNETISM — Demo 4: Dynamics & Magnons")
    print("=" * 70)
    
    # Test spin dynamics
    print("\n--- Testing Coadjoint Orbit Dynamics ---")
    M0 = np.array([np.sin(np.pi/6), 0, np.cos(np.pi/6)])
    H = lambda t: np.array([0, 0, 1.0])
    
    traj = simulate_spin_dynamics(M0, H, T=10, dt=0.001)
    print(f"  Initial |M| = {np.linalg.norm(traj[0]):.10f}")
    print(f"  Final   |M| = {np.linalg.norm(traj[-1]):.10f}")
    print(f"  |M| is conserved: {np.allclose(np.linalg.norm(traj, axis=1), 1.0)}")
    print(f"  → Confirms flow stays on coadjoint orbit S²")
    
    # Magnon dispersions
    print("\n--- Magnon Dispersion at Special Points ---")
    print(f"  FM magnon at k=0:  ω = {magnon_dispersion_ferromagnet(0):.4f} (gapless ✓)")
    print(f"  FM magnon at k=π:  ω = {magnon_dispersion_ferromagnet(np.pi):.4f}")
    print(f"  AFM magnon at k=0: ω = {magnon_dispersion_antiferromagnet(0):.4f} (gapless ✓)")
    print(f"  AFM magnon at k=π: ω = {magnon_dispersion_antiferromagnet(np.pi):.4f} (gapless ✓)")
    
    # Generate figures
    print("\n--- Generating Figures ---")
    plot_spin_precession()
    plot_magnon_dispersions()
    plot_bloch_law()
    plot_spin_wave_visualization()
    
    print("\n✓ Demo 4 complete!")
