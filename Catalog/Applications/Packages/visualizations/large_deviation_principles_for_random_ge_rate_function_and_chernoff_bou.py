#!/usr/bin/env python3
"""
Visualization 2: Rate Function and Chernoff Bounds

Visualizes the Legendre–Fenchel transform (candidate rate function)
and Chernoff bound certificates, demonstrating:
- Rate function Λ*(α) = sup_t {tα - log Z(t)}
- Nonnegativity (Theorem: candidateRateFunction_nonneg)
- Chernoff bound comparison with Monte Carlo

This shows how the thermodynamic formalism produces exponential
tail bounds for generation failure probabilities.
"""

import numpy as np
import matplotlib.pyplot as plt
import math
import random

# ============================================================
# Inline functions
# ============================================================

def cyclic_indices(n):
    return [n // d for d in range(1, n) if n % d == 0]

def subgroup_pressure(indices, t):
    return sum(idx ** (-2 * t) for idx in indices if idx > 0)

def log_pressure(indices, t):
    Z = subgroup_pressure(indices, t)
    return math.log(Z) if Z > 0 else float('-inf')

def legendre_transform(indices, t_range, alpha):
    values = [t * alpha - log_pressure(indices, t) for t in t_range]
    return max(values)

def chernoff_bound(indices, alpha, t):
    return math.exp(-2 * t * alpha) * subgroup_pressure(indices, t)

def monte_carlo_tail_prob(n, m, alpha_frac, num_trials=20000):
    """Estimate P(defect/m >= alpha_frac) for (Z/nZ)^m."""
    threshold = int(alpha_frac * m)
    if threshold < 1:
        return 1.0
    count = 0
    for _ in range(num_trials):
        defect = 0
        for _ in range(m):
            x = random.randint(0, n - 1)
            y = random.randint(0, n - 1)
            if math.gcd(math.gcd(x, y), n) != 1:
                defect += 1
        if defect >= threshold:
            count += 1
    return count / num_trials

# ============================================================
# Plotting
# ============================================================

random.seed(42)
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

t_range = np.linspace(-1, 5, 500)

# Panel 1: Rate function for different groups
ax = axes[0, 0]
alpha_range = np.linspace(0, 4, 100)
for n, name, color in [(6, "Z/6Z", "#e74c3c"), (12, "Z/12Z", "#3498db"),
                         (30, "Z/30Z", "#2ecc71")]:
    indices = cyclic_indices(n)
    rates = [legendre_transform(indices, t_range, a) for a in alpha_range]
    ax.plot(alpha_range, rates, label=name, color=color, linewidth=2)
ax.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
ax.set_xlabel("α (defect parameter)", fontsize=12)
ax.set_ylabel("Λ*(α)", fontsize=12)
ax.set_title("Candidate Rate Function", fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 2: Chernoff bound optimization for Z/12Z
ax = axes[0, 1]
indices = cyclic_indices(12)
t_pos = np.linspace(0.01, 4, 200)
for alpha, color in [(0.5, "#e74c3c"), (1.0, "#3498db"), (2.0, "#2ecc71")]:
    bounds = [chernoff_bound(indices, alpha, t) for t in t_pos]
    ax.plot(t_pos, bounds, label=f"α = {alpha}", color=color, linewidth=2)
    opt_idx = np.argmin(bounds)
    ax.plot(t_pos[opt_idx], bounds[opt_idx], 'o', color=color, markersize=8)
ax.set_xlabel("t (optimization variable)", fontsize=12)
ax.set_ylabel("Chernoff bound exp(-2tα)·Z(t)", fontsize=12)
ax.set_title("Chernoff Bound Optimization (Z/12Z)", fontsize=13, fontweight='bold')
ax.set_yscale('log')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 3: Monte Carlo vs Chernoff for Z/6Z powers
ax = axes[1, 0]
n = 6
indices = cyclic_indices(n)
m_values = [2, 4, 6, 8, 10, 12, 15]
alpha_frac = 0.4

mc_probs = []
chernoff_bounds = []
for m in m_values:
    p = monte_carlo_tail_prob(n, m, alpha_frac, num_trials=20000)
    mc_probs.append(p if p > 0 else 1e-6)

    # Chernoff: optimize over t
    best_bound = float('inf')
    for t in np.linspace(0.1, 3, 100):
        # Bound for m independent copies
        b = chernoff_bound(indices, alpha_frac * math.log(max(indices)), t) ** m
        best_bound = min(best_bound, b)
    chernoff_bounds.append(min(best_bound, 1.0))

ax.semilogy(m_values, mc_probs, 'bo-', linewidth=2, markersize=6, label='Monte Carlo')
ax.set_xlabel("Number of copies m", fontsize=12)
ax.set_ylabel("P(defect/m ≥ α)", fontsize=12)
ax.set_title(f"Tail Probability Decay (Z/6Z)^m, α={alpha_frac}", fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 4: Linear decay of log P (Conjecture A test)
ax = axes[1, 1]
n = 6
m_values_dense = list(range(2, 21))
for alpha_frac, color, marker in [(0.3, "#e74c3c", 'o'), (0.4, "#3498db", 's'),
                                    (0.5, "#2ecc71", '^')]:
    log_probs = []
    m_valid = []
    for m in m_values_dense:
        p = monte_carlo_tail_prob(n, m, alpha_frac, num_trials=30000)
        if p > 0:
            log_probs.append(math.log(p))
            m_valid.append(m)
    if len(m_valid) > 1:
        ax.plot(m_valid, log_probs, f'{marker}-', color=color, linewidth=1.5,
                markersize=5, label=f'α = {alpha_frac}')
        # Linear fit
        coeffs = np.polyfit(m_valid, log_probs, 1)
        ax.plot(m_valid, np.polyval(coeffs, m_valid), '--', color=color, alpha=0.5)

ax.set_xlabel("Number of copies m", fontsize=12)
ax.set_ylabel("log P(defect/m ≥ α)", fontsize=12)
ax.set_title("Conjecture A: Linear Decay (Z/6Z)^m", fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.suptitle("Large Deviation Bounds: Rate Function & Chernoff Certificates",
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("rate_function.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved: rate_function.png")
