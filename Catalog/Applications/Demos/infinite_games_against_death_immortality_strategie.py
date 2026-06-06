#!/usr/bin/env python3
"""
Asymmetric Duration Games: Mortal vs Eternity
Demo showing the ascending strategy in action.
"""

from typing import List, Set, Tuple
import random

def ascending_strategy(banned: Set[int]) -> int:
    """The ascending strategy: pick max(banned) + 1, or 0 if empty."""
    if not banned:
        return 0
    return max(banned) + 1

def random_eternity(banned: Set[int], mortal_pos: int) -> int:
    """Random Eternity: ban a random position."""
    return random.randint(0, mortal_pos + 10)

def adversarial_eternity(banned: Set[int], mortal_pos: int) -> int:
    """Adversarial Eternity: always ban Mortal's current position + 1."""
    return mortal_pos + 1

def play_game(mortal_strat, eternity_strat, n_rounds: int) -> Tuple[List[int], List[int], bool]:
    """Play the evasion game for n rounds.
    
    Returns (mortal_moves, eternity_bans, survived).
    """
    banned: Set[int] = set()
    mortal_moves = []
    eternity_bans = []
    survived = True
    
    for i in range(n_rounds):
        pos = mortal_strat(banned)
        if pos in banned:
            survived = False
            mortal_moves.append(pos)
            break
        mortal_moves.append(pos)
        ban = eternity_strat(banned, pos)
        eternity_bans.append(ban)
        banned.add(ban)
    
    return mortal_moves, eternity_bans, survived


def demo_basic_survival():
    """Demo: ascending strategy vs various Eternity strategies."""
    print("=" * 60)
    print("DEMO 1: Basic Evasion Game - Ascending Strategy")
    print("=" * 60)
    
    for n in [5, 10, 20, 50]:
        moves, bans, survived = play_game(ascending_strategy, random_eternity, n)
        status = "SURVIVED" if survived else "CAUGHT"
        print(f"\n  {n} rounds vs Random Eternity: {status}")
        print(f"    Mortal's moves (first 10): {moves[:10]}...")
        print(f"    Eternity's bans (first 10): {bans[:10]}...")
    
    print("\n  Against Adversarial Eternity (bans pos+1):")
    for n in [5, 10, 20]:
        moves, bans, survived = play_game(ascending_strategy, adversarial_eternity, n)
        status = "SURVIVED" if survived else "CAUGHT"
        print(f"    {n} rounds: {status} - moves: {moves}")


def cardinality_strategy(banned: Set[int]) -> int:
    """Cardinality strategy: pick |banned| as position."""
    return len(banned)

def demo_strategy_comparison():
    """Demo: compare ascending vs cardinality strategies."""
    print("\n" + "=" * 60)
    print("DEMO 2: Strategy Comparison")
    print("=" * 60)
    
    # Targeted Eternity that specifically targets cardinality strategy
    def targeting_eternity(banned: Set[int], mortal_pos: int) -> int:
        """Ban the next cardinality value."""
        return len(banned) + 1
    
    print("\n  Ascending strategy vs targeting Eternity:")
    moves, bans, survived = play_game(ascending_strategy, targeting_eternity, 10)
    print(f"    Survived: {survived}, moves: {moves}")
    
    print("\n  Cardinality strategy vs targeting Eternity:")
    moves, bans, survived = play_game(cardinality_strategy, targeting_eternity, 10)
    print(f"    Survived: {survived}, moves: {moves}")
    print(f"    Bans: {bans}")


def demo_omega_squared():
    """Demo: ω²-survival via epoch composition."""
    print("\n" + "=" * 60)
    print("DEMO 3: ω²-Survival via Epoch Composition")
    print("=" * 60)
    
    print("\n  Testing m × n survival for various (m, n):")
    for m in [1, 2, 5, 10]:
        for n_val in [1, 2, 5, 10]:
            total = m * n_val
            _, _, survived = play_game(ascending_strategy, random_eternity, total)
            print(f"    m={m}, n={n_val}, total={total}: {'SURVIVED' if survived else 'FAILED'}")


def demo_power_eternity():
    """Demo: k-power Eternity (banning k positions per round)."""
    print("\n" + "=" * 60)
    print("DEMO 4: Power Eternity (k bans per round)")
    print("=" * 60)
    
    for k in [1, 2, 5, 10]:
        banned: Set[int] = set()
        survived = True
        rounds = 20
        
        for i in range(rounds):
            pos = ascending_strategy(banned)
            if pos in banned:
                survived = False
                break
            # Eternity bans k positions
            for j in range(k):
                banned.add(random.randint(0, pos + 10 * k))
        
        print(f"  k={k}: {'SURVIVED' if survived else 'CAUGHT'} after {rounds} rounds "
              f"({len(banned)} positions banned)")


