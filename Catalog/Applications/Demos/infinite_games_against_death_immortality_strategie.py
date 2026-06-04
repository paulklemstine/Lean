#!/usr/bin/env python3
"""
Infinite Games Against Death: Mortal vs. Eternity
==================================================
Demonstrates the ordinal survival hierarchy:
- fullProfile → survival ω
- boundedProfile(k) → survival k < ω
- nestedFamily(d) → survival ≥ ω^d
- ascending family → survival ω
"""

import math
from typing import List, Tuple, Optional


def survival_ordinal_display(profile_type: str, param: int = 0) -> str:
    """Display the survival ordinal for a given profile type."""
    if profile_type == "full":
        return "ω (omega)"
    elif profile_type == "bounded":
        return f"{param} < ω"
    elif profile_type == "empty":
        return "0"
    elif profile_type == "nested":
        if param == 0:
            return "ω"
        elif param == 1:
            return "ω (nested level 1)"
        else:
            return f"≥ ω (nested level {param})"
    elif profile_type == "ascending":
        return "ω"
    return "unknown"


def simulate_mortal_vs_eternity(
    mortal_depth: int,
    eternity_branching: int,
    rounds: int = 20
) -> List[Tuple[int, str, str]]:
    """
    Simulate a game between Mortal (depth-limited) and Eternity.
    
    Returns a trace of (round, mortal_action, eternity_action).
    """
    trace = []
    mortal_resource = mortal_depth
    
    for r in range(1, rounds + 1):
        if mortal_resource <= 0:
            trace.append((r, "DEAD", ""))
            break
        
        # Mortal plays: spend 1 resource to survive
        mortal_action = f"defend(depth={mortal_resource})"
        
        # Eternity plays: attack with branching factor
        # Eternity's best strategy: deplete fastest resource
        eternity_action = f"attack(branch={eternity_branching})"
        mortal_resource -= 1
        
        trace.append((r, mortal_action, eternity_action))
    
    return trace


def demonstrate_survival_profiles():
    """Demonstrate the survival ordinal hierarchy."""
    print("=" * 60)
    print("SURVIVAL PROFILE HIERARCHY")
    print("=" * 60)
    
    profiles = [
        ("Empty Profile", "empty", 0),
        ("Bounded Profile (k=5)", "bounded", 5),
        ("Bounded Profile (k=100)", "bounded", 100),
        ("Full Profile", "full", 0),
        ("Ascending Family", "ascending", 0),
        ("Nested Family (d=0)", "nested", 0),
        ("Nested Family (d=1)", "nested", 1),
        ("Nested Family (d=2)", "nested", 2),
        ("Nested Family (d=5)", "nested", 5),
    ]
    
    print(f"\n{'Profile':<30} {'Survival Ordinal':<25} {'Is Full?':<10}")
    print("-" * 65)
    
    for name, ptype, param in profiles:
        ordinal = survival_ordinal_display(ptype, param)
        is_full = ptype in ("full", "ascending") or ptype == "nested"
        print(f"{name:<30} {ordinal:<25} {'Yes' if is_full else 'No':<10}")
    
    print("\n" + "=" * 60)
    print("KEY THEOREM: survival ≥ ω ⟺ profile is full")
    print("=" * 60)


def demonstrate_sequential_composition():
    """Show how sequential composition works."""
    print("\n" + "=" * 60)
    print("SEQUENTIAL COMPOSITION")
    print("=" * 60)
    
    # seq(P, Q) can survive a+b if P survives a and Q survives b
    examples = [
        ("bounded(3) ∘ bounded(4)", 3, 4, 7),
        ("bounded(10) ∘ bounded(20)", 10, 20, 30),
        ("full ∘ full", "∞", "∞", "∞"),
        ("full ∘ empty", "∞", 0, "∞"),
    ]
    
    print(f"\n{'Composition':<30} {'P survives':<12} {'Q survives':<12} {'P∘Q survives':<12}")
    print("-" * 66)
    for name, a, b, total in examples:
        print(f"{name:<30} {str(a):<12} {str(b):<12} {str(total):<12}")


