#!/usr/bin/env python3
"""
Visualization: Potential Function Descent Trajectories

Shows how the depth-aware potential Φ_k decreases during exchange descent,
comparing high-depth (fast decay) vs low-depth (slow decay) regimes.

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


def exchange_descent_trajectory(S, f, x0, max_steps=1000):
    """Return list of (step, f(x), Phi(x)) tuples."""
    x = x0.copy()
    d = S.dimension

    # Find optimum for potential computation
    opt = S.points[np.argmin([f(p) for p in S.points])]
    f_opt = f(opt)

    trajectory = []
    for step in range(max_steps):
        fx = f(x)
        dist = np.sum(np.abs(x - opt))
        phi = (fx - f_opt) + 0.5 * dist
        trajectory.append((step, fx, phi))

        best_y = None
        best_fy = fx
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
            trajectory.append((step + 1, fx, 0.0))
            break
        x = best_y

    return trajectory


# --- Generate trajectories ---

d = 5
radius = 3
S = generate_box_family(d, radius)
D = S.diameter()

# High-depth objective (separable Gaussian)
def f_high(x):
    return sum((x[i] - 0.5)**2 for i in range(d))

# Medium-depth objective
rng = np.random.RandomState(42)
A_med = np.eye(d) + 0.3 * rng.randn(d, d)
A_med = A_med @ A_med.T

def f_med(x):
    xf = np.array(x, dtype=float)
    return float(xf @ A_med @ xf)

# Low-depth objective
A_low = rng.randn(d, d)
A_low = A_low @ A_low.T + 0.1 * np.eye(d)

def f_low(x):
    xf = np.array(x, dtype=float)
    return float(xf @ A_low @ xf) + 0.5 * sum(abs(x[i]) for i in range(d))

# Find worst starting point for each
x0_high = S.points[np.argmax([f_high(p) for p in S.points])]
x0_med = S.points[np.argmax([f_med(p) for p in S.points])]
x0_low = S.points[np.argmax([f_low(p) for p in S.points])]

traj_high = exchange_descent_trajectory(S, f_high, x0_high)
traj_med = exchange_descent_trajectory(S, f_med, x0_med)
traj_low = exchange_descent_trajectory(S, f_low, x0_low)

# --- Plotting ---

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Objective value trajectories
for traj, label, color in [
    (traj_high, 'High depth (separable)', '#2ecc71'),
    (traj_med, 'Medium depth', '#e67e22'),
    (traj_low, 'Low depth (coupled)', '#e74c3c')
]:
    steps = [t[0] for t in traj]
    fvals = [t[1] for t in traj]
    axes[0].plot(steps, fvals, '-o', label=label, color=color,
                 markersize=4, linewidth=2)

axes[0].set_xlabel('Step', fontsize=12)
axes[0].set_ylabel('Objective f(x)', fontsize=12)
axes[0].set_title('Objective Descent Trajectories', fontsize=13)
axes[0].legend(fontsize=10)
axes[0].grid(True, alpha=0.3)

# Plot 2: Potential value trajectories
for traj, label, color in [
    (traj_high, 'High depth', '#2ecc71'),
    (traj_med, 'Medium depth', '#e67e22'),
    (traj_low, 'Low depth', '#e74c3c')
]:
    steps = [t[0] for t in traj]
    phis = [t[2] for t in traj]
    axes[1].plot(steps, phis, '-s', label=label, color=color,
                 markersize=4, linewidth=2)

axes[1].set_xlabel('Step', fontsize=12)
axes[1].set_ylabel('Potential Φ(x)', fontsize=12)
axes[1].set_title('Depth-Aware Potential Descent', fontsize=13)
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

# Plot 3: Per-step potential decrease
for traj, label, color in [
    (traj_high, 'High depth', '#2ecc71'),
    (traj_med, 'Medium depth', '#e67e22'),
    (traj_low, 'Low depth', '#e74c3c')
]:
    phis = [t[2] for t in traj]
    if len(phis) > 1:
        deltas = [phis[i] - phis[i+1] for i in range(len(phis)-1)]
        axes[2].plot(range(len(deltas)), deltas, '-^', label=label,
                     color=color, markersize=4, linewidth=1.5)

axes[2].axhline(y=0, color='black', linewidth=0.5, linestyle='--')
axes[2].set_xlabel('Step', fontsize=12)
axes[2].set_ylabel('ΔΦ per step', fontsize=12)
axes[2].set_title('Per-Step Potential Decrease', fontsize=13)
axes[2].legend(fontsize=10)
axes[2].grid(True, alpha=0.3)

plt.suptitle(f'Exchange Descent: d={d}, radius={radius}, D={D}',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_potential_descent.png', dpi=150, bbox_inches='tight')
print("Saved viz_potential_descent.png")
