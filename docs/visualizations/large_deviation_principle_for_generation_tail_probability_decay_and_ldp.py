#!/usr/bin/env python3
"""
Visualization 2: Tail Probability Decay and LDP Convergence

Shows the exponential decay of tail probabilities P(D_N >= α) as N grows,
demonstrating the large deviation principle. The slope of log P vs N 
converges to -I(α), confirming the Legendre-transform prediction.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import log, exp, comb


def rate_exact(q, alpha):
    """Binary KL divergence I(α) = D(Ber(α) ‖ Ber(q))."""
    if alpha <= 1e-12:
        return -log(1 - q)
    if alpha >= 1 - 1e-12:
        return -log(q)
    return alpha * log(alpha / q) + (1 - alpha) * log((1 - alpha) / (1 - q))


def exact_tail_prob(q, N, alpha):
    """Compute P(D_N >= α) = P(Binomial(N,q)/N >= α) exactly."""
    k_threshold = int(np.ceil(alpha * N - 1e-10))
    k_threshold = max(0, min(N, k_threshold))
    
    prob = 0.0
    for k in range(k_threshold, N + 1):
        prob += comb(N, k) * (q ** k) * ((1 - q) ** (N - k))
    return prob


fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

q = 1/3  # Z/6Z

# --- Left panel: Tail probability decay ---
ax = axes[0]
Ns = list(range(1, 81))

for alpha, color, marker in [(0.5, '#E91E63', 's'), 
                              (0.6, '#FF9800', '^'),
                              (0.7, '#2196F3', 'o'),
                              (0.8, '#4CAF50', 'D')]:
    log_probs = []
    for N in Ns:
        p = exact_tail_prob(q, N, alpha)
        log_probs.append(log(p) if p > 0 else None)
    
    valid = [(N, lp) for N, lp in zip(Ns, log_probs) if lp is not None]
    if valid:
        ns_valid, lps_valid = zip(*valid)
        ax.plot(ns_valid, lps_valid, color=color, marker=marker, 
                markersize=3, linewidth=1.5, label=f'α = {alpha}')
        
        # Theoretical slope
        I_val = rate_exact(q, alpha)
        ax.plot(ns_valid, [-I_val * n for n in ns_valid], '--', 
                color=color, linewidth=1, alpha=0.6)

ax.set_xlabel('N (number of coordinates)', fontsize=13)
ax.set_ylabel('log P(D_N ≥ α)', fontsize=13)
ax.set_title('Tail Probability Decay (Z/6Z, q=1/3)', fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Add annotation
ax.text(50, -8, 'Dashed: slope = -I(α)\n(LDP prediction)', 
        fontsize=10, style='italic', color='gray',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# --- Right panel: Rate convergence ---
ax = axes[1]
Ns_rate = list(range(5, 201, 5))

for alpha, color, marker in [(0.5, '#E91E63', 's'),
                              (0.6, '#FF9800', '^'),
                              (0.7, '#2196F3', 'o')]:
    empirical_rates = []
    for N in Ns_rate:
        p = exact_tail_prob(q, N, alpha)
        if p > 0:
            empirical_rates.append(-log(p) / N)
        else:
            empirical_rates.append(None)
    
    valid = [(N, r) for N, r in zip(Ns_rate, empirical_rates) if r is not None]
    if valid:
        ns_v, rs_v = zip(*valid)
        ax.plot(ns_v, rs_v, color=color, marker=marker, markersize=3,
                linewidth=1.2, label=f'α = {alpha}')
    
    # Theoretical rate
    I_val = rate_exact(q, alpha)
    ax.axhline(y=I_val, color=color, linestyle='--', linewidth=1, alpha=0.6)

ax.set_xlabel('N', fontsize=13)
ax.set_ylabel('-(1/N) log P(D_N ≥ α)', fontsize=13)
ax.set_title('Convergence to Rate Function I(α)', fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.text(120, 0.15, 'Dashed lines:\nexact I(α)', fontsize=10, 
        style='italic', color='gray',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_tail_decay.png', dpi=150, bbox_inches='tight')
print("Saved viz_tail_decay.png")
