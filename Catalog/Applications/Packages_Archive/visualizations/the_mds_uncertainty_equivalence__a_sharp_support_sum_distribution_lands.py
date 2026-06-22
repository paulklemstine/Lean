"""
Visualization: support-sum landscapes for MDS vs non-MDS 3x3 matrices over F_5.

For each nonzero f in F_5^3 we plot |supp(f)| + |supp(Mf)|.  For an MDS matrix
the histogram is entirely >= n+1 = 4 with mass exactly at 4 (the sharp floor);
for a non-MDS matrix some f fall below 4, exposing the uncertainty violators.
"""
from itertools import product
from typing import List
import matplotlib.pyplot as plt

p, n = 5, 3

def support_sums(M: List[List[int]]) -> List[int]:
    out = []
    for f in product(range(p), repeat=n):
        if not any(f):
            continue
        Mf = [sum(M[i][j] * f[j] for j in range(n)) % p for i in range(n)]
        out.append(sum(1 for v in f if v) + sum(1 for v in Mf if v))
    return out

# MDS Cauchy matrix over F_5 and a deliberately non-MDS matrix.
xs, ys = [0, 1, 2], [2, 3, 4]
mds = [[pow((x - y) % p, p - 2, p) for y in ys] for x in xs]
non_mds = [[1, 1, 0], [2, 2, 0], [0, 0, 1]]

fig, axes = plt.subplots(1, 2, figsize=(11, 4), sharey=True)
for ax, M, title in [(axes[0], mds, "MDS (Cauchy)"),
                     (axes[1], non_mds, "Non-MDS")]:
    sums = support_sums(M)
    bins = range(min(sums), max(sums) + 2)
    ax.hist(sums, bins=bins, align="left", rwidth=0.85, color="#3b7dd8")
    ax.axvline(n + 1 - 0.5, color="crimson", linestyle="--",
               label=f"forbidden line < n+1 = {n+1}")
    ax.set_title(f"{title}: support-sum distribution")
    ax.set_xlabel("|supp(f)| + |supp(Mf)|")
    ax.legend()
axes[0].set_ylabel("number of nonzero f")
fig.suptitle("MDS forbids support sums below n+1; non-MDS does not")
fig.tight_layout()
fig.savefig("mds_uncertainty_landscape.png", dpi=150)
print("saved mds_uncertainty_landscape.png")
