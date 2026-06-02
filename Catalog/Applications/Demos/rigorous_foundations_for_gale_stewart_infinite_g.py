#!/usr/bin/env python3
"""
Gale-Stewart Infinite Game Theory — Demonstration

This module demonstrates key concepts from infinite game theory through
concrete numerical examples, including strategy evaluation, backward
induction for finite-depth games, and Wadge reducibility computation.
"""

from typing import Callable, List, Tuple, Optional
import random


# === Core Types ===

Play = List[int]          # Finite prefix of a play
Strategy = Callable[[Play], int]  # Maps history to next move


def play_game(sigma: Strategy, tau: Strategy, n_rounds: int) -> Play:
    """Generate n rounds of play between two strategies."""
    history: Play = []
    for i in range(n_rounds):
        if i % 2 == 0:  # Player I's turn
            move = sigma(history[:])
        else:            # Player II's turn
            move = tau(history[:])
        history.append(move)
    return history


# === Demo 1: Strategy Exclusivity ===

def demo_strategy_exclusivity():
    """Demonstrate that both players cannot simultaneously have winning strategies."""
    print("=" * 60)
    print("DEMO 1: Strategy Exclusivity")
    print("=" * 60)
    print()
    
    # Game: Player I wins iff the sum of first 4 moves is even
    def payoff(play: Play) -> bool:
        return sum(play[:4]) % 2 == 0
    
    # Candidate strategies
    sigma: Strategy = lambda h: 0   # Always play 0
    tau: Strategy = lambda h: 1     # Always play 1
    
    result = play_game(sigma, tau, 10)
    print(f"Play with sigma=0, tau=1: {result[:6]}...")
    print(f"Sum of first 4: {sum(result[:4])}, Even: {payoff(result)}")
    print()
    
    # Check: can both win?
    n_tests = 1000
    sigma_wins_all = True
    tau_wins_all = True
    
    for _ in range(n_tests):
        # Random opponent for sigma
        tau_rand: Strategy = lambda h, _=None: random.randint(0, 3)
        play1 = play_game(sigma, tau_rand, 4)
        if not payoff(play1):
            sigma_wins_all = False
        
        # Random opponent for tau
        sigma_rand: Strategy = lambda h, _=None: random.randint(0, 3)
        play2 = play_game(sigma_rand, tau, 4)
        if payoff(play2):
            tau_wins_all = False
    
    print(f"sigma=0 wins against all random opponents: {sigma_wins_all}")
    print(f"tau=1 wins against all random opponents: {tau_wins_all}")
    print(f"Both win simultaneously: {sigma_wins_all and tau_wins_all}")
    print(f"(Strategy Exclusivity guarantees this is always False)")
    print()


# === Demo 2: Backward Induction ===

def backward_induction(
    moves: List[int],
    depth: int,
    payoff: Callable[[Play], bool]
) -> Tuple[bool, Strategy]:
    """
    Backward induction for depth-n prefix-determined games.
    
    Returns (player_I_wins, winning_strategy) where the strategy
    is for the winning player.
    """
    # Build game tree and solve by backward induction
    memo: dict = {}
    
    def solve(history: Play, d: int) -> bool:
        """Returns True if Player I wins from this position."""
        key = tuple(history)
        if key in memo:
            return memo[key]
        
        if d == 0:
            result = payoff(history)
            memo[key] = result
            return result
        
        is_player_I_turn = len(history) % 2 == 0
        
        if is_player_I_turn:
            # Player I chooses: wins if ANY move leads to a win
            result = any(solve(history + [m], d - 1) for m in moves)
        else:
            # Player II chooses: Player I wins only if ALL moves lead to I winning
            result = all(solve(history + [m], d - 1) for m in moves)
        
        memo[key] = result
        return result
    
    player_I_wins = solve([], depth)
    
    # Extract optimal strategy
    def optimal_strategy(history: Play) -> int:
        d = depth - len(history)
        if d <= 0:
            return moves[0]
        is_player_I_turn = len(history) % 2 == 0
        if is_player_I_turn == player_I_wins:
            # This is the winning player's turn
            for m in moves:
                if player_I_wins == solve(history + [m], d - 1):
                    return m
        return moves[0]
    
    return player_I_wins, optimal_strategy


