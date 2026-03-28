#!/usr/bin/env python3
"""
Demo 3: Topological Magnetic Textures — Algebraic Classification
=================================================================

This script demonstrates how the algebraic theory classifies topological
magnetic textures through the homotopy groups of order parameter spaces.

We visualize:
1. Magnetic skyrmions (π₂(S²) = ℤ)
2. Magnetic vortices (π₁(S¹) = ℤ)
3. Domain walls (π₀ classification)
4. The topological charge computation

Key theorem: The order parameter space G/H is determined algebraically
by the symmetry breaking pattern, and πₙ(G/H) classifies the topological
defects of codimension n+1.

Author: The Oracle Council
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import hsv_to_rgb, Normalize
from matplotlib.patches import FancyArrowPatch
import matplotlib.gridspec as gridspec

# ============================================================================
# Part 1: Magnetic Texture Definitions
# ============================================================================

def skyrmion_field(X, Y, R=1.0, helicity=0, vorticity=1, polarity=1):
    """
    Generate a magnetic skyrmion spin texture.
    
    The skyrmion is a topological soliton classified by π₂(S²) = ℤ.
    Its topological charge is Q = (1/4π) ∫ n · (∂ₓn × ∂ᵧn) dx dy = ±1.
    
    Parameters
    ----------
    R : float - Skyrmion radius
    helicity : float - Helicity angle γ (Bloch: π/2, Néel: 0)
    vorticity : int - Vorticity m (number of 2π rotations)
    polarity : int - Core polarity p = ±1
    """
    r = np.sqrt(X**2 + Y**2)
    phi = np.arctan2(Y, X)
    
    # Radial profile: θ(r) goes from π (core) to 0 (boundary)
    theta = 2 * np.arctan(R / (r + 1e-10))
    
    # Spin components
    mx = np.sin(theta) * np.cos(vorticity * phi + helicity)
    my = np.sin(theta) * np.sin(vorticity * phi + helicity)
    mz = polarity * np.cos(theta)
    
    return mx, my, mz


def vortex_field(X, Y, winding=1, chirality=1):
    """
    Generate an XY vortex spin texture.
    
    Classified by π₁(S¹) = ℤ. Winding number = ±1, ±2, ...
    """
    phi = np.arctan2(Y, X)
    
    mx = chirality * np.cos(winding * phi + np.pi/2)
    my = chirality * np.sin(winding * phi + np.pi/2)
    mz = np.zeros_like(X)
    
    return mx, my, mz


def domain_wall_field(X, Y, wall_type='Bloch', width=0.5):
    """
    Generate a domain wall spin texture.
    
    Classified by π₀(S⁰) = ℤ₂ for Ising-like systems.
    """
    profile = np.tanh(X / width)
    
    if wall_type == 'Bloch':
        mx = np.zeros_like(X)
        my = 1.0 / np.cosh(X / width)
        mz = profile
    elif wall_type == 'Neel':
        mx = 1.0 / np.cosh(X / width)
        my = np.zeros_like(X)
        mz = profile
    else:
        mx = np.zeros_like(X)
        my = np.zeros_like(X)
        mz = profile
    
    return mx, my, mz


def compute_topological_charge(mx, my, mz, dx, dy):
    """
    Compute the skyrmion topological charge.
    
    Q = (1/4π) ∫ n · (∂ₓn × ∂ᵧn) dx dy
    
    This is the degree of the map n: ℝ² → S², an element of π₂(S²) = ℤ.
    """
    # Numerical partial derivatives
    dmx_dx = np.gradient(mx, dx, axis=1)
    dmx_dy = np.gradient(mx, dy, axis=0)
    dmy_dx = np.gradient(my, dx, axis=1)
    dmy_dy = np.gradient(my, dy, axis=0)
    dmz_dx = np.gradient(mz, dx, axis=1)
    dmz_dy = np.gradient(mz, dy, axis=0)
    
    # Cross product ∂ₓn × ∂ᵧn
    cross_x = dmy_dx * dmz_dy - dmz_dx * dmy_dy
    cross_y = dmz_dx * dmx_dy - dmx_dx * dmz_dy
    cross_z = dmx_dx * dmy_dy - dmy_dx * dmx_dy
    
    # Dot with n
    density = mx * cross_x + my * cross_y + mz * cross_z
    
    # Integrate
    Q = np.sum(density) * dx * dy / (4 * np.pi)
    
    return Q, density


# ============================================================================
# Part 2: Visualization
# ============================================================================

def spin_color(mx, my, mz):
    """Map spin direction to color using HSV colormap."""
    # Hue from in-plane angle
    hue = (np.arctan2(my, mx) / (2 * np.pi)) % 1.0
    # Saturation from in-plane magnitude  
    sat = np.sqrt(mx**2 + my**2)
    # Value from mz
    val = 0.5 * (mz + 1)
    
    hsv = np.stack([hue, sat, np.clip(val, 0, 1)], axis=-1)
    return hsv_to_rgb(hsv)


def plot_skyrmions():
    """Visualize skyrmions with different topological properties."""
    fig = plt.figure(figsize=(16, 12))
    gs = gridspec.GridSpec(2, 3, hspace=0.35, wspace=0.3)
    fig.suptitle('Magnetic Skyrmions — Classified by π₂(S²) = ℤ\n'
                'Order Parameter Space: G/H = SO(3)/SO(2) ≅ S²',
                fontsize=14, fontweight='bold')
    
    L = 3.0
    N = 200
    x = np.linspace(-L, L, N)
    y = np.linspace(-L, L, N)
    X, Y = np.meshgrid(x, y)
    dx = x[1] - x[0]
    dy = y[1] - y[0]
    
    configs = [
        ('Néel Skyrmion (Q=-1)\nhelicity γ = 0', 
         dict(helicity=0, vorticity=1, polarity=-1)),
        ('Bloch Skyrmion (Q=-1)\nhelicity γ = π/2',
         dict(helicity=np.pi/2, vorticity=1, polarity=-1)),
        ('Anti-Skyrmion (Q=+1)\nvorticity m = -1',
         dict(helicity=0, vorticity=-1, polarity=-1)),
        ('Q=-2 Skyrmion\nvorticity m = 2',
         dict(helicity=0, vorticity=2, polarity=-1)),
        ('Meron (half-skyrmion)\nQ = -1/2',
         dict(helicity=0, vorticity=1, polarity=-1, R=0.3)),
        ('Skyrmion lattice\n(superposition)',
         None),  # Special case
    ]
    
    for idx, (title, params) in enumerate(configs):
        ax = fig.add_subplot(gs[idx // 3, idx % 3])
        
        if params is not None:
            mx, my, mz = skyrmion_field(X, Y, **params)
        else:
            # Skyrmion lattice (approximate)
            mx = np.zeros_like(X)
            my = np.zeros_like(X)
            mz = np.ones_like(X)
            centers = [(0, 0), (2, 0), (-2, 0), (1, 1.73), (-1, 1.73),
                      (1, -1.73), (-1, -1.73)]
            for cx, cy in centers:
                mx1, my1, mz1 = skyrmion_field(X - cx, Y - cy, R=0.5, polarity=-1)
                r = np.sqrt((X-cx)**2 + (Y-cy)**2)
                weight = np.exp(-r**2 / 1.5)
                mx += mx1 * weight
                my += my1 * weight
                mz = mz - (1 - mz1) * weight
            # Normalize
            norm = np.sqrt(mx**2 + my**2 + mz**2) + 1e-10
            mx /= norm; my /= norm; mz /= norm
        
        # Color plot based on mz
        colors = spin_color(mx, my, mz)
        ax.imshow(colors, extent=[-L, L, -L, L], origin='lower')
        
        # Quiver plot for in-plane components
        skip = N // 20
        ax.quiver(X[::skip, ::skip], Y[::skip, ::skip],
                 mx[::skip, ::skip], my[::skip, ::skip],
                 color='white', alpha=0.6, scale=15,
                 headwidth=4, headlength=5, width=0.004)
        
        # Compute topological charge
        Q, density = compute_topological_charge(mx, my, mz, dx, dy)
        
        ax.set_title(f'{title}\nQ = {Q:.2f}', fontsize=10)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
    
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/skyrmions.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved skyrmions.png")


def plot_vortices():
    """Visualize XY model vortices classified by π₁(S¹) = ℤ."""
    fig, axes = plt.subplots(1, 4, figsize=(16, 4))
    fig.suptitle('Magnetic Vortices — Classified by π₁(S¹) = ℤ\n'
                'Order Parameter Space: G/H = U(1) ≅ S¹',
                fontsize=14, fontweight='bold')
    
    L = 3.0
    N = 150
    x = np.linspace(-L, L, N)
    y = np.linspace(-L, L, N)
    X, Y = np.meshgrid(x, y)
    
    configs = [
        ('Vortex (w=+1)', 1, 1),
        ('Anti-vortex (w=-1)', -1, 1),
        ('Double vortex (w=+2)', 2, 1),
        ('Vortex-antivortex pair', None, None),
    ]
    
    for ax, (title, w, c) in zip(axes, configs):
        if w is not None:
            mx, my, mz = vortex_field(X, Y, winding=w, chirality=c)
        else:
            # Vortex-antivortex pair
            d = 1.5
            phi1 = np.arctan2(Y, X - d)
            phi2 = np.arctan2(Y, X + d)
            angle = phi1 - phi2
            mx = np.cos(angle + np.pi/2)
            my = np.sin(angle + np.pi/2)
            mz = np.zeros_like(X)
        
        # Color by in-plane angle
        angle = np.arctan2(my, mx)
        ax.imshow(angle, extent=[-L, L, -L, L], origin='lower',
                 cmap='hsv', vmin=-np.pi, vmax=np.pi)
        
        skip = N // 15
        ax.quiver(X[::skip, ::skip], Y[::skip, ::skip],
                 mx[::skip, ::skip], my[::skip, ::skip],
                 color='black', alpha=0.7, scale=12,
                 headwidth=4, headlength=5, width=0.005)
        
        ax.set_title(title, fontsize=11)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/vortices.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved vortices.png")


def plot_domain_walls():
    """Visualize domain walls classified by π₀."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle('Magnetic Domain Walls — Classified by π₀(G/H)\n'
                'Ising: π₀(S⁰) = ℤ₂ | Heisenberg: π₀(S²) = 0',
                fontsize=14, fontweight='bold')
    
    L = 3.0
    N = 200
    x = np.linspace(-L, L, N)
    y = np.linspace(-L, L, N)
    X, Y = np.meshgrid(x, y)
    
    wall_types = [('Ising (sharp)', 'Ising'), ('Bloch wall', 'Bloch'), ('Néel wall', 'Neel')]
    
    for ax, (title, wtype) in zip(axes, wall_types):
        mx, my, mz = domain_wall_field(X, Y, wall_type=wtype, width=0.5)
        
        colors = spin_color(mx, my, mz)
        ax.imshow(colors, extent=[-L, L, -L, L], origin='lower')
        
        skip = N // 20
        ax.quiver(X[::skip, ::skip], Y[::skip, ::skip],
                 mx[::skip, ::skip], mz[::skip, ::skip],
                 color='white', alpha=0.7, scale=15,
                 headwidth=4, headlength=5, width=0.004)
        
        ax.set_title(title, fontsize=12)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/domain_walls.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved domain_walls.png")


