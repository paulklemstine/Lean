#!/usr/bin/env python3
"""
Visualization 3: Phase Transition Detection via Newton Inequality

Shows how the Newton inequality ratio transitions from > 1 (log-concave)
to < 1 (non-log-concave) as coupling strength increases, for various graphs.
This transition is a precursor to the ferromagnetic phase transition.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
import math


def powerset(s):
    s = list(s)
    return [frozenset(s[j] for j in range(len(s)) if i & (1 << j)) for i in range(2**len(s))]


def level_weights(vertices, edges, J, beta):
    n = len(vertices)
    lw = np.zeros(n + 1)
    for S in powerset(vertices):
        energy = sum(J.get((u,v), J.get((v,u), 0.0))
                     for u, v in edges
                     if (u in S and v in S) or (u not in S and v not in S))
        lw[len(S)] += math.exp(beta * energy)
    return lw


def min_newton_ratio(lw):
    min_r = float('inf')
    for k in range(1, len(lw) - 1):
        if lw[k-1] * lw[k+1] > 0:
            r = lw[k]**2 / (lw[k-1] * lw[k+1])
            min_r = min(min_r, r)
    return min_r


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- K2 ---
ax = axes[0]
betas = np.linspace(0.001, 2.5, 200)
ratios_k2 = []
for b in betas:
    a0 = math.exp(b)
    a1 = 2.0
    a2 = math.exp(b)
    ratios_k2.append(a1**2 / (a0 * a2))

ax.plot(betas, ratios_k2, 'b-', linewidth=2.5)
ax.axhline(y=1, color='red', linestyle='--', linewidth=1.5)
ax.axvline(x=np.log(2), color='orange', linestyle=':', linewidth=2,
           label=f'βJ = ln 2 ≈ {np.log(2):.3f}')
ax.fill_between(betas, ratios_k2, 1,
                where=np.array(ratios_k2) >= 1, alpha=0.2, color='green')
ax.fill_between(betas, ratios_k2, 1,
                where=np.array(ratios_k2) < 1, alpha=0.2, color='red')
ax.set_xlabel(r'$\beta J$', fontsize=12)
ax.set_ylabel('Min Newton ratio', fontsize=12)
ax.set_title('K₂ (Two Spins)\nSharp threshold proved', fontsize=13)
ax.legend(fontsize=10)
ax.set_xlim(0, 2.5)
ax.set_ylim(0, 5)

# --- K3 ---
ax = axes[1]
vertices3 = [0, 1, 2]
edges3 = [(0,1), (0,2), (1,2)]
J3 = {e: 1.0 for e in edges3}

ratios_k3 = []
for b in betas:
    lw = level_weights(vertices3, edges3, J3, b)
    ratios_k3.append(min_newton_ratio(lw))

ax.plot(betas, ratios_k3, 'g-', linewidth=2.5)
ax.axhline(y=1, color='red', linestyle='--', linewidth=1.5)

# Find threshold
threshold_k3 = None
for i, r in enumerate(ratios_k3):
    if r < 1:
        threshold_k3 = betas[i]
        break

if threshold_k3:
    ax.axvline(x=threshold_k3, color='orange', linestyle=':', linewidth=2,
               label=f'Threshold ≈ {threshold_k3:.3f}')

ax.fill_between(betas, ratios_k3, 1,
                where=np.array(ratios_k3) >= 1, alpha=0.2, color='green')
ax.fill_between(betas, ratios_k3, 1,
                where=np.array(ratios_k3) < 1, alpha=0.2, color='red')
ax.set_xlabel(r'$\beta J$', fontsize=12)
ax.set_ylabel('Min Newton ratio', fontsize=12)
ax.set_title('K₃ (Triangle)', fontsize=13)
ax.legend(fontsize=10)
ax.set_xlim(0, 2.5)
ax.set_ylim(0, 5)

# --- K4 ---
ax = axes[2]
vertices4 = list(range(4))
edges4 = list(combinations(range(4), 2))
J4 = {e: 1.0 for e in edges4}

ratios_k4 = []
for b in betas:
    lw = level_weights(vertices4, edges4, J4, b)
    ratios_k4.append(min_newton_ratio(lw))

ax.plot(betas, ratios_k4, 'm-', linewidth=2.5)
ax.axhline(y=1, color='red', linestyle='--', linewidth=1.5)

threshold_k4 = None
for i, r in enumerate(ratios_k4):
    if r < 1:
        threshold_k4 = betas[i]
        break

if threshold_k4:
    ax.axvline(x=threshold_k4, color='orange', linestyle=':', linewidth=2,
               label=f'Threshold ≈ {threshold_k4:.3f}')

ax.fill_between(betas, ratios_k4, 1,
                where=np.array(ratios_k4) >= 1, alpha=0.2, color='green')
ax.fill_between(betas, ratios_k4, 1,
                where=np.array(ratios_k4) < 1, alpha=0.2, color='red')
ax.set_xlabel(r'$\beta J$', fontsize=12)
ax.set_ylabel('Min Newton ratio', fontsize=12)
ax.set_title('K₄ (Complete on 4)', fontsize=13)
ax.legend(fontsize=10)
ax.set_xlim(0, 2.5)
ax.set_ylim(0, 5)

fig.suptitle('Newton Inequality Threshold as Phase Transition Precursor',
             fontsize=15, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_transition.png")
