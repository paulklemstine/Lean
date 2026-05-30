#!/usr/bin/env python3
"""
Visualization: Spectral Gap vs Group Order for Cayley Graphs

This visualization shows how the spectral gap of the transposition walk
on S_n scales as 2/n (Diaconis-Shahshahani), and compares with cyclic
groups Z_n and dihedral groups D_n. The spectral gap determines mixing
speed: larger gap = faster convergence to uniform distribution.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations


def cayley_adj_cyclic(n, gens):
    A = np.zeros((n, n))
    for g in range(n):
        for s in gens:
            A[g][(g + s) % n] = 1
    return A


def spectral_gap_from_adj(A):
    n = A.shape[0]
    d = A.sum(axis=1)[0]
    P = A / d
    eigs = np.sort(np.abs(np.linalg.eigvalsh(P)))[::-1]
    return 1.0 - eigs[1]


def sn_adj(n):
    perms = list(permutations(range(n)))
    idx = {p: i for i, p in enumerate(perms)}
    N = len(perms)
    A = np.zeros((N, N))
    for i, p in enumerate(perms):
        for a in range(n):
            for b in range(a + 1, n):
                q = list(p)
                q[a], q[b] = q[b], q[a]
                A[i][idx[tuple(q)]] = 1
    return A


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Spectral gap of Z_n
ns_cyclic = list(range(4, 101))
gaps_cyclic = []
for n in ns_cyclic:
    A = cayley_adj_cyclic(n, [1, n-1])
    gaps_cyclic.append(spectral_gap_from_adj(A))

axes[0].plot(ns_cyclic, gaps_cyclic, 'b-', linewidth=2, label='Computed γ')
axes[0].plot(ns_cyclic, [1 - np.cos(2*np.pi/n) for n in ns_cyclic],
             'r--', linewidth=1.5, label='1 - cos(2π/n)')
axes[0].set_xlabel('Group order n', fontsize=12)
axes[0].set_ylabel('Spectral gap γ', fontsize=12)
axes[0].set_title('Z_n with generators {±1}', fontsize=13)
axes[0].legend(fontsize=10)
axes[0].set_yscale('log')
axes[0].grid(True, alpha=0.3)

# Panel 2: Spectral gap of S_n
ns_sn = [3, 4, 5]
gaps_sn = []
orders_sn = []
predicted_sn = []
for n in ns_sn:
    A = sn_adj(n)
    gaps_sn.append(spectral_gap_from_adj(A))
    orders_sn.append(np.math.factorial(n))
    predicted_sn.append(2.0 / n)

axes[1].bar(range(len(ns_sn)), gaps_sn, color='steelblue', alpha=0.7, label='Computed')
axes[1].bar(range(len(ns_sn)), predicted_sn, color='none', edgecolor='red',
            linewidth=2, label='Predicted 2/n')
axes[1].set_xticks(range(len(ns_sn)))
axes[1].set_xticklabels([f'S_{n}\n(|G|={orders_sn[i]})' for i, n in enumerate(ns_sn)])
axes[1].set_ylabel('Spectral gap γ', fontsize=12)
axes[1].set_title('S_n with transpositions', fontsize=13)
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3, axis='y')

# Panel 3: Mixing time comparison
ns = list(range(3, 30))
classical_mixing = []
quantum_mixing = []

for n in ns:
    gamma = 2.0 / n
    N = np.math.factorial(n) if n <= 20 else np.exp(n * np.log(n) - n)  # Stirling
    tau_cl = (1.0 / gamma) * np.log(max(N, 2))
    tau_q = (1.0 / np.sqrt(gamma)) * np.sqrt(np.log(max(N, 2)))
    classical_mixing.append(tau_cl)
    quantum_mixing.append(tau_q)

axes[2].semilogy(ns, classical_mixing, 'b-', linewidth=2, label='Classical τ_cl')
axes[2].semilogy(ns, quantum_mixing, 'r-', linewidth=2, label='Quantum τ_q')
axes[2].fill_between(ns, quantum_mixing, classical_mixing, alpha=0.15, color='green',
                     label='Quantum advantage')
axes[2].set_xlabel('n (in S_n)', fontsize=12)
axes[2].set_ylabel('Mixing time (log scale)', fontsize=12)
axes[2].set_title('Classical vs Quantum Mixing', fontsize=13)
axes[2].legend(fontsize=10)
axes[2].grid(True, alpha=0.3)

plt.suptitle('Spectral Gaps and Mixing Times on Cayley Graphs', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('spectral_gap_analysis.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap_analysis.png")
