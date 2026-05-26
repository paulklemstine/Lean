#!/usr/bin/env python3
"""
Visualization 3: Position Heatmap and Inversion Current

Shows the evolution of tagged card position distribution over time as a
heatmap, revealing the transition from concentrated to spread-out distribution.
Also shows the inversion-current bridge (Theorem 4).
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

def tagged_inversion_count(perm, j):
    pos_j = perm.index(j)
    return sum(1 for k in range(j + 1, len(perm)) if perm.index(k) < pos_j)

np.random.seed(42)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Position distribution heatmap
ax = axes[0, 0]
n = 10
j = 5
max_time = 200
num_trials = 5000
time_bins = list(range(0, max_time + 1, 5))
heatmap = np.zeros((n, len(time_bins)))

for trial in range(num_trials):
    perm = identity_perm(n)
    t_idx = 0
    for t in range(max_time + 1):
        if t_idx < len(time_bins) and t == time_bins[t_idx]:
            pos = perm.index(j)
            heatmap[pos, t_idx] += 1
            t_idx += 1
        if t < max_time:
            perm = swap_step(perm)

heatmap /= num_trials
im = ax.imshow(heatmap, aspect='auto', origin='lower', cmap='hot',
               extent=[0, max_time, -0.5, n - 0.5])
ax.set_xlabel('Time t', fontsize=11)
ax.set_ylabel('Position', fontsize=11)
ax.set_title(f'Position Distribution Heatmap (n={n}, j={j})', fontsize=12, fontweight='bold')
plt.colorbar(im, ax=ax, label='Probability')

# Panel 2: Increment vs inversion change correlation
ax = axes[0, 1]
increments = []
inv_changes = []
for _ in range(30000):
    perm = list(np.random.permutation(n))
    i = np.random.randint(0, n - 1)
    
    old_pos = perm.index(j)
    old_inv = tagged_inversion_count(perm, j)
    
    perm[i], perm[i+1] = perm[i+1], perm[i]
    
    new_pos = perm.index(j)
    new_inv = tagged_inversion_count(perm, j)
    
    increments.append(new_pos - old_pos)
    inv_changes.append(new_inv - old_inv)

# Create scatter with jitter for visibility
inc_arr = np.array(increments)
inv_arr = np.array(inv_changes)
jitter_x = np.random.normal(0, 0.05, len(inc_arr))
jitter_y = np.random.normal(0, 0.05, len(inv_arr))
ax.scatter(inc_arr + jitter_x, inv_arr + jitter_y, alpha=0.01, s=1, c='blue')

# Count matrix
for dx in [-1, 0, 1]:
    for di in [-2, -1, 0, 1, 2]:
        mask = (inc_arr == dx) & (inv_arr == di)
        count = np.sum(mask)
        if count > 0:
            ax.annotate(f'{count}', (dx, di), ha='center', va='center',
                       fontsize=8, fontweight='bold',
                       bbox=dict(boxstyle='round,pad=0.2', facecolor='yellow', alpha=0.8))

ax.set_xlabel('Position increment Δⱼ', fontsize=11)
ax.set_ylabel('Inversion change ΔIⱼ', fontsize=11)
ax.set_title('Increment–Inversion Bridge (Theorem 4)', fontsize=12, fontweight='bold')
ax.set_xticks([-1, 0, 1])
ax.set_yticks([-2, -1, 0, 1, 2])
ax.grid(True, alpha=0.3)

# Panel 3: Convergence to uniform distribution
ax = axes[1, 0]
n = 8
j = 4
times_to_show = [0, 5, 20, 50, 100, 500]
num_trials = 10000

for t in times_to_show:
    pos_counts = np.zeros(n)
    for _ in range(num_trials):
        perm = identity_perm(n)
        for _ in range(t):
            perm = swap_step(perm)
        pos_counts[perm.index(j)] += 1
    pos_counts /= num_trials
    ax.plot(range(n), pos_counts, 'o-', markersize=4, linewidth=1.5, 
            label=f't={t}', alpha=0.8)

ax.axhline(y=1/n, color='black', linestyle='--', alpha=0.5, label='Uniform')
ax.set_xlabel('Position', fontsize=11)
ax.set_ylabel('Probability', fontsize=11)
ax.set_title(f'Convergence to Equilibrium (n={n}, j={j})', fontsize=12, fontweight='bold')
ax.legend(fontsize=8, ncol=2)

# Panel 4: Compensated current J_j(t)
ax = axes[1, 1]
n = 10
j = 5
num_steps = 500
for traj in range(6):
    perm = identity_perm(n)
    positions = [perm.index(j)]
    for _ in range(num_steps):
        perm = swap_step(perm)
        positions.append(perm.index(j))
    
    positions = np.array(positions, dtype=float)
    # Drift-corrected current (drift ≈ 0 for symmetric walk)
    drift = np.mean(np.diff(positions))
    t_arr = np.arange(len(positions))
    current = positions - positions[0] - drift * t_arr
    ax.plot(t_arr, current, alpha=0.5, linewidth=0.8)

ax.set_xlabel('Time t', fontsize=11)
ax.set_ylabel('Compensated current J_j(t)', fontsize=11)
ax.set_title(f'Drift-Corrected Current (n={n}, j={j})', fontsize=12, fontweight='bold')
ax.axhline(y=0, color='black', linestyle='--', alpha=0.3)

plt.suptitle('Tagged-Card Observables: Position, Inversions, and Current', 
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_heatmap.png")
