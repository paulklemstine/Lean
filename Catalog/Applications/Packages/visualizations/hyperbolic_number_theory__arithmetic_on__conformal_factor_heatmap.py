"""
Visualization 2: Poincaré Disk Conformal Factor Heatmap
========================================================
Shows the conformal factor λ(z) = 2/(1-|z|²) as a heatmap on the disk.
Demonstrates how distances are stretched near the boundary — the key feature
that makes hyperbolic geometry "infinite" inside a finite disk.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    # ── Left panel: Conformal factor heatmap ──
    ax = axes[0]
    
    n = 500
    x = np.linspace(-1, 1, n)
    y = np.linspace(-1, 1, n)
    X, Y = np.meshgrid(x, y)
    R = np.sqrt(X**2 + Y**2)
    
    # Conformal factor: λ = 2/(1 - r²)
    with np.errstate(divide='ignore', invalid='ignore'):
        lam = np.where(R < 0.999, 2.0 / (1 - R**2), np.nan)
    
    # Mask outside disk
    lam[R >= 0.999] = np.nan
    
    im = ax.imshow(lam, extent=[-1, 1, -1, 1], origin='lower',
                   cmap='inferno', norm=LogNorm(vmin=2, vmax=1000),
                   interpolation='bilinear')
    
    # Draw unit circle
    theta = np.linspace(0, 2*np.pi, 200)
    ax.plot(np.cos(theta), np.sin(theta), 'w-', linewidth=2)
    
    # Draw concentric hyperbolic circles (equal hyp distance)
    for d_hyp in [1, 2, 3, 4]:
        r_euc = np.tanh(d_hyp / 2)
        ax.plot(r_euc * np.cos(theta), r_euc * np.sin(theta),
                'w--', linewidth=0.8, alpha=0.6)
        ax.text(r_euc + 0.02, 0.02, f'd={d_hyp}', color='white',
                fontsize=8, alpha=0.8)
    
    plt.colorbar(im, ax=ax, label='Conformal factor λ(z) = 2/(1-|z|²)', shrink=0.8)
    ax.set_title('Poincaré Metric Conformal Factor', fontsize=14, fontweight='bold')
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')
    ax.set_aspect('equal')
    
    # ── Right panel: Radial profile ──
    ax2 = axes[1]
    
    r_vals = np.linspace(0, 0.999, 1000)
    lam_vals = 2.0 / (1 - r_vals**2)
    
    ax2.semilogy(r_vals, lam_vals, 'b-', linewidth=2, label='λ(r) = 2/(1-r²)')
    
    # Show 1/ε bound (proved in Lean)
    eps_vals = 1 - r_vals
    bound_vals = 1.0 / eps_vals
    ax2.semilogy(r_vals, bound_vals, 'r--', linewidth=1.5,
                 label='Lower bound 1/(1-r)', alpha=0.7)
    
    # Mark key points
    for r in [0.5, 0.9, 0.99]:
        lam_r = 2.0 / (1 - r**2)
        ax2.plot(r, lam_r, 'ko', markersize=6)
        ax2.annotate(f'r={r}\nλ={lam_r:.1f}', xy=(r, lam_r),
                    xytext=(r-0.15, lam_r*2),
                    fontsize=9, ha='center',
                    arrowprops=dict(arrowstyle='->', color='gray'))
    
    ax2.set_xlabel('Euclidean distance from origin |z|', fontsize=12)
    ax2.set_ylabel('Conformal factor λ(z)', fontsize=12)
    ax2.set_title('Boundary Divergence\n(Theorem poincareConformalFactor_large)',
                  fontsize=13, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(0, 1.01)
    ax2.set_ylim(1, 5000)
    
    plt.tight_layout()
    plt.savefig('viz_conformal_factor.png', dpi=150, bbox_inches='tight')
    print("Saved viz_conformal_factor.png")


if __name__ == "__main__":
    main()
