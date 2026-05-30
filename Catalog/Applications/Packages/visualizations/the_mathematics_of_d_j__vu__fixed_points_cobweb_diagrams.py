"""
Visualization 2: Cobweb Diagrams — Periodic Orbits as Déjà Vu

Shows cobweb (staircase) diagrams for the logistic map at three parameter
values: r=2.8 (fixed point), r=3.2 (period-2), and r=3.83 (period-3).
The cobweb diagram makes visible how iteration "bounces" between the
curve y=f(x) and the line y=x, revealing the periodic structure.
Fixed points appear as single intersections, period-2 as rectangles,
and period-3 as triangles. These are the "shapes of déjà vu."
"""

import numpy as np
import matplotlib.pyplot as plt

def logistic(r, x):
    return r * x * (1.0 - x)

def cobweb(ax, r, x0=0.5, n_iter=80, n_transient=200, title=""):
    """Draw a cobweb diagram for the logistic map at parameter r."""
    x = np.linspace(0, 1, 500)
    y = r * x * (1.0 - x)

    ax.plot(x, y, 'b-', linewidth=1.5, label=f'f(x) = {r}x(1-x)')
    ax.plot(x, x, 'k--', linewidth=0.8, alpha=0.5, label='y = x')

    # Skip transient
    xn = x0
    for _ in range(n_transient):
        xn = logistic(r, xn)

    # Draw cobweb
    for _ in range(n_iter):
        xn1 = logistic(r, xn)
        ax.plot([xn, xn], [xn, xn1], 'r-', linewidth=0.6, alpha=0.7)
        ax.plot([xn, xn1], [xn1, xn1], 'r-', linewidth=0.6, alpha=0.7)
        xn = xn1

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_title(title, fontsize=11, fontweight='bold')
    ax.set_xlabel('Current state x_n')
    ax.set_ylabel('Next state x_{n+1}')
    ax.legend(fontsize=8, loc='upper left')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

cobweb(axes[0], r=2.8, title='Fixed Point (r=2.8)\nSingle Déjà Vu State')
cobweb(axes[1], r=3.2, title='Period-2 (r=3.2)\nAlternating Déjà Vu')
cobweb(axes[2], r=3.8284, title='Period-3 (r≈3.83)\nTriple Déjà Vu → Chaos')

fig.suptitle('The Shapes of Déjà Vu: Cobweb Diagrams of Cognitive Orbits',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('cobweb_orbits.png', dpi=200, bbox_inches='tight')
print("Saved cobweb_orbits.png")
