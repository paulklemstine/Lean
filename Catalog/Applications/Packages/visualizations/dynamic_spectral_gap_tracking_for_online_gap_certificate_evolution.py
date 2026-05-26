"""
Visualization: Online Gap Certificate Evolution

Shows how the spectral gap certificate evolves under a stream of
random rank-1 updates, comparing the online bound with the locality-
based tracking that preserves the gap exactly when no leaves are affected.

This visualizes the key support-sensitivity result: inactive updates
(affecting no leaves) cause zero gap degradation.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def enumerate_multiindices(n, total):
    if n == 0:
        return [()] if total == 0 else []
    if n == 1:
        return [(total,)]
    result = []
    for b0 in range(total + 1):
        for rest in enumerate_multiindices(n - 1, total - b0):
            result.append((b0,) + rest)
    return result


def has_affected_leaves(alpha, d):
    """Check if any (d-2)-leaf is affected by alpha."""
    n = len(alpha)
    target = d - 2
    if target < 0:
        return False
    all_leaves = enumerate_multiindices(n, target)
    return any(all(beta[i] <= alpha[i] for i in range(n)) for beta in all_leaves)


np.random.seed(42)
n, d = 6, 6
kappa = 0.5
K = 2 * kappa

n_updates = 40
initial_gap = 5.0

# Track gaps under two strategies
gap_naive = initial_gap       # Always assumes worst case
gap_locality = initial_gap    # Uses locality theorem

naive_history = [gap_naive]
locality_history = [gap_locality]
active_steps = []

for t in range(n_updates):
    # Random update with varying sparsity
    sparsity = np.random.choice([1, 1, 1, 2, 2, 3], p=[0.3, 0.2, 0.1, 0.2, 0.1, 0.1])
    support = np.random.choice(n, size=min(sparsity, n), replace=False)
    alpha = tuple(1 if i in support else 0 for i in range(n))
    c = np.random.uniform(0.01, 0.1)

    # Naive: always degrade
    gap_naive = max(0, gap_naive - K)

    # Locality-aware: only degrade when leaves are actually affected
    is_active = has_affected_leaves(alpha, d)
    active_steps.append(is_active)

    if is_active:
        gap_locality = max(0, gap_locality - K)

    naive_history.append(gap_naive)
    locality_history.append(gap_locality)

# Create visualization
fig, axes = plt.subplots(2, 1, figsize=(12, 9), gridspec_kw={'height_ratios': [3, 1]})

# Gap evolution
ax = axes[0]
steps = range(len(naive_history))
ax.plot(steps, naive_history, 'r-', linewidth=2, label='Naive bound (always degrade)', alpha=0.7)
ax.plot(steps, locality_history, 'b-', linewidth=2, label='Locality-aware bound')

# Mark active vs inactive steps
for t in range(n_updates):
    if active_steps[t]:
        ax.axvline(t + 1, color='orange', alpha=0.15, linewidth=3)
    else:
        ax.axvline(t + 1, color='green', alpha=0.1, linewidth=3)

ax.set_xlabel('Update step', fontsize=12)
ax.set_ylabel('Spectral gap lower bound', fontsize=12)
ax.set_title('Online Gap Certificate Evolution\n(Locality-Aware vs Naive Tracking)', fontsize=14)
ax.legend(fontsize=11, loc='upper right')
ax.grid(True, alpha=0.3)
ax.set_xlim(0, n_updates + 1)

# Activity indicator
ax2 = axes[1]
colors = ['orange' if a else 'green' for a in active_steps]
ax2.bar(range(1, n_updates + 1), [1] * n_updates, color=colors, width=0.8)
ax2.set_xlabel('Update step', fontsize=12)
ax2.set_ylabel('')
ax2.set_yticks([])
ax2.set_title('Update Activity (orange = leaves affected, green = gap preserved)', fontsize=11)
ax2.set_xlim(0, n_updates + 1)

n_active = sum(active_steps)
n_inactive = n_updates - n_active
fig.text(0.5, 0.01,
         f'Active updates: {n_active}/{n_updates} ({n_active/n_updates:.0%})  |  '
         f'Inactive (gap preserved): {n_inactive}/{n_updates} ({n_inactive/n_updates:.0%})  |  '
         f'Final gap: naive={naive_history[-1]:.2f}, locality={locality_history[-1]:.2f}',
         ha='center', fontsize=10, style='italic')

plt.tight_layout(rect=[0, 0.03, 1, 1])
plt.savefig('viz_gap_evolution.png', dpi=150, bbox_inches='tight')
print("Saved viz_gap_evolution.png")
