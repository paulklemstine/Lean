#!/usr/bin/env python3
"""
Visualization 1: Tagged Card Trajectories and Drift Decomposition

Shows multiple tagged card position trajectories under the adjacent-swap
walk on S_n, illustrating the random walk behavior predicted by the
drift decomposition theorem. Each step changes the tagged card position
by exactly +1, -1, or 0 (Theorem 1).

The plot reveals the diffusive spreading of position and the bounded
per-step increments that are the hallmark of exclusion-process dynamics.
"""
import numpy as np
import matplotlib.pyplot as plt

def identity_perm(n):
    return list(range(n))

def swap_step(perm):
    n = len(perm)
    i = np.random.randint(0, n - 1)
    p = perm[:]
    p[i], p[i+1] = p[i+1], p[i]
    return p

np.random.seed(42)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Multiple trajectories for n=8
ax = axes[0, 0]
n = 8
j = 4
num_steps = 300
for traj in range(8):
    perm = identity_perm(n)
    positions = [perm.index(j)]
    for _ in range(num_steps):
        perm = swap_step(perm)
        positions.append(perm.index(j))
    ax.plot(range(num_steps + 1), positions, alpha=0.6, linewidth=0.8)
ax.set_xlabel('Step t', fontsize=11)
ax.set_ylabel('Position of card j', fontsize=11)
ax.set_title(f'Tagged Card Trajectories (n={n}, j={j})', fontsize=12, fontweight='bold')
ax.axhline(y=j, color='black', linestyle='--', alpha=0.3, label='Initial position')
ax.legend(fontsize=9)

# Panel 2: Increment histogram (should be {-1, 0, 1})
ax = axes[0, 1]
increments = []
for _ in range(50000):
    perm = list(np.random.permutation(n))
    i_swap = np.random.randint(0, n - 1)
    old_pos = perm.index(j)
    perm[i_swap], perm[i_swap + 1] = perm[i_swap + 1], perm[i_swap]
    new_pos = perm.index(j)
    increments.append(new_pos - old_pos)

values, counts = np.unique(increments, return_counts=True)
colors = ['#e74c3c' if v == -1 else '#2ecc71' if v == 1 else '#3498db' for v in values]
ax.bar(values, counts / len(increments), color=colors, edgecolor='black', linewidth=0.5, width=0.6)
ax.set_xlabel('Increment Δⱼ', fontsize=11)
ax.set_ylabel('Probability', fontsize=11)
ax.set_title('Drift Decomposition: Increment Distribution', fontsize=12, fontweight='bold')
ax.set_xticks([-1, 0, 1])
for v, c in zip(values, counts):
    ax.annotate(f'{c/len(increments):.3f}', (v, c/len(increments) + 0.01), 
                ha='center', fontsize=10)

# Panel 3: Displacement variance vs time
ax = axes[1, 0]
num_trials = 2000
for n_val in [5, 6, 7, 8, 10]:
    j_val = n_val // 2
    times = list(range(0, 201, 10))
    variances = []
    for t in times:
        disps = []
        for _ in range(num_trials):
            perm = identity_perm(n_val)
            for _ in range(t):
                perm = swap_step(perm)
            disps.append(perm.index(j_val) - j_val)
        variances.append(np.var(disps))
    ax.plot(times, variances, 'o-', markersize=2, linewidth=1.5, label=f'n={n_val}')

ax.set_xlabel('Time t', fontsize=11)
ax.set_ylabel('Var(pos_j(t) − pos_j(0))', fontsize=11)
ax.set_title('Variance Growth (Theorem 2: bounded by t)', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

# Panel 4: Inversion count trajectory
ax = axes[1, 1]
n = 8
j = 4
num_steps = 200
for traj in range(5):
    perm = identity_perm(n)
    inv_counts = []
    pos_j = perm.index(j)
    inv = sum(1 for k in range(j + 1, n) if perm.index(k) < pos_j)
    inv_counts.append(inv)
    for _ in range(num_steps):
        perm = swap_step(perm)
        pos_j = perm.index(j)
        inv = sum(1 for k in range(j + 1, n) if perm.index(k) < pos_j)
        inv_counts.append(inv)
    ax.plot(range(num_steps + 1), inv_counts, alpha=0.6, linewidth=0.8)

ax.set_xlabel('Step t', fontsize=11)
ax.set_ylabel('Inversion count I_j(σ)', fontsize=11)
ax.set_title(f'Inversion Count Trajectories (n={n}, j={j})', fontsize=12, fontweight='bold')

plt.suptitle('Tagged-Card Dynamics: TASEP Signatures in Permutation Walks', 
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_trajectories.png', dpi=150, bbox_inches='tight')
print("Saved viz_trajectories.png")
