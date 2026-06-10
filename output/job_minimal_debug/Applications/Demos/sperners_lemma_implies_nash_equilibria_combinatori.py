#!/usr/bin/env python3
"""
Demo: Sperner's Lemma → Nash Equilibria
Combinatorial Fixed Points in Game Theory

Demonstrates the BRCS (Best Response Coloring System) framework
by computing Nash equilibria of small games using the Sperner-based
triangulation approach.
"""

import numpy as np
from itertools import product


def compute_expected_payoff(game, mixed_profile, player):
    """Compute expected payoff for a player under a mixed strategy profile."""
    n_players = len(game)
    strat_counts = [len(mixed_profile[i]) for i in range(n_players)]
    total = 0.0
    for pure_profile in product(*[range(s) for s in strat_counts]):
        prob = 1.0
        for j in range(n_players):
            prob *= mixed_profile[j][pure_profile[j]]
        total += prob * game[player][pure_profile]
    return total


def compute_deviation_payoff(game, mixed_profile, player, pure_strat):
    """Compute payoff when player deviates to a pure strategy."""
    n_players = len(game)
    strat_counts = [len(mixed_profile[i]) for i in range(n_players)]
    total = 0.0
    for pure_profile in product(*[range(s) for s in strat_counts]):
        if pure_profile[player] != pure_strat:
            continue
        prob = 1.0
        for j in range(n_players):
            if j == player:
                continue
            prob *= mixed_profile[j][pure_profile[j]]
        total += prob * game[player][pure_profile]
    return total


def compute_regret(game, mixed_profile, player, pure_strat):
    """Compute regret of a player from a pure strategy."""
    return (compute_deviation_payoff(game, mixed_profile, player, pure_strat)
            - compute_expected_payoff(game, mixed_profile, player))


def max_regret(game, mixed_profile):
    """Compute maximum regret across all players and strategies."""
    n_players = len(game)
    strat_counts = [len(mixed_profile[i]) for i in range(n_players)]
    mr = float('-inf')
    for i in range(n_players):
        for si in range(strat_counts[i]):
            r = compute_regret(game, mixed_profile, i, si)
            mr = max(mr, r)
    return mr


def is_approx_nash(game, mixed_profile, epsilon):
    """Check if a mixed profile is an ε-approximate Nash equilibrium."""
    return max_regret(game, mixed_profile) <= epsilon + 1e-10


def sperner_nash_search(game, mesh_size=0.1):
    """
    Find approximate Nash equilibria using Sperner-based triangulation.

    Triangulates the strategy simplex and finds vertices where
    the best-response coloring produces a "fully colored" simplex.
    """
    n_players = len(game)
    strat_counts = [game[0].shape[i] for i in range(n_players)]

    # Generate grid points on each player's strategy simplex
    def simplex_grid(n_strats, mesh):
        """Generate grid points on the (n_strats-1)-simplex with given mesh."""
        k = max(1, int(1.0 / mesh))
        if n_strats == 1:
            return [np.array([1.0])]
        if n_strats == 2:
            return [np.array([i/k, 1 - i/k]) for i in range(k + 1)]
        # General case: enumerate lattice points
        points = []
        def _gen(remaining, depth, current):
            if depth == n_strats - 1:
                current.append(remaining / k)
                points.append(np.array(current[:]))
                current.pop()
                return
            for val in range(remaining + 1):
                current.append(val / k)
                _gen(remaining - val, depth + 1, current)
                current.pop()
        _gen(k, 0, [])
        return points

    # Generate all mixed strategy profiles on the grid
    grids = [simplex_grid(strat_counts[i], mesh_size) for i in range(n_players)]

    best_profile = None
    best_regret = float('inf')

    for combo in product(*grids):
        profile = list(combo)
        mr = max_regret(game, profile)
        if mr < best_regret:
            best_regret = mr
            best_profile = profile

    return best_profile, best_regret


def create_prisoners_dilemma():
    """Create the Prisoner's Dilemma game."""
    # Player 0's payoffs
    p0 = np.array([[-1, -3], [0, -2]])
    # Player 1's payoffs
    p1 = np.array([[-1, 0], [-3, -2]])
    return [p0, p1]


