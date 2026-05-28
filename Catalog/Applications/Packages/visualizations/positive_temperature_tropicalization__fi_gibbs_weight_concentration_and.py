#!/usr/bin/env python3
"""
Visualization: Gibbs Weight Concentration and Phase Transitions

This script visualizes how Gibbs/Boltzmann weights concentrate on the
maximizer as inverse temperature β increases. This is the statistical
mechanics interpretation: at low temperature, the system freezes into
its ground state. At high temperature, all states are equally likely.

The visualization shows both the weight evolution and the entropy decay,
connecting tropical geometry to statistical mechanics.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def gibbs_weights(beta, a):
    s = beta * a
    s = s - np.max(s)
    w = np.exp(s)
    return w / np.sum(w)

def log_sum_exp(beta, a):
    scaled = beta * a
    m = np.max(scaled)
    return (1.0 / beta) * (m + np.log(np.sum(np.exp(scaled - m))))

# Data
a = np.array([1.0, 2.5, 2.3, 0.5, 1.8])
labels = [f'a[{i}]={a[i]}' for i in range(len(a))]
betas = np.logspace(-1, 2, 200)

# Compute weights and entropy
weights = np.array([gibbs_weights(b, a) for b in betas])
entropies = []
lse_values = []
for b in betas:
    p = gibbs_weights(b, a)
    H = -np.sum(p[p > 1e-300] * np.log(p[p > 1e-300]))
    entropies.append(H)
    lse_values.append(log_sum_exp(b, a))

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top-left: Gibbs weights vs β
ax = axes[0, 0]
colors = plt.cm.tab10(np.linspace(0, 1, len(a)))
for i in range(len(a)):
    ax.plot(betas, weights[:, i], linewidth=2, color=colors[i], label=labels[i])
ax.set_xlabel('β (inverse temperature)', fontsize=12)
ax.set_ylabel('Gibbs weight', fontsize=12)
ax.set_title('Gibbs Weights: Concentration → Ground State', fontsize=14)
ax.set_xscale('log')
ax.legend(fontsize=10, loc='center right')
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 1.05)

# Top-right: Entropy vs β
ax = axes[0, 1]
ax.plot(betas, entropies, 'purple', linewidth=2.5)
ax.axhline(y=np.log(len(a)), color='gray', linestyle=':', label=f'Max entropy = log({len(a)}) = {np.log(len(a)):.2f}')
ax.axhline(y=0, color='gray', linestyle=':')
ax.set_xlabel('β (inverse temperature)', fontsize=12)
ax.set_ylabel('Shannon entropy H(p)', fontsize=12)
ax.set_title('Entropy Decay: Disorder → Order', fontsize=14)
ax.set_xscale('log')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom-left: Free energy decomposition
ax = axes[1, 0]
energies = [np.sum(gibbs_weights(b, a) * a) for b in betas]
entropy_terms = [e / b for e, b in zip(entropies, betas)]
ax.plot(betas, lse_values, 'b-', linewidth=2.5, label='LSE (free energy)')
ax.plot(betas, energies, 'r--', linewidth=2, label='⟨a⟩ (Gibbs energy)')
ax.plot(betas, entropy_terms, 'g:', linewidth=2, label='H/β (entropy term)')
ax.axhline(y=np.max(a), color='k', linestyle='-.', alpha=0.5, label=f'max(a) = {np.max(a)}')
ax.set_xlabel('β (inverse temperature)', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Free Energy = Energy + Entropy/β', fontsize=14)
ax.set_xscale('log')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom-right: Phase transition in a 2-state system
ax = axes[1, 1]
ts = np.linspace(-2, 2, 300)
for beta in [0.5, 1, 2, 5, 20]:
    vals = []
    for t in ts:
        a2 = np.array([0.0, t])
        vals.append(log_sum_exp(beta, a2))
    ax.plot(ts, vals, linewidth=2, label=f'β={beta}')
ax.plot(ts, np.maximum(0, ts), 'k--', linewidth=2.5, label='max(0, t) [β=∞]')
ax.set_xlabel('t', fontsize=12)
ax.set_ylabel('LSE_β(0, t)', fontsize=12)
ax.set_title('Two-State Phase Transition: Thermal Rounding', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_gibbs_concentration.png', dpi=150, bbox_inches='tight')
print("Saved viz_gibbs_concentration.png")
