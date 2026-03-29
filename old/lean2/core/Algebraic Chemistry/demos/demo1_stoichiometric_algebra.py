#!/usr/bin/env python3
"""
Demo 1: Stoichiometric Algebra — The Linear Algebra of Chemical Reactions
=========================================================================

This demo shows how the stoichiometric matrix captures the algebraic structure
of a reaction network, and how conservation laws emerge as its kernel.

Part of "The Algebraic Theory of Chemistry" project.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.patches as mpatches
from mpl_toolkits.mplot3d import Axes3D
from scipy.linalg import null_space
import os

# Create output directory
os.makedirs("output", exist_ok=True)


def build_stoichiometric_matrix(species, reactions):
    """
    Build the stoichiometric matrix from species list and reactions.
    
    Each reaction is a dict: {'reactants': {species: coeff}, 'products': {species: coeff}}
    
    Returns: Γ ∈ ℤ^(n×r) where n = |species|, r = |reactions|
    """
    n = len(species)
    r = len(reactions)
    Gamma = np.zeros((n, r), dtype=int)
    
    species_idx = {s: i for i, s in enumerate(species)}
    
    for j, rxn in enumerate(reactions):
        for s, coeff in rxn.get('reactants', {}).items():
            Gamma[species_idx[s], j] -= coeff
        for s, coeff in rxn.get('products', {}).items():
            Gamma[species_idx[s], j] += coeff
    
    return Gamma


def find_conservation_laws(Gamma):
    """
    Conservation laws live in ker(Γᵀ).
    Returns a basis for the left null space of Γ.
    """
    ns = null_space(Gamma.T.astype(float))
    return ns


def plot_stoichiometric_analysis(species, reactions, reaction_names, title, filename):
    """Create a comprehensive visualization of the stoichiometric algebra."""
    
    Gamma = build_stoichiometric_matrix(species, reactions)
    conservation = find_conservation_laws(Gamma)
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle(f'Stoichiometric Algebra: {title}', fontsize=16, fontweight='bold')
    
    # --- Panel 1: Stoichiometric Matrix ---
    ax1 = axes[0]
    im = ax1.imshow(Gamma, cmap='RdBu', aspect='auto', vmin=-max(abs(Gamma.min()), Gamma.max()),
                     vmax=max(abs(Gamma.min()), Gamma.max()))
    ax1.set_xticks(range(len(reaction_names)))
    ax1.set_xticklabels(reaction_names, rotation=45, ha='right', fontsize=9)
    ax1.set_yticks(range(len(species)))
    ax1.set_yticklabels(species, fontsize=10)
    ax1.set_title('Stoichiometric Matrix Γ', fontsize=13, fontweight='bold')
    ax1.set_xlabel('Reactions')
    ax1.set_ylabel('Species')
    
    # Annotate cells
    for i in range(Gamma.shape[0]):
        for j in range(Gamma.shape[1]):
            color = 'white' if abs(Gamma[i, j]) > 1 else 'black'
            ax1.text(j, i, str(Gamma[i, j]), ha='center', va='center', 
                    fontsize=12, fontweight='bold', color=color)
    
    plt.colorbar(im, ax=ax1, shrink=0.8)
    
    # --- Panel 2: Conservation Laws ---
    ax2 = axes[1]
    if conservation.shape[1] > 0:
        # Round to nearest rational-looking numbers
        cons_display = conservation.copy()
        for col in range(cons_display.shape[1]):
            v = cons_display[:, col]
            # Normalize so smallest nonzero entry is 1
            nonzero = np.abs(v[np.abs(v) > 1e-10])
            if len(nonzero) > 0:
                v = v / nonzero.min()
                cons_display[:, col] = np.round(v, 2)
        
        im2 = ax2.imshow(cons_display, cmap='Greens', aspect='auto')
        ax2.set_xticks(range(cons_display.shape[1]))
        ax2.set_xticklabels([f'Law {i+1}' for i in range(cons_display.shape[1])], fontsize=10)
        ax2.set_yticks(range(len(species)))
        ax2.set_yticklabels(species, fontsize=10)
        
        for i in range(cons_display.shape[0]):
            for j in range(cons_display.shape[1]):
                ax2.text(j, i, f'{cons_display[i,j]:.1f}', ha='center', va='center',
                        fontsize=12, fontweight='bold')
        
        plt.colorbar(im2, ax=ax2, shrink=0.8)
    else:
        ax2.text(0.5, 0.5, 'No conservation laws\n(full rank system)', 
                transform=ax2.transAxes, ha='center', va='center', fontsize=14)
    
    ax2.set_title('Conservation Laws\nker(Γᵀ)', fontsize=13, fontweight='bold')
    
    # --- Panel 3: Rank and Deficiency Info ---
    ax3 = axes[2]
    ax3.axis('off')
    
    rank = np.linalg.matrix_rank(Gamma)
    n_species = len(species)
    n_reactions = len(reactions)
    n_conservation = conservation.shape[1]
    
    info_text = f"""
    ALGEBRAIC INVARIANTS
    ━━━━━━━━━━━━━━━━━━━
    
    Species (n):          {n_species}
    Reactions (r):        {n_reactions}
    
    Stoichiometric rank:  {rank}
    dim(ker Γᵀ):          {n_conservation}
    
    Rank-Nullity Check:
      n = rank + nullity
      {n_species} = {rank} + {n_conservation}  ✓
    
    Conservation laws
    preserve {n_conservation} independent
    linear combinations of
    concentrations.
    
    The stoichiometric
    subspace has dimension {rank},
    so dynamics are confined
    to {rank}-dimensional affine
    subspaces of ℝⁿ.
    """
    
    ax3.text(0.1, 0.95, info_text, transform=ax3.transAxes, fontsize=11,
            verticalalignment='top', fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    ax3.set_title('Algebraic Summary', fontsize=13, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig(f'output/{filename}', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: output/{filename}")


# ============================================================
# EXAMPLE 1: Hydrogen Combustion
# ============================================================
species_1 = ['H₂', 'O₂', 'H₂O']
reactions_1 = [
    {'reactants': {'H₂': 2, 'O₂': 1}, 'products': {'H₂O': 2}},
]
reaction_names_1 = ['2H₂+O₂→2H₂O']

plot_stoichiometric_analysis(species_1, reactions_1, reaction_names_1,
                             'Hydrogen Combustion', 'stoich_hydrogen.png')


# ============================================================
# EXAMPLE 2: Glycolysis (simplified)
# ============================================================
species_2 = ['Glucose', 'ATP', 'ADP', 'Pyruvate', 'NADH', 'NAD⁺']
reactions_2 = [
    # Glucose + 2ATP → 2G3P + 2ADP (investment phase, simplified)
    {'reactants': {'Glucose': 1, 'ATP': 2}, 'products': {'ADP': 2, 'Pyruvate': 1, 'NADH': 1}},
    # Payoff: G3P → Pyruvate + ATP + NADH (simplified)
    {'reactants': {'ADP': 1, 'NAD⁺': 1}, 'products': {'ATP': 1, 'NADH': 1, 'Pyruvate': 1}},
]
reaction_names_2 = ['Investment', 'Payoff']

plot_stoichiometric_analysis(species_2, reactions_2, reaction_names_2,
                             'Glycolysis (Simplified)', 'stoich_glycolysis.png')


# ============================================================
# EXAMPLE 3: Lotka-Volterra (as chemical reactions)
# ============================================================
species_3 = ['A', 'X', 'Y', 'B', 'C']
reactions_3 = [
    # A + X → 2X  (prey reproduction with resource)
    {'reactants': {'A': 1, 'X': 1}, 'products': {'X': 2}},
    # X + Y → 2Y  (predation)
    {'reactants': {'X': 1, 'Y': 1}, 'products': {'Y': 2}},
    # Y → B       (predator death)
    {'reactants': {'Y': 1}, 'products': {'B': 1}},
]
reaction_names_3 = ['A+X→2X', 'X+Y→2Y', 'Y→B']

plot_stoichiometric_analysis(species_3, reactions_3, reaction_names_3,
                             'Lotka-Volterra as Chemistry', 'stoich_lotka.png')


# ============================================================
# VISUALIZATION: Stoichiometric Compatibility Class (Polytope)
# ============================================================
def plot_compatibility_class():
    """
    Visualize the stoichiometric compatibility class for a simple system.
    
    For the reaction A ⇌ B ⇌ C:
    - Conservation law: [A] + [B] + [C] = const
    - The dynamics are confined to a 2-simplex (triangle) in 3D concentration space
    """
    fig = plt.figure(figsize=(12, 5))
    
    # 3D simplex
    ax1 = fig.add_subplot(121, projection='3d')
    
    # The simplex vertices (conservation: a + b + c = 1)
    vertices = np.array([
        [1, 0, 0],  # pure A
        [0, 1, 0],  # pure B
        [0, 0, 1],  # pure C
    ])
    
    # Draw simplex edges
    for i in range(3):
        for j in range(i+1, 3):
            ax1.plot3D(*zip(vertices[i], vertices[j]), 'b-', linewidth=2, alpha=0.7)
    
    # Fill the simplex (triangle)
    from mpl_toolkits.mplot3d.art3d import Poly3DCollection
    triangle = Poly3DCollection([vertices], alpha=0.2, facecolor='cyan', edgecolor='blue')
    ax1.add_collection3d(triangle)
    
    # Sample trajectory on the simplex
    t = np.linspace(0, 20, 500)
    # Simulate A ⇌ B ⇌ C with rates k₁=1, k₋₁=0.5, k₂=0.3, k₋₂=0.2
    from scipy.integrate import odeint
    
    def rate_eqns(y, t):
        a, b, c = y
        da = -1.0*a + 0.5*b
        db = 1.0*a - 0.5*b - 0.3*b + 0.2*c
        dc = 0.3*b - 0.2*c
        return [da, db, dc]
    
    y0 = [0.9, 0.05, 0.05]
    sol = odeint(rate_eqns, y0, t)
    
    ax1.plot3D(sol[:, 0], sol[:, 1], sol[:, 2], 'r-', linewidth=2, label='Trajectory')
    ax1.scatter(*y0, color='green', s=100, zorder=5, label='Start')
    ax1.scatter(*sol[-1], color='red', s=100, zorder=5, marker='*', label='Equilibrium')
    
    ax1.set_xlabel('[A]', fontsize=11)
    ax1.set_ylabel('[B]', fontsize=11)
    ax1.set_zlabel('[C]', fontsize=11)
    ax1.set_title('Stoichiometric Compatibility Class\n(Trajectory on the Simplex)', fontsize=12, fontweight='bold')
    ax1.legend(fontsize=9)
    
    # 2D projection: ternary-like plot
    ax2 = fig.add_subplot(122)
    
    ax2.plot(sol[:, 0], sol[:, 1], 'r-', linewidth=2, label='Trajectory')
    ax2.scatter(y0[0], y0[1], color='green', s=100, zorder=5, label='Start')
    ax2.scatter(sol[-1, 0], sol[-1, 1], color='red', s=100, zorder=5, marker='*', label='Equilibrium')
    
    # Draw the simplex boundary in 2D projection
    # a + b ≤ 1, a ≥ 0, b ≥ 0
    simplex_x = [0, 1, 0, 0]
    simplex_y = [0, 0, 1, 0]
    ax2.plot(simplex_x, simplex_y, 'b-', linewidth=2, alpha=0.5)
    ax2.fill(simplex_x, simplex_y, alpha=0.1, color='cyan')
    
    # Multiple trajectories from different initial conditions
    for a0 in [0.1, 0.3, 0.5, 0.7]:
        for b0 in [0.1, 0.3, 0.5]:
            c0 = 1.0 - a0 - b0
            if c0 > 0:
                sol2 = odeint(rate_eqns, [a0, b0, c0], t)
                ax2.plot(sol2[:, 0], sol2[:, 1], '-', linewidth=0.8, alpha=0.4, color='gray')
                ax2.scatter(a0, b0, color='green', s=20, alpha=0.5)
    
    ax2.set_xlabel('[A]', fontsize=12)
    ax2.set_ylabel('[B]', fontsize=12)
    ax2.set_title('Phase Portrait on Compatibility Class\n([A] + [B] + [C] = 1)', fontsize=12, fontweight='bold')
    ax2.legend(fontsize=9)
    ax2.set_xlim(-0.05, 1.05)
    ax2.set_ylim(-0.05, 1.05)
    ax2.set_aspect('equal')
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('output/compatibility_class.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: output/compatibility_class.png")

plot_compatibility_class()


# ============================================================
# VISUALIZATION: Network Deficiency Computation
# ============================================================
def plot_deficiency_examples():
    """Compute and visualize deficiency for several reaction networks."""
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Reaction Network Deficiency: The Master Algebraic Invariant', 
                 fontsize=16, fontweight='bold')
    
    networks = [
        {
            'name': 'A ⇌ B ⇌ C',
            'species': ['A', 'B', 'C'],
            'complexes': ['A', 'B', 'C'],
            'reactions': [('A', 'B'), ('B', 'A'), ('B', 'C'), ('C', 'B')],
            'stoich_reactions': [
                {'reactants': {'A': 1}, 'products': {'B': 1}},
                {'reactants': {'B': 1}, 'products': {'C': 1}},
            ],
            'linkage_classes': 1,
        },
        {
            'name': '2A → B, B → 2A',
            'species': ['A', 'B'],
            'complexes': ['2A', 'B'],
            'reactions': [('2A', 'B'), ('B', '2A')],
            'stoich_reactions': [
                {'reactants': {'A': 2}, 'products': {'B': 1}},
            ],
            'linkage_classes': 1,
        },
        {
            'name': 'Michaelis-Menten\nE+S ⇌ ES → E+P',
            'species': ['E', 'S', 'ES', 'P'],
            'complexes': ['E+S', 'ES', 'E+P'],
            'reactions': [('E+S', 'ES'), ('ES', 'E+S'), ('ES', 'E+P')],
            'stoich_reactions': [
                {'reactants': {'E': 1, 'S': 1}, 'products': {'ES': 1}},
                {'reactants': {'ES': 1}, 'products': {'E': 1, 'P': 1}},
            ],
            'linkage_classes': 1,
        },
        {
            'name': 'A → B, C → D\n(Two independent reactions)',
            'species': ['A', 'B', 'C', 'D'],
            'complexes': ['A', 'B', 'C', 'D'],
            'reactions': [('A', 'B'), ('C', 'D')],
            'stoich_reactions': [
                {'reactants': {'A': 1}, 'products': {'B': 1}},
                {'reactants': {'C': 1}, 'products': {'D': 1}},
            ],
            'linkage_classes': 2,
        },
    ]
    
    for idx, net in enumerate(networks):
        ax = axes[idx // 2][idx % 2]
        
        Gamma = build_stoichiometric_matrix(net['species'], net['stoich_reactions'])
        s = np.linalg.matrix_rank(Gamma)
        n_complexes = len(net['complexes'])
        ell = net['linkage_classes']
        delta = n_complexes - ell - s
        
        # Draw the reaction graph
        ax.set_xlim(-0.5, 3.5)
        ax.set_ylim(-0.5, 2.5)
        
        # Position complexes in a circle
        n_c = len(net['complexes'])
        angles = np.linspace(0, 2*np.pi, n_c, endpoint=False)
        cx = 1.5 + 1.2 * np.cos(angles + np.pi/2)
        cy = 1.5 + 0.8 * np.sin(angles + np.pi/2)
        
        # Draw complexes
        for i, (x, y, name) in enumerate(zip(cx, cy, net['complexes'])):
            circle = plt.Circle((x, y), 0.3, fill=True, facecolor='lightblue', 
                              edgecolor='navy', linewidth=2)
            ax.add_patch(circle)
            ax.text(x, y, name, ha='center', va='center', fontsize=9, fontweight='bold')
        
        # Draw reaction arrows
        complex_pos = {name: (x, y) for name, x, y in zip(net['complexes'], cx, cy)}
        for src, tgt in net['reactions']:
            x1, y1 = complex_pos[src]
            x2, y2 = complex_pos[tgt]
            dx, dy = x2 - x1, y2 - y1
            dist = np.sqrt(dx**2 + dy**2)
            # Shorten arrow to not overlap circles
            shrink = 0.35 / dist if dist > 0 else 0
            ax.annotate('', xy=(x2 - dx*shrink, y2 - dy*shrink), 
                       xytext=(x1 + dx*shrink, y1 + dy*shrink),
                       arrowprops=dict(arrowstyle='->', color='red', lw=2))
        
        # Deficiency info box
        color = 'green' if delta == 0 else ('orange' if delta == 1 else 'red')
        info = f'|C|={n_c}  ℓ={ell}  s={s}\nδ = {n_c}-{ell}-{s} = {delta}'
        ax.text(0.02, 0.02, info, transform=ax.transAxes, fontsize=11,
               verticalalignment='bottom', fontfamily='monospace',
               bbox=dict(boxstyle='round', facecolor=color, alpha=0.3))
        
        ax.set_title(net['name'], fontsize=12, fontweight='bold')
        ax.set_aspect('equal')
        ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('output/deficiency_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: output/deficiency_analysis.png")

plot_deficiency_examples()

print("\n✅ Demo 1 Complete: Stoichiometric Algebra")
print("=" * 50)
print("Key results:")
print("• Stoichiometric matrix Γ captures all reaction structure")
print("• Conservation laws = ker(Γᵀ)")  
print("• Rank-nullity theorem ↔ balance of constraints and freedoms")
print("• Deficiency δ = |C| - ℓ - s is the master algebraic invariant")
print("• Dynamics confined to stoichiometric compatibility classes (polytopes)")
