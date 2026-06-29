"""Visualization: uncertainty support-sum landscape for MDS vs non-MDS."""
import numpy as np
import matplotlib.pyplot as plt
from itertools import product


def inv_mod(a, p):
    return pow(a % p, p - 2, p)


def matvec(M, f, p):
    n = len(M)
    return [sum(M[i][j] * f[j] for j in range(n)) % p for i in range(n)]


def support_sum_hist(M, p):
    n = len(M)
    sums = []
    for f in product(range(p), repeat=n):
        if not any(f):
            continue
        Mf = matvec(M, list(f), p)
        sums.append(sum(1 for x in f if x % p) + sum(1 for x in Mf if x % p))
    return sums


p = 5
n = 3
# Cauchy (MDS) matrix
xs, ys = [1, 2, 3], [0, 4, 3]  # ensure distinct & disjoint mod p where possible
C = [[inv_mod((xs[i] - ys[j]) % p, p) for j in range(n)] for i in range(n)]
# A non-MDS matrix (identity)
I = [[1 if i == j else 0 for j in range(n)] for i in range(n)]

fig, ax = plt.subplots(1, 2, figsize=(11, 4), sharey=True)
for a, M, title in ((ax[0], C, "MDS (Cauchy)"), (ax[1], I, "non-MDS (Identity)")):
    s = support_sum_hist(M, p)
    bins = np.arange(min(s) - 0.5, max(s) + 1.5)
    a.hist(s, bins=bins, color="#2a6f97", edgecolor="white")
    a.axvline(n + 1, color="crimson", lw=2, label=f"threshold n+1={n+1}")
    a.set_title(f"{title}\nmin support sum = {min(s)}")
    a.set_xlabel("|supp(f)| + |supp(Mf)|")
    a.legend()
ax[0].set_ylabel("# nonzero vectors f")
fig.suptitle("MDS forces all support sums to the wall at n+1; non-MDS leaks below")
fig.tight_layout()
fig.savefig("uncertainty_landscape.png", dpi=150)
print("saved uncertainty_landscape.png")
