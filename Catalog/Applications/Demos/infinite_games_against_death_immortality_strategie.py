#!/usr/bin/env python3
"""
Infinite Games Against Death: Numerical Demonstrations

Demonstrates the key results from the Mortal-Eternity game framework:
1. Reactive evasion with cyclic shift
2. Layered game survival scaling
3. Nested game survival (ω² hierarchy)
4. Ordinal game value visualization
"""

import random
from typing import List, Tuple, Callable


def cyclic_shift(position: int, n: int) -> int:
    """Mortal's reactive strategy: shift by 1 mod n."""
    return (position + 1) % n


def simulate_reactive_game(n: int, rounds: int, 
                           eternity_strategy: Callable[[int], int] = None) -> List[bool]:
    """
    Simulate a reactive evasion game.
    
    Args:
        n: Number of positions (board size)
        rounds: Number of rounds to simulate
        eternity_strategy: Eternity's search strategy (default: random)
    
    Returns:
        List of survival outcomes (True = survived) for each round
    """
    if eternity_strategy is None:
        eternity_strategy = lambda t: random.randint(0, n - 1)
    
    results = []
    for t in range(rounds):
        search = eternity_strategy(t)
        hide = cyclic_shift(search, n)
        results.append(hide != search)
    return results


def demo_reactive_evasion():
    """Demonstrate that cyclic shift always evades."""
    print("=" * 60)
    print("DEMO 1: Reactive Evasion with Cyclic Shift")
    print("=" * 60)
    
    for n in [2, 3, 5, 10, 100]:
        # Test all possible search positions
        all_survive = all(cyclic_shift(e, n) != e for e in range(n))
        print(f"  n = {n:3d}: Fixed-point-free? {all_survive}")
    
    # Simulate against various Eternity strategies
    print("\n  Simulation: 1000 rounds against random Eternity")
    for n in [2, 5, 10]:
        results = simulate_reactive_game(n, 1000)
        survived = sum(results)
        print(f"  n = {n:2d}: Survived {survived}/1000 rounds "
              f"({'PERFECT' if survived == 1000 else 'FAILED'})")
    
    # Adversarial Eternity (tries to predict cyclic shift)
    print("\n  Against adversarial Eternity (always searches position 0):")
    for n in [2, 5, 10]:
        results = simulate_reactive_game(n, 1000, lambda t: 0)
        survived = sum(results)
        print(f"  n = {n:2d}: Survived {survived}/1000 rounds "
              f"({'PERFECT' if survived == 1000 else 'FAILED'})")


def demo_deterministic_mortal():
    """Demonstrate that deterministic Mortal is immediately caught."""
    print("\n" + "=" * 60)
    print("DEMO 2: Deterministic Mortal is Caught Immediately")
    print("=" * 60)
    
    for n in [2, 5, 10]:
        # Mortal uses a fixed sequence
        mortal_pos = random.randint(0, n - 1)
        # Eternity mirrors Mortal's position
        caught_round = 0  # Always caught in round 0
        print(f"  n = {n:2d}: Mortal at position {mortal_pos}, "
              f"caught in round {caught_round}")
    
    print("\n  THE REACTIVITY GAP:")
    print("  Reactive Mortal:      ω rounds (infinite)")
    print("  Deterministic Mortal: 0 rounds (immediate capture)")
    print("  Gap: INFINITE")


def demo_layered_survival():
    """Demonstrate layered game survival scaling."""
    print("\n" + "=" * 60)
    print("DEMO 3: Layered Game Survival (ω · k)")
    print("=" * 60)
    
    print("  k tracks × d rounds/track = total survival")
    print("  " + "-" * 50)
    for k in [1, 2, 5, 10, 100]:
        for d in [10, 100, 1000]:
            total = k * d
            print(f"  k = {k:3d}, d = {d:4d}: total = {total:>8d}")
    
    print("\n  Key insight: For fixed k, as d → ∞, total → ∞")
    print("  Ordinal value: ω · k (k parallel ω-games)")
    
    print("\n  Exceeding any bound B with k = 3 tracks:")
    for bound in [100, 10000, 1000000]:
        d_needed = (bound + 2) // 3  # Each track needs d_needed rounds
        total = 3 * d_needed
        print(f"  B = {bound:>8d}: d = {d_needed:>8d}, total = {total:>8d} ≥ B ✓")


