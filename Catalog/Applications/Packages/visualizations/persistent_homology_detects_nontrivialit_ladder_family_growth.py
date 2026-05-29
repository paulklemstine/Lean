"""
Visualization: Ladder Family Persistent Complexity Growth
=========================================================
Shows how the barcode complexity of the ladder flow model family
grows with the depth parameter k, demonstrating that persistent
invariants capture increasingly rich structure.
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


def interval_mults(bt, max_filt):
    def beta(i, j):
        if i < 0 or j < 0 or i > j:
            return 0
        return bt.get((i, j), 0)
    mults = {}
    for b in range(max_filt + 1):
        for d in range(b + 1, max_filt + 2):
            mu = beta(b, d-1) - beta(b-1, d-1) - beta(b, d) + beta(b-1, d)
            if mu != 0:
                mults[(b, d)] = mu
        mu_inf = beta(b, max_filt) - beta(b-1, max_filt)
        if mu_inf != 0:
            mults[(b, 'inf')] = mu_inf
    return mults


def ladder_model(k):
    gen0_filts = list(range(k + 1))
    gen1_filts = list(range(1, k + 1))
    diff = np.zeros((k + 1, k), dtype=int)
    for j in range(k):
        diff[0, j] = -1
        diff[j + 1, j] = 1
    return FilteredChainComplex(gen0_filts, gen1_filts, diff)


# Compute data
max_k = 10
ks = list(range(1, max_k + 1))
bar_counts = []
betti_entries = []
max_betti_vals = []

for k in ks:
    L = ladder_model(k)
    bt = betti_table(L, 2)
    mults = interval_mults(bt, L.max_filt)
    bar_counts.append(sum(abs(v) for v in mults.values()))
    betti_entries.append(len(bt))
    max_betti_vals.append(max(bt.values()) if bt else 0)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Bar count growth
ax = axes[0, 0]
ax.plot(ks, bar_counts, 'o-', color='#2196F3', linewidth=2, markersize=8)
ax.set_xlabel("Ladder depth k", fontsize=12)
ax.set_ylabel("Total bar count", fontsize=12)
ax.set_title("Barcode Complexity Growth", fontsize=13, fontweight='bold')
ax.grid(alpha=0.3)

# Panel 2: Betti table size
ax = axes[0, 1]
ax.plot(ks, betti_entries, 's-', color='#4CAF50', linewidth=2, markersize=8)
ax.set_xlabel("Ladder depth k", fontsize=12)
ax.set_ylabel("# Persistent Betti entries", fontsize=12)
ax.set_title("Persistent Betti Table Size", fontsize=13, fontweight='bold')
ax.grid(alpha=0.3)

# Panel 3: Barcode diagrams for k=1,2,3,4
ax = axes[1, 0]
ax.set_title("Barcodes for Ladder Models (mod 2)", fontsize=13, fontweight='bold')
colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']
y_offset = 0
labels_done = set()
for idx, k in enumerate([1, 2, 3, 4]):
    L = ladder_model(k)
    bt = betti_table(L, 2)
    mults = interval_mults(bt, L.max_filt)

    label = f"k={k}"
    first = True
    for (b, d), mult in sorted(mults.items(), key=lambda x: (x[0][0], 0 if x[0][1] == 'inf' else -x[0][1])):
        for _ in range(abs(mult)):
            if d == 'inf':
                ax.barh(y_offset, 6 - b, left=b, height=0.5,
                        color=colors[idx], alpha=0.7,
                        label=label if first else None)
                ax.plot(6, y_offset, '>', markersize=8, color=colors[idx])
            else:
                ax.barh(y_offset, d - b, left=b, height=0.5,
                        color=colors[idx], alpha=0.7,
                        label=label if first else None)
            first = False
            y_offset += 1
    y_offset += 0.5  # gap between k values

ax.set_xlabel("Filtration level", fontsize=12)
ax.set_ylabel("Bar index", fontsize=12)
ax.legend(loc='upper right')
ax.grid(axis='x', alpha=0.3)

# Panel 4: Persistent Betti heatmap for k=5
ax = axes[1, 1]
k = 5
L = ladder_model(k)
bt = betti_table(L, 2)
F = L.max_filt

heatmap_data = np.full((F + 1, F + 1), np.nan)
for (i, j), v in bt.items():
    heatmap_data[i, j] = v

im = ax.imshow(heatmap_data, cmap='YlOrRd', aspect='auto', origin='upper')
for i in range(F + 1):
    for j in range(F + 1):
        if not np.isnan(heatmap_data[i, j]):
            ax.text(j, i, str(int(heatmap_data[i, j])),
                    ha='center', va='center', fontsize=9, fontweight='bold')

ax.set_xlabel("j (filtration death)", fontsize=12)
ax.set_ylabel("i (filtration birth)", fontsize=12)
ax.set_title(f"β₀^{{i,j}} Heatmap (k={k}, mod 2)", fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax, label="Persistent Betti number")

plt.tight_layout()
plt.savefig('ladder_growth.png', dpi=150, bbox_inches='tight')
print("Saved ladder_growth.png")
