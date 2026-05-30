"""
Visualization 2: Spectral Decomposition and Eigenspaces

Shows the spectral decomposition theorem: every element decomposes into
symmetric (+1) and antisymmetric (-1) eigenspace components under an involution.
Illustrates the Tate norm-difference exact sequence.
"""
import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# ============================================================
# Panel 1: Spectral Decomposition
# ============================================================
ax1 = axes[0]

# For phi(x) = -x, symmetric part = 0, antisymmetric part = x
# For phi(x) = x, symmetric part = x, antisymmetric part = 0
# For a general involution on R^2, phi(x,y) = (y,x):
#   symmetric part = ((x+y)/2, (x+y)/2)
#   antisymmetric part = ((x-y)/2, -(x-y)/2)

# Visualize decomposition of various elements under phi(x) = -x
elements = np.linspace(-3, 3, 15)
for g in elements:
    s = 0  # (g + (-g))/2 = 0
    a = g  # (g - (-g))/2 = g
    # Plot original as a point
    ax1.plot(g, 0, 'ko', markersize=4)
    # Plot decomposition
    ax1.annotate('', xy=(s, a), xytext=(g, 0),
                arrowprops=dict(arrowstyle='->', color='steelblue', lw=0.8, alpha=0.5))

# Under identity: s = g, a = 0
for g in elements:
    ax1.plot(g, 0, 'ko', markersize=4)

ax1.axhline(y=0, color='green', linestyle='-', linewidth=2, alpha=0.5, label='+1 eigenspace')
ax1.axvline(x=0, color='red', linestyle='-', linewidth=2, alpha=0.5, label='-1 eigenspace')

ax1.set_xlabel('Symmetric component (s)', fontsize=12)
ax1.set_ylabel('Antisymmetric component (a)', fontsize=12)
ax1.set_title('Spectral Decomposition\n$g = s + a$, $\\phi(s) = s$, $\\phi(a) = -a$', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_xlim(-4, 4)
ax1.set_ylim(-4, 4)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.2)

# ============================================================
# Panel 2: Tate Norm and Difference Map
# ============================================================
ax2 = axes[1]

t_vals = np.linspace(-3, 3, 100)

# For phi(x) = -x:
# N(g) = g + phi(g) = g - g = 0 (kills everything)
# D(g) = g - phi(g) = g + g = 2g (doubles)
N_neg = np.zeros_like(t_vals)
D_neg = 2 * t_vals

ax2.plot(t_vals, t_vals, 'k--', linewidth=0.5, alpha=0.3, label='$g$ (input)')
ax2.plot(t_vals, N_neg, 'b-', linewidth=2, label='$N(g) = g + \\phi(g) = 0$')
ax2.plot(t_vals, D_neg, 'r-', linewidth=2, label='$D(g) = g - \\phi(g) = 2g$')

ax2.set_xlabel('$g$', fontsize=12)
ax2.set_ylabel('Output', fontsize=12)
ax2.set_title('Tate Norm & Difference Map\n$\\phi(x) = -x$ (negation)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.2)

# ============================================================
# Panel 3: Fixed Points in Z/nZ
# ============================================================
ax3 = axes[2]

ns = range(2, 21)
fixed_counts = []
for n in ns:
    count = sum(1 for x in range(n) if (-x) % n == x)
    fixed_counts.append(count)

colors = ['red' if n % 2 == 0 else 'steelblue' for n in ns]
bars = ax3.bar(list(ns), fixed_counts, color=colors, alpha=0.7, edgecolor='black', linewidth=0.5)

# Add legend
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor='steelblue', alpha=0.7, label='Odd $n$: $|\\mathrm{Fix}| = 1$'),
                   Patch(facecolor='red', alpha=0.7, label='Even $n$: $|\\mathrm{Fix}| = 2$')]
ax3.legend(handles=legend_elements, fontsize=10)

ax3.set_xlabel('$n$', fontsize=12)
ax3.set_ylabel('$|\\{x \\in \\mathbb{Z}/n\\mathbb{Z} : -x = x\\}|$', fontsize=12)
ax3.set_title('Fixed Points of Negation\nin $\\mathbb{Z}/n\\mathbb{Z}$', fontsize=13)
ax3.set_xticks(list(ns))
ax3.grid(True, alpha=0.2, axis='y')

plt.tight_layout()
plt.savefig('eigenspaces_and_fixed_points.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: eigenspaces_and_fixed_points.png")
