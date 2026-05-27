"""
Visualization: Warm-Start Total Variation Bound
=================================================

Visualizes the relationship between coefficient perturbation magnitude
and the total variation distance between normalized distributions,
demonstrating the TV ≤ Δ/max(Z,Z') bound from the formal proof.

Shows how small coefficient changes lead to proportionally small
distribution shifts, enabling efficient warm-start MCMC.
"""

import numpy as np
import matplotlib.pyplot as plt


def tv_distance(mu, nu):
    """Total variation distance."""
    return 0.5 * np.sum(np.abs(mu - nu))


def normalize(w):
    """Normalize to probability distribution."""
    return w / w.sum()


# ── Panel 1: TV distance vs perturbation size ───────────────────────────────

np.random.seed(42)
n_states = 20
w_base = np.random.exponential(2.0, size=n_states)
w_base = np.sort(w_base)[::-1]
Z_base = w_base.sum()

perturbation_sizes = np.linspace(0, 5, 100)
tv_actual = []
tv_bound = []

for delta in perturbation_sizes:
    w_new = w_base.copy()
    w_new[0] += delta  # Perturb largest weight
    mu_old = normalize(w_base)
    mu_new = normalize(w_new)
    tv = tv_distance(mu_old, mu_new)
    tv_actual.append(tv)
    Z_new = w_new.sum()
    bound = delta / max(Z_base, Z_new)
    tv_bound.append(bound)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: TV vs perturbation
ax = axes[0]
ax.plot(perturbation_sizes, tv_actual, 'b-', linewidth=2, label='Actual TV')
ax.plot(perturbation_sizes, tv_bound, 'r--', linewidth=2, label='Bound (Δ/max(Z,Z′))')
ax.fill_between(perturbation_sizes, tv_actual, tv_bound, alpha=0.15, color='green')
ax.set_xlabel('Perturbation Size (Δ)', fontsize=12)
ax.set_ylabel('Total Variation Distance', fontsize=12)
ax.set_title('TV Distance vs Coefficient Perturbation', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Multiple perturbation targets
ax2 = axes[1]
colors = plt.cm.viridis(np.linspace(0, 0.8, 5))
for idx, color in zip([0, 4, 9, 14, 19], colors):
    tvs = []
    bounds = []
    for delta in perturbation_sizes:
        w_new = w_base.copy()
        w_new[idx] += delta
        mu_old = normalize(w_base)
        mu_new = normalize(w_new)
        tvs.append(tv_distance(mu_old, mu_new))
        bounds.append(delta / max(w_base.sum(), w_new.sum()))
    ax2.plot(perturbation_sizes, tvs, color=color, linewidth=1.5,
             label=f'Perturb state {idx} (w={w_base[idx]:.1f})')

ax2.set_xlabel('Perturbation Size (Δ)', fontsize=12)
ax2.set_ylabel('Total Variation Distance', fontsize=12)
ax2.set_title('TV by Perturbation Target', fontsize=13, fontweight='bold')
ax2.legend(fontsize=8, loc='upper left')
ax2.grid(True, alpha=0.3)

# Panel 3: Bound tightness ratio
ax3 = axes[2]
tightness = [a / b if b > 1e-10 else 1.0 for a, b in zip(tv_actual, tv_bound)]
ax3.plot(perturbation_sizes[1:], tightness[1:], 'purple', linewidth=2)
ax3.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='Tight (ratio=1)')
ax3.set_xlabel('Perturbation Size (Δ)', fontsize=12)
ax3.set_ylabel('TV / Bound', fontsize=12)
ax3.set_title('Bound Tightness Ratio', fontsize=13, fontweight='bold')
ax3.set_ylim(0, 1.1)
ax3.legend()
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_warmstart_tv.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_warmstart_tv.png")
