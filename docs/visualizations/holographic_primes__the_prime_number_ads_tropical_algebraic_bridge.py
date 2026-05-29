#!/usr/bin/env python3
"""
Visualization 2: Tropical-Algebraic Bridge

Visualizes the tropical prime bound:
  exp(∑ p⁻ᵝ) ≤ ∏(1 - p⁻ᵝ)⁻¹ = ζ(β)

Shows how the "tropicalized" (additive/logarithmic) partition function
underestimates the true (multiplicative) partition function, and how
the gap between them encodes higher-order prime correlations.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def sieve_of_eratosthenes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


primes = sieve_of_eratosthenes(50000)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Tropical-Algebraic Bridge: Additive vs Multiplicative Structure",
             fontsize=16, fontweight='bold')

# Plot 1: exp(∑ p⁻ᵝ) vs ζ(β) as function of β
ax1 = axes[0, 0]
betas = np.linspace(1.05, 6.0, 200)
tropical_vals = []
euler_vals = []

for beta in betas:
    prime_sum = sum(p ** (-beta) for p in primes)
    tropical_vals.append(math.exp(prime_sum))
    log_euler = sum(-math.log(1 - p**(-beta)) for p in primes)
    euler_vals.append(math.exp(log_euler))

ax1.plot(betas, euler_vals, 'b-', linewidth=2, label='ζ(β) = ∏(1-p⁻ᵝ)⁻¹')
ax1.plot(betas, tropical_vals, 'r--', linewidth=2, label='exp(∑ p⁻ᵝ)')
ax1.fill_between(betas, tropical_vals, euler_vals, alpha=0.15, color='purple',
                 label='Gap (higher correlations)')
ax1.set_xlabel('β (inverse temperature)', fontsize=11)
ax1.set_ylabel('Partition function', fontsize=11)
ax1.set_title('Tropical underestimates Algebraic', fontsize=12)
ax1.set_ylim(0, 15)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: The ratio ζ(β) / exp(∑ p⁻ᵝ) = exp(∑_{k≥2} P(kβ)/k)
ax2 = axes[0, 1]
ratios = [e / t for e, t in zip(euler_vals, tropical_vals)]
ax2.plot(betas, ratios, 'purple', linewidth=2)
ax2.axhline(y=1, color='gray', linestyle=':', linewidth=1)
ax2.set_xlabel('β', fontsize=11)
ax2.set_ylabel('ζ(β) / exp(∑ p⁻ᵝ)', fontsize=11)
ax2.set_title('Ratio: higher-order prime correlations', fontsize=12)
ax2.grid(True, alpha=0.3)
ax2.annotate('β → 1⁺: ratio grows\n(stronger correlations)',
            xy=(1.2, ratios[5]), fontsize=9,
            xytext=(2.5, ratios[5] + 0.1),
            arrowprops=dict(arrowstyle='->', color='purple'))

# Plot 3: The key inequality exp(x) ≤ 1/(1-x) for individual primes
ax3 = axes[1, 0]
x_vals = np.linspace(0, 0.95, 200)
exp_vals = np.exp(x_vals)
inv_vals = 1.0 / (1.0 - x_vals)

ax3.plot(x_vals, exp_vals, 'r-', linewidth=2, label='exp(x)')
ax3.plot(x_vals, inv_vals, 'b-', linewidth=2, label='(1-x)⁻¹')
ax3.fill_between(x_vals, exp_vals, inv_vals, alpha=0.15, color='green',
                 label='Gap = tropical deficit')

# Mark prime values for β=2
for p in [2, 3, 5, 7, 11]:
    x = p ** (-2)
    ax3.plot(x, math.exp(x), 'ro', markersize=8)
    ax3.plot(x, 1/(1-x), 'bs', markersize=8)
    ax3.annotate(f'p={p}', xy=(x, 1/(1-x)), fontsize=8,
                xytext=(x+0.02, 1/(1-x)+0.1))

ax3.set_xlabel('x = p⁻ᵝ', fontsize=11)
ax3.set_ylabel('Value', fontsize=11)
ax3.set_title('Fundamental inequality (β=2 marked)', fontsize=12)
ax3.legend(fontsize=10)
ax3.set_xlim(-0.02, 0.5)
ax3.set_ylim(0.9, 2.2)
ax3.grid(True, alpha=0.3)

# Plot 4: Cumulative log contributions
ax4 = axes[1, 1]
N_vals = list(range(2, 200))
cum_tropical = []
cum_euler = []

for N in N_vals:
    ps = [p for p in primes if p <= N]
    if not ps:
        cum_tropical.append(0)
        cum_euler.append(0)
        continue
    cum_tropical.append(sum(p**(-2) for p in ps))
    cum_euler.append(sum(-math.log(1 - p**(-2)) for p in ps))

ax4.plot(N_vals, cum_euler, 'b-', linewidth=2,
         label='∑ -log(1-p⁻²) (Euler)')
ax4.plot(N_vals, cum_tropical, 'r--', linewidth=2,
         label='∑ p⁻² (Tropical)')
ax4.fill_between(N_vals, cum_tropical, cum_euler, alpha=0.15, color='orange')
ax4.set_xlabel('N (boundary cutoff)', fontsize=11)
ax4.set_ylabel('Cumulative log-contribution', fontsize=11)
ax4.set_title('Cumulative: Euler vs Tropical (β=2)', fontsize=12)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tropical_algebraic_bridge.png', dpi=150, bbox_inches='tight')
print("Saved: tropical_algebraic_bridge.png")
