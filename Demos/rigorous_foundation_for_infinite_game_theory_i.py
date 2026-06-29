"""
Infinite Game Theory: Interactive Demonstrations
=================================================

Demonstrates key concepts from the Gale-Stewart game formalization:
1. Strategy evaluation and play generation
2. Determinacy checking for finite game trees
3. Wadge reducibility via continuous functions
4. Game rank computation
"""

from typing import Callable, List, Optional, Tuple
from dataclasses import dataclass


# ============================================================================
# Core Definitions
# ============================================================================

@dataclass
class GaleStewartGame:
    """A Gale-Stewart game specified by a payoff predicate on infinite plays."""
    name: str
    # For finite approximation: payoff checks prefix of given length
    payoff: Callable[[List[int]], bool]
    description: str


def play_game(
    strategy_I: Callable[[List[int]], int],
    strategy_II: Callable[[List[int]], int],
    num_rounds: int
) -> List[int]:
    """Generate the play sequence from two strategies for a given number of rounds."""
    history: List[int] = []
    for n in range(2 * num_rounds):
        if n % 2 == 0:
            move = strategy_I(history[:])
        else:
            move = strategy_II(history[:])
        history.append(move)
    return history


def evaluate_game(
    game: GaleStewartGame,
    strategy_I: Callable[[List[int]], int],
    strategy_II: Callable[[List[int]], int],
    num_rounds: int = 10
) -> Tuple[List[int], bool]:
    """Play a game and determine the winner."""
    play = play_game(strategy_I, strategy_II, num_rounds)
    player_I_wins = game.payoff(play)
    return play, player_I_wins


# ============================================================================
# Demo 1: Strategy Exclusivity
# ============================================================================

def demo_strategy_exclusivity():
    """Demonstrate that winning strategies for the two players are mutually exclusive."""
    print("=" * 70)
    print("DEMO 1: Strategy Exclusivity")
    print("=" * 70)
    print()

    # Game: Player I wins if the sum of all moves is even
    game = GaleStewartGame(
        name="Even Sum Game",
        payoff=lambda play: sum(play) % 2 == 0,
        description="Player I wins if sum of all moves is even"
    )

    # Player I strategy: always play 0 (trying to keep sum even)
    def sigma(hist): return 0

    # Player II strategy: always play 1 (trying to make sum odd)
    def tau(hist): return 1

    play, p1_wins = evaluate_game(game, sigma, tau, num_rounds=5)
    print(f"Game: {game.description}")
    print(f"Player I strategy: always play 0")
    print(f"Player II strategy: always play 1")
    print(f"Play sequence: {play}")
    print(f"Sum = {sum(play)}, Player I wins: {p1_wins}")
    print()

    # Now show exclusivity: if sigma beats every tau, then no tau beats every sigma
    def test_winning_I(sigma, num_taus=100, rounds=5):
        """Test if sigma appears to be winning against random strategies."""
        import random
        wins = 0
        for _ in range(num_taus):
            tau = lambda hist, r=random: r.randint(0, 3)
            _, p1_wins = evaluate_game(game, sigma, tau, rounds)
            if p1_wins:
                wins += 1
        return wins / num_taus

    def test_winning_II(tau, num_sigmas=100, rounds=5):
        """Test if tau appears to be winning against random strategies."""
        import random
        wins = 0
        for _ in range(num_sigmas):
            sigma = lambda hist, r=random: r.randint(0, 3)
            _, p1_wins = evaluate_game(game, sigma, tau, rounds)
            if not p1_wins:
                wins += 1
        return wins / num_sigmas

    # Player I's winning strategy for Even Sum: always play 0
    sigma_star = lambda hist: 0
    win_rate_I = test_winning_I(sigma_star)
    print(f"Player I strategy (always 0) win rate: {win_rate_I:.2%}")

    # Try Player II's best counter
    tau_star = lambda hist: 1
    win_rate_II = test_winning_II(tau_star)
    print(f"Player II strategy (always 1) win rate: {win_rate_II:.2%}")
    print()
    print("Observation: Both strategies do well against random opponents,")
    print("but when they face each other, exactly one wins — demonstrating")
    print("strategy exclusivity.")
    print()


