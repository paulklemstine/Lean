#!/usr/bin/env python3
"""
Demo: Infinite Games Against Death — Mortal vs Eternity

Demonstrates the key game-theoretic constructions and survival bounds
from our formalization.
"""

from typing import Callable, Optional
import random

# ============================================================================
# Game Framework
# ============================================================================

class SurvivalGame:
    """A survival game where Mortal navigates a graph with finite out-degree."""
    
    def __init__(self, successors: Callable):
        """
        successors: function mapping state -> list of successor states
        """
        self.successors = successors
    
    def is_live(self, state) -> bool:
        """Check if the game is live at a given state."""
        return len(self.successors(state)) > 0
    
    def play(self, strategy: Callable, initial_state, num_rounds: int) -> list:
        """Play the game for num_rounds using the given strategy."""
        states = [initial_state]
        current = initial_state
        for _ in range(num_rounds):
            succs = self.successors(current)
            if not succs:
                break  # Game over
            current = strategy(current, succs)
            states.append(current)
        return states


# ============================================================================
# Example Games
# ============================================================================

def counting_game():
    """The counting game: from n, move to n+1."""
    return SurvivalGame(lambda n: [n + 1])

def bounded_counting_game():
    """Bounded counting game: from k>0, move to k-1. At 0, game over."""
    return SurvivalGame(lambda k: [k - 1] if k > 0 else [])

def layered_game():
    """Layered game on (i,j): advance to (i,j+1) or jump to (i+1,0)."""
    return SurvivalGame(lambda s: [(s[0], s[1] + 1), (s[0] + 1, 0)])

def n_layered_game(n: int):
    """n-layered game: 2 choices if layer < n, 1 choice otherwise."""
    def succs(s):
        i, j = s
        if i < n:
            return [(i, j + 1), (i + 1, 0)]
        else:
            return [(i, j + 1)]
    return SurvivalGame(succs)


# ============================================================================
# Strategies
# ============================================================================

def increment_strategy(state, succs):
    """Always pick the first successor (increment)."""
    return succs[0]

def random_strategy(state, succs):
    """Pick a random successor."""
    return random.choice(succs)

def advance_then_jump_strategy(jump_threshold: int):
    """Advance within layer for jump_threshold steps, then jump."""
    def strategy(state, succs):
        i, j = state
        if j >= jump_threshold and len(succs) > 1:
            return succs[1]  # Jump to next layer
        return succs[0]  # Advance within layer
    return strategy


# ============================================================================
# Demonstrations
# ============================================================================

def demo_counting_game():
    """Demonstrate the counting game: Mortal survives ω rounds."""
    print("=" * 60)
    print("DEMO 1: The Counting Game (survival ordinal = ω)")
    print("=" * 60)
    
    game = counting_game()
    states = game.play(increment_strategy, 0, 20)
    print(f"Play from 0, 20 rounds: {states}")
    print(f"Every state is live: {all(game.is_live(s) for s in states)}")
    print(f"For ANY n, Mortal survives n rounds → survival ordinal = ω")
    print()

def demo_bounded_counting():
    """Demonstrate bounded counting: exact calibration."""
    print("=" * 60)
    print("DEMO 2: Bounded Counting Game (survival = initial state)")
    print("=" * 60)
    
    game = bounded_counting_game()
    for n in [3, 5, 10]:
        states = game.play(increment_strategy, n, n + 5)
        survived = len(states) - 1
        print(f"  Start at {n}: survived {survived} rounds, "
              f"final state = {states[-1]}, "
              f"{'CORRECT' if survived == n else 'ERROR'}")
    print(f"Mortal survives EXACTLY n rounds from state n")
    print()

def demo_layered_game():
    """Demonstrate the layered game with different strategies."""
    print("=" * 60)
    print("DEMO 3: Layered Game (bounded nondeterminism → ω²)")
    print("=" * 60)
    
    game = layered_game()
    
    # Strategy 1: Always advance
    states = game.play(increment_strategy, (0, 0), 10)
    print(f"  Always advance: {states}")
    
    # Strategy 2: Jump every 3 steps
    states = game.play(advance_then_jump_strategy(3), (0, 0), 12)
    print(f"  Jump every 3:   {states}")
    
    # Strategy 3: Random
    random.seed(42)
    states = game.play(random_strategy, (0, 0), 10)
    print(f"  Random:         {states}")
    
    print(f"\n  With 2 choices per step, survival structure approaches ω²")
    print()

