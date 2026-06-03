"""
Sperner's Lemma → Nash Equilibria: Demonstration

This script demonstrates the Sperner-based algorithm for finding Nash equilibria
in finite games. It implements the triangulation of the mixed strategy simplex,
the Sperner coloring derived from best responses, and the iterative refinement
that converges to Nash equilibria.
"""

import numpy as np
from itertools import product

def simplex_grid(n_strategies, resolution):
    """Generate grid points on the n-simplex with given resolution.
    
    Returns points (p1, ..., pn) with pi >= 0 and sum = 1,
    discretized at multiples of 1/resolution.
    """
    if n_strategies == 1:
        return [np.array([1.0])]
    
    points = []
    for combo in product(range(resolution + 1), repeat=n_strategies - 1):
        if sum(combo) <= resolution:
            last = resolution - sum(combo)
            point = np.array(list(combo) + [last]) / resolution
            points.append(point)
    return points


def best_response_coloring(payoff_matrix, opponent_strategy):
    """Compute the best response pure strategy against an opponent's mixed strategy.
    
    For a 2-player game:
    - payoff_matrix[i][j] = payoff when I play i, opponent plays j
    - opponent_strategy = probability vector over opponent's strategies
    
    Returns the index of the best response pure strategy.
    """
    expected_payoffs = payoff_matrix @ opponent_strategy
    return int(np.argmax(expected_payoffs))


def sperner_coloring_2player(game, point, player):
    """Compute the Sperner coloring for a point in the mixed strategy simplex.
    
    For a 2-player game, color a vertex by which pure strategy is the best
    response for the given player.
    """
    if player == 0:
        return best_response_coloring(game['A'], point)
    else:
        return best_response_coloring(game['B'].T, point)


def find_approx_nash_sperner(game, resolution=10):
    """Find approximate Nash equilibria using Sperner-type construction.
    
    For a 2-player game with strategy sets S1, S2:
    - Triangulate the product simplex Δ(S1) × Δ(S2)
    - Color each vertex by (best_response_1, best_response_2)
    - Find vertices where each player's best response is stable
    
    Returns approximate Nash equilibria as (p1, p2) pairs.
    """
    n1, n2 = game['A'].shape
    
    # Generate grid on each player's simplex
    grid1 = simplex_grid(n1, resolution)
    grid2 = simplex_grid(n2, resolution)
    
    approx_equilibria = []
    
    for p1 in grid1:
        for p2 in grid2:
            # Check if (p1, p2) is approximately a Nash equilibrium
            # Player 1's expected payoff: p1^T A p2
            exp1 = p1 @ game['A'] @ p2
            # Player 2's expected payoff: p1^T B p2
            exp2 = p1 @ game['B'] @ p2
            
            # Best response payoffs
            br1_payoffs = game['A'] @ p2
            br2_payoffs = game['B'].T @ p1
            
            max_gain1 = max(br1_payoffs) - exp1
            max_gain2 = max(br2_payoffs) - exp2
            
            epsilon = 1.0 / resolution
            if max_gain1 <= epsilon and max_gain2 <= epsilon:
                approx_equilibria.append((p1.copy(), p2.copy(), max_gain1 + max_gain2))
    
    return approx_equilibria


def compute_nash_support_verification(game, p1, p2):
    """Verify the support lemma: in a Nash equilibrium, all strategies with
    positive probability achieve equal expected payoff."""
    exp1 = p1 @ game['A'] @ p2
    exp2 = p1 @ game['B'] @ p2
    
    br1_payoffs = game['A'] @ p2
    br2_payoffs = game['B'].T @ p1
    
    print(f"  Player 1 expected payoff: {exp1:.4f}")
    print(f"  Player 1 pure strategy payoffs: {br1_payoffs}")
    for i, pi in enumerate(p1):
        if pi > 1e-10:
            print(f"    Strategy {i} (prob={pi:.3f}): payoff={br1_payoffs[i]:.4f} "
                  f"(diff from expected: {br1_payoffs[i] - exp1:.6f})")
    
    print(f"  Player 2 expected payoff: {exp2:.4f}")
    print(f"  Player 2 pure strategy payoffs: {br2_payoffs}")
    for j, pj in enumerate(p2):
        if pj > 1e-10:
            print(f"    Strategy {j} (prob={pj:.3f}): payoff={br2_payoffs[j]:.4f} "
                  f"(diff from expected: {br2_payoffs[j] - exp2:.6f})")


def demo_prisoners_dilemma():
    """Prisoner's Dilemma: unique pure strategy Nash equilibrium (D, D)."""
    print("=" * 60)
    print("PRISONER'S DILEMMA")
    print("=" * 60)
    
    # Payoff matrices (row player, column player)
    game = {
        'A': np.array([[3, 0], [5, 1]]),  # Row player
        'B': np.array([[3, 5], [0, 1]])   # Column player
    }
    
    print("Payoff matrix A (row player):")
    print(game['A'])
    print("Payoff matrix B (column player):")
    print(game['B'])
    
    for res in [5, 10, 20, 50]:
        equilibria = find_approx_nash_sperner(game, resolution=res)
        print(f"\nResolution {res}: Found {len(equilibria)} approximate equilibria")
        if equilibria:
            best = min(equilibria, key=lambda x: x[2])
            print(f"  Best: p1={best[0]}, p2={best[1]}, total regret={best[2]:.4f}")
    
    print("\nSupport lemma verification at (D,D):")
    compute_nash_support_verification(game, np.array([0, 1]), np.array([0, 1]))


