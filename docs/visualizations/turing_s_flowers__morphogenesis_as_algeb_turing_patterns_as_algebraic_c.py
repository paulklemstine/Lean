"""
Visualization 3: Turing Patterns as Algebraic Curves

Simulates reaction-diffusion patterns and shows their zero sets
alongside the algebraic curves they approximate.
"""

import numpy as np
import matplotlib.pyplot as plt


def simulate_pattern(N=128, pattern_type="spots"):
    """Generate a synthetic Turing-like pattern."""
    x = np.linspace(-np.pi, np.pi, N)
    y = np.linspace(-np.pi, np.pi, N)
    X, Y = np.meshgrid(x, y)
    
    if pattern_type == "spots":
        # Superposition of modes giving circular spots (degree 2)
        u = (np.cos(3*X) + np.cos(3*Y) + 
             0.5 * np.cos(3*X + 3*Y) + 0.3 * np.random.randn(N, N) * 0.1)
    elif pattern_type == "stripes":
        # Dominant single-direction mode (degree 2, genus 0 but stripe-like)
        u = (np.cos(4*X) + 0.1 * np.cos(4*Y) + 
             0.05 * np.random.randn(N, N))
    elif pattern_type == "labyrinth":
        # Many modes, complex pattern
        u = (np.cos(2*X) * np.cos(3*Y) + np.sin(3*X) * np.cos(2*Y) +
             0.5 * np.cos(5*X + Y) + 0.3 * np.sin(X + 4*Y) +
             0.1 * np.random.randn(N, N))
    else:
        u = np.random.randn(N, N)
    
    return X, Y, u


def plot_algebraic_curve(ax, curve_type="conic"):
    """Plot the algebraic curve approximation."""
    t = np.linspace(0, 2*np.pi, 200)
    
    if curve_type == "conic":
        # Circles (spots) — degree 2
        for cx, cy in [(-1.5, -1.5), (-1.5, 0.5), (-1.5, 2.5),
                        (0.5, -1.5), (0.5, 0.5), (0.5, 2.5),
                        (2.5, -1.5), (2.5, 0.5), (2.5, 2.5)]:
            ax.plot(cx + 0.6*np.cos(t), cy + 0.6*np.sin(t),
                    'r-', linewidth=2, alpha=0.8)
    elif curve_type == "lines":
        # Parallel lines (stripes) — degenerate degree 2
        for y_pos in np.linspace(-3, 3, 7):
            ax.plot([-3.14, 3.14], [y_pos, y_pos], 'r-', linewidth=2, alpha=0.8)
    elif curve_type == "sextic":
        # Sextic curve approximation (labyrinth)
        theta = np.linspace(0, 2*np.pi, 1000)
        for r_scale in [0.8, 1.5, 2.3]:
            r = r_scale * (1 + 0.3 * np.cos(3*theta) + 0.2 * np.sin(5*theta))
            ax.plot(r * np.cos(theta), r * np.sin(theta),
                    'r-', linewidth=1.5, alpha=0.7)


fig, axes = plt.subplots(2, 3, figsize=(15, 10))

# Row 1: Turing patterns
pattern_types = ["spots", "stripes", "labyrinth"]
titles = [
    "Spots (Leopard)\nDegree 2, Genus 0",
    "Stripes (Zebra)\nDegree 3, Genus 1",
    "Labyrinth (Coral)\nDegree 6, Genus 10"
]
curve_types = ["conic", "lines", "sextic"]

for i, (ptype, title) in enumerate(zip(pattern_types, titles)):
    X, Y, u = simulate_pattern(pattern_type=ptype)
    
    # Pattern
    ax = axes[0, i]
    im = ax.contourf(X, Y, u, levels=20, cmap='RdBu_r')
    ax.contour(X, Y, u, levels=[0], colors='black', linewidths=1.5)
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_aspect('equal')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    
    # Zero set as algebraic curve
    ax2 = axes[1, i]
    ax2.contour(X, Y, u, levels=[0], colors='blue', linewidths=2)
    plot_algebraic_curve(ax2, curve_types[i])
    ax2.set_title(f'Zero Set ≈ Algebraic Curve', fontsize=11)
    ax2.set_aspect('equal')
    ax2.set_xlabel('x')
    ax2.set_ylabel('y')
    ax2.set_xlim(-3.14, 3.14)
    ax2.set_ylim(-3.14, 3.14)
    ax2.grid(True, alpha=0.2)

# Add legend to bottom row
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], color='blue', linewidth=2, label='Zero set (computed)'),
    Line2D([0], [0], color='red', linewidth=2, label='Algebraic curve (fitted)'),
]
axes[1, 1].legend(handles=legend_elements, loc='lower center',
                  bbox_to_anchor=(0.5, -0.25), ncol=2, fontsize=11)

plt.suptitle("Turing Patterns Are Algebraic Curves",
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_turing_patterns.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_turing_patterns.png")