def plot_topological_classification_table():
    """
    Create a visual summary of the algebraic-topological classification
    of magnetic textures.
    """
    fig, ax = plt.subplots(figsize=(14, 8))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    ax.set_title('Algebraic-Topological Classification of Magnetic Textures',
                fontsize=16, fontweight='bold', pad=20)
    
    # Table headers
    headers = ['Model', 'Symmetry\nBreaking', 'Order Param.\nSpace G/H', 
               'π₀(G/H)', 'π₁(G/H)', 'π₂(G/H)', 'Defects']
    x_positions = [0.5, 2.5, 4.5, 6.5, 8, 9.5, 11.5]
    
    for x, h in zip(x_positions, headers):
        ax.text(x, 9.2, h, fontsize=10, fontweight='bold', ha='center', va='center',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='#3498db', alpha=0.3))
    
    # Table data
    data = [
        ['Ising', 'ℤ₂ → {e}', 'S⁰ = {±1}', 'ℤ₂', '0', '0', 'Domain walls'],
        ['XY', 'U(1) → {e}', 'S¹', '0', 'ℤ', '0', 'Vortices'],
        ['Heisenberg', 'SO(3)→SO(2)', 'S²', '0', '0', 'ℤ', 'Skyrmions,\nhedgehogs'],
        ['Planar AF', 'SO(3)→SO(2)', 'S²/ℤ₂ = RP²', '0', 'ℤ₂', 'ℤ', 'Z₂ vortices,\nskyrmions'],
        ['p-wave SC', 'SO(3)×U(1)\n→ SO(2)', 'S² × S¹', '0', 'ℤ', 'ℤ', 'Vortices +\nskyrmions'],
    ]
    
    colors = ['#ecf0f1', '#ffffff']
    for row_idx, row in enumerate(data):
        y = 8.0 - row_idx * 1.4
        bg_color = colors[row_idx % 2]
        
        # Background
        rect = plt.Rectangle((0, y - 0.6), 14, 1.2, facecolor=bg_color, 
                             edgecolor='gray', alpha=0.5)
        ax.add_patch(rect)
        
        for col_idx, (x, val) in enumerate(zip(x_positions, row)):
            fontsize = 9 if col_idx > 0 else 10
            fontweight = 'bold' if col_idx == 0 else 'normal'
            ax.text(x, y, val, fontsize=fontsize, fontweight=fontweight,
                   ha='center', va='center')
    
    # Footer
    ax.text(7, 0.5, 
            'Key Theorem: Topological defects of codimension (n+1) in a magnetic system\n'
            'with order parameter space G/H are classified by the homotopy group πₙ(G/H).\n'
            'These groups are computable from the algebraic data of the symmetry breaking.',
            fontsize=10, ha='center', va='center', style='italic',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#f1c40f', alpha=0.2))
    
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/topological_classification.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved topological_classification.png")


# ============================================================================
# Main
# ============================================================================

if __name__ == '__main__':
    print("=" * 70)
    print("ALGEBRAIC THEORY OF MAGNETISM — Demo 3: Topological Textures")
    print("=" * 70)
    
    # Compute topological charges
    print("\n--- Computing Topological Charges ---")
    L, N = 5.0, 300
    x = np.linspace(-L, L, N)
    y = np.linspace(-L, L, N)
    X, Y = np.meshgrid(x, y)
    dx = x[1] - x[0]
    dy = y[1] - y[0]
    
    configs = [
        ("Néel skyrmion (Q=-1)", dict(helicity=0, vorticity=1, polarity=-1)),
        ("Bloch skyrmion (Q=-1)", dict(helicity=np.pi/2, vorticity=1, polarity=-1)),
        ("Anti-skyrmion (Q=+1)", dict(helicity=0, vorticity=-1, polarity=-1)),
        ("Q=-2 skyrmion", dict(helicity=0, vorticity=2, polarity=-1)),
    ]
    
    for name, params in configs:
        mx, my, mz = skyrmion_field(X, Y, **params)
        Q, _ = compute_topological_charge(mx, my, mz, dx, dy)
        print(f"  {name}: Q = {Q:.4f}")
    
    # Generate figures
    print("\n--- Generating Figures ---")
    plot_skyrmions()
    plot_vortices()
    plot_domain_walls()
    plot_topological_classification_table()
    
    print("\n✓ Demo 3 complete!")
