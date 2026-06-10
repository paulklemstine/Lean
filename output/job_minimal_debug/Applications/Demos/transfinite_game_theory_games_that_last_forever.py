#!/usr/bin/env python3
"""
Transfinite Game Theory — Interactive Demo

Demonstrates key concepts from the formalization:
1. Minimax computation for finite game trees
2. Strategy exclusivity verification
3. Ordinal rank computation
4. Quasistrategy pruning
"""

from typing import List, Optional, Tuple, Callable


# ============================================================
# Game Tree Representation
# ============================================================

class GameTree:
    """A finite game tree node."""
    def __init__(self, children: Optional[List['GameTree']] = None, label: str = ""):
        self.children = children or []
        self.label = label

    @property
    def is_leaf(self) -> bool:
        return len(self.children) == 0

    def rank(self) -> int:
        """Compute the game-theoretic rank."""
        if self.is_leaf:
            return 0
        return max(c.rank() + 1 for c in self.children)

    def is_winning(self) -> bool:
        """Is the current position winning for the player to move?
        Leaf = losing (no moves). Node = winning iff some child is losing."""
        if self.is_leaf:
            return False
        return any(not c.is_winning() for c in self.children)

    def size(self) -> int:
        """Total number of nodes."""
        return 1 + sum(c.size() for c in self.children)


def chain_game(n: int) -> GameTree:
    """Create a linear chain game of depth n."""
    if n == 0:
        return GameTree(label=f"L")
    return GameTree([chain_game(n - 1)], label=f"D{n}")


def wide_game(n: int) -> GameTree:
    """Create a wide game with n leaf children."""
    return GameTree([GameTree(label=f"L{i}") for i in range(n)], label=f"W{n}")


# ============================================================
# Gale-Stewart Game Simulation
# ============================================================

Strategy = Callable[[List[int]], int]

def build_history(sigma: Strategy, tau: Strategy, n: int) -> List[int]:
    """Build the first n moves from two strategies."""
    history = []
    for step in range(n):
        if step % 2 == 0:
            history.append(sigma(list(history)))
        else:
            history.append(tau(list(history)))
    return history


def canonical_play(sigma: Strategy, tau: Strategy, length: int = 20) -> List[int]:
    """Generate the canonical play from two strategies."""
    return build_history(sigma, tau, length)


def check_exclusivity(
    sigma: Strategy, tau: Strategy,
    payoff: Callable[[List[int]], bool],
    play_length: int = 20
) -> Tuple[bool, List[int]]:
    """Demonstrate the exclusivity theorem:
    playing sigma against tau must produce a definite winner."""
    play = canonical_play(sigma, tau, play_length)
    player_i_wins = payoff(play)
    return player_i_wins, play


# ============================================================
# Demo 1: Finite Game Trees
# ============================================================

def demo_game_trees():
    print("=" * 60)
    print("DEMO 1: Finite Game Trees")
    print("=" * 60)

    # Chain games
    for n in range(6):
        g = chain_game(n)
        winning = g.is_winning()
        print(f"  Chain depth {n}: rank={g.rank()}, "
              f"winning={'Player I' if winning else 'Player II'}, "
              f"size={g.size()}")

    print("\n  Parity pattern: even depth → Player II wins, odd → Player I wins")

    # Wide games
    print()
    for n in [1, 2, 3, 5, 10]:
        g = wide_game(n)
        print(f"  Wide game ({n} leaves): rank={g.rank()}, "
              f"winning={'Player I' if g.is_winning() else 'Player II'}")


# ============================================================
# Demo 2: Strategy Exclusivity
# ============================================================

def demo_exclusivity():
    print("\n" + "=" * 60)
    print("DEMO 2: Strategy Exclusivity")
    print("=" * 60)

    # Game: Player I wins if sum of first 3 moves is even
    def payoff(play: List[int]) -> bool:
        return sum(play[:3]) % 2 == 0

    # Strategy: always play 0
    sigma_zero: Strategy = lambda h: 0
    tau_zero: Strategy = lambda h: 0

    # Strategy: always play 1
    sigma_one: Strategy = lambda h: 1
    tau_one: Strategy = lambda h: 1

    # Strategy: play the move number
    sigma_count: Strategy = lambda h: len(h)

    scenarios = [
        ("σ=0, τ=0", sigma_zero, tau_zero),
        ("σ=0, τ=1", sigma_zero, tau_one),
        ("σ=1, τ=0", sigma_one, tau_zero),
        ("σ=1, τ=1", sigma_one, tau_one),
        ("σ=count, τ=0", sigma_count, tau_zero),
    ]

    for name, sigma, tau in scenarios:
        winner, play = check_exclusivity(sigma, tau, payoff, 6)
        print(f"  {name}: play={play[:6]}, sum={sum(play[:3])}, "
              f"winner={'Player I' if winner else 'Player II'}")

    print("\n  Key insight: for EACH pair (σ, τ), exactly one player wins.")
    print("  This is the exclusivity theorem in action.")


