"""
Visualization: Root Geometry of Lehmer's Polynomial

Illustrates the complex roots of Lehmer's polynomial relative to the unit circle,
showing which roots "escape" the unit disk and contribute to the Mahler measure.
The root escape pattern reveals the arithmetic-dynamical structure: roots outside
the circle produce entropy, roots inside are contracted, and roots on the circle
are neutral.

This visualization makes tangible why Lehmer's polynomial is special: it has the
minimal possible root escape among all non-cyclotomic monic integer polynomials
(conjectured), with exactly one real root barely outside the unit circle.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Lehmer's polynomial: x^10 + x^9 - x^7 - x^6 - x^5 - x^4 - x^3 + x + 1
LEHMER_COEFFS = [1, 1, 0, -1, -1, -1, -1, -1, 0, 1, 1]

def polynomial_roots(coeffs):
    return np.roots(list(reversed(coeffs)))

def log_mahler_measure(coeffs):
    roots = polynomial_roots(coeffs)
    lc = abs(coeffs[-1])
    M = lc * float(np.prod([max(1.0, abs(r)) for r in roots]))
    return float(np.log(M)) if M > 0 else 0.0

# Compute roots
roots = polynomial_roots(LEHMER_COEFFS)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# --- Panel 1: Roots in the complex plane ---
ax = axes[0]
theta = np.linspace(0, 2*np.pi, 200)
ax.fill(np.cos(theta), np.sin(theta), alpha=0.05, color='blue')
ax.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.4, linewidth=1.5, label='Unit circle S¹')

for r in roots:
    mod = abs(r)
    if mod > 1.001:
        color, label = '#d62728', 'Escaping (|z| > 1)'
    elif mod < 0.999:
        color, label = '#1f77b4', 'Contracting (|z| < 1)'
    else:
        color, label = '#2ca02c', 'Neutral (|z| ≈ 1)'
    ax.plot(r.real, r.imag, 'o', color=color, markersize=10, zorder=5,
            markeredgecolor='black', markeredgewidth=0.5)

# Legend with unique entries
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#d62728', markersize=10, label='Escaping (|z| > 1)'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#2ca02c', markersize=10, label='Neutral (|z| ≈ 1)'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#1f77b4', markersize=10, label='Contracting (|z| < 1)'),
    Line2D([0], [0], color='black', alpha=0.4, linewidth=1.5, label='Unit circle S¹'),
]
ax.legend(handles=legend_elements, loc='upper left', fontsize=8)
ax.set_xlabel('Re(z)', fontsize=11)
ax.set_ylabel('Im(z)', fontsize=11)
ax.set_title("Roots of Lehmer's Polynomial in ℂ", fontsize=12, fontweight='bold')
ax.set_aspect('equal')
ax.grid(True, alpha=0.2)
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)

# --- Panel 2: Root moduli bar chart ---
ax = axes[1]
moduli = sorted([abs(r) for r in roots], reverse=True)
colors = ['#d62728' if m > 1.001 else ('#1f77b4' if m < 0.999 else '#2ca02c') for m in moduli]
bars = ax.bar(range(len(moduli)), moduli, color=colors, alpha=0.8, edgecolor='black', linewidth=0.5)
ax.axhline(y=1.0, color='black', linestyle='--', alpha=0.5, linewidth=1.5, label='|z| = 1')
ax.set_xlabel('Root index (sorted by modulus)', fontsize=11)
ax.set_ylabel('|z|', fontsize=11)
ax.set_title('Root Moduli: The Unit Circle Barrier', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.2, axis='y')

# Annotate the Salem number
ax.annotate(f'τ ≈ {moduli[0]:.6f}', xy=(0, moduli[0]), xytext=(1.5, moduli[0]+0.08),
            arrowprops=dict(arrowstyle='->', color='red'), fontsize=9, color='red')

# --- Panel 3: Escape mass contributions ---
ax = axes[2]
contributions = [max(0, np.log(m)) for m in moduli]
colors2 = ['#d62728' if c > 0.001 else '#cccccc' for c in contributions]
ax.bar(range(len(contributions)), contributions, color=colors2, alpha=0.8,
       edgecolor='black', linewidth=0.5)
ax.set_xlabel('Root index (sorted by modulus)', fontsize=11)
ax.set_ylabel('max(0, log|z|)', fontsize=11)
ax.set_title('Root Escape Mass Contributions', fontsize=12, fontweight='bold')
ax.grid(True, alpha=0.2, axis='y')

total_mass = sum(contributions)
ax.annotate(f'Total escape mass\n= m(L) ≈ {total_mass:.6f}',
            xy=(0, contributions[0]), xytext=(3, contributions[0]*0.8),
            arrowprops=dict(arrowstyle='->', color='darkred'),
            fontsize=9, color='darkred', fontweight='bold')

plt.suptitle("Root Geometry of Lehmer's Polynomial — The Smallest Known Entropy Gap",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_root_geometry.png', dpi=150, bbox_inches='tight')
print("Saved viz_root_geometry.png")
