#!/usr/bin/env python3
"""
Visualization: Centered Simplex Embedding and (q-1) Scaling

Visualizes the centered simplex embedding that reduces the effective
perturbation dimension from q to (q-1). Shows the geometry of Potts
state vectors and how the centered projection captures the essential
fluctuation structure.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from itertools import product


def potts_partition(n, q, J, beta):
    Z = 0.0
    for sigma in product(range(q), repeat=n):
        sigma_arr = np.array(sigma)
        total = sum(J[i, j] for i in range(n) for j in range(n) if sigma_arr[i] == sigma_arr[j])
        Z += np.exp(beta * total)
    return Z


fig = plt.figure(figsize=(16, 10))

# ─── Plot 1: Centered state vectors for q=3 ───
ax1 = fig.add_subplot(2, 3, 1)
q = 3
vecs = np.eye(q) - 1.0 / q
colors = ['#e41a1c', '#377eb8', '#4daf4a']
labels = [f'State {i}' for i in range(q)]

for i in range(q):
    ax1.arrow(0, 0, vecs[i, 0], vecs[i, 1], head_width=0.03,
              head_length=0.02, fc=colors[i], ec=colors[i], linewidth=2)
    ax1.plot(vecs[i, 0], vecs[i, 1], 'o', color=colors[i], markersize=10)
    ax1.annotate(labels[i], (vecs[i, 0] + 0.05, vecs[i, 1] + 0.05), fontsize=11)

# Draw the constant direction (1/√q, 1/√q, ...)
ax1.plot(0, 0, 'k+', markersize=15, markeredgewidth=2)
ax1.set_xlim(-0.8, 1.0)
ax1.set_ylim(-0.8, 1.0)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)
ax1.set_title(f'Centered vectors (q={q})', fontsize=13)
ax1.set_xlabel('Component 1')
ax1.set_ylabel('Component 2')

# ─── Plot 2: Inner product matrix ───
ax2 = fig.add_subplot(2, 3, 2)
q = 5
inner_prod = np.zeros((q, q))
vecs = np.eye(q) - 1.0 / q
for a in range(q):
    for b in range(q):
        inner_prod[a, b] = np.dot(vecs[a], vecs[b])

im = ax2.imshow(inner_prod, cmap='RdBu_r', vmin=-0.5, vmax=1.0)
ax2.set_title(f'⟨v_a, v_b⟩ for q={q}', fontsize=13)
ax2.set_xlabel('State b')
ax2.set_ylabel('State a')
plt.colorbar(im, ax=ax2)
for a in range(q):
    for b in range(q):
        ax2.text(b, a, f'{inner_prod[a,b]:.2f}', ha='center', va='center',
                 fontsize=8, color='white' if abs(inner_prod[a,b]) > 0.3 else 'black')

# ─── Plot 3: (q-1) vs q scaling comparison ───
ax3 = fig.add_subplot(2, 3, 3)
q_values = list(range(2, 8))
n = 3
beta = 0.5
n_trials = 30
np.random.seed(42)

max_ratios_naive = []
max_ratios_centered = []

for q in q_values:
    max_naive = 0.0
    max_centered = 0.0
    for _ in range(n_trials):
        J = np.random.randn(n, n) * 0.3
        J = (J + J.T) / 2
        dJ = np.random.randn(n, n) * 0.05
        dJ = (dJ + dJ.T) / 2
        K = J + dJ

        Z_J = potts_partition(n, q, J, beta)
        Z_K = potts_partition(n, q, K, beta)
        empirical = abs(np.log(Z_J) - np.log(Z_K))
        sup_norm = np.max(np.abs(J - K))

        naive_bound = abs(beta) * n**2 * sup_norm
        centered_bound = abs(beta) * (q - 1) * n**2 * sup_norm

        if naive_bound > 0:
            max_naive = max(max_naive, empirical / naive_bound)
        if centered_bound > 0:
            max_centered = max(max_centered, empirical / centered_bound)

    max_ratios_naive.append(max_naive)
    max_ratios_centered.append(max_centered)

ax3.bar(np.array(q_values) - 0.15, max_ratios_naive, 0.3, label='Ratio to n² bound',
        color='steelblue', alpha=0.8)
ax3.bar(np.array(q_values) + 0.15, max_ratios_centered, 0.3, label='Ratio to (q-1)n² bound',
        color='coral', alpha=0.8)
ax3.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='Bound = 1')
ax3.set_xlabel('Number of states q', fontsize=12)
ax3.set_ylabel('Max empirical/bound ratio', fontsize=12)
ax3.set_title('Bound tightness comparison', fontsize=13)
ax3.legend(fontsize=9)
ax3.set_xticks(q_values)

# ─── Plot 4: Kronecker decomposition ───
ax4 = fig.add_subplot(2, 3, 4)
q = 4
const_part = np.full((q, q), 1.0 / q)
fluct_part = np.zeros((q, q))
vecs = np.eye(q) - 1.0 / q
for a in range(q):
    for b in range(q):
        fluct_part[a, b] = np.dot(vecs[a], vecs[b])

kronecker = np.eye(q)
reconstructed = const_part + fluct_part

ax4.bar(range(3), [np.linalg.norm(kronecker), np.linalg.norm(const_part),
                     np.linalg.norm(fluct_part)],
        color=['purple', 'orange', 'green'], alpha=0.7)
ax4.set_xticks(range(3))
ax4.set_xticklabels(['δ(a,b)', '1/q (const)', '⟨v_a,v_b⟩ (fluct)'], fontsize=10)
ax4.set_ylabel('Frobenius norm', fontsize=12)
ax4.set_title(f'Kronecker decomposition (q={q})', fontsize=13)

# Verify: ||δ||² = ||const||² + ||fluct||²
err = np.linalg.norm(kronecker - reconstructed)
ax4.text(0.5, 0.9, f'Reconstruction error: {err:.2e}',
         transform=ax4.transAxes, fontsize=10, ha='center')

# ─── Plot 5: Antiferromagnetic energy landscape ───
ax5 = fig.add_subplot(2, 3, 5)
n, q = 3, 3
J = np.ones((n, n)) - np.eye(n)
betas = np.linspace(-5, 2, 50)

mono_fracs = []
for beta_val in betas:
    Z = 0.0
    Z_mono = 0.0
    for sigma in product(range(q), repeat=n):
        sigma_arr = np.array(sigma)
        total = sum(J[i, j] for i in range(n) for j in range(n) if sigma_arr[i] == sigma_arr[j])
        w = np.exp(beta_val * total)
        Z += w
        if len(set(sigma)) == 1:
            Z_mono += w
    mono_fracs.append(Z_mono / Z)

ax5.plot(betas, mono_fracs, 'b-', linewidth=2)
ax5.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
ax5.fill_between(betas, 0, mono_fracs, alpha=0.1, color='blue')
ax5.set_xlabel('Inverse temperature β', fontsize=12)
ax5.set_ylabel('P(monochromatic)', fontsize=12)
ax5.set_title('Antiferro suppression (K₃)', fontsize=13)
ax5.annotate('Antiferromagnetic\n(graph coloring)', xy=(-4, 0.01),
             fontsize=9, ha='center', color='blue')
ax5.annotate('Ferromagnetic\n(clustering)', xy=(1.5, 0.15),
             fontsize=9, ha='center', color='red')

# ─── Plot 6: Determinantal stability ───
ax6 = fig.add_subplot(2, 3, 6)
np.random.seed(42)
dims = list(range(2, 9))
det_ratios = []

for d in dims:
    max_ratio = 0.0
    for _ in range(20):
        A = np.random.randn(d, d)
        L = A @ A.T
        B = np.random.randn(d, d) * 0.1
        M = L + B @ B.T

        det_L = np.linalg.det(L + np.eye(d))
        det_M = np.linalg.det(M + np.eye(d))
        if det_L > 0 and det_M > 0:
            empirical = abs(np.log(det_L) - np.log(det_M))
            sup_norm = np.max(np.abs(L - M))
            if sup_norm > 0:
                ratio = empirical / (d * sup_norm)
                max_ratio = max(max_ratio, ratio)
    det_ratios.append(max_ratio)

ax6.bar(dims, det_ratios, color='teal', alpha=0.7)
ax6.axhline(y=1.0, color='red', linestyle='--', label='Bound = 1')
ax6.set_xlabel('Matrix dimension n', fontsize=12)
ax6.set_ylabel('Max |Δ log det| / (n·sup)', fontsize=12)
ax6.set_title('Determinantal stability', fontsize=13)
ax6.legend(fontsize=10)

plt.suptitle('Centered Simplex Geometry and Potts-Lorentzian Stability',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_centered_simplex.png', dpi=150, bbox_inches='tight')
print("Saved viz_centered_simplex.png")
