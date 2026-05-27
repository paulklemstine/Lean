"""
Visualization: Integer-Scaled Laplacian Heatmap

Visualizes the integer-scaled reduced Laplacian matrix for cycle graphs
with various rational edge lengths. Shows how the arithmetic structure
(symmetry, diagonal dominance) is preserved under integer scaling.

The heatmap reveals the characteristic banded structure of cycle graph
Laplacians and how rational edge lengths create non-uniform conductance
patterns in the integer domain.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from fractions import Fraction
from math import gcd
from functools import reduce

# ─── Inlined algorithms ──────────────────────────────────────────────────

def lcm(a, b): return abs(a*b)//gcd(a,b) if a and b else 0
def common_denom(fracs): return reduce(lcm, [f.denominator for f in fracs]) if fracs else 1

def weighted_laplacian_Q(n, adj, lengths):
    L = [[Fraction(0)]*n for _ in range(n)]
    for (i,j) in adj:
        c = Fraction(1)/lengths[(i,j)]
        L[i][j] -= c; L[j][i] -= c; L[i][i] += c; L[j][j] += c
    return L

def reduced_lap(L, base=0):
    n = len(L); idx = [i for i in range(n) if i != base]
    return [[L[i][j] for j in idx] for i in idx]

def scale_int(M):
    entries = [M[i][j] for i in range(len(M)) for j in range(len(M[0]))]
    D = common_denom(entries)
    return D, [[int(D*M[i][j]) for j in range(len(M[0]))] for i in range(len(M))]

# ─── Create figure ────────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle('Integer-Scaled Reduced Laplacians of Rational Metric Graphs',
             fontsize=16, fontweight='bold', y=0.98)

configs = [
    (5, [Fraction(1,2), Fraction(1,3), Fraction(1,5), Fraction(1,7), Fraction(1,11)],
     'C₅: lengths 1/2, 1/3, 1/5, 1/7, 1/11'),
    (6, [Fraction(2,3), Fraction(3,5), Fraction(5,7), Fraction(7,11),
         Fraction(11,13), Fraction(13,17)],
     'C₆: lengths 2/3, 3/5, 5/7, 7/11, 11/13, 13/17'),
    (4, [Fraction(1,1), Fraction(1,1), Fraction(1,1), Fraction(1,1)],
     'C₄: unit lengths (standard Laplacian)'),
    (7, [Fraction(1,2), Fraction(2,3), Fraction(3,4), Fraction(4,5),
         Fraction(5,6), Fraction(6,7), Fraction(7,8)],
     'C₇: lengths k/(k+1) for k=1..7'),
]

for ax, (n, lengths, title) in zip(axes.flat, configs):
    adj = [(i, (i+1)%n) for i in range(n)]
    ld = {e: lengths[i] for i, e in enumerate(adj)}
    L = weighted_laplacian_Q(n, adj, ld)
    Lr = reduced_lap(L)
    D, M = scale_int(Lr)

    m = len(M)
    max_abs = max(abs(M[i][j]) for i in range(m) for j in range(m))

    # Diverging colormap: negative=blue, zero=white, positive=red
    norm = mcolors.TwoSlopeNorm(vmin=-max_abs, vcenter=0, vmax=max_abs)
    im = ax.imshow(M, cmap='RdBu_r', norm=norm, aspect='equal')

    # Annotate small matrices with values
    if m <= 6:
        for i in range(m):
            for j in range(m):
                val = M[i][j]
                color = 'white' if abs(val) > max_abs * 0.6 else 'black'
                ax.text(j, i, str(val), ha='center', va='center',
                       fontsize=8 if m <= 5 else 6, color=color)

    ax.set_title(f'{title}\nD = {D}', fontsize=10)
    ax.set_xlabel('Column index')
    ax.set_ylabel('Row index')
    plt.colorbar(im, ax=ax, shrink=0.8, label='Entry value')

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_laplacian_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_laplacian_heatmap.png")
