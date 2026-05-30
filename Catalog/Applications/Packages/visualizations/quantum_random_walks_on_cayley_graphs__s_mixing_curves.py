#!/usr/bin/env python3
"""
Visualization: Mixing Curves for Classical vs Quantum Walks

Shows how the total variation distance to uniform decays over time
for classical random walks on various Cayley graphs. Compares the
empirical decay with the theoretical bound exp(-γt), verifying the
spectral gap controls convergence rate.
"""

import numpy as np
import matplotlib.pyplot as plt


def cayley_adj_cyclic(n, gens):
    A = np.zeros((n, n))
    for g in range(n):
        for s in gens:
            A[g][(g + s) % n] = 1
    return A


def simulate_classical_walk(A, steps):
    n = A.shape[0]
    P = A / A.sum(axis=1, keepdims=True)
    p = np.zeros(n)
    p[0] = 1.0
    uniform = np.ones(n) / n
    tvs = []
    for _ in range(steps):
        tvs.append(0.5 * np.sum(np.abs(p - uniform)))
        p = p @ P
    return np.array(tvs)


def spectral_gap_from_adj(A):
    d = A.sum(axis=1)[0]
    P = A / d
    eigs = np.sort(np.abs(np.linalg.eigvalsh(P)))[::-1]
    return 1.0 - eigs[1]


fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Plot 1: Z_20 with different generator sets
ax = axes[0, 0]
n = 20
configs = [
    ([1, n-1], '±1', 'blue'),
    ([1, n-1, 2, n-2], '±1, ±2', 'red'),
    ([1, n-1, 5, n-5], '±1, ±5', 'green'),
]
steps = 200

for gens, label, color in configs:
    A = cayley_adj_cyclic(n, gens)
    tvs = simulate_classical_walk(A, steps)
    gap = spectral_gap_from_adj(A)
    ax.plot(tvs, color=color, linewidth=1.5, label=f'S={{{label}}}, γ={gap:.3f}')
    # Theoretical bound
    ts = np.arange(steps)
    ax.plot(np.exp(-gap * ts), color=color, linewidth=1, linestyle='--', alpha=0.5)

ax.set_xlabel('Steps t', fontsize=11)
ax.set_ylabel('TV distance to uniform', fontsize=11)
ax.set_title('Z₂₀: TV distance decay', fontsize=12)
ax.legend(fontsize=9)
ax.set_yscale('log')
ax.set_ylim(1e-6, 1)
ax.grid(True, alpha=0.3)

# Plot 2: Different cyclic group sizes
ax = axes[0, 1]
for n in [10, 30, 50, 100]:
    A = cayley_adj_cyclic(n, [1, n-1])
    steps_n = min(n * 10, 2000)
    tvs = simulate_classical_walk(A, steps_n)
    gap = spectral_gap_from_adj(A)
    ax.plot(np.arange(steps_n) / (1/gap), tvs, linewidth=1.5,
            label=f'Z_{n}, γ={gap:.4f}')

ax.set_xlabel('Normalized time t·γ', fontsize=11)
ax.set_ylabel('TV distance to uniform', fontsize=11)
ax.set_title('Scaling collapse by spectral gap', fontsize=12)
ax.legend(fontsize=9)
ax.set_yscale('log')
ax.set_ylim(1e-4, 1)
ax.grid(True, alpha=0.3)

# Plot 3: Entropy production
ax = axes[1, 0]
for gamma in [0.05, 0.1, 0.3, 0.5]:
    ts = np.arange(100)
    deficit = (1 - gamma) ** ts
    ax.plot(ts, deficit, linewidth=2, label=f'γ={gamma}')

ax.axhline(y=0, color='black', linewidth=0.5)
ax.set_xlabel('Steps t', fontsize=11)
ax.set_ylabel('Entropy deficit (1-γ)^t', fontsize=11)
ax.set_title('Entropy deficit decay', fontsize=12)
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.set_ylim(1e-8, 1)
ax.grid(True, alpha=0.3)

# Plot 4: Quadratic speedup visualization
ax = axes[1, 1]
Ns = np.logspace(1, 6, 50)
gammas = [0.5, 0.1, 0.01]

for gamma in gammas:
    tau_cl = (1/gamma) * np.log(Ns)
    tau_q = (1/np.sqrt(gamma)) * np.sqrt(np.log(Ns))
    ratio = tau_q / tau_cl
    ax.semilogx(Ns, ratio, linewidth=2, label=f'γ={gamma}')

ax.set_xlabel('Group order N', fontsize=11)
ax.set_ylabel('τ_q / τ_cl (speedup ratio)', fontsize=11)
ax.set_title('Quantum speedup ratio → 0', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 1)

plt.suptitle('Classical Random Walk Mixing on Cayley Graphs', fontsize=14, y=1.01)
plt.tight_layout()
plt.savefig('mixing_curves.png', dpi=150, bbox_inches='tight')
print("Saved mixing_curves.png")
