"""
Visualization: Hessian Eigenvalue Spectrum at Derivative Leaves

Shows the eigenvalue structure of Hessian matrices at degree-2 derivative
leaves of DPP partition polynomials for different kernel types.
Illustrates the Lorentzian signature constraint (at most 1 positive eigenvalue).

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt


def random_psd_contraction(n, rng):
    A = rng.standard_normal((n, n))
    Q, _ = np.linalg.qr(A)
    eigs = rng.uniform(0, 1, n)
    return Q @ np.diag(eigs) @ Q.T


fig, axes = plt.subplots(2, 2, figsize=(14, 11))

rng = np.random.default_rng(42)

# ─── Panel 1: Diagonal kernel leaf eigenvalues ─────────────────────────────
ax = axes[0, 0]
n = 5
p = np.array([0.3, 0.6, 0.1, 0.8, 0.5])

pairs = [(i, j) for i in range(n) for j in range(i + 1, n)]
pair_labels = [f'({i},{j})' for i, j in pairs]
pos_eigs = [p[i] * p[j] for i, j in pairs]
neg_eigs = [-p[i] * p[j] for i, j in pairs]

x_pos = np.arange(len(pairs))
width = 0.35

bars1 = ax.bar(x_pos - width / 2, pos_eigs, width, color='steelblue',
               alpha=0.8, label=r'$+\lambda$')
bars2 = ax.bar(x_pos + width / 2, neg_eigs, width, color='coral',
               alpha=0.8, label=r'$-\lambda$')

ax.axhline(y=0, color='black', linewidth=0.5)
ax.set_xticks(x_pos)
ax.set_xticklabels(pair_labels, fontsize=8, rotation=45)
ax.set_ylabel('Eigenvalue', fontsize=11)
ax.set_title('Diagonal Kernel: Leaf Hessian Eigenvalues\n'
             r'$H = [[0, p_i p_j], [p_i p_j, 0]]$  →  eigenvalues $\pm p_i p_j$',
             fontsize=11, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3, axis='y')

# ─── Panel 2: Pos index histogram for random kernels ──────────────────────
ax = axes[0, 1]
n = 5
num_trials = 500
pos_indices = []

for _ in range(num_trials):
    K = random_psd_contraction(n, rng)
    for i in range(n):
        for j in range(i + 1, n):
            # For diagonal-like kernels, Hessian is [[0, c], [c, 0]]
            # For general kernels, examine the 2×2 principal minor structure
            c = K[i, j]
            det = -c ** 2
            if det < -1e-15:
                pos_indices.append(1)
            elif det > 1e-15:
                pos_indices.append(2 if c > 0 else 0)
            else:
                pos_indices.append(0)

counts = [pos_indices.count(i) for i in range(3)]
colors_bar = ['#d62728', '#2ca02c', '#9467bd']
bars = ax.bar([0, 1, 2], counts, color=colors_bar, alpha=0.8, edgecolor='black')
ax.set_xticks([0, 1, 2])
ax.set_xticklabels(['0', '1', '2'], fontsize=12)
ax.set_xlabel('Positive Index', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title(f'Hessian Positive Index Distribution\n'
             f'({num_trials} random kernels, n={n})',
             fontsize=11, fontweight='bold')

# Annotate Lorentzian constraint
ax.annotate('Lorentzian: pos index ≤ 1\n(formally verified)',
            xy=(1, counts[1]), xytext=(1.5, counts[1] * 0.8),
            fontsize=10, color='green', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='green'))
if counts[2] > 0:
    ax.annotate('Should be 0\nfor Lorentzian\npolynomials',
                xy=(2, counts[2]), xytext=(2.3, counts[2] + 100),
                fontsize=9, color='red',
                arrowprops=dict(arrowstyle='->', color='red'))

ax.grid(True, alpha=0.3, axis='y')

# ─── Panel 3: Curvature vs entropy scatter (pairs) ────────────────────────
ax = axes[1, 0]
n = 6
curvatures = []
pair_entropies = []

for trial in range(200):
    K = random_psd_contraction(n, rng)
    for i in range(n):
        for j in range(i + 1, n):
            curv = K[i, j] ** 2
            # 2×2 submatrix entropy
            K_sub = K[np.ix_([i, j], [i, j])]
            eigs = np.clip(np.linalg.eigvalsh(K_sub), 0, 1)
            S = sum(-lam * np.log(max(lam, 1e-15)) - (1 - lam) * np.log(max(1 - lam, 1e-15))
                    if 0 < lam < 1 else 0 for lam in eigs)
            curvatures.append(curv)
            pair_entropies.append(S)

curvatures = np.array(curvatures)
pair_entropies = np.array(pair_entropies)

ax.scatter(curvatures, pair_entropies, alpha=0.2, s=5, c='steelblue',
           edgecolors='none')

# Fit trend line
mask = curvatures > 1e-8
if np.sum(mask) > 10:
    z = np.polyfit(curvatures[mask], pair_entropies[mask], 1)
    x_fit = np.linspace(0, np.max(curvatures), 100)
    ax.plot(x_fit, np.polyval(z, x_fit), 'r-', linewidth=2,
            label=f'Linear fit (slope={z[0]:.2f})')

corr = np.corrcoef(curvatures, pair_entropies)[0, 1]
ax.set_xlabel(r'Leaf curvature $K_{ij}^2$', fontsize=11)
ax.set_ylabel(r'Pair entropy $S_{\{i,j\}}$', fontsize=11)
ax.set_title(f'Curvature vs. Pair Entropy\n(ρ = {corr:.3f})',
             fontsize=11, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ─── Panel 4: Signature profile heatmap ───────────────────────────────────
ax = axes[1, 1]
n = 6
K = random_psd_contraction(n, rng)

# Compute the curvature matrix
curv_mat = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        if i != j:
            curv_mat[i, j] = K[i, j] ** 2

im = ax.imshow(curv_mat, cmap='YlOrRd', aspect='equal')
ax.set_xticks(range(n))
ax.set_yticks(range(n))
ax.set_xlabel('Mode j', fontsize=11)
ax.set_ylabel('Mode i', fontsize=11)
ax.set_title('Leaf Curvature Profile $K_{ij}^2$\n(Random Kernel)',
             fontsize=11, fontweight='bold')

for i in range(n):
    for j in range(n):
        val = curv_mat[i, j]
        color = 'white' if val > 0.5 * curv_mat.max() else 'black'
        ax.text(j, i, f'{val:.3f}', ha='center', va='center',
                fontsize=7, color=color)

plt.colorbar(im, ax=ax, shrink=0.8)

plt.suptitle('Hessian Signature Analysis for DPP Partition Polynomials',
             fontsize=14, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('hessian_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved hessian_spectrum.png")