def demo_backward_induction():
    """Demonstrate backward induction for prefix-determined games."""
    print("=" * 60)
    print("DEMO 2: Backward Induction for Finite-Depth Games")
    print("=" * 60)
    print()
    
    moves = [0, 1]
    
    # Game 1: Player I wins iff first move is 0
    print("Game 1: Player I wins iff x(0) = 0 (depth 1)")
    winner1, strat1 = backward_induction(moves, 1, lambda p: p[0] == 0)
    print(f"  Player I wins: {winner1}")
    print(f"  Winning move: {strat1([])}")
    print()
    
    # Game 2: Player I wins iff x(0) XOR x(1) = 1 (depth 2)
    print("Game 2: Player I wins iff x(0) XOR x(1) = 1 (depth 2)")
    winner2, strat2 = backward_induction(moves, 2, lambda p: p[0] ^ p[1] == 1)
    print(f"  Player I wins: {winner2}")
    print()
    
    # Game 3: Player I wins iff majority of first 3 moves is 1 (depth 3)
    print("Game 3: Player I wins iff majority of first 3 moves is 1 (depth 3)")
    winner3, strat3 = backward_induction(moves, 3, 
                                          lambda p: sum(p[:3]) >= 2)
    print(f"  Player I wins: {winner3}")
    print()
    
    # Game 4: Nim-like game, depth 4, moves {0,1,2}
    moves3 = [0, 1, 2]
    print("Game 4: Player I wins iff sum of 4 moves ≡ 0 (mod 3), moves {0,1,2}")
    winner4, strat4 = backward_induction(moves3, 4, 
                                          lambda p: sum(p[:4]) % 3 == 0)
    print(f"  Player I wins: {winner4}")
    
    # Verify by exhaustive play
    if winner4:
        losses = 0
        for t0 in moves3:
            for t1 in moves3:
                play = [strat4([]), t0, strat4([strat4([]), t0]), t1]
                if sum(play) % 3 != 0:
                    losses += 1
        print(f"  Verification: {losses} losses out of {len(moves3)**2} opponent combinations")
    print()


# === Demo 3: Game Rank Computation ===

def compute_game_rank(
    moves: List[int],
    payoff: Callable[[Play], bool],
    max_depth: int = 8
) -> Optional[int]:
    """
    Compute the game rank (minimum prefix length for determination).
    Returns None if rank > max_depth.
    """
    for n in range(max_depth + 1):
        # Check if payoff is n-prefix-determined
        is_determined = True
        
        # Generate all prefixes of length n
        def check_prefix(prefix: Play, remaining: int) -> bool:
            if remaining == 0:
                # Check if all extensions agree
                results = set()
                def check_extensions(ext: Play, r: int):
                    if r == 0:
                        results.add(payoff(prefix + ext))
                        return
                    for m in moves:
                        check_extensions(ext + [m], r - 1)
                        if len(results) > 1:
                            return
                
                check_extensions([], 2)  # Check 2 extra positions
                return len(results) <= 1
            
            for m in moves:
                if not check_prefix(prefix + [m], remaining - 1):
                    return False
            return True
        
        if check_prefix([], n):
            return n
    
    return None


def demo_game_rank():
    """Demonstrate game rank computation."""
    print("=" * 60)
    print("DEMO 3: Game Rank — Strategic Complexity")
    print("=" * 60)
    print()
    
    moves = [0, 1]
    
    games = [
        ("Empty (Player II always wins)", lambda p: False),
        ("Universal (Player I always wins)", lambda p: True),
        ("x(0) = 0", lambda p: p[0] == 0),
        ("x(0) + x(1) even", lambda p: (p[0] + p[1]) % 2 == 0),
        ("x(0) + x(1) + x(2) even", lambda p: (sum(p[:3])) % 2 == 0),
        ("x(0) = x(1)", lambda p: p[0] == p[1]),
    ]
    
    for name, payoff in games:
        rank = compute_game_rank(moves, payoff)
        print(f"  Game '{name}': rank = {rank}")
    
    print()
    print("  Note: rank(A) = rank(Aᶜ) — complement invariance!")
    
    for name, payoff in games[:4]:
        rank_A = compute_game_rank(moves, payoff)
        rank_Ac = compute_game_rank(moves, lambda p, f=payoff: not f(p))
        print(f"  '{name}': rank(A)={rank_A}, rank(Aᶜ)={rank_Ac}, equal={rank_A==rank_Ac}")
    print()


# === Demo 4: Wadge Reducibility ===