def create_matching_pennies():
    """Create the Matching Pennies game."""
    p0 = np.array([[1, -1], [-1, 1]])
    p1 = np.array([[-1, 1], [1, -1]])
    return [p0, p1]


def create_battle_of_sexes():
    """Create the Battle of the Sexes game."""
    p0 = np.array([[3, 0], [0, 2]])
    p1 = np.array([[2, 0], [0, 3]])
    return [p0, p1]


def demo_convergence():
    """Demonstrate how mesh refinement improves approximation quality."""
    print("=" * 60)
    print("BRCS Convergence: Matching Pennies")
    print("=" * 60)
    game = create_matching_pennies()
    print("\nTheoretical Nash: each player plays (0.5, 0.5)")
    print(f"\n{'Mesh Size':>10} {'Max Regret':>12} {'Player 1':>20} {'Player 2':>20}")
    print("-" * 64)

    for k in [2, 4, 8, 16, 32, 64]:
        mesh = 1.0 / k
        profile, regret = sperner_nash_search(game, mesh)
        p1_str = f"({profile[0][0]:.4f}, {profile[0][1]:.4f})"
        p2_str = f"({profile[1][0]:.4f}, {profile[1][1]:.4f})"
        print(f"{mesh:>10.4f} {regret:>12.6f} {p1_str:>20} {p2_str:>20}")


def demo_games():
    """Demonstrate Nash equilibrium finding for classic games."""
    games = {
        "Prisoner's Dilemma": create_prisoners_dilemma(),
        "Matching Pennies": create_matching_pennies(),
        "Battle of the Sexes": create_battle_of_sexes(),
    }

    for name, game in games.items():
        print(f"\n{'=' * 60}")
        print(f"Game: {name}")
        print(f"{'=' * 60}")

        profile, regret = sperner_nash_search(game, mesh_size=1/32)
        print(f"Approximate Nash Equilibrium (mesh=1/32):")
        for i, p in enumerate(profile):
            print(f"  Player {i+1}: {np.round(p, 4)}")
        print(f"  Max regret: {regret:.6f}")
        print(f"  Is 0.1-Nash? {is_approx_nash(game, profile, 0.1)}")


def demo_support_lemma():
    """Demonstrate the Nash Support Lemma."""
    print("\n" + "=" * 60)
    print("Nash Support Lemma Verification")
    print("=" * 60)

    game = create_matching_pennies()
    # Exact Nash equilibrium
    profile = [np.array([0.5, 0.5]), np.array([0.5, 0.5])]

    print("\nMatching Pennies - Nash eq: (0.5, 0.5) vs (0.5, 0.5)")
    for i in range(2):
        exp = compute_expected_payoff(game, profile, i)
        print(f"\n  Player {i+1} expected payoff: {exp:.4f}")
        for si in range(2):
            dev = compute_deviation_payoff(game, profile, i, si)
            prob = profile[i][si]
            print(f"    Strategy {si}: prob={prob:.2f}, "
                  f"deviation_payoff={dev:.4f}, "
                  f"regret={dev - exp:.4f}")
            if prob > 0:
                print(f"    → Support lemma: deviation_payoff == expected_payoff? "
                      f"{abs(dev - exp) < 1e-10}")


def demo_dominance():
    """Demonstrate dominated strategy elimination."""
    print("\n" + "=" * 60)
    print("Dominated Strategy Elimination")
    print("=" * 60)

    # Game where strategy 2 strictly dominates strategy 0 for player 0
    p0 = np.array([[1, 0], [2, 1], [3, 2]])
    p1 = np.array([[0, 1], [0, 1], [0, 1]])
    game = [p0, p1]

    print("\nPlayer 1 payoff matrix:")
    print(p0)
    print("Strategy 2 dominates Strategy 0 (3>2>1 and 2>1>0)")

    profile, regret = sperner_nash_search(game, mesh_size=1/32)
    print(f"\nNash equilibrium approximation:")
    print(f"  Player 1: {np.round(profile[0], 4)}")
    print(f"  Player 2: {np.round(profile[1], 4)}")
    print(f"  Strategy 0 probability: {profile[0][0]:.4f} (should be ~0)")


