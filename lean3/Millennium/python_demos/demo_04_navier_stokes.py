#!/usr/bin/env python3
"""
Navier-Stokes Existence and Smoothness — Visual Demonstration

Visualizes:
1. 2D vortex dynamics (where regularity IS known)
2. Vortex stretching in 3D (the mechanism that COULD cause blow-up)
3. Energy cascade and Kolmogorov scaling
4. Near-singular vortex configurations

Run: python demo_04_navier_stokes.py
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import Normalize
from scipy.integrate import solve_ivp


def plot_2d_vortex_flow():
    """
    Simulate 2D inviscid vortex dynamics using point vortices.
    In 2D, Navier-Stokes regularity is PROVED — no blow-up possible.
    """
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Panel 1: Velocity field of a single vortex
    ax = axes[0]
    x = np.linspace(-3, 3, 30)
    y = np.linspace(-3, 3, 30)
    X, Y = np.meshgrid(x, y)

    # Point vortex at origin
    R2 = X**2 + Y**2 + 0.01  # regularize
    Gamma = 2 * np.pi
    U = -Gamma * Y / (2 * np.pi * R2)
    V = Gamma * X / (2 * np.pi * R2)

    speed = np.sqrt(U**2 + V**2)
    lw = 2 * speed / speed.max()

    ax.streamplot(X, Y, U, V, density=2, linewidth=lw, color=speed,
                 cmap='coolwarm', arrowsize=1.5)
    ax.plot(0, 0, 'ko', markersize=10)
    ax.set_title('Single Vortex Flow\n(2D: Always Regular ✓)', fontsize=12, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_aspect('equal')

    # Panel 2: Two counter-rotating vortices
    ax = axes[1]
    # Vortex pair
    d = 1.0  # separation
    vortices = [(0, d/2, 1.0), (0, -d/2, -1.0)]  # (x, y, circulation)

    U = np.zeros_like(X)
    V = np.zeros_like(Y)
    for xv, yv, gamma in vortices:
        dx = X - xv
        dy = Y - yv
        r2 = dx**2 + dy**2 + 0.05
        U += -gamma * dy / (2 * np.pi * r2)
        V += gamma * dx / (2 * np.pi * r2)

    speed = np.sqrt(U**2 + V**2)
    lw = 2 * speed / speed.max()

    ax.streamplot(X, Y, U, V, density=2, linewidth=lw, color=speed,
                 cmap='coolwarm', arrowsize=1.5)
    ax.plot(0, d/2, 'ro', markersize=10, label='Γ > 0')
    ax.plot(0, -d/2, 'bo', markersize=10, label='Γ < 0')
    ax.set_title('Vortex Dipole\n(Translating pair)', fontsize=12, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_aspect('equal')

    # Panel 3: Vorticity evolution — initially smooth, stays smooth (2D)
    ax = axes[2]
    x = np.linspace(-5, 5, 200)
    y = np.linspace(-5, 5, 200)
    X, Y = np.meshgrid(x, y)

    # Two Gaussian vortex blobs
    omega = (np.exp(-((X-1)**2 + Y**2)) - np.exp(-((X+1)**2 + Y**2)))
    omega += 0.5 * np.exp(-((X)**2 + (Y-1.5)**2) * 2)

    im = ax.contourf(X, Y, omega, levels=30, cmap='RdBu_r')
    plt.colorbar(im, ax=ax, label='Vorticity ω')
    ax.set_title('Vorticity Field ω(x,y)\n‖ω‖∞ stays bounded in 2D!',
                fontsize=12, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_aspect('equal')

    plt.tight_layout()
    plt.savefig('demo_04_navier_stokes_2d.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demo_04_navier_stokes_2d.png")


def plot_3d_vortex_stretching():
    """
    Illustrate vortex stretching — the mechanism unique to 3D
    that could potentially cause blow-up.
    """
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Panel 1: Vortex stretching schematic
    ax = axes[0]
    # Show a vortex tube being stretched
    t_vals = np.linspace(0, 1, 5)

    for i, t in enumerate(t_vals):
        stretch = 1 + 2 * t
        compress = 1 / np.sqrt(stretch)

        theta = np.linspace(0, 2 * np.pi, 50)
        x_circle = compress * np.cos(theta)
        y_circle = compress * np.sin(theta) + i * 2.5

        alpha = 0.3 + 0.7 * t  # gets more intense
        ax.fill(x_circle, y_circle, alpha=alpha, color='red')
        ax.plot(x_circle, y_circle, 'r-', linewidth=1)
        ax.text(1.5, i * 2.5, f'stretch={stretch:.1f}×\nω ~ {stretch:.1f}ω₀',
               fontsize=9, va='center')

    ax.annotate('', xy=(0, 10.5), xytext=(0, -0.5),
               arrowprops=dict(arrowstyle='->', color='blue', lw=3))
    ax.text(-2, 5, 'Stretching\ndirection',
           fontsize=11, color='blue', fontweight='bold', rotation=90, va='center')

    ax.set_xlim(-3, 4)
    ax.set_ylim(-1, 11)
    ax.set_title('Vortex Stretching (3D only!)\nω → ∞ as tube thins',
                fontsize=12, fontweight='bold')
    ax.set_aspect('equal')
    ax.axis('off')

    # Panel 2: Energy cascade (Kolmogorov spectrum)
    ax = axes[1]
    k = np.logspace(-1, 3, 500)  # wavenumber

    # Kolmogorov -5/3 spectrum
    k_L = 1  # injection scale
    k_eta = 500  # dissipation scale
    E_k = k**(-5/3) * np.exp(-2 * (k / k_eta)**2)
    E_k[k < k_L] = k_L**(-5/3)

    ax.loglog(k, E_k, 'b-', linewidth=3)

    # Reference slope
    k_ref = np.logspace(0.3, 2, 50)
    ax.loglog(k_ref, 3 * k_ref**(-5/3), 'r--', linewidth=2, label='k^{-5/3} (Kolmogorov)')

    ax.axvline(x=k_L, color='green', linestyle=':', linewidth=2, label='Injection scale')
    ax.axvline(x=k_eta, color='orange', linestyle=':', linewidth=2, label='Dissipation scale')

    # Annotate regions
    ax.text(3, 0.1, 'Inertial\nRange', fontsize=12, ha='center',
           fontweight='bold', color='blue')
    ax.text(0.3, 0.5, 'Energy\nInput', fontsize=10, ha='center', color='green')

    ax.set_xlabel('Wavenumber k', fontsize=12)
    ax.set_ylabel('Energy Spectrum E(k)', fontsize=12)
    ax.set_title('Kolmogorov Energy Cascade\nE(k) ~ k^{-5/3}',
                fontsize=12, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, which='both')

    # Panel 3: The critical scaling gap
    ax = axes[2]
    dims = [1, 2, 3, 4]
    labels = ['1D\nBurgers', '2D NS\n(SOLVED ✓)', '3D NS\n(OPEN ✗)', '4D NS']
    criticality = ['subcritical', 'critical', 'supercritical', 'supercritical']
    colors = ['#2ecc71', '#2ecc71', '#e74c3c', '#e74c3c']
    values = [1, 0.5, 0, -0.5]

    bars = ax.bar(labels, [1, 0.8, 0.2, 0.1], color=colors, edgecolor='black', linewidth=1.5)
    for bar, crit in zip(bars, criticality):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.03,
               crit, ha='center', va='bottom', fontsize=10, fontweight='bold',
               style='italic')

    ax.set_ylabel('Regularity Status', fontsize=12)
    ax.set_title('NS Regularity by Dimension\n3D is the Critical Frontier',
                fontsize=12, fontweight='bold')
    ax.set_ylim(0, 1.3)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('demo_04b_navier_stokes_3d.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demo_04b_navier_stokes_3d.png")


def plot_burgers_equation():
    """
    Solve 1D Burgers equation — the simplest model of shock formation.
    Shows how nonlinearity can create singularities (but viscosity prevents them).
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    N = 500
    x = np.linspace(-5, 5, N)
    dx = x[1] - x[0]

    # Initial condition: smooth bump
    u0 = np.exp(-x**2)

    # Panel 1: Inviscid Burgers (develops shock)
    ax = axes[0]
    times = [0, 0.3, 0.6, 0.9]
    colors = ['blue', 'green', 'orange', 'red']

    for t, c in zip(times, colors):
        # Method of characteristics: x = x₀ + u₀(x₀)·t
        # Implicit: u(x,t) = u₀(x - u·t)
        # Approximate by shifting
        u = np.interp(x, x + u0 * t, u0, left=0, right=0)
        ax.plot(x, u, color=c, linewidth=2, label=f't = {t}')

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('u(x,t)', fontsize=12)
    ax.set_title('Inviscid Burgers Equation\n∂u/∂t + u·∂u/∂x = 0 (SHOCK forms!)',
                fontsize=12, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Panel 2: Viscous Burgers (stays smooth)
    ax = axes[1]
    # Solve: ∂u/∂t + u·∂u/∂x = ν·∂²u/∂x²
    nu = 0.1

    def burgers_rhs(t, u):
        # Periodic-ish boundary
        dudx = np.gradient(u, dx)
        d2udx2 = np.gradient(dudx, dx)
        return -u * dudx + nu * d2udx2

    u_init = np.exp(-x**2)
    sol = solve_ivp(burgers_rhs, [0, 2], u_init, t_eval=[0, 0.3, 0.6, 1.0, 2.0],
                    method='RK45', max_step=0.001)

    for i, (t_val, c) in enumerate(zip(sol.t, ['blue', 'green', 'orange', 'red', 'purple'])):
        ax.plot(x, sol.y[:, i], color=c, linewidth=2, label=f't = {t_val:.1f}')

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('u(x,t)', fontsize=12)
    ax.set_title(f'Viscous Burgers (ν={nu})\nViscosity prevents blow-up ✓',
                fontsize=12, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demo_04c_burgers.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demo_04c_burgers.png")


if __name__ == '__main__':
    print("=" * 60)
    print("Navier-Stokes — Visual Demonstrations")
    print("=" * 60)
    print("\n1. Generating 2D vortex flow...")
    plot_2d_vortex_flow()
    print("\n2. Generating 3D vortex stretching and energy cascade...")
    plot_3d_vortex_stretching()
    print("\n3. Generating Burgers equation comparison...")
    plot_burgers_equation()
    print("\nDone! Check the generated PNG files.")