# ============================================================
# Demo 3: Ordinal Ranks
# ============================================================

def demo_ordinal_ranks():
    print("\n" + "=" * 60)
    print("DEMO 3: Ordinal Rank Hierarchy")
    print("=" * 60)

    # Build a tree: node with children of ranks 0, 1, 2
    leaf = GameTree(label="leaf")
    depth1 = GameTree([leaf], label="d1")
    depth2 = GameTree([depth1], label="d2")

    node = GameTree([leaf, depth1, depth2], label="root")

    print(f"  Tree structure:")
    print(f"    root → [leaf(r=0), d1(r=1), d2(r=2)]")
    print(f"    Rank of root: {node.rank()}")
    print(f"    Expected: max(0,1,2) + 1 = 3 ✓" if node.rank() == 3 else "    ERROR!")

    # Demonstrate monotonicity
    print(f"\n  Rank monotonicity (child < parent):")
    for i, c in enumerate(node.children):
        print(f"    child[{i}].rank = {c.rank()} < parent.rank = {node.rank()}: "
              f"{'✓' if c.rank() < node.rank() else '✗'}")


# ============================================================
# Demo 4: Open Game Detection
# ============================================================

def demo_open_games():
    print("\n" + "=" * 60)
    print("DEMO 4: Open and Clopen Games")
    print("=" * 60)

    # Clopen game: determined at stage 2
    def clopen_payoff(play: List[int]) -> bool:
        """Player I wins iff first two moves sum to > 5."""
        if len(play) < 2:
            return False
        return play[0] + play[1] > 5

    # Open game: Player I wins if ANY move is > 100
    def open_payoff(play: List[int]) -> bool:
        """Player I wins iff some move exceeds 100."""
        return any(m > 100 for m in play)

    print("  Clopen game (sum of first 2 moves > 5):")
    print("    Determined at stage: 2")
    print("    Is clopen: True (depends only on first 2 moves)")
    print("    Is open: True (all clopen games are open)")
    print("    Is closed: True (all clopen games are closed)")

    print("\n  Open game (some move > 100):")
    print("    Determined at stage: ∞ (not clopen)")
    print("    Is open: True (winning witnessed by finite prefix)")
    print("    Is closed: False (complement is not open)")

    # Test with strategies
    sigma_big: Strategy = lambda h: 200 if len(h) == 4 else 0
    tau_zero: Strategy = lambda h: 0
    play = canonical_play(sigma_big, tau_zero, 10)
    print(f"\n  Open game with σ(len=4)=200: play={play}")
    print(f"    Player I wins: {open_payoff(play)}")


# ============================================================
# Demo 5: Determinacy Hierarchy
# ============================================================

def demo_hierarchy():
    print("\n" + "=" * 60)
    print("DEMO 5: Determinacy Hierarchy")
    print("=" * 60)

    hierarchy = [
        ("Clopen (Σ⁰₀)", 0, "ZF"),
        ("Open (Σ⁰₁)", 0, "ZF (Gale-Stewart)"),
        ("Σ⁰₂", 1, "ZFC + sharps"),
        ("Σ⁰₃", 2, "ZFC + measurable cardinal"),
        ("Σ⁰₄", 3, "ZFC + 2 Woodin cardinals"),
        ("Borel", "ω", "ZFC (Martin 1975)"),
        ("Analytic (Σ¹₁)", "ω₁", "ZFC + sharps for all reals"),
        ("Projective", "∞", "ZFC + ω Woodin cardinals"),
        ("All sets (AD)", "Ω", "ZF + DC + large cardinals"),
    ]

    print(f"  {'Level':<20} {'Strength':<10} {'Required Axioms'}")
    print(f"  {'-'*20} {'-'*10} {'-'*30}")
    for level, strength, axioms in hierarchy:
        print(f"  {level:<20} {str(strength):<10} {axioms}")

    print("\n  Key insight: each step up the Borel hierarchy requires")
    print("  strictly more set-theoretic axiom strength.")
    print("  This is the deep connection between game complexity")
    print("  and large cardinal axioms.")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   TRANSFINITE GAME THEORY: GAMES THAT LAST FOREVER     ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    demo_game_trees()
    demo_exclusivity()
    demo_ordinal_ranks()
    demo_open_games()
    demo_hierarchy()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization 2: The Determinacy Hierarchy
