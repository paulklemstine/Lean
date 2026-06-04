#!/usr/bin/env python3
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as iprod

INF = float('inf')

def trop_mat_mul(A, B):
    n, m, k = A.shape[0], B.shape[1], A.shape[1]
    C = np.full((n, m), INF)
    for i in range(n):
        for j in range(m):
            for l in range(k):
                if A[i,l] != INF and B[l,j] != INF:
                    C[i,j] = min(C[i,j], A[i,l] + B[l,j])
    return C

def centralizer_fraction(n, bound, num_samples=10):
    total = (bound + 1) ** (n * n)
    entries = list(range(bound + 1))
    fracs = []
    for _ in range(num_samples):
        G = np.random.randint(0, bound + 1, size=(n, n)).astype(float)
        count = sum(1 for vals in iprod(entries, repeat=n*n)
                   if np.array_equal(trop_mat_mul(np.array(vals, float).reshape(n,n), G),
                                     trop_mat_mul(G, np.array(vals, float).reshape(n,n))))
        fracs.append(count / total)
    return np.mean(fracs), np.std(fracs)

dims = [1, 2, 3]
bound = 2
means, stds = [], []
for n in dims:
    m, s = centralizer_fraction(n, bound)
    means.append(m); stds.append(s)

fig, ax = plt.subplots(figsize=(8, 6))
ax.errorbar(dims, means, yerr=stds, fmt='o-', linewidth=2, markersize=8, capsize=5)
ax.set_xlabel('Matrix dimension n', fontsize=14)
ax.set_ylabel('Centralizer fraction', fontsize=14)
ax.set_title('Centralizer Gap: Security Grows with Dimension', fontsize=16)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('centralizer_gap.png', dpi=150)
print('Saved centralizer_gap.png')