"""
Demo 3: Quantum Laser Mode Visualization
=========================================
Visualizes the orbital angular momentum (OAM) modes that the proposed
Topological Cascade Laser would produce. Shows Laguerre-Gaussian beam
profiles and their phase structures.

Generates: output/quantum_laser_modes.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from scipy.special import genlaguerre

def laguerre_gaussian(X, Y, l, p, w0=1.0, wavelength=0.633e-6, z=0):
    """
    Generate a Laguerre-Gaussian beam profile LG_pl.
    l: azimuthal index (OAM quantum number / topological charge)
    p: radial index
    w0: beam waist
    """
    R = np.sqrt(X**2 + Y**2)
    PHI = np.arctan2(Y, X)
    
    # Normalized radial coordinate
    rho = np.sqrt(2) * R / w0
    
    # Laguerre polynomial
    L = genlaguerre(p, abs(l))
    
    # Amplitude
    amplitude = (rho**abs(l)) * L(rho**2) * np.exp(-rho**2 / 2)
    
    # Phase (azimuthal)
    phase = l * PHI
    
    # Complex field
    field = amplitude * np.exp(1j * phase)
    
    return field

def main():
    N = 300
    x = np.linspace(-3, 3, N)
    y = np.linspace(-3, 3, N)
    X, Y = np.meshgrid(x, y)
    
    # Define modes to show: (l, p) pairs
    modes = [
        (0, 0), (1, 0), (2, 0), (3, 0),
        (0, 1), (1, 1), (-1, 0), (-2, 0)
    ]
    
    fig, axes = plt.subplots(4, 4, figsize=(18, 18))
    fig.suptitle('Topological Cascade Laser: Laguerre-Gaussian OAM Modes\n'
                 'Intensity (left) and Phase (right) for each mode',
                 fontsize=18, fontweight='bold', y=0.98)
    
    for i, (l, p) in enumerate(modes):
        row = i // 2
        col_base = (i % 2) * 2
        
        field = laguerre_gaussian(X, Y, l, p, w0=1.0)
        intensity = np.abs(field)**2
        phase = np.angle(field)
        
        # Intensity plot
        ax_int = axes[row, col_base]
        im = ax_int.imshow(intensity / intensity.max(), cmap='inferno',
                           extent=[-3, 3, -3, 3], origin='lower')
        ax_int.set_title(f'LG({l},{p}) Intensity\nOAM = {l}ℏ', fontsize=11)
        ax_int.set_xlabel('x/w₀')
        ax_int.set_ylabel('y/w₀')
        
        # Phase plot
        ax_ph = axes[row, col_base + 1]
        # Mask phase where intensity is very low
        phase_masked = np.where(intensity / intensity.max() > 0.01, phase, np.nan)
        ax_ph.imshow(phase_masked, cmap='hsv', extent=[-3, 3, -3, 3],
                     origin='lower', vmin=-np.pi, vmax=np.pi)
        ax_ph.set_title(f'LG({l},{p}) Phase\nTopological charge = {l}', fontsize=11)
        ax_ph.set_xlabel('x/w₀')
        ax_ph.set_ylabel('y/w₀')
    
    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig('demos/output/quantum_laser_modes.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Generated: demos/output/quantum_laser_modes.png")
    
    # === Second figure: Superposition and interference ===
    fig2, axes2 = plt.subplots(2, 3, figsize=(18, 12))
    fig2.suptitle('OAM Mode Superpositions for Holographic Channels',
                  fontsize=18, fontweight='bold')
    
    superpositions = [
        ('LG(1,0) + LG(-1,0)', [(1, 0, 1.0), (-1, 0, 1.0)]),
        ('LG(2,0) + LG(-2,0)', [(2, 0, 1.0), (-2, 0, 1.0)]),
        ('LG(0,0) + LG(3,0)', [(0, 0, 1.0), (3, 0, 0.7)]),
        ('LG(1,0) + LG(2,0) + LG(3,0)', [(1, 0, 1.0), (2, 0, 0.8), (3, 0, 0.6)]),
        ('7-Channel TCL Output\n(l = -3 to +3)', 
         [(l, 0, 1.0 / (1 + abs(l))) for l in range(-3, 4)]),
        ('Holographic Petal Pattern\nLG(4,0) + LG(-4,0) + LG(0,0)',
         [(4, 0, 1.0), (-4, 0, 1.0), (0, 0, 0.5)]),
    ]
    
    for idx, (title, components) in enumerate(superpositions):
        row, col = idx // 3, idx % 3
        
        field = np.zeros((N, N), dtype=complex)
        for l, p, amp in components:
            field += amp * laguerre_gaussian(X, Y, l, p, w0=1.0)
        
        intensity = np.abs(field)**2
        ax = axes2[row, col]
        ax.imshow(intensity / intensity.max(), cmap='inferno',
                  extent=[-3, 3, -3, 3], origin='lower')
        ax.set_title(title, fontsize=12)
        ax.set_xlabel('x/w₀')
        ax.set_ylabel('y/w₀')
    
    plt.tight_layout()
    plt.savefig('demos/output/oam_superpositions.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Generated: demos/output/oam_superpositions.png")

if __name__ == '__main__':
    main()
