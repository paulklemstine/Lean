#!/usr/bin/env python3
"""
Visualization: Witness Size Bounds for Parametric Pythagorean Triples

Shows the tight bounds on hypotenuse size: m² ≤ c = m² + n² ≤ 2m²,
and the relationship between parameters (m, n) and the generated triple.

This visualizes the key size theorems from the formal verification:
witness_hypotenuse_bound and witness_hypotenuse_lower.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import gcd

fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle('Witness Size Bounds: Parametric Pythagorean Triple Synthesis',
             fontsize=16, fontweight='bold')

# --- Panel 1: Hypotenuse vs parameters ---
ax = axes[0, 0]
ms = np.arange(2, 30)
for n_ratio_label, n_func, color in [
    ('n = 1', lambda m: 1, '#e74c3c'),
    ('n = m//2', lambda m: max(1, m//2), '#3498db'),
    ('n = m-1', lambda m: m-1, '#2ecc71'),
]:
    hyps = []
    m_vals = []
    for m in ms:
        n = n_func(m)
        if n < m and n >= 1:
            c = m**2 + n**2
            hyps.append(c)
            m_vals.append(m)
    ax.plot(m_vals, hyps, 'o-', label=n_ratio_label, color=color, markersize=4)

# Bounds
m_cont = np.linspace(2, 29, 100)
ax.fill_between(m_cont, m_cont**2, 2*m_cont**2, alpha=0.15, color='gray',
                label='Bound: m² ≤ c ≤ 2m²')
ax.plot(m_cont, m_cont**2, '--', color='gray', alpha=0.5)
ax.plot(m_cont, 2*m_cont**2, '--', color='gray', alpha=0.5)

ax.set_xlabel('Parameter m', fontsize=12)
ax.set_ylabel('Hypotenuse c = m² + n²', fontsize=12)
ax.set_title('Hypotenuse Growth with Parameter m', fontsize=13)
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# --- Panel 2: All primitive triples up to hypotenuse 500 ---
ax = axes[0, 1]
triples = []
for m in range(2, 50):
    for n in range(1, m):
        if gcd(m, n) == 1 and (m - n) % 2 == 1:
            a = m**2 - n**2
            b = 2 * m * n
            c = m**2 + n**2
            if c <= 500:
                triples.append((min(a,b), max(a,b), c))

a_vals = [t[0] for t in triples]
b_vals = [t[1] for t in triples]
c_vals = [t[2] for t in triples]

scatter = ax.scatter(a_vals, b_vals, c=c_vals, cmap='viridis', 
                     s=30, alpha=0.8, edgecolors='white', linewidths=0.5)
plt.colorbar(scatter, ax=ax, label='Hypotenuse c')

# Draw the line a = b (no isosceles triple exists here)
max_val = max(max(a_vals), max(b_vals))
ax.plot([0, max_val], [0, max_val], 'r--', alpha=0.5, label='a = b (forbidden)')

ax.set_xlabel('Shorter leg a', fontsize=12)
ax.set_ylabel('Longer leg b', fontsize=12)
ax.set_title('Primitive Triples (c ≤ 500)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# --- Panel 3: Leg ratio distribution ---
ax = axes[1, 0]
ratios = [t[1]/t[0] for t in triples if t[0] > 0]
ax.hist(ratios, bins=30, color='#9b59b6', alpha=0.7, edgecolor='white')
ax.axvline(x=1, color='red', linestyle='--', linewidth=2, label='b/a = 1 (impossible)')
ax.set_xlabel('Leg ratio b/a', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Distribution of Leg Ratios', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# --- Panel 4: Quadratic bound visualization ---
ax = axes[1, 1]
m_range = range(2, 25)
for m in m_range:
    n_vals = range(1, m)
    for n in n_vals:
        if gcd(m, n) == 1 and (m - n) % 2 == 1:
            c = m**2 + n**2
            bound = (m + n)**2
            ratio = c / bound
            ax.scatter(m, ratio, c='#3498db', s=20, alpha=0.6)

ax.axhline(y=0.5, color='red', linestyle='--', alpha=0.5, 
           label='c/(m+n)² = 0.5 (when n=0)')
ax.axhline(y=1.0, color='green', linestyle='--', alpha=0.5,
           label='c/(m+n)² = 1 (upper bound)')

ax.set_xlabel('Parameter m', fontsize=12)
ax.set_ylabel('c / (m+n)²', fontsize=12)
ax.set_title('Quadratic Bound Tightness: c ≤ (m+n)²', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(0.4, 1.05)

plt.tight_layout()
plt.savefig('viz_witness_bounds.png', dpi=150, bbox_inches='tight')
print("Saved viz_witness_bounds.png")
