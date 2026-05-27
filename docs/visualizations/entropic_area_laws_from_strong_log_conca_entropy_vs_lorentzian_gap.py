"""
Visualization: Entropy vs Lorentzian Gap for TFIM Ground States

This script produces a scatter plot showing the relationship between
the pair-mass gap δ (Lorentzian gap surrogate) and the Shannon entropy
across bipartition cuts for TFIM ground states at various system sizes.

The key finding: entropy scales logarithmically with 1/δ, consistent
with area-law behavior. The formally verified bound log(2/δ) serves
as a rigorous upper envelope.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


# ============================================================
# Self-contained functions (no local imports)
# ============================================================

def shannon_entropy(probs):
    result = 0.0
    for p in probs:
        if p > 0:
            result -= p * np.log(p)
    return result

def pair_mass_gap(probs, tol=1e-12):
    support = probs[probs > tol]
    if len(support) < 2:
        return float('inf')
    s = np.sort(support)
    return s[0] + s[1]

def marginal_distribution(probs, n, subset):
    k = len(subset)
    marg = np.zeros(2**k)
    for x in range(2**n):
        bits = tuple((x >> (n - 1 - i)) & 1 for i in subset)
        idx = sum(b << (k - 1 - j) for j, b in enumerate(bits))
        marg[idx] += probs[x]
    return marg

def pauli_x():
    return np.array([[0,1],[1,0]], dtype=complex)

def pauli_z():
    return np.array([[1,0],[0,-1]], dtype=complex)

def kron_at(op, site, n):
    result = np.array([[1.0]], dtype=complex)
    for i in range(n):
        result = np.kron(result, op if i == site else np.eye(2, dtype=complex))
    return result

def tfim_hamiltonian(n, J=1.0, h=1.0):
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    for i in range(n-1):
        H -= J * kron_at(pauli_z(), i, n) @ kron_at(pauli_z(), i+1, n)
    for i in range(n):
        H -= h * kron_at(pauli_x(), i, n)
    return H

def ground_state(H):
    vals, vecs = np.linalg.eigh(H)
    psi = vecs[:, 0]
    return psi

def entanglement_entropy(psi, n, k):
    mat = psi.reshape(2**k, 2**(n-k))
    sv = np.linalg.svd(mat, compute_uv=False)
    sp = sv**2
    sp = sp[sp > 1e-15]
    return -np.sum(sp * np.log(sp))


# ============================================================
# Generate data
# ============================================================

data_points = []
colors_map = {4: '#2196F3', 5: '#4CAF50', 6: '#FF9800', 7: '#9C27B0', 8: '#F44336'}
marker_map = {4: 'o', 5: 's', 6: '^', 7: 'D', 8: 'v'}

for n in range(4, 9):
    for h in np.linspace(0.3, 2.5, 12):
        H = tfim_hamiltonian(n, 1.0, h)
        psi = ground_state(H)
        probs = np.abs(psi)**2
        probs /= probs.sum()
        
        delta = pair_mass_gap(probs)
        if delta == float('inf') or delta <= 0:
            continue
        
        for k in range(1, n):
            marg = marginal_distribution(probs, n, list(range(k)))
            S_marginal = shannon_entropy(marg)
            S_quantum = entanglement_entropy(psi, n, k)
            
            data_points.append({
                'n': n, 'h': h, 'k': k,
                'delta': delta,
                'S_marginal': S_marginal,
                'S_quantum': S_quantum,
            })


# ============================================================
# Plot
# ============================================================

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: S_quantum vs log(1/δ)
ax1 = axes[0]
for n in range(4, 9):
    pts = [d for d in data_points if d['n'] == n]
    x = [np.log(1.0/d['delta']) for d in pts]
    y = [d['S_quantum'] for d in pts]
    ax1.scatter(x, y, c=colors_map[n], marker=marker_map[n], 
                s=30, alpha=0.6, label=f'n={n}')

# Theoretical bound
x_bound = np.linspace(0, max(np.log(1/d['delta']) for d in data_points), 100)
y_bound = np.log(2) + x_bound  # log(2/δ) = log(2) + log(1/δ)
ax1.plot(x_bound, y_bound, 'k--', linewidth=2, label=r'Bound: $\log(2/\delta)$', alpha=0.7)

ax1.set_xlabel(r'$\log(1/\delta)$', fontsize=13)
ax1.set_ylabel(r'$S(A)$ (nats)', fontsize=13)
ax1.set_title('Entanglement Entropy vs Log-Gap\n(Logarithmic Scaling = Area Law)', fontsize=12)
ax1.legend(fontsize=9, loc='upper left')
ax1.grid(True, alpha=0.3)

# Panel 2: S_quantum vs 1/δ
ax2 = axes[1]
for n in range(4, 9):
    pts = [d for d in data_points if d['n'] == n]
    x = [1.0/d['delta'] for d in pts]
    y = [d['S_quantum'] for d in pts]
    ax2.scatter(x, y, c=colors_map[n], marker=marker_map[n],
                s=30, alpha=0.6, label=f'n={n}')

ax2.set_xlabel(r'$1/\delta$', fontsize=13)
ax2.set_ylabel(r'$S(A)$ (nats)', fontsize=13)
ax2.set_title('Entanglement Entropy vs Inverse Gap\n(Linear Scaling = Volume Law)', fontsize=12)
ax2.legend(fontsize=9, loc='upper left')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('entropy_vs_gap.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved: entropy_vs_gap.png")
