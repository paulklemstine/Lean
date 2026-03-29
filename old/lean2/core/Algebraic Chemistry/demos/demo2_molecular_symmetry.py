#!/usr/bin/env python3
"""
Demo 2: Molecular Symmetry — Group Theory in Chemistry
=======================================================

This demo visualizes molecular symmetry operations, point groups,
character tables, and symmetry-adapted molecular orbitals.

Part of "The Algebraic Theory of Chemistry" project.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyArrowPatch, Arc
import os

os.makedirs("output", exist_ok=True)


# ============================================================
# Point Group Character Tables (algebraic data)
# ============================================================
CHARACTER_TABLES = {
    'C2v': {
        'operations': ['E', 'C₂', 'σᵥ(xz)', "σᵥ'(yz)"],
        'irreps': {
            'A₁': [1, 1, 1, 1],
            'A₂': [1, 1, -1, -1],
            'B₁': [1, -1, 1, -1],
            'B₂': [1, -1, -1, 1],
        },
        'basis': ['z', 'Rz', 'x, Ry', 'y, Rx'],
    },
    'C3v': {
        'operations': ['E', '2C₃', '3σᵥ'],
        'irreps': {
            'A₁': [1, 1, 1],
            'A₂': [1, 1, -1],
            'E': [2, -1, 0],
        },
        'basis': ['z', 'Rz', '(x,y), (Rx,Ry)'],
    },
    'D3h': {
        'operations': ['E', '2C₃', '3C₂', 'σₕ', '2S₃', '3σᵥ'],
        'irreps': {
            "A₁'": [1, 1, 1, 1, 1, 1],
            "A₂'": [1, 1, -1, 1, 1, -1],
            "E'": [2, -1, 0, 2, -1, 0],
            "A₁''": [1, 1, 1, -1, -1, -1],
            "A₂''": [1, 1, -1, -1, -1, 1],
            "E''": [2, -1, 0, -2, 1, 0],
        },
        'basis': ['', 'Rz', '(x,y)', '', 'z', '(Rx,Ry)'],
    },
    'Td': {
        'operations': ['E', '8C₃', '3C₂', '6S₄', '6σd'],
        'irreps': {
            'A₁': [1, 1, 1, 1, 1],
            'A₂': [1, 1, 1, -1, -1],
            'E': [2, -1, 2, 0, 0],
            'T₁': [3, 0, -1, 1, -1],
            'T₂': [3, 0, -1, -1, 1],
        },
        'basis': ['', '', '', '(Rx,Ry,Rz)', '(x,y,z)'],
    }
}


def plot_character_tables():
    """Visualize character tables as algebraic objects."""
    
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    fig.suptitle('Character Tables: Complete Algebraic Invariants of Point Groups', 
                 fontsize=16, fontweight='bold')
    
    for idx, (group_name, data) in enumerate(CHARACTER_TABLES.items()):
        ax = axes[idx // 2][idx % 2]
        ax.axis('off')
        
        ops = data['operations']
        irreps = data['irreps']
        
        n_rows = len(irreps) + 1
        n_cols = len(ops) + 1
        
        # Create table
        cell_text = []
        for irrep_name, chars in irreps.items():
            row = [irrep_name] + [str(c) for c in chars]
            cell_text.append(row)
        
        col_labels = [''] + ops
        
        table = ax.table(cellText=cell_text, colLabels=col_labels,
                        loc='center', cellLoc='center')
        table.auto_set_font_size(False)
        table.set_fontsize(11)
        table.scale(1.0, 1.8)
        
        # Color the header
        for j in range(n_cols):
            table[(0, j)].set_facecolor('#4472C4')
            table[(0, j)].set_text_props(color='white', fontweight='bold')
        
        # Color the irrep labels
        colors = ['#E8F0FE', '#FCE4EC', '#E8F5E9', '#FFF3E0', '#F3E5F5', '#E0F7FA']
        for i in range(len(irreps)):
            table[(i+1, 0)].set_facecolor(colors[i % len(colors)])
            table[(i+1, 0)].set_text_props(fontweight='bold')
            for j in range(1, n_cols):
                val = list(irreps.values())[i][j-1]
                if val > 0:
                    table[(i+1, j)].set_facecolor('#E8F5E9')
                elif val < 0:
                    table[(i+1, j)].set_facecolor('#FCE4EC')
                else:
                    table[(i+1, j)].set_facecolor('#F5F5F5')
        
        ax.set_title(f'Point Group {group_name}', fontsize=14, fontweight='bold', pad=20)
    
    plt.tight_layout()
    plt.savefig('output/character_tables.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: output/character_tables.png")


def plot_symmetry_operations():
    """Visualize symmetry operations on a water molecule (C₂ᵥ)."""
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 14))
    fig.suptitle('Symmetry Operations of H₂O (C₂ᵥ Point Group)', 
                 fontsize=16, fontweight='bold')
    
    def draw_water(ax, title, transform=None, show_axes=True):
        """Draw a water molecule with optional transformation."""
        # Oxygen at origin
        O_pos = np.array([0, 0])
        # H atoms at 104.5° angle
        angle = 104.5 / 2
        bond_length = 1.5
        H1_pos = np.array([-bond_length * np.sin(np.radians(angle)), 
                           bond_length * np.cos(np.radians(angle))])
        H2_pos = np.array([bond_length * np.sin(np.radians(angle)), 
                           bond_length * np.cos(np.radians(angle))])
        
        positions = {'O': O_pos, 'H1': H1_pos, 'H2': H2_pos}
        
        if transform is not None:
            for key in positions:
                positions[key] = transform @ positions[key]
        
        # Draw bonds
        for H_key in ['H1', 'H2']:
            ax.plot([positions['O'][0], positions[H_key][0]], 
                   [positions['O'][1], positions[H_key][1]], 
                   'k-', linewidth=3, zorder=1)
        
        # Draw atoms
        ax.scatter(*positions['O'], s=800, c='red', zorder=3, edgecolors='darkred', linewidth=2)
        ax.scatter(*positions['H1'], s=400, c='white', zorder=3, edgecolors='gray', linewidth=2)
        ax.scatter(*positions['H2'], s=400, c='white', zorder=3, edgecolors='gray', linewidth=2)
        
        # Labels
        ax.text(positions['O'][0], positions['O'][1]-0.15, 'O', ha='center', va='center', 
               fontsize=12, fontweight='bold', color='white', zorder=4)
        ax.text(positions['H1'][0]-0.25, positions['H1'][1], 'H', ha='center', va='center', 
               fontsize=10, fontweight='bold', zorder=4)
        ax.text(positions['H2'][0]+0.25, positions['H2'][1], 'H', ha='center', va='center', 
               fontsize=10, fontweight='bold', zorder=4)
        
        if show_axes:
            # Symmetry elements
            ax.axhline(y=0, color='gray', linestyle=':', alpha=0.3)
            ax.axvline(x=0, color='gray', linestyle=':', alpha=0.3)
        
        ax.set_xlim(-2.5, 2.5)
        ax.set_ylim(-2, 2.5)
        ax.set_aspect('equal')
        ax.set_title(title, fontsize=13, fontweight='bold')
        ax.grid(True, alpha=0.2)
        
        return positions
    
    # E: Identity
    ax1 = axes[0][0]
    draw_water(ax1, 'E (Identity)')
    ax1.text(0, -1.7, 'Matrix: I₂ = [[1,0],[0,1]]', ha='center', fontsize=10, 
            fontfamily='monospace', bbox=dict(boxstyle='round', facecolor='lightyellow'))
    
    # C₂: 180° rotation
    ax2 = axes[0][1]
    C2 = np.array([[-1, 0], [0, -1]])  # 180° rotation
    draw_water(ax2, 'C₂ (180° Rotation)', transform=C2)
    # Draw rotation arrow
    arc = Arc((0, 0), 3, 3, angle=0, theta1=0, theta2=180, color='blue', linewidth=2, linestyle='--')
    ax2.add_patch(arc)
    ax2.annotate('', xy=(-1.5, 0), xytext=(-1.4, 0.3),
                arrowprops=dict(arrowstyle='->', color='blue', lw=2))
    ax2.text(0, -1.7, 'Matrix: [[-1,0],[0,-1]]', ha='center', fontsize=10,
            fontfamily='monospace', bbox=dict(boxstyle='round', facecolor='lightyellow'))
    
    # σᵥ(xz): reflection in xz plane (flip y)
    ax3 = axes[1][0]
    sigma_v = np.array([[-1, 0], [0, 1]])  # reflect through yz plane (y-axis)
    draw_water(ax3, "σᵥ (Mirror plane containing C₂)", transform=sigma_v)
    ax3.axvline(x=0, color='green', linewidth=3, alpha=0.5, linestyle='--', label='Mirror plane')
    ax3.legend(fontsize=10)
    ax3.text(0, -1.7, 'Matrix: [[-1,0],[0,1]]', ha='center', fontsize=10,
            fontfamily='monospace', bbox=dict(boxstyle='round', facecolor='lightyellow'))
    
    # σᵥ'(yz): reflection in yz plane (flip x → same as σᵥ for planar molecule)
    ax4 = axes[1][1]
    sigma_v_prime = np.array([[1, 0], [0, -1]])  # reflect through xz plane
    draw_water(ax4, "σᵥ' (Mirror plane ⊥ molecular plane)", transform=sigma_v_prime)
    ax4.axhline(y=0, color='purple', linewidth=3, alpha=0.5, linestyle='--', label='Mirror plane')
    ax4.legend(fontsize=10)
    ax4.text(0, -1.7, 'Matrix: [[1,0],[0,-1]]', ha='center', fontsize=10,
            fontfamily='monospace', bbox=dict(boxstyle='round', facecolor='lightyellow'))
    
    plt.tight_layout()
    plt.savefig('output/symmetry_operations.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: output/symmetry_operations.png")


def plot_group_multiplication_table():
    """Visualize the group multiplication table for C₂ᵥ."""
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Group Algebra of C₂ᵥ', fontsize=16, fontweight='bold')
    
    # C₂ᵥ multiplication table
    # Elements: E, C₂, σᵥ, σᵥ'
    # This group is isomorphic to ℤ₂ × ℤ₂ (Klein four-group)
    elements = ['E', 'C₂', 'σᵥ', "σᵥ'"]
    
    # Multiplication table (indices)
    mult_table = [
        [0, 1, 2, 3],  # E * x
        [1, 0, 3, 2],  # C₂ * x
        [2, 3, 0, 1],  # σᵥ * x
        [3, 2, 1, 0],  # σᵥ' * x
    ]
    
    cell_text = []
    cell_colors = []
    color_map = ['#E3F2FD', '#FFECB3', '#E8F5E9', '#FCE4EC']
    
    for row in mult_table:
        cell_text.append([elements[i] for i in row])
        cell_colors.append([color_map[i] for i in row])
    
    table = ax1.table(cellText=cell_text, rowLabels=elements, colLabels=elements,
                      cellColours=cell_colors, loc='center', cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(13)
    table.scale(1.2, 2.0)
    
    # Style header
    for j in range(4):
        table[(0, j)].set_facecolor('#1565C0')
        table[(0, j)].set_text_props(color='white', fontweight='bold', fontsize=13)
    for i in range(4):
        table[(i+1, -1)].set_facecolor('#1565C0')
        table[(i+1, -1)].set_text_props(color='white', fontweight='bold', fontsize=13)
    
    ax1.axis('off')
    ax1.set_title('Cayley (Multiplication) Table\nC₂ᵥ ≅ ℤ₂ × ℤ₂', fontsize=13, fontweight='bold')
    
    # Subgroup lattice
    ax2.set_xlim(-1, 5)
    ax2.set_ylim(-0.5, 3.5)
    
    # Draw subgroup lattice
    groups = {
        'C₂ᵥ': (2, 3),
        '{E, C₂}': (0.5, 1.5),
        '{E, σᵥ}': (2, 1.5),
        "{E, σᵥ'}": (3.5, 1.5),
        '{E}': (2, 0),
    }
    
    edges = [
        ('C₂ᵥ', '{E, C₂}'), ('C₂ᵥ', '{E, σᵥ}'), ('C₂ᵥ', "{E, σᵥ'}"),
        ('{E, C₂}', '{E}'), ('{E, σᵥ}', '{E}'), ("{E, σᵥ'}", '{E}'),
    ]
    
    for name, pos in groups.items():
        circle = plt.Circle(pos, 0.4, fill=True, facecolor='lightcoral', 
                           edgecolor='darkred', linewidth=2)
        ax2.add_patch(circle)
        ax2.text(pos[0], pos[1], name, ha='center', va='center', fontsize=8, fontweight='bold')
    
    for g1, g2 in edges:
        p1, p2 = groups[g1], groups[g2]
        dx, dy = p2[0]-p1[0], p2[1]-p1[1]
        dist = np.sqrt(dx**2 + dy**2)
        shrink = 0.4 / dist
        ax2.plot([p1[0]+dx*shrink, p2[0]-dx*shrink], 
                [p1[1]+dy*shrink, p2[1]-dy*shrink], 
                'k-', linewidth=2)
    
    # Add order labels
    ax2.text(4.3, 3, '|G| = 4', fontsize=11, fontweight='bold')
    ax2.text(4.3, 1.5, '|H| = 2', fontsize=11, fontweight='bold')
    ax2.text(4.3, 0, '|H| = 1', fontsize=11, fontweight='bold')
    
    ax2.set_title('Subgroup Lattice of C₂ᵥ', fontsize=13, fontweight='bold')
    ax2.set_aspect('equal')
    ax2.axis('off')
    
    plt.tight_layout()
    plt.savefig('output/group_algebra.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: output/group_algebra.png")


def plot_orbital_symmetry():
    """Visualize how group theory classifies molecular orbitals."""
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle('Symmetry Classification of Molecular Orbitals (H₂O, C₂ᵥ)', 
                 fontsize=16, fontweight='bold')
    
    def draw_orbital(ax, orbital_type, title, symmetry_label, 
                     energy_level, color_pos='blue', color_neg='red'):
        """Draw a schematic molecular orbital."""
        
        theta = np.linspace(0, 2*np.pi, 100)
        
        if orbital_type == 'a1_bonding':
            # Symmetric bonding - all positive lobes overlap
            for cx, cy in [(-0.8, 0.5), (0, -0.3), (0.8, 0.5)]:
                r = 0.4
                ax.fill(cx + r*np.cos(theta), cy + r*np.sin(theta), 
                       alpha=0.4, color=color_pos)
                ax.plot(cx + r*np.cos(theta), cy + r*np.sin(theta), 
                       color=color_pos, linewidth=1.5)
            # + signs
            for cx, cy in [(-0.8, 0.5), (0, -0.3), (0.8, 0.5)]:
                ax.text(cx, cy, '+', ha='center', va='center', fontsize=16, fontweight='bold')
                
        elif orbital_type == 'b2_bonding':
            # Antisymmetric under C₂
            ax.fill(-0.8 + 0.4*np.cos(theta), 0.5 + 0.4*np.sin(theta), 
                   alpha=0.4, color=color_pos)
            ax.fill(0 + 0.35*np.cos(theta), -0.3 + 0.35*np.sin(theta), 
                   alpha=0.4, color=color_pos)
            ax.fill(0.8 + 0.4*np.cos(theta), 0.5 + 0.4*np.sin(theta), 
                   alpha=0.4, color=color_neg)
            ax.text(-0.8, 0.5, '+', ha='center', va='center', fontsize=16, fontweight='bold')
            ax.text(0, -0.3, '+', ha='center', va='center', fontsize=16, fontweight='bold')
            ax.text(0.8, 0.5, '−', ha='center', va='center', fontsize=16, fontweight='bold')
            
        elif orbital_type == 'a1_nonbonding':
            # Lone pair on oxygen
            # Two lobes along z-axis
            ax.fill(0 + 0.3*np.cos(theta), 0.6 + 0.5*np.sin(theta), 
                   alpha=0.4, color=color_pos)
            ax.fill(0 + 0.3*np.cos(theta), -0.9 + 0.5*np.sin(theta), 
                   alpha=0.4, color=color_neg)
            ax.text(0, 0.6, '+', ha='center', va='center', fontsize=16, fontweight='bold')
            ax.text(0, -0.9, '−', ha='center', va='center', fontsize=16, fontweight='bold')
            
        elif orbital_type == 'b1_nonbonding':
            # Lone pair perpendicular to molecular plane
            ax.fill(-0.5 + 0.4*np.cos(theta), 0 + 0.4*np.sin(theta), 
                   alpha=0.4, color=color_pos)
            ax.fill(0.5 + 0.4*np.cos(theta), 0 + 0.4*np.sin(theta), 
                   alpha=0.4, color=color_neg)
            ax.text(-0.5, 0, '+', ha='center', va='center', fontsize=16, fontweight='bold')
            ax.text(0.5, 0, '−', ha='center', va='center', fontsize=16, fontweight='bold')
        
        # Symmetry axes
        ax.axvline(x=0, color='gray', linestyle=':', alpha=0.3)
        ax.axhline(y=0, color='gray', linestyle=':', alpha=0.3)
        
        ax.set_xlim(-2, 2)
        ax.set_ylim(-2, 2)
        ax.set_aspect('equal')
        ax.set_title(f'{title}\nSymmetry: {symmetry_label}  |  E ≈ {energy_level}', 
                    fontsize=11, fontweight='bold')
        
        # Character under each operation
        ax.text(0, -1.7, f'χ(E)=+1  χ(C₂)={"+" if "A" in symmetry_label or "a" in symmetry_label else "−"}1  ' + 
               f'χ(σᵥ)={"+" if "1" in symmetry_label else "−"}1', 
               ha='center', fontsize=9, fontfamily='monospace',
               bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
        ax.axis('off')
    
    draw_orbital(axes[0][0], 'a1_bonding', '1a₁ (Bonding)', 'A₁', 'low')
    draw_orbital(axes[0][1], 'b2_bonding', '1b₂ (Bonding)', 'B₂', 'medium-low')
    draw_orbital(axes[1][0], 'a1_nonbonding', '2a₁ (Nonbonding)', 'A₁', 'medium')
    draw_orbital(axes[1][1], 'b1_nonbonding', '1b₁ (Lone pair)', 'B₁', 'medium-high')
    
    plt.tight_layout()
    plt.savefig('output/orbital_symmetry.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: output/orbital_symmetry.png")


# Run all visualizations
plot_character_tables()
plot_symmetry_operations()
plot_group_multiplication_table()
plot_orbital_symmetry()

print("\n✅ Demo 2 Complete: Molecular Symmetry Algebra")
print("=" * 50)
print("Key results:")
print("• Point groups classify molecular symmetry as algebraic objects")
print("• Character tables are complete invariants of group representations")
print("• Molecular orbitals are classified by irreducible representations")
print("• Selection rules are purely algebraic (tensor product decomposition)")
print("• The Cayley table captures the full group structure")