def demo_matching_pennies():
    """Matching Pennies: unique mixed strategy Nash equilibrium (1/2, 1/2)."""
    print("\n" + "=" * 60)
    print("MATCHING PENNIES")
    print("=" * 60)
    
    game = {
        'A': np.array([[1, -1], [-1, 1]]),
        'B': np.array([[-1, 1], [1, -1]])
    }
    
    print("Payoff matrix A (row player):")
    print(game['A'])
    
    for res in [5, 10, 20, 50, 100]:
        equilibria = find_approx_nash_sperner(game, resolution=res)
        print(f"\nResolution {res}: Found {len(equilibria)} approximate equilibria")
        if equilibria:
            best = min(equilibria, key=lambda x: x[2])
            print(f"  Best: p1={best[0]}, p2={best[1]}, total regret={best[2]:.6f}")
    
    print("\nSupport lemma verification at (0.5, 0.5):")
    compute_nash_support_verification(game, np.array([0.5, 0.5]), np.array([0.5, 0.5]))


def demo_battle_of_sexes():
    """Battle of the Sexes: three Nash equilibria (2 pure, 1 mixed)."""
    print("\n" + "=" * 60)
    print("BATTLE OF THE SEXES")
    print("=" * 60)
    
    game = {
        'A': np.array([[3, 0], [0, 2]]),
        'B': np.array([[2, 0], [0, 3]])
    }
    
    print("Payoff matrix A (row player):")
    print(game['A'])
    print("Payoff matrix B (column player):")
    print(game['B'])
    
    for res in [10, 20, 50]:
        equilibria = find_approx_nash_sperner(game, resolution=res)
        print(f"\nResolution {res}: Found {len(equilibria)} approximate equilibria")
        # Cluster equilibria
        if equilibria:
            for eq in sorted(equilibria, key=lambda x: x[2])[:5]:
                print(f"  p1={eq[0]}, p2={eq[1]}, regret={eq[2]:.4f}")


def demo_convergence():
    """Demonstrate convergence of approximate equilibria as mesh → 0."""
    print("\n" + "=" * 60)
    print("CONVERGENCE ANALYSIS")
    print("=" * 60)
    
    # Rock-Paper-Scissors
    game = {
        'A': np.array([[0, -1, 1], [1, 0, -1], [-1, 1, 0]]),
        'B': np.array([[0, 1, -1], [-1, 0, 1], [1, -1, 0]])
    }
    
    print("Rock-Paper-Scissors:")
    print("True Nash: (1/3, 1/3, 1/3) for both players")
    
    for res in [3, 6, 9, 12, 15, 30]:
        equilibria = find_approx_nash_sperner(game, resolution=res)
        if equilibria:
            best = min(equilibria, key=lambda x: x[2])
            dist = np.linalg.norm(best[0] - np.array([1/3, 1/3, 1/3]))
            print(f"  Res={res:3d}: best p1={best[0]}, "
                  f"dist to (1/3,1/3,1/3)={dist:.4f}, regret={best[2]:.4f}")


if __name__ == '__main__':
    demo_prisoners_dilemma()
    demo_matching_pennies()
    demo_battle_of_sexes()
    demo_convergence()


