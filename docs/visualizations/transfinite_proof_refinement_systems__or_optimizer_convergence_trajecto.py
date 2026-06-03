#!/usr/bin/env python3
"""
Visualization: Optimizer Convergence Trajectories

Shows how different optimizers converge to fixed points,
demonstrating the ω-Step Theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def halving_optimizer(x: int) -> int:
    return x // 2

def greedy_optimizer(x: int) -> int:
    return max(0, x - 1)

def sqrt_optimizer(x: int) -> int:
    return int(x ** 0.5)

def log_optimizer(x: int) -> int:
    if x <= 1:
        return 0
    return max(0, int(np.log2(x)))

def get_trajectory(optimizer, initial, max_steps=200):
    trajectory = [initial]
    x = initial
    for _ in range(max_steps):
        x_new = optimizer(x)
        trajectory.append(x_new)
        if x_new == x:
            break
        x = x_new
    return trajectory

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Optimizer Convergence Trajectories\n(ω-Step Theorem: All Must Stabilize)',
             fontsize=14, fontweight='bold')

initial = 1000
optimizers = [
    ("Greedy (−1)", greedy_optimizer),
    ("Halving (÷2)", halving_optimizer),
    ("Square Root (√)", sqrt_optimizer),
    ("Logarithmic (log₂)", log_optimizer),
]

colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

for idx, ((name, opt), color) in enumerate(zip(optimizers, colors)):
    ax = axes[idx // 2][idx % 2]
    traj = get_trajectory(opt, initial)
    steps = list(range(len(traj)))

    ax.plot(steps, traj, '-o', color=color, markersize=3, linewidth=1.5, label=name)
    ax.axhline(y=traj[-1], color='gray', linestyle='--', alpha=0.5, label=f'Fixed point = {traj[-1]}')

    # Mark stabilization point
    stab = len(traj) - 1
    for i in range(len(traj) - 1):
        if traj[i] == traj[-1]:
            stab = i
            break
    ax.axvline(x=stab, color='orange', linestyle=':', alpha=0.7, label=f'N = {stab}')

    ax.set_xlabel('Iteration Step')
    ax.set_ylabel('Complexity')
    ax.set_title(f'{name} (N = {stab} steps)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('convergence_trajectories.png', dpi=150, bbox_inches='tight')
print("Saved: convergence_trajectories.png")

# Second figure: multiple initial values
fig2, ax2 = plt.subplots(figsize=(12, 6))
for initial_val in [100, 500, 1000, 5000, 10000]:
    traj = get_trajectory(halving_optimizer, initial_val, max_steps=30)
    ax2.plot(range(len(traj)), traj, '-o', markersize=4,
             label=f'Initial = {initial_val}')

ax2.set_xlabel('Iteration Step', fontsize=12)
ax2.set_ylabel('Complexity', fontsize=12)
ax2.set_title('Halving Optimizer: Convergence from Different Initial Values', fontsize=14)
ax2.legend()
ax2.grid(True, alpha=0.3)
ax2.set_yscale('log')

plt.tight_layout()
plt.savefig('convergence_initial_values.png', dpi=150, bbox_inches='tight')
print("Saved: convergence_initial_values.png")
