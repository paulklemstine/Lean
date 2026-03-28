"""
Demo 5: Holographic Projector System Diagram & Wave Propagation
===============================================================
Visualizes the TPL-Holo projector architecture and simulates
multi-channel wavefront propagation for volumetric reconstruction.

Generates: output/holographic_projector_system.png
           output/volumetric_propagation.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
from numpy.fft import fft2, ifft2, fftshift, ifftshift

def draw_system_diagram():
    """Draw the TPL-Holo system architecture."""
    fig, ax = plt.subplots(1, 1, figsize=(20, 12))
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 12)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Title
    ax.text(10, 11.5, 'TPL-Holo: Topological Phase Lattice Holographic Projector',
            fontsize=20, fontweight='bold', ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#2c3e50', edgecolor='none'),
            color='white')
    
    # Module colors
    colors = {
        'source': '#e74c3c',
        'compute': '#3498db',
        'modulator': '#2ecc71',
        'output': '#9b59b6',
        'monitor': '#f39c12'
    }
    
    def draw_module(x, y, w, h, title, details, color):
        rect = FancyBboxPatch((x, y), w, h,
                               boxstyle="round,pad=0.1",
                               facecolor=color, edgecolor='#2c3e50',
                               linewidth=2, alpha=0.85)
        ax.add_patch(rect)
        ax.text(x + w/2, y + h - 0.3, title,
                fontsize=11, fontweight='bold', ha='center', va='top', color='white')
        for i, detail in enumerate(details):
            ax.text(x + w/2, y + h - 0.7 - i*0.35, detail,
                    fontsize=8, ha='center', va='top', color='white', alpha=0.9)
    
    # === Draw modules ===
    
    # Quantum Source Module
    draw_module(0.5, 7, 4, 3.5, '🔴🟢🔵 Quantum Light Source',
                ['Topological Cascade Laser (TCL)',
                 'RGB: 635nm / 532nm / 450nm',
                 'OAM modes: l = -3 to +3',
                 '21 channels × 100mW each',
                 'Coherence length > 10m',
                 'Total power: 2.1W'],
                colors['source'])
    
    # TPL Phase Computer
    draw_module(5.5, 7, 4, 3.5, '💻 TPL Phase Computer',
                ['Custom FPGA/ASIC',
                 'TPL Decomposition (Thm 2.3)',
                 'φ = φ_topo + φ_smooth + φ_noise',
                 'O(N log N) computation',
                 'Input: 3D scene (mesh/point cloud)',
                 '120 Hz refresh rate'],
                colors['compute'])
    
    # Meta-SLM
    draw_module(10.5, 7, 4, 3.5, '🔲 Meta-SLM Array',
                ['Metasurface Spatial Light Mod.',
                 'TiO₂ nanopillar pixels',
                 '500nm pixel pitch (sub-λ)',
                 '8K × 8K = 64 Megapixels',
                 '8-bit phase + amplitude',
                 'Switching: < 1ms (LCoS)'],
                colors['modulator'])
    
    # Holographic Volume
    draw_module(15.5, 7, 4, 3.5, '✨ Holographic Volume',
                ['Volumetric reconstruction',
                 '30cm × 30cm × 30cm',
                 'Viewing cone: ±60°',
                 'Continuous depth',
                 'Resolution: 8K equivalent',
                 'Simultaneous full color'],
                colors['output'])
    
    # Bottom row: support systems
    draw_module(1.5, 2, 3.5, 3, '📊 Coherence Monitor',
                ['Real-time coherence tracking',
                 'Photon counting detectors',
                 'Quantum state tomography',
                 'Feedback to source',
                 'Error rate < 10⁻⁶'],
                colors['monitor'])
    
    draw_module(6, 2, 3.5, 3, '🔄 Topology Optimizer',
                ['Phase Entropy maximization',
                 'Gradient descent on S[φ]',
                 'Topological charge constraints',
                 'Real-time adaptive correction',
                 'Theorem 3.1 bound check'],
                colors['compute'])
    
    draw_module(10.5, 2, 3.5, 3, '🎯 Scene Engine',
                ['3D scene capture/generation',
                 'Point cloud processing',
                 'Depth map computation',
                 'Motion prediction (120 Hz)',
                 'Hand/eye tracking input'],
                colors['modulator'])
    
    draw_module(15, 2, 4.5, 3, '📈 Performance Specs',
                ['Resolution: 8K equivalent',
                 'Color: Simultaneous RGB',
                 'Depth: Continuous volume',
                 'View angle: ±60°',
                 'Frame rate: 120 Hz',
                 'Fidelity: 40+ dB PSNR'],
                colors['output'])
    
    # === Arrows ===
    arrow_style = dict(arrowstyle='->', color='#2c3e50', lw=2.5,
                       connectionstyle='arc3,rad=0')
    
    # Main flow
    ax.annotate('', xy=(5.5, 8.75), xytext=(4.5, 8.75), arrowprops=arrow_style)
    ax.annotate('', xy=(10.5, 8.75), xytext=(9.5, 8.75), arrowprops=arrow_style)
    ax.annotate('', xy=(15.5, 8.75), xytext=(14.5, 8.75), arrowprops=arrow_style)
    
    # Vertical connections
    ax.annotate('', xy=(2.5, 7), xytext=(3.25, 5), arrowprops=dict(
        arrowstyle='->', color='#f39c12', lw=1.5, connectionstyle='arc3,rad=0.3'))
    ax.annotate('', xy=(7.5, 7), xytext=(7.75, 5), arrowprops=dict(
        arrowstyle='->', color='#3498db', lw=1.5, connectionstyle='arc3,rad=0'))
    ax.annotate('', xy=(12, 7), xytext=(12.25, 5), arrowprops=dict(
        arrowstyle='->', color='#2ecc71', lw=1.5, connectionstyle='arc3,rad=0'))
    
    # Flow labels
    ax.text(5, 9.3, 'OAM\nbeams', fontsize=8, ha='center', style='italic', color='#e74c3c')
    ax.text(10, 9.3, 'Phase\npatterns', fontsize=8, ha='center', style='italic', color='#3498db')
    ax.text(15, 9.3, 'Shaped\nwavefronts', fontsize=8, ha='center', style='italic', color='#2ecc71')
    
    plt.savefig('demos/output/holographic_projector_system.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Generated: demos/output/holographic_projector_system.png")

def simulate_volumetric_propagation():
    """Simulate multi-channel wavefront propagation for volumetric holography."""
    N = 256
    x = np.linspace(-5, 5, N)
    y = np.linspace(-5, 5, N)
    X, Y = np.meshgrid(x, y)
    R = np.sqrt(X**2 + Y**2)
    
    # Simulate propagation at different z-planes
    z_planes = [0.5, 1.0, 2.0, 3.0, 5.0, 8.0]
    wavelength = 0.532  # green, in μm
    k = 2 * np.pi / wavelength
    
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))
    fig.suptitle('Volumetric Holographic Reconstruction: Multi-Plane Propagation\n'
                 'Showing interference pattern at different z-distances from SLM',
                 fontsize=16, fontweight='bold')
    
    # Create a holographic phase pattern (simulating a 3D point cloud)
    # Target: two point sources at different depths
    points = [
        (0, 0, 2.0, 1.0),      # (x, y, z, amplitude) - center, near
        (-2, 1, 5.0, 0.8),     # off-center, far
        (1.5, -1.5, 3.0, 0.7), # off-center, medium
        (0, 2, 8.0, 0.5),      # top, very far
    ]
    
    for idx, z in enumerate(z_planes):
        row, col = idx // 3, idx % 3
        
        # Compute field at this z-plane from all point sources
        field = np.zeros((N, N), dtype=complex)
        for px, py, pz, amp in points:
            r = np.sqrt((X - px)**2 + (Y - py)**2 + (z - pz)**2)
            # Spherical wave from point source
            field += amp * np.exp(1j * k * r) / (r + 0.1)
        
        # Add OAM channel structure
        for l in range(-2, 3):
            oam_phase = l * np.arctan2(Y, X)
            channel_amp = np.exp(-R**2 / 10) * 0.1
            field += channel_amp * np.exp(1j * (oam_phase + k * z))
        
        intensity = np.abs(field)**2
        intensity = intensity / intensity.max()
        
        ax = axes[row, col]
        im = ax.imshow(intensity, cmap='hot', extent=[-5, 5, -5, 5],
                       origin='lower', vmin=0, vmax=1)
        ax.set_title(f'z = {z:.1f} mm\n({"near" if z < 2 else "mid" if z < 5 else "far"} field)',
                     fontsize=12)
        ax.set_xlabel('x (mm)')
        ax.set_ylabel('y (mm)')
        
        # Mark expected point positions if they're near this z
        for px, py, pz, amp in points:
            if abs(z - pz) < 1.0:
                ax.plot(px, py, 'c+', markersize=15, markeredgewidth=2)
                ax.annotate(f'z₀={pz}', (px + 0.3, py + 0.3),
                           color='cyan', fontsize=9)
    
    plt.colorbar(im, ax=axes.ravel().tolist(), label='Normalized Intensity',
                 shrink=0.6)
    plt.tight_layout()
    plt.savefig('demos/output/volumetric_propagation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Generated: demos/output/volumetric_propagation.png")

def main():
    draw_system_diagram()
    simulate_volumetric_propagation()

if __name__ == '__main__':
    main()
