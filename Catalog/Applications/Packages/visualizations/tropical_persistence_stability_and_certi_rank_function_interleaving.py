"""
Visualization: Tropical Rank Function Interleaving

Shows how the tropical rank function (step function counting edges in the
sublevel set) of a weighted graph shifts under weight perturbation. The
ε-interleaving is visually apparent: the original curve always lies below
the shifted perturbed curve.

This visualizes the core theorem: tropical_rank_interleaving_of_sup_bound.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def tropical_rank_array(w, thresholds):
    """Compute rank function at multiple thresholds."""
    sorted_w = np.sort(w)
    return np.searchsorted(sorted_w, thresholds, side='right')


def weight_sup_dist(w, w_prime):
    return float(np.max(np.abs(w - w_prime)))


# Setup
np.random.seed(42)
m = 8
w = np.array([1.0, 2.0, 3.5, 4.0, 5.5, 6.0, 7.5, 9.0])
eps = 0.8
noise = np.random.uniform(-eps, eps, m)
w_prime = w + noise
actual_eps = weight_sup_dist(w, w_prime)

thresholds = np.linspace(-0.5, 10.5, 1000)
rho_w = tropical_rank_array(w, thresholds)
rho_wp = tropical_rank_array(w_prime, thresholds)
rho_wp_shifted = tropical_rank_array(w_prime, thresholds + actual_eps)
rho_w_shifted = tropical_rank_array(w, thresholds + actual_eps)

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left panel: Forward interleaving
ax = axes[0]
ax.step(thresholds, rho_w, label=r'$\rho_w(t)$', color='#2196F3', linewidth=2.5)
ax.step(thresholds, rho_wp_shifted,
        label=r"$\rho_{w'}(t+\varepsilon)$", color='#F44336',
        linewidth=2, linestyle='--')
ax.step(thresholds, rho_wp, label=r"$\rho_{w'}(t)$",
        color='#F44336', linewidth=1, alpha=0.4)
ax.fill_between(thresholds, rho_w, rho_wp_shifted, alpha=0.08, color='green')
ax.set_xlabel('Threshold t', fontsize=13)
ax.set_ylabel('Rank (# edges in sublevel set)', fontsize=13)
ax.set_title(f'Forward: ρ_w(t) ≤ ρ_w\'(t+ε)\n(ε = {actual_eps:.3f})', fontsize=13)
ax.legend(fontsize=11, loc='lower right')
ax.grid(True, alpha=0.3)
ax.set_xlim(-0.5, 10.5)

# Right panel: Both directions
ax = axes[1]
ax.step(thresholds, rho_w, label=r'$\rho_w(t)$', color='#2196F3', linewidth=2.5)
ax.step(thresholds, rho_wp, label=r"$\rho_{w'}(t)$", color='#F44336', linewidth=2.5)
# Show the ε-band
for i, t_val in enumerate(np.sort(w)):
    ax.axvline(x=t_val, color='#2196F3', alpha=0.15, linewidth=1)
for i, t_val in enumerate(np.sort(w_prime)):
    ax.axvline(x=t_val, color='#F44336', alpha=0.15, linewidth=1)

# Annotate ε
ax.annotate('', xy=(5.5, 4.5), xytext=(5.5 + actual_eps, 4.5),
            arrowprops=dict(arrowstyle='<->', color='green', lw=2))
ax.text(5.5 + actual_eps/2, 4.8, f'ε = {actual_eps:.3f}',
        ha='center', fontsize=11, color='green', fontweight='bold')

ax.set_xlabel('Threshold t', fontsize=13)
ax.set_ylabel('Rank', fontsize=13)
ax.set_title('Both Rank Functions with Critical Values', fontsize=13)
ax.legend(fontsize=11, loc='lower right')
ax.grid(True, alpha=0.3)
ax.set_xlim(-0.5, 10.5)

plt.suptitle('Tropical Persistence Stability: Rank Function Interleaving',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_interleaving.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_interleaving.png")