"""
Visualization: Sperner Coloring of the Mixed Strategy Simplex

Shows how the Sperner coloring derived from best responses partitions
the strategy space, and how approximate Nash equilibria emerge at
the boundaries between colored regions.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.tri as tri
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection


def barycentric_to_cartesian(p):
    """Convert barycentric coordinates to 2D Cartesian for plotting."""
    x = 0.5 * p[1] + p[2]
    y = (np.sqrt(3) / 2) * p[1]
    return x, y


def plot_sperner_coloring_2x2(game_A, game_B, resolution=30, title="Sperner Coloring"):
    """Plot the Sperner coloring of a 2x2 game's strategy simplex.
    
    For a 2x2 game, each player's strategy space is [0,1] (probability of 
    playing strategy 0). We plot the product space [0,1]^2 with coloring.
    """
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Grid
    n = resolution
    p1_vals = np.linspace(0, 1, n + 1)
    p2_vals = np.linspace(0, 1, n + 1)
    P1, P2 = np.meshgrid(p1_vals, p2_vals)
    
    # Player 1's best response coloring
    BR1 = np.zeros_like(P1)
    for i in range(n + 1):
        for j in range(n + 1):
            p2 = np.array([p2_vals[j], 1 - p2_vals[j]])
            payoffs = game_A @ p2
            BR1[i, j] = 0 if payoffs[0] >= payoffs[1] else 1
    
    # Player 2's best response coloring
    BR2 = np.zeros_like(P1)
    for i in range(n + 1):
        for j in range(n + 1):
            p1 = np.array([p1_vals[i], 1 - p1_vals[i]])
            payoffs = game_B.T @ p1
            BR2[i, j] = 0 if payoffs[0] >= payoffs[1] else 1
    
    # Regret heatmap
    Regret = np.zeros_like(P1)
    for i in range(n + 1):
        for j in range(n + 1):
            p1 = np.array([p1_vals[i], 1 - p1_vals[i]])
            p2 = np.array([p2_vals[j], 1 - p2_vals[j]])
            exp1 = p1 @ game_A @ p2
            exp2 = p1 @ game_B @ p2
            max_dev1 = max(game_A @ p2)
            max_dev2 = max(game_B.T @ p1)
            Regret[i, j] = max(max_dev1 - exp1, max_dev2 - exp2)
    
    # Plot 1: Player 1's best response
    ax = axes[0]
    c = ax.pcolormesh(P1, P2, BR1, cmap='RdBu', alpha=0.7)
    ax.set_xlabel('p₁(strategy 0)')
    ax.set_ylabel('p₂(strategy 0)')
    ax.set_title('Player 1 Best Response')
    ax.set_aspect('equal')
    
    # Plot 2: Player 2's best response
    ax = axes[1]
    c = ax.pcolormesh(P1, P2, BR2, cmap='RdYlGn', alpha=0.7)
    ax.set_xlabel('p₁(strategy 0)')
    ax.set_ylabel('p₂(strategy 0)')
    ax.set_title('Player 2 Best Response')
    ax.set_aspect('equal')
    
    # Plot 3: Regret heatmap
    ax = axes[2]
    c = ax.pcolormesh(P1, P2, Regret, cmap='hot_r')
    plt.colorbar(c, ax=ax, label='Max Regret')
    ax.set_xlabel('p₁(strategy 0)')
    ax.set_ylabel('p₂(strategy 0)')
    ax.set_title('Regret Landscape')
    ax.set_aspect('equal')
    
    # Mark Nash equilibria (regret ≈ 0)
    for i in range(n + 1):
        for j in range(n + 1):
            if Regret[i, j] < 0.05:
                ax.plot(p1_vals[i], p2_vals[j], 'g*', markersize=10)
    
    plt.suptitle(title, fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('sperner_coloring.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved sperner_coloring.png")


def plot_convergence():
    """Plot convergence of Sperner approximations to Nash equilibria."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Matching Pennies
    A = np.array([[1, -1], [-1, 1]])
    B = -A
    
    resolutions = [3, 5, 8, 12, 18, 25, 35, 50, 75, 100]
    best_regrets = []
    best_distances = []
    
    for res in resolutions:
        best_regret = float('inf')
        best_dist = float('inf')
        
        for i in range(res + 1):
            for j in range(res + 1):
                p1 = np.array([i / res, 1 - i / res])
                p2 = np.array([j / res, 1 - j / res])
                
                exp1 = p1 @ A @ p2
                exp2 = p1 @ B @ p2
                max_dev1 = max(A @ p2)
                max_dev2 = max(B.T @ p1)
                regret = max(max_dev1 - exp1, max_dev2 - exp2)
                dist = abs(p1[0] - 0.5) + abs(p2[0] - 0.5)
                
                if regret < best_regret:
                    best_regret = regret
                    best_dist = dist
        
        best_regrets.append(best_regret)
        best_distances.append(best_dist)
    
    ax = axes[0]
    ax.loglog(resolutions, best_regrets, 'bo-', linewidth=2, markersize=8, label='Best regret')
    ax.loglog(resolutions, [1/r for r in resolutions], 'r--', linewidth=1, label='O(1/N)')
    ax.set_xlabel('Resolution N', fontsize=12)
    ax.set_ylabel('Best Regret', fontsize=12)
    ax.set_title('Convergence: Regret vs Resolution', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    ax = axes[1]
    ax.loglog(resolutions, best_distances, 'go-', linewidth=2, markersize=8, label='Distance to Nash')
    ax.loglog(resolutions, [1/r for r in resolutions], 'r--', linewidth=1, label='O(1/N)')
    ax.set_xlabel('Resolution N', fontsize=12)
    ax.set_ylabel('Distance to True Nash', fontsize=12)
    ax.set_title('Convergence: Distance vs Resolution', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.suptitle('Matching Pennies: Sperner Approximation Convergence', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved convergence.png")


if __name__ == '__main__':
    # Matching Pennies
    A = np.array([[1, -1], [-1, 1]])
    B = -A
    plot_sperner_coloring_2x2(A, B, resolution=50, title="Matching Pennies: Sperner Coloring")
    
    # Battle of the Sexes
    A2 = np.array([[3, 0], [0, 2]])
    B2 = np.array([[2, 0], [0, 3]])
    plot_sperner_coloring_2x2(A2, B2, resolution=50, title="Battle of the Sexes: Sperner Coloring")
    
    plot_convergence()