def demo_finite_boundary():
    """Demo: on Fin(k), Mortal is doomed after k rounds."""
    print("\n" + "=" * 60)
    print("DEMO 5: Boundary - Finite State Space Fin(k)")
    print("=" * 60)
    
    for k in [3, 5, 8, 10]:
        banned: Set[int] = set()
        survived_rounds = 0
        
        for i in range(k + 5):
            # Find a position in {0, ..., k-1} not in banned
            available = [x for x in range(k) if x not in banned]
            if not available:
                break
            pos = available[0]
            survived_rounds += 1
            # Eternity bans a position
            banned.add(pos)  # Worst case: ban the position Mortal just used
        
        print(f"  Fin({k}): survived {survived_rounds} rounds (max possible: {k})")


if __name__ == "__main__":
    random.seed(42)
    demo_basic_survival()
    demo_strategy_comparison()
    demo_omega_squared()
    demo_power_eternity()
    demo_finite_boundary()
    
    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Survival Game Dynamics
Shows Mortal's trajectory vs Eternity's bans over time.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import random

def ascending_strategy(banned):
    if not banned:
        return 0
    return max(banned) + 1

def random_eternity(banned, pos):
    return random.randint(0, pos + 5)

def adversarial_eternity(banned, pos):
    return pos + 1

def play_game(mortal, eternity, n_rounds):
    banned = set()
    mortal_moves = []
    eternity_bans = []
    for i in range(n_rounds):
        pos = mortal(banned)
        mortal_moves.append(pos)
        ban = eternity(banned, pos)
        eternity_bans.append(ban)
        banned.add(ban)
    return mortal_moves, eternity_bans

def main():
    random.seed(42)
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Asymmetric Duration Games: Mortal vs Eternity', fontsize=16, fontweight='bold')

    # Plot 1: Ascending strategy vs random Eternity
    ax = axes[0, 0]
    n = 30
    moves, bans = play_game(ascending_strategy, random_eternity, n)
    rounds = list(range(n))
    ax.plot(rounds, moves, 'b-o', label='Mortal (ascending)', markersize=4, linewidth=1.5)
    ax.scatter(rounds, bans, c='red', marker='x', s=40, label='Eternity bans', zorder=5)
    ax.fill_between(rounds, 0, [max(bans[:i+1]) if bans[:i+1] else 0 for i in range(n)],
                     alpha=0.1, color='red', label='Banned zone')
    ax.set_xlabel('Round')
    ax.set_ylabel('Position')
    ax.set_title('Ascending Strategy vs Random Eternity')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Plot 2: Ascending strategy vs adversarial Eternity
    ax = axes[0, 1]
    moves, bans = play_game(ascending_strategy, adversarial_eternity, n)
    ax.plot(rounds, moves, 'b-o', label='Mortal (ascending)', markersize=4, linewidth=1.5)
    ax.scatter(rounds, bans, c='red', marker='x', s=40, label='Eternity bans', zorder=5)
    ax.set_xlabel('Round')
    ax.set_ylabel('Position')
    ax.set_title('Ascending Strategy vs Adversarial Eternity')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Plot 3: Game state size over time (k-power Eternity)
    ax = axes[1, 0]
    for k in [1, 2, 5, 10]:
        sizes = []
        banned = set()
        for i in range(30):
            pos = ascending_strategy(banned)
            for j in range(k):
                banned.add(random.randint(0, pos + 5*k))
            sizes.append(len(banned))
        ax.plot(range(30), sizes, label=f'k={k} power', linewidth=1.5)
    ax.plot(range(30), range(30), 'k--', alpha=0.3, label='n (reference)')
    ax.set_xlabel('Round')
    ax.set_ylabel('|Banned set|')
    ax.set_title('Banned Set Growth: k-Power Eternity')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Plot 4: Finite vs infinite survival
    ax = axes[1, 1]
    finite_sizes = [3, 5, 8, 10, 15, 20]
    max_survival = []
    for k in finite_sizes:
        banned = set()
        survived = 0
        for i in range(k + 5):
            available = [x for x in range(k) if x not in banned]
            if not available:
                break
            survived += 1
            banned.add(available[0])
        max_survival.append(survived)
    
    ax.bar(range(len(finite_sizes)), max_survival, color='steelblue', alpha=0.7)
    ax.plot(range(len(finite_sizes)), finite_sizes, 'ro-', label='k (upper bound)', markersize=6)
    ax.set_xticks(range(len(finite_sizes)))
    ax.set_xticklabels([f'Fin({k})' for k in finite_sizes])
    ax.set_ylabel('Max Survival Rounds')
    ax.set_title('Boundary: Finite State Space Survival')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Novelty/survival_dynamics.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: survival_dynamics.png")

if __name__ == "__main__":
    main()
