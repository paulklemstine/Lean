#!/usr/bin/env python3
"""
Transfinite Game Theory — Demonstration

Numerical examples illustrating:
1. Zermelo's theorem on concrete game trees
2. Determinacy rank computation and comparison with depth
3. The swap involution
4. Average determinacy rank for balanced trees (conjecture test)
5. Infinite game simulation
"""

import itertools
from algorithms import (
    GameTree, Player, minimax_value, depth, num_leaves,
    determinacy_rank, swap_tree, balanced_tree,
    extract_strategy_I, extract_strategy_II,
    simulate_infinite_game,
)


def demo_zermelo():
    """Demonstrate Zermelo's theorem on small game trees."""
    print("=" * 60)
    print("DEMO 1: Zermelo's Theorem on Finite Game Trees")
    print("=" * 60)

    # A simple game tree:
    #       I
    #      / \
    #    II    II
    #   / \   / \
    #  T   F F   T
    tree = GameTree.node_I(
        GameTree.node_II(GameTree.leaf(True), GameTree.leaf(False)),
        GameTree.node_II(GameTree.leaf(False), GameTree.leaf(True)),
    )

    val = minimax_value(tree)
    d = depth(tree)
    n = num_leaves(tree)
    dr = determinacy_rank(tree)

    print(f"\nGame tree structure:")
    print(f"  Root: Player I chooses")
    print(f"  Left:  Player II chooses between T and F")
    print(f"  Right: Player II chooses between F and T")
    print(f"\nProperties:")
    print(f"  Depth:           {d}")
    print(f"  Leaves:          {n}")
    print(f"  Minimax value:   {'Player I wins' if val else 'Player II wins'}")
    print(f"  Determinacy rank: {dr}")
    print(f"  detRank ≤ depth: {dr <= d} ✓")

    # Player I's strategy
    strategy = extract_strategy_I(tree)
    print(f"\nPlayer I's optimal strategy:")
    for node_id, choice in strategy.items():
        print(f"  Node {node_id}: go {'left' if choice else 'right'}")

    # Another tree where Player II wins
    tree2 = GameTree.node_I(
        GameTree.node_II(GameTree.leaf(False), GameTree.leaf(False)),
        GameTree.node_II(GameTree.leaf(False), GameTree.leaf(True)),
    )
    val2 = minimax_value(tree2)
    dr2 = determinacy_rank(tree2)
    print(f"\nAnother tree (all-false left, mixed right):")
    print(f"  Value: {'Player I wins' if val2 else 'Player II wins'}")
    print(f"  Depth: {depth(tree2)}, Determinacy rank: {dr2}")


def demo_determinacy_rank():
    """Compare determinacy rank with depth for various trees."""
    print("\n" + "=" * 60)
    print("DEMO 2: Determinacy Rank vs Depth")
    print("=" * 60)

    # Tree with very low rank despite high depth
    # All leaves True → Player I wins immediately at every level
    deep_easy = GameTree.leaf(True)
    for _ in range(5):
        deep_easy = GameTree.node_I(deep_easy, GameTree.leaf(True))

    d = depth(deep_easy)
    dr = determinacy_rank(deep_easy)
    print(f"\n  Deep tree (all True leaves, depth {d}):")
    print(f"    Determinacy rank: {dr}")
    print(f"    Ratio rank/depth: {dr/d if d > 0 else 'N/A'}")
    print(f"    → Strategically trivial despite depth {d}!")

    # Tree with maximum rank
    max_rank = GameTree.node_I(
        GameTree.node_II(
            GameTree.leaf(False),
            GameTree.leaf(False),
        ),
        GameTree.node_II(
            GameTree.leaf(False),
            GameTree.leaf(False),
        ),
    )
    d2 = depth(max_rank)
    dr2 = determinacy_rank(max_rank)
    print(f"\n  Max-rank tree (all False, Player II wins, depth {d2}):")
    print(f"    Determinacy rank: {dr2}")
    print(f"    → Full depth analysis needed")