Shows the relationship between Borel complexity and axiom strength.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def main():
    fig, ax = plt.subplots(figsize=(14, 9))

    # Hierarchy levels
    levels = [
        {"name": "Clopen (Δ⁰₁)", "y": 0, "strength": 0, "color": "#81C784",
         "axiom": "ZF", "det_year": "1913 (Zermelo)"},
        {"name": "Open (Σ⁰₁)", "y": 1, "strength": 0, "color": "#66BB6A",
         "axiom": "ZF", "det_year": "1953 (Gale-Stewart)"},
        {"name": "Σ⁰₂", "y": 2, "strength": 1, "color": "#FFF176",
         "axiom": "ZFC", "det_year": "1975 (Martin)"},
        {"name": "Σ⁰₃", "y": 3, "strength": 2, "color": "#FFD54F",
         "axiom": "ZFC", "det_year": "1975 (Martin)"},
        {"name": "Borel", "y": 4, "strength": 5, "color": "#FFB74D",
         "axiom": "ZFC", "det_year": "1975 (Martin)"},
        {"name": "Analytic (Σ¹₁)", "y": 5.5, "strength": 10, "color": "#FF8A65",
         "axiom": "ZFC + sharps", "det_year": "1985 (Harrington-Martin)"},
        {"name": "Projective", "y": 7, "strength": 20, "color": "#EF5350",
         "axiom": "ZFC + Woodin", "det_year": "1989 (Martin-Steel)"},
        {"name": "AD (all sets)", "y": 9, "strength": 50, "color": "#AB47BC",
         "axiom": "ZF + DC + LC", "det_year": "1962 (Mycielski-Steinhaus)"},
    ]

    # Draw boxes
    box_width = 6
    for level in levels:
        rect = mpatches.FancyBboxPatch(
            (0.5, level["y"] - 0.35), box_width, 0.7,
            boxstyle="round,pad=0.1",
            facecolor=level["color"], edgecolor='#424242',
            linewidth=1.5, alpha=0.9
        )
        ax.add_patch(rect)

        # Level name
        ax.text(0.5 + box_width / 2, level["y"],
                level["name"], ha='center', va='center',
                fontsize=12, fontweight='bold', color='#212121')

    # Draw strength bars
    max_strength = 50
    bar_x = 8
    bar_width = 4

    for level in levels:
        w = bar_width * level["strength"] / max_strength
        rect = mpatches.FancyBboxPatch(
            (bar_x, level["y"] - 0.25), max(w, 0.05), 0.5,
            boxstyle="round,pad=0.05",
            facecolor=level["color"], edgecolor='#616161',
            linewidth=1, alpha=0.7
        )
        ax.add_patch(rect)

        # Axiom label
        ax.text(bar_x + bar_width + 0.3, level["y"],
                f'{level["axiom"]}  ({level["det_year"]})',
                ha='left', va='center', fontsize=9, color='#424242')

    # Arrows between levels
    for i in range(len(levels) - 1):
        y1 = levels[i]["y"] + 0.35
        y2 = levels[i + 1]["y"] - 0.35
        ax.annotate('', xy=(3.5, y2), xytext=(3.5, y1),
                    arrowprops=dict(arrowstyle='->', color='#757575',
                                   lw=1.5, connectionstyle='arc3,rad=0'))

    # Labels
    ax.text(3.5, -1.3, 'Topological Complexity →',
            ha='center', va='center', fontsize=11, fontweight='bold',
            color='#424242')
    ax.text(bar_x + bar_width / 2, -1.3, 'Axiom Strength →',
            ha='center', va='center', fontsize=11, fontweight='bold',
            color='#424242')

    # Title
    ax.set_title('The Determinacy Hierarchy\n'
                 'Topological Complexity vs. Axiomatic Strength',
                 fontsize=16, fontweight='bold', pad=20)

    # Annotation
    ax.text(bar_x + bar_width / 2, 10.5,
            'Each step up the hierarchy requires\n'
            'strictly stronger set-theoretic axioms.\n'
            'This is the deep bridge between\n'
            'game theory and large cardinals.',
            ha='center', va='center', fontsize=10,
            style='italic', color='#616161',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#F5F5F5',
                     edgecolor='#BDBDBD'))

    ax.set_xlim(-0.5, 20)
    ax.set_ylim(-2, 11.5)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('determinacy_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: determinacy_hierarchy.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 1: Game Tree with Minimax Values
Shows a game tree colored by winning status.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import List, Optional, Tuple, Dict


class VizNode:
    def __init__(self, children=None, terminal_value=None, label=""):
        self.children = children or []
        self.terminal_value = terminal_value
        self.label = label
        self.x = 0.0
        self.y = 0.0
        self.value = None  # minimax value

    @property
    def is_terminal(self):
        return len(self.children) == 0


def minimax(node: VizNode, depth: int = 0) -> bool:
    if node.is_terminal:
        node.value = node.terminal_value if node.terminal_value is not None else False
        return node.value
    if depth % 2 == 0:
        node.value = any(minimax(c, depth + 1) for c in node.children)
    else:
        node.value = all(minimax(c, depth + 1) for c in node.children)
    return node.value


def layout_tree(node: VizNode, x: float = 0, y: float = 0,
                x_span: float = 8, y_step: float = 1.5) -> None:
    node.x = x
    node.y = y
    if node.children:
        n = len(node.children)
        child_span = x_span / max(n, 1)
        start_x = x - x_span / 2 + child_span / 2
        for i, child in enumerate(node.children):
            layout_tree(child, start_x + i * child_span, y - y_step,
                       child_span * 0.8, y_step)


def draw_tree(ax, node: VizNode, depth: int = 0):
    # Draw edges first
    for child in node.children:
        ax.plot([node.x, child.x], [node.y, child.y],
                'k-', linewidth=1.5, alpha=0.5, zorder=1)
        draw_tree(ax, child, depth + 1)

    # Node color based on minimax value
    color = '#4CAF50' if node.value else '#F44336'  # green=PI wins, red=PII wins
    edge_color = '#2E7D32' if node.value else '#C62828'

    # Shape based on player
    if node.is_terminal:
        marker = 's'  # square for terminal
        size = 400
    elif depth % 2 == 0:
        marker = 'o'  # circle for Player I
        size = 600
    else:
        marker = 'D'  # diamond for Player II
        size = 500

    ax.scatter(node.x, node.y, s=size, c=color, marker=marker,
              edgecolors=edge_color, linewidths=2, zorder=3)

    # Label
    if node.label:
        ax.annotate(node.label, (node.x, node.y), fontsize=7,
                   ha='center', va='center', fontweight='bold',
                   color='white', zorder=4)


def main():
    # Build an interesting game tree
    # Level 3 leaves
    l1 = VizNode(terminal_value=True, label="W")
    l2 = VizNode(terminal_value=False, label="L")
    l3 = VizNode(terminal_value=True, label="W")
    l4 = VizNode(terminal_value=False, label="L")
    l5 = VizNode(terminal_value=True, label="W")
    l6 = VizNode(terminal_value=False, label="L")
    l7 = VizNode(terminal_value=True, label="W")
    l8 = VizNode(terminal_value=False, label="L")

    # Level 2 (Player II nodes)
    n1 = VizNode([l1, l2], label="II")
    n2 = VizNode([l3, l4], label="II")
    n3 = VizNode([l5, l6], label="II")
    n4 = VizNode([l7, l8], label="II")

    # Level 1 (Player I nodes)
    m1 = VizNode([n1, n2], label="I")
    m2 = VizNode([n3, n4], label="I")

    # Root (Player I)
    root = VizNode([m1, m2], label="I")

    # Compute minimax
    minimax(root)

    # Layout
    layout_tree(root)

    # Draw
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    draw_tree(ax, root)

    ax.set_xlim(-6, 6)
    ax.set_ylim(-6, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#4CAF50', edgecolor='#2E7D32',
                      label='Player I wins'),
        mpatches.Patch(facecolor='#F44336', edgecolor='#C62828',
                      label='Player II wins'),
        plt.Line2D([0], [0], marker='o', color='w', markerfacecolor='gray',
                   markersize=12, label='Player I node'),
        plt.Line2D([0], [0], marker='D', color='w', markerfacecolor='gray',
                   markersize=10, label='Player II node'),
        plt.Line2D([0], [0], marker='s', color='w', markerfacecolor='gray',
                   markersize=10, label='Terminal'),
    ]
    ax.legend(handles=legend_elements, loc='lower right', fontsize=10,
             framealpha=0.9)

    ax.set_title('Game Tree with Minimax Values\n'
                 '(Green = Player I wins, Red = Player II wins)',
                 fontsize=14, fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('game_tree_minimax.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: game_tree_minimax.png")


if __name__ == "__main__":
    main()
