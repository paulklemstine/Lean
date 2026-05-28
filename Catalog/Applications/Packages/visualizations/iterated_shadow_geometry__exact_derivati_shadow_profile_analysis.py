"""
Visualization: Shadow Profiles and Log-Concavity

Visualizes the shadow profile decay for various polynomial support families,
demonstrating the log-concavity phenomenon and the semigroup structure
of the shadow operator.

This script is fully self-contained — all needed functions are inlined.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


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


# --- Figure 1: Shadow Profile Comparison ---

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Uniform matroids
ax = axes[0]
for n in [6, 7, 8]:
    for r in [3, 4]:
        S = uniform_matroid_support(n, r)
        prof = shadow_profile(S)
        ax.plot(range(len(prof)), prof, 'o-', label=f'U({r},{n})', markersize=4)
ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('|Shadow_k(S)|', fontsize=12)
ax.set_title('Uniform Matroid Shadows', fontsize=13)
ax.legend(fontsize=8)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 2: Homogeneous polynomial supports
ax = axes[1]
for n in [2, 3, 4]:
    for d in [3, 4, 5]:
        S = homogeneous_support(n, d)
        if len(S) > 200:
            continue
        prof = shadow_profile(S)
        ax.plot(range(len(prof)), prof, 's-', label=f'Hom({n},{d})', markersize=4)
ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('|Shadow_k(S)|', fontsize=12)
ax.set_title('Homogeneous Polynomial Shadows', fontsize=13)
ax.legend(fontsize=8)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 3: Log-concavity verification (a_k^2 vs a_{k-1}*a_{k+1})
ax = axes[2]
for n in [6, 7, 8]:
    S = uniform_matroid_support(n, n // 2)
    prof = shadow_profile(S)
    if len(prof) >= 3:
        ks = range(1, len(prof) - 1)
        lhs = [prof[k] ** 2 for k in ks]
        rhs = [prof[k-1] * prof[k+1] for k in ks]
        ratios = [l / r if r > 0 else float('inf') for l, r in zip(lhs, rhs)]
        ax.plot(list(ks), ratios, 'D-', label=f'U({n//2},{n})', markersize=5)

ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.7, label='LC threshold')
ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('a_k² / (a_{k-1} · a_{k+1})', fontsize=12)
ax.set_title('Log-Concavity Ratios ≥ 1', fontsize=13)
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

plt.suptitle('Iterated Shadow Geometry: Profile Analysis', fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('shadow_profiles.png', dpi=150, bbox_inches='tight')
print("Saved shadow_profiles.png")
