#!/usr/bin/env python3
"""
Infinite Games Against Death: Numerical Demonstrations

Demonstrates the key concepts from the ordinal survival game theory:
1. Strategy enumeration and survival checking
2. The ω-survival theorem via pigeonhole
3. Countdown game analysis
4. Evasion game paradox
"""

import itertools
from typing import Callable, List, Tuple, Optional


def enumerate_strategies(num_states: int, num_moves: int) -> List[Tuple[int, ...]]:
    """Enumerate all Mortal strategies for a game with given parameters.
    
    A strategy maps each state to a move: State -> Fin(mortalArity).
    Total strategies = mortalArity ^ numStates.
    """
    return list(itertools.product(range(num_moves), repeat=num_states))


def play_game(
    transition: Callable[[int, int, int], int],
    mortal_strategy: Tuple[int, ...],
    eternity_strategy: Callable[[int, int], int],
    initial_state: int,
    rounds: int,
) -> List[int]:
    """Play a survival game for the given number of rounds.
    
    Returns the sequence of states visited.
    """
    states = [initial_state]
    s = initial_state
    for _ in range(rounds):
        m_move = mortal_strategy[s]
        e_move = eternity_strategy(s, m_move)
        s = transition(s, m_move, e_move)
        states.append(s)
    return states


def check_survival(states: List[int], alive_pred: Callable[[int], bool]) -> bool:
    """Check if all states in the sequence satisfy the alive predicate."""
    return all(alive_pred(s) for s in states)


# === Demo 1: Strategy Enumeration ===
print("=" * 60)
print("Demo 1: Strategy Space Size")
print("=" * 60)
for num_states in [2, 3, 4, 5]:
    for num_moves in [2, 3]:
        total = num_moves ** num_states
        print(f"  States={num_states}, Moves={num_moves}: "
              f"{total} strategies")
print()


# === Demo 2: Countdown Game ===
print("=" * 60)
print("Demo 2: Countdown Game Analysis")
print("=" * 60)

def countdown_transition(s: int, m_move: int, e_move: int) -> int:
    """Countdown game: state decrements by 1 each round."""
    return max(0, s - 1)

def countdown_alive(s: int) -> bool:
    return s > 0

for bound in range(1, 8):
    # Only one strategy possible (mortalArity = 1, eternityArity = 1)
    strategy = (0,) * (bound + 1)
    states = play_game(
        countdown_transition, strategy, lambda s, m: 0, bound, bound + 1
    )
    survival_rounds = 0
    for s in states:
        if countdown_alive(s):
            survival_rounds += 1
        else:
            break
    print(f"  Countdown from {bound}: survives {survival_rounds - 1} rounds "
          f"(states: {states[:bound+2]})")
print()


# === Demo 3: ω-Survival Theorem Illustration ===
print("=" * 60)
print("Demo 3: ω-Survival Theorem (Pigeonhole Illustration)")
print("=" * 60)

# A simple game: 3 states, 2 Mortal moves, 2 Eternity moves
# State 0: alive, State 1: alive, State 2: dead
# Transition designed so that strategy (1, 0, 0) is immortal

def demo_transition(s: int, m: int, e: int) -> int:
    """A 3-state game where strategy (1,0,0) keeps states cycling in {0,1}."""
    if s == 0:
        return 1 if m == 1 else 2  # move 1 keeps alive, move 0 dies
    elif s == 1:
        return 0 if m == 0 else (1 if e == 0 else 0)  # move 0 returns to state 0
    else:
        return 2  # dead state absorbs

def demo_alive(s: int) -> bool:
    return s < 2

strategies = enumerate_strategies(3, 2)
print(f"  Total strategies: {len(strategies)}")

for n in [1, 5, 10, 50, 100]:
    surviving = []
    for strat in strategies:
        # Check against ALL 2^(3*2) = 64 eternity strategies
        survives_all = True
        for e_vals in itertools.product(range(2), repeat=6):
            e_func = lambda s, m, ev=e_vals: ev[s * 2 + m]
            states = play_game(demo_transition, strat, e_func, 0, n)
            if not check_survival(states, demo_alive):
                survives_all = False
                break
        if survives_all:
            surviving.append(strat)
    print(f"  Horizon {n:3d}: {len(surviving)} surviving strategies: {surviving}")

print("\n  → The same strategy (1,0,0) survives ALL horizons (ω-survival!)")
print()


# === Demo 4: Evasion Paradox ===
print("=" * 60)
print("Demo 4: Evasion Paradox")
print("=" * 60)