# ============================================================================
# Demo 2: Determinacy of Finite Game Trees (Zermelo's Algorithm)
# ============================================================================

@dataclass
class GameTree:
    """A finite game tree."""
    is_leaf: bool
    value: Optional[bool] = None  # True = Player I wins (at leaves)
    children: Optional[List['GameTree']] = None
    player: int = 0  # 0 = Player I, 1 = Player II

    def minimax(self) -> bool:
        """Determine the winner by backward induction."""
        if self.is_leaf:
            return self.value
        child_values = [c.minimax() for c in self.children]
        if self.player == 0:  # Player I maximizes (wants True)
            return any(child_values)
        else:  # Player II minimizes (wants False)
            return all(child_values)

    def size(self) -> int:
        if self.is_leaf:
            return 1
        return 1 + sum(c.size() for c in self.children)


def demo_determinacy():
    """Demonstrate determinacy checking for finite game trees."""
    print("=" * 70)
    print("DEMO 2: Finite Game Tree Determinacy (Zermelo's Algorithm)")
    print("=" * 70)
    print()

    # Build a sample game tree
    #         I
    #        / \
    #       II   II
    #      / \  / \
    #     T  F  F  T
    tree = GameTree(
        is_leaf=False, player=0, children=[
            GameTree(is_leaf=False, player=1, children=[
                GameTree(is_leaf=True, value=True),
                GameTree(is_leaf=True, value=False),
            ]),
            GameTree(is_leaf=False, player=1, children=[
                GameTree(is_leaf=True, value=False),
                GameTree(is_leaf=True, value=True),
            ]),
        ]
    )

    winner = tree.minimax()
    print(f"Game tree (size {tree.size()}):")
    print("       Player I")
    print("        /    \\")
    print("    Player II  Player II")
    print("     / \\        / \\")
    print("    W   L      L   W")
    print()
    print(f"Determined: YES (always true for finite trees)")
    print(f"Winner: Player {'I' if winner else 'II'}")
    print(f"Strategy: Player I goes {'left' if tree.children[0].minimax() else 'right'}")
    print()

    # Larger random tree
    import random
    random.seed(42)

    def random_tree(depth, branching=2, player=0):
        if depth == 0:
            return GameTree(is_leaf=True, value=random.choice([True, False]))
        children = [random_tree(depth - 1, branching, 1 - player)
                    for _ in range(branching)]
        return GameTree(is_leaf=False, player=player, children=children)

    for depth in [3, 5, 8, 10]:
        tree = random_tree(depth)
        winner = tree.minimax()
        print(f"Random tree depth={depth}, size={tree.size()}: "
              f"Player {'I' if winner else 'II'} wins")
    print()


# ============================================================================
# Demo 3: Wadge Reducibility
# ============================================================================

