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
