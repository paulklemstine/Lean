"""
Visualization: Mixing Time Analysis for Symplectic Random Walks

Shows how the random walk on Cayley graphs of Sp_{2n}(F_q) converges
to the uniform distribution. The exponential decay rate is controlled
by the spectral gap, demonstrating rapid mixing for the canonical family.
"""

import numpy as np
import matplotlib.pyplot as plt
import math

def spectral_gap(n, q):
    return 1 - (n + 1) / q

def mixing_error(n, q, steps):
    """L² mixing error after `steps` steps"""
    gap = spectral_gap(n, q)
    if gap <= 0:
        return 1.0
    return (1 - gap) ** steps

def sp2n_log_order(n, q):
    """log₁₀ of |Sp_{2n}(F_q)|"""
    result = n**2 * math.log10(q)
    for i in range(1, n + 1):
        result += math.log10(q**(2*i) - 1)
    return result

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Mixing curves for Sp₆
ax1 = axes[0]
steps = np.arange(0, 200)
for q in [5, 7, 11, 17, 31]:
    errors = [mixing_error(3, q, s) for s in steps]
    ax1.semilogy(steps, errors, linewidth=2, label=f'q={q}')

ax1.axhline(y=0.01, color='gray', linestyle='--', alpha=0.5, label='ε = 0.01')
ax1.set_xlabel('Random walk steps', fontsize=12)
ax1.set_ylabel('L² mixing error', fontsize=12)
ax1.set_title('Sp₆(𝔽_q): Mixing Convergence', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(1e-10, 1.5)

# Plot 2: Mixing time vs rank (at threshold)
ax2 = axes[1]
ranks = range(1, 12)
for q_mult in [2, 3, 5, 10]:
    times = []
    for n in ranks:
        q = q_mult * (n + 1)
        gap = spectral_gap(n, q)
        if gap > 0:
            log_ord = 3 * n**2 * math.log(q)
            t = (log_ord + math.log(100)) / gap
            times.append(t)
        else:
            times.append(None)
    valid = [(r, t) for r, t in zip(ranks, times) if t is not None]
    if valid:
        rs, ts = zip(*valid)
        ax2.plot(rs, ts, '-o', linewidth=2, markersize=5,
                 label=f'q = {q_mult}(n+1)')

ax2.set_xlabel('Rank n', fontsize=12)
ax2.set_ylabel('Mixing time τ_mix(0.01)', fontsize=12)
ax2.set_title('Mixing Time vs Rank', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: Group order growth vs mixing time
ax3 = axes[2]
data_n, data_logG, data_tau = [], [], []
for n in range(1, 8):
    for q in [7, 11, 13, 17, 23, 29]:
        gap = spectral_gap(n, q)
        if gap > 0:
            logG = sp2n_log_order(n, q)
            tau = (3 * n**2 * math.log(q) + math.log(100)) / gap
            data_n.append(n)
            data_logG.append(logG)
            data_tau.append(tau)

scatter = ax3.scatter(data_logG, data_tau, c=data_n, cmap='viridis',
                      s=40, alpha=0.8, edgecolors='black', linewidth=0.5)
plt.colorbar(scatter, ax=ax3, label='Rank n')

# Reference line: τ ~ log|G|
x_ref = np.linspace(min(data_logG), max(data_logG), 100)
ax3.plot(x_ref, 5 * x_ref, 'r--', alpha=0.5, label='τ ~ 5·log|G|')

ax3.set_xlabel('log₁₀|Sp₂ₙ(𝔽_q)|', fontsize=12)
ax3.set_ylabel('Mixing time τ_mix', fontsize=12)
ax3.set_title('Mixing Time vs Group Size', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.suptitle('Random Walk Mixing on Symplectic Groups',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('mixing_time_analysis.png', dpi=150, bbox_inches='tight')
print("Saved mixing_time_analysis.png")
