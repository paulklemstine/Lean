"""
Visualization: Shadow Profile Decay Curves

Visualizes the shadow profiles of key polynomials (∏(1+xᵢ), permanent,
elementary symmetric) as bar charts / line plots, showing how the
iterated shadow sizes decay. The shape of these curves is the
"fingerprint" that constrains circuit complexity.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations, combinations
from typing import Set, Tuple, List

MultiIndex = Tuple[int, ...]


def lower_shadow(S: Set[MultiIndex]) -> Set[MultiIndex]:
    result: Set[MultiIndex] = set()
    for v in S:
        for i in range(len(v)):
            if v[i] > 0:
                w = list(v)
                w[i] -= 1
                result.add(tuple(w))
    return result


def shadow_profile(S: Set[MultiIndex]) -> List[int]:
    if not S:
        return [0]
    profile = []
    current = set(S)
    while current:
        profile.append(len(current))
        current = lower_shadow(current)
    return profile


def support_product(n):
    result = set()
    for bits in range(2 ** n):
        result.add(tuple((bits >> i) & 1 for i in range(n)))
    return result


def support_permanent(n):
    result = set()
    for perm in permutations(range(n)):
        v = [0] * (n * n)
        for i in range(n):
            v[i * n + perm[i]] = 1
        result.add(tuple(v))
    return result


def support_elem_sym(n, k):
    result = set()
    for subset in combinations(range(n), k):
        v = [0] * n
        for i in subset:
            v[i] = 1
        result.add(tuple(v))
    return result


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: ∏(1+xᵢ) for various n
ax = axes[0]
colors = plt.cm.viridis(np.linspace(0.2, 0.8, 4))
for idx, n in enumerate([2, 3, 4, 5]):
    prof = shadow_profile(support_product(n))
    ax.bar(np.arange(len(prof)) + idx * 0.18 - 0.27, prof,
           width=0.17, color=colors[idx], label=f'n={n}', alpha=0.85)
ax.set_xlabel('Shadow iteration k')
ax.set_ylabel('|∂ᵏ(S)|')
ax.set_title('Shadow Profiles of ∏(1+xᵢ)')
ax.legend()
ax.set_yscale('log')

# Plot 2: Permanent for n=2,3,4
ax = axes[1]
colors2 = plt.cm.plasma(np.linspace(0.2, 0.8, 3))
for idx, n in enumerate([2, 3, 4]):
    prof = shadow_profile(support_permanent(n))
    ax.plot(range(len(prof)), prof, 'o-', color=colors2[idx],
            label=f'perm_{n}', markersize=6, linewidth=2)
ax.set_xlabel('Shadow iteration k')
ax.set_ylabel('|∂ᵏ(S)|')
ax.set_title('Shadow Profiles of Permanent')
ax.legend()

# Plot 3: Elementary symmetric polynomials
ax = axes[2]
n = 6
colors3 = plt.cm.coolwarm(np.linspace(0.1, 0.9, n))
for k in range(1, n + 1):
    prof = shadow_profile(support_elem_sym(n, k))
    ax.plot(range(len(prof)), prof, 's-', color=colors3[k-1],
            label=f'e_{k}', markersize=5, linewidth=1.5)
ax.set_xlabel('Shadow iteration k')
ax.set_ylabel('|∂ᵏ(S)|')
ax.set_title(f'Shadow Profiles of eₖ(x₁,...,x₆)')
ax.legend(ncol=2, fontsize=8)

plt.tight_layout()
plt.savefig('shadow_profiles.png', dpi=150, bbox_inches='tight')
print("Saved shadow_profiles.png")
