"""
Visualization 1: Depth-Sensitive Potential Decrease During Exchange Descent

Shows how the depth-aware potential Φ_k decreases during exchange descent
at different certificate depths. Higher depth k means larger minimum
decrease per step (δ_k = c/d^{d-k}), leading to fewer total steps.

The key insight: certificate depth controls the "granularity" of progress,
analogous to how curvature controls convergence rate in continuous optimization.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct


def depth_decrement(d, k, c=1.0):
    """Compute δ_k = c / d^{d-k}."""
    return c / (d ** (d - k))


def generate_family(d, box_size=3):
    """Generate exchange family on hyperplane sum(x)=0."""
    ranges = [range(-box_size, box_size + 1) for _ in range(d)]
    points = []
    for pt in iterproduct(*ranges):
        if sum(pt) == 0:
            points.append(list(pt))
    return np.array(points, dtype=int)


def make_objective(d, depth):
    """Create a separable objective with tunable depth."""
    np.random.seed(42)
    centers = np.random.uniform(-1, 1, size=d)
    scales = np.random.uniform(0.5, 2.0, size=d)
    sigma_factor = 1.0 / (1 + 0.3 * depth)

    def f(x):
        return sum((x[i] - centers[i])**2 / (2 * (scales[i] * sigma_factor)**2)
                   for i in range(d))
    return f


def run_descent(points, f, x0, d):
    """Run exchange descent tracking potential."""
    S_set = {tuple(p) for p in points}
    opt_val = min(f(p) for p in points)

    x = x0.copy()
    f_vals = [f(x)]
    potentials = [f(x) - opt_val + np.sum(np.abs(x))]

    for _ in range(5000):
        best_y, best_v = None, f(x)
        for i in range(d):
            for j in range(d):
                if i == j:
                    continue
                y = x.copy()
                y[i] += 1
                y[j] -= 1
                if tuple(y) in S_set and f(y) < best_v:
                    best_v = f(y)
                    best_y = y.copy()
        if best_y is None:
            break
        x = best_y
        f_vals.append(f(x))
        potentials.append(f(x) - opt_val + np.sum(np.abs(x)))

    return f_vals, potentials


# Generate data
d = 5
points = generate_family(d, box_size=2)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Potential trajectories at different depths
ax1 = axes[0]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']

for depth_idx, depth in enumerate([1, 2, 3, 4, 5]):
    f = make_objective(d, depth)

    # Find worst starting point
    worst_idx = max(range(len(points)), key=lambda i: f(points[i]))
    x0 = points[worst_idx]

    f_vals, potentials = run_descent(points, f, x0, d)

    # Normalize potential
    if potentials:
        pot_max = potentials[0]
        pot_normalized = [p / max(pot_max, 1e-10) for p in potentials]
        ax1.plot(range(len(pot_normalized)), pot_normalized,
                color=colors[depth_idx], linewidth=2,
                label=f'depth k={depth}', alpha=0.85)

ax1.set_xlabel('Descent Step', fontsize=13)
ax1.set_ylabel('Normalized Potential Φ_k / Φ_k(x₀)', fontsize=13)
ax1.set_title('Potential Decrease at Different Certificate Depths', fontsize=14)
ax1.legend(fontsize=11, loc='upper right')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-0.05, 1.05)

# Panel 2: Step count vs depth
ax2 = axes[1]
depths_list = list(range(1, d + 1))
step_counts = []
theoretical_bounds = []

f_base = make_objective(d, d)
worst_idx = max(range(len(points)), key=lambda i: f_base(points[i]))
x0 = points[worst_idx]
D = 0
for i in range(len(points)):
    for j in range(i+1, len(points)):
        dist = int(np.sum(np.abs(points[i] - points[j])))
        D = max(D, dist)

for depth in depths_list:
    f = make_objective(d, depth)
    f_vals, _ = run_descent(points, f, x0, d)
    step_counts.append(len(f_vals) - 1)

    delta_k = depth_decrement(d, depth)
    bound = 2.0 * D / delta_k if delta_k > 0 else 0
    theoretical_bounds.append(bound)

ax2.bar([k - 0.2 for k in depths_list], step_counts, width=0.35,
       color='#3498db', label='Actual steps', alpha=0.8)
ax2.bar([k + 0.2 for k in depths_list],
       [min(b, max(step_counts) * 3) for b in theoretical_bounds],
       width=0.35, color='#e74c3c', label='Theoretical bound', alpha=0.5)

ax2.set_xlabel('Certificate Depth k', fontsize=13)
ax2.set_ylabel('Number of Steps', fontsize=13)
ax2.set_title(f'Steps vs Depth (d={d}, D={D})', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3, axis='y')
ax2.set_xticks(depths_list)

plt.tight_layout()
plt.savefig('viz_descent_potential.png', dpi=150, bbox_inches='tight')
print("Saved viz_descent_potential.png")
