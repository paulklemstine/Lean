"""
Visualization: Convolution Theorem Illustration

Visualizes the shadow convolution inequality for Minkowski sums:
shows the actual shadow profile of A+B compared to the convolution
bound Σᵢ aᵢ^A · a_{k-i}^B. The gap between the two curves
represents the "slack" in the convolution bound.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
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


def minkowski_sum(A: Set[MultiIndex], B: Set[MultiIndex]) -> Set[MultiIndex]:
    return {tuple(ai + bi for ai, bi in zip(a, b)) for a in A for b in B}


def convolve_profiles(pa: List[int], pb: List[int]) -> List[int]:
    length = len(pa) + len(pb) - 1
    conv = []
    for k in range(length):
        val = sum(pa[i] * pb[k - i] for i in range(k + 1)
                  if i < len(pa) and (k - i) < len(pb))
        conv.append(val)
    return conv


fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Example 1: (1+x)(1+y) decomposition
A1 = {(1, 0, 0), (0, 0, 0)}
B1 = {(0, 1, 0), (0, 0, 0)}

# Example 2: larger sets
A2 = {(1, 0, 0), (0, 1, 0), (0, 0, 0)}
B2 = {(0, 0, 1), (0, 0, 0)}

# Example 3: self-sum
A3 = {(1, 0), (0, 1)}
B3 = {(1, 0), (0, 1)}

# Example 4: elementary symmetric
A4 = set()
for subset in combinations(range(3), 1):
    v = [0] * 3
    for i in subset:
        v[i] = 1
    A4.add(tuple(v))
B4 = set(A4)

examples = [
    (A1, B1, "A={e₁, 0}, B={e₂, 0}"),
    (A2, B2, "A={e₁, e₂, 0}, B={e₃, 0}"),
    (A3, B3, "A=B={e₁, e₂}"),
    (A4, B4, "A=B=Supp(e₁(x₁,x₂,x₃))"),
]

for idx, (A, B, title) in enumerate(examples):
    ax = axes[idx // 2][idx % 2]

    AB = minkowski_sum(A, B)
    pa = shadow_profile(A)
    pb = shadow_profile(B)
    pab = shadow_profile(AB)
    conv = convolve_profiles(pa, pb)

    max_k = max(len(pab), len(conv))
    pab_ext = pab + [0] * (max_k - len(pab))
    conv_ext = conv + [0] * (max_k - len(conv))

    x = np.arange(max_k)
    width = 0.35

    ax.bar(x - width / 2, pab_ext, width, label='Actual |∂ᵏ(A+B)|',
           color='steelblue', alpha=0.8)
    ax.bar(x + width / 2, conv_ext, width, label='Conv bound',
           color='coral', alpha=0.8)

    # Highlight slack
    for k in range(max_k):
        if conv_ext[k] > pab_ext[k]:
            ax.annotate('', xy=(k + width / 2, pab_ext[k]),
                        xytext=(k + width / 2, conv_ext[k]),
                        arrowprops=dict(arrowstyle='<->', color='green', lw=1.5))

    ax.set_xlabel('k')
    ax.set_ylabel('Count')
    ax.set_title(title, fontsize=10)
    ax.legend(fontsize=8)

    # Add complexity info
    sc_ab = sum(pab)
    sc_a = sum(pa)
    sc_b = sum(pb)
    ax.text(0.95, 0.95, f'Σ(A+B)={sc_ab}\nΣ(A)·Σ(B)={sc_a * sc_b}',
            transform=ax.transAxes, ha='right', va='top',
            fontsize=8, bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

fig.suptitle('Shadow Convolution Inequality: Actual vs Bound', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('convolution_theorem.png', dpi=150, bbox_inches='tight')
print("Saved convolution_theorem.png")