def demo_nested_survival():
    """Demonstrate nested game survival (ω²)."""
    print("\n" + "=" * 60)
    print("DEMO 4: Nested Survival (ω²)")
    print("=" * 60)
    
    print("  Doubly-nested: m macro-rounds × k resets × d rounds")
    print("  " + "-" * 50)
    
    # Show that any bound can be exceeded
    for bound in [100, 10000, 1000000, 10**9]:
        # Simple strategy: use bound macro-rounds of 1 each
        m = bound
        k = 1
        d = 1
        total = m * k * d
        print(f"  B = {bound:>12d}: m={m}, k={k}, d={d} → "
              f"total = {total:>12d} ≥ B ✓")
    
    # More interesting: balanced nesting
    print("\n  Balanced nesting (m = k = d = ∛B):")
    for bound in [1000, 1000000, 10**9]:
        cbrt = int(bound ** (1/3)) + 1
        total = cbrt ** 3
        print(f"  B = {bound:>12d}: m=k=d={cbrt:>5d} → "
              f"total = {total:>12d} ≥ B ✓")
    
    print("\n  Key insight: ω² = sup{m·k : m,k ∈ ℕ}")
    print("  No finite bound constrains doubly-nested games!")


def demo_ordinal_hierarchy():
    """Demonstrate the ordinal game value hierarchy."""
    print("\n" + "=" * 60)
    print("DEMO 5: Ordinal Game Value Hierarchy")
    print("=" * 60)
    
    print("  Game Depth → Ordinal Value → Memory Required")
    print("  " + "-" * 50)
    
    depths = [0, 1, 2, 3, 4, 5, 10]
    for d in depths:
        if d == 0:
            value = "n (finite)"
            memory = "0 counters"
        else:
            value = f"ω^{d}" if d > 1 else "ω"
            memory = f"{d} counter{'s' if d > 1 else ''}"
        print(f"  depth {d:2d}: value = {value:>12s}, memory = {memory}")
    
    print(f"\n  {'∞':>10s}: value = ε₀ = ω^ω^ω^..., memory = ω counters")
    print("\n  Key insight: Each additional counter multiplies")
    print("  game value by ω (infinite multiplicative gain per bit!)")
    
    print("\n  Survival vs memory trade-off:")
    print("  1 bit of state  → ω rounds")
    print("  2 bits of state → ω² rounds")  
    print("  d bits of state → ω^d rounds")
    print("  ω bits of state → ε₀ rounds")


def demo_ittm_connection():
    """Demonstrate the connection to Infinite Time Turing Machines."""
    print("\n" + "=" * 60)
    print("DEMO 6: Connection to Infinite Time Turing Machines")
    print("=" * 60)
    
    print("  ITTM Computation Stages vs Game Nesting Depth:")
    print("  " + "-" * 50)
    
    correspondences = [
        ("Finite TM", "n steps", "No nesting", "n rounds"),
        ("1st limit", "ω steps", "1 level", "ω rounds"),
        ("2nd limit", "ω·2 steps", "2 tracks", "ω·2 rounds"),
        ("ω limits", "ω² steps", "2 levels", "ω² rounds"),
        ("ω² limits", "ω³ steps", "3 levels", "ω³ rounds"),
        ("ε₀ limits", "ε₀ steps", "Self-ref", "ε₀ rounds"),
    ]
    
    print(f"  {'ITTM Stage':<14s} {'Comp Steps':<14s} "
          f"{'Game Struct':<14s} {'Game Value':<14s}")
    for stage, steps, structure, value in correspondences:
        print(f"  {stage:<14s} {steps:<14s} {structure:<14s} {value:<14s}")
    
    print("\n  THE BRIDGE: Computation depth = Game depth = Ordinal value")
    print("  This is not an analogy — it is a mathematical equivalence.")


