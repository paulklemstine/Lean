"""
Visualization: Binary Entropy and Fermionic Entropy Landscape

Visualizes the binary entropy function h(x) = -x log x - (1-x) log(1-x)
along with its quadratic lower bound 2x(1-x) and the constant upper bound ln(2).
Also shows the fermionic entropy as a function of a 2-mode spectrum.

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def binary_entropy(x):
    """h(x) = -x log x - (1-x) log(1-x)"""
    result = np.zeros_like(x, dtype=float)
    mask = (x > 0) & (x < 1)
    xm = x[mask]
    result[mask] = -xm * np.log(xm) - (1 - xm) * np.log(1 - xm)
    return result


fig = plt.figure(figsize=(14, 10))
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

# ─── Panel 1: Binary entropy with bounds ───────────────────────────────────
ax1 = fig.add_subplot(gs[0, 0])
x = np.linspace(0, 1, 1000)
h = binary_entropy(x)
quad = 2 * x * (1 - x)

ax1.fill_between(x, quad, np.log(2), alpha=0.15, color='steelblue',
                  label='Feasible region')
ax1.plot(x, h, 'b-', linewidth=2.5, label=r'$h(x) = -x\ln x - (1{-}x)\ln(1{-}x)$')
ax1.plot(x, quad, 'r--', linewidth=1.5, label=r'Lower bound: $2x(1{-}x)$')
ax1.axhline(y=np.log(2), color='green', linestyle=':', linewidth=1.5,
            label=r'Upper bound: $\ln 2$')
ax1.set_xlabel('x (occupation probability)', fontsize=12)
ax1.set_ylabel('h(x)', fontsize=12)
ax1.set_title('Binary Entropy with Verified Bounds', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9, loc='lower center')
ax1.set_xlim(0, 1)
ax1.set_ylim(-0.02, 0.8)
ax1.grid(True, alpha=0.3)

# ─── Panel 2: 2-mode fermionic entropy surface ────────────────────────────
ax2 = fig.add_subplot(gs[0, 1], projection='3d')
p1 = np.linspace(0, 1, 80)
p2 = np.linspace(0, 1, 80)
P1, P2 = np.meshgrid(p1, p2)
H1 = binary_entropy(P1.ravel()).reshape(P1.shape)
H2 = binary_entropy(P2.ravel()).reshape(P2.shape)
S = H1 + H2

surf = ax2.plot_surface(P1, P2, S, cmap='viridis', alpha=0.85,
                         edgecolor='none')
ax2.set_xlabel(r'$p_1$', fontsize=11)
ax2.set_ylabel(r'$p_2$', fontsize=11)
ax2.set_zlabel(r'$S_{\{1,2\}}$', fontsize=11)
ax2.set_title('2-Mode Entropy Surface', fontsize=13, fontweight='bold')
ax2.view_init(elev=25, azim=135)

# ─── Panel 3: Entropy monotonicity ────────────────────────────────────────
ax3 = fig.add_subplot(gs[1, 0])
np.random.seed(42)
n = 6
p = np.sort(np.random.uniform(0.1, 0.9, n))[::-1]

sizes = range(1, n + 1)
entropies = [sum(binary_entropy(np.array([p[i]])) for i in range(k)) for k in sizes]

ax3.bar(sizes, entropies, color='steelblue', alpha=0.7, edgecolor='navy')
ax3.plot(sizes, entropies, 'ro-', markersize=8, linewidth=2, zorder=5)
ax3.set_xlabel('Subsystem size |A|', fontsize=12)
ax3.set_ylabel('Fermionic entropy $S_A$', fontsize=12)
ax3.set_title('Entropy Monotonicity (Verified)', fontsize=13, fontweight='bold')
ax3.set_xticks(list(sizes))
ax3.grid(True, alpha=0.3)
ax3.annotate('Monotone increasing\n(formally verified)',
             xy=(3, entropies[2]), xytext=(1.5, entropies[4]),
             fontsize=10, arrowprops=dict(arrowstyle='->', color='red'),
             color='red')

# ─── Panel 4: Hessian signature profile ───────────────────────────────────
ax4 = fig.add_subplot(gs[1, 1])
n = 5
p_vals = np.array([0.3, 0.0, 0.7, 0.5, 0.9])
mat = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        if i != j:
            prod = p_vals[i] * p_vals[j]
            mat[i, j] = 1 if prod > 1e-10 else 0

im = ax4.imshow(mat, cmap='RdYlGn', vmin=0, vmax=1, aspect='equal')
ax4.set_xticks(range(n))
ax4.set_yticks(range(n))
ax4.set_xticklabels([f'{p:.1f}' for p in p_vals])
ax4.set_yticklabels([f'{p:.1f}' for p in p_vals])
ax4.set_xlabel('$p_j$', fontsize=12)
ax4.set_ylabel('$p_i$', fontsize=12)
ax4.set_title('Leaf Hessian Positive Index\n(1=green, 0=red)', fontsize=13, fontweight='bold')

for i in range(n):
    for j in range(n):
        if i != j:
            ax4.text(j, i, f'{int(mat[i, j])}',
                     ha='center', va='center', fontsize=14, fontweight='bold',
                     color='white' if mat[i, j] < 0.5 else 'black')
        else:
            ax4.text(j, i, '—', ha='center', va='center', fontsize=12, color='gray')

plt.colorbar(im, ax=ax4, shrink=0.8)

plt.suptitle('Quantum DPP Entanglement via Lorentzian Geometry',
             fontsize=15, fontweight='bold', y=1.01)
plt.savefig('entropy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved entropy_landscape.png")
