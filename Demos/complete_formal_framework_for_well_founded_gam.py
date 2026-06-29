#!/usr/bin/env python3
"""
Transfinite Game Values — Interactive Demo

Demonstrates the key concepts from the formal framework:
1. Game value computation for finite games
2. Depth spectrum analysis
3. ε₀ approximation via ordinal tower iteration
4. Nim game analysis
"""

from typing import Dict, List, Set, Optional, Tuple


def compute_game_value(moves: Dict[int, List[int]]) -> Dict[int, int]:
    """
    Compute the game value (ordinal rank) of each position in a finite game.
    
    Args:
        moves: Dictionary mapping each position to its list of successor positions.
               moves[p] = [q1, q2, ...] means from p, player can move to q1, q2, ...
    
    Returns:
        Dictionary mapping each position to its game value (natural number for finite games).
    """
    values: Dict[int, int] = {}
    
    def compute(pos: int) -> int:
        if pos in values:
            return values[pos]
        successors = moves.get(pos, [])
        if not successors:
            values[pos] = 0
            return 0
        # Game value = lsub {gameValue(q) | q ∈ successors}
        # For finite ordinals, lsub S = max(S) + 1
        successor_values = [compute(q) for q in successors]
        values[pos] = max(successor_values) + 1
        return values[pos]
    
    for pos in moves:
        compute(pos)
    return values


def compute_depth_spectrum(moves: Dict[int, List[int]], pos: int, 
                           values: Dict[int, int]) -> Set[int]:
    """
    Compute the depth spectrum: set of all game values reachable from pos.
    """
    spectrum: Set[int] = set()
    visited: Set[int] = set()
    
    def explore(p: int):
        if p in visited:
            return
        visited.add(p)
        for q in moves.get(p, []):
            spectrum.add(values[q])
            explore(q)
    
    for q in moves.get(pos, []):
        spectrum.add(values[q])
        explore(q)
    
    return spectrum


def is_forced(moves: Dict[int, List[int]], pos: int) -> bool:
    """Check if a position is forced (at most one move available)."""
    return len(moves.get(pos, [])) <= 1


def nim_game(heap_size: int) -> Dict[int, List[int]]:
    """
    Construct the Nim game on a heap of given size.
    Position i means heap has i stones. Move: remove any positive number of stones.
    """
    return {i: list(range(i)) for i in range(heap_size + 1)}


def epsilon0_approximation(iterations: int = 10) -> List[str]:
    """
    Approximate ε₀ by iterating ω^(·) starting from 0.
    Returns symbolic representations of the iterates.
    
    ε₀ = sup { 0, ω^0, ω^(ω^0), ω^(ω^(ω^0)), ... }
        = sup { 0, 1, ω, ω^ω, ω^(ω^ω), ... }
    """
    iterates = ["0", "1", "ω"]
    current = "ω"
    for i in range(iterations - 3):
        current = f"ω^({current})"
        iterates.append(current)
    return iterates


def omega_power_hierarchy(n: int) -> str:
    """
    Represent ω^n symbolically.
    Demonstrates the ω^ω supremum theorem: sup {ω^n | n ∈ ℕ} = ω^ω
    """
    if n == 0:
        return "1"
    elif n == 1:
        return "ω"
    else:
        return f"ω^{n}"


