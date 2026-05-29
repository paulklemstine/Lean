#!/usr/bin/env python3
"""
Visualization 2: Alexander Polynomial Roots in the Complex Plane

Shows the roots of Alexander polynomials for different knots,
plotted in the complex plane with the unit circle for reference.
Roots ON the unit circle correspond to OAM modes of knotted light.
The trefoil's roots are primitive 6th roots of unity (on the circle),
while the figure-eight's roots are real (off the circle).
"""
import numpy as np
import matplotlib.pyplot as plt


def find_roots(coeffs):
    """Find roots of polynomial given as [a_0, a_1, ..., a_d]."""
    if len(coeffs) <= 1:
        return np.array([])
    # numpy.roots expects highest-degree-first
    return np.roots(coeffs[::-1])


knots = {
    'Trefoil (3₁)': {
        'coeffs': [1, -1, 1],
        'color': '#E91E63',
        'marker': 'o',
    },
    'Figure-Eight (4₁)': {
        'coeffs': [-1, 3, -1],
        'color': '#FF9800',
        'marker': 's',
    },
    'Cinquefoil (5₁)': {
        'coeffs': [1, -1, 1, -1, 1],
        'color': '#4CAF50',
        'marker': '^',
    },
    'Three-Twist (5₂)': {
        'coeffs': [1, -3, 5, -3, 1],
        'color': '#9C27B0',
        'marker': 'D',
    },
}

fig, ax = plt.subplots(1, 1, figsize=(10, 10))

# Draw unit circle
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k--', alpha=0.3, linewidth=1.5,
        label='Unit circle')
ax.axhline(y=0, color='gray', linewidth=0.5, alpha=0.3)
ax.axvline(x=0, color='gray', linewidth=0.5, alpha=0.3)

for name, info in knots.items():
    roots = find_roots(info['coeffs'])
    ax.scatter(roots.real, roots.imag, c=info['color'], marker=info['marker'],
              s=150, zorder=5, label=name, edgecolors='black', linewidth=1)

    # Annotate with distance from unit circle
    for r in roots:
        dist = abs(abs(r) - 1)
        on_circle = "ON" if dist < 0.01 else f"off ({abs(r):.3f})"
        ax.annotate(f'{on_circle}',
                   xy=(r.real, r.imag),
                   xytext=(10, 10), textcoords='offset points',
                   fontsize=8, alpha=0.7)

ax.set_xlim(-2.2, 2.8)
ax.set_ylim(-1.8, 1.8)
ax.set_aspect('equal')
ax.set_xlabel('Re(z)', fontsize=13)
ax.set_ylabel('Im(z)', fontsize=13)
ax.set_title('Alexander Polynomial Roots in the Complex Plane\n'
            'Roots ON the unit circle = OAM modes of knotted light',
            fontsize=14, fontweight='bold')
ax.legend(loc='upper right', fontsize=11)
ax.grid(True, alpha=0.2)

# Add annotation box
textstr = ('Trefoil: roots = e^{±iπ/3} (on circle)\n'
          'Figure-8: roots = (3±√5)/2 (real, off circle)\n'
          'Cinquefoil: roots = e^{±2πik/10}, k=1,3 (on circle)')
props = dict(boxstyle='round', facecolor='wheat', alpha=0.8)
ax.text(0.02, 0.02, textstr, transform=ax.transAxes, fontsize=9,
        verticalalignment='bottom', bbox=props)

plt.savefig('viz_alexander_roots.png', dpi=150, bbox_inches='tight')
print("Saved viz_alexander_roots.png")