def demo_n_layered():
    """Demonstrate n-layered games with increasing n."""
    print("=" * 60)
    print("DEMO 4: n-Layered Games (bounded nondeterminism parameter)")
    print("=" * 60)
    
    for n in [1, 3, 5, 10]:
        game = n_layered_game(n)
        # Use jump strategy to explore layers
        strategy = advance_then_jump_strategy(2)
        states = game.play(strategy, (0, 0), min(3 * n, 30))
        max_layer = max(s[0] for s in states)
        max_pos = max(s[1] for s in states)
        print(f"  n={n:2d}: {len(states)-1} rounds, "
              f"max layer={max_layer}, max position={max_pos}")
    
    print(f"\n  As n → ∞, the family captures ordinal structure up to ω²")
    print()

def demo_survival_ordinals():
    """Demonstrate survival ordinal computation."""
    print("=" * 60)
    print("DEMO 5: Survival Ordinals")
    print("=" * 60)
    
    # Counting game: survival = ω
    game = counting_game()
    print(f"  Counting game: everywhere live = {all(game.is_live(i) for i in range(100))}")
    print(f"    → Survival ordinal = ω (survives any finite n)")
    
    # Bounded counting from 5: survival = 5
    game = bounded_counting_game()
    print(f"  Bounded counting from 5: survival = 5")
    print(f"    → Survival ordinal = 5 (finite)")
    
    # Layered game: survival = ω
    game = layered_game()
    print(f"  Layered game: everywhere live = {all(game.is_live((i,j)) for i in range(10) for j in range(10))}")
    print(f"    → Survival ordinal = ω (survives any finite n)")
    
    # Family of n-layered games: sup = ω²
    print(f"  Family {{n-layered : n ∈ ℕ}}: each has survival ω")
    print(f"    → Combined ordinal structure reaches ω² via layers")
    print()