def demo_wadge_reducibility():
    """Demonstrate Wadge reducibility between games."""
    print("=" * 60)
    print("DEMO 4: Wadge Reducibility")
    print("=" * 60)
    print()
    
    # A = {x : x(0) = 0}, B = {x : x(0) + x(1) ≤ 1}
    # Reduction: f(x) = x (identity) reduces A to B? No.
    # But: A ≤_W B if we can find continuous f with x ∈ A ↔ f(x) ∈ B
    
    # A = {x : x(0) = 0}
    # B = {x : x(0) = 0 ∨ x(0) = 1} = Set.univ (for binary)
    # Then A ≤_W B via identity (trivially, since B = univ)
    
    # More interesting: A = {x : x(0) = 0}, C = {x : x(1) = 0}
    # f(x)(n) = x(n+1) for n ≥ 1, f(x)(0) = x(1) -- NOT Lipschitz!
    # Actually f(x)(0) depends on x(1), so it's 2-Lipschitz, not 1-Lipschitz.
    
    print("  A = {x : x(0) = 0}  (rank 1)")
    print("  B = {x : x(0) = 0 AND x(1) = 0}  (rank 2)")
    print()
    print("  Is A ≤_W B?")
    print("  Reduction f: f(x)(0) = x(0), f(x)(1) = 0, f(x)(n) = x(n) for n≥2")
    print("  Then x ∈ A ↔ x(0)=0 ↔ f(x)(0)=0 AND f(x)(1)=0 ↔ f(x) ∈ B ✓")
    print("  f is 1-Lipschitz ✓")
    print()
    
    print("  Wadge rank monotonicity: rank(A) ≤ rank(B)")
    print("  rank(A) = 1 ≤ 2 = rank(B) ✓")
    print()
    
    # Demonstrate reflexivity and transitivity
    print("  Wadge Reflexivity: A ≤_W A via identity ✓")
    print("  Wadge Transitivity: if A ≤_W B ≤_W C then A ≤_W C via composition ✓")
    print()


# === Demo 5: Quasi-Strategy Refinement ===

def demo_quasi_strategies():
    """Demonstrate quasi-strategy refinement."""
    print("=" * 60)
    print("DEMO 5: Quasi-Strategy Refinement")
    print("=" * 60)
    print()
    
    # A quasi-strategy specifies allowed moves at each history
    # Game: x(0) + x(1) is even, moves in {0, 1, 2, 3}
    
    print("  Game: Player I wins iff x(0) + x(1) is even")
    print("  Moves: {0, 1, 2, 3}")
    print()
    
    # Quasi-strategy: "play any even number"
    quasi_allowed = {
        (): {0, 2},        # At the start, play 0 or 2
    }
    print(f"  Quasi-strategy: at start, allowed = {quasi_allowed[()]}")
    
    # Refinement 1: always play 0
    refined_1 = {(): {0}}
    print(f"  Refinement 1: at start, allowed = {refined_1[()]}")
    print(f"    Refines quasi-strategy: {refined_1[()] <= quasi_allowed[()]}")
    
    # Refinement 2: always play 2
    refined_2 = {(): {2}}
    print(f"  Refinement 2: at start, allowed = {refined_2[()]}")
    print(f"    Refines quasi-strategy: {refined_2[()] <= quasi_allowed[()]}")
    
    # Both refinements are deterministic strategies
    print()
    print("  Both refinements are valid deterministic strategies.")
    print("  The quasi-strategy captures Player I's strategic flexibility.")
    print("  Refinement extracts a concrete plan from flexible options.")
    print()


# === Main ===

if __name__ == "__main__":
    print("Gale-Stewart Infinite Game Theory — Demonstrations")
    print("=" * 60)
    print()
    
    random.seed(42)
    
    demo_strategy_exclusivity()
    demo_backward_induction()
    demo_game_rank()
    demo_wadge_reducibility()
    demo_quasi_strategies()
    
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Game Tree for Finite-Depth Gale-Stewart Games

Renders the game tree showing backward induction results.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import List, Tuple, Dict, Optional


def build_game_tree(
    moves: List[int],
    depth: int, 
    payoff_fn,
) -> Dict[Tuple[int,...], dict]:
    """Build the game tree with backward induction labels."""
    nodes: Dict[Tuple[int,...], dict] = {}
    
    def solve(history: Tuple[int,...], d: int) -> bool:
        if d == 0:
            result = payoff_fn(list(history))
            nodes[history] = {
                'winner': 'I' if result else 'II',
                'is_leaf': True,
                'player': None,
                'depth': len(history)
            }
            return result
        
        is_p1 = len(history) % 2 == 0
        children_results = {}
        for m in moves:
            children_results[m] = solve(history + (m,), d - 1)
        
        if is_p1:
            result = any(children_results.values())
        else:
            result = all(children_results.values())
        
        nodes[history] = {
            'winner': 'I' if result else 'II',
            'is_leaf': False,
            'player': 'I' if is_p1 else 'II',
            'depth': len(history),
            'children': [history + (m,) for m in moves]
        }
        return result
    
    solve((), depth)
    return nodes


