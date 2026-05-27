"""
Visualization 3: Transfer Matrix Evolution and State Vector Dynamics

Shows how the state vector evolves under transfer matrix multiplication,
demonstrating the connection between local transfer steps and global
Lorentzian structure.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def state_vector_evolution(n_max, v, T_mat):
    """Compute state vectors for all chain lengths up to n_max."""
    states = [np.array([1.0, 1.0])]  # n=0
    states.append(v.copy())            # n=1
    
    s = v.copy()
    for _ in range(n_max - 1):
        s = T_mat.T @ s
        states.append(s.copy())
    
    return states


def weight_marginals_from_chain(n, v, T_mat):
    """Compute weight marginals for chain of length n."""
    if n == 0:
        return np.array([1.0])
    
    values = np.zeros(2**n)
    for idx in range(2**n):
        config = [(idx >> i) & 1 for i in range(n)]
        amp = v[config[0]]
        for i in range(n - 1):
            amp *= T_mat[config[i], config[i+1]]
        values[idx] = amp
    
    S = np.zeros(n + 1)
    for idx in range(2**n):
        w = bin(idx).count('1')
        S[w] += values[idx]
    return S


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Transfer Matrix Evolution and Lorentzian Structure', 
             fontsize=14, fontweight='bold')

# --- Panel 1: State Vector Evolution ---
ax = axes[0, 0]
n_max = 15

configs = [
    ('Ferromagnetic (J=1.0)', 1.0, 'blue'),
    ('Weak coupling (J=0.3)', 0.3, 'green'),
    ('Strong coupling (J=2.0)', 2.0, 'red'),
]

for label, J, color in configs:
    alpha = np.exp(J)
    beta = np.exp(-J)
    T = np.array([[alpha, beta], [beta, alpha]])
    v = np.array([1.0, 1.0])
    
    states = state_vector_evolution(n_max, v, T)
    
    # Plot ratio s[0]/(s[0]+s[1]) as the "magnetization" of the state
    ratios = [s[0]/(s[0]+s[1]) if s[0]+s[1] > 0 else 0.5 for s in states[1:]]
    Z_vals = [s[0]+s[1] for s in states[1:]]
    
    ax.plot(range(1, n_max + 1), ratios, 'o-', color=color, label=label, 
            linewidth=2, markersize=4)

ax.set_xlabel('Chain length n')
ax.set_ylabel('State ratio s₀/(s₀+s₁)')
ax.set_title('State Vector Evolution under Transfer')
ax.axhline(y=0.5, color='gray', linestyle='--', alpha=0.3)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# --- Panel 2: Partition Function Growth ---
ax = axes[0, 1]

for label, J, color in configs:
    alpha = np.exp(J)
    beta = np.exp(-J)
    T = np.array([[alpha, beta], [beta, alpha]])
    v = np.array([1.0, 1.0])
    
    states = state_vector_evolution(n_max, v, T)
    Z_vals = [s[0]+s[1] for s in states[1:]]
    
    ax.semilogy(range(1, n_max + 1), Z_vals, 'o-', color=color, label=label,
                linewidth=2, markersize=4)

ax.set_xlabel('Chain length n')
ax.set_ylabel('Partition function Z')
ax.set_title('Partition Function Growth')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# --- Panel 3: Weight Marginal Evolution ---
ax = axes[1, 0]
J = 1.0
alpha = np.exp(J)
beta_val = np.exp(-J)
T = np.array([[alpha, beta_val], [beta_val, alpha]])
v = np.array([1.0, 1.0])

n_show = [3, 5, 7, 9]
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(n_show)))

for n, color in zip(n_show, colors):
    S = weight_marginals_from_chain(n, v, T)
    S_norm = S / S.sum()
    x = np.array(range(n + 1)) / n  # Normalize to [0,1]
    ax.plot(x, S_norm * n, 'o-', color=color, label=f'n={n}', 
            linewidth=2, markersize=5)

ax.set_xlabel('Normalized weight k/n')
ax.set_ylabel('Scaled marginal n·S_k/Z')
ax.set_title(f'Weight Marginal Convergence (J={J})')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# --- Panel 4: Total Nonnegativity and Determinant ---
ax = axes[1, 1]
J_range = np.linspace(0.0, 3.0, 100)
det_vals = []
trace_vals = []
spectral_gap = []

for J in J_range:
    alpha = np.exp(J)
    beta_val = np.exp(-J)
    T = np.array([[alpha, beta_val], [beta_val, alpha]])
    det_vals.append(np.linalg.det(T))
    trace_vals.append(np.trace(T))
    eigs = np.linalg.eigvalsh(T)
    spectral_gap.append(eigs[1] - eigs[0])

ax.plot(J_range, det_vals, 'b-', label='det(T) = α² − β²', linewidth=2)
ax.plot(J_range, trace_vals, 'r-', label='tr(T) = 2α', linewidth=2)
ax.plot(J_range, spectral_gap, 'g--', label='Spectral gap', linewidth=2)
ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
ax.set_xlabel('Coupling J')
ax.set_ylabel('Value')
ax.set_title('Transfer Matrix Properties')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_transfer.png', dpi=150, bbox_inches='tight')
print("Saved viz_transfer.png")
