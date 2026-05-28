#!/usr/bin/env python3
"""
Visualization: Eigenvalue Flow Under Perturbation

This script shows how the eigenvalues of the leaf Hessian J - I evolve
as perturbation strength increases, revealing the exact moment when
the Lorentzian signature breaks (a second eigenvalue crosses zero).

Panel 1: Eigenvalue flow for diagonal perturbation (m=6)
Panel 2: Eigenvalue flow for rank-one perturbation
Panel 3: Comparison of thresholds across perturbation types
"""

import numpy as np
import matplotlib.pyplot as plt


def leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Eigenvalue flow under diagonal perturbation
m = 6
H = leaf_hessian(m)
t_vals = np.linspace(0, 2.0, 300)
all_eigs = []

for t in t_vals:
    E = t * np.eye(m)
    eigs = np.linalg.eigvalsh(H + E)
    eigs.sort()
    all_eigs.append(eigs)

all_eigs = np.array(all_eigs)
colors = ['#d62728', '#ff7f0e', '#2ca02c', '#1f77b4', '#9467bd', '#8c564b']

for k in range(m):
    label = None
    if k == 0:
        label = f'λ = {m-1}+t (positive)'
    elif k == 1:
        label = f'λ = -1+t (×{m-1})'
    axes[0].plot(t_vals, all_eigs[:, k], color=colors[min(k, len(colors)-1)],
                  linewidth=2 if k in [0, m-1] else 1, label=label)

axes[0].axhline(y=0, color='gray', linestyle='--', alpha=0.5)
axes[0].axvline(x=1.0, color='red', linestyle=':', alpha=0.7, linewidth=2)
axes[0].annotate('Threshold t = 1', xy=(1.0, 0), xytext=(1.3, -0.5),
                  fontsize=10, arrowprops=dict(arrowstyle='->', color='red'),
                  color='red')
axes[0].set_xlabel('Perturbation strength t', fontsize=12)
axes[0].set_ylabel('Eigenvalue', fontsize=12)
axes[0].set_title(f'Eigenvalue Flow: (J−I) + tI, m={m}', fontsize=13)
axes[0].legend(fontsize=9)

# Panel 2: Rank-one perturbation
all_eigs_r1 = []
for t in t_vals:
    E = np.zeros((m, m))
    E[0, 0] = t
    eigs = np.linalg.eigvalsh(H + E)
    eigs.sort()
    all_eigs_r1.append(eigs)

all_eigs_r1 = np.array(all_eigs_r1)
for k in range(m):
    axes[1].plot(t_vals, all_eigs_r1[:, k], 
                  color=colors[min(k, len(colors)-1)],
                  linewidth=1.5)

axes[1].axhline(y=0, color='gray', linestyle='--', alpha=0.5)

# Find threshold
for i in range(len(t_vals) - 1):
    eigs = np.linalg.eigvalsh(H + t_vals[i] * np.diag([1] + [0]*(m-1)))
    n_pos = np.sum(eigs > 1e-10)
    if n_pos > 1:
        axes[1].axvline(x=t_vals[i], color='red', linestyle=':', alpha=0.7, linewidth=2)
        break

axes[1].set_xlabel('Perturbation strength t', fontsize=12)
axes[1].set_ylabel('Eigenvalue', fontsize=12)
axes[1].set_title(f'Eigenvalue Flow: (J−I) + t·e₁e₁ᵀ, m={m}', fontsize=13)

# Panel 3: Threshold comparison across dimensions
ms = list(range(3, 18))
thresholds_diag = []
thresholds_r1 = []
thresholds_uniform = []

for m in ms:
    H = leaf_hessian(m)
    
    # Diagonal threshold (exact: t = 1)
    thresholds_diag.append(1.0)
    
    # Rank-one threshold (binary search)
    lo, hi = 0.0, 10.0
    for _ in range(100):
        mid = (lo + hi) / 2
        E = np.zeros((m, m))
        E[0, 0] = mid
        eigs = np.linalg.eigvalsh(H + E)
        if np.sum(eigs > 1e-10) <= 1:
            lo = mid
        else:
            hi = mid
    thresholds_r1.append((lo + hi) / 2)
    
    # Uniform random (average over trials)
    np.random.seed(42)
    trial_thresholds = []
    for _ in range(20):
        R = np.random.randn(m, m)
        R = (R + R.T) / 2
        R /= max(np.max(np.abs(np.linalg.eigvalsh(R))), 1e-10)
        lo, hi = 0.0, 10.0
        for _ in range(80):
            mid = (lo + hi) / 2
            eigs = np.linalg.eigvalsh(H + mid * R)
            if np.sum(eigs > 1e-10) <= 1:
                lo = mid
            else:
                hi = mid
        trial_thresholds.append((lo + hi) / 2)
    thresholds_uniform.append(np.mean(trial_thresholds))

axes[2].plot(ms, thresholds_diag, 'ko-', markersize=5, label='Diagonal (tI)', linewidth=2)
axes[2].plot(ms, thresholds_r1, 'b^-', markersize=5, label='Rank-one (te₁e₁ᵀ)')
axes[2].plot(ms, thresholds_uniform, 'rs-', markersize=4, label='Random symmetric (avg)')
axes[2].axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='Gap = 1')
axes[2].set_xlabel('Leaf dimension m', fontsize=12)
axes[2].set_ylabel('Instability threshold', fontsize=12)
axes[2].set_title('Threshold Comparison Across Perturbation Types', fontsize=13)
axes[2].legend(fontsize=9)

plt.tight_layout()
plt.savefig('eigenvalue_flow.png', dpi=150, bbox_inches='tight')
print("Saved eigenvalue_flow.png")
