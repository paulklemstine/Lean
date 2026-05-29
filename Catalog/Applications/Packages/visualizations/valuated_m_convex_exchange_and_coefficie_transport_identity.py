#!/usr/bin/env python3
"""
Visualization: Coefficient Transport Identity Under Differentiation

Illustrates the fundamental identity:
    coeff_m(∂_i p) = (m_i + 1) * coeff_{m + e_i}(p)

Shows how coefficients flow through the differentiation map and how
the (m_i + 1) scaling factor creates the rescaling geometry that
governs valuated exchange transport.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import itertools

def weighted_uniform_poly(n, d, weights_dict):
    """Create weighted uniform matroid polynomial."""
    poly = {}
    for subset, w in weights_dict.items():
        exp = tuple(1 if i in subset else 0 for i in range(n))
        poly[exp] = w
    return poly

def partial_derivative(poly, var, n):
    """Compute partial derivative."""
    result = {}
    for exp, coeff in poly.items():
        if exp[var] > 0:
            new_exp = list(exp)
            new_exp[var] -= 1
            new_exp = tuple(new_exp)
            result[new_exp] = result.get(new_exp, 0.0) + coeff * exp[var]
    return {k: v for k, v in result.items() if abs(v) > 1e-15}

def exp_label(exp):
    parts = []
    for i, e in enumerate(exp):
        if e == 1:
            parts.append(f"x_{i}")
        elif e > 1:
            parts.append(f"x_{i}^{e}")
    return " ".join(parts) if parts else "1"

# U(3,5) polynomial for richer structure
n = 5
d = 3
weights = {}
w_vals = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
for idx, subset in enumerate(itertools.combinations(range(n), d)):
    weights[subset] = w_vals[idx % len(w_vals)]

poly = weighted_uniform_poly(n, d, weights)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Transport identity verification for variable 0
ax = axes[0, 0]
var = 0
dp = partial_derivative(poly, var, n)

x_pos = []
y_direct = []
y_transport = []
labels = []

for m_exp in sorted(dp.keys()):
    lifted = list(m_exp)
    lifted[var] += 1
    lifted = tuple(lifted)
    
    direct = dp.get(m_exp, 0)
    factor = m_exp[var] + 1
    original_coeff = poly.get(lifted, 0)
    transported = factor * original_coeff
    
    x_pos.append(len(labels))
    y_direct.append(direct)
    y_transport.append(transported)
    labels.append(exp_label(m_exp))

x = np.array(x_pos)
width = 0.35
bars1 = ax.bar(x - width/2, y_direct, width, label='Direct: coeff_m(∂₀p)', 
               color='#2196F3', edgecolor='navy', linewidth=1.5)
bars2 = ax.bar(x + width/2, y_transport, width, label='Transport: (m₀+1)·coeff_{m+e₀}(p)',
               color='#FF9800', edgecolor='darkorange', linewidth=1.5)
ax.set_xticks(x)
ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
ax.set_ylabel('Coefficient value', fontsize=10)
ax.set_title('Transport Identity: ∂/∂x₀', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(axis='y', alpha=0.3)

# Panel 2: Scaling factors (m_i + 1) histogram
ax = axes[0, 1]
scaling_factors = []
for var in range(n):
    dp = partial_derivative(poly, var, n)
    for m_exp in dp.keys():
        scaling_factors.append(m_exp[var] + 1)

ax.hist(scaling_factors, bins=range(1, max(scaling_factors) + 2), 
        color='#4CAF50', edgecolor='darkgreen', linewidth=1.5, align='left')
ax.set_xlabel('Scaling factor (m_i + 1)', fontsize=11)
ax.set_ylabel('Frequency', fontsize=11)
ax.set_title('Distribution of Transport\nScaling Factors', fontsize=12, fontweight='bold')
ax.grid(axis='y', alpha=0.3)

# Panel 3: Coefficient decay through derivative tower
ax = axes[1, 0]
tower_coeffs = []
current = poly
max_coeff_per_level = []
for level in range(d + 1):
    max_c = max(current.values()) if current else 0
    sum_c = sum(current.values()) if current else 0
    n_terms = len(current)
    tower_coeffs.append({'level': level, 'max': max_c, 'sum': sum_c, 'n_terms': n_terms})
    if level < d:
        current = partial_derivative(current, level % n, n)
        if not current:
            break

levels = [tc['level'] for tc in tower_coeffs]
maxes = [tc['max'] for tc in tower_coeffs]
sums = [tc['sum'] for tc in tower_coeffs]
n_terms_list = [tc['n_terms'] for tc in tower_coeffs]

ax.plot(levels, maxes, 'o-', color='#E91E63', linewidth=2, markersize=8, label='Max coeff')
ax.plot(levels, sums, 's-', color='#9C27B0', linewidth=2, markersize=8, label='Sum of coeffs')
ax.set_xlabel('Derivative level', fontsize=11)
ax.set_ylabel('Coefficient value', fontsize=11)
ax.set_title('Coefficient Evolution\nThrough Derivative Tower', fontsize=12, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(alpha=0.3)

# Panel 4: Support size through derivative tower
ax = axes[1, 1]
ax.bar(levels, n_terms_list, color='#00BCD4', edgecolor='teal', linewidth=1.5)
ax.set_xlabel('Derivative level', fontsize=11)
ax.set_ylabel('Number of support monomials', fontsize=11)
ax.set_title('Support Size\nThrough Derivative Tower', fontsize=12, fontweight='bold')
ax.grid(axis='y', alpha=0.3)

# Add text annotations
for i, (l, nt) in enumerate(zip(levels, n_terms_list)):
    ax.annotate(f'{nt}', (l, nt), textcoords="offset points", xytext=(0, 5),
                ha='center', fontsize=10, fontweight='bold')

plt.suptitle('Coefficient Transport Identity and Derivative Tower Analysis',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('transport_identity.png', dpi=150, bbox_inches='tight')
print("Saved transport_identity.png")
