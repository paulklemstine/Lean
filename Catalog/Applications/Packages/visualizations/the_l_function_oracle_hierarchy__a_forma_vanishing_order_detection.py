#!/usr/bin/env python3
"""
Visualization 2: Vanishing Order Detection

Shows how the derivative oracle uniquely determines the vanishing order
of a function at a point. Displays derivative values for functions with
different vanishing orders, illustrating the "first nonzero derivative"
detection algorithm.
"""

import matplotlib.pyplot as plt
import numpy as np
import math

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Test functions with different vanishing orders at z = 0
test_cases = [
    (r'$f(z) = e^z - 1$', lambda z: np.exp(z) - 1, 1,
     'Order 1: f(0)=0, f\'(0)=1'),
    (r'$f(z) = 1 - \cos(z)$', lambda z: 1 - np.cos(z), 2,
     'Order 2: f(0)=f\'(0)=0, f\'\'(0)=1'),
    (r'$f(z) = z - \sin(z)$', lambda z: z - np.sin(z), 3,
     'Order 3: f=f\'=f\'\'=0, f\'\'\'(0)=1'),
    (r'$f(z) = z^4$', lambda z: z**4, 4,
     'Order 4: first 4 derivs vanish'),
]


def compute_nth_deriv(f, z0, n, r=0.01, N=128):
    """Compute n-th derivative using contour integral."""
    total = 0.0 + 0j
    for k in range(N):
        theta = 2 * np.pi * k / N
        z = z0 + r * np.exp(1j * theta)
        total += f(z) * np.exp(-1j * n * theta)
    return (math.factorial(n) * total / (N * r**n)).real


for idx, (name, f, order, desc) in enumerate(test_cases):
    ax = axes[idx // 2][idx % 2]

    max_n = 8
    derivs = []
    for n in range(max_n):
        d = compute_nth_deriv(f, 0.0, n)
        derivs.append(d)

    # Normalize by n! for display
    normalized = [d / math.factorial(n) if abs(d) > 1e-10 else 0
                  for n, d in enumerate(derivs)]

    colors = ['red' if abs(d) < 1e-6 else 'green' for d in derivs]
    # Highlight the first nonzero
    first_nonzero_idx = next((i for i, d in enumerate(derivs) if abs(d) > 1e-6), None)
    if first_nonzero_idx is not None:
        colors[first_nonzero_idx] = '#FFD700'

    bars = ax.bar(range(max_n), [abs(d) for d in derivs], color=colors,
                  edgecolor='black', linewidth=0.5, alpha=0.8)

    # Add value labels
    for i, d in enumerate(derivs):
        if abs(d) > 1e-6:
            ax.text(i, abs(d) + max(abs(d) for d in derivs) * 0.05,
                    f'{d:.1f}', ha='center', va='bottom', fontsize=8)

    ax.set_xlabel('Derivative order n', fontsize=11)
    ax.set_ylabel(r'$|f^{(n)}(0)|$', fontsize=11)
    ax.set_title(f'{name}\n{desc}', fontsize=11)
    ax.set_xticks(range(max_n))

    # Mark the vanishing order
    if first_nonzero_idx is not None:
        ax.annotate(f'Vanishing\norder = {first_nonzero_idx}',
                   xy=(first_nonzero_idx, abs(derivs[first_nonzero_idx])),
                   xytext=(first_nonzero_idx + 1.5,
                          abs(derivs[first_nonzero_idx]) * 0.8),
                   arrowprops=dict(arrowstyle='->', color='blue', lw=2),
                   fontsize=10, fontweight='bold', color='blue')

    ax.grid(True, alpha=0.3, axis='y')

    # Legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='red', edgecolor='black', label='Zero derivative'),
        Patch(facecolor='#FFD700', edgecolor='black', label='First nonzero (= order)'),
        Patch(facecolor='green', edgecolor='black', label='Nonzero derivative'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=7)

fig.suptitle('Vanishing Order Detection via Derivative Oracle',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_vanishing_order.png', dpi=150, bbox_inches='tight')
print("Saved viz_vanishing_order.png")
