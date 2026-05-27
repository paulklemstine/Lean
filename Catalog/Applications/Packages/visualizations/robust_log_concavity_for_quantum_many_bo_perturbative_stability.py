"""
Visualization: Perturbative Stability of Measurement Distributions

Shows how the formal perturbation theorems work in practice:
1. Heatmap of measurement distributions at different field strengths
2. Perturbation parameter ε as a function of distance from reference
3. Guaranteed vs actual bounds from the formal theorems

Demonstrates event_prob_ratio_bound and minMass_perturbation_lower_bound.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


def pauli_x():
    return np.array([[0, 1], [1, 0]], dtype=complex)

def pauli_z():
    return np.array([[1, 0], [0, -1]], dtype=complex)

def kron_at(op, site, n):
    result = np.eye(1, dtype=complex)
    for i in range(n):
        result = np.kron(result, op if i == site else np.eye(2, dtype=complex))
    return result

def tfim_hamiltonian(n, J, h):
    dim = 2**n
    H = np.zeros((dim, dim), dtype=complex)
    for i in range(n - 1):
        H -= J * kron_at(pauli_z(), i, n) @ kron_at(pauli_z(), i + 1, n)
    for i in range(n):
        H -= h * kron_at(pauli_x(), i, n)
    return H

def ground_probs(n, J, h):
    H = tfim_hamiltonian(n, J, h)
    evals, evecs = np.linalg.eigh(H)
    idx = np.argsort(evals)
    return np.abs(evecs[:, idx[0]])**2


n = 5
dim = 2**n
h_ref = 1.0
probs_ref = ground_probs(n, 1.0, h_ref)

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: Heatmap of distributions
h_values = np.linspace(0.2, 2.5, 40)
dist_matrix = np.zeros((len(h_values), dim))
for i, h in enumerate(h_values):
    dist_matrix[i] = ground_probs(n, 1.0, h)

im = axes[0, 0].imshow(dist_matrix, aspect='auto', cmap='hot',
                        extent=[0, dim-1, h_values[-1], h_values[0]],
                        norm=LogNorm(vmin=1e-6, vmax=1))
axes[0, 0].set_xlabel('Configuration index', fontsize=11)
axes[0, 0].set_ylabel('Transverse field h', fontsize=11)
axes[0, 0].set_title('Ground-State Measurement Distribution', fontsize=12, fontweight='bold')
plt.colorbar(im, ax=axes[0, 0], label='μ(x)')

# Panel 2: Perturbation ε vs distance
deltas = np.linspace(0.01, 1.5, 50)
epsilons = []
for d in deltas:
    probs_pert = ground_probs(n, 1.0, h_ref + d)
    mask = (probs_ref > 1e-15) & (probs_pert > 1e-15)
    if np.any(mask):
        eps = float(np.max(np.abs(np.log(probs_pert[mask] / probs_ref[mask]))))
    else:
        eps = float('inf')
    epsilons.append(eps)

axes[0, 1].plot(deltas, epsilons, 'b-', linewidth=2)
axes[0, 1].fill_between(deltas, 0, epsilons, alpha=0.15, color='blue')
axes[0, 1].set_xlabel('Distance from reference |h - h₀|', fontsize=11)
axes[0, 1].set_ylabel('Perturbation parameter ε', fontsize=11)
axes[0, 1].set_title('Multiplicative Closeness', fontsize=12, fontweight='bold')
axes[0, 1].grid(True, alpha=0.3)

# Panel 3: Guaranteed vs actual event probabilities
test_deltas = [0.1, 0.3, 0.5, 0.8, 1.0]
event = np.arange(dim // 2)  # first half

for d in test_deltas:
    probs_pert = ground_probs(n, 1.0, h_ref + d)
    mask = (probs_ref > 1e-15) & (probs_pert > 1e-15)
    eps = float(np.max(np.abs(np.log(probs_pert[mask] / probs_ref[mask])))) if np.any(mask) else 10.0

    nu_sum = np.sum(probs_ref[event])
    mu_sum = np.sum(probs_pert[event])
    lower = np.exp(-eps) * nu_sum
    upper = np.exp(eps) * nu_sum

    axes[1, 0].errorbar(d, mu_sum, yerr=[[mu_sum - lower], [upper - mu_sum]],
                        fmt='o', color='darkblue', capsize=5, markersize=8)

axes[1, 0].set_xlabel('Perturbation δh', fontsize=11)
axes[1, 0].set_ylabel('Event probability Pr[first half]', fontsize=11)
axes[1, 0].set_title('Event Prob Ratio Bound (Theorem 1)', fontsize=12, fontweight='bold')
axes[1, 0].grid(True, alpha=0.3)

# Panel 4: MinMass guaranteed vs actual
min_mass_ref = float(np.min(probs_ref))
deltas_dense = np.linspace(0.01, 1.2, 40)
guaranteed_list = []
actual_list = []

for d in deltas_dense:
    probs_pert = ground_probs(n, 1.0, h_ref + d)
    mask = (probs_ref > 1e-15) & (probs_pert > 1e-15)
    eps = float(np.max(np.abs(np.log(probs_pert[mask] / probs_ref[mask])))) if np.any(mask) else 10.0
    guaranteed_list.append(np.exp(-eps) * min_mass_ref)
    actual_list.append(float(np.min(probs_pert)))

axes[1, 1].semilogy(deltas_dense, actual_list, 'b-o', markersize=3, linewidth=1.5, label='Actual min mass')
axes[1, 1].semilogy(deltas_dense, guaranteed_list, 'r--s', markersize=3, linewidth=1.5, label='Guaranteed (Theorem 2)')
axes[1, 1].fill_between(deltas_dense, guaranteed_list, actual_list, alpha=0.1, color='green')
axes[1, 1].set_xlabel('Perturbation δh', fontsize=11)
axes[1, 1].set_ylabel('Minimum mass', fontsize=11)
axes[1, 1].set_title('MinMass Perturbation Bound (Theorem 2)', fontsize=12, fontweight='bold')
axes[1, 1].legend(fontsize=9)
axes[1, 1].grid(True, alpha=0.3)

plt.suptitle('Perturbative Stability of Quantum Measurement Distributions (n=5)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_perturbation.png', dpi=150, bbox_inches='tight')
