#!/usr/bin/env python3
"""
Visualization 2: Tropical Morse Stability

Demonstrates the stability theorem: small perturbations in edge weights
produce small changes in the tropical Morse spectrum. This is the tropical
analogue of the Cohen-Steiner–Edelsbrunner–Harer persistence stability theorem.

Shows: Critical value shifts vs perturbation magnitude ε, confirming
that bottleneck distance ≤ ε.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ──── Self-contained implementations ────

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n

    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.num_components -= 1
        return True


def compute_tms_values(n, edges):
    """Return list of (critical_value, event_type) pairs."""
    events = []
    uf = UnionFind(n)
    for u, v, w in sorted(edges, key=lambda e: e[2]):
        if uf.union(u, v):
            events.append((w, "merge"))
        else:
            events.append((w, "cycle_death"))
    return events


# ──── Setup ────

# Base graph: C₆ with weights 1..6
base_n = 6
base_edges = [(i, (i+1)%6, float(i+1)) for i in range(6)]
base_tms = compute_tms_values(base_n, base_edges)
base_values = [v for v, _ in base_tms]

# Perturbation study
epsilons = np.linspace(0, 2.0, 50)
n_trials = 100

bottleneck_dists = []
mean_shifts = []
max_shifts = []

np.random.seed(42)

for eps in epsilons:
    trial_bottlenecks = []
    trial_means = []
    trial_maxes = []

    for _ in range(n_trials):
        perturbed_edges = [(u, v, w + np.random.uniform(-eps, eps))
                          for u, v, w in base_edges]
        pert_tms = compute_tms_values(base_n, perturbed_edges)
        pert_values = [v for v, _ in pert_tms]

        if len(pert_values) == len(base_values):
            shifts = [abs(a - b) for a, b in zip(base_values, pert_values)]
            trial_bottlenecks.append(max(shifts))
            trial_means.append(np.mean(shifts))
            trial_maxes.append(max(shifts))

    bottleneck_dists.append(np.mean(trial_bottlenecks) if trial_bottlenecks else 0)
    mean_shifts.append(np.mean(trial_means) if trial_means else 0)
    max_shifts.append(np.percentile(trial_maxes, 95) if trial_maxes else 0)


# ──── Plotting ────

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Bottleneck distance vs epsilon
ax1 = axes[0]
ax1.plot(epsilons, bottleneck_dists, 'b-', linewidth=2, label='Mean bottleneck dist')
ax1.plot(epsilons, max_shifts, 'r--', linewidth=1.5, alpha=0.7, label='95th percentile')
ax1.plot(epsilons, epsilons, 'k:', linewidth=1, label='y = ε (stability bound)')
ax1.set_xlabel('Perturbation magnitude ε', fontsize=12)
ax1.set_ylabel('Bottleneck distance', fontsize=12)
ax1.set_title('Stability Theorem Verification\n'
              'd_B(TMS(G), TMS(G\')) ≤ ε', fontsize=11)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Event type preservation
type_preservation = []
for eps in epsilons:
    preserved = 0
    for _ in range(n_trials):
        perturbed_edges = [(u, v, w + np.random.uniform(-eps, eps))
                          for u, v, w in base_edges]
        pert_tms = compute_tms_values(base_n, perturbed_edges)
        pert_types = [t for _, t in pert_tms]
        base_types = [t for _, t in base_tms]
        if pert_types == base_types:
            preserved += 1
    type_preservation.append(preserved / n_trials)

ax2 = axes[1]
ax2.plot(epsilons, type_preservation, 'g-', linewidth=2)
ax2.axhline(y=1.0, color='k', linestyle=':', alpha=0.3)
ax2.set_xlabel('Perturbation magnitude ε', fontsize=12)
ax2.set_ylabel('Event type preservation rate', fontsize=12)
ax2.set_title('Event Type Stability\n'
              'Fraction of trials preserving merge/cycle order', fontsize=11)
ax2.set_ylim(-0.05, 1.05)
ax2.grid(True, alpha=0.3)

# Panel 3: Critical value distributions under perturbation
ax3 = axes[2]
colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b']
eps_show = 0.8

for trial in range(min(20, n_trials)):
    perturbed_edges = [(u, v, w + np.random.uniform(-eps_show, eps_show))
                      for u, v, w in base_edges]
    pert_tms = compute_tms_values(base_n, perturbed_edges)
    pert_values = [v for v, _ in pert_tms]
    ax3.scatter(range(len(pert_values)), pert_values,
               color='lightblue', s=15, alpha=0.3, zorder=1)

ax3.scatter(range(len(base_values)), base_values,
           color='red', s=80, zorder=3, label='Original', marker='D')

# Draw ε bands
for i, bv in enumerate(base_values):
    ax3.fill_between([i-0.3, i+0.3], bv-eps_show, bv+eps_show,
                    color='red', alpha=0.1)

ax3.set_xlabel('Event index', fontsize=12)
ax3.set_ylabel('Critical value', fontsize=12)
ax3.set_title(f'Critical Value Distribution (ε={eps_show})\n'
              'Red bands: ±ε guarantee', fontsize=11)
ax3.set_xticks(range(len(base_values)))
ax3.set_xticklabels([f'{t}' for _, t in base_tms], rotation=45, fontsize=8)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('vis_stability.png', dpi=150, bbox_inches='tight')
print("Saved vis_stability.png")
