"""
Visualization: Rank Function Stability Under Perturbation

Shows the sublevel edge count (rank function) for an original weight
function and several perturbations. The ε-shifted curves demonstrate
the 1-Lipschitz interleaving: rank_w(t) ≤ rank_w'(t + ε).

The shaded region between shifted curves shows the certified uncertainty
band for the rank function under bounded noise.
"""

import numpy as np
import matplotlib.pyplot as plt


def sublevel_count(w, t):
    return int(np.sum(w <= t))


def weight_sup_dist(w, w_prime):
    return float(np.max(np.abs(w - w_prime)))


rng = np.random.default_rng(2024)

# Generate a weighted graph
n = 12
m = n * (n - 1) // 2
w = rng.uniform(0, 1, m)
epsilon = 0.08

# Generate perturbations
n_perturbations = 20
perturbations = []
for _ in range(n_perturbations):
    wp = w + rng.uniform(-epsilon, epsilon, m)
    perturbations.append(wp)

# Compute rank functions
thresholds = np.linspace(-0.1, 1.1, 500)
rank_w = np.array([sublevel_count(w, t) for t in thresholds])

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: rank functions overlay
ax = axes[0]
for wp in perturbations:
    rank_wp = np.array([sublevel_count(wp, t) for t in thresholds])
    ax.step(thresholds, rank_wp, alpha=0.2, color='steelblue', linewidth=0.8)

ax.step(thresholds, rank_w, color='red', linewidth=2.5, label='Original w')
ax.set_xlabel('Threshold t', fontsize=12)
ax.set_ylabel('Sublevel edge count |F_w(t)|', fontsize=12)
ax.set_title('Rank Functions Under Perturbation', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_xlim(-0.05, 1.05)

# Right: certified uncertainty band
ax = axes[1]

# Compute envelope
rank_lower = np.array([sublevel_count(w, t - epsilon) for t in thresholds])
rank_upper = np.array([sublevel_count(w, t + epsilon) for t in thresholds])

ax.fill_between(thresholds, rank_lower, rank_upper, alpha=0.25,
                color='steelblue', label=f'Certified band (ε={epsilon})')
ax.step(thresholds, rank_w, color='red', linewidth=2.5, label='Original w')

# Overlay a few perturbations to show they lie within the band
for wp in perturbations[:5]:
    rank_wp = np.array([sublevel_count(wp, t) for t in thresholds])
    ax.step(thresholds, rank_wp, alpha=0.4, color='green', linewidth=0.8)

ax.step(thresholds, rank_wp, alpha=0.4, color='green', linewidth=0.8,
        label='Perturbed samples')

ax.set_xlabel('Threshold t', fontsize=12)
ax.set_ylabel('Sublevel edge count |F_w(t)|', fontsize=12)
ax.set_title('Certified Uncertainty Band', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_xlim(-0.05, 1.05)

fig.suptitle('1-Lipschitz Stability of the Rank Function',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_rank_function.png', dpi=150, bbox_inches='tight')
print("Saved: viz_rank_function.png")
