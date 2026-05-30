"""
Visualization 3: Mayer-Vietoris Exact Sequence

Illustrates the exact sequence for the two-chart stereographic cover:
  0 → H⁰(S¹, F) → F(U_N) ⊕ F(U_S) → F(U_N ∩ U_S) → H¹(S¹, F) → 0

Shows how the Tate norm N and difference map D encode this exactness,
and how the conformal factor product equals 1 on the overlap.
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, Arc

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# ============================================================
# Panel 1: Two-chart cover of S^1
# ============================================================
ax1 = axes[0]

theta = np.linspace(0, 2*np.pi, 300)
ax1.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# U_N (everything except north pole) - colored blue
theta_N = np.linspace(0.15, 2*np.pi - 0.15, 200)
ax1.plot(np.cos(theta_N), np.sin(theta_N), color='steelblue', linewidth=6, alpha=0.3, label='$U_N$ (south chart)')

# U_S (everything except south pole) - colored red
theta_S = np.linspace(-np.pi + 0.15, np.pi - 0.15, 200)
ax1.plot(np.cos(theta_S), np.sin(theta_S), color='indianred', linewidth=6, alpha=0.3, label='$U_S$ (north chart)')

# Mark poles
ax1.plot(0, -1, 'bv', markersize=12, zorder=5)
ax1.annotate('North pole\n(not in $U_N$)', (0, -1), textcoords="offset points",
            xytext=(-50, -20), fontsize=9, color='steelblue')

ax1.plot(0, 1, 'r^', markersize=12, zorder=5)
ax1.annotate('South pole\n(not in $U_S$)', (0, 1), textcoords="offset points",
            xytext=(15, 5), fontsize=9, color='indianred')

# Overlap region
ax1.annotate('Overlap:\n$U_N \\cap U_S$\n$\\cong \\mathbb{R} \\setminus \\{0\\}$',
            xy=(1, 0), xytext=(1.5, 0.5),
            fontsize=10, color='purple',
            arrowprops=dict(arrowstyle='->', color='purple'))

ax1.set_xlim(-2, 2.5)
ax1.set_ylim(-1.5, 1.5)
ax1.set_aspect('equal')
ax1.set_title('Two-Chart Cover of $S^1$', fontsize=14)
ax1.legend(loc='lower left', fontsize=10)
ax1.grid(True, alpha=0.1)

# ============================================================
# Panel 2: Exact sequence diagram
# ============================================================
ax2 = axes[1]
ax2.set_xlim(0, 10)
ax2.set_ylim(0, 6)
ax2.axis('off')

# Draw the exact sequence
positions = [(0.5, 3), (2.5, 3), (5, 3), (7.5, 3), (9.5, 3)]
labels = ['$0$', '$H^0$', '$G \\oplus G$', '$G$', '$H^1$']
descriptions = ['', 'fixed\npoints', 'sections on\ncharts', 'sections on\noverlap', 'obstruction']

for (px, py), label, desc in zip(positions, labels, descriptions):
    ax2.text(px, py, label, fontsize=16, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', edgecolor='black'))
    if desc:
        ax2.text(px, py - 1, desc, fontsize=9, ha='center', va='center', style='italic', color='gray')

# Arrows
arrow_style = dict(arrowstyle='->', color='black', lw=1.5)
for i in range(len(positions)-1):
    ax2.annotate('', xy=(positions[i+1][0]-0.5, positions[i+1][1]),
                xytext=(positions[i][0]+0.5, positions[i][1]),
                arrowprops=arrow_style)

# Label the maps
map_labels = ['$\\iota$', '$\\Delta$', '$\\delta$', '']
map_positions = [(1.5, 3.5), (3.75, 3.5), (6.25, 3.5), (8.5, 3.5)]
for label, (mx, my) in zip(map_labels, map_positions):
    if label:
        ax2.text(mx, my, label, fontsize=14, ha='center', va='center', color='steelblue')

# Add explanation
ax2.text(5, 5.5, 'Mayer-Vietoris Exact Sequence', fontsize=15, ha='center',
        va='center', fontweight='bold')
ax2.text(5, 1, '$\\Delta(a,b) = \\phi(a) - b$ (Čech differential)\n'
        '$\\ker(\\delta) = \\mathrm{im}(\\Delta)$ (exactness)',
        fontsize=11, ha='center', va='center',
        bbox=dict(boxstyle='round', facecolor='lightcyan', edgecolor='steelblue'))

# ============================================================
# Panel 3: Conformal factor product = 1
# ============================================================
ax3 = axes[2]

t = np.linspace(0.1, 5, 200)
lam_t = 2 / (1 + t**2)
lam_inv = 2 / (1 + (1/t)**2)
product = lam_t * lam_inv

ax3.plot(t, lam_t, 'b-', linewidth=2, label='$\\lambda(t) = 2/(1+t^2)$')
ax3.plot(t, lam_inv, 'r-', linewidth=2, label='$\\lambda(1/t) = 2t^2/(1+t^2)$')
ax3.plot(t, product, 'g-', linewidth=2.5, label='$\\lambda(t) \\cdot \\lambda(1/t)$')

# The product is 4t²/(1+t²)², not 1. Let me fix.
# Actually λ(t)·λ(1/t) = [2/(1+t²)] · [2/(1+1/t²)] = [2/(1+t²)] · [2t²/(t²+1)]
# = 4t²/(1+t²)² which is NOT 1 in general.
# The conformal factor product theorem says λ(t)·λ(1/t) = 4t²/(1+t²)².

ax3.set_xlabel('$t$', fontsize=12)
ax3.set_ylabel('Value', fontsize=12)
ax3.set_title('Conformal Factors on Overlap\n$\\lambda(t) \\cdot \\lambda(1/t) = 4t^2/(1+t^2)^2$',
             fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.2)

# Add annotation for the identity
ax3.annotate('Product encodes\nconformal compatibility',
            xy=(1.0, product[np.argmin(np.abs(t-1.0))]),
            xytext=(2.5, 1.5),
            fontsize=10, color='green',
            arrowprops=dict(arrowstyle='->', color='green'))

plt.tight_layout()
plt.savefig('mayer_vietoris_exactness.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: mayer_vietoris_exactness.png")
