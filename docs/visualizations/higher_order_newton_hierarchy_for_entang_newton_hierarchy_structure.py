"""
Visualization: Newton hierarchy structure and defects.

Shows how Newton defects (e_k^2 - e_{k-1}*e_{k+1} >= 0) organize the
spectral data, and how the ratio profile log(rho_k) encodes phase information.

This visualizes the Lorentzian constraint structure from Newton's inequality.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def esymm_all_local(lam):
    m = len(lam)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for j in range(m):
        for r in range(min(m, j + 1), 0, -1):
            e[r] += lam[j] * e[r - 1]
    return e


def generate_spectrum(L, L_A, delta=0.0):
    H = np.zeros((L, L))
    for i in range(L - 1):
        H[i, i + 1] = -1.0
        H[i + 1, i] = -1.0
    for i in range(L):
        H[i, i] = delta * (-1) ** i
    _, states = np.linalg.eigh(H)
    K = states[:, :L // 2] @ states[:, :L // 2].T
    return np.clip(np.sort(np.linalg.eigvalsh(K[:L_A, :L_A]))[::-1], 0, 1)


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Log-concavity of e_k sequence
ax = axes[0, 0]
L_A = 12
for delta in [0.0, 0.5, 1.0, 2.0]:
    lam = generate_spectrum(60, L_A, delta=delta)
    e = esymm_all_local(lam)
    ks = np.arange(len(e))
    log_e = np.log(np.maximum(e, 1e-20))
    ax.plot(ks, log_e, 'o-', markersize=4, label=f'gap={delta}')

ax.set_xlabel('k')
ax.set_ylabel('log(e_k)')
ax.set_title('Log-concavity of elementary symmetric polynomials')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: Newton defects
ax = axes[0, 1]
for delta in [0.0, 0.5, 1.0, 2.0]:
    lam = generate_spectrum(60, L_A, delta=delta)
    e = esymm_all_local(lam)
    m = len(lam)
    defects = np.array([e[k]**2 - e[k-1]*e[k+1] for k in range(1, m)])
    ks = np.arange(1, m)
    ax.semilogy(ks, np.maximum(defects, 1e-20), 'o-', markersize=4, label=f'gap={delta}')

ax.set_xlabel('k')
ax.set_ylabel('Newton defect Δ_k (log scale)')
ax.set_title('Newton defects Δ_k = e_k² − e_{k−1}·e_{k+1} ≥ 0')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 3: Newton ratios across gap values
ax = axes[1, 0]
for L_A in [6, 10, 15, 20]:
    lam = generate_spectrum(80, L_A, delta=0.3)
    e = esymm_all_local(lam)
    m = len(lam)
    ratios = []
    for k in range(1, m):
        denom = e[k-1] * e[k+1]
        if abs(denom) > 1e-15:
            ratios.append(e[k]**2 / denom)
        else:
            ratios.append(np.nan)
    ks = np.arange(1, m)
    ax.plot(ks, np.log(np.array(ratios)), 'o-', markersize=3, label=f'L_A={L_A}')

ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5, label='ρ_k = 1')
ax.set_xlabel('k')
ax.set_ylabel('log(ρ_k)')
ax.set_title('Newton ratio profile (gap=0.3)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 4: Phase diagram — max log(rho) vs gap
ax = axes[1, 1]
deltas = np.linspace(0, 3, 30)
L_A = 12
max_log_rhos = []
entropies = []

for delta in deltas:
    lam = generate_spectrum(60, L_A, delta=delta)
    e = esymm_all_local(lam)
    m = len(lam)

    S = sum(-x * np.log(x) - (1-x) * np.log(1-x) if 0 < x < 1 else 0 for x in lam)
    ratios = []
    for k in range(1, m):
        denom = e[k-1] * e[k+1]
        if abs(denom) > 1e-15:
            ratios.append(e[k]**2 / denom)
    if ratios:
        max_lr = np.max(np.abs(np.log(np.array(ratios))))
    else:
        max_lr = 0
    max_log_rhos.append(max_lr)
    entropies.append(S)

ax2 = ax.twinx()
l1, = ax.plot(deltas, entropies, 'b-o', markersize=3, label='Entropy S')
l2, = ax2.plot(deltas, max_log_rhos, 'r-s', markersize=3, label='max|log ρ_k|')
ax.set_xlabel('Gap parameter δ')
ax.set_ylabel('Shannon entropy S', color='blue')
ax2.set_ylabel('max|log ρ_k|', color='red')
ax.set_title('Entropy and Newton-ratio diagnostics vs gap')
ax.legend(handles=[l1, l2], loc='center right')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_newton_hierarchy.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_newton_hierarchy.png")
