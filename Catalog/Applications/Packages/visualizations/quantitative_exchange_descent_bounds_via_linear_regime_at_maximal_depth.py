#!/usr/bin/env python3
"""
Visualization: Linear Regime at Maximal Depth

Demonstrates Theorem B: when certificate depth k equals dimension d,
descent terminates in O(D) steps — a linear relationship between
step count and exchange diameter.

This script is fully self-contained and does not import local modules.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import itertools
from dataclasses import dataclass


# --- Self-contained infrastructure ---

@dataclass
class ExchangeFamily:
    points: np.ndarray
    dimension: int

    def __post_init__(self):
        self.point_set = {tuple(p) for p in self.points}

    @property
    def size(self):
        return len(self.points)

    def contains(self, x):
        return tuple(x) in self.point_set

    def diameter(self):
        if self.size <= 1:
            return 0
        dists = np.sum(np.abs(
            self.points[:, None, :] - self.points[None, :, :]
        ), axis=2)
        return int(np.max(dists))


def generate_box_family(d, radius):
    ranges = [range(-radius, radius + 1) for _ in range(d)]
    points = [list(x) for x in itertools.product(*ranges) if sum(x) == 0]
    if not points:
        points = [[0] * d]
    return ExchangeFamily(np.array(points, dtype=int), d)


def exchange_descent_count(S, f, x0, max_steps=50000):
    x = x0.copy()
    d = S.dimension
    for step in range(max_steps):
        best_y = None
        best_fy = f(x)
        for i in range(d):
            for j in range(d):
                if i == j:
                    continue
                y = x.copy()
                y[i] += 1
                y[j] -= 1
                if S.contains(y) and f(y) < best_fy:
                    best_fy = f(y)
                    best_y = y.copy()
        if best_y is None:
            return step
        x = best_y
    return max_steps


# --- Experiment: Steps vs Diameter at maximal depth ---

dimensions = [3, 4, 5, 6]
radii = [1, 2, 3, 4, 5]
n_trials = 5

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Collect data for each dimension
for d in dimensions:
    diameters = []
    avg_steps = []
    std_steps = []

    for radius in radii:
        S = generate_box_family(d, radius)
        if S.size < 2:
            continue

        D = S.diameter()

        # Separable Gaussian objective (maximal depth)
        def f(x, d=d):
            return sum((x[i])**2 for i in range(d))

        steps_list = []
        for trial in range(n_trials):
            rng = np.random.RandomState(trial + d * 1000 + radius * 100)
            idx = rng.randint(0, S.size)
            steps = exchange_descent_count(S, f, S.points[idx])
            steps_list.append(steps)

        diameters.append(D)
        avg_steps.append(np.mean(steps_list))
        std_steps.append(np.std(steps_list))

    if diameters:
        diameters = np.array(diameters)
        avg_steps = np.array(avg_steps)
        std_steps = np.array(std_steps)

        # Plot steps vs diameter
        axes[0].errorbar(diameters, avg_steps, yerr=std_steps,
                         fmt='o-', label=f'd={d}', capsize=3,
                         markersize=6, linewidth=2)

        # Plot steps/D vs diameter (should be roughly constant)
        ratio = avg_steps / np.maximum(diameters, 1)
        axes[1].plot(diameters, ratio, 's-', label=f'd={d}',
                     markersize=6, linewidth=2)

# Plot 1: Steps vs Diameter
axes[0].set_xlabel('Exchange Diameter D', fontsize=12)
axes[0].set_ylabel('Average Steps to Optimum', fontsize=12)
axes[0].set_title('Theorem B: Steps vs Diameter at Max Depth (k=d)', fontsize=13)
axes[0].legend(fontsize=10)
axes[0].grid(True, alpha=0.3)

# Add reference lines
for d in dimensions:
    S_ref = generate_box_family(d, max(radii))
    if S_ref.size >= 2:
        D_max = S_ref.diameter()
        axes[0].plot([0, D_max], [0, D_max], '--', alpha=0.3, color='gray')

axes[0].text(0.05, 0.95, 'Dashed: slope 1 (linear)',
             transform=axes[0].transAxes, fontsize=9, alpha=0.6,
             verticalalignment='top')

# Plot 2: Steps/D ratio
axes[1].set_xlabel('Exchange Diameter D', fontsize=12)
axes[1].set_ylabel('Steps / Diameter', fontsize=12)
axes[1].set_title('Linearity Check: Steps/D Should Be Bounded', fontsize=13)
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)
axes[1].axhline(y=1, color='gray', linestyle='--', alpha=0.3)

plt.suptitle('Linear Bound T ≤ C·D at Maximal Certificate Depth',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_linear_regime.png', dpi=150, bbox_inches='tight')
print("Saved viz_linear_regime.png")
