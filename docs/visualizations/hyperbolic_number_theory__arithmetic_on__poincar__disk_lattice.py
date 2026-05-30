"""
Visualization 1: Hyperbolic Lattice on the Poincaré Disk
=========================================================
Visualizes the {7,3} tessellation lattice points on the Poincaré disk,
color-coded by generation (BFS depth). Shows the exponential growth of
lattice points and the boundary accumulation characteristic of hyperbolic geometry.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def moebius_map(a, z):
    """Möbius automorphism φ_a(z) = (z - a) / (1 - conj(a) * z)."""
    return (z - a) / (1 - np.conj(a) * z)


def generate_lattice(p=7, q=3, depth=4):
    """Generate {p,q} tessellation lattice points with BFS metadata."""
    d = np.arccosh(np.cos(np.pi/q) / np.sin(np.pi/p))
    r = np.tanh(d / 2)
    
    generators = [r * np.exp(2j * np.pi * k / p) for k in range(p)]
    
    points = [(0+0j, 0)]  # (point, generation)
    point_set = {(0.0, 0.0)}
    queue = [0+0j]
    
    for gen in range(1, depth + 1):
        new_queue = []
        for center in queue:
            for g in generators:
                try:
                    new_pt = moebius_map(-center, g)
                    key = (round(new_pt.real, 7), round(new_pt.imag, 7))
                    if key not in point_set and abs(new_pt) < 0.999:
                        point_set.add(key)
                        points.append((new_pt, gen))
                        new_queue.append(new_pt)
                except:
                    continue
        queue = new_queue
    
    return points


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7.5))
    
    # ── Left panel: Lattice points on disk ──
    ax = axes[0]
    lattice = generate_lattice(7, 3, depth=4)
    
    # Draw unit circle
    theta = np.linspace(0, 2*np.pi, 200)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
    
    # Color by generation
    colors = ['#e63946', '#457b9d', '#2a9d8f', '#e9c46a', '#f4a261']
    gen_labels = ['Origin', 'Gen 1', 'Gen 2', 'Gen 3', 'Gen 4']
    
    for gen in range(5):
        pts = [p for p, g in lattice if g == gen]
        if pts:
            xs = [p.real for p in pts]
            ys = [p.imag for p in pts]
            size = max(80 - gen * 15, 10)
            ax.scatter(xs, ys, c=colors[gen], s=size, alpha=0.8,
                      edgecolors='black', linewidth=0.5, zorder=5-gen,
                      label=f'{gen_labels[gen]} ({len(pts)} pts)')
    
    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.set_title('Hyperbolic Lattice {7,3} on Poincaré Disk', fontsize=14, fontweight='bold')
    ax.legend(loc='upper right', fontsize=9)
    ax.grid(True, alpha=0.2)
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')
    
    # ── Right panel: Growth curves ──
    ax2 = axes[1]
    
    # Count by hyperbolic distance
    def hyp_dist_from_origin(z):
        r = abs(z)
        if r >= 1: return float('inf')
        return np.log((1 + r) / (1 - r))
    
    all_dists = sorted([hyp_dist_from_origin(p) for p, _ in lattice])
    
    Rs = np.linspace(0.1, max(all_dists) * 0.95, 200)
    counts = [sum(1 for d in all_dists if d <= R) for R in Rs]
    
    ax2.plot(Rs, counts, 'b-', linewidth=2, label='N(R) (lattice count)')
    
    # Theoretical hyperbolic area curve (scaled)
    hyp_areas = [4 * np.pi * np.sinh(R/2)**2 for R in Rs]
    scale = max(counts) / max(hyp_areas) if max(hyp_areas) > 0 else 1
    ax2.plot(Rs, [a * scale for a in hyp_areas], 'r--', linewidth=1.5,
             label=f'Scaled hyp. area 4π sinh²(R/2)')
    
    # Euclidean comparison
    euc_areas = [np.pi * R**2 for R in Rs]
    scale_e = max(counts) / max(euc_areas) if max(euc_areas) > 0 else 1
    ax2.plot(Rs, [a * scale_e for a in euc_areas], 'g:', linewidth=1.5,
             label='Scaled Euclidean πR²')
    
    ax2.set_xlabel('Hyperbolic radius R', fontsize=12)
    ax2.set_ylabel('Count / Scaled area', fontsize=12)
    ax2.set_title('Exponential Growth of Lattice Points', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('viz_poincare_lattice.png', dpi=150, bbox_inches='tight')
    print("Saved viz_poincare_lattice.png")


if __name__ == "__main__":
    main()
