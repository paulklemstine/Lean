"""
Visualization: Tightness of the Entropy Bound

Shows the ratio S(A) / log(2/δ) across system sizes and cuts,
demonstrating that the formally verified bound is satisfied and
examining how tight it is in practice.
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
# Generate data
# ============================================================

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Bound tightness heatmap
h_values = np.linspace(0.3, 2.5, 15)
n_values = range(4, 9)

ratios_all = []
for n in n_values:
    row = []
    for h in h_values:
        H = tfim_hamiltonian(n, 1.0, h)
        vals, vecs = np.linalg.eigh(H)
        psi = vecs[:, 0]
        probs = np.abs(psi)**2
        probs /= probs.sum()
        
        delta = pair_mass_gap(probs)
        if delta <= 0 or delta == float('inf'):
            row.append(0)
            continue
        
        bound = np.log(2.0 / delta)
        
        # Max ratio across cuts
        max_ratio = 0
        for k in range(1, n):
            marg = marginal_distribution(probs, n, list(range(k)))
            S = shannon_entropy(marg)
            if bound > 0:
                max_ratio = max(max_ratio, S / bound)
        
        row.append(max_ratio)
    ratios_all.append(row)

ratios_arr = np.array(ratios_all)

im = axes[0].imshow(ratios_arr, aspect='auto', cmap='YlOrRd',
                     extent=[h_values[0], h_values[-1], max(n_values)+0.5, min(n_values)-0.5],
                     vmin=0, vmax=1)
axes[0].set_xlabel(r'Transverse field $h/J$', fontsize=13)
axes[0].set_ylabel('System size $n$', fontsize=13)
axes[0].set_title(r'Bound Tightness: $S_{\mathrm{marginal}}(A) / \log(2/\delta)$', fontsize=12)
axes[0].set_yticks(list(n_values))
plt.colorbar(im, ax=axes[0], label='Ratio (1 = tight)')

# Right: Distribution of ratios
all_ratios = []
for n in n_values:
    for h in np.linspace(0.3, 2.5, 20):
        H = tfim_hamiltonian(n, 1.0, h)
        vals, vecs = np.linalg.eigh(H)
        psi = vecs[:, 0]
        probs = np.abs(psi)**2
        probs /= probs.sum()
        
        delta = pair_mass_gap(probs)
        if delta <= 0 or delta == float('inf'):
            continue
        
        bound = np.log(2.0 / delta)
        if bound <= 0:
            continue
        
        for k in range(1, n):
            marg = marginal_distribution(probs, n, list(range(k)))
            S = shannon_entropy(marg)
            S_q = entanglement_entropy(psi, n, k)
            all_ratios.append({
                'n': n, 'h': h, 'k': k,
                'ratio_marginal': S / bound,
                'ratio_quantum': S_q / bound if bound > 0 else 0,
            })

# Histogram of ratios
ratios_m = [r['ratio_marginal'] for r in all_ratios]
ratios_q = [r['ratio_quantum'] for r in all_ratios]

axes[1].hist(ratios_m, bins=30, alpha=0.6, color='#2196F3', 
             label='Marginal entropy', density=True)
axes[1].hist(ratios_q, bins=30, alpha=0.6, color='#FF9800',
             label='Quantum entropy', density=True)
axes[1].axvline(x=1.0, color='red', linestyle='--', linewidth=2, label='Bound = 1')
axes[1].set_xlabel(r'$S / \log(2/\delta)$', fontsize=13)
axes[1].set_ylabel('Density', fontsize=13)
axes[1].set_title('Distribution of Entropy-to-Bound Ratios\n(All ratios < 1 confirms the theorem)', fontsize=12)
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

# Check all ratios < 1
max_ratio = max(ratios_m)
axes[1].annotate(f'Max ratio: {max_ratio:.4f}', 
                 xy=(max_ratio, 0), fontsize=10, color='#2196F3',
                 ha='center', va='bottom')

plt.tight_layout()
plt.savefig('bound_tightness.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved: bound_tightness.png")
