"""
Visualization: Tropical Spectral Gap vs. Certified Radius

Shows how the certified robustness radius grows with the tropical spectral
gap, comparing tropical certificates with classical eigenvalue certificates
across multiple matrix dimensions.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def tropical_spectral_gap(Q):
    """Compute Gershgorin diagonal dominance margin."""
    n = Q.shape[0]
    return min(Q[i, i] - sum(abs(Q[i, j]) for j in range(n) if j != i) for i in range(n))


def generate_diag_dominant_matrix(n, gap, seed=42):
    """Generate symmetric diag-dominant matrix with given gap."""
    rng = np.random.RandomState(seed)
    Q = 0.5 * rng.randn(n, n)
    Q = (Q + Q.T) / 2
    for i in range(n):
        off_sum = sum(abs(Q[i, j]) for j in range(n) if j != i)
        Q[i, i] = off_sum + gap
    return Q


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Certified radius vs tropical gap
R = 0.5
gaps = np.linspace(0.1, 10, 200)
r_tropical = np.sqrt(gaps / (2 * R))

axes[0].plot(gaps, r_tropical, 'b-', linewidth=2.5, label='Tropical certificate')
axes[0].fill_between(gaps, 0, r_tropical, alpha=0.15, color='blue')
axes[0].set_xlabel('Tropical Spectral Gap γ', fontsize=12)
axes[0].set_ylabel('Certified Radius r', fontsize=12)
axes[0].set_title('Certified Radius vs. Tropical Gap', fontsize=13)
axes[0].legend(fontsize=11)
axes[0].grid(True, alpha=0.3)
axes[0].set_xlim(0, 10)

# Plot 2: Tropical gap vs minimum eigenvalue (scatter)
dims = [5, 10, 20]
colors = ['#2196F3', '#4CAF50', '#FF9800']
for dim, color in zip(dims, colors):
    g_vals, e_vals = [], []
    for seed in range(100):
        gap = np.random.RandomState(seed + 1000).uniform(0.5, 5.0)
        Q = generate_diag_dominant_matrix(dim, gap, seed=seed)
        g_vals.append(tropical_spectral_gap(Q))
        e_vals.append(float(np.linalg.eigvalsh(Q).min()))
    axes[1].scatter(g_vals, e_vals, s=20, alpha=0.6, color=color, label=f'n={dim}')

max_val = 8
axes[1].plot([0, max_val], [0, max_val], 'k--', alpha=0.3, label='y=x')
axes[1].set_xlabel('Tropical Gap γ', fontsize=12)
axes[1].set_ylabel('Min Eigenvalue λ_min', fontsize=12)
axes[1].set_title('Tropical Gap ≤ Min Eigenvalue', fontsize=13)
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

# Plot 3: Energy barrier
r_range = np.linspace(0, 3.5, 200)
alpha = 4.0
R_val = 0.3
actual = np.maximum(0, (alpha/2)*r_range**2 - R_val*r_range**4)
guaranteed = (alpha/4)*r_range**2
valid_mask = R_val * r_range**2 <= alpha/4

axes[2].plot(r_range, actual, 'b-', linewidth=2.5, label='Actual barrier')
axes[2].plot(r_range[valid_mask], guaranteed[valid_mask], 'r--', linewidth=2,
             label='Guaranteed (α/4)r²')
r_crit = np.sqrt(alpha / (2*R_val))
axes[2].axvline(x=r_crit, color='gray', linestyle=':', alpha=0.5, label=f'r_crit={r_crit:.2f}')
axes[2].set_xlabel('Radius r', fontsize=12)
axes[2].set_ylabel('Energy Barrier Height', fontsize=12)
axes[2].set_title('Energy Barrier Theorem', fontsize=13)
axes[2].legend(fontsize=10)
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_tropical_gap.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical_gap.png")
