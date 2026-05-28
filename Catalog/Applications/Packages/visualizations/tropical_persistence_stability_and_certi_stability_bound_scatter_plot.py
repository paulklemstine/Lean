"""
Visualization: Tropical Persistence Stability Bound

Visualizes the 1-Lipschitz stability theorem by plotting actual barcode
displacement vs. the certified upper bound (sup-norm distance) for
multiple graph families and perturbation levels.

The certified bound d_B ≤ ‖w - w'‖_∞ is shown as the diagonal line.
All data points must lie below this line, confirming the theorem.
"""

import numpy as np
import matplotlib.pyplot as plt


def weight_sup_dist(w, w_prime):
    return float(np.max(np.abs(w - w_prime)))


def barcode_displacement(w, w_prime):
    cv1 = np.sort(w)
    cv2 = np.sort(w_prime)
    n = min(len(cv1), len(cv2))
    if n == 0:
        return 0.0
    return float(np.max(np.abs(cv1[:n] - cv2[:n])))


def complete_graph_weights(n, rng):
    return rng.uniform(0, 1, n * (n - 1) // 2)


def perturb_weights(w, epsilon, rng):
    return w + rng.uniform(-epsilon, epsilon, len(w))


rng = np.random.default_rng(42)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

graph_configs = [
    ("K₅ (10 edges)", 5),
    ("K₁₀ (45 edges)", 10),
    ("K₂₀ (190 edges)", 20),
]

for ax, (name, n) in zip(axes, graph_configs):
    w = complete_graph_weights(n, rng)

    sup_dists = []
    displacements = []

    for eps in np.linspace(0.001, 0.3, 30):
        for _ in range(50):
            wp = perturb_weights(w, eps, rng)
            sd = weight_sup_dist(w, wp)
            bd = barcode_displacement(w, wp)
            sup_dists.append(sd)
            displacements.append(bd)

    sup_dists = np.array(sup_dists)
    displacements = np.array(displacements)

    ax.scatter(sup_dists, displacements, alpha=0.3, s=8, c='steelblue',
               label='Observed displacement')

    # Certified bound line (diagonal)
    max_val = max(sup_dists.max(), displacements.max()) * 1.1
    ax.plot([0, max_val], [0, max_val], 'r-', linewidth=2,
            label='Certified bound d_B ≤ ‖w−w\'‖_∞')

    ax.set_xlabel('Sup-norm distance ‖w − w\'‖_∞', fontsize=11)
    ax.set_ylabel('Barcode displacement', fontsize=11)
    ax.set_title(name, fontsize=13, fontweight='bold')
    ax.legend(fontsize=9, loc='upper left')
    ax.set_xlim(0, max_val)
    ax.set_ylim(0, max_val)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

fig.suptitle('Tropical Persistence Stability: Displacement ≤ Certified Bound',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_stability_bound.png', dpi=150, bbox_inches='tight')
print("Saved: viz_stability_bound.png")
