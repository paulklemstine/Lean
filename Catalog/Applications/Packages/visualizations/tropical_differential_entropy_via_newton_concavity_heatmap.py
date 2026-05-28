"""
Visualization 3: Log-Concavity Heatmap

Creates a heatmap showing the log-concavity ratio c(k+1)²/(c(k)·c(k+2)) 
across different support families and shadow steps. All values ≥ 1 confirms
the log-concavity conjecture.
"""

import itertools
import math
import matplotlib.pyplot as plt
import matplotlib
import numpy as np

matplotlib.rcParams['font.size'] = 11

# ============================================================
# Self-contained core functions
# ============================================================

def total_mass(v):
    return sum(v)

def _gen_multiindex(remaining, bound, idx, n, current, results):
    if idx == n - 1:
        if remaining <= bound[idx]:
            results.append(tuple(current + [remaining]))
        return
    for v in range(min(remaining, bound[idx]) + 1):
        current.append(v)
        _gen_multiindex(remaining - v, bound, idx + 1, n, current, results)
        current.pop()

def kth_shadow(S, k, n):
    if not S:
        return set()
    shadow = set()
    for alpha in S:
        results = []
        _gen_multiindex(k, alpha, 0, n, [], results)
        for tau in results:
            beta = tuple(alpha[i] - tau[i] for i in range(n))
            shadow.add(beta)
    return shadow

def shadow_card(S, k, n):
    return len(kth_shadow(S, k, n))

def support_max_deg(S):
    return max((total_mass(v) for v in S), default=0)

def compute_shadow_profile(S, n):
    D = support_max_deg(S)
    return [shadow_card(S, k, n) for k in range(D + 1)]

def simplex_support(n, d):
    result = set()
    def gen(remaining, idx, current):
        if idx == n:
            result.add(tuple(current))
            return
        for v in range(remaining + 1):
            current.append(v)
            gen(remaining - v, idx + 1, current)
            current.pop()
    gen(d, 0, [])
    return result

def box_support(bounds):
    ranges = [range(b + 1) for b in bounds]
    return set(itertools.product(*ranges))

# ============================================================
# Compute data
# ============================================================

cases = [
    ("Σ(2,3)", simplex_support(2, 3), 2),
    ("Σ(2,4)", simplex_support(2, 4), 2),
    ("Σ(2,5)", simplex_support(2, 5), 2),
    ("Σ(2,6)", simplex_support(2, 6), 2),
    ("Σ(3,3)", simplex_support(3, 3), 3),
    ("Σ(3,4)", simplex_support(3, 4), 3),
    ("B(2,3)", box_support((2, 3)), 2),
    ("B(3,3)", box_support((3, 3)), 2),
    ("B(2,4)", box_support((2, 4)), 2),
    ("B(4,4)", box_support((4, 4)), 2),
    ("B(2,2,2)", box_support((2, 2, 2)), 3),
    ("B(1,2,3)", box_support((1, 2, 3)), 3),
]

# Find max number of LC ratio values
max_ratios = 0
for name, S, n in cases:
    profile = compute_shadow_profile(S, n)
    nr = len(profile) - 2
    if nr > max_ratios:
        max_ratios = nr

# Build ratio matrix
ratio_matrix = np.full((len(cases), max_ratios), np.nan)
names = []

for i, (name, S, n) in enumerate(cases):
    profile = compute_shadow_profile(S, n)
    names.append(f"{name} |S|={len(S)}")
    for k in range(len(profile) - 2):
        if profile[k] * profile[k+2] > 0:
            ratio_matrix[i, k] = profile[k+1]**2 / (profile[k] * profile[k+2])
        elif profile[k+1] > 0:
            ratio_matrix[i, k] = float('inf')

# ============================================================
# Plotting
# ============================================================

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7), 
                                 gridspec_kw={'width_ratios': [2, 1]})

fig.suptitle('Log-Concavity of Shadow Profiles: Computational Evidence', 
             fontsize=14, fontweight='bold')

# Left: Heatmap
# Replace inf with a cap for visualization
ratio_display = np.copy(ratio_matrix)
ratio_display[np.isinf(ratio_display)] = 5.0
ratio_display = np.where(np.isnan(ratio_display), 0, ratio_display)

im = ax1.imshow(ratio_display, aspect='auto', cmap='RdYlGn', vmin=0.8, vmax=3.0)
ax1.set_yticks(range(len(names)))
ax1.set_yticklabels(names, fontsize=9)
ax1.set_xticks(range(max_ratios))
ax1.set_xticklabels([f'k={k}' for k in range(max_ratios)])
ax1.set_xlabel('Shadow step k')
ax1.set_title('c(k+1)²/[c(k)·c(k+2)]  (green = log-concave, ≥ 1)')

# Add text annotations
for i in range(len(cases)):
    for j in range(max_ratios):
        val = ratio_matrix[i, j]
        if not np.isnan(val) and not np.isinf(val):
            text_color = 'white' if val < 1.2 else 'black'
            ax1.text(j, i, f'{val:.2f}', ha='center', va='center', 
                    fontsize=8, color=text_color, fontweight='bold')
        elif np.isinf(val):
            ax1.text(j, i, '∞', ha='center', va='center',
                    fontsize=9, color='darkgreen', fontweight='bold')

cbar = plt.colorbar(im, ax=ax1, shrink=0.8)
cbar.set_label('LC ratio')

# Right: Summary bar chart showing minimum LC ratio per support
min_ratios = []
support_names = []
for i, (name, S, n) in enumerate(cases):
    profile = compute_shadow_profile(S, n)
    ratios = []
    for k in range(len(profile) - 2):
        if profile[k] * profile[k+2] > 0:
            ratios.append(profile[k+1]**2 / (profile[k] * profile[k+2]))
    if ratios:
        min_ratios.append(min(ratios))
        support_names.append(name)

colors_bar = ['#4CAF50' if r >= 1 else '#f44336' for r in min_ratios]
bars = ax2.barh(range(len(min_ratios)), min_ratios, color=colors_bar, edgecolor='black', linewidth=0.5)
ax2.axvline(x=1, color='red', linestyle='--', linewidth=2, label='LC threshold')
ax2.set_yticks(range(len(support_names)))
ax2.set_yticklabels(support_names, fontsize=9)
ax2.set_xlabel('Minimum LC ratio')
ax2.set_title('Min c(k+1)²/[c(k)·c(k+2)]')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3, axis='x')

# Add value labels
for i, v in enumerate(min_ratios):
    ax2.text(v + 0.02, i, f'{v:.3f}', va='center', fontsize=9, fontweight='bold')

plt.tight_layout()
plt.savefig('concavity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved concavity_heatmap.png")
