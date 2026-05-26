#!/usr/bin/env python3
"""
Visualization: Localization as a Functorial Filter

Visualizes how the localization functor acts on two interleaved persistence
modules, demonstrating Theorem 1 (interleaving preservation) and
Theorem 3 (primewise stability as a consequence of localization).

Shows two persistence modules side by side, their interleavings, and how
localization preserves (and can tighten) the interleaving distance.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def p_primary_part(n, p):
    result = 1
    while n % p == 0:
        result *= p
        n //= p
    return result

# Define two persistence modules
# Format: list of (free_rank, [invariant_factors])
F_levels = [
    (1, []),
    (1, [6]),        # 2-torsion and 3-torsion born at level 1
    (1, [6, 4]),
    (2, [12, 4]),
    (2, [12, 4]),
]

G_levels = [
    (1, []),
    (1, []),
    (1, []),
    (1, [6]),        # 2-torsion and 3-torsion born at level 3
    (2, [6, 4]),
]

delta = 2  # Interleaving parameter

fig, axes = plt.subplots(1, 3, figsize=(18, 8))

prime_colors = {2: '#e74c3c', 3: '#3498db', 5: '#2ecc71'}

# Helper function to draw a module
def draw_module(ax, levels, label, color_base, x_offset=0):
    n = len(levels)
    for i, (rank, factors) in enumerate(levels):
        y = n - 1 - i
        # Draw node
        total_torsion = sum(factors)
        size = 200 + rank * 100 + total_torsion * 5
        
        # Color by torsion content
        if not factors:
            c = '#bdc3c7'
        else:
            # Mix colors based on prime factors
            has_2 = any(d % 2 == 0 for d in factors)
            has_3 = any(d % 3 == 0 for d in factors)
            if has_2 and has_3:
                c = '#9b59b6'  # purple for mixed
            elif has_2:
                c = '#e74c3c'
            elif has_3:
                c = '#3498db'
            else:
                c = '#2ecc71'
        
        ax.scatter(x_offset, y, s=size, c=c, zorder=5, alpha=0.8, edgecolors='black', linewidth=1)
        
        # Label
        parts = []
        if rank > 0:
            parts.append(f"Z{'²' if rank==2 else ''}")
        for d in factors:
            parts.append(f"Z/{d}")
        text = "⊕".join(parts) if parts else "0"
        ax.annotate(text, (x_offset, y), xytext=(15, 0), textcoords='offset points',
                   fontsize=7, va='center')
        
        # Draw arrow to next level
        if i < n - 1:
            ax.annotate('', xy=(x_offset, y - 0.8), xytext=(x_offset, y - 0.2),
                       arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    
    ax.set_ylabel('Filtration index', fontsize=10)
    ax.set_yticks(range(n))
    ax.set_yticklabels(list(range(n))[::-1])

# Panel 1: Original modules with interleaving
ax = axes[0]
ax.set_title(f'Original Modules\n(δ={delta}-interleaved)', fontsize=12, fontweight='bold')

draw_module(ax, F_levels, 'F', '#e74c3c', x_offset=-1)
draw_module(ax, G_levels, 'G', '#3498db', x_offset=1)

# Draw interleaving arrows
n = len(F_levels)
for i in range(n):
    j = min(i + delta, n - 1)
    y_from = n - 1 - i
    y_to = n - 1 - j
    # F -> G[+delta]
    ax.annotate('', xy=(0.7, y_to + 0.1), xytext=(-0.7, y_from + 0.1),
               arrowprops=dict(arrowstyle='->', color='#e67e22', lw=1, alpha=0.5, 
                              connectionstyle='arc3,rad=0.2'))
    # G -> F[+delta]
    ax.annotate('', xy=(-0.7, y_to - 0.1), xytext=(0.7, y_from - 0.1),
               arrowprops=dict(arrowstyle='->', color='#e67e22', lw=1, alpha=0.5,
                              connectionstyle='arc3,rad=0.2'))

ax.text(-1, n + 0.3, 'F', fontsize=14, fontweight='bold', ha='center', color='#c0392b')
ax.text(1, n + 0.3, 'G', fontsize=14, fontweight='bold', ha='center', color='#2980b9')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-1, n + 0.8)

# Birth indicators
birth_F = 1  # 2-torsion born at level 1
birth_G = 3  # 2-torsion born at level 3
ax.axhline(y=n-1-birth_F, color='#e74c3c', linestyle='--', alpha=0.3)
ax.axhline(y=n-1-birth_G, color='#3498db', linestyle='--', alpha=0.3)
ax.text(-2.3, n-1-birth_F, f'birth(F)={birth_F}', fontsize=8, color='#e74c3c')
ax.text(1.5, n-1-birth_G, f'birth(G)={birth_G}', fontsize=8, color='#3498db')

# Panel 2: Localized at p=2
ax = axes[1]
ax.set_title(f'Localized at p=2\n(Still δ={delta}-interleaved)', fontsize=12, fontweight='bold', color='#e74c3c')

# Compute 2-primary parts
F2 = [(r, [p_primary_part(d, 2) for d in factors if p_primary_part(d, 2) > 1]) 
      for r, factors in F_levels]
G2 = [(r, [p_primary_part(d, 2) for d in factors if p_primary_part(d, 2) > 1]) 
      for r, factors in G_levels]

draw_module(ax, F2, 'L₂(F)', '#e74c3c', x_offset=-1)
draw_module(ax, G2, 'L₂(G)', '#3498db', x_offset=1)

ax.text(-1, n + 0.3, 'L₂(F)', fontsize=12, fontweight='bold', ha='center', color='#c0392b')
ax.text(1, n + 0.3, 'L₂(G)', fontsize=12, fontweight='bold', ha='center', color='#2980b9')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-1, n + 0.8)

# 2-torsion births
b2_F = next((i for i, (_, f) in enumerate(F2) if f), None)
b2_G = next((i for i, (_, f) in enumerate(G2) if f), None)
if b2_F is not None:
    ax.axhline(y=n-1-b2_F, color='#e74c3c', linestyle='--', alpha=0.3)
    ax.text(-2.3, n-1-b2_F, f'birth={b2_F}', fontsize=8, color='#e74c3c')
if b2_G is not None:
    ax.axhline(y=n-1-b2_G, color='#3498db', linestyle='--', alpha=0.3)
    ax.text(1.5, n-1-b2_G, f'birth={b2_G}', fontsize=8, color='#3498db')

dist_2 = abs(b2_F - b2_G) if b2_F is not None and b2_G is not None else '∞'
ax.text(0, -0.7, f'2-primary distance = {dist_2}', ha='center', fontsize=10, 
        fontweight='bold', color='#e74c3c')

# Panel 3: Localized at p=3
ax = axes[2]
ax.set_title(f'Localized at p=3\n(Still δ={delta}-interleaved)', fontsize=12, fontweight='bold', color='#3498db')

F3 = [(r, [p_primary_part(d, 3) for d in factors if p_primary_part(d, 3) > 1]) 
      for r, factors in F_levels]
G3 = [(r, [p_primary_part(d, 3) for d in factors if p_primary_part(d, 3) > 1]) 
      for r, factors in G_levels]

draw_module(ax, F3, 'L₃(F)', '#e74c3c', x_offset=-1)
draw_module(ax, G3, 'L₃(G)', '#3498db', x_offset=1)

ax.text(-1, n + 0.3, 'L₃(F)', fontsize=12, fontweight='bold', ha='center', color='#c0392b')
ax.text(1, n + 0.3, 'L₃(G)', fontsize=12, fontweight='bold', ha='center', color='#2980b9')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-1, n + 0.8)

b3_F = next((i for i, (_, f) in enumerate(F3) if f), None)
b3_G = next((i for i, (_, f) in enumerate(G3) if f), None)
if b3_F is not None:
    ax.axhline(y=n-1-b3_F, color='#e74c3c', linestyle='--', alpha=0.3)
    ax.text(-2.3, n-1-b3_F, f'birth={b3_F}', fontsize=8, color='#e74c3c')
if b3_G is not None:
    ax.axhline(y=n-1-b3_G, color='#3498db', linestyle='--', alpha=0.3)
    ax.text(1.5, n-1-b3_G, f'birth={b3_G}', fontsize=8, color='#3498db')

dist_3 = abs(b3_F - b3_G) if b3_F is not None and b3_G is not None else '∞'
ax.text(0, -0.7, f'3-primary distance = {dist_3}', ha='center', fontsize=10, 
        fontweight='bold', color='#3498db')

plt.suptitle('Functorial Localization Preserves Interleavings\n'
             'and Can Sharpen Distance Estimates',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_localization_functor.png', dpi=150, bbox_inches='tight')
print("Saved: viz_localization_functor.png")
