"""
Visualization: Lipschitz Properties of Tropical Observables

Shows that mergeTime, minCriticalValue, and weightRange are
1-Lipschitz, 1-Lipschitz, and 2-Lipschitz respectively.
Each panel plots |Δ(observable)| vs ‖Δw‖∞ for random perturbations,
showing the theoretical bound line.

This visualizes: mergeTime_lipschitz, minCriticalValue_lipschitz,
weight_range_lipschitz.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def weight_sup_dist(w, wp):
    return float(np.max(np.abs(w - wp)))

def merge_time(w):
    return float(np.max(w))

def min_critical_value(w):
    return float(np.min(w))

def weight_range(w):
    return merge_time(w) - min_critical_value(w)


np.random.seed(42)
m = 15
w = np.random.uniform(1, 10, m)

n_trials = 2000
sup_dists = []
delta_merge = []
delta_min = []
delta_range = []

for _ in range(n_trials):
    eps = np.random.uniform(0, 2)
    noise = np.random.uniform(-eps, eps, m)
    wp = w + noise

    d = weight_sup_dist(w, wp)
    sup_dists.append(d)
    delta_merge.append(abs(merge_time(w) - merge_time(wp)))
    delta_min.append(abs(min_critical_value(w) - min_critical_value(wp)))
    delta_range.append(abs(weight_range(w) - weight_range(wp)))

sup_dists = np.array(sup_dists)
delta_merge = np.array(delta_merge)
delta_min = np.array(delta_min)
delta_range = np.array(delta_range)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Merge time
ax = axes[0]
ax.scatter(sup_dists, delta_merge, alpha=0.15, s=8, c='#2196F3')
ax.plot([0, 2], [0, 2], 'r-', linewidth=2.5, label='y = x (1-Lipschitz)')
ax.set_xlabel('‖w - w\'‖∞', fontsize=12)
ax.set_ylabel('|τ(w) - τ(w\')|', fontsize=12)
ax.set_title('Merge Time (1-Lipschitz)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')
ax.set_xlim(0, 2.1)
ax.set_ylim(0, 2.1)

# Panel 2: Min critical value
ax = axes[1]
ax.scatter(sup_dists, delta_min, alpha=0.15, s=8, c='#4CAF50')
ax.plot([0, 2], [0, 2], 'r-', linewidth=2.5, label='y = x (1-Lipschitz)')
ax.set_xlabel('‖w - w\'‖∞', fontsize=12)
ax.set_ylabel('|μ(w) - μ(w\')|', fontsize=12)
ax.set_title('Min Critical Value (1-Lipschitz)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')
ax.set_xlim(0, 2.1)
ax.set_ylim(0, 2.1)

# Panel 3: Weight range
ax = axes[2]
ax.scatter(sup_dists, delta_range, alpha=0.15, s=8, c='#FF9800')
ax.plot([0, 2], [0, 4], 'r-', linewidth=2.5, label='y = 2x (2-Lipschitz)')
ax.plot([0, 2], [0, 2], 'g--', linewidth=1.5, alpha=0.5, label='y = x')
ax.set_xlabel('‖w - w\'‖∞', fontsize=12)
ax.set_ylabel('|Δrange|', fontsize=12)
ax.set_title('Weight Range (2-Lipschitz)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 2.1)
ax.set_ylim(0, 4.2)

plt.suptitle('Lipschitz Properties of Tropical Observables',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_lipschitz.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_lipschitz.png")
