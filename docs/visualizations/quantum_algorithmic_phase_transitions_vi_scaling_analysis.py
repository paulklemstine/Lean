"""
Scaling Visualization: Certified Threshold and Empirical Agreement

This script visualizes the relationship between the certified Lorentzian
stability radius and the empirically observed noise threshold across
instance families of varying size.

Visualizes: Certified vs empirical thresholds for complete graph matching
Hessians (n=3..8), demonstrating the conjecture that Lorentzian radius
predicts noise robustness ordering.
"""

import numpy as np
import matplotlib.pyplot as plt


def compute_lorentzian_gap(A):
    eigenvalues = np.linalg.eigvalsh(A)
    eigenvalues = np.sort(eigenvalues)[::-1]
    return -eigenvalues[1] if A.shape[0] >= 2 else float('inf')


def find_empirical_threshold(A, num_samples=100, num_noise_levels=60):
    """Find noise level where survival rate drops below 50%."""
    gap = compute_lorentzian_gap(A)
    n = A.shape[0]
    noise_levels = np.linspace(0, gap * 2, num_noise_levels)

    for eta in noise_levels:
        survived = 0
        for _ in range(num_samples):
            E = np.random.randn(n, n)
            E = (E + E.T) / 2
            norm_e = np.linalg.norm(E, ord=2)
            if norm_e > 0:
                E = E / norm_e * eta
            g = compute_lorentzian_gap(A + E)
            if g > 0:
                survived += 1
        if survived / num_samples < 0.5:
            return eta
    return noise_levels[-1]


np.random.seed(2025)

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Panel 1: Certified vs Empirical threshold (complete graphs)
ax = axes[0, 0]
sizes = list(range(3, 9))
certified = []
empirical = []

for n in sizes:
    adj = np.ones((n, n)) - np.eye(n)
    H = adj
    gap = compute_lorentzian_gap(H)
    certified.append(gap / 2)
    emp_thresh = find_empirical_threshold(H, num_samples=60)
    empirical.append(emp_thresh)

ax.bar(np.array(sizes) - 0.15, certified, 0.3, color='#3498db',
       label='Certified (Theorem 1)', alpha=0.85)
ax.bar(np.array(sizes) + 0.15, empirical, 0.3, color='#e74c3c',
       label='Empirical (50% survival)', alpha=0.85)
ax.set_xlabel('Graph size n (Kₙ)', fontsize=13)
ax.set_ylabel('Threshold', fontsize=13)
ax.set_title('Certified vs Empirical Thresholds\n(Complete Graphs)',
             fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.set_xticks(sizes)
ax.grid(True, alpha=0.3, axis='y')

# Panel 2: Scatter plot of certified vs empirical
ax = axes[0, 1]
ax.scatter(certified, empirical, s=120, c=sizes, cmap='viridis',
           edgecolors='black', linewidth=1.5, zorder=5)
for i, n in enumerate(sizes):
    ax.annotate(f'K{n}', (certified[i], empirical[i]),
                textcoords="offset points", xytext=(8, 5), fontsize=11)

# Identity line
max_val = max(max(certified), max(empirical)) * 1.1
ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.5, label='y = x')
ax.plot([0, max_val], [0, 2 * max_val], 'g:', alpha=0.5, label='y = 2x')
ax.set_xlabel('Certified threshold (ε/2)', fontsize=13)
ax.set_ylabel('Empirical threshold', fontsize=13)
ax.set_title('Certified vs Empirical Agreement\n(Each point = one graph)',
             fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, max_val)
ax.set_ylim(0, max(empirical) * 1.2)

# Panel 3: Gap scaling across graph families
ax = axes[1, 0]
families = {
    'Complete Kₙ': lambda n: np.ones((n, n)) - np.eye(n),
    'Cycle Cₙ': lambda n: np.diag(np.ones(n-1), 1) + np.diag(np.ones(n-1), -1) +
                            np.diag([1.0], n-1) + np.diag([1.0], -(n-1)),
    'Path Pₙ': lambda n: np.diag(np.ones(n-1), 1) + np.diag(np.ones(n-1), -1),
}

colors_f = {'Complete Kₙ': '#e74c3c', 'Cycle Cₙ': '#3498db', 'Path Pₙ': '#2ecc71'}
markers_f = {'Complete Kₙ': 's', 'Cycle Cₙ': 'D', 'Path Pₙ': 'o'}

for name, gen in families.items():
    gaps = []
    for n in range(3, 12):
        adj = gen(n)
        g = compute_lorentzian_gap(-adj)
        gaps.append(g)
    ax.plot(range(3, 12), gaps, f'{markers_f[name]}-', color=colors_f[name],
            linewidth=2.5, markersize=8, label=name)

ax.set_xlabel('Graph size n', fontsize=13)
ax.set_ylabel('Lorentzian gap', fontsize=13)
ax.set_title('Gap Scaling by Graph Family', fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 4: PSD matrix gap distribution
ax = axes[1, 1]
np.random.seed(42)
psd_gaps = []
psd_min_eigs = []
for _ in range(200):
    n = 5
    M = np.random.randn(n, n)
    A = M @ M.T / n + 0.5 * np.eye(n)
    gap = compute_lorentzian_gap(-A)
    min_eig = np.min(np.linalg.eigvalsh(A))
    psd_gaps.append(gap)
    psd_min_eigs.append(min_eig)

ax.scatter(psd_min_eigs, psd_gaps, s=30, alpha=0.5, c='#8e44ad')
# Perfect correlation line
min_v = min(min(psd_min_eigs), min(psd_gaps))
max_v = max(max(psd_min_eigs), max(psd_gaps))
ax.plot([min_v, max_v], [min_v, max_v], 'k-', linewidth=2, label='gap = λ_min')
ax.set_xlabel('Minimum eigenvalue of A (λ_min)', fontsize=13)
ax.set_ylabel('Lorentzian gap of -A', fontsize=13)
ax.set_title('PSD Proxy: Gap = λ_min(A)\n(200 random PSD matrices)',
             fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('scaling_analysis.png', dpi=150, bbox_inches='tight')
print("Saved scaling_analysis.png")
