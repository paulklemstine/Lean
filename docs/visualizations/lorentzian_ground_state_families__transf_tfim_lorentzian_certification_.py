"""
Visualization 1: Lorentzian Certification Heatmap in TFIM Parameter Space

Visualizes which (J, β_scale) parameter points yield weight-log-concave 
(Lorentzian) ground-state families for qubit chains of various lengths.
The heatmap reveals the phase boundary of Lorentzianity.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb


def chain_amplitude_values(n, v, T_mat):
    """Product-form chain amplitudes."""
    if n == 0:
        return np.array([1.0])
    values = np.zeros(2**n)
    for idx in range(2**n):
        config = [(idx >> i) & 1 for i in range(n)]
        amp = v[config[0]]
        for i in range(n - 1):
            amp *= T_mat[config[i], config[i+1]]
        values[idx] = amp
    return values


def weight_marginals(n, values):
    """Compute weight marginals S_0, ..., S_n."""
    S = np.zeros(n + 1)
    for idx in range(len(values)):
        w = bin(idx).count('1')
        S[w] += values[idx]
    return S


def is_weight_log_concave(S):
    """Check S_k^2 >= S_{k-1} * S_{k+1}."""
    n = len(S) - 1
    for k in range(1, n):
        if S[k]**2 < S[k-1] * S[k+1] - 1e-12:
            return False
    return True


# Parameters
n_vals = [4, 6, 8, 10]
J_range = np.linspace(0.0, 3.0, 40)
beta_range = np.linspace(0.01, 3.0, 40)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Lorentzian Certification in TFIM Parameter Space\n'
             '(Weight Log-Concavity of Transfer-Matrix Amplitudes)', 
             fontsize=14, fontweight='bold')

for ax_idx, n in enumerate(n_vals):
    ax = axes[ax_idx // 2, ax_idx % 2]
    
    results = np.zeros((len(J_range), len(beta_range)))
    log_concavity_margin = np.zeros((len(J_range), len(beta_range)))
    
    for i, J in enumerate(J_range):
        for j, bs in enumerate(beta_range):
            alpha = np.exp(J)
            beta_val = np.exp(-J) * bs
            T_mat = np.array([[alpha, beta_val], [beta_val, alpha]])
            v = np.array([1.0, 1.0])
            values = chain_amplitude_values(n, v, T_mat)
            S = weight_marginals(n, values)
            
            # Compute minimum log-concavity ratio
            min_ratio = float('inf')
            for k in range(1, n):
                denom = S[k-1] * S[k+1]
                if denom > 1e-20:
                    ratio = S[k]**2 / denom
                    min_ratio = min(min_ratio, ratio)
            
            results[i, j] = 1.0 if is_weight_log_concave(S) else 0.0
            log_concavity_margin[i, j] = min(min_ratio, 5.0) if min_ratio < float('inf') else 5.0
    
    im = ax.imshow(log_concavity_margin, origin='lower', aspect='auto',
                   extent=[beta_range[0], beta_range[-1], J_range[0], J_range[-1]],
                   cmap='RdYlGn', vmin=0.5, vmax=2.5)
    
    # Overlay contour at ratio = 1 (Lorentzian boundary)
    ax.contour(beta_range, J_range, results, levels=[0.5], colors='black', linewidths=2)
    
    certified_pct = 100 * results.sum() / results.size
    ax.set_title(f'n = {n}  ({certified_pct:.0f}% certified)', fontsize=12)
    ax.set_xlabel('β scale (field strength)')
    ax.set_ylabel('J (coupling)')
    
    plt.colorbar(im, ax=ax, label='Min log-concavity ratio S_k²/(S_{k-1}S_{k+1})')

plt.tight_layout()
plt.savefig('viz_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_heatmap.png")
