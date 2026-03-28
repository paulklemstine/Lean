#!/usr/bin/env python3
"""
Demo 4: Periodic Table Algebra — Quantum Numbers as Lattice Points
===================================================================

This demo visualizes the periodic table as an algebraic object:
quantum numbers as coordinates in a representation space, the Madelung
ordering as a partial order, and chemical periodicity as group structure.

Part of "The Algebraic Theory of Chemistry" project.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Rectangle
from matplotlib.colors import Normalize
from matplotlib import cm
import os

os.makedirs("output", exist_ok=True)

# ============================================================
# Element Data: The Algebraic Coordinates
# ============================================================
ELEMENTS = {
    1:  ('H',  1, 1,  0, 0, 'Nonmetal'),
    2:  ('He', 1, 0,  0, 0, 'Noble gas'),
    3:  ('Li', 2, 1,  0, 0, 'Alkali metal'),
    4:  ('Be', 2, 2,  0, 0, 'Alkaline earth'),
    5:  ('B',  2, 2,  1, 1, 'Metalloid'),
    6:  ('C',  2, 2,  1, 2, 'Nonmetal'),
    7:  ('N',  2, 2,  1, 3, 'Nonmetal'),
    8:  ('O',  2, 2,  1, 4, 'Nonmetal'),
    9:  ('F',  2, 2,  1, 5, 'Halogen'),
    10: ('Ne', 2, 2,  1, 6, 'Noble gas'),
    11: ('Na', 3, 1,  0, 0, 'Alkali metal'),
    12: ('Mg', 3, 2,  0, 0, 'Alkaline earth'),
    13: ('Al', 3, 2,  1, 1, 'Post-transition'),
    14: ('Si', 3, 2,  1, 2, 'Metalloid'),
    15: ('P',  3, 2,  1, 3, 'Nonmetal'),
    16: ('S',  3, 2,  1, 4, 'Nonmetal'),
    17: ('Cl', 3, 2,  1, 5, 'Halogen'),
    18: ('Ar', 3, 2,  1, 6, 'Noble gas'),
    19: ('K',  4, 1,  0, 0, 'Alkali metal'),
    20: ('Ca', 4, 2,  0, 0, 'Alkaline earth'),
    # Transition metals (3d)
    21: ('Sc', 4, 2,  2, 1, 'Transition metal'),
    22: ('Ti', 4, 2,  2, 2, 'Transition metal'),
    23: ('V',  4, 2,  2, 3, 'Transition metal'),
    24: ('Cr', 4, 1,  2, 5, 'Transition metal'),  # anomalous config
    25: ('Mn', 4, 2,  2, 5, 'Transition metal'),
    26: ('Fe', 4, 2,  2, 6, 'Transition metal'),
    27: ('Co', 4, 2,  2, 7, 'Transition metal'),
    28: ('Ni', 4, 2,  2, 8, 'Transition metal'),
    29: ('Cu', 4, 1,  2, 10, 'Transition metal'),  # anomalous
    30: ('Zn', 4, 2,  2, 10, 'Transition metal'),
    31: ('Ga', 4, 2,  1, 1, 'Post-transition'),
    32: ('Ge', 4, 2,  1, 2, 'Metalloid'),
    33: ('As', 4, 2,  1, 3, 'Metalloid'),
    34: ('Se', 4, 2,  1, 4, 'Nonmetal'),
    35: ('Br', 4, 2,  1, 5, 'Halogen'),
    36: ('Kr', 4, 2,  1, 6, 'Noble gas'),
}

# Standard periodic table positions (period, group)
PT_POSITIONS = {
    1: (1,1), 2: (1,18),
    3: (2,1), 4: (2,2), 5: (2,13), 6: (2,14), 7: (2,15), 8: (2,16), 9: (2,17), 10: (2,18),
    11: (3,1), 12: (3,2), 13: (3,13), 14: (3,14), 15: (3,15), 16: (3,16), 17: (3,17), 18: (3,18),
    19: (4,1), 20: (4,2),
    21: (4,3), 22: (4,4), 23: (4,5), 24: (4,6), 25: (4,7), 26: (4,8), 27: (4,9), 28: (4,10),
    29: (4,11), 30: (4,12),
    31: (4,13), 32: (4,14), 33: (4,15), 34: (4,16), 35: (4,17), 36: (4,18),
}

CATEGORY_COLORS = {
    'Nonmetal': '#A8E6CF',
    'Noble gas': '#FFD3B6',
    'Alkali metal': '#FF8B94',
    'Alkaline earth': '#FFAAA5',
    'Metalloid': '#B5EAD7',
    'Halogen': '#C7CEEA',
    'Transition metal': '#FFDAC1',
    'Post-transition': '#E2F0CB',
}


def plot_periodic_table_algebraic():
    """Periodic table colored by algebraic properties."""
    
    fig, axes = plt.subplots(1, 2, figsize=(20, 8))
    fig.suptitle('The Periodic Table as an Algebraic Object', fontsize=18, fontweight='bold')
    
    # --- Panel 1: Standard periodic table with Madelung (n+l) coloring ---
    ax1 = axes[0]
    
    # Madelung rule: fill by n+l, then by n
    for Z, (symbol, n, s_elec, l_max, d_elec, category) in ELEMENTS.items():
        if Z not in PT_POSITIONS:
            continue
        period, group = PT_POSITIONS[Z]
        
        # Color by n+l of the last filled subshell
        if l_max == 0:
            n_plus_l = n  # s orbital
        elif l_max == 1:
            n_plus_l = n + 1  # p orbital
        elif l_max == 2:
            n_plus_l = n + 2  # d orbital (but listed n is for s electrons)
            n_plus_l = (n-1) + 2  # d orbitals are (n-1)d
        
        color = plt.cm.viridis(n_plus_l / 8)
        
        rect = FancyBboxPatch((group - 0.45, -period + 0.45), 0.9, -0.9,
                              boxstyle="round,pad=0.05", 
                              facecolor=color, edgecolor='black', linewidth=0.5)
        ax1.add_patch(rect)
        ax1.text(group, -period, symbol, ha='center', va='center', 
                fontsize=8, fontweight='bold', color='white')
        ax1.text(group, -period - 0.3, str(Z), ha='center', va='center', 
                fontsize=5, color='white', alpha=0.8)
    
    ax1.set_xlim(0, 19)
    ax1.set_ylim(-5, 0.5)
    ax1.set_aspect('equal')
    ax1.set_title('Colored by Madelung Number (n + ℓ)\nThe algebraic filling order', 
                  fontsize=13, fontweight='bold')
    ax1.axis('off')
    
    # Add colorbar
    sm = plt.cm.ScalarMappable(cmap='viridis', norm=Normalize(vmin=1, vmax=7))
    cb = plt.colorbar(sm, ax=ax1, shrink=0.5, label='n + ℓ')
    
    # --- Panel 2: Periodic table colored by category ---
    ax2 = axes[1]
    
    for Z, (symbol, n, s_elec, l_max, d_elec, category) in ELEMENTS.items():
        if Z not in PT_POSITIONS:
            continue
        period, group = PT_POSITIONS[Z]
        
        color = CATEGORY_COLORS.get(category, '#FFFFFF')
        
        rect = FancyBboxPatch((group - 0.45, -period + 0.45), 0.9, -0.9,
                              boxstyle="round,pad=0.05", 
                              facecolor=color, edgecolor='black', linewidth=0.5)
        ax2.add_patch(rect)
        ax2.text(group, -period, symbol, ha='center', va='center', 
                fontsize=8, fontweight='bold')
        ax2.text(group, -period - 0.3, str(Z), ha='center', va='center', 
                fontsize=5, alpha=0.6)
    
    ax2.set_xlim(0, 19)
    ax2.set_ylim(-5, 0.5)
    ax2.set_aspect('equal')
    ax2.set_title('Colored by Chemical Category\nAlgebraic equivalence classes', 
                  fontsize=13, fontweight='bold')
    ax2.axis('off')
    
    # Legend for categories
    legend_patches = [mpatches.Patch(color=c, label=cat) for cat, c in CATEGORY_COLORS.items()]
    ax2.legend(handles=legend_patches, loc='lower right', fontsize=7, ncol=2)
    
    plt.tight_layout()
    plt.savefig('output/periodic_table_algebraic.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: output/periodic_table_algebraic.png")

import matplotlib.patches as mpatches

def plot_quantum_number_space():
    """Visualize quantum numbers as points in a lattice."""
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle('Quantum Numbers as Lattice Points in Representation Space', 
                 fontsize=16, fontweight='bold')
    
    # --- Panel 1: (n, l) space with Madelung diagonals ---
    ax1 = axes[0]
    
    orbital_names = 'spdfghijk'
    subshells = []
    for n in range(1, 8):
        for l in range(min(n, len(orbital_names))):
            capacity = 2 * (2*l + 1)
            subshells.append((n, l, capacity, n+l))
    
    # Color by n+l
    for n, l, cap, npl in subshells:
        color = plt.cm.Set1(npl / 10)
        size = cap * 15
        ax1.scatter(l, n, s=size, c=[color], edgecolors='black', linewidth=1, zorder=5)
        ax1.text(l, n, f'{n}{orbital_names[l]}', ha='center', va='center', fontsize=7, fontweight='bold')
    
    # Draw Madelung diagonals
    for k in range(1, 12):
        xs = [l for n, l, _, npl in subshells if npl == k]
        ys = [n for n, l, _, npl in subshells if npl == k]
        if xs:
            ax1.plot(xs, ys, '--', linewidth=1, alpha=0.5, color=plt.cm.Set1(k/10))
            ax1.text(max(xs) + 0.3, min(ys), f'n+ℓ={k}', fontsize=7, alpha=0.7)
    
    ax1.set_xlabel('Angular momentum quantum number ℓ', fontsize=11)
    ax1.set_ylabel('Principal quantum number n', fontsize=11)
    ax1.set_title('Subshell Lattice (n, ℓ)\nMadelung diagonal = filling order', fontsize=12, fontweight='bold')
    ax1.grid(True, alpha=0.3)
    ax1.set_xticks(range(5))
    ax1.set_xticklabels(['s (ℓ=0)', 'p (ℓ=1)', 'd (ℓ=2)', 'f (ℓ=3)', 'g (ℓ=4)'])
    
    # --- Panel 2: Orbital degeneracy pattern ---
    ax2 = axes[1]
    
    for n in range(1, 6):
        for l in range(n):
            for ml in range(-l, l+1):
                color = 'blue' if ml < 0 else ('red' if ml > 0 else 'green')
                ax2.scatter(ml, n - l*0.15, s=80, c=color, alpha=0.7, edgecolors='black', linewidth=0.5)
    
    ax2.set_xlabel('Magnetic quantum number mₗ', fontsize=11)
    ax2.set_ylabel('Shell (n)', fontsize=11)
    ax2.set_title('Orbital Degeneracy Pattern\nmₗ ∈ {-ℓ, ..., +ℓ}: dim = 2ℓ+1', fontsize=12, fontweight='bold')
    ax2.grid(True, alpha=0.3)
    
    # --- Panel 3: Cumulative electron count ---
    ax3 = axes[2]
    
    # Madelung filling order
    filling_order = []
    for k in range(1, 12):  # n + l value
        for n in range(1, k+1):
            l = k - n
            if 0 <= l < n:
                capacity = 2 * (2*l + 1)
                filling_order.append((n, l, capacity, f'{n}{orbital_names[l]}'))
    
    cumulative = 0
    xs, ys, labels = [], [], []
    for n, l, cap, label in filling_order:
        cumulative += cap
        xs.append(len(xs) + 1)
        ys.append(cumulative)
        labels.append(label)
    
    ax3.bar(xs, ys, color=[plt.cm.viridis(y/120) for y in ys], edgecolor='black')
    ax3.set_xticks(xs)
    ax3.set_xticklabels(labels, rotation=45, fontsize=8)
    ax3.set_xlabel('Subshell (Madelung order)', fontsize=11)
    ax3.set_ylabel('Cumulative electrons', fontsize=11)
    ax3.set_title('Aufbau Principle\nCumulative electrons = atomic number', fontsize=12, fontweight='bold')
    
    # Mark noble gases
    noble_gas_Z = [2, 10, 18, 36]
    for Z in noble_gas_Z:
        idx = next(i for i, y in enumerate(ys) if y >= Z)
        ax3.axhline(y=Z, color='red', linewidth=1, linestyle=':', alpha=0.5)
        ax3.text(len(xs) + 0.5, Z, f'Z={Z}', fontsize=8, color='red')
    
    ax3.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('output/quantum_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: output/quantum_lattice.png")


def plot_madelung_rule():
    """Visualize the Madelung rule as an algebraic ordering on ℕ²."""
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))
    ax.set_title('The Madelung Rule: A Total Order on Quantum Number Space\n'
                 'Order by (n+ℓ), then by n — an algebraic filling prescription', 
                 fontsize=14, fontweight='bold')
    
    # Draw the n-l grid
    order = 0
    positions = {}
    
    for k in range(1, 10):  # n + l = k
        for n in range(1, k+1):
            l = k - n
            if 0 <= l < n:
                order += 1
                positions[(n, l)] = order
    
    # Draw grid and connections
    prev_pos = None
    for k in range(1, 10):
        for n in range(1, k+1):
            l = k - n
            if 0 <= l < n:
                capacity = 2 * (2*l + 1)
                o = positions[(n, l)]
                
                # Draw circle sized by capacity
                color = plt.cm.tab10(l)
                circle = plt.Circle((l, n), 0.35, facecolor=color, edgecolor='black', 
                                   linewidth=2, alpha=0.7)
                ax.add_patch(circle)
                
                # Label
                label = f'{n}{"spdfghijk"[l]}\n({capacity}e⁻)'
                ax.text(l, n, label, ha='center', va='center', fontsize=8, fontweight='bold')
                
                # Draw arrow from previous
                if prev_pos is not None:
                    pl, pn = prev_pos
                    dx, dy = l - pl, n - pn
                    dist = np.sqrt(dx**2 + dy**2)
                    shrink = 0.38 / dist if dist > 0 else 0
                    ax.annotate('', xy=(l - dx*shrink, n - dy*shrink),
                               xytext=(pl + dx*shrink, pn + dy*shrink),
                               arrowprops=dict(arrowstyle='->', color='red', lw=2))
                    ax.text((l + pl)/2, (n + pn)/2, str(o), fontsize=7, color='red',
                           ha='center', va='center',
                           bbox=dict(boxstyle='round,pad=0.1', facecolor='white', alpha=0.7))
                
                prev_pos = (l, n)
    
    # Draw diagonal lines
    for k in range(1, 10):
        xs, ys = [], []
        for n in range(1, k+1):
            l = k - n
            if 0 <= l < n:
                xs.append(l)
                ys.append(n)
        if xs:
            ax.plot(xs, ys, 'k:', linewidth=1, alpha=0.3)
    
    ax.set_xlabel('Angular momentum ℓ', fontsize=13)
    ax.set_ylabel('Principal quantum number n', fontsize=13)
    ax.set_xlim(-0.5, 5)
    ax.set_ylim(0.5, 8)
    ax.set_xticks(range(5))
    ax.set_xticklabels(['s', 'p', 'd', 'f', 'g'], fontsize=12)
    ax.grid(True, alpha=0.2)
    ax.set_aspect('equal')
    
    plt.tight_layout()
    plt.savefig('output/madelung_rule.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: output/madelung_rule.png")


# Run all visualizations
plot_periodic_table_algebraic()
plot_quantum_number_space()
plot_madelung_rule()

print("\n✅ Demo 4 Complete: Periodic Table Algebra")
print("=" * 50)
print("Key results:")
print("• Quantum numbers (n,ℓ,mₗ,mₛ) are lattice points in representation space")
print("• The Madelung rule defines a total order on ℕ² (filling order)")
print("• Chemical periodicity = quotient structure modulo noble gas closures")
print("• Element categories = algebraic equivalence classes under valence")
