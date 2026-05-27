"""
Visualization: Phase Diagram — Gap and Entropy vs Transverse Field

Shows how the pair-mass gap δ and entanglement entropy evolve across 
the TFIM quantum phase transition (h/J = 1). The gap minimum signals
the critical point, where entropy is maximized and the area-law bound
is least constraining.
"""

import numpy as np
import matplotlib.pyplot as plt


# ============================================================
# Self-contained functions
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

def entanglement_entropy(psi, n, k):
    mat = psi.reshape(2**k, 2**(n-k))
    sv = np.linalg.svd(mat, compute_uv=False)
    sp = sv**2
    sp = sp[sp > 1e-15]
    return -np.sum(sp * np.log(sp))


# ============================================================
# Generate phase diagram data
# ============================================================

h_values = np.linspace(0.1, 3.0, 50)
system_sizes = [4, 6, 8]
colors = ['#2196F3', '#FF9800', '#F44336']

fig, axes = plt.subplots(2, 1, figsize=(10, 8), sharex=True)

for idx, n in enumerate(system_sizes):
    gaps = []
    mid_entropies = []
    bounds = []
    
    for h in h_values:
        H = tfim_hamiltonian(n, 1.0, h)
        vals, vecs = np.linalg.eigh(H)
        psi = vecs[:, 0]
        probs = np.abs(psi)**2
        probs /= probs.sum()
        
        delta = pair_mass_gap(probs)
        gaps.append(delta if delta < float('inf') else 1.0)
        
        k = n // 2
        S = entanglement_entropy(psi, n, k)
        mid_entropies.append(S)
        
        if delta > 0 and delta < float('inf'):
            bounds.append(np.log(2.0 / delta))
        else:
            bounds.append(0)
    
    # Top panel: Pair-mass gap
    axes[0].plot(h_values, gaps, color=colors[idx], linewidth=2, 
                 label=f'n={n}', marker='o', markersize=3)
    
    # Bottom panel: Entanglement entropy and bound
    axes[1].plot(h_values, mid_entropies, color=colors[idx], linewidth=2,
                 label=f'S(n={n})', marker='o', markersize=3)
    axes[1].plot(h_values, bounds, color=colors[idx], linewidth=1,
                 linestyle='--', alpha=0.5, label=f'Bound (n={n})')

# Critical point marker
for ax in axes:
    ax.axvline(x=1.0, color='gray', linestyle=':', linewidth=1, alpha=0.7)

axes[0].set_ylabel(r'Pair-mass gap $\delta$', fontsize=13)
axes[0].set_title('TFIM Phase Diagram: Gap and Entropy vs Transverse Field', fontsize=13)
axes[0].legend(fontsize=10)
axes[0].grid(True, alpha=0.3)
axes[0].annotate('Critical point\n(h/J = 1)', xy=(1.0, 0), fontsize=9,
                 ha='center', va='bottom', color='gray')

axes[1].set_xlabel(r'Transverse field $h/J$', fontsize=13)
axes[1].set_ylabel(r'Mid-chain entropy $S(n/2)$ (nats)', fontsize=13)
axes[1].legend(fontsize=9, ncol=2)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('phase_diagram.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved: phase_diagram.png")
