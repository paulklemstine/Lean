#!/usr/bin/env python3
"""
Visualization: Lorentz Form Invariance and the Berggren Light Cone

Shows how the Berggren matrices preserve the Lorentz form Q(a,b,c) = a² + b² - c².
Pythagorean triples lie on the "light cone" Q = 0. The Berggren matrices
act as isometries of this quadratic form, mapping the cone to itself.

This visualizes the deep geometric reason why compositional synthesis works:
the Berggren matrices belong to the integer Lorentz group O(2,1;ℤ).
"""

import matplotlib.pyplot as plt
import numpy as np
from math import gcd

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Lorentz Form Invariance: Why Berggren Synthesis Works',
             fontsize=16, fontweight='bold')

# --- Panel 1: The Light Cone ---
ax = axes[0]

# Draw the cone a² + b² = c² in the (a, c) plane (fixing b)
a_range = np.linspace(0, 50, 200)
for b_val, color, alpha in [(0, '#e74c3c', 0.8), (10, '#3498db', 0.6), 
                              (20, '#2ecc71', 0.4), (30, '#f39c12', 0.3)]:
    c_vals = np.sqrt(a_range**2 + b_val**2)
    ax.plot(a_range, c_vals, '-', color=color, alpha=alpha, linewidth=2,
            label=f'b = {b_val}')

# Plot primitive Pythagorean triples
for m in range(2, 12):
    for n in range(1, m):
        if gcd(m, n) == 1 and (m - n) % 2 == 1:
            a = m**2 - n**2
            b = 2 * m * n
            c = m**2 + n**2
            if c <= 60:
                ax.scatter([a], [c], c='black', s=40, zorder=5, alpha=0.8)
                if c <= 30:
                    ax.annotate(f'({a},{b},{c})', (a, c), fontsize=7,
                               xytext=(3, 3), textcoords='offset points')

ax.set_xlabel('First leg a', fontsize=12)
ax.set_ylabel('Hypotenuse c', fontsize=12)
ax.set_title('The Pythagorean Light Cone\na² + b² = c²', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 50)
ax.set_ylim(0, 60)

# --- Panel 2: Lorentz form values along Berggren paths ---
ax = axes[1]

BERGGREN = [
    np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]]),
    np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]]),
    np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]),
]
NAMES = ['A', 'B', 'C']
COLORS = ['#e74c3c', '#3498db', '#2ecc71']

root = np.array([3, 4, 5])

# Generate paths and compute Q values
max_depth = 6
all_q_values = []
all_depths = []
all_colors = []

def explore(v, depth, first_step):
    q = int(v[0]**2 + v[1]**2 - v[2]**2)
    all_q_values.append(q)
    all_depths.append(depth + np.random.uniform(-0.1, 0.1))
    all_colors.append(COLORS[first_step] if first_step >= 0 else '#f39c12')
    
    if depth < max_depth:
        for i in range(3):
            child = BERGGREN[i] @ v
            explore(child, depth + 1, i if first_step < 0 else first_step)

explore(root, 0, -1)

ax.scatter(all_depths, all_q_values, c=all_colors, s=15, alpha=0.7)
ax.axhline(y=0, color='red', linewidth=2, linestyle='--', alpha=0.8,
           label='Q = 0 (Pythagorean)')

# Add legend for branches
for i in range(3):
    ax.scatter([], [], c=COLORS[i], s=50, label=f'Branch {NAMES[i]}')
ax.scatter([], [], c='#f39c12', s=50, label='Root')

ax.set_xlabel('Depth in Berggren Tree', fontsize=12)
ax.set_ylabel('Lorentz Form Q = a² + b² - c²', fontsize=12)
ax.set_title('Lorentz Form is Invariant\nQ = 0 at Every Node', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(-2, 2)

# --- Panel 3: Hypotenuse growth along paths ---
ax = axes[2]

# Follow specific long paths and track hypotenuse
paths_to_follow = {
    'AAA...': 0,
    'BBB...': 1,
    'CCC...': 2,
    'ABC...': None  # alternating
}

max_path_depth = 10
for label, fixed_idx in paths_to_follow.items():
    v = root.copy().astype(np.float64)
    hyps = [float(v[2])]
    for d in range(max_path_depth):
        if fixed_idx is not None:
            idx = fixed_idx
        else:
            idx = d % 3
        v = BERGGREN[idx] @ v
        hyps.append(float(v[2]))
    
    color = COLORS[fixed_idx] if fixed_idx is not None else '#f39c12'
    ax.semilogy(range(len(hyps)), hyps, 'o-', color=color, label=label,
                markersize=5, linewidth=2)

# Reference line: spectral radius growth
spectral = [5 * (3 + 2*np.sqrt(2))**d for d in range(max_path_depth + 1)]
ax.semilogy(range(len(spectral)), spectral, 'k--', alpha=0.3,
            label=f'(3+2√2)^d ≈ 5.83^d')

ax.set_xlabel('Depth d', fontsize=12)
ax.set_ylabel('Hypotenuse (log scale)', fontsize=12)
ax.set_title('Hypotenuse Growth Along Paths\nExponential in Tree Depth', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_lorentz_invariance.png', dpi=150, bbox_inches='tight')
print("Saved viz_lorentz_invariance.png")
