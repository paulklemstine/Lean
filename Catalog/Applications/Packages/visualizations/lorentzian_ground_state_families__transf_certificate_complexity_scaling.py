"""
Visualization 2: Certificate Complexity Scaling

Shows how certificate depth and verification complexity scale with chain length n,
comparing brute-force Hessian checking with the chain-inductive O(n) scheme.
Also shows weight marginal profiles for different chain lengths.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb, log2


def chain_amplitude_values(n, v, T_mat):
    """Product-form chain amplitudes."""
    values = np.zeros(2**n)
    for idx in range(2**n):
        config = [(idx >> i) & 1 for i in range(n)]
        amp = v[config[0]]
        for i in range(n - 1):
            amp *= T_mat[config[i], config[i+1]]
        values[idx] = amp
    return values


def weight_marginals(n, values):
    """Compute weight marginals."""
    S = np.zeros(n + 1)
    for idx in range(len(values)):
        w = bin(idx).count('1')
        S[w] += values[idx]
    return S


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Lorentzian Certificate Structure for Qubit Chains', 
             fontsize=14, fontweight='bold')

# --- Panel 1: Complexity Scaling ---
ax = axes[0, 0]
n_range = range(2, 16)
brute_force = []
chain_inductive = []
for n in n_range:
    bf = comb(2*n, max(n-2, 0)) * (2*n)**2
    ci = n * 4
    brute_force.append(bf)
    chain_inductive.append(ci)

ax.semilogy(list(n_range), brute_force, 'ro-', label='Brute force (Hessian)', linewidth=2)
ax.semilogy(list(n_range), chain_inductive, 'b^-', label='Chain inductive O(n)', linewidth=2)
ax.set_xlabel('Chain length n')
ax.set_ylabel('Verification operations')
ax.set_title('Certificate Verification Complexity')
ax.legend()
ax.grid(True, alpha=0.3)

# --- Panel 2: Certificate Depth ---
ax = axes[0, 1]
n_range2 = range(2, 21)
depths = [n for n in n_range2]
ax.plot(list(n_range2), depths, 'gs-', linewidth=2, markersize=6)
ax.plot(list(n_range2), list(n_range2), 'k--', alpha=0.5, label='y = n')
ax.set_xlabel('Chain length n')
ax.set_ylabel('Certificate depth')
ax.set_title('Certificate Depth = O(n)')
ax.legend()
ax.grid(True, alpha=0.3)

# --- Panel 3: Weight Marginals for Different J ---
ax = axes[1, 0]
n = 10
J_vals = [0.0, 0.5, 1.0, 2.0]
colors = ['blue', 'green', 'orange', 'red']

for J, color in zip(J_vals, colors):
    alpha = np.exp(J)
    beta = np.exp(-J)
    T = np.array([[alpha, beta], [beta, alpha]])
    v = np.array([1.0, 1.0])
    values = chain_amplitude_values(n, v, T)
    S = weight_marginals(n, values)
    S_norm = S / S.sum()
    
    ax.plot(range(n + 1), S_norm, 'o-', color=color, label=f'J = {J}', 
            linewidth=2, markersize=5)

# Also plot binomial (independent)
binom = np.array([comb(n, k) for k in range(n + 1)], dtype=float)
binom /= binom.sum()
ax.plot(range(n + 1), binom, 'k--', label='Binomial (J=0)', linewidth=1, alpha=0.5)

ax.set_xlabel('Weight k (number of 1s)')
ax.set_ylabel('Normalized marginal')
ax.set_title(f'Weight Marginal Profiles (n={n})')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# --- Panel 4: Log-Concavity Margin vs J ---
ax = axes[1, 1]
n_test_vals = [6, 8, 10, 12]
J_scan = np.linspace(0.0, 3.0, 50)

for n in n_test_vals:
    margins = []
    for J in J_scan:
        alpha = np.exp(J)
        beta = np.exp(-J)
        T = np.array([[alpha, beta], [beta, alpha]])
        v = np.array([1.0, 1.0])
        values = chain_amplitude_values(n, v, T)
        S = weight_marginals(n, values)
        
        min_ratio = float('inf')
        for k in range(1, n):
            denom = S[k-1] * S[k+1]
            if denom > 1e-20:
                ratio = S[k]**2 / denom
                min_ratio = min(min_ratio, ratio)
        margins.append(min(min_ratio, 10.0) if min_ratio < float('inf') else 10.0)
    
    ax.plot(J_scan, margins, '-', label=f'n={n}', linewidth=2)

ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='LC boundary')
ax.set_xlabel('Coupling J')
ax.set_ylabel('Min S_k² / (S_{k-1}·S_{k+1})')
ax.set_title('Log-Concavity Margin vs Coupling')
ax.legend(fontsize=9)
ax.set_ylim(0.8, 3.0)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_scaling.png', dpi=150, bbox_inches='tight')
print("Saved viz_scaling.png")
