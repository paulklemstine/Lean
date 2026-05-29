"""
Visualization: Primewise Persistence Profile Heatmap
=====================================================
Shows how different primes p reveal different persistent Betti
numbers for a torsion-sensitive filtered chain complex.

This visualizes the "primewise barcode profile" — the central new
invariant introduced in this work.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# Self-contained implementations
class FilteredChainComplex:
    def __init__(self, gen0_filts, gen1_filts, diff):
        self.gen0_filts = gen0_filts
        self.gen1_filts = gen1_filts
        self.diff = np.array(diff)
        self.gen0 = len(gen0_filts)
        self.gen1 = len(gen1_filts)
        self.max_filt = max(gen0_filts + gen1_filts) if gen0_filts + gen1_filts else 0

    def restricted_diff(self, f):
        result = np.zeros_like(self.diff)
        for i in range(self.gen0):
            for j in range(self.gen1):
                if self.gen0_filts[i] <= f and self.gen1_filts[j] <= f:
                    result[i, j] = self.diff[i, j]
        return result

    def num_gen0_at_filt(self, f):
        return sum(1 for x in self.gen0_filts if x <= f)


def rank_mod_p(matrix, p):
    m, n = matrix.shape
    if m == 0 or n == 0:
        return 0
    mat = matrix.astype(int) % p
    rank = 0
    for col in range(n):
        pivot_row = None
        for row in range(rank, m):
            if mat[row, col] % p != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue
        mat[[rank, pivot_row]] = mat[[pivot_row, rank]]
        inv = pow(int(mat[rank, col]), p - 2, p)
        for row in range(m):
            if row != rank and mat[row, col] % p != 0:
                factor = (mat[row, col] * inv) % p
                mat[row] = (mat[row] - factor * mat[rank]) % p
        rank += 1
    return rank


def persistent_betti(C, p, i, j):
    if i > j:
        return 0
    d_j = C.restricted_diff(j)
    gen0_at_i = [k for k in range(C.gen0) if C.gen0_filts[k] <= i]
    dim_V = len(gen0_at_i)
    if dim_V == 0:
        return 0
    V = np.zeros((C.gen0, dim_V), dtype=int)
    for idx, k in enumerate(gen0_at_i):
        V[k, idx] = 1
    combined = np.hstack([d_j, V])
    rank_A = rank_mod_p(d_j, p)
    rank_AB = rank_mod_p(combined, p)
    return dim_V - (rank_A + dim_V - rank_AB)


def betti_table(C, p):
    F = C.max_filt
    table = {}
    for i in range(F + 1):
        for j in range(i, F + 1):
            table[(i, j)] = persistent_betti(C, p, i, j)
    return table


# Create torsion-sensitive complex
# d(e₁) = 6(b-a) = (2·3)(b-a), d(e₂) = 10(c-a) = (2·5)(c-a), d(e₃) = 15(d-a) = (3·5)(d-a)
C = FilteredChainComplex(
    gen0_filts=[0, 1, 2, 3],
    gen1_filts=[3, 3, 3],
    diff=np.array([
        [-6, -10, -15],
        [ 6,   0,   0],
        [ 0,  10,   0],
        [ 0,   0,  15]
    ])
)

primes = [2, 3, 5, 7, 11, 13]
F = C.max_filt

fig, axes = plt.subplots(2, 3, figsize=(16, 10))
fig.suptitle("Primewise Persistence Profile: β₀^{i,j} across primes\n"
             "d(e₁)=6(b−a), d(e₂)=10(c−a), d(e₃)=15(d−a)",
             fontsize=14, fontweight='bold')

for idx, p in enumerate(primes):
    ax = axes[idx // 3, idx % 3]
    bt = betti_table(C, p)

    heatmap = np.full((F + 1, F + 1), np.nan)
    for (i, j), v in bt.items():
        heatmap[i, j] = v

    im = ax.imshow(heatmap, cmap='Blues', aspect='auto', origin='upper',
                   vmin=0, vmax=max(bt.values()) if bt else 1)
    for i in range(F + 1):
        for j in range(F + 1):
            if not np.isnan(heatmap[i, j]):
                ax.text(j, i, str(int(heatmap[i, j])),
                        ha='center', va='center', fontsize=12, fontweight='bold',
                        color='white' if heatmap[i, j] > max(bt.values())/2 else 'black')

    ax.set_xlabel("j", fontsize=11)
    ax.set_ylabel("i", fontsize=11)
    ax.set_title(f"p = {p}", fontsize=13, fontweight='bold',
                 color='#D32F2F' if p in [2, 3, 5] else '#1976D2')
    ax.set_xticks(range(F + 1))
    ax.set_yticks(range(F + 1))

# Add explanation
fig.text(0.5, 0.02,
         "Red titles: primes dividing the coefficients (6=2·3, 10=2·5, 15=3·5). "
         "Each prime reveals a different persistence pattern.",
         ha='center', fontsize=11, style='italic')

plt.tight_layout(rect=[0, 0.04, 1, 0.94])
plt.savefig('primewise_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved primewise_heatmap.png")