def main():
    print("=" * 60)
    print("TRANSFINITE GAME VALUES — DEMONSTRATION")
    print("=" * 60)
    
    # Demo 1: Simple game tree
    print("\n--- Demo 1: Game Value Computation ---")
    print("Game tree:  0 ← 1 ← 3")
    print("                 ↑")
    print("            0 ← 2")
    # Position 3 can move to 1 or 2
    # Position 1 can move to 0
    # Position 2 can move to 0
    # Position 0 is terminal
    moves = {
        3: [1, 2],
        1: [0],
        2: [0],
        0: []
    }
    values = compute_game_value(moves)
    for pos in sorted(moves.keys()):
        forced = "forced" if is_forced(moves, pos) else "decision"
        successors = moves[pos]
        print(f"  Position {pos}: value={values[pos]}, "
              f"moves={successors}, [{forced}]")
    
    spectrum = compute_depth_spectrum(moves, 3, values)
    print(f"  Depth spectrum of root (pos 3): {sorted(spectrum)}")
    print(f"  (Bounded by game value {values[3]}: "
          f"all elements < {values[3]}? {all(v < values[3] for v in spectrum)})")
    
    # Demo 2: Nim game
    print("\n--- Demo 2: Nim Game (heap size 5) ---")
    nim = nim_game(5)
    nim_values = compute_game_value(nim)
    for pos in range(6):
        print(f"  Nim({pos}): value={nim_values[pos]}")
    print("  Note: Nim game value = heap size (nim_value_eq theorem)")
    
    # Demo 3: Linear (forced) game
    print("\n--- Demo 3: Strategically Trivial Game ---")
    linear = {i: [i-1] if i > 0 else [] for i in range(6)}
    linear_values = compute_game_value(linear)
    all_forced = all(is_forced(linear, p) for p in linear)
    print(f"  Linear game 0 ← 1 ← 2 ← 3 ← 4 ← 5")
    print(f"  All positions forced: {all_forced}")
    print(f"  Game values: {[linear_values[i] for i in range(6)]}")
    print(f"  Strategically trivial: True (but game value can be any ordinal!)")
    
    # Demo 4: ε₀ approximation
    print("\n--- Demo 4: ε₀ Tower Approximation ---")
    tower = epsilon0_approximation(8)
    for i, t in enumerate(tower):
        print(f"  Iterate {i}: {t}")
    print(f"  ε₀ = limit of this sequence")
    print(f"  Key property: ω^ε₀ = ε₀ (fixed point!)")
    
    # Demo 5: ω^ω supremum
    print("\n--- Demo 5: ω^ω Supremum Theorem ---")
    for n in range(7):
        print(f"  ω^{n} = {omega_power_hierarchy(n)}")
    print(f"  sup {{ω^n | n ∈ ℕ}} = ω^ω")
    print(f"  This is the ω^ω supremum theorem (omega_opow_sup)")
    
    # Demo 6: Game embedding example
    print("\n--- Demo 6: Game Embedding Preservation ---")
    print("  Game G₁: positions {a, b, c}, moves: c→b→a")
    print("  Game G₂: positions {0,1,2,3,4}, moves: 4→3→2→1→0")
    print("  Embedding f: a↦0, b↦1, c↦2")
    print("  f preserves moves and reflects moves")
    print("  gameValue(c) = 2 in G₁")
    print("  gameValue(f(c)) = gameValue(2) = 2 in G₂")
    print("  Values preserved! (embedding_preserves_value theorem)")
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("See RESEARCH_PAPER.md for full mathematical details.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Game Tree with Game Values

Displays a game tree colored by game value, showing the descent property
(game values strictly decrease along moves).
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Dict, List, Set, Tuple, Optional


def compute_game_values(moves: Dict[int, List[int]]) -> Dict[int, int]:
    """Compute game values for all positions."""
    values: Dict[int, int] = {}
    def compute(pos: int) -> int:
        if pos in values:
            return values[pos]
        succs = moves.get(pos, [])
        if not succs:
            values[pos] = 0
        else:
            values[pos] = max(compute(q) for q in succs) + 1
        return values[pos]
    for pos in moves:
        compute(pos)
    return values


def layout_tree(moves: Dict[int, List[int]], root: int) -> Dict[int, Tuple[float, float]]:
    """Compute positions for tree layout."""
    levels: Dict[int, int] = {}
    order: Dict[int, int] = {}
    level_counts: Dict[int, int] = {}
    
    def assign_levels(pos: int, level: int):
        if pos in levels:
            return
        levels[pos] = level
        for q in moves.get(pos, []):
            assign_levels(q, level + 1)
    
    assign_levels(root, 0)
    
    # Count nodes at each level
    for pos, lvl in levels.items():
        level_counts[lvl] = level_counts.get(lvl, 0) + 1
    
    # Assign horizontal positions
    level_current: Dict[int, int] = {lvl: 0 for lvl in level_counts}
    positions: Dict[int, Tuple[float, float]] = {}
    
    def assign_positions(pos: int):
        if pos in positions:
            return
        lvl = levels[pos]
        count = level_counts[lvl]
        idx = level_current[lvl]
        level_current[lvl] += 1
        x = (idx + 0.5) / count
        y = 1.0 - lvl * 0.25
        positions[pos] = (x, y)
        for q in moves.get(pos, []):
            assign_positions(q)
    
    assign_positions(root)
    return positions


def visualize_game_tree():
    """Create a visualization of a game tree with game values."""
    # Define a game tree
    moves = {
        7: [5, 6],
        6: [3, 4],
        5: [2, 3],
        4: [1, 2],
        3: [0, 1],
        2: [0],
        1: [0],
        0: []
    }
    
    values = compute_game_values(moves)
    positions = layout_tree(moves, 7)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Plot 1: Game tree with values
    ax = axes[0]
    max_val = max(values.values()) if values else 1
    
    # Draw edges
    for parent, children in moves.items():
        if parent in positions:
            px, py = positions[parent]
            for child in children:
                if child in positions:
                    cx, cy = positions[child]
                    ax.plot([px, cx], [py, cy], 'k-', linewidth=1.5, alpha=0.5, zorder=1)
    
    # Draw nodes
    for pos, (x, y) in positions.items():
        val = values[pos]
        color = plt.cm.viridis(val / max_val if max_val > 0 else 0)
        circle = plt.Circle((x, y), 0.035, color=color, ec='black', linewidth=2, zorder=2)
        ax.add_patch(circle)
        ax.text(x, y, str(val), ha='center', va='center', fontsize=10,
                fontweight='bold', color='white' if val > max_val/2 else 'black', zorder=3)
    
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.1, 1.1)
    ax.set_aspect('equal')
    ax.set_title('Game Tree with Ordinal Values\n(values decrease along moves)', fontsize=12)
    ax.axis('off')
    
    # Plot 2: Depth spectrum
    ax2 = axes[1]
    root = 7
    spectrum = set()
    visited = set()
    
    def collect_spectrum(p):
        if p in visited:
            return
        visited.add(p)
        for q in moves.get(p, []):
            spectrum.add(values[q])
            collect_spectrum(q)
    
    for q in moves.get(root, []):
        spectrum.add(values[q])
        collect_spectrum(q)
    
    spectrum_list = sorted(spectrum)
    colors = [plt.cm.viridis(v / max_val) for v in spectrum_list]
    
    bars = ax2.bar(range(len(spectrum_list)), spectrum_list, color=colors, 
                   edgecolor='black', linewidth=1.5)
    ax2.axhline(y=values[root], color='red', linestyle='--', linewidth=2, 
                label=f'Game value of root = {values[root]}')
    ax2.set_xticks(range(len(spectrum_list)))
    ax2.set_xticklabels([f'v={v}' for v in spectrum_list])
    ax2.set_ylabel('Ordinal Value')
    ax2.set_title(f'Depth Spectrum of Root (pos {root})\n'
                  f'All values < {values[root]} (Spectrum Boundedness)', fontsize=12)
    ax2.legend(fontsize=10)
    
    plt.tight_layout()
    plt.savefig('game_tree_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: game_tree_visualization.png")


def visualize_epsilon0_tower():
    """Visualize the ε₀ approximation tower."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Represent the tower heights symbolically
    # Using log scale since actual values grow super-exponentially
    labels = ['0', '1', 'ω', 'ω^ω', 'ω^(ω^ω)', 'ω^(ω^(ω^ω))']
    # Use fake heights for visualization (actual heights are incomparably larger)
    heights = [0, 1, 2, 4, 8, 16]
    
    colors = plt.cm.inferno(np.linspace(0.2, 0.9, len(labels)))
    
    bars = ax.bar(range(len(labels)), heights, color=colors, edgecolor='black', linewidth=1.5)
    ax.set_xticks(range(len(labels)))
    ax.set_xticklabels(labels, fontsize=9, rotation=15)
    ax.set_ylabel('Relative Scale (log)', fontsize=12)
    ax.set_title('ε₀ Tower: Iterating ω^(·) from 0\n'
                 'ε₀ = sup{0, 1, ω, ω^ω, ω^(ω^ω), ...}', fontsize=13)
    
    # Add annotation
    ax.annotate('ε₀ = fixed point\nω^ε₀ = ε₀',
                xy=(5, 16), xytext=(3.5, 18),
                fontsize=11, fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='red', lw=2),
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))
    
    ax.set_ylim(0, 22)
    plt.tight_layout()
    plt.savefig('epsilon0_tower.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: epsilon0_tower.png")


if __name__ == "__main__":
    visualize_game_tree()
    visualize_epsilon0_tower()