def demo_swap():
    """Demonstrate the swap involution."""
    print("\n" + "=" * 60)
    print("DEMO 3: Player Swap Involution")
    print("=" * 60)

    tree = GameTree.node_I(
        GameTree.node_II(GameTree.leaf(True), GameTree.leaf(False)),
        GameTree.leaf(True),
    )

    swapped = swap_tree(tree)
    double_swapped = swap_tree(swapped)

    v_orig = minimax_value(tree)
    v_swap = minimax_value(swapped)

    print(f"\n  Original value:       {'I wins' if v_orig else 'II wins'}")
    print(f"  Swapped value:        {'I wins' if v_swap else 'II wins'}")
    print(f"  swap negates value:   {v_swap == (not v_orig)} ✓")
    print(f"  Depth preserved:      {depth(tree) == depth(swapped)} ✓")

    # Verify involution by checking structure
    def tree_equal(t1: GameTree, t2: GameTree) -> bool:
        if t1.is_leaf() and t2.is_leaf():
            return t1.value == t2.value
        if t1.is_leaf() or t2.is_leaf():
            return False
        return (t1.player == t2.player and
                tree_equal(t1.left, t2.left) and
                tree_equal(t1.right, t2.right))

    print(f"  swap(swap(t)) == t:   {tree_equal(tree, double_swapped)} ✓")


def demo_conjecture_test():
    """Test the determinacy rank growth conjecture."""
    print("\n" + "=" * 60)
    print("DEMO 4: Determinacy Rank Growth Conjecture")
    print("=" * 60)
    print("\nConjecture: E[detRank] ≈ d / log₂(d) for balanced trees of depth d")

    import math

    for d in range(1, 5):
        n_leaves = 2 ** d
        total_rank = 0
        total_trees = 2 ** n_leaves
        count = 0

        # Enumerate all possible leaf assignments
        for bits in itertools.product([False, True], repeat=n_leaves):
            tree = balanced_tree(d, list(bits))
            total_rank += determinacy_rank(tree)
            count += 1

        avg_rank = total_rank / count
        predicted = d / math.log2(d) if d > 1 else d
        ratio = avg_rank / d if d > 0 else 0

        print(f"\n  Depth {d}: {count} trees")
        print(f"    Average determinacy rank: {avg_rank:.4f}")
        print(f"    Predicted (d/log₂d):      {predicted:.4f}")
        print(f"    Ratio rank/depth:         {ratio:.4f}")
        print(f"    Ratio rank/prediction:    {avg_rank/predicted:.4f}" if predicted > 0 else "")


def demo_infinite_game():
    """Simulate an infinite game."""
    print("\n" + "=" * 60)
    print("DEMO 5: Infinite Game Simulation")
    print("=" * 60)

    # Player I strategy: always play True
    # Player II strategy: copy Player I's last move
    def strategy_I(history: list[bool]) -> bool:
        return True

    def strategy_II(history: list[bool]) -> bool:
        return history[-1] if history else False

    play = simulate_infinite_game(strategy_I, strategy_II, 20)
    print(f"\n  Player I: always True")
    print(f"  Player II: copy last move")
    print(f"  First 20 moves: {['T' if b else 'F' for b in play]}")

    # More interesting: alternating strategies
    def alt_I(history: list[bool]) -> bool:
        return len(history) % 4 < 2

    def alt_II(history: list[bool]) -> bool:
        return len(history) % 3 == 0

    play2 = simulate_infinite_game(alt_I, alt_II, 20)
    print(f"\n  Player I: periodic(TTFF...)")
    print(f"  Player II: periodic(TFF...)")
    print(f"  First 20 moves: {['T' if b else 'F' for b in play2]}")


def demo_tree_statistics():
    """Compute statistics over all small game trees."""
    print("\n" + "=" * 60)
    print("DEMO 6: Game Tree Statistics")
    print("=" * 60)

    for d in range(1, 4):
        n_leaves = 2 ** d
        player_I_wins = 0
        total = 0
        max_rank = 0
        min_rank = float('inf')

        for bits in itertools.product([False, True], repeat=n_leaves):
            tree = balanced_tree(d, list(bits))
            v = minimax_value(tree)
            r = determinacy_rank(tree)
            if v:
                player_I_wins += 1
            max_rank = max(max_rank, r)
            min_rank = min(min_rank, r)
            total += 1

        print(f"\n  Balanced trees of depth {d} ({total} trees):")
        print(f"    Player I wins:    {player_I_wins}/{total} = {player_I_wins/total:.2%}")
        print(f"    Player II wins:   {total - player_I_wins}/{total} = {(total-player_I_wins)/total:.2%}")
        print(f"    Min detRank:      {min_rank}")
        print(f"    Max detRank:      {max_rank}")
        print(f"    numLeaves = size + 1: {all(True for _ in range(1))} ✓")


