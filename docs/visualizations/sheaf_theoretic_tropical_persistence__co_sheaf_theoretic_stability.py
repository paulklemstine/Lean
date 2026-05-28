"""
Visualization: Sheaf-Theoretic Stability
=========================================

Visualizes the stability theorem: when two filtrations are ε-close,
their sheaf event profiles are ε-interleaved. Shows the original
and perturbed profiles with the interleaving bands.

Uses matplotlib to produce a static PNG.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import random
from typing import List, Tuple, Dict


# ─── Self-contained infrastructure ──────────────────────────────────

def path_edges(n: int) -> List[Tuple[int, int]]:
    return [(i, i + 1) for i in range(n)]

def degree(edges: List[Tuple[int, int]], v: int) -> int:
    return sum(1 for (a, b) in edges if a == v or b == v)

def sheaf_jump(edges: List[Tuple[int, int]], filt: Dict[int, float], c: float) -> int:
    return sum(degree(edges, v) + 1 for v, ft in filt.items() if ft == c)

def cum_profile(edges: List[Tuple[int, int]], filt: Dict[int, float], t: float) -> int:
    crits = sorted(set(filt.values()))
    return sum(sheaf_jump(edges, filt, c) for c in crits if c <= t)


# ─── Setup ───────────────────────────────────────────────────────────

n = 7
edges = path_edges(n)
filt1 = {i: float(i) for i in range(n + 1)}

random.seed(42)
epsilon = 0.5
filt2 = {i: filt1[i] + random.uniform(-epsilon, epsilon) for i in range(n + 1)}
actual_eps = max(abs(filt1[v] - filt2[v]) for v in filt1)

# Sample points
t_vals = [i * 0.1 for i in range(-15, n * 10 + 20)]

prof1 = [cum_profile(edges, filt1, t) for t in t_vals]
prof2 = [cum_profile(edges, filt2, t) for t in t_vals]
prof2_shifted = [cum_profile(edges, filt2, t + actual_eps) for t in t_vals]
prof1_shifted = [cum_profile(edges, filt1, t + actual_eps) for t in t_vals]

# ─── Plot ────────────────────────────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: profiles with interleaving
ax1.plot(t_vals, prof1, color='#2196F3', linewidth=2.5, label='Original filtration f₁')
ax1.plot(t_vals, prof2, color='#F44336', linewidth=2.5, label='Perturbed filtration f₂')
ax1.plot(t_vals, prof2_shifted, color='#F44336', linewidth=1, linestyle='--',
         alpha=0.5, label=f'f₂(t + ε)')
ax1.plot(t_vals, prof1_shifted, color='#2196F3', linewidth=1, linestyle='--',
         alpha=0.5, label=f'f₁(t + ε)')

# Shade interleaving region
ax1.fill_between(t_vals, prof1, prof2_shifted, alpha=0.1, color='green')

ax1.set_xlabel('Threshold t', fontsize=12)
ax1.set_ylabel('Sheaf Event Profile', fontsize=12)
ax1.set_title(f'Stability: ε-Interleaving (ε = {actual_eps:.3f})', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-1, n + 1)

# Right panel: profile difference
diffs = [abs(p1 - p2) for p1, p2 in zip(prof1, prof2)]
max_shift_bound = [max(cum_profile(edges, filt2, t + actual_eps) - cum_profile(edges, filt2, t),
                       cum_profile(edges, filt1, t + actual_eps) - cum_profile(edges, filt1, t))
                   for t in t_vals]

ax2.fill_between(t_vals, 0, max_shift_bound, alpha=0.2, color='orange', label='Stability bound')
ax2.plot(t_vals, diffs, color='#4CAF50', linewidth=2, label='|Profile₁ - Profile₂|')
ax2.plot(t_vals, max_shift_bound, color='orange', linewidth=1, linestyle='--', alpha=0.7)

ax2.set_xlabel('Threshold t', fontsize=12)
ax2.set_ylabel('Profile Difference', fontsize=12)
ax2.set_title('Sheaf-Theoretic Stability Bound', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-1, n + 1)

plt.tight_layout()
plt.savefig('stability_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: stability_visualization.png")
