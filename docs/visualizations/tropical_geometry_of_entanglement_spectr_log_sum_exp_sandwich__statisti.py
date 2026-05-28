"""
Visualization 3: Log-Sum-Exp Sandwich and Statistical Mechanics

Visualizes the cross-domain theorem connecting tropical geometry to
statistical mechanics. The log-sum-exp sandwich

    max(a_i) ≤ log Σ exp(a_i) ≤ max(a_i) + log n

shows that the free energy (log-sum-exp) is sandwiched between
the ground state energy (max) and ground state + entropy (max + log n).

As temperature → 0, the tropical (max) term dominates.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import log, exp


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Sandwich visualization for varying number of terms
ax = axes[0]
ns = list(range(2, 51))
max_vals = []
lse_vals = []
upper_vals = []

np.random.seed(42)
base_values = np.random.randn(50)

for n in ns:
    vals = base_values[:n]
    mx = np.max(vals)
    shifted = vals - mx
    lse = mx + log(np.sum(np.exp(shifted)))
    max_vals.append(mx)
    lse_vals.append(lse)
    upper_vals.append(mx + log(n))

ax.fill_between(ns, max_vals, upper_vals, alpha=0.15, color='blue',
                label='Sandwich region')
ax.plot(ns, max_vals, 'b-', linewidth=2, label=r'$\max_i a_i$')
ax.plot(ns, lse_vals, 'r-', linewidth=2, label=r'$\log \sum e^{a_i}$')
ax.plot(ns, upper_vals, 'g--', linewidth=2, label=r'$\max + \log n$')
ax.set_xlabel('Number of terms $n$', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Log-Sum-Exp Sandwich', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Temperature interpretation
ax = axes[1]
values = np.array([1.0, 2.5, 4.0, 3.0])
betas = np.linspace(0.1, 5.0, 50)  # inverse temperature

free_energies = []
ground_state = np.max(values)

for beta in betas:
    shifted = beta * values - beta * ground_state
    fe = ground_state + (1/beta) * log(np.sum(np.exp(shifted)))
    free_energies.append(fe)

ax.plot(betas, free_energies, 'r-', linewidth=2, label=r'$\frac{1}{\beta}\log \sum e^{\beta a_i}$')
ax.axhline(y=ground_state, color='blue', linestyle='--', linewidth=2,
           label=f'Ground state = {ground_state}')
ax.axhline(y=ground_state + log(len(values))/betas[0], color='gray',
           linestyle=':', alpha=0.5)

ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=12)
ax.set_ylabel('Free energy', fontsize=12)
ax.set_title('Tropical Limit as T → 0', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.annotate('Tropical\nlimit', xy=(4.5, ground_state + 0.05),
            fontsize=10, color='blue', ha='center')

# Panel 3: Block spectrum sandwich
ax = axes[2]
blocks = [(6.0, 4), (2.0, 3)]
spectrum = np.concatenate([np.full(m, w) for w, m in blocks])
N = len(spectrum)

# Compute exact e_k
def esp(weights):
    m = len(weights)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for i in range(m):
        for k in range(min(i + 1, m), 0, -1):
            e[k] += weights[i] * e[k - 1]
    return e

e = esp(spectrum)
profile = np.array([log(e[k]) if e[k] > 0 else float('-inf') for k in range(N + 1)])

# Envelope
la, lb = log(blocks[0][0]), log(blocks[1][0])
p = blocks[0][1]
envelope = np.array([la * min(k, p) + lb * max(k - p, 0) for k in range(N + 1)])

# Admissible count (entropy term)
def adm_count(p, q, k):
    r1_min = max(0, k - q)
    r1_max = min(k, p)
    return max(0, r1_max - r1_min + 1)

q = blocks[1][1]
entropy_correction = np.array([log(adm_count(p, q, k)) if adm_count(p, q, k) > 0 else 0
                                for k in range(N + 1)])

ks = np.arange(N + 1)
ax.plot(ks, profile, 'b-o', markersize=5, linewidth=2, label=r'$\log e_k$')
ax.plot(ks, envelope, 'r--s', markersize=5, linewidth=2, label='Envelope $F(k)$')
ax.plot(ks, envelope + entropy_correction, 'g-.^', markersize=5, linewidth=2,
        label='$F(k) + \\log |\\mathcal{C}_k|$')

ax.fill_between(ks, envelope, envelope + entropy_correction, alpha=0.1, color='green')
ax.set_xlabel('$k$', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Tropical Sandwich for Block Spectrum', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Statistical Mechanics of Tropical Entanglement',
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('log_sum_exp_sandwich.png', dpi=150, bbox_inches='tight')
print("Saved log_sum_exp_sandwich.png")
