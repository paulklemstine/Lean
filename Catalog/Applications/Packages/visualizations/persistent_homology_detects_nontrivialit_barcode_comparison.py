"""
Visualization: Barcode Comparison of Separation Examples
========================================================
Visualizes the barcodes of complexes C and D side by side,
highlighting the separating persistent Betti number β₀^{1,2}.

Complex C: d(e) = b - a  (kills filt-1 class)
Complex D: d(e) = c - a  (kills filt-2 class)
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


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


# Create examples
C = FilteredChainComplex([0, 1, 2], [2], [[-1], [1], [0]])
D = FilteredChainComplex([0, 1, 2], [2], [[-1], [0], [1]])

p = 2
bt_C = betti_table(C, p)
bt_D = betti_table(D, p)
mults_C = interval_mults(bt_C, C.max_filt)
mults_D = interval_mults(bt_D, D.max_filt)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Barcode of C
ax = axes[0, 0]
ax.set_title("Complex C: d(e) = b − a\n(kills filt-1 class)", fontsize=12, fontweight='bold')
colors_C = ['#2196F3', '#4CAF50', '#FF9800', '#9C27B0']
y = 0
bars_C = sorted(mults_C.items(), key=lambda x: (x[0][0], 0 if x[0][1] == 'inf' else -x[0][1]))
for (b, d), mult in bars_C:
    for _ in range(abs(mult)):
        if d == 'inf':
            ax.barh(y, 3.5 - b, left=b, height=0.6, color=colors_C[y % len(colors_C)], alpha=0.8)
            ax.plot(3.5, y, '>', markersize=10, color=colors_C[y % len(colors_C)])
        else:
            ax.barh(y, d - b, left=b, height=0.6, color=colors_C[y % len(colors_C)], alpha=0.8)
        ax.text(b + 0.05, y + 0.05, f"[{b},{d})", fontsize=8, va='center')
        y += 1
ax.set_xlabel("Filtration level")
ax.set_ylabel("Bar index")
ax.set_xlim(-0.2, 4)
ax.set_yticks(range(y))
ax.grid(axis='x', alpha=0.3)

# Panel 2: Barcode of D
ax = axes[0, 1]
ax.set_title("Complex D: d(e) = c − a\n(kills filt-2 class)", fontsize=12, fontweight='bold')
colors_D = ['#E91E63', '#00BCD4', '#FF5722', '#673AB7']
y = 0
bars_D = sorted(mults_D.items(), key=lambda x: (x[0][0], 0 if x[0][1] == 'inf' else -x[0][1]))
for (b, d), mult in bars_D:
    for _ in range(abs(mult)):
        if d == 'inf':
            ax.barh(y, 3.5 - b, left=b, height=0.6, color=colors_D[y % len(colors_D)], alpha=0.8)
            ax.plot(3.5, y, '>', markersize=10, color=colors_D[y % len(colors_D)])
        else:
            ax.barh(y, d - b, left=b, height=0.6, color=colors_D[y % len(colors_D)], alpha=0.8)
        ax.text(b + 0.05, y + 0.05, f"[{b},{d})", fontsize=8, va='center')
        y += 1
ax.set_xlabel("Filtration level")
ax.set_ylabel("Bar index")
ax.set_xlim(-0.2, 4)
ax.set_yticks(range(y))
ax.grid(axis='x', alpha=0.3)

# Panel 3: Persistent Betti table comparison
ax = axes[1, 0]
ax.set_title("Persistent Betti Numbers β₀^{i,j} (mod 2)", fontsize=12, fontweight='bold')

F = 2
cell_data = []
cell_colors = []
for i in range(F + 1):
    row = []
    row_colors = []
    for j in range(F + 1):
        if j >= i:
            bc = bt_C[(i, j)]
            bd = bt_D[(i, j)]
            row.append(f"C:{bc} D:{bd}")
            if bc != bd:
                row_colors.append('#FFCDD2')  # red highlight
            else:
                row_colors.append('#E8F5E9')  # green
        else:
            row.append("")
            row_colors.append('white')
    cell_data.append(row)
    cell_colors.append(row_colors)

table = ax.table(cellText=cell_data, cellColours=cell_colors,
                  rowLabels=[f"i={i}" for i in range(F+1)],
                  colLabels=[f"j={j}" for j in range(F+1)],
                  loc='center', cellLoc='center')
table.auto_set_font_size(False)
table.set_fontsize(11)
table.scale(1.2, 1.8)
ax.axis('off')
ax.text(0.5, -0.05, "Red = SEPARATING pair", ha='center', transform=ax.transAxes,
        fontsize=10, color='red', fontweight='bold')

# Panel 4: Schematic of the complexes
ax = axes[1, 1]
ax.set_title("Filtration Structure Schematic", fontsize=12, fontweight='bold')

# Draw filtration levels
for f in range(3):
    ax.axvline(f, color='gray', linestyle='--', alpha=0.3)
    ax.text(f, -0.8, f"f={f}", ha='center', fontsize=10)

# Complex C generators
ax.plot(0, 2, 'o', markersize=15, color='#2196F3', zorder=5)
ax.text(0, 2.4, 'a', ha='center', fontsize=12, fontweight='bold')
ax.plot(1, 2, 'o', markersize=15, color='#4CAF50', zorder=5)
ax.text(1, 2.4, 'b', ha='center', fontsize=12, fontweight='bold')
ax.plot(2, 2, 'o', markersize=15, color='#FF9800', zorder=5)
ax.text(2, 2.4, 'c', ha='center', fontsize=12, fontweight='bold')
ax.plot(2, 3.5, 's', markersize=12, color='#F44336', zorder=5)
ax.text(2, 3.9, 'e', ha='center', fontsize=12, fontweight='bold')

# C differential arrows
ax.annotate('', xy=(0, 2.2), xytext=(1.9, 3.3),
            arrowprops=dict(arrowstyle='->', color='#F44336', lw=2))
ax.annotate('', xy=(1, 2.2), xytext=(1.9, 3.3),
            arrowprops=dict(arrowstyle='->', color='#F44336', lw=2))
ax.text(0.5, 3.0, 'd(e)=b−a', fontsize=9, color='#F44336', rotation=0)

ax.text(1, 4.5, 'Complex C', ha='center', fontsize=13, fontweight='bold', color='#1565C0')

ax.set_xlim(-0.5, 2.5)
ax.set_ylim(-1, 5)
ax.axis('off')

plt.tight_layout()
plt.savefig('barcode_comparison.png', dpi=150, bbox_inches='tight')
print("Saved barcode_comparison.png")