def demonstrate_ordinal_arithmetic():
    """Show ordinal arithmetic relevant to survival hierarchy."""
    print("\n" + "=" * 60)
    print("ORDINAL ARITHMETIC OF SURVIVAL")
    print("=" * 60)
    
    computations = [
        ("sup{n : ℕ}", "ω"),
        ("ω + ω", "ω·2"),
        ("ω · k (k finite)", "ω·k"),
        ("sup{ω·n : n ∈ ℕ}", "ω²"),
        ("ω^d (d finite)", "ω^d"),
        ("sup{ω^d : d ∈ ℕ}", "ω^ω"),
    ]
    
    print(f"\n{'Expression':<30} {'Result':<20}")
    print("-" * 50)
    for expr, result in computations:
        print(f"{expr:<30} {result:<20}")
    
    print("\nInterpretation:")
    print("  • Deterministic Mortal with arbitrary depth: survival = ω")
    print("  • k sequential compositions of full profiles: survival = ω")
    print("  • Family of all bounded profiles: survival = ω")
    print("  • d-nested families: survival ≥ ω (for every d)")
    print("  • ITTM with d limit stages: computes at level ω^d")


def simulate_game_tree():
    """Simulate and visualize a simple game tree."""
    print("\n" + "=" * 60)
    print("GAME TREE SIMULATION")
    print("=" * 60)
    
    print("\nCountdown Game (initial state: 10)")
    print("Mortal decrements by 1. Eternity can set to any lower value.")
    
    trace = simulate_mortal_vs_eternity(mortal_depth=10, eternity_branching=3)
    
    print(f"\n{'Round':<8} {'Mortal':<25} {'Eternity':<25}")
    print("-" * 58)
    for r, m, e in trace:
        print(f"{r:<8} {m:<25} {e:<25}")
    
    print(f"\nMortal survived {len([t for t in trace if t[1] != 'DEAD'])} rounds")
    print(f"Bounded profile survival: {len([t for t in trace if t[1] != 'DEAD'])}")