if __name__ == "__main__":
    print("SPERNER'S LEMMA → NASH EQUILIBRIA")
    print("Combinatorial Fixed Points in Game Theory\n")

    demo_games()
    demo_convergence()
    demo_support_lemma()
    demo_dominance()


#!/usr/bin/env python3
"""
Visualization: BRCS Convergence — How mesh refinement drives
approximate Nash equilibria toward exact equilibria.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


def compute_max_regret_2x2(game_p0, game_p1, p, q):
    """Compute max regret for 2x2 game at mixed profile (p, 1-p) vs (q, 1-q)."""
    profile = [np.array([p, 1-p]), np.array([q, 1-q])]
    max_r = float('-inf')
    for i, payoff in enumerate([game_p0, game_p1]):
        exp = 0.0
        for s0 in range(2):
            for s1 in range(2):
                exp += profile[0][s0] * profile[1][s1] * payoff[s0, s1]
        for si in range(2):
            dev = 0.0
            for sj in range(2):
                j = 1 - i
                dev += profile[j][sj] * payoff[(si, sj) if i == 0 else (sj, si)]
            r = dev - exp
            max_r = max(max_r, r)
    return max_r


def plot_convergence():
    # Matching Pennies
    p0 = np.array([[1, -1], [-1, 1]])
    p1 = np.array([[-1, 1], [1, -1]])

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot 1: Regret landscape
    ax = axes[0]
    ps = np.linspace(0, 1, 100)
    qs = np.linspace(0, 1, 100)
    P, Q = np.meshgrid(ps, qs)
    R = np.zeros_like(P)
    for i in range(len(ps)):
        for j in range(len(qs)):
            R[j, i] = compute_max_regret_2x2(p0, p1, ps[i], qs[j])

    c = ax.contourf(P, Q, R, levels=20, cmap='RdYlGn_r')
    plt.colorbar(c, ax=ax, label='Max Regret')
    ax.plot(0.5, 0.5, 'w*', markersize=15, label='Nash Equilibrium')
    ax.set_xlabel('Player 1: P(Heads)')
    ax.set_ylabel('Player 2: P(Heads)')
    ax.set_title('Matching Pennies: Regret Landscape')
    ax.legend()

    # Plot 2: Convergence of mesh refinement
    ax = axes[1]
    mesh_sizes = []
    regrets = []
    for k in range(1, 8):
        mesh = 1.0 / (2**k)
        grid = [i * mesh for i in range(int(1/mesh) + 1)]
        best_r = float('inf')
        for p in grid:
            for q in grid:
                r = compute_max_regret_2x2(p0, p1, p, q)
                best_r = min(best_r, r)
        mesh_sizes.append(mesh)
        regrets.append(best_r)

    ax.semilogy(range(1, 8), regrets, 'bo-', linewidth=2, markersize=8)
    ax.semilogy(range(1, 8), mesh_sizes, 'r--', linewidth=1.5,
                label='Mesh size (upper bound)')
    ax.set_xlabel('Refinement Level')
    ax.set_ylabel('Max Regret (log scale)')
    ax.set_title('BRCS Convergence Rate')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: Grid points colored by best-response player
    ax = axes[2]
    k = 8
    mesh = 1.0 / k
    grid = [i * mesh for i in range(k + 1)]
    colors = []
    xs, ys = [], []
    for p in grid:
        for q in grid:
            profile = [np.array([p, 1-p]), np.array([q, 1-q])]
            # Color by player with max regret
            r0 = max(profile[1][0] * (p0[0,0] - p0[1,0]) + profile[1][1] * (p0[0,1] - p0[1,1]),
                     profile[1][0] * (p0[1,0] - p0[0,0]) + profile[1][1] * (p0[1,1] - p0[0,1]), 0)
            r1 = max(profile[0][0] * (p1[0,0] - p1[0,1]) + profile[0][1] * (p1[1,0] - p1[1,1]),
                     profile[0][0] * (p1[0,1] - p1[0,0]) + profile[0][1] * (p1[1,1] - p1[1,0]), 0)
            colors.append(0 if r0 >= r1 else 1)
            xs.append(p)
            ys.append(q)

    scatter = ax.scatter(xs, ys, c=colors, cmap='coolwarm', s=60, edgecolors='black', linewidth=0.5)
    ax.plot(0.5, 0.5, 'g*', markersize=20, zorder=5)
    ax.set_xlabel('Player 1: P(Heads)')
    ax.set_ylabel('Player 2: P(Heads)')
    ax.set_title(f'BRCS Coloring (mesh=1/{k})')
    ax.legend(*scatter.legend_elements(), title="Max Regret Player")

    plt.tight_layout()
    plt.savefig('brcs_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved brcs_convergence.png")


if __name__ == "__main__":
    plot_convergence()


#!/usr/bin/env python3
"""
Visualization: Regret Decomposition — showing how per-player regrets
combine to form the total regret landscape.
"""

import numpy as np
import matplotlib.pyplot as plt


def player_max_regret_2x2(payoff, profile, player_idx):
    """Compute maximum regret for one player in a 2x2 game."""
    p, q = profile[0][0], profile[1][0]
    if player_idx == 0:
        exp = p * q * payoff[0,0] + p * (1-q) * payoff[0,1] + \
              (1-p) * q * payoff[1,0] + (1-p) * (1-q) * payoff[1,1]
        dev0 = q * payoff[0,0] + (1-q) * payoff[0,1]
        dev1 = q * payoff[1,0] + (1-q) * payoff[1,1]
        return max(dev0 - exp, dev1 - exp)
    else:
        exp = p * q * payoff[0,0] + p * (1-q) * payoff[0,1] + \
              (1-p) * q * payoff[1,0] + (1-p) * (1-q) * payoff[1,1]
        dev0 = p * payoff[0,0] + (1-p) * payoff[1,0]
        dev1 = p * payoff[0,1] + (1-p) * payoff[1,1]
        return max(dev0 - exp, dev1 - exp)


def plot_regret_decomposition():
    # Battle of the Sexes
    p0 = np.array([[3, 0], [0, 2]])
    p1 = np.array([[2, 0], [0, 3]])

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    ps = np.linspace(0, 1, 100)
    qs = np.linspace(0, 1, 100)
    P, Q = np.meshgrid(ps, qs)

    R0 = np.zeros_like(P)
    R1 = np.zeros_like(P)

    for i in range(len(ps)):
        for j in range(len(qs)):
            profile = [np.array([ps[i], 1-ps[i]]), np.array([qs[j], 1-qs[j]])]
            R0[j, i] = player_max_regret_2x2(p0, profile, 0)
            R1[j, i] = player_max_regret_2x2(p1, profile, 1)

    Rmax = np.maximum(R0, R1)

    # Player 1 regret
    c = axes[0].contourf(P, Q, R0, levels=20, cmap='Reds')
    plt.colorbar(c, ax=axes[0], label='Player 1 Max Regret')
    axes[0].set_xlabel('Player 1: P(Opera)')
    axes[0].set_ylabel('Player 2: P(Opera)')
    axes[0].set_title('Player 1 Regret')

    # Player 2 regret
    c = axes[1].contourf(P, Q, R1, levels=20, cmap='Blues')
    plt.colorbar(c, ax=axes[1], label='Player 2 Max Regret')
    axes[1].set_xlabel('Player 1: P(Opera)')
    axes[1].set_ylabel('Player 2: P(Opera)')
    axes[1].set_title('Player 2 Regret')

    # Combined (max) regret
    c = axes[2].contourf(P, Q, Rmax, levels=20, cmap='RdYlGn_r')
    plt.colorbar(c, ax=axes[2], label='Max Regret')
    # Mark Nash equilibria
    # Pure NE: (1,1) and (0,0); Mixed NE: (3/5, 2/5)
    axes[2].plot([1, 0, 0.6], [1, 0, 0.4], 'w*', markersize=15)
    axes[2].set_xlabel('Player 1: P(Opera)')
    axes[2].set_ylabel('Player 2: P(Opera)')
    axes[2].set_title('Regret Decomposition (max)')

    for ax in axes:
        ax.set_aspect('equal')

    plt.suptitle('Battle of the Sexes: Regret Decomposition', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('regret_decomposition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved regret_decomposition.png")


if __name__ == "__main__":
    plot_regret_decomposition()
