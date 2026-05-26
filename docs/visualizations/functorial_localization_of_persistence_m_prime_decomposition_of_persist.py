#!/usr/bin/env python3
"""
Visualization: Prime Decomposition of Persistence Torsion

Visualizes how torsion in a persistence module decomposes along the prime
spectrum. Shows the original mixed-torsion filtration alongside its
localized (p-primary) components, illustrating Theorem 2: the p-torsion
birth set equals the global torsion birth set after localization.

Output: A multi-panel figure showing the arithmetic decomposition of
persistence torsion into independent prime channels.
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

def prime_factors(n):
    factors = set()
    d = 2
    while d * d <= n:
        if n % d == 0:
            factors.add(d)
            while n % d == 0:
                n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors

# Define a persistence module with mixed torsion
# Each level: (free_rank, [invariant_factors])
levels = [
    (2, []),           # Level 0: Z²
    (2, [6]),          # Level 1: Z² ⊕ Z/6 (2-torsion AND 3-torsion born)
    (2, [6, 4]),       # Level 2: Z² ⊕ Z/6 ⊕ Z/4 (more 2-torsion)
    (2, [12, 4]),      # Level 3: Z² ⊕ Z/12 ⊕ Z/4
    (3, [12, 4, 25]),  # Level 4: Z³ ⊕ Z/12 ⊕ Z/4 ⊕ Z/25 (5-torsion born)
    (3, [60, 4, 25]),  # Level 5: Z³ ⊕ Z/60 ⊕ Z/4 ⊕ Z/25
]

primes = [2, 3, 5]
prime_colors = {2: '#e74c3c', 3: '#3498db', 5: '#2ecc71'}
prime_labels = {2: 'p=2 channel', 3: 'p=3 channel', 5: 'p=5 channel'}

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Original mixed-torsion module
ax = axes[0, 0]
ax.set_title('Original Persistence Module\n(Mixed Torsion)', fontsize=12, fontweight='bold')

for i, (rank, factors) in enumerate(levels):
    # Draw free part
    if rank > 0:
        ax.barh(i, rank * 0.3, left=0, height=0.4, color='#95a5a6', alpha=0.7)
        ax.text(rank * 0.15, i, f'Z{"²" if rank==2 else "³" if rank==3 else ""}', 
                ha='center', va='center', fontsize=8, color='white', fontweight='bold')
    
    # Draw torsion parts with prime coloring
    offset = rank * 0.3 + 0.1
    for d in factors:
        width = np.log2(d + 1) * 0.15
        pf = prime_factors(d)
        # Color by largest prime factor
        if len(pf) > 1:
            color = '#9b59b6'  # purple for mixed
        else:
            p = list(pf)[0]
            color = prime_colors.get(p, '#7f8c8d')
        ax.barh(i, width, left=offset, height=0.4, color=color, alpha=0.8)
        ax.text(offset + width/2, i, f'Z/{d}', ha='center', va='center', fontsize=7)
        offset += width + 0.05

ax.set_xlabel('Group structure')
ax.set_ylabel('Filtration level')
ax.set_yticks(range(len(levels)))
ax.invert_yaxis()

# Panels 2-4: Localized at each prime
for idx, p in enumerate(primes):
    row, col = (idx + 1) // 2, (idx + 1) % 2
    ax = axes[row, col]
    
    color = prime_colors[p]
    ax.set_title(f'Localized at p={p}\n(Only {p}-primary torsion survives)', 
                 fontsize=12, fontweight='bold', color=color)
    
    birth_found = False
    birth_level = None
    
    for i, (rank, factors) in enumerate(levels):
        # Localized torsion: extract p-primary parts
        p_parts = []
        for d in factors:
            pk = p_primary_part(d, p)
            if pk > 1:
                p_parts.append(pk)
        
        # Draw free part (stays)
        if rank > 0:
            ax.barh(i, rank * 0.3, left=0, height=0.4, color='#bdc3c7', alpha=0.5)
            ax.text(rank * 0.15, i, f'Z(p){"²" if rank==2 else "³" if rank==3 else ""}', 
                    ha='center', va='center', fontsize=7, color='#7f8c8d')
        
        # Draw p-primary torsion
        offset = rank * 0.3 + 0.1
        for pk in p_parts:
            width = np.log2(pk + 1) * 0.15
            ax.barh(i, width, left=offset, height=0.4, color=color, alpha=0.8)
            ax.text(offset + width/2, i, f'Z/{pk}', ha='center', va='center', fontsize=7)
            offset += width + 0.05
        
        # Mark birth
        if p_parts and not birth_found:
            birth_found = True
            birth_level = i
            ax.axhline(y=i, color=color, linewidth=2, linestyle='--', alpha=0.5)
            ax.text(offset + 0.2, i, f'← BIRTH (level {i})', 
                    va='center', fontsize=9, color=color, fontweight='bold')
    
    ax.set_xlabel('Localized group structure')
    ax.set_ylabel('Filtration level')
    ax.set_yticks(range(len(levels)))
    ax.invert_yaxis()

plt.suptitle('Prime Decomposition of Persistence Torsion\n'
             'Each prime channel reveals independent topological structure',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_prime_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved: viz_prime_decomposition.png")
