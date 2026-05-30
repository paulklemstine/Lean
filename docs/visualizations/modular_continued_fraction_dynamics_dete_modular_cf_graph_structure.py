#!/usr/bin/env python3
"""
Visualization: Modular CF Graph Structure
==========================================

Visualizes the modular continued-fraction graph K_p(x, N) for different
quadratic irrationals and a transcendental number, showing how convergent
pairs distribute modulo a prime p. Quadratic irrationals produce structured,
periodic graphs while transcendentals fill the state space more densely.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def cf_state_mod(coeffs, n, p):
    """Compute CF states (p_curr, q_curr) mod p for first n terms."""
    if n == 0:
        return []
    p_prev, p_curr = 1, coeffs[0] % p
    q_prev, q_curr = 0, 1
    pairs = [(p_curr % p, q_curr % p)]
    for i in range(1, n):
        a = coeffs[i] % p
        p_new = (a * p_curr + p_prev) % p
        q_new = (a * q_curr + q_prev) % p
        pairs.append((p_new, q_new))
        p_prev, p_curr = p_curr, p_new
        q_prev, q_curr = q_curr, q_new
    return pairs


def make_coeffs(name, n):
    """Generate CF coefficients for named constants."""
    if name == "φ":
        return [1] * n
    elif name == "√2":
        return [1] + [2] * (n - 1)
    elif name == "√3":
        result = [1]
        for i in range(1, n):
            result.append(1 if i % 2 == 1 else 2)
        return result
    elif name == "e":
        result = [2]
        k = 1
        for i in range(1, n):
            if i % 3 == 2:
                result.append(2 * k)
                k += 1
            else:
                result.append(1)
        return result
    return [1] * n


fig, axes = plt.subplots(2, 2, figsize=(12, 12))
p = 11  # prime modulus
n_terms = 120

cases = [("φ (Golden Ratio)", "φ"), ("√2", "√2"), ("√3", "√3"), ("e (Euler's number)", "e")]
colors_list = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']

for idx, (title, name) in enumerate(cases):
    ax = axes[idx // 2][idx % 2]
    coeffs = make_coeffs(name, n_terms)
    pairs = cf_state_mod(coeffs, n_terms, p)

    # Plot all possible grid points in light gray
    for x in range(p):
        for y in range(p):
            ax.plot(x, y, '.', color='#E0E0E0', markersize=3, zorder=1)

    # Plot edges
    for i in range(len(pairs) - 1):
        x1, y1 = pairs[i]
        x2, y2 = pairs[i + 1]
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle='->', color=colors_list[idx],
                                   alpha=0.3, lw=0.8),
                    zorder=2)

    # Plot vertices with visit frequency
    from collections import Counter
    counts = Counter(pairs)
    unique_pairs = list(counts.keys())
    sizes = [min(200, 20 + 10 * counts[pair]) for pair in unique_pairs]

    xs = [pair[0] for pair in unique_pairs]
    ys = [pair[1] for pair in unique_pairs]
    ax.scatter(xs, ys, s=sizes, c=colors_list[idx], alpha=0.7,
              edgecolors='black', linewidths=0.5, zorder=3)

    # Mark start
    ax.plot(pairs[0][0], pairs[0][1], '*', color='red', markersize=12, zorder=4)

    ax.set_title(f'{title}\nmod {p}: {len(counts)} vertices, '
                f'{"periodic" if name != "e" else "non-periodic"}',
                fontsize=11, fontweight='bold')
    ax.set_xlabel('p_n mod p', fontsize=10)
    ax.set_ylabel('q_n mod p', fontsize=10)
    ax.set_xlim(-0.5, p - 0.5)
    ax.set_ylim(-0.5, p - 0.5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

fig.suptitle(f'Modular CF Graphs K_{{p}}(x, {n_terms}) for p = {p}\n'
             'Quadratic irrationals (top, bottom-left) vs transcendental (bottom-right)',
             fontsize=14, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.94])
plt.savefig('viz_modular_graph.png', dpi=150, bbox_inches='tight')
print("Saved viz_modular_graph.png")