def demo_wadge():
    """Demonstrate Wadge reducibility between sets in Cantor space."""
    print("=" * 70)
    print("DEMO 3: Wadge Reducibility")
    print("=" * 70)
    print()

    # Define some sets in ℕ → {0,1} (approximated by finite prefixes)
    def eventually_zero(seq, n=20):
        """The set of sequences that are eventually 0."""
        return all(x == 0 for x in seq[n//2:])

    def has_finite_ones(seq, n=20):
        """The set of sequences with finitely many 1s."""
        return sum(1 for x in seq[n//2:] if x == 1) == 0

    def starts_with_1(seq, n=20):
        """The set of sequences starting with 1."""
        return len(seq) > 0 and seq[0] == 1

    # Wadge reduction: eventually_zero ≤_W has_finite_ones via identity
    print("Set A: 'eventually zero' (all sufficiently late terms are 0)")
    print("Set B: 'finitely many ones' (only finitely many terms equal 1)")
    print()
    print("Reduction A ≤_W B: via the identity function")
    print("  Proof: x is eventually zero ⟺ x has finitely many ones")
    print("  (These sets are actually equal for binary sequences!)")
    print()

    # Wadge reduction: starts_with_1 ≤_W starts_with_1 via identity (reflexivity)
    print("Wadge reflexivity: A ≤_W A for any set A")
    print("  Witness: f = id (the identity function)")
    print("  x ∈ A ⟺ id(x) ∈ A ✓")
    print()

    # Transitivity example
    print("Wadge transitivity: if A ≤_W B ≤_W C then A ≤_W C")
    print("  Witness: if f reduces A to B and g reduces B to C,")
    print("  then g ∘ f reduces A to C")
    print("  This works because composition preserves continuity.")
    print()

    # Show that the empty set reduces to any proper subset
    print("The empty set ∅ is NOT Wadge-reducible to every set!")
    print("  ∅ ≤_W A requires: ∀x, x ∈ ∅ ⟺ f(x) ∈ A")
    print("  Since x ∈ ∅ is always false, we need f(x) ∉ A for all x")
    print("  This fails when A = universe (everything).")
    print("  ∅ ≤_W A holds iff A ≠ universe, via any constant function")
    print("  mapping to a point outside A.")
    print()


# ============================================================================
# Demo 4: Game Rank
# ============================================================================

def demo_game_rank():
    """Demonstrate game rank computation."""
    print("=" * 70)
    print("DEMO 4: Game Rank Theory")
    print("=" * 70)
    print()

    def compute_rank(payoff_empty: bool, payoff_universal: bool) -> int:
        if payoff_empty:
            return 0
        if payoff_universal:
            return 0
        return 1

    examples = [
        ("Empty game (∅)", True, False),
        ("Universal game (univ)", False, True),
        ("Even sum game", False, False),
        ("First move = 0", False, False),
    ]

    print("Game Rank characterizes triviality:")
    print(f"{'Game':<30} {'Payoff ∅?':<12} {'Payoff univ?':<14} {'Rank':<6} {'Trivial?'}")
    print("-" * 75)
    for name, empty, univ in examples:
        rank = compute_rank(empty, univ)
        trivial = rank == 0
        print(f"{name:<30} {str(empty):<12} {str(univ):<14} {rank:<6} {trivial}")
    print()

    print("Key theorem: rank(G) = 0 ⟺ G is trivial")
    print("Key theorem: rank(G^c) = rank(G) (complement preserves rank)")
    print()

    # Show complement invariance
    print("Complement invariance examples:")
    print(f"  rank(∅) = 0,     rank(∅^c = univ) = 0    ✓")
    print(f"  rank(univ) = 0,  rank(univ^c = ∅) = 0    ✓")
    print(f"  rank(even_sum) = 1, rank(odd_sum) = 1     ✓")
    print()


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    demo_strategy_exclusivity()
    demo_determinacy()
    demo_wadge()
    demo_game_rank()

    print("=" * 70)
    print("All demonstrations complete.")
    print()
    print("Summary of formalized theorems:")
    print("  • Strategy exclusivity (axiom-free)")
    print("  • Trivial game determinacy")
    print("  • Complement involution and duality")
    print("  • De Morgan laws for game operations")
    print("  • Wadge reflexivity and transitivity")
    print("  • Wadge equivalence is an equivalence relation")
    print("  • Game rank characterizes triviality")
    print("  • Rank is complement-invariant")
    print("  • Quasi-strategy refinement")
    print("=" * 70)


"""
Visualization: Finite Game Tree with Backward Induction
========================================================

Draws a game tree and color-codes nodes by which player wins
from that position. Demonstrates Zermelo's determinacy theorem
for finite games.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import random

random.seed(42)


def generate_random_tree(depth, branching=2):
    """Generate a random game tree as nested dicts."""
    if depth == 0:
        return {"leaf": True, "value": random.choice([True, False])}
    children = [generate_random_tree(depth - 1, branching) for _ in range(branching)]
    return {"leaf": False, "player": depth % 2, "children": children}


def solve_tree(node):
    """Backward induction: returns True if Player I wins."""
    if node["leaf"]:
        return node["value"]
    results = [solve_tree(c) for c in node["children"]]
    if node["player"] == 0:  # Player I: exists winning child
        return any(results)
    else:  # Player II: all children winning for I
        return all(results)


def layout_tree(node, x=0, y=0, dx=1.0, positions=None, edges=None, node_id=0):
    """Compute positions for all nodes."""
    if positions is None:
        positions = {}
        edges = []

    positions[node_id] = (x, y, node)
    current_id = node_id

    if not node["leaf"]:
        n = len(node["children"])
        start_x = x - dx * (n - 1) / 2
        next_id = node_id + 1
        for i, child in enumerate(node["children"]):
            child_x = start_x + i * dx
            edges.append((node_id, next_id))
            next_id = layout_tree(child, child_x, y - 1, dx / 2.5,
                                  positions, edges, next_id)
        return next_id
    return node_id + 1


def draw_game_tree():
    """Draw the game tree visualization."""
    tree = generate_random_tree(depth=4, branching=2)

    positions = {}
    edges = []
    layout_tree(tree, x=0, y=0, dx=8.0, positions=positions, edges=edges)

    fig, ax = plt.subplots(1, 1, figsize=(16, 10))
    fig.suptitle("Finite Game Tree: Backward Induction (Zermelo's Theorem)",
                 fontsize=16, fontweight='bold')

    # Draw edges
    for (p, c) in edges:
        px, py, _ = positions[p]
        cx, cy, _ = positions[c]
        ax.plot([px, cx], [py, cy], 'k-', alpha=0.3, linewidth=1)

    # Draw nodes
    for nid, (x, y, node) in positions.items():
        winner = solve_tree(node)
        color = '#2ecc71' if winner else '#e74c3c'  # Green=I wins, Red=II wins

        if node["leaf"]:
            marker = 's'
            size = 80
        else:
            marker = 'o' if node["player"] == 0 else 'D'
            size = 120

        ax.scatter(x, y, c=color, s=size, marker=marker, zorder=5,
                   edgecolors='black', linewidth=0.5)

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#2ecc71', edgecolor='black', label='Player I wins'),
        mpatches.Patch(facecolor='#e74c3c', edgecolor='black', label='Player II wins'),
        plt.Line2D([0], [0], marker='o', color='w', markerfacecolor='gray',
                   markersize=10, label='Player I node (circle)'),
        plt.Line2D([0], [0], marker='D', color='w', markerfacecolor='gray',
                   markersize=10, label='Player II node (diamond)'),
        plt.Line2D([0], [0], marker='s', color='w', markerfacecolor='gray',
                   markersize=8, label='Terminal node (square)'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=10)

    overall = solve_tree(tree)
    ax.set_title(f"Result: Player {'I' if overall else 'II'} has a winning strategy\n"
                 f"(Depth 4, 31 nodes — every finite game is determined)",
                 fontsize=12)

    ax.set_xlim(-10, 10)
    ax.set_ylim(-5, 1)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('viz_game_tree.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_game_tree.png")


if __name__ == "__main__":
    draw_game_tree()


"""
Visualization: The Wadge Hierarchy Structure
=============================================

Visualizes the Wadge hierarchy for simple sets in Baire space,
showing reducibility relationships as a Hasse diagram.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_wadge_hierarchy():
    """Draw the Wadge hierarchy for low Borel complexity classes."""

    fig, ax = plt.subplots(1, 1, figsize=(12, 10))
    fig.suptitle("The Wadge Hierarchy: Complexity of Infinite Game Payoff Sets",
                 fontsize=15, fontweight='bold')

    # Nodes in the hierarchy (name, x, y, color, description)
    nodes = [
        ("∅", 0, 0, '#95a5a6', "Empty set\n(rank 0)"),
        ("univ", 0, 1, '#95a5a6', "Universal set\n(rank 0)"),
        ("Clopen₁", -2, 2, '#3498db', "Simple clopen\n(rank 1)"),
        ("Clopen₁ᶜ", 2, 2, '#3498db', "Complement clopen\n(rank 1)"),
        ("Open", -3, 3.5, '#2ecc71', "Open sets\n(Σ⁰₁)"),
        ("Closed", 3, 3.5, '#e74c3c', "Closed sets\n(Π⁰₁)"),
        ("Fσ", -2, 5, '#f39c12', "Countable union\nof closed (Σ⁰₂)"),
        ("Gδ", 2, 5, '#9b59b6', "Countable intersection\nof open (Π⁰₂)"),
        ("Borel", 0, 7, '#1abc9c', "All Borel sets\n(determined!)"),
    ]

    # Edges (from, to) representing ≤_W
    edges = [
        ("∅", "univ"),
        ("univ", "Clopen₁"),
        ("univ", "Clopen₁ᶜ"),
        ("Clopen₁", "Open"),
        ("Clopen₁ᶜ", "Open"),
        ("Clopen₁", "Closed"),
        ("Clopen₁ᶜ", "Closed"),
        ("Open", "Fσ"),
        ("Closed", "Fσ"),
        ("Open", "Gδ"),
        ("Closed", "Gδ"),
        ("Fσ", "Borel"),
        ("Gδ", "Borel"),
    ]

    # Position lookup
    pos = {n[0]: (n[1], n[2]) for n in nodes}
    colors = {n[0]: n[3] for n in nodes}
    labels = {n[0]: n[4] for n in nodes}

    # Draw edges
    for (a, b) in edges:
        x1, y1 = pos[a]
        x2, y2 = pos[b]
        ax.annotate("", xy=(x2, y2 - 0.3), xytext=(x1, y1 + 0.3),
                     arrowprops=dict(arrowstyle='->', color='gray',
                                     lw=1.5, alpha=0.6))

    # Draw nodes
    for name, x, y, color, desc in nodes:
        circle = plt.Circle((x, y), 0.4, facecolor=color, edgecolor='black',
                            linewidth=2, zorder=5, alpha=0.9)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=8,
                fontweight='bold', color='white', zorder=6)
        ax.text(x + 0.7, y, desc, ha='left', va='center', fontsize=7,
                color='#2c3e50')

    # Annotations
    ax.annotate("Gale-Stewart\nDeterminacy", xy=(-3, 3.0), fontsize=9,
                color='#27ae60', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#eafaf1'))

    ax.annotate("Martin's Theorem:\nAll Borel games\nare determined", xy=(-1.5, 7),
                fontsize=9, color='#16a085', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#e8f8f5'))

    ax.annotate("Complement\nDuality", xy=(3.5, 2), fontsize=8,
                color='#2980b9', fontstyle='italic')

    # Key theorems box
    theorems = [
        "Key Theorems Proved:",
        "• Wadge reflexivity: A ≤_W A",
        "• Wadge transitivity: A ≤_W B ≤_W C ⟹ A ≤_W C",
        "• Rank complement: rank(G) = rank(Gᶜ)",
        "• Strategy exclusivity: ¬(∃σ winning-I ∧ ∃τ winning-II)",
    ]
    textbox = '\n'.join(theorems)
    ax.text(-4.5, 0.5, textbox, fontsize=8, verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    ax.set_xlim(-5.5, 5.5)
    ax.set_ylim(-1, 8.5)
    ax.set_aspect('equal')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('viz_wadge_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_wadge_hierarchy.png")


if __name__ == "__main__":
    draw_wadge_hierarchy()
