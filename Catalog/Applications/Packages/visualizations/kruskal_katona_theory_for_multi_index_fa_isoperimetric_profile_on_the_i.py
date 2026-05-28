"""
Visualization: Isoperimetric Profile on the Integer Simplex

Shows the minimum shadow size as a function of family size m
for different simplex parameters (n, d). This is the discrete
isoperimetric function: the multi-index analogue of the classical
edge-isoperimetric problem on the hypercube.

CRITICAL: Fully self-contained. No local imports.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from typing import List, Tuple, Set


def degree_slice(n: int, d: int) -> List[Tuple[int, ...]]:
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in degree_slice(n - 1, d - k):
            result.append((k,) + rest)
    return result


def shadow(family: Set[Tuple[int, ...]]) -> Set[Tuple[int, ...]]:
    result = set()
    for alpha in family:
        for i in range(len(alpha)):
            if alpha[i] > 0:
                beta = list(alpha)
                beta[i] -= 1
                result.add(tuple(beta))
    return result


def lex_initial_segment(n: int, d: int, m: int) -> Set[Tuple[int, ...]]:
    slc = sorted(degree_slice(n, d))
    return set(slc[:m])


# Compute profiles
configs = [(3, 2, 'tab:blue'), (3, 3, 'tab:orange'), (3, 4, 'tab:green'),
           (4, 2, 'tab:red'), (4, 3, 'tab:purple')]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

for n, d, color in configs:
    slc = degree_slice(n, d)
    slc_size = len(slc)
    ms = list(range(1, slc_size + 1))
    shadows = [len(shadow(lex_initial_segment(n, d, m))) for m in ms]
    
    # Normalized plot
    ax1.plot(ms, shadows, 'o-', color=color, markersize=3,
             label=f'n={n}, d={d} ({slc_size} pts)')
    
    # Ratio plot
    ratios = [s / m for m, s in zip(ms, shadows)]
    ax2.plot(ms, ratios, 'o-', color=color, markersize=3,
             label=f'n={n}, d={d}')

ax1.set_xlabel('Family size m', fontsize=12)
ax1.set_ylabel('Minimum shadow size |∂F|', fontsize=12)
ax1.set_title('Discrete Isoperimetric Profile\non the Integer Simplex', fontsize=14)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

ax2.set_xlabel('Family size m', fontsize=12)
ax2.set_ylabel('Shadow ratio min|∂F|/m', fontsize=12)
ax2.set_title('Shadow Concentration Ratio\n(Lower = More Concentrated)', fontsize=14)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.axhline(y=1, color='gray', linestyle='--', alpha=0.5)

plt.tight_layout()
plt.savefig('viz_shadow_profile.png', dpi=150, bbox_inches='tight')
print("Saved viz_shadow_profile.png")