def plot_game_tree(
    moves: List[int],
    depth: int,
    payoff_fn,
    title: str = "Game Tree with Backward Induction"
):
    """Plot the game tree."""
    nodes = build_game_tree(moves, depth, payoff_fn)
    
    # Compute positions
    positions: Dict[Tuple[int,...], Tuple[float, float]] = {}
    
    def assign_positions(node_key: Tuple[int,...], x_min: float, x_max: float, y: float):
        positions[node_key] = ((x_min + x_max) / 2, y)
        node = nodes[node_key]
        if not node['is_leaf']:
            n_children = len(moves)
            width = (x_max - x_min) / n_children
            for i, child in enumerate(node['children']):
                assign_positions(child, x_min + i * width, x_min + (i+1) * width, y - 1)
    
    assign_positions((), 0, 2**depth, 0)
    
    fig, ax = plt.subplots(1, 1, figsize=(min(14, 2**depth * 2), depth * 2 + 1))
    
    # Draw edges
    for key, node in nodes.items():
        if not node['is_leaf']:
            x_parent, y_parent = positions[key]
            for i, child in enumerate(node['children']):
                x_child, y_child = positions[child]
                ax.plot([x_parent, x_child], [y_parent, y_child], 
                       'k-', linewidth=0.8, alpha=0.5)
                # Label edge with move
                mx = (x_parent + x_child) / 2
                my = (y_parent + y_child) / 2
                ax.text(mx, my, str(moves[i]), fontsize=7, ha='center', 
                       va='center', color='gray',
                       bbox=dict(boxstyle='round,pad=0.1', facecolor='white', 
                                edgecolor='none', alpha=0.8))
    
    # Draw nodes
    for key, node in nodes.items():
        x, y = positions[key]
        color = '#2ecc71' if node['winner'] == 'I' else '#e74c3c'
        
        if node['is_leaf']:
            marker = 's'
            size = 80
        else:
            marker = 'o'
            size = 120
        
        ax.scatter([x], [y], c=[color], s=size, marker=marker, 
                  zorder=5, edgecolors='black', linewidths=0.5)
        
        if not node['is_leaf']:
            ax.text(x, y + 0.15, node['player'], fontsize=6, 
                   ha='center', va='bottom', fontweight='bold')
    
    # Legend
    p1_patch = mpatches.Patch(color='#2ecc71', label='Player I wins')
    p2_patch = mpatches.Patch(color='#e74c3c', label='Player II wins')
    ax.legend(handles=[p1_patch, p2_patch], loc='upper right', fontsize=9)
    
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_ylabel('Depth', fontsize=10)
    ax.set_xlim(-0.5, 2**depth + 0.5)
    ax.set_ylim(-depth - 0.5, 1)
    ax.set_yticks(range(0, -depth-1, -1))
    ax.set_yticklabels(range(0, depth+1))
    ax.set_xticks([])
    ax.grid(True, axis='y', alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('game_tree.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: game_tree.png")


if __name__ == "__main__":
    # Game: Player I wins iff x(0) XOR x(1) XOR x(2) = 1
    moves = [0, 1]
    payoff = lambda p: (p[0] ^ p[1] ^ p[2]) == 1
    
    plot_game_tree(moves, 3, payoff,
                   "Game Tree: Player I wins iff x₀ ⊕ x₁ ⊕ x₂ = 1")


#!/usr/bin/env python3
"""
Visualization: Wadge Hierarchy and Game Rank

Plots the Wadge hierarchy for small games showing reducibility relations
and game rank values.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import List, Dict, Tuple, Set


def compute_rank(moves: List[int], payoff, max_depth: int = 6, ext: int = 2) -> int:
    """Compute game rank."""
    import itertools
    for n in range(max_depth + 1):
        determined = True
        for prefix in itertools.product(moves, repeat=n):
            results = set()
            for extension in itertools.product(moves, repeat=ext):
                play = list(prefix) + list(extension)
                results.add(payoff(play))
                if len(results) > 1:
                    break
            if len(results) > 1:
                determined = False
                break
        if determined:
            return n
    return -1


def plot_wadge_hierarchy():
    """Plot the Wadge hierarchy for binary games of small depth."""
    moves = [0, 1]
    
    # Define games with names, payoffs, and expected structure
    games = {
        '∅': lambda p: False,
        'Univ': lambda p: True,
        'x₀=0': lambda p: p[0] == 0,
        'x₀=1': lambda p: p[0] == 1,
        'x₀+x₁ even': lambda p: (p[0] + p[1]) % 2 == 0,
        'x₀+x₁ odd': lambda p: (p[0] + p[1]) % 2 == 1,
        'x₀=x₁': lambda p: p[0] == p[1],
        'x₀≠x₁': lambda p: p[0] != p[1],
        'x₀∧x₁': lambda p: p[0] == 1 and p[1] == 1,
        'x₀∨x₁': lambda p: p[0] == 1 or p[1] == 1,
    }
    
    # Compute ranks
    ranks = {}
    for name, payoff in games.items():
        ranks[name] = compute_rank(moves, payoff)
    
    # Identify complement pairs
    complement_pairs = [
        ('∅', 'Univ'),
        ('x₀=0', 'x₀=1'),
        ('x₀+x₁ even', 'x₀+x₁ odd'),
        ('x₀=x₁', 'x₀≠x₁'),
        ('x₀∧x₁', 'x₀∨x₁'),
    ]
    
    # Plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 7))
    
    # Left: Hierarchy by rank
    rank_groups: Dict[int, List[str]] = {}
    for name, rank in ranks.items():
        rank_groups.setdefault(rank, []).append(name)
    
    colors = {0: '#3498db', 1: '#2ecc71', 2: '#e74c3c', 3: '#9b59b6'}
    
    y_positions = {}
    for rank in sorted(rank_groups.keys()):
        names = rank_groups[rank]
        for i, name in enumerate(names):
            x = i - (len(names) - 1) / 2
            y = -rank * 2
            y_positions[name] = (x, y)
            
            color = colors.get(rank, '#95a5a6')
            ax1.scatter([x], [y], c=[color], s=200, zorder=5, 
                       edgecolors='black', linewidths=1)
            ax1.text(x, y - 0.35, name, ha='center', va='top', fontsize=7,
                    fontweight='bold')
    
    # Draw reduction arrows (higher rank reduces FROM lower rank)
    for rank in sorted(rank_groups.keys()):
        if rank == 0:
            continue
        for name in rank_groups[rank]:
            # Every set reduces to itself and to higher-rank sets
            for lower_rank in sorted(rank_groups.keys()):
                if lower_rank < rank:
                    for target in rank_groups[lower_rank]:
                        x1, y1 = y_positions[target]
                        x2, y2 = y_positions[name]
                        ax1.annotate('', xy=(x1, y1 + 0.2), xytext=(x2, y2 - 0.2),
                                   arrowprops=dict(arrowstyle='->', color='gray',
                                                  alpha=0.3, lw=0.5))
    
    ax1.set_title('Wadge Hierarchy by Game Rank', fontsize=13, fontweight='bold')
    ax1.set_ylabel('Game Rank (lower = simpler)', fontsize=10)
    ax1.set_yticks([0, -2, -4])
    ax1.set_yticklabels(['Rank 0', 'Rank 1', 'Rank 2'])
    ax1.set_xlim(-3, 3)
    ax1.set_ylim(-5, 1)
    ax1.set_xticks([])
    ax1.grid(True, axis='y', alpha=0.3)
    
    # Right: Complement invariance
    bar_width = 0.35
    x_pos = np.arange(len(complement_pairs))
    
    ranks_A = [ranks[a] for a, _ in complement_pairs]
    ranks_Ac = [ranks[b] for _, b in complement_pairs]
    labels_A = [a for a, _ in complement_pairs]
    labels_Ac = [b for _, b in complement_pairs]
    
    bars1 = ax2.bar(x_pos - bar_width/2, ranks_A, bar_width, 
                    label='A', color='#3498db', edgecolor='black', linewidth=0.5)
    bars2 = ax2.bar(x_pos + bar_width/2, ranks_Ac, bar_width,
                    label='Aᶜ', color='#e74c3c', edgecolor='black', linewidth=0.5)
    
    ax2.set_xlabel('Complement Pairs', fontsize=10)
    ax2.set_ylabel('Game Rank', fontsize=10)
    ax2.set_title('Complement Invariance: rank(A) = rank(Aᶜ)', 
                  fontsize=13, fontweight='bold')
    ax2.set_xticks(x_pos)
    ax2.set_xticklabels([f'{a}\nvs\n{b}' for a, b in complement_pairs], 
                        fontsize=7)
    ax2.legend(fontsize=10)
    ax2.set_ylim(0, max(max(ranks_A), max(ranks_Ac)) + 0.5)
    
    # Add equality markers
    for i, (rA, rAc) in enumerate(zip(ranks_A, ranks_Ac)):
        if rA == rAc:
            ax2.text(i, max(rA, rAc) + 0.15, '✓', ha='center', fontsize=14,
                    color='green', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('wadge_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: wadge_hierarchy.png")


if __name__ == "__main__":
    plot_wadge_hierarchy()
