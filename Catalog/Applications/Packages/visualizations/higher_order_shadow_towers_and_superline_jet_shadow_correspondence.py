"""
Jet-Shadow Correspondence Visualization
=========================================
Visualizes the cross-domain connection between jet bundle dimensions
and shadow tower cardinalities. Shows how the product
jet_dim(d,k) × |Sh_k(T(d,m))| encodes the full Taylor information
content of a polynomial.
"""
import numpy as np
import matplotlib.pyplot as plt
from math import comb


def jet_dimension(d: int, k: int) -> int:
    """C(d + k - 1, k)"""
    return comb(d + k - 1, k)


def shadow_card(d: int, m: int, k: int) -> int:
    """C(m - k + d - 1, d - 1)"""
    if k > m:
        return 0
    return comb(m - k + d - 1, d - 1)


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Jet dimension vs shadow cardinality (trade-off)
ax = axes[0]
d, m = 5, 12
ks = range(m + 1)
jets = [jet_dimension(d, k) for k in ks]
shadows = [shadow_card(d, m, k) for k in ks]
products = [j * s for j, s in zip(jets, shadows)]

ax.semilogy(ks, jets, 's-', color='blue', label='Jet dim C(d+k-1,k)', markersize=5)
ax.semilogy(ks, [max(s, 0.5) for s in shadows], 'o-', color='red', 
            label='Shadow |Sh_k|', markersize=5)
ax.semilogy(ks, products, '^-', color='green', label='Product (info content)', markersize=5)

ax.set_xlabel('Order k', fontsize=11)
ax.set_ylabel('Count (log scale)', fontsize=11)
ax.set_title(f'Jet-Shadow Trade-off (d={d}, m={m})', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Information content stacked area
ax = axes[1]
d = 4
for m in [6, 10, 15]:
    ks_list = list(range(m + 1))
    info = [jet_dimension(d, k) * shadow_card(d, m, k) for k in ks_list]
    total = sum(info)
    cumulative = np.cumsum(info) / total
    ax.plot(ks_list, cumulative, 'o-', markersize=4, label=f'm={m}')

ax.set_xlabel('Order k', fontsize=11)
ax.set_ylabel('Cumulative info fraction', fontsize=11)
ax.set_title(f'Taylor Information Distribution (d={d})', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 1.05)

# Panel 3: Superlinear growth test
ax = axes[2]
for d in [3, 4, 5, 8]:
    m = 20
    ks_list = list(range(1, m // 2 + 1))
    # Ratio: (shadow_card(d,m,k) * d) / (k * shadow_card(d,m,0))
    ratios = []
    for k in ks_list:
        sc_k = shadow_card(d, m, k)
        sc_0 = shadow_card(d, m, 0)
        ratio = (sc_k * d) / (k * sc_0) if k * sc_0 > 0 else 0
        ratios.append(ratio)
    ax.plot(ks_list, ratios, 'o-', markersize=4, label=f'd={d}')

ax.axhline(y=1.0, color='black', linestyle='--', alpha=0.5, label='Threshold')
ax.set_xlabel('Order k', fontsize=11)
ax.set_ylabel('Superlinear ratio', fontsize=11)
ax.set_title(f'Superlinear Conjecture (m=20)', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Jet-Shadow Correspondence: Geometry Meets Complexity',
             fontsize=15, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('jet_shadow_correspondence.png', dpi=150, bbox_inches='tight')
plt.show()
