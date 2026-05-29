#!/usr/bin/env python3
"""
Visualization: Falling Factorial Scalars

Visualizes the falling factorial multi-index product that governs
coefficient transformation under iterated differentiation.

Shows that this scalar is ALWAYS positive — the key fact that makes
cancellation impossible over characteristic zero.
"""

import matplotlib.pyplot as plt
import numpy as np

def desc_factorial(n, k):
    r = 1
    for i in range(k): r *= (n - i)
    return r

def falling_factorial_multi_2d(beta, gamma):
    """For 2D multi-indices."""
    result = 1
    for b, g in zip(beta, gamma):
        result *= desc_factorial(b + g, g)
    return result

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Show scalar values for different gamma directions
gammas = [(1, 0), (0, 1), (1, 1), (2, 0), (0, 2), (2, 1)]
titles = ['∂/∂x₁', '∂/∂x₂', '∂²/∂x₁∂x₂', '∂²/∂x₁²', '∂²/∂x₂²', '∂³/∂x₁²∂x₂']

for idx, (gamma, title) in enumerate(zip(gammas, titles)):
    ax = axes[idx // 3][idx % 3]

    max_b = 6
    data = np.zeros((max_b, max_b))
    for b1 in range(max_b):
        for b2 in range(max_b):
            beta = (b1, b2)
            data[b2, b1] = falling_factorial_multi_2d(beta, gamma)

    im = ax.imshow(data, cmap='YlGnBu', origin='lower',
                    interpolation='nearest', vmin=0)
    ax.set_xlabel('β₁', fontsize=11)
    ax.set_ylabel('β₂', fontsize=11)
    ax.set_title(f'{title}\nγ = {gamma}', fontsize=12)

    # Annotate cells with values
    for b1 in range(max_b):
        for b2 in range(max_b):
            val = int(data[b2, b1])
            if val > 0:
                color = 'white' if val > data.max() * 0.6 else 'black'
                ax.text(b1, b2, str(val), ha='center', va='center',
                       fontsize=7, color=color)

    plt.colorbar(im, ax=ax, shrink=0.8)

plt.suptitle('Falling Factorial Scalars: F(β, γ) = ∏ᵢ (βᵢ+γᵢ)!/βᵢ!\n'
             'Always positive → no cancellation possible over ℚ',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_falling_factorial.png', dpi=150, bbox_inches='tight')
print("Saved viz_falling_factorial.png")
