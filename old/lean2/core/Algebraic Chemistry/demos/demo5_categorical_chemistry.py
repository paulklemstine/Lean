#!/usr/bin/env python3
"""
Demo 5: Categorical Chemistry — The Grand Unification
=======================================================

This demo visualizes chemistry as a symmetric monoidal category,
showing how reactions, conservation laws, and catalysis have natural
categorical descriptions.

Part of "The Algebraic Theory of Chemistry" project.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Circle
import os

os.makedirs("output", exist_ok=True)


def plot_chemcat_diagram():
    """Visualize ChemCat: the category of chemical reactions."""
    
    fig, axes = plt.subplots(2, 2, figsize=(18, 14))
    fig.suptitle('ChemCat: Chemistry as a Symmetric Monoidal Category', 
                 fontsize=18, fontweight='bold')
    
    # --- Panel 1: Objects and Morphisms ---
    ax1 = axes[0][0]
    ax1.set_xlim(-1, 11)
    ax1.set_ylim(-1, 7)
    
    # Objects (chemical species as nodes)
    objects = {
        'H₂': (1, 5),
        'O₂': (3, 5),
        'H₂O': (5, 5),
        'CO₂': (7, 5),
        'CH₄': (9, 5),
        '2H₂+O₂': (2, 3),
        '2H₂O': (5, 3),
        'CH₄+2O₂': (8, 1),
        'CO₂+2H₂O': (5, 1),
    }
    
    for name, (x, y) in objects.items():
        is_complex = '+' in name or name[0].isdigit()
        color = '#FFE0B2' if is_complex else '#BBDEFB'
        rect = FancyBboxPatch((x-0.8, y-0.3), 1.6, 0.6,
                              boxstyle="round,pad=0.1",
                              facecolor=color, edgecolor='navy', linewidth=1.5)
        ax1.add_patch(rect)
        ax1.text(x, y, name, ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Morphisms (reactions as arrows)
    morphisms = [
        ('2H₂+O₂', '2H₂O', 'combustion'),
        ('CH₄+2O₂', 'CO₂+2H₂O', 'combustion'),
    ]
    
    for src, tgt, label in morphisms:
        x1, y1 = objects[src]
        x2, y2 = objects[tgt]
        ax1.annotate('', xy=(x2, y2+0.35), xytext=(x1, y1-0.35),
                    arrowprops=dict(arrowstyle='->', color='red', lw=2.5,
                                   connectionstyle='arc3,rad=0.1'))
        mx, my = (x1+x2)/2, (y1+y2)/2
        ax1.text(mx+0.3, my, label, fontsize=8, color='red', fontstyle='italic')
    
    ax1.set_title('Objects = Species/Complexes\nMorphisms = Reactions', 
                  fontsize=13, fontweight='bold')
    ax1.axis('off')
    
    # --- Panel 2: Tensor Product (Monoidal Structure) ---
    ax2 = axes[0][1]
    ax2.set_xlim(-1, 11)
    ax2.set_ylim(-1, 5)
    
    # Show A ⊗ B = A + B (mixing)
    boxes = [
        ('A', 1, 3.5, '#BBDEFB'),
        ('⊗', 3, 3.5, 'white'),
        ('B', 5, 3.5, '#C8E6C9'),
        ('=', 7, 3.5, 'white'),
        ('A + B', 9, 3.5, '#FFF9C4'),
    ]
    
    for text, x, y, color in boxes:
        if text in ['⊗', '=']:
            ax2.text(x, y, text, ha='center', va='center', fontsize=20, fontweight='bold')
        else:
            rect = FancyBboxPatch((x-0.8, y-0.3), 1.6, 0.6,
                                  boxstyle="round,pad=0.1",
                                  facecolor=color, edgecolor='navy', linewidth=1.5)
            ax2.add_patch(rect)
            ax2.text(x, y, text, ha='center', va='center', fontsize=11, fontweight='bold')
    
    # Example
    ax2.text(5, 2, 'Example: H₂ ⊗ H₂ ⊗ O₂ = 2H₂ + O₂', 
            ha='center', fontsize=11, fontstyle='italic',
            bbox=dict(boxstyle='round', facecolor='lightyellow'))
    
    # Properties
    props = [
        'Associative: (A⊗B)⊗C = A⊗(B⊗C)',
        'Commutative: A⊗B ≅ B⊗A (symmetric)',
        'Unit: A⊗∅ = A (empty mixture)',
    ]
    for i, prop in enumerate(props):
        ax2.text(5, 0.8 - i*0.5, prop, ha='center', fontsize=9, fontfamily='monospace',
                bbox=dict(boxstyle='round', facecolor='#E8F5E9', alpha=0.5))
    
    ax2.set_title('Monoidal Structure: ⊗ = Mixing\n(Symmetric monoidal category)', 
                  fontsize=13, fontweight='bold')
    ax2.axis('off')
    
    # --- Panel 3: Functors (Conservation Laws) ---
    ax3 = axes[1][0]
    ax3.set_xlim(-1, 11)
    ax3.set_ylim(-1, 7)
    
    # ChemCat → ℤ functors
    ax3.text(3, 6, 'ChemCat', ha='center', fontsize=16, fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='#BBDEFB', edgecolor='navy', linewidth=2))
    
    targets = [
        ('Mass: → ℝ₊', 1, 4, '#FFE0B2'),
        ('Charge: → ℤ', 3, 4, '#C8E6C9'),
        ('Atoms: → ℕᴱ', 5, 4, '#E1BEE7'),
        ('Kinetics: → DynSys', 3, 2, '#FFCCBC'),
        ('Thermo: → ConvCone', 7, 4, '#B2EBF2'),
    ]
    
    for label, x, y, color in targets:
        rect = FancyBboxPatch((x-1.2, y-0.3), 2.4, 0.6,
                              boxstyle="round,pad=0.1",
                              facecolor=color, edgecolor='black', linewidth=1)
        ax3.add_patch(rect)
        ax3.text(x, y, label, ha='center', va='center', fontsize=8, fontweight='bold')
        
        # Arrow from ChemCat
        ax3.annotate('', xy=(x, y+0.35), xytext=(3, 5.7),
                    arrowprops=dict(arrowstyle='->', color='darkblue', lw=1.5,
                                   connectionstyle='arc3,rad=0.2'))
    
    ax3.text(8, 2, 'Each functor is a\nconservation law:\n\n'
            'F(A → B) means\nF(A) = F(B)\n\n'
            'Mass, charge, and\natom counts are all\npreserved by every\nmorphism (reaction).',
            fontsize=9, fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    
    ax3.set_title('Functors = Conservation Laws\n(Natural transformations to abelian groups)', 
                  fontsize=13, fontweight='bold')
    ax3.axis('off')
    
    # --- Panel 4: Catalysis as Endofunctor ---
    ax4 = axes[1][1]
    ax4.set_xlim(-1, 11)
    ax4.set_ylim(-1, 7)
    
    # Show catalyzed reaction
    # Without catalyst: A + B → C (slow or impossible)
    # With catalyst E: A + B + E → C + E (fast)
    
    # Uncatalyzed
    ax4.text(2, 6, 'Without Catalyst:', fontsize=11, fontweight='bold', color='gray')
    for text, x, y in [('A + B', 1, 5), ('C', 4, 5)]:
        rect = FancyBboxPatch((x-0.7, y-0.3), 1.4, 0.6,
                              boxstyle="round,pad=0.1",
                              facecolor='#FFCDD2', edgecolor='gray', linewidth=1)
        ax4.add_patch(rect)
        ax4.text(x, y, text, ha='center', va='center', fontsize=10, fontweight='bold')
    ax4.annotate('', xy=(3.3, 5), xytext=(1.7, 5),
                arrowprops=dict(arrowstyle='->', color='gray', lw=2, linestyle='dashed'))
    ax4.text(2.5, 5.3, 'slow', fontsize=9, color='gray', fontstyle='italic')
    
    # Catalyzed
    ax4.text(2, 3.8, 'With Catalyst E:', fontsize=11, fontweight='bold', color='darkgreen')
    
    steps = [
        ('A+B+E', 1, 2.5, '#C8E6C9'),
        ('A·E+B', 3.5, 2.5, '#C8E6C9'),
        ('C·E', 6, 2.5, '#C8E6C9'),
        ('C + E', 8.5, 2.5, '#C8E6C9'),
    ]
    for text, x, y, color in steps:
        rect = FancyBboxPatch((x-0.8, y-0.3), 1.6, 0.6,
                              boxstyle="round,pad=0.1",
                              facecolor=color, edgecolor='darkgreen', linewidth=1.5)
        ax4.add_patch(rect)
        ax4.text(x, y, text, ha='center', va='center', fontsize=8, fontweight='bold')
    
    for i in range(len(steps)-1):
        x1 = steps[i][1] + 0.8
        x2 = steps[i+1][1] - 0.8
        ax4.annotate('', xy=(x2, 2.5), xytext=(x1, 2.5),
                    arrowprops=dict(arrowstyle='->', color='darkgreen', lw=2))
    
    # Categorical interpretation
    ax4.text(5, 0.5, 'Catalysis = Endofunctor T: ChemCat → ChemCat\n'
            'T(X) = X ⊗ E   (add catalyst)\n'
            'T preserves all conservation laws (natural transformation)\n'
            'E is recovered: T factors through the identity on E',
            ha='center', fontsize=9, fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))
    
    ax4.set_title('Catalysis as an Endofunctor\n(Structure-preserving self-map of ChemCat)', 
                  fontsize=13, fontweight='bold')
    ax4.axis('off')
    
    plt.tight_layout()
    plt.savefig('output/categorical_chemistry.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: output/categorical_chemistry.png")


def plot_commutative_diagrams():
    """Draw commutative diagrams expressing chemical laws categorically."""
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle('Commutative Diagrams in Algebraic Chemistry', 
                 fontsize=16, fontweight='bold')
    
    # --- Diagram 1: Conservation Law as Natural Transformation ---
    ax1 = axes[0]
    ax1.set_xlim(-1, 7)
    ax1.set_ylim(-1, 5)
    
    nodes = {
        'A': (1, 4), 'B': (5, 4),
        'F(A)': (1, 1), 'F(B)': (5, 1),
    }
    
    for name, (x, y) in nodes.items():
        color = '#BBDEFB' if 'F' not in name else '#C8E6C9'
        rect = FancyBboxPatch((x-0.6, y-0.3), 1.2, 0.6,
                              boxstyle="round,pad=0.1",
                              facecolor=color, edgecolor='black', linewidth=1.5)
        ax1.add_patch(rect)
        ax1.text(x, y, name, ha='center', va='center', fontsize=12, fontweight='bold')
    
    # Arrows
    # A → B (reaction)
    ax1.annotate('', xy=(4.4, 4), xytext=(1.6, 4),
                arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ax1.text(3, 4.3, 'ρ (reaction)', fontsize=9, ha='center', color='red')
    
    # F(A) → F(B)
    ax1.annotate('', xy=(4.4, 1), xytext=(1.6, 1),
                arrowprops=dict(arrowstyle='->', color='blue', lw=2))
    ax1.text(3, 0.6, 'F(ρ)', fontsize=9, ha='center', color='blue')
    
    # A → F(A), B → F(B)
    ax1.annotate('', xy=(1, 1.35), xytext=(1, 3.65),
                arrowprops=dict(arrowstyle='->', color='green', lw=2))
    ax1.text(0.4, 2.5, 'η_A', fontsize=9, color='green')
    
    ax1.annotate('', xy=(5, 1.35), xytext=(5, 3.65),
                arrowprops=dict(arrowstyle='->', color='green', lw=2))
    ax1.text(5.4, 2.5, 'η_B', fontsize=9, color='green')
    
    ax1.text(3, -0.5, 'Conservation Law:\nF(ρ) ∘ η_A = η_B ∘ ρ\n'
            '(e.g., mass(reactants) = mass(products))',
            ha='center', fontsize=8, fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='lightyellow'))
    
    ax1.set_title('Conservation as\nNatural Transformation', fontsize=12, fontweight='bold')
    ax1.axis('off')
    
    # --- Diagram 2: Monoidal Functor (Mass is multiplicative) ---
    ax2 = axes[1]
    ax2.set_xlim(-1, 7)
    ax2.set_ylim(-1, 5)
    
    nodes2 = {
        'A⊗B': (1, 4), 'F(A⊗B)': (5, 4),
        'F(A)⊗F(B)': (3, 1),
    }
    
    for name, (x, y) in nodes2.items():
        w = max(1.2, len(name) * 0.13)
        color = '#BBDEFB' if '⊗' in name and 'F' not in name else '#E1BEE7'
        rect = FancyBboxPatch((x-w, y-0.3), 2*w, 0.6,
                              boxstyle="round,pad=0.1",
                              facecolor=color, edgecolor='black', linewidth=1.5)
        ax2.add_patch(rect)
        ax2.text(x, y, name, ha='center', va='center', fontsize=10, fontweight='bold')
    
    # F(A⊗B) = F(A)⊗F(B) arrow
    ax2.annotate('', xy=(4, 1.3), xytext=(5, 3.65),
                arrowprops=dict(arrowstyle='->', color='purple', lw=2))
    ax2.text(5, 2.5, '≅', fontsize=14, color='purple', fontweight='bold')
    
    ax2.annotate('', xy=(2.2, 1.3), xytext=(1, 3.65),
                arrowprops=dict(arrowstyle='->', color='blue', lw=2))
    ax2.text(0.8, 2.5, 'F', fontsize=12, color='blue', fontweight='bold')
    
    ax2.text(3, -0.5, 'Monoidal Functor:\nMass(A⊗B) = Mass(A) + Mass(B)\n'
            '(Mass is additive over mixing)',
            ha='center', fontsize=8, fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='lightyellow'))
    
    ax2.set_title('Monoidal Functor\n(Additive Conservation)', fontsize=12, fontweight='bold')
    ax2.axis('off')
    
    # --- Diagram 3: Equilibrium as Terminal Object ---
    ax3 = axes[2]
    ax3.set_xlim(-1, 7)
    ax3.set_ylim(-1, 5)
    
    # Multiple initial states → unique equilibrium
    eq_x, eq_y = 3, 1
    circle = plt.Circle((eq_x, eq_y), 0.5, facecolor='gold', edgecolor='darkred', 
                        linewidth=3, zorder=5)
    ax3.add_patch(circle)
    ax3.text(eq_x, eq_y, 'x*\n(eq.)', ha='center', va='center', fontsize=9, fontweight='bold')
    
    initial_states = [
        ('x₁', 0.5, 4),
        ('x₂', 2, 4.5),
        ('x₃', 4, 4.5),
        ('x₄', 5.5, 4),
        ('x₅', 1, 3),
        ('x₆', 5, 3),
    ]
    
    colors = plt.cm.Set2(np.linspace(0, 1, len(initial_states)))
    for i, (name, x, y) in enumerate(initial_states):
        rect = FancyBboxPatch((x-0.4, y-0.25), 0.8, 0.5,
                              boxstyle="round,pad=0.05",
                              facecolor=colors[i], edgecolor='black', linewidth=1)
        ax3.add_patch(rect)
        ax3.text(x, y, name, ha='center', va='center', fontsize=9)
        
        # Arrow to equilibrium
        dx, dy = eq_x - x, eq_y - y
        dist = np.sqrt(dx**2 + dy**2)
        shrink = 0.5 / dist
        ax3.annotate('', xy=(eq_x - dx*shrink, eq_y - dy*shrink),
                    xytext=(x + dx*0.3, y + dy*0.3),
                    arrowprops=dict(arrowstyle='->', color=colors[i], lw=1.5,
                                   connectionstyle='arc3,rad=0.2'))
    
    ax3.text(3, -0.5, 'Equilibrium as Terminal Object:\n∀ initial state x₀, ∃! morphism x₀ → x*\n'
            '(Deficiency Zero Theorem)',
            ha='center', fontsize=8, fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='lightyellow'))
    
    ax3.set_title('Equilibrium as\nTerminal Object', fontsize=12, fontweight='bold')
    ax3.axis('off')
    
    plt.tight_layout()
    plt.savefig('output/commutative_diagrams.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: output/commutative_diagrams.png")


def plot_grand_synthesis():
    """Create the grand unification diagram showing how all branches connect."""
    
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(-2, 14)
    ax.set_ylim(-2, 12)
    
    ax.set_title('The Grand Synthesis: All of Chemistry is Algebra', 
                 fontsize=18, fontweight='bold')
    
    # Central hub
    hub_x, hub_y = 6, 6
    hub = plt.Circle((hub_x, hub_y), 1.5, facecolor='gold', edgecolor='darkred', 
                     linewidth=3, zorder=10)
    ax.add_patch(hub)
    ax.text(hub_x, hub_y+0.3, 'ChemCat', ha='center', va='center', 
           fontsize=16, fontweight='bold', zorder=11)
    ax.text(hub_x, hub_y-0.3, '(Symmetric Monoidal\nCategory)', ha='center', va='center', 
           fontsize=8, zorder=11)
    
    # Satellite domains
    satellites = [
        ('Stoichiometric\nAlgebra', 1, 10, '#BBDEFB', 'Γ ∈ ℤⁿˣʳ\nker(Γᵀ) = conservation'),
        ('Group Theory\n(Symmetry)', 6, 11, '#C8E6C9', 'Point groups ≤ O(3)\nCharacter tables'),
        ('Reaction\nKinetics', 11, 10, '#FFE0B2', 'dx/dt = Γ·v(x)\nPolynomial dynamics'),
        ('Thermodynamic\nAlgebra', 11.5, 5, '#E1BEE7', 'Legendre duality\nGibbs phase rule'),
        ('Bond\nAlgebra', 11, 1.5, '#FFCCBC', 'Molecular graphs\nMO theory as functor'),
        ('Periodic Table\nAlgebra', 6, 0.5, '#B2EBF2', 'Quantum lattice ℕ⁴\nMadelung order'),
        ('Algebraic\nGeometry', 0.5, 5, '#F0F4C3', 'Equilibrium =\nalgebraic variety'),
        ('Homological\nAlgebra', 1, 1.5, '#FFCDD2', 'Resonance =\nH₁(molecular graph)'),
    ]
    
    for name, x, y, color, detail in satellites:
        rect = FancyBboxPatch((x-1.3, y-0.7), 2.6, 1.4,
                              boxstyle="round,pad=0.15",
                              facecolor=color, edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        ax.text(x, y+0.15, name, ha='center', va='center', fontsize=10, fontweight='bold')
        ax.text(x, y-0.4, detail, ha='center', va='center', fontsize=6, 
               fontstyle='italic', color='gray')
        
        # Arrow to hub
        dx, dy = hub_x - x, hub_y - y
        dist = np.sqrt(dx**2 + dy**2)
        shrink_start = 1.3 / dist
        shrink_end = 1.5 / dist
        ax.annotate('', 
                   xy=(hub_x - dx*shrink_end, hub_y - dy*shrink_end),
                   xytext=(x + dx*shrink_start, y + dy*shrink_start),
                   arrowprops=dict(arrowstyle='<->', color='darkblue', lw=2,
                                  connectionstyle='arc3,rad=0.1'))
    
    # Add axiom box
    axiom_text = """The Five Axioms of Algebraic Chemistry:
1. Species form a commutative monoid (ℕˢ)
2. Reactions are morphisms (source → target)
3. Conservation laws are natural transformations
4. Equilibrium maximizes entropy on a polytope
5. Identical species are interchangeable (symmetry)"""
    
    ax.text(6, -1.5, axiom_text, ha='center', fontsize=8, fontfamily='monospace',
           bbox=dict(boxstyle='round', facecolor='lightyellow', edgecolor='darkgoldenrod',
                    linewidth=2, alpha=0.9))
    
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('output/grand_synthesis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: output/grand_synthesis.png")


# Run all visualizations
plot_chemcat_diagram()
plot_commutative_diagrams()
plot_grand_synthesis()

print("\n✅ Demo 5 Complete: Categorical Chemistry")
print("=" * 50)
print("Key results:")
print("• Chemistry IS a symmetric monoidal category (ChemCat)")
print("• Conservation laws are natural transformations (functors to ℤ, ℝ)")
print("• Catalysis is an endofunctor on ChemCat")
print("• Equilibrium is a terminal object in the dynamics category")
print("• All branches of theoretical chemistry are functorial images of ChemCat")
