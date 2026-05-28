"""
Visualization: Semigroup Flow of the Shadow Operator

Illustrates the semigroup law Shadow_b(Shadow_a(S)) = Shadow_{a+b}(S)
as a commutative flow diagram, and shows the shadow profile decay curves
for multiple support families.

This script is fully self-contained — all needed functions are inlined.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from math import comb


# --- Self-contained core functions ---

def enumerate_sub_indices(alpha, k):
    n = len(alpha)
    results = set()
    def backtrack(pos, rem, cur):
        if pos == n:
            if rem == 0:
                results.add(tuple(cur))
            return
        for t in range(min(alpha[pos], rem) + 1):
            cur.append(alpha[pos] - t)
            backtrack(pos + 1, rem - t, cur)
            cur.pop()
    backtrack(0, k, [])
    return results

def kth_shadow(S, k):
    shadow = set()
    for alpha in S:
        shadow.update(enumerate_sub_indices(alpha, k))
    return shadow

def shadow_profile(S, max_k=None):
    if not S:
        return [0]
    if max_k is None:
        max_k = max(sum(a) for a in S)
    return [len(kth_shadow(S, k)) for k in range(max_k + 1)]

def uniform_matroid_support(n, r):
    result = set()
    for combo in combinations(range(n), r):
        vec = [0] * n
        for i in combo:
            vec[i] = 1
        result.add(tuple(vec))
    return result

def homogeneous_support(n, d):
    def gen(pos, rem):
        if pos == n - 1:
            yield (rem,)
            return
        for v in range(rem + 1):
            for rest in gen(pos + 1, rem - v):
                yield (v,) + rest
    if n == 0:
        return {()} if d == 0 else set()
    return set(gen(0, d))


# --- Figure ---
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Semigroup verification grid
ax = axes[0]
S = homogeneous_support(3, 4)
max_ab = 5
grid = np.zeros((max_ab, max_ab))
for a in range(max_ab):
    for b in range(max_ab):
        lhs = kth_shadow(kth_shadow(S, a), b)
        rhs = kth_shadow(S, a + b)
        grid[b, a] = 1 if lhs == rhs else 0

im = ax.imshow(grid, cmap='Greens', vmin=0, vmax=1, origin='lower')
ax.set_xlabel('a (first shadow depth)', fontsize=11)
ax.set_ylabel('b (second shadow depth)', fontsize=11)
ax.set_title('Semigroup Law Verification\nSh_b(Sh_a(S)) = Sh_{a+b}(S)', fontsize=12)
ax.set_xticks(range(max_ab))
ax.set_yticks(range(max_ab))
for a in range(max_ab):
    for b in range(max_ab):
        ax.text(a, b, '✓' if grid[b, a] == 1 else '✗',
                ha='center', va='center', fontsize=14,
                color='darkgreen' if grid[b, a] == 1 else 'red')

# Panel 2: Profile decay comparison
ax = axes[1]
families = [
    ('U(3,7)', uniform_matroid_support(7, 3)),
    ('U(4,8)', uniform_matroid_support(8, 4)),
    ('Hom(3,4)', homogeneous_support(3, 4)),
    ('Hom(4,3)', homogeneous_support(4, 3)),
    ('Hom(3,5)', homogeneous_support(3, 5)),
]
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(families)))
for (name, S), color in zip(families, colors):
    prof = shadow_profile(S)
    # Normalize to start at 1
    norm_prof = [p / prof[0] for p in prof]
    ax.plot(range(len(norm_prof)), norm_prof, 'o-', color=color,
            label=name, markersize=5, linewidth=2)

ax.set_xlabel('Shadow depth k', fontsize=11)
ax.set_ylabel('|Shadow_k| / |S|  (normalized)', fontsize=11)
ax.set_title('Normalized Shadow Decay', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(bottom=0)

# Panel 3: Shadow size vs binomial coefficients
ax = axes[2]
for n in [5, 6, 7, 8]:
    r = n // 2
    S = uniform_matroid_support(n, r)
    prof = shadow_profile(S)
    binomials = [comb(n, r - k) if r - k >= 0 else 0 for k in range(r + 1)]
    # Plot ratio
    ratios = [p / b if b > 0 else 0 for p, b in zip(prof, binomials)]
    ax.plot(range(len(ratios)), ratios, 's-', label=f'U({r},{n})',
            markersize=5, linewidth=2)

ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
ax.set_xlabel('Shadow depth k', fontsize=11)
ax.set_ylabel('|Shadow_k| / C(n, r-k)', fontsize=11)
ax.set_title('Shadow vs Binomial Coefficients', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('The Shadow Operator as a Discrete Flow',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('semigroup_flow.png', dpi=150, bbox_inches='tight')
print("Saved semigroup_flow.png")