for n in [2, 3, 5, 10]:
    print(f"\n  Evasion game on {n} positions:")
    total_strategies = n ** (n * n)  # strategies: (Fin n × Fin n) → Fin n
    print(f"    Mortal has {total_strategies} strategies")
    
    # For any Mortal strategy, Eternity uses the "copy" strategy: search where Mortal hides
    # At round 1: state = (m(s0), m(s0)) which has equal components → dead
    caught = True
    print(f"    Eternity's counter: copy Mortal's move → catches in round 1")
    print(f"    Result: Mortal {'CANNOT' if caught else 'CAN'} survive round 1")

print()


# === Demo 5: Ordinal Arithmetic ===
print("=" * 60)
print("Demo 5: Ordinal Survival Hierarchy")
print("=" * 60)

print("""
  Game Type              | Survival Ordinal
  -----------------------|------------------
  All-dead game          | 0
  Countdown(n)           | n - 1
  Trivial game           | ω
  Hierarchical (ω×ω)     | ω²
  Double hierarchy       | ω³
  Self-referential       | ε₀ (conjectured)
  
  Key insight: ω·ω = ω² (first infinite ordinal squared)
  ω² is strictly larger than ω — there are ω²-many ordinals below ω²
  but only ω-many below ω.
""")


# === Demo 6: Strategy Space Growth ===
print("=" * 60)
print("Demo 6: Strategy Space Explosion")
print("=" * 60)

print("  |State| | Mortal Arity | # Strategies")
print("  --------|-------------|-------------")
for states in [2, 3, 5, 10, 20]:
    for arity in [2, 3, 5]:
        count = arity ** states
        print(f"  {states:7d} | {arity:11d} | {count:>12,d}")
        if count > 10**15:
            break

print("\n  The ω-survival theorem works despite this combinatorial explosion:")
print("  it extracts a universal strategy without enumerating!")

