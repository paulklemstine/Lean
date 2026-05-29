#!/usr/bin/env python3
"""
Visualization: Exchange Network for Weighted Matroid Polynomials

Visualizes the exchange graph structure: nodes are support monomials,
edges connect exchange pairs, and edge weights encode the coefficient
ratios. This reveals how the four-point exchange inequality creates
a geometric network on the coefficient space.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import itertools

def compute_exchange_ratios(poly, n):
    """Compute all exchange ratios between support elements."""
    support = [exp for exp, c in poly.items() if c > 0]
    edges = []
    
    for a in support:
        for b in support:
            if a >= b:  # avoid duplicates
                continue
            for i in range(n):
                if b[i] >= a[i]:
                    continue
                for j in range(n):
                    if a[j] >= b[j]:
                        continue
                    a_p = list(a); a_p[i] -= 1; a_p[j] += 1; a_p = tuple(a_p)
                    b_p = list(b); b_p[i] += 1; b_p[j] -= 1; b_p = tuple(b_p)
                    ca = poly.get(a, 0)
                    cb = poly.get(b, 0)
                    ca_p = poly.get(a_p, 0)
                    cb_p = poly.get(b_p, 0)
                    if ca_p > 0 and cb_p > 0:
                        ratio = (ca * cb) / (ca_p * cb_p)
                        edges.append({
                            'a': a, 'b': b, 'i': i, 'j': j,
                            'a_prime': a_p, 'b_prime': b_p,
                            'ratio': ratio
                        })
    return support, edges

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

def exp_to_label(exp):
    """Convert exponent tuple to monomial label."""
    parts = []
    for i, e in enumerate(exp):
        if e == 1:
            parts.append(f"x{i}")
        elif e > 1:
            parts.append(f"x{i}^{e}")
    return "·".join(parts) if parts else "1"

# Create the U(2,4) polynomial with specific weights
n = 4
weights = {
    (0,1): 3, (0,2): 5, (0,3): 2,
    (1,2): 4, (1,3): 7, (2,3): 6
}
poly = {}
for subset, w in weights.items():
    exp = tuple(1 if i in subset else 0 for i in range(n))
    poly[exp] = w

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Top row: Original polynomial and its exchange network
support, edges = compute_exchange_ratios(poly, n)

# Position nodes in a circle
angles = np.linspace(0, 2*np.pi, len(support), endpoint=False)
positions = {exp: (np.cos(a), np.sin(a)) for exp, a in zip(support, angles)}

# Draw exchange network for original polynomial
ax = axes[0, 0]
for exp, (x, y) in positions.items():
    coeff = poly[exp]
    size = 300 + 100 * coeff
    ax.scatter(x, y, s=size, c='steelblue', zorder=5, edgecolors='navy', linewidth=2)
    ax.annotate(f"{exp_to_label(exp)}\nc={coeff}", (x, y), 
                textcoords="offset points", xytext=(0, -25),
                ha='center', fontsize=8, fontweight='bold')

for edge in edges:
    a_pos = positions[edge['a']]
    b_pos = positions[edge['b']]
    ratio = edge['ratio']
    color = 'green' if ratio <= 1 else 'red'
    width = max(0.5, min(3, 2 / ratio))
    ax.plot([a_pos[0], b_pos[0]], [a_pos[1], b_pos[1]], 
            color=color, linewidth=width, alpha=0.6, zorder=1)
    mid = ((a_pos[0]+b_pos[0])/2, (a_pos[1]+b_pos[1])/2)
    ax.annotate(f"{ratio:.2f}", mid, fontsize=7, ha='center',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8))

ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.set_title('Original p: Exchange Network\n(green=K≤1, red=K>1)', fontsize=11, fontweight='bold')
ax.axis('off')

# Top row: Derivatives
for var_idx, ax_idx in enumerate(range(3)):
    if var_idx >= 3:
        break
    ax = axes[0, var_idx] if var_idx == 0 else axes[0, var_idx]
    if var_idx == 0:
        continue  # already drawn
    
    dp = partial_derivative(poly, var_idx - 1, n)
    if not dp:
        continue
    
    dp_support, dp_edges = compute_exchange_ratios(dp, n)
    
    dp_angles = np.linspace(0, 2*np.pi, len(dp_support), endpoint=False)
    dp_positions = {exp: (np.cos(a), np.sin(a)) for exp, a in zip(dp_support, dp_angles)}
    
    for exp, (x, y) in dp_positions.items():
        coeff = dp[exp]
        size = 300 + 50 * abs(coeff)
        ax.scatter(x, y, s=size, c='coral', zorder=5, edgecolors='darkred', linewidth=2)
        ax.annotate(f"{exp_to_label(exp)}\nc={coeff:.0f}", (x, y),
                    textcoords="offset points", xytext=(0, -25),
                    ha='center', fontsize=8, fontweight='bold')
    
    for edge in dp_edges:
        if edge['a'] in dp_positions and edge['b'] in dp_positions:
            a_pos = dp_positions[edge['a']]
            b_pos = dp_positions[edge['b']]
            ratio = edge['ratio']
            color = 'green' if ratio <= 1 else 'red'
            ax.plot([a_pos[0], b_pos[0]], [a_pos[1], b_pos[1]],
                    color=color, linewidth=2, alpha=0.6, zorder=1)
    
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title(f'∂/∂x{var_idx-1} p: Exchange Network', fontsize=11, fontweight='bold')
    ax.axis('off')

# Bottom row: Coefficient bar chart comparison
for var_idx in range(3):
    ax = axes[1, var_idx]
    dp = partial_derivative(poly, var_idx, n)
    
    exps = sorted(dp.keys())
    coeffs = [dp[e] for e in exps]
    labels = [exp_to_label(e) for e in exps]
    
    colors = ['#2196F3' if c > 0 else '#F44336' for c in coeffs]
    bars = ax.bar(range(len(exps)), coeffs, color=colors, edgecolor='navy', linewidth=1.5)
    ax.set_xticks(range(len(exps)))
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=9)
    ax.set_ylabel('Coefficient', fontsize=10)
    ax.set_title(f'∂/∂x{var_idx} p: Coefficients', fontsize=11, fontweight='bold')
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.grid(axis='y', alpha=0.3)

plt.suptitle('Valuated Exchange Network: U(2,4) with Weights [3,5,2,4,7,6]',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('exchange_network.png', dpi=150, bbox_inches='tight')
print("Saved exchange_network.png")
