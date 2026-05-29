#!/usr/bin/env python3
"""
Visualization 2: Perturbation Stability of Event Probabilities

Demonstrates Theorem 1 (event_prob_ratio_bound): when two distributions are
multiplicatively ε-close pointwise, event probabilities are also ε-close.
Shows the exponential envelope exp(±ε) · ν(s) bounding μ(s) for various events.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


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

def get_ground_state_probs(n, J, h):
    H = tfim_hamiltonian(n, J, h)
    evals, evecs = np.linalg.eigh(H)
    psi = evecs[:, np.argmin(evals)]
    return np.abs(psi)**2


n = 5
J = 1.0
h_ref = 3.0  # Reference (deep paramagnetic)
mu_ref = get_ground_state_probs(n, J, h_ref)

h_values = np.linspace(0.5, 3.0, 40)

# Define several events
dim = 2**n
events = {
    'First half': np.arange(dim) < dim // 2,
    'Even configs': np.arange(dim) % 2 == 0,
    'Low weight': np.array([bin(x).count('1') <= n//2 for x in range(dim)]),
    'Single config': np.arange(dim) == 0,
}

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

for ax, (event_name, event_mask) in zip(axes.flatten(), events.items()):
    ref_prob = np.sum(mu_ref[event_mask])
    
    actual_probs = []
    epsilons = []
    lower_bounds = []
    upper_bounds = []
    
    for h in h_values:
        mu = get_ground_state_probs(n, J, h)
        actual = np.sum(mu[event_mask])
        actual_probs.append(actual)
        
        # Compute ε
        valid = (mu_ref > 1e-15) & (mu > 1e-15)
        if np.any(valid):
            eps = np.max(np.abs(np.log(mu[valid] / mu_ref[valid])))
        else:
            eps = 5.0
        epsilons.append(eps)
        lower_bounds.append(np.exp(-eps) * ref_prob)
        upper_bounds.append(np.exp(eps) * ref_prob)
    
    ax.fill_between(h_values, lower_bounds, upper_bounds, alpha=0.2, color='blue',
                     label='Certified envelope')
    ax.plot(h_values, actual_probs, 'r-', linewidth=2, label='Actual μ(s)')
    ax.plot(h_values, lower_bounds, 'b--', alpha=0.5, linewidth=1)
    ax.plot(h_values, upper_bounds, 'b--', alpha=0.5, linewidth=1)
    ax.axhline(y=ref_prob, color='g', linestyle=':', alpha=0.5, label=f'ν(s)={ref_prob:.3f}')
    ax.axvline(x=h_ref, color='gray', linestyle=':', alpha=0.3)
    ax.set_xlabel('Transverse field h', fontsize=11)
    ax.set_ylabel('Event probability', fontsize=11)
    ax.set_title(f'Event: {event_name}', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.2)
    ax.set_ylim(bottom=0)

plt.suptitle('Theorem 1: Event Probability Ratio Bound\n'
             r'$e^{-\varepsilon}\nu(s) \leq \mu(s) \leq e^{\varepsilon}\nu(s)$',
             fontsize=15)
plt.tight_layout()
plt.savefig('viz_perturbation_stability.png', dpi=150, bbox_inches='tight')
print("Saved viz_perturbation_stability.png")
