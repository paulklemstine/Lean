"""
Visualization: Spectral Decomposition of Torsion Persistence

Visualizes how a persistence module's torsion decomposes into
independent prime channels via localization. Shows the original
module's torsion structure alongside each prime channel.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from dataclasses import dataclass, field


@dataclass
class FinAb:
    free_rank: int = 0
    torsion_orders: list = field(default_factory=list)

@dataclass
class PersMod:
    groups: list

def extract_p_part(n, p):
    pk = 1
    while n % p == 0:
        pk *= p
        n //= p
    return pk

def p_primary_subgroup(G, p):
    orders = []
    for n in G.torsion_orders:
        pk = extract_p_part(n, p)
        if pk > 1:
            orders.append(pk)
    return FinAb(free_rank=0, torsion_orders=sorted(orders))

def localize(F, p):
    return PersMod(groups=[p_primary_subgroup(G, p) for G in F.groups])

def p_torsion_detected(G, p):
    return any(n % p == 0 for n in G.torsion_orders)

def total_p_torsion(G, p):
    total = 0
    for n in G.torsion_orders:
        pk = extract_p_part(n, p)
        if pk > 1:
            total += pk
    return total


# Construct example
F = PersMod(groups=[
    FinAb(free_rank=2),
    FinAb(free_rank=1, torsion_orders=[2]),
    FinAb(torsion_orders=[6]),
    FinAb(torsion_orders=[4, 9]),
    FinAb(torsion_orders=[2, 3, 5]),
    FinAb(torsion_orders=[30]),
    FinAb(torsion_orders=[60]),
    FinAb(torsion_orders=[8, 27]),
])

primes = [2, 3, 5]
n_levels = len(F.groups)
prime_colors = {2: '#e74c3c', 3: '#3498db', 5: '#2ecc71'}

fig, axes = plt.subplots(1, len(primes) + 1, figsize=(4 * (len(primes) + 1), 6),
                          sharey=True)

# Panel 0: Original module (stacked bars by prime)
ax = axes[0]
ax.set_title('Original Module F', fontsize=13, fontweight='bold')
for i in range(n_levels):
    G = F.groups[i]
    bottom = 0
    for p in primes:
        val = total_p_torsion(G, p)
        if val > 0:
            ax.barh(i, val, left=bottom, height=0.6,
                   color=prime_colors[p], alpha=0.8, edgecolor='white', linewidth=0.5)
            bottom += val
    parts = []
    if G.free_rank > 0:
        parts.append(f'ℤ^{G.free_rank}')
    for n in G.torsion_orders:
        parts.append(f'ℤ/{n}')
    ax.text(-0.5, i, ' ⊕ '.join(parts) if parts else '0',
           ha='right', va='center', fontsize=7)

ax.set_ylabel('Filtration Level', fontsize=12)
ax.set_yticks(range(n_levels))
ax.set_xlabel('Torsion Magnitude', fontsize=10)
ax.invert_yaxis()

# Panels 1+: Localized modules
for idx, p in enumerate(primes):
    ax = axes[idx + 1]
    Lp = localize(F, p)
    color = prime_colors[p]
    ax.set_title(f'L_{p}(F)', fontsize=13, fontweight='bold', color=color)

    birth = None
    for i in range(n_levels):
        if p_torsion_detected(F.groups[i], p):
            birth = i
            break

    for i in range(n_levels):
        G = Lp.groups[i]
        total = sum(G.torsion_orders) if G.torsion_orders else 0
        if total > 0:
            ax.barh(i, total, height=0.6, color=color, alpha=0.7,
                   edgecolor='white', linewidth=0.5)
            label = ' ⊕ '.join(f'ℤ/{n}' for n in G.torsion_orders)
            ax.text(total + 0.3, i, label, ha='left', va='center', fontsize=8)
        if i == birth:
            ax.plot(-0.5, i, '*', color=color, markersize=15, zorder=5)

    ax.set_xlabel('Torsion Magnitude', fontsize=10)
    ax.invert_yaxis()

legend_patches = [mpatches.Patch(color=prime_colors[p], label=f'p={p}') for p in primes]
fig.legend(handles=legend_patches, loc='lower center', ncol=len(primes),
          fontsize=11, bbox_to_anchor=(0.5, -0.02))

plt.suptitle('Spectral Decomposition via Localization',
            fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_spectral_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_decomposition.png")
