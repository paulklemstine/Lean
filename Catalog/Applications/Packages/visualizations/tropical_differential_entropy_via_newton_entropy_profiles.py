"""
Visualization 1: Shadow Entropy Profiles

Visualizes the shadow cardinality profile, entropy profile, and entropy drops
for several canonical support families (simplices, boxes), demonstrating
monotone dissipation and the approach to extinction.
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
# Plotting
# ============================================================

fig, axes = plt.subplots(2, 3, figsize=(15, 9))
fig.suptitle('Tropical Shadow Entropy: Profiles and Dissipation', fontsize=16, fontweight='bold')

# Define test cases
cases = [
    ("Simplex(2,5)", simplex_support(2, 5), 2),
    ("Simplex(3,4)", simplex_support(3, 4), 3),
    ("Box(2,3)", box_support((2, 3)), 2),
    ("Box(3,3)", box_support((3, 3)), 2),
    ("Box(2,2,2)", box_support((2, 2, 2)), 3),
    ("Box(1,2,3)", box_support((1, 2, 3)), 3),
]

colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0', '#FF9800', '#00BCD4']

# Top row: Shadow cardinality profiles
ax1 = axes[0, 0]
for i, (name, S, n) in enumerate(cases):
    profile = compute_shadow_profile(S, n)
    ks = list(range(len(profile)))
    ax1.plot(ks, profile, 'o-', color=colors[i], label=name, markersize=5, linewidth=2)
ax1.set_xlabel('Shadow step k')
ax1.set_ylabel('|Sh_k(S)|')
ax1.set_title('Shadow Cardinality (Monotone ↓)')
ax1.legend(fontsize=8, loc='upper right')
ax1.grid(True, alpha=0.3)

# Top middle: Entropy profiles
ax2 = axes[0, 1]
for i, (name, S, n) in enumerate(cases):
    profile = compute_shadow_profile(S, n)
    entropy = [math.log(c + 1) for c in profile]
    ks = list(range(len(entropy)))
    ax2.plot(ks, entropy, 'o-', color=colors[i], label=name, markersize=5, linewidth=2)
ax2.set_xlabel('Shadow step k')
ax2.set_ylabel('H_S(k) = log(|Sh_k(S)| + 1)')
ax2.set_title('Shadow Entropy (Antitone)')
ax2.legend(fontsize=8, loc='upper right')
ax2.grid(True, alpha=0.3)

# Top right: Entropy drops
ax3 = axes[0, 2]
for i, (name, S, n) in enumerate(cases):
    profile = compute_shadow_profile(S, n)
    entropy = [math.log(c + 1) for c in profile]
    drops = [entropy[k+1] - entropy[k] for k in range(len(entropy)-1)]
    ks = list(range(len(drops)))
    ax3.plot(ks, drops, 's-', color=colors[i], label=name, markersize=5, linewidth=2)
ax3.axhline(y=0, color='black', linestyle='--', linewidth=0.8)
ax3.set_xlabel('Shadow step k')
ax3.set_ylabel('ΔH_S(k)')
ax3.set_title('Entropy Drop (≤ 0 for DC sets)')
ax3.legend(fontsize=8, loc='lower right')
ax3.grid(True, alpha=0.3)

# Bottom left: Log-concavity check (profile[k+1]^2 vs profile[k]*profile[k+2])
ax4 = axes[1, 0]
for i, (name, S, n) in enumerate(cases[:3]):
    profile = compute_shadow_profile(S, n)
    lhs = [profile[k+1]**2 for k in range(len(profile)-2)]
    rhs = [profile[k]*profile[k+2] for k in range(len(profile)-2)]
    ratio = [l/r if r > 0 else float('inf') for l, r in zip(lhs, rhs)]
    ks = list(range(len(ratio)))
    ax4.plot(ks, ratio, 'D-', color=colors[i], label=name, markersize=6, linewidth=2)
ax4.axhline(y=1, color='red', linestyle='--', linewidth=1.5, label='LC threshold')
ax4.set_xlabel('Shadow step k')
ax4.set_ylabel('c(k+1)² / [c(k)·c(k+2)]')
ax4.set_title('Log-Concavity Ratio (≥ 1 = LC)')
ax4.legend(fontsize=8)
ax4.grid(True, alpha=0.3)

# Bottom middle: Second differences of entropy
ax5 = axes[1, 1]
for i, (name, S, n) in enumerate(cases):
    profile = compute_shadow_profile(S, n)
    entropy = [math.log(c + 1) for c in profile]
    if len(entropy) >= 3:
        second_diff = [entropy[k+2] - 2*entropy[k+1] + entropy[k] for k in range(len(entropy)-2)]
        ks = list(range(len(second_diff)))
        ax5.plot(ks, second_diff, '^-', color=colors[i], label=name, markersize=5, linewidth=2)
ax5.axhline(y=0, color='red', linestyle='--', linewidth=1.5, label='Concavity boundary')
ax5.set_xlabel('Shadow step k')
ax5.set_ylabel('Δ²H_S(k)')
ax5.set_title('Second Differences (≤ 0 = Concave)')
ax5.legend(fontsize=8, loc='lower right')
ax5.grid(True, alpha=0.3)

# Bottom right: Degree layer profiles
ax6 = axes[1, 2]
for i, (name, S, n) in enumerate(cases[:4]):
    D = support_max_deg(S)
    layers = [sum(1 for v in S if total_mass(v) == t) for t in range(D+1)]
    ax6.bar(np.array(range(len(layers))) + i*0.15, layers, width=0.15, 
            color=colors[i], alpha=0.8, label=name)
ax6.set_xlabel('Total degree t')
ax6.set_ylabel('L_S(t)')
ax6.set_title('Degree Layer Profiles')
ax6.legend(fontsize=8)
ax6.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('entropy_profiles.png', dpi=150, bbox_inches='tight')
print("Saved entropy_profiles.png")