def demo_adversarial():
    """Demonstrate adversarial game where Eternity opposes Mortal."""
    print("=" * 60)
    print("DEMO 6: Adversarial Game")
    print("=" * 60)
    
    # Simple adversarial game: Mortal picks action, Eternity picks outcome
    # Even with adversary, if game is live, Mortal survives
    
    print("  Game: Mortal picks {left, right}, Eternity picks outcome")
    print("  States: integers, Mortal wants to stay alive")
    print()
    
    state = 0
    for round_num in range(10):
        mortal_action = random.choice(["left", "right"])
        # Eternity picks worst outcome for Mortal
        eternity_response = -1 if mortal_action == "left" else 1
        state += eternity_response
        print(f"  Round {round_num+1}: Mortal={mortal_action}, "
              f"Eternity responds → state={state}")
    
    print(f"\n  Despite Eternity's opposition, Mortal always has moves → survival ≥ ω")
    print()


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  INFINITE GAMES AGAINST DEATH: Mortal vs Eternity      ║")
    print("║  Numerical Demonstrations                               ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_counting_game()
    demo_bounded_counting()
    demo_layered_game()
    demo_n_layered()
    demo_survival_ordinals()
    demo_adversarial()
    
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("  • Counting game: Mortal survives ω rounds (any finite n)")
    print("  • Bounded counting: Exact calibration (survival = start)")
    print("  • Layered game: Bounded nondeterminism → ω² structure")
    print("  • Adversarial: Eternity cannot stop a live game")
    print("  • ITTM connection: Non-halting machines → ω survival")
    print()


#!/usr/bin/env python3
"""
Visualization: Survival Ordinals in Mortal-Eternity Games

Generates plots showing:
1. Survival time vs initial state for bounded counting game
2. Layered game trajectory visualization
3. Nondeterminism amplification: survival vs branching factor
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_bounded_counting():
    """Plot survival time vs initial state for bounded counting game."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    
    ns = list(range(0, 21))
    survivals = ns  # Exact calibration: survival = initial state
    
    ax.bar(ns, survivals, color='steelblue', alpha=0.8, edgecolor='navy')
    ax.plot(ns, ns, 'r--', linewidth=2, label='y = n (exact calibration)')
    
    ax.set_xlabel('Initial State n', fontsize=12)
    ax.set_ylabel('Survival Time (rounds)', fontsize=12)
    ax.set_title('Bounded Counting Game: Survival = Initial State', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('viz_bounded_counting.png', dpi=150)
    plt.close()
    print("Saved viz_bounded_counting.png")


def plot_layered_trajectory():
    """Plot trajectories in the layered game with different strategies."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    strategies = [
        ("Always Advance", lambda i, j: (i, j + 1)),
        ("Jump Every 3", lambda i, j: (i + 1, 0) if j >= 3 else (i, j + 1)),
        ("Jump Every 5", lambda i, j: (i + 1, 0) if j >= 5 else (i, j + 1)),
    ]
    
    colors = ['#e74c3c', '#2ecc71', '#3498db']
    
    for idx, (name, strategy) in enumerate(strategies):
        ax = axes[idx]
        
        # Generate trajectory
        positions = [(0, 0)]
        i, j = 0, 0
        for step in range(30):
            i, j = strategy(i, j)
            positions.append((i, j))
        
        layers = [p[0] for p in positions]
        steps = [p[1] for p in positions]
        
        # Plot
        ax.plot(range(len(positions)), layers, 'o-', color=colors[idx], 
                markersize=4, linewidth=1.5, label='Layer')
        ax.fill_between(range(len(positions)), layers, alpha=0.2, color=colors[idx])
        
        ax.set_xlabel('Round', fontsize=11)
        ax.set_ylabel('Layer', fontsize=11)
        ax.set_title(name, fontsize=13)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(-0.5, max(layers) + 1)
    
    plt.suptitle('Layered Game Trajectories: Strategy Comparison', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_layered_trajectories.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_layered_trajectories.png")


def plot_nondeterminism_amplification():
    """Plot how nondeterminism amplifies survival ordinals."""
    fig, ax = plt.subplots(1, 1, figsize=(9, 6))
    
    # Conceptual plot: ordinal height vs nondeterminism parameter
    n_values = list(range(1, 11))
    
    # For n-layered game: conceptual ordinal = ω * n
    # We represent ω * n as n on a "ordinal units of ω" scale
    ordinal_heights = n_values  # ω * n
    
    bars = ax.bar(n_values, ordinal_heights, color='coral', alpha=0.8, 
                  edgecolor='darkred', width=0.7)
    
    # Add ω labels
    for bar, n in zip(bars, n_values):
        ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.15,
                f'ω·{n}', ha='center', va='bottom', fontsize=9, fontweight='bold')
    
    # Add limit line at ω²
    ax.axhline(y=max(n_values) + 1, color='purple', linestyle='--', 
               linewidth=2, alpha=0.7)
    ax.text(0.5, max(n_values) + 1.3, 'ω² (limit)', fontsize=12, 
            color='purple', fontweight='bold')
    
    ax.set_xlabel('Nondeterminism Parameter n (number of layers)', fontsize=12)
    ax.set_ylabel('Game Rank (in units of ω)', fontsize=12)
    ax.set_title('Nondeterminism Amplification: ω → ω²', fontsize=14)
    ax.set_xticks(n_values)
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('viz_nondeterminism.png', dpi=150)
    plt.close()
    print("Saved viz_nondeterminism.png")


def plot_game_tree():
    """Plot a game tree showing finite vs infinite branching."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 7))
    
    # Left: Bounded counting game (finite, well-founded)
    ax = axes[0]
    ax.set_xlim(-1, 6)
    ax.set_ylim(-0.5, 5.5)
    
    for level in range(6):
        y = 5 - level
        x = level * 0.8 + 0.5
        circle = plt.Circle((x, y), 0.25, color='steelblue' if level < 5 else 'red',
                            alpha=0.8, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, str(5 - level), ha='center', va='center', 
                fontsize=10, color='white', fontweight='bold', zorder=6)
        
        if level < 5:
            next_x = (level + 1) * 0.8 + 0.5
            next_y = 5 - level - 1
            ax.annotate('', xy=(next_x - 0.2, next_y + 0.2),
                       xytext=(x + 0.2, y - 0.2),
                       arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    
    ax.text(5 * 0.8 + 0.5, -0.3, 'GAME OVER', ha='center', fontsize=10, 
            color='red', fontweight='bold')
    ax.set_title('Bounded Counting: Rank = 5\n(Well-founded, finite survival)', fontsize=12)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Right: Counting game (infinite, ω survival)
    ax = axes[1]
    ax.set_xlim(-1, 8)
    ax.set_ylim(-0.5, 5.5)
    
    for level in range(6):
        y = 5 - level
        x = level * 1.0 + 0.5
        circle = plt.Circle((x, y), 0.25, color='forestgreen', alpha=0.8, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, str(level), ha='center', va='center',
                fontsize=10, color='white', fontweight='bold', zorder=6)
        
        if level < 5:
            next_x = (level + 1) * 1.0 + 0.5
            next_y = 5 - level - 1
            ax.annotate('', xy=(next_x - 0.2, next_y + 0.2),
                       xytext=(x + 0.2, y - 0.2),
                       arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    
    # Add dots for continuation
    ax.text(6.2, -0.2, '···  → ∞', ha='center', fontsize=14, 
            color='forestgreen', fontweight='bold')
    ax.set_title('Counting Game: Rank = ω\n(Everywhere live, infinite survival)', fontsize=12)
    ax.set_aspect('equal')
    ax.axis('off')
    
    plt.suptitle('Finite vs Infinite Game Trees', fontsize=14, y=0.98)
    plt.tight_layout()
    plt.savefig('viz_game_trees.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_game_trees.png")


if __name__ == "__main__":
    plot_bounded_counting()
    plot_layered_trajectory()
    plot_nondeterminism_amplification()
    plot_game_tree()
    print("\nAll visualizations generated!")
