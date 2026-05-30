"""
Visualization 2: Convergence of Generation Probability P_k → 1

Plots P_k(Z/nZ) as a function of k for several values of n,
showing the geometric convergence rate. The convergence is governed
by the largest prime factor: P_k ≈ 1 - Σ 1/p^k.

Key insight: Even for highly composite numbers, P_k converges to 1
exponentially fast — three random elements almost always generate.
"""

import numpy as np
import matplotlib.pyplot as plt


def jordan_totient(k, n):
    """Compute J_k(n) via Euler product."""
    result = n ** k
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            result = result * (d ** k - 1) // (d ** k)
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        result = result * (temp ** k - 1) // (temp ** k)
    return result


def generation_probability(n, k):
    return jordan_totient(k, n) / n ** k


# Groups to analyze
groups = {
    'Z/6Z (= Z/2Z × Z/3Z)': 6,
    'Z/30Z (= Z/2Z × Z/3Z × Z/5Z)': 30,
    'Z/210Z (2·3·5·7)': 210,
    'Z/2310Z (2·3·5·7·11)': 2310,
    'Z/12Z (2²·3)': 12,
    'Z/60Z (2²·3·5)': 60,
}

k_values = range(1, 16)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: P_k vs k
colors = plt.cm.Set1(np.linspace(0, 1, len(groups)))
for (label, n), color in zip(groups.items(), colors):
    probs = [generation_probability(n, k) for k in k_values]
    ax1.plot(k_values, probs, 'o-', color=color, label=label,
             markersize=4, linewidth=1.5)

ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
ax1.axhline(y=0.99, color='gray', linestyle=':', alpha=0.5)
ax1.set_xlabel('k (tuple size)', fontsize=12)
ax1.set_ylabel('P_k(Z/nZ)', fontsize=12)
ax1.set_title('Generation Probability vs Tuple Size', fontsize=13)
ax1.legend(fontsize=8, loc='lower right')
ax1.set_ylim(0, 1.05)
ax1.grid(True, alpha=0.3)

# Right: log(1 - P_k) vs k (showing exponential convergence)
for (label, n), color in zip(groups.items(), colors):
    gaps = []
    ks = []
    for k in k_values:
        p = generation_probability(n, k)
        if p < 1:
            gaps.append(np.log10(1 - p))
            ks.append(k)
    if gaps:
        ax2.plot(ks, gaps, 'o-', color=color, label=label,
                 markersize=4, linewidth=1.5)

ax2.set_xlabel('k (tuple size)', fontsize=12)
ax2.set_ylabel('log₁₀(1 - P_k)', fontsize=12)
ax2.set_title('Exponential Convergence Rate\n(linear = geometric convergence)',
              fontsize=13)
ax2.legend(fontsize=8, loc='upper right')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('convergence_plot.png', dpi=150, bbox_inches='tight')
print("Saved convergence_plot.png")
