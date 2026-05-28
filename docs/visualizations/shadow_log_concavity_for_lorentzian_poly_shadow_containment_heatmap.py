"""
Visualization: Shadow Containment Heatmap

Shows the shadow containment structure as a heatmap. For each pair (k, element),
the heatmap shows which shadow layers contain which elements, revealing the
nested structure of iterated shadows.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb

# ─── Self-contained functions ────────────────────────────────────────────────

def bounded_compositions(n, total, bounds):
    results = []
    def bt(idx, rem, cur):
        if idx == n:
            if rem == 0: results.append(tuple(cur))
            return
        for v in range(min(rem, bounds[idx]) + 1):
            cur.append(v); bt(idx+1, rem-v, cur); cur.pop()
    bt(0, total, [])
    return results

def kth_shadow(S, d, k):
    target = d - k
    if target < 0: return set()
    shadow = set()
    for alpha in S:
        for beta in bounded_compositions(len(alpha), target, alpha):
            shadow.add(beta)
    return shadow

def shadow_profile(S, d):
    return [len(kth_shadow(S, d, k)) for k in range(d + 1)]

def boolean_support(n, r):
    S = set()
    for subset in combinations(range(n), r):
        vec = [0]*n
        for i in subset: vec[i] = 1
        S.add(tuple(vec))
    return S

# ─── Generate data for U_{3,6} ──────────────────────────────────────────────

n, r = 6, 3
S = boolean_support(n, r)
d = r

# Compute all shadow layers
shadows = {}
all_elements = set()
for k in range(d + 1):
    sh = kth_shadow(S, d, k)
    shadows[k] = sh
    all_elements.update(sh)

# Create figure with two panels
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Shadow profile bar chart with log-concavity annotation
prof = shadow_profile(S, d)
ks = list(range(d + 1))
colors_bar = ['#1a237e', '#1565c0', '#42a5f5', '#90caf9']

ax1.bar(ks, prof, color=[colors_bar[k] for k in ks], edgecolor='white', linewidth=1.5)
ax1.plot(ks, prof, 'ko-', markersize=8, linewidth=2, zorder=5)

for k in range(d + 1):
    ax1.text(k, prof[k] + 0.5, str(prof[k]), ha='center', va='bottom',
             fontweight='bold', fontsize=12)

# Add log-concavity check
for k in range(1, len(prof) - 1):
    denom = prof[k-1] * prof[k+1]
    if denom > 0:
        ratio = prof[k]**2 / denom
        ax1.annotate(f'ratio={ratio:.2f}',
                    xy=(k, prof[k]/2), fontsize=9,
                    ha='center', color='darkred', fontweight='bold')

ax1.set_xlabel('Shadow depth k', fontsize=12)
ax1.set_ylabel('|Sh_k(S)|', fontsize=12)
ax1.set_title(f'Shadow Profile of U_{{{r},{n}}}\n'
              f'C({n},3), C({n},2), C({n},1), C({n},0) = {prof}',
              fontsize=11, fontweight='bold')
ax1.set_xticks(ks)
ax1.grid(axis='y', alpha=0.3)

# Panel 2: Shadow containment — which original elements contribute to which shadows
# For each element in S, show how many shadow elements it generates at each level
S_list = sorted(S)
mat = np.zeros((len(S_list), d + 1))

for idx, alpha in enumerate(S_list):
    for k in range(d + 1):
        # Count elements in Sh_k that are ≤ alpha
        count = 0
        for beta in shadows[k]:
            if all(beta[i] <= alpha[i] for i in range(n)):
                count += 1
        mat[idx, k] = count

im = ax2.imshow(mat, aspect='auto', cmap='YlOrRd', interpolation='nearest')
ax2.set_xlabel('Shadow depth k', fontsize=12)
ax2.set_ylabel('Support element index', fontsize=12)
ax2.set_title('Shadow contributions per support element\n'
              '(how many shadow elements each α ∈ S generates)',
              fontsize=11, fontweight='bold')
ax2.set_xticks(range(d + 1))
plt.colorbar(im, ax=ax2, label='# shadow elements ≤ α')

fig.suptitle('Shadow Structure of a Uniform Matroid Support',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('shadow_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved shadow_heatmap.png")