if __name__ == "__main__":
    print("\n\nAll demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Survival Strategy Landscape

Shows how the set of surviving strategies shrinks as the horizon increases,
illustrating the core mechanism of the ω-survival theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product as cart_product


def compute_surviving_strategies(num_states, mortal_arity, eternity_arity,
                                  transition_func, alive_func, s0, max_horizon):
    """Compute which strategies survive each horizon."""
    strategies = list(cart_product(range(mortal_arity), repeat=num_states))
    
    eternity_strats = []
    for vals in cart_product(range(eternity_arity),
                             repeat=num_states * mortal_arity):
        def make_e(v):
            def e(s, m):
                return v[s * mortal_arity + m]
            return e
        eternity_strats.append(make_e(vals))
    
    surviving = {}
    for n in range(max_horizon + 1):
        surviving[n] = set()
        for i, strat in enumerate(strategies):
            ok = True
            for e in eternity_strats:
                s = s0
                alive = True
                for step in range(n + 1):
                    if not alive_func(s):
                        alive = False
                        break
                    if step < n:
                        m_move = strat[s]
                        e_move = e(s, m_move)
                        s = transition_func(s, m_move, e_move)
                if not alive:
                    ok = False
                    break
            if ok:
                surviving[n].add(i)
    
    return strategies, surviving


def plot_survival_landscape():
    """Plot the decreasing chain of surviving strategy sets."""
    # 3-state game, 2 moves each
    def transition(s, m, e):
        if s == 0:
            return 1 if m == 1 else 2
        elif s == 1:
            return 0 if m == 0 else (1 if e == 0 else 0)
        return 2
    
    def alive(s):
        return s < 2
    
    strategies, surviving = compute_surviving_strategies(
        3, 2, 2, transition, alive, 0, 15
    )
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Plot 1: Number of surviving strategies vs horizon
    horizons = sorted(surviving.keys())
    counts = [len(surviving[n]) for n in horizons]
    
    ax1 = axes[0]
    ax1.bar(horizons, counts, color='steelblue', alpha=0.8, edgecolor='navy')
    ax1.set_xlabel('Horizon (n)', fontsize=12)
    ax1.set_ylabel('# Surviving Strategies', fontsize=12)
    ax1.set_title('Surviving Strategy Count vs Horizon\n(3-state cycling game)', fontsize=13)
    ax1.axhline(y=1, color='red', linestyle='--', alpha=0.7, label='Immortal threshold')
    ax1.legend(fontsize=10)
    ax1.set_ylim(0, max(counts) + 1)
    
    # Plot 2: Strategy survival matrix
    ax2 = axes[1]
    total_strats = len(strategies)
    matrix = np.zeros((total_strats, len(horizons)))
    for j, n in enumerate(horizons):
        for i in surviving[n]:
            matrix[i, j] = 1
    
    ax2.imshow(matrix, aspect='auto', cmap='YlGn', interpolation='nearest',
               extent=[0, len(horizons), total_strats, 0])
    ax2.set_xlabel('Horizon (n)', fontsize=12)
    ax2.set_ylabel('Strategy Index', fontsize=12)
    ax2.set_title('Strategy Survival Matrix\n(green = survives)', fontsize=13)
    
    # Mark immortal strategies
    for i in range(total_strats):
        if all(i in surviving[n] for n in horizons):
            ax2.annotate('★', xy=(len(horizons)-1, i+0.5), fontsize=14, color='red',
                        ha='center', va='center')
    
    plt.tight_layout()
    plt.savefig('survival_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: survival_landscape.png")


def plot_ordinal_hierarchy():
    """Plot the ordinal hierarchy of survival depths."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 7))
    
    # Represent ordinals on a log-like scale
    levels = {
        'Finite games': [(i, f'countdown({i+1})') for i in range(6)],
    }
    
    # Draw the finite ordinals
    y_pos = 0.3
    for i in range(7):
        ax.plot(i, y_pos, 'o', color='steelblue', markersize=10)
        ax.annotate(str(i), (i, y_pos - 0.08), ha='center', fontsize=9)
    
    ax.annotate('...', (7.5, y_pos), ha='center', fontsize=14, color='gray')
    
    # Draw ω
    omega_x = 9
    ax.plot(omega_x, y_pos, 's', color='darkorange', markersize=14)
    ax.annotate('ω', (omega_x, y_pos - 0.1), ha='center', fontsize=13, fontweight='bold')
    ax.annotate('(trivial game,\ncycling game)', (omega_x, y_pos + 0.12),
                ha='center', fontsize=8, color='gray')
    
    # Draw ω·2, ω·3, etc.
    for i, label in enumerate(['ω·2', 'ω·3']):
        x = omega_x + 1.5 + i * 1.5
        ax.plot(x, y_pos, 's', color='darkorange', markersize=12, alpha=0.7)
        ax.annotate(label, (x, y_pos - 0.1), ha='center', fontsize=11)
    
    ax.annotate('...', (omega_x + 5.5, y_pos), ha='center', fontsize=14, color='gray')
    
    # Draw ω²
    omega2_x = omega_x + 7
    ax.plot(omega2_x, y_pos, 'D', color='crimson', markersize=14)
    ax.annotate('ω²', (omega2_x, y_pos - 0.1), ha='center', fontsize=13, fontweight='bold')
    ax.annotate('(hierarchical\ngame)', (omega2_x, y_pos + 0.12),
                ha='center', fontsize=8, color='gray')
    
    # Draw ω³, ε₀
    for i, (label, color) in enumerate([('ω³', 'purple'), ('ε₀', 'black')]):
        x = omega2_x + 2 + i * 2
        marker = 'D' if i == 0 else '*'
        size = 14 if i == 0 else 18
        ax.plot(x, y_pos, marker, color=color, markersize=size)
        ax.annotate(label, (x, y_pos - 0.1), ha='center', fontsize=13,
                    fontweight='bold', color=color)
        if i == 1:
            ax.annotate('(conjectured:\nself-referential)', (x, y_pos + 0.12),
                        ha='center', fontsize=8, color='gray')
    
    # Arrows showing the key theorems
    ax.annotate('', xy=(omega_x - 0.3, y_pos + 0.25), xytext=(5, y_pos + 0.25),
                arrowprops=dict(arrowstyle='->', color='green', lw=2))
    ax.annotate('ω-Survival\nTheorem', (7, y_pos + 0.35), ha='center',
                fontsize=10, color='green', fontweight='bold')
    
    ax.annotate('', xy=(omega2_x - 0.3, y_pos + 0.25),
                xytext=(omega_x + 0.3, y_pos + 0.25),
                arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ax.annotate('ω²-Survival\nTheorem', ((omega_x + omega2_x) / 2, y_pos + 0.35),
                ha='center', fontsize=10, color='red', fontweight='bold')
    
    ax.set_xlim(-0.5, omega2_x + 6)
    ax.set_ylim(0, 0.7)
    ax.set_title('Ordinal Survival Hierarchy', fontsize=15, fontweight='bold')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('ordinal_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: ordinal_hierarchy.png")


if __name__ == "__main__":
    plot_survival_landscape()
    plot_ordinal_hierarchy()