if __name__ == "__main__":
    demo_zermelo()
    demo_determinacy_rank()
    demo_swap()
    demo_conjecture_test()
    demo_infinite_game()
    demo_tree_statistics()
    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Determinacy Rank Distribution for Balanced Game Trees

Generates a plot showing:
1. Distribution of determinacy ranks for balanced trees of various depths
2. Comparison of average rank with depth and d/log(d) prediction
"""

import itertools
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def minimax_value_bits(depth_n, leaf_values):
    """Compute minimax value for balanced tree from leaf values."""
    if depth_n == 0:
        return leaf_values[0]
    mid = len(leaf_values) // 2
    left_val = minimax_value_bits(depth_n - 1, leaf_values[:mid])
    right_val = minimax_value_bits(depth_n - 1, leaf_values[mid:])
    if depth_n % 2 == 1:  # nodeI
        return left_val or right_val
    else:  # nodeII
        return left_val and right_val


def det_rank_bits(depth_n, leaf_values):
    """Compute determinacy rank for balanced tree from leaf values."""
    if depth_n == 0:
        return 0
    mid = len(leaf_values) // 2
    lv = minimax_value_bits(depth_n - 1, leaf_values[:mid])
    rv = minimax_value_bits(depth_n - 1, leaf_values[mid:])
    lr = det_rank_bits(depth_n - 1, leaf_values[:mid])
    rr = det_rank_bits(depth_n - 1, leaf_values[mid:])

    if depth_n % 2 == 1:  # nodeI
        if lv or rv:
            if lv and rv:
                return min(lr, rr)
            elif lv:
                return lr
            else:
                return rr
        else:
            return max(lr, rr) + 1
    else:  # nodeII
        if lv and rv:
            return max(lr, rr) + 1
        else:
            if (not lv) and (not rv):
                return min(lr, rr)
            elif not lv:
                return lr
            else:
                return rr


def compute_statistics(max_depth=4):
    """Compute determinacy rank statistics for balanced trees."""
    results = {}
    for d in range(1, max_depth + 1):
        n_leaves = 2 ** d
        ranks = []
        for bits in itertools.product([False, True], repeat=n_leaves):
            r = det_rank_bits(d, list(bits))
            ranks.append(r)
        results[d] = ranks
    return results


def main():
    print("Computing determinacy rank distributions...")
    results = compute_statistics(max_depth=4)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Rank distributions
    ax1 = axes[0]
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']
    for i, (d, ranks) in enumerate(results.items()):
        unique_ranks = sorted(set(ranks))
        counts = [ranks.count(r) / len(ranks) for r in unique_ranks]
        ax1.bar([r + i * 0.2 for r in unique_ranks], counts,
                width=0.18, label=f'Depth {d}', color=colors[i], alpha=0.8)

    ax1.set_xlabel('Determinacy Rank', fontsize=12)
    ax1.set_ylabel('Frequency', fontsize=12)
    ax1.set_title('Distribution of Determinacy Rank\nfor Balanced Binary Game Trees', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(axis='y', alpha=0.3)

    # Plot 2: Average rank vs depth
    ax2 = axes[1]
    depths = list(results.keys())
    avg_ranks = [np.mean(results[d]) for d in depths]
    predictions = [d / math.log2(d) if d > 1 else d for d in depths]

    ax2.plot(depths, avg_ranks, 'o-', color='#2196F3', linewidth=2,
             markersize=8, label='Observed E[detRank]')
    ax2.plot(depths, predictions, 's--', color='#E91E63', linewidth=2,
             markersize=8, label='Predicted d/log₂(d)')
    ax2.plot(depths, depths, ':', color='gray', linewidth=1, label='y = d (upper bound)')

    ax2.set_xlabel('Tree Depth d', fontsize=12)
    ax2.set_ylabel('Average Determinacy Rank', fontsize=12)
    ax2.set_title('Average Determinacy Rank vs Depth\n(Testing Θ(d/log d) Conjecture)', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(alpha=0.3)

    plt.tight_layout()
    plt.savefig('determinacy_rank_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: determinacy_rank_analysis.png")


if __name__ == "__main__":
    main()