def main():
    """Run all demonstrations."""
    print("╔" + "═" * 58 + "╗")
    print("║  INFINITE GAMES AGAINST DEATH: MORTAL vs. ETERNITY      ║")
    print("║  Ordinal Survival in Asymmetric Computation Games        ║")
    print("╚" + "═" * 58 + "╝")
    
    demonstrate_survival_profiles()
    demonstrate_sequential_composition()
    demonstrate_ordinal_arithmetic()
    simulate_game_tree()
    
    print("\n" + "=" * 60)
    print("ITTM CONNECTION")
    print("=" * 60)
    print("""
Infinite Time Turing Machines (ITTMs) extend Turing machines:
- At limit ordinal steps, tape = limsup of previous states
- ITTM Level 0: finite computation (< ω steps)
- ITTM Level 1: ω steps (one limit transition)
- ITTM Level d: ω^d steps (d limit transitions)

The survival hierarchy mirrors ITTM levels:
- boundedProfile(k) ↔ ITTM Level 0 (k computation steps)
- fullProfile        ↔ ITTM Level 1 (ω computation steps)
- nestedFamily(d)    ↔ ITTM Level d (ω^d computation steps)

CONJECTURE: For each ordinal α < ε₀, there exists a survival
profile with survival ordinal exactly α.
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Survival Ordinal Hierarchy
==========================================
Plots the survival ordinal landscape for different profile types.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_survival_hierarchy():
    """Plot the survival ordinal hierarchy."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    # Panel 1: Bounded vs Full profiles
    ax1 = axes[0]
    ks = list(range(1, 21))
    bounded_ords = ks  # survival ordinal = k for bounded(k)
    
    ax1.bar(ks, bounded_ords, color='steelblue', alpha=0.7, label='bounded(k)')
    ax1.axhline(y=20, color='crimson', linestyle='--', linewidth=2, label='ω (full profile)')
    ax1.set_xlabel('Bound k', fontsize=12)
    ax1.set_ylabel('Survival Ordinal', fontsize=12)
    ax1.set_title('Bounded Profiles vs ω', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.set_ylim(0, 25)
    ax1.annotate('ω = sup{k : k ∈ ℕ}', xy=(15, 20), xytext=(10, 23),
                fontsize=11, arrowprops=dict(arrowstyle='->', color='crimson'),
                color='crimson')
    
    # Panel 2: Sequential composition
    ax2 = axes[1]
    compositions = ['P⁰\n(empty)', 'P¹\n(full)', 'P²\n(full∘full)', 
                    'P³', 'P⁴', 'P⁵']
    survival = [0, 1, 1, 1, 1, 1]  # All ≥1 means ω
    colors = ['gray'] + ['crimson'] * 5
    
    bars = ax2.bar(range(len(compositions)), [0, 20, 20, 20, 20, 20], 
                   color=colors, alpha=0.7)
    bars[0].set_height(1)
    ax2.set_xticks(range(len(compositions)))
    ax2.set_xticklabels(compositions, fontsize=10)
    ax2.set_ylabel('Survival Ordinal', fontsize=12)
    ax2.set_title('Sequential Composition seqPow(full, k)', fontsize=14)
    ax2.set_ylim(0, 25)
    ax2.axhline(y=20, color='crimson', linestyle='--', linewidth=1, alpha=0.5)
    ax2.annotate('k=0: survival = 0', xy=(0, 1), xytext=(0.5, 5),
                fontsize=10, arrowprops=dict(arrowstyle='->', color='gray'))
    ax2.annotate('k≥1: survival = ω', xy=(3, 20), xytext=(2, 23),
                fontsize=11, color='crimson')
    
    # Panel 3: Nested hierarchy
    ax3 = axes[2]
    depths = list(range(6))
    # All nested families are full, so all have survival ≥ ω
    nested_heights = [20] * 6
    
    ax3.bar(depths, nested_heights, color='darkgreen', alpha=0.7)
    ax3.set_xlabel('Nesting Depth d', fontsize=12)
    ax3.set_ylabel('Survival Ordinal', fontsize=12)
    ax3.set_title('Nested Family Hierarchy', fontsize=14)
    ax3.set_ylim(0, 25)
    
    for d in depths:
        ax3.annotate(f'≥ω', xy=(d, 20), xytext=(d, 21.5),
                    fontsize=9, ha='center', color='darkgreen')
    
    ax3.axhline(y=20, color='crimson', linestyle='--', linewidth=1, alpha=0.5)
    
    plt.tight_layout()
    plt.savefig('survival_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: survival_hierarchy.png")


def plot_game_simulation():
    """Plot a simulated game between Mortal and Eternity."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Simulation: Mortal with different resource levels
    for initial in [5, 10, 20, 50]:
        rounds = list(range(initial + 1))
        resources = [max(0, initial - r) for r in rounds]
        ax1.plot(rounds, resources, 'o-', markersize=3, 
                label=f'resource={initial}', alpha=0.8)
    
    ax1.set_xlabel('Round', fontsize=12)
    ax1.set_ylabel('Remaining Resources', fontsize=12)
    ax1.set_title('Countdown Game: Mortal vs Eternity', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_ylim(-1, 55)
    ax1.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
    ax1.fill_between(range(51), 0, -1, alpha=0.1, color='red', label='Death zone')
    
    # Ordinal hierarchy visualization
    levels = ['0', '1', '2', '...', 'k', '...', 'ω', 'ω·2', '...', 'ω²', 'ω^ω']
    positions = list(range(len(levels)))
    colors_list = ['gray']*6 + ['crimson'] + ['orange']*2 + ['darkgreen'] + ['purple']
    sizes = [100]*6 + [200] + [150]*2 + [200] + [200]
    
    ax2.scatter(positions, [0]*len(positions), s=sizes, c=colors_list, 
               zorder=5, edgecolors='black', linewidth=0.5)
    for i, label in enumerate(positions):
        ax2.annotate(levels[i], xy=(i, 0), xytext=(i, 0.15),
                    fontsize=10, ha='center', fontweight='bold')
    
    ax2.set_xlim(-0.5, len(levels) - 0.5)
    ax2.set_ylim(-0.5, 0.5)
    ax2.set_title('Ordinal Number Line', fontsize=14)
    ax2.axhline(y=0, color='black', linewidth=0.5)
    ax2.set_yticks([])
    ax2.set_xticks([])
    
    # Brackets
    ax2.annotate('', xy=(0, -0.15), xytext=(5, -0.15),
                arrowprops=dict(arrowstyle='<->', color='steelblue', lw=2))
    ax2.text(2.5, -0.25, 'finite ordinals\n(bounded profiles)', 
            ha='center', fontsize=9, color='steelblue')
    
    ax2.annotate('', xy=(6, -0.15), xytext=(10, -0.15),
                arrowprops=dict(arrowstyle='<->', color='darkgreen', lw=2))
    ax2.text(8, -0.25, 'transfinite ordinals\n(full/nested profiles)', 
            ha='center', fontsize=9, color='darkgreen')
    
    plt.tight_layout()
    plt.savefig('game_simulation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: game_simulation.png")


def plot_dichotomy():
    """Visualize the sharp dichotomy theorem."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Create a visual representation of the dichotomy
    n_profiles = 50
    np.random.seed(42)
    
    # Bounded profiles (sub-ω)
    bounded_x = np.random.uniform(0, 4, 25)
    bounded_y = np.random.uniform(0, 0.9, 25) 
    
    # Full profiles (= ω)
    full_x = np.random.uniform(6, 10, 25)
    full_y = np.ones(25) + np.random.uniform(-0.02, 0.02, 25)
    
    ax.scatter(bounded_x, bounded_y, s=80, c='steelblue', alpha=0.7,
              edgecolors='navy', label='Bounded (sub-ω)', zorder=5)
    ax.scatter(full_x, full_y, s=80, c='crimson', alpha=0.7,
              edgecolors='darkred', label='Full (= ω)', zorder=5)
    
    # Dividing line
    ax.axvline(x=5, color='black', linestyle='--', linewidth=2, alpha=0.5)
    ax.axhline(y=1, color='crimson', linestyle=':', linewidth=1, alpha=0.3)
    
    ax.text(2, 1.15, 'NOT FULL\n(∃k: ¬canSurvive(k))', 
           ha='center', fontsize=12, fontweight='bold', color='steelblue')
    ax.text(8, 1.15, 'FULL\n(∀n: canSurvive(n))', 
           ha='center', fontsize=12, fontweight='bold', color='crimson')
    
    ax.set_ylabel('Survival Ordinal (normalized)', fontsize=12)
    ax.set_xlabel('Profile Space', fontsize=12)
    ax.set_title('The Sharp Dichotomy: survival_omega_iff_full', fontsize=14)
    ax.legend(fontsize=11, loc='upper left')
    ax.set_ylim(-0.1, 1.3)
    ax.set_xlim(-0.5, 10.5)
    
    # Arrow showing the gap
    ax.annotate('', xy=(5, 0.95), xytext=(5, 0.05),
               arrowprops=dict(arrowstyle='<->', color='green', lw=3))
    ax.text(5.3, 0.5, 'NO profiles\nin between!', fontsize=10, 
           color='green', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('dichotomy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: dichotomy.png")


if __name__ == "__main__":
    plot_survival_hierarchy()
    plot_game_simulation()
    plot_dichotomy()
    print("\nAll visualizations generated.")