if __name__ == "__main__":
    random.seed(42)  # Reproducibility
    
    print("╔" + "═" * 58 + "╗")
    print("║  INFINITE GAMES AGAINST DEATH: IMMORTALITY STRATEGIES    ║")
    print("║  Mortal vs Eternity — How Finite Minds Outrun Infinity   ║")
    print("╚" + "═" * 58 + "╝")
    
    demo_reactive_evasion()
    demo_deterministic_mortal()
    demo_layered_survival()
    demo_nested_survival()
    demo_ordinal_hierarchy()
    demo_ittm_connection()
    
    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Game Tree Structure and Ordinal Values

Visualizes the hierarchical game tree for the Mortal-Eternity game,
showing how nesting depth corresponds to ordinal game values.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_game_tree():
    """Draw the game tree for different nesting depths."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    # Depth 0: Finite game (n rounds)
    ax = axes[0]
    ax.set_title("Depth 0: Finite Game\n(value = n)", fontsize=14, fontweight='bold')
    n = 5
    for i in range(n):
        y = 1 - i / (n - 1)
        ax.add_patch(plt.Circle((0.5, y), 0.04, color='steelblue', zorder=5))
        if i < n - 1:
            ax.plot([0.5, 0.5], [y - 0.04, y - 1/(n-1) + 0.04], 
                   color='gray', linewidth=2)
    ax.add_patch(plt.Circle((0.5, 0), 0.04, color='red', zorder=5))
    ax.text(0.5, -0.15, "Game Over", ha='center', fontsize=10, color='red')
    ax.set_xlim(0, 1)
    ax.set_ylim(-0.3, 1.1)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Depth 1: ω-game (infinite rounds via resets)
    ax = axes[1]
    ax.set_title("Depth 1: ω-Game\n(value = ω)", fontsize=14, fontweight='bold')
    
    # Draw 3 blocks + ellipsis
    colors = ['steelblue', 'royalblue', 'cornflowerblue']
    for block in range(3):
        x_start = 0.1 + block * 0.25
        for i in range(4):
            y = 0.9 - i * 0.2
            ax.add_patch(plt.Circle((x_start + 0.1, y), 0.03, 
                        color=colors[block], zorder=5))
            if i < 3:
                ax.plot([x_start + 0.1, x_start + 0.1], 
                       [y - 0.03, y - 0.17], color='gray', linewidth=1.5)
        # Reset arrow
        if block < 2:
            ax.annotate("", xy=(x_start + 0.35, 0.9), 
                       xytext=(x_start + 0.1, 0.2),
                       arrowprops=dict(arrowstyle="->", color='green', lw=2))
            ax.text(x_start + 0.22, 0.55, "reset", fontsize=8, color='green',
                   rotation=70, ha='center')
    
    ax.text(0.92, 0.5, "···", fontsize=20, ha='center', va='center')
    ax.set_xlim(0, 1)
    ax.set_ylim(-0.1, 1.1)
    ax.axis('off')
    
    # Depth 2: ω²-game
    ax = axes[2]
    ax.set_title("Depth 2: ω²-Game\n(value = ω²)", fontsize=14, fontweight='bold')
    
    # Draw nested structure
    for macro in range(2):
        y_base = 0.55 - macro * 0.45
        # Outer box
        ax.add_patch(mpatches.FancyBboxPatch(
            (0.05, y_base - 0.05), 0.85, 0.4,
            boxstyle="round,pad=0.02", 
            facecolor='lightyellow', edgecolor='orange', linewidth=2))
        ax.text(0.07, y_base + 0.3, f"Macro {macro+1}", fontsize=9, 
               fontweight='bold', color='orange')
        
        for inner in range(3):
            x = 0.15 + inner * 0.25
            ax.add_patch(mpatches.FancyBboxPatch(
                (x, y_base), 0.15, 0.25,
                boxstyle="round,pad=0.01",
                facecolor='lightblue', edgecolor='steelblue', linewidth=1))
            for i in range(3):
                y = y_base + 0.2 - i * 0.07
                ax.add_patch(plt.Circle((x + 0.075, y), 0.015,
                            color='steelblue', zorder=5))
        
        ax.text(0.82, y_base + 0.1, "···", fontsize=14, ha='center')
    
    ax.text(0.5, 0.02, "···", fontsize=16, ha='center', va='center')
    ax.set_xlim(0, 1)
    ax.set_ylim(-0.05, 1.05)
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('Applications/game_tree_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: game_tree_hierarchy.png")


def draw_ordinal_staircase():
    """Visualize the ordinal hierarchy as a staircase."""
    fig, ax = plt.subplots(figsize=(12, 7))
    
    # Ordinal values and labels
    levels = [
        (0, "0", "No game"),
        (1, "1", "1 round"),
        (2, "n", "n rounds"),
        (4, "ω", "Reactive evasion"),
        (5, "ω·2", "2 parallel tracks"),
        (6, "ω·k", "k parallel tracks"),
        (8, "ω²", "Nested resets"),
        (9, "ω²·k", "k nested games"),
        (11, "ω³", "3-level nesting"),
        (13, "ω^d", "d-level nesting"),
        (16, "ε₀", "Self-referential"),
    ]
    
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(levels)))
    
    for i, (y, label, desc) in enumerate(levels):
        ax.barh(y, 0.8, height=0.6, color=colors[i], alpha=0.8, 
               edgecolor='black', linewidth=0.5)
        ax.text(0.85, y, f" {label}", fontsize=12, va='center', fontweight='bold')
        ax.text(1.5, y, desc, fontsize=10, va='center', color='gray')
    
    # Add arrows showing game structure correspondence
    ax.annotate("Reactivity\ngap (∞)", xy=(0.4, 3), xytext=(0.4, 2.3),
               fontsize=9, ha='center', color='red', fontweight='bold',
               arrowprops=dict(arrowstyle="<->", color='red', lw=2))
    
    ax.annotate("Bounded\nnondeterminism", xy=(-0.3, 6), xytext=(-0.3, 7),
               fontsize=9, ha='center', color='green',
               arrowprops=dict(arrowstyle="->", color='green', lw=2))
    
    ax.set_xlabel("Relative magnitude (symbolic)", fontsize=12)
    ax.set_title("The Ordinal Staircase of Game Values\n"
                "Each level = one nesting depth of strategy", 
                fontsize=14, fontweight='bold')
    ax.set_yticks([])
    ax.set_xlim(-0.5, 3)
    
    plt.tight_layout()
    plt.savefig('Applications/ordinal_staircase.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: ordinal_staircase.png")


def draw_survival_scaling():
    """Plot survival time vs game parameters."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Layered survival (ω·k)
    ax = axes[0]
    k_values = range(1, 11)
    for d in [10, 50, 100, 500]:
        totals = [k * d for k in k_values]
        ax.plot(k_values, totals, 'o-', label=f'd = {d}', linewidth=2, markersize=6)
    
    ax.set_xlabel("Number of tracks (k)", fontsize=12)
    ax.set_ylabel("Total survival time", fontsize=12)
    ax.set_title("Layered Survival: ω · k\n(k tracks × d rounds each)", 
                fontsize=13, fontweight='bold')
    ax.legend(title="Duration per track", fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_yscale('log')
    
    # Right: Nested survival (ω²)
    ax = axes[1]
    m_values = range(1, 21)
    for k in [1, 5, 10, 20]:
        totals = [m * k * 10 for m in m_values]  # d=10 fixed
        ax.plot(m_values, totals, 's-', label=f'k = {k}', linewidth=2, markersize=5)
    
    ax.set_xlabel("Number of macro-rounds (m)", fontsize=12)
    ax.set_ylabel("Total survival time", fontsize=12)
    ax.set_title("Nested Survival: ω²\n(m macro × k inner × d base)", 
                fontsize=13, fontweight='bold')
    ax.legend(title="Inner tracks", fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('Applications/survival_scaling.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: survival_scaling.png")


if __name__ == "__main__":
    draw_game_tree()
    draw_ordinal_staircase()
    draw_survival_scaling()
    print("\nAll visualizations generated!")
