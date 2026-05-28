#!/usr/bin/env python3
"""
Visualization 2: KL Divergence Decomposition under Reweighting

Visualizes the fundamental identity:
    D_KL(q || p) = Σ qᵢ log wᵢ - log S

Shows how the KL divergence of a reweighted distribution decomposes
into a weighted log-sum minus the log-normalizer, and how this
relates to Jensen's inequality for log.

Self-contained — all functions are inlined.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import log


def kl_divergence(p: np.ndarray, q: np.ndarray) -> float:
    mask = p > 0
    return np.sum(p[mask] * np.log(p[mask] / q[mask]))


# ─────────────────────────────────────────────────────────────
# Create visualization
# ─────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: KL divergence identity verification
ax1 = axes[0]
np.random.seed(42)
n_tests = 200
kl_direct = []
kl_formula = []

for _ in range(n_tests):
    n = np.random.randint(3, 10)
    p = np.random.dirichlet(np.ones(n))
    w = np.random.exponential(2.0, n) + 0.01
    S = np.sum(w * p)
    q = w * p / S
    
    kl_d = kl_divergence(q, p)
    kl_f = np.sum(q * np.log(w)) - log(S)
    kl_direct.append(kl_d)
    kl_formula.append(kl_f)

ax1.scatter(kl_direct, kl_formula, alpha=0.5, s=20, c='steelblue')
lim = max(max(kl_direct), max(kl_formula)) * 1.1
ax1.plot([0, lim], [0, lim], 'r--', linewidth=1.5, label='y = x')
ax1.set_xlabel('$D_{KL}(q \\| p)$ (direct)', fontsize=11)
ax1.set_ylabel('$\\sum q_i \\log w_i - \\log S$', fontsize=11)
ax1.set_title('KL Decomposition Identity', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_aspect('equal')

# Panel 2: Weighted Jensen inequality
ax2 = axes[1]
np.random.seed(123)
n = 5
p_fixed = np.random.dirichlet(np.ones(n))

# Vary the weight magnitude
scale_range = np.linspace(0.1, 5.0, 50)
jensen_gaps = []
kl_values = []

for scale in scale_range:
    w = np.ones(n) + scale * np.random.exponential(1.0, n)
    S = np.sum(w * p_fixed)
    q = w * p_fixed / S
    
    weighted_log = np.sum(q * np.log(w))
    log_S = log(S)
    
    jensen_gaps.append(weighted_log - log_S)
    kl_values.append(kl_divergence(q, p_fixed))

ax2.fill_between(scale_range, 0, jensen_gaps, alpha=0.3, color='green',
                 label='$\\sum q_i \\log w_i - \\log S \\geq 0$')
ax2.plot(scale_range, jensen_gaps, 'g-', linewidth=2)
ax2.axhline(y=0, color='red', linestyle='--', linewidth=1)
ax2.set_xlabel('Weight scale', fontsize=11)
ax2.set_ylabel('Jensen gap', fontsize=11)
ax2.set_title('Weighted Jensen Inequality', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Entropy change under reweighting
ax3 = axes[2]
np.random.seed(456)

# For various weight distributions, show H(q) vs H(p)
n = 6
p_fixed = np.random.dirichlet(3 * np.ones(n))
H_p = -np.sum(p_fixed * np.log(p_fixed))

weight_spreads = np.linspace(0.01, 3.0, 100)
H_q_values = []
cross_entropy_values = []

for spread in weight_spreads:
    w = np.exp(spread * np.linspace(-1, 1, n))
    S = np.sum(w * p_fixed)
    q = w * p_fixed / S
    
    mask = q > 0
    H_q = -np.sum(q[mask] * np.log(q[mask]))
    H_cross = -np.sum(q * np.log(p_fixed))
    
    H_q_values.append(H_q)
    cross_entropy_values.append(H_cross)

ax3.plot(weight_spreads, H_q_values, 'b-', linewidth=2, label='$H(q)$ (entropy)')
ax3.plot(weight_spreads, cross_entropy_values, 'r-', linewidth=2, 
         label='$H_\\times(q, p)$ (cross-entropy)')
ax3.axhline(y=H_p, color='green', linestyle='--', linewidth=1.5, 
            label=f'$H(p) = {H_p:.3f}$')
ax3.fill_between(weight_spreads, H_q_values, cross_entropy_values, 
                 alpha=0.2, color='orange', label='$D_{KL}(q \\| p)$ gap')
ax3.set_xlabel('Weight spread', fontsize=11)
ax3.set_ylabel('Entropy / Cross-entropy (nats)', fontsize=11)
ax3.set_title('Entropy vs Cross-Entropy under Reweighting', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.suptitle('KL Divergence Decomposition: The Engine of Entropy Monotonicity',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('kl_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved kl_decomposition.png")
