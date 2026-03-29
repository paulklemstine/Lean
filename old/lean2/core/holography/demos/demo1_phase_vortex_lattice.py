"""
Demo 1: Topological Phase Lattice Visualization
================================================
Visualizes the topological phase vortex structure that forms the basis
of the TPL framework. Shows how phase configurations carry topological
charges (winding numbers) and how they combine.

Generates: output/phase_vortex_lattice.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

def create_vortex(X, Y, x0, y0, charge=1):
    """Create a phase vortex centered at (x0, y0) with given topological charge."""
    return charge * np.arctan2(Y - y0, X - x0)

def phase_to_rgb(phase, amplitude=None):
    """Convert phase (0 to 2π) to HSV color, with optional amplitude modulation."""
    if amplitude is None:
        amplitude = np.ones_like(phase)
    # Normalize phase to [0, 1]
    hue = (phase % (2 * np.pi)) / (2 * np.pi)
    saturation = np.ones_like(hue)
    value = amplitude / amplitude.max() if amplitude.max() > 0 else amplitude
    
    hsv = np.stack([hue, saturation, value], axis=-1)
    rgb = mcolors.hsv_to_rgb(hsv)
    return rgb

def main():
    # Grid
    N = 500
    x = np.linspace(-5, 5, N)
    y = np.linspace(-5, 5, N)
    X, Y = np.meshgrid(x, y)
    
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))
    fig.suptitle('Topological Phase Lattice: Vortex Configurations',
                 fontsize=20, fontweight='bold', y=0.98)
    
    # Panel 1: Single vortex (charge +1)
    phi1 = create_vortex(X, Y, 0, 0, charge=1)
    ax = axes[0, 0]
    ax.imshow(phase_to_rgb(phi1), extent=[-5, 5, -5, 5], origin='lower')
    ax.set_title('Single Vortex\n(Topological Charge n = +1)', fontsize=13)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.plot(0, 0, 'w+', markersize=15, markeredgewidth=2)
    
    # Panel 2: Anti-vortex (charge -1)
    phi2 = create_vortex(X, Y, 0, 0, charge=-1)
    ax = axes[0, 1]
    ax.imshow(phase_to_rgb(phi2), extent=[-5, 5, -5, 5], origin='lower')
    ax.set_title('Anti-Vortex\n(Topological Charge n = −1)', fontsize=13)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.plot(0, 0, 'w-', markersize=15, markeredgewidth=2)
    ax.plot(0, 0, 'wo', markersize=8, markeredgewidth=2, markerfacecolor='none')
    
    # Panel 3: Higher-order vortex (charge +3)
    phi3 = create_vortex(X, Y, 0, 0, charge=3)
    ax = axes[0, 2]
    ax.imshow(phase_to_rgb(phi3), extent=[-5, 5, -5, 5], origin='lower')
    ax.set_title('Higher-Order Vortex\n(Topological Charge n = +3)', fontsize=13)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.plot(0, 0, 'w+', markersize=15, markeredgewidth=2)
    
    # Panel 4: Vortex lattice (multiple vortices)
    phi4 = np.zeros_like(X)
    vortex_positions = [(-2, -2, 1), (2, -2, 1), (-2, 2, 1), (2, 2, 1), (0, 0, -2)]
    for x0, y0, q in vortex_positions:
        phi4 += create_vortex(X, Y, x0, y0, charge=q)
    ax = axes[1, 0]
    ax.imshow(phase_to_rgb(phi4), extent=[-5, 5, -5, 5], origin='lower')
    ax.set_title('Vortex Lattice\n(4×(+1) + 1×(−2), Total n = +2)', fontsize=13)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    for x0, y0, q in vortex_positions:
        marker = 'w+' if q > 0 else 'wo'
        ax.plot(x0, y0, marker, markersize=10, markeredgewidth=2,
                markerfacecolor='none' if q < 0 else 'white')
    
    # Panel 5: TPL Decomposition - smooth component
    # Harmonic component (smooth phase variation)
    phi_smooth = 0.5 * np.sin(2 * np.pi * X / 5) * np.cos(2 * np.pi * Y / 5) * np.pi
    ax = axes[1, 1]
    ax.imshow(phase_to_rgb(phi_smooth), extent=[-5, 5, -5, 5], origin='lower')
    ax.set_title('Smooth (Harmonic) Component\nφ_smooth — Scene Detail', fontsize=13)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    
    # Panel 6: Full TPL composition
    phi_noise = np.random.RandomState(42).uniform(-0.3, 0.3, X.shape) * np.pi
    phi_total = phi4 + phi_smooth + phi_noise
    ax = axes[1, 2]
    ax.imshow(phase_to_rgb(phi_total), extent=[-5, 5, -5, 5], origin='lower')
    ax.set_title('Full TPL Composition\nφ_topo + φ_smooth + φ_noise', fontsize=13)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    
    # Add colorbar for phase
    cbar_ax = fig.add_axes([0.92, 0.15, 0.02, 0.7])
    phase_cmap = plt.cm.hsv
    norm = plt.Normalize(0, 360)
    sm = plt.cm.ScalarMappable(cmap=phase_cmap, norm=norm)
    sm.set_array([])
    cbar = fig.colorbar(sm, cax=cbar_ax)
    cbar.set_label('Phase (degrees)', fontsize=12)
    
    plt.tight_layout(rect=[0, 0, 0.9, 0.95])
    plt.savefig('demos/output/phase_vortex_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Generated: demos/output/phase_vortex_lattice.png")

if __name__ == '__main__':
    main()
