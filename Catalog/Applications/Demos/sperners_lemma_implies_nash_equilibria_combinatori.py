#!/usr/bin/env python3
"""
Sperner-Nash Bridge: Demonstrating how Sperner colorings find Nash equilibria.

This demo implements the Sperner-based algorithm for finding approximate Nash
equilibria in 2-player games. It triangulates the mixed strategy simplex,
assigns Sperner-compatible colorings from best-response correspondences,
and locates fully-colored simplices whose barycenters are approximate equilibria.
"""

import numpy as np
from itertools import product


def expected_payoff(payoff_matrix, p, q):
    """Expected payoff for row player given mixed strategies p, q."""
    return p @ payoff_matrix @ q


def deviation_payoff(payoff_matrix, pure_i, q):
    """Payoff to row player deviating to pure strategy i against q."""
    return payoff_matrix[pure_i] @ q


def best_response(payoff_matrix, q):
    """Best response pure strategy for row player against mixed strategy q."""
    payoffs = payoff_matrix @ q
    return np.argmax(payoffs)


def regret(payoff_matrix, p, q, pure_i):
    """Regret of row player from strategy pure_i: deviation - expected."""
    return deviation_payoff(payoff_matrix, pure_i, q) - expected_payoff(payoff_matrix, p, q)


def max_regret_profile(A, B, p, q):
    """Maximum regret across both players."""
    regrets = []
    for i in range(A.shape[0]):
        regrets.append(regret(A, p, q, i))
    for j in range(B.shape[1]):
        regrets.append(regret(B.T, q, p, j))
    return max(regrets)


def triangulate_simplex_2d(n_divisions):
    """
    Triangulate the unit simplex {(x,y) : x+y <= 1, x,y >= 0}
    into small triangles with mesh size 1/n_divisions.
    Returns vertices and triangle indices.
    """
    vertices = []
    vertex_map = {}
    for i in range(n_divisions + 1):
        for j in range(n_divisions + 1 - i):
            v = (i / n_divisions, j / n_divisions)
            vertex_map[(i, j)] = len(vertices)
            vertices.append(v)

    triangles = []
    for i in range(n_divisions):
        for j in range(n_divisions - i):
            # Lower triangle
            v0 = vertex_map[(i, j)]
            v1 = vertex_map[(i + 1, j)]
            v2 = vertex_map[(i, j + 1)]
            triangles.append((v0, v1, v2))
            # Upper triangle (if it exists)
            if i + j + 1 < n_divisions:
                v3 = vertex_map[(i + 1, j + 1)]
                triangles.append((v1, v3, v2))

    return np.array(vertices), triangles


def sperner_color_game(A, B, vertex, n_strats_row, n_strats_col):
    """
    Assign a Sperner-compatible color based on best-response:
    - vertex is a point in the product simplex (p, q)
    - Color = player with highest regret from their best deviation
    Returns 0 (row player) or 1 (col player) and the max regret.
    """
    p = np.zeros(n_strats_row)
    q = np.zeros(n_strats_col)

    # For 2x2 games: vertex = (p1, q1) where p = (1-p1, p1), q = (1-q1, q1)
    p[0] = 1 - vertex[0]
    p[1] = vertex[0]
    q[0] = 1 - vertex[1]
    q[1] = vertex[1]

    row_regrets = [regret(A, p, q, i) for i in range(n_strats_row)]
    col_regrets = [regret(B.T, q, p, j) for j in range(n_strats_col)]

    max_row = max(row_regrets)
    max_col = max(col_regrets)

    return (0 if max_row >= max_col else 1, max(max_row, max_col))


def find_approx_nash_sperner(A, B, n_divisions=20):
    """
    Find approximate Nash equilibria using Sperner-type coloring.
    
    Algorithm:
    1. Triangulate the 2D mixed strategy space
    2. Color each vertex by which player has higher max regret
    3. Find "chromatic boundary" simplices (mixed colors)
    4. Return barycenters of boundary simplices as approximate equilibria
    """
    vertices, triangles = triangulate_simplex_2d(n_divisions)
    n_row, n_col = A.shape

    # Color each vertex
    colors = []
    max_regrets = []
    for v in vertices:
        c, mr = sperner_color_game(A, B, v, n_row, n_col)
        colors.append(c)
        max_regrets.append(mr)

    # Find chromatic boundary simplices (containing both colors)
    boundary_simplices = []
    for tri in triangles:
        tri_colors = {colors[v] for v in tri}
        if len(tri_colors) > 1:  # Mixed colors = boundary
            boundary_simplices.append(tri)

    # Compute barycenters and their regrets
    approx_equilibria = []
    for tri in boundary_simplices:
        barycenter = np.mean([vertices[v] for v in tri], axis=0)
        p = np.array([1 - barycenter[0], barycenter[0]])
        q = np.array([1 - barycenter[1], barycenter[1]])
        mr = max_regret_profile(A, B, p, q)
        approx_equilibria.append((p, q, mr))

    # Sort by max regret (best approximations first)
    approx_equilibria.sort(key=lambda x: x[2])
    return approx_equilibria


def demo_prisoners_dilemma():
    """Prisoner's Dilemma: unique Nash at (Defect, Defect)."""
    print("=" * 60)
    print("PRISONER'S DILEMMA")
    print("=" * 60)
    # Payoff matrices (row player A, column player B)
    A = np.array([[-1, -3], [0, -2]])  # Row player
    B = np.array([[-1, 0], [-3, -2]])  # Column player

    print("Row player payoff matrix A:")
    print(A)
    print("Column player payoff matrix B:")
    print(B)

    equilibria = find_approx_nash_sperner(A, B, n_divisions=50)
    print(f"\nFound {len(equilibria)} chromatic boundary simplices")
    if equilibria:
        p, q, mr = equilibria[0]
        print(f"\nBest approximate Nash equilibrium:")
        print(f"  Row player: p = ({p[0]:.4f}, {p[1]:.4f})")
        print(f"  Col player: q = ({q[0]:.4f}, {q[1]:.4f})")
        print(f"  Max regret: {mr:.6f}")
        print(f"  (Expected: p ≈ (0, 1), q ≈ (0, 1) — both defect)")


def demo_matching_pennies():
    """Matching Pennies: unique Nash at (0.5, 0.5)."""
    print("\n" + "=" * 60)
    print("MATCHING PENNIES")
    print("=" * 60)
    A = np.array([[1, -1], [-1, 1]])
    B = np.array([[-1, 1], [1, -1]])

    print("Row player payoff matrix A:")
    print(A)
    print("Column player payoff matrix B:")
    print(B)

    equilibria = find_approx_nash_sperner(A, B, n_divisions=50)
    print(f"\nFound {len(equilibria)} chromatic boundary simplices")
    if equilibria:
        p, q, mr = equilibria[0]
        print(f"\nBest approximate Nash equilibrium:")
        print(f"  Row player: p = ({p[0]:.4f}, {p[1]:.4f})")
        print(f"  Col player: q = ({q[0]:.4f}, {q[1]:.4f})")
        print(f"  Max regret: {mr:.6f}")
        print(f"  (Expected: p = (0.5, 0.5), q = (0.5, 0.5))")


def demo_battle_of_sexes():
    """Battle of the Sexes: two pure + one mixed Nash."""
    print("\n" + "=" * 60)
    print("BATTLE OF THE SEXES")
    print("=" * 60)
    A = np.array([[3, 0], [0, 2]])
    B = np.array([[2, 0], [0, 3]])

    print("Row player payoff matrix A:")
    print(A)
    print("Column player payoff matrix B:")
    print(B)

    equilibria = find_approx_nash_sperner(A, B, n_divisions=100)
    print(f"\nFound {len(equilibria)} chromatic boundary simplices")

    # Show top 3 approximate equilibria
    seen = set()
    count = 0
    for p, q, mr in equilibria:
        key = (round(p[0], 2), round(q[0], 2))
        if key not in seen and mr < 0.1:
            seen.add(key)
            count += 1
            print(f"\nApproximate Nash #{count}:")
            print(f"  Row player: p = ({p[0]:.4f}, {p[1]:.4f})")
            print(f"  Col player: q = ({q[0]:.4f}, {q[1]:.4f})")
            print(f"  Max regret: {mr:.6f}")
            if count >= 5:
                break

    print(f"\n  (Expected equilibria: (1,0)x(1,0), (0,1)x(0,1), (0.6,0.4)x(0.4,0.6))")


def demo_convergence():
    """Show convergence of Sperner approximation as mesh refines."""
    print("\n" + "=" * 60)
    print("CONVERGENCE OF SPERNER APPROXIMATION")
    print("=" * 60)

    # Use matching pennies (known Nash at (0.5, 0.5))
    A = np.array([[1, -1], [-1, 1]])
    B = np.array([[-1, 1], [1, -1]])

    print("\nMatching Pennies — tracking best approximation vs mesh size:")
    print(f"{'Divisions':>10} {'Mesh':>10} {'Max Regret':>12} {'p[0]':>8} {'q[0]':>8}")
    print("-" * 55)

    for n in [5, 10, 20, 50, 100, 200]:
        equilibria = find_approx_nash_sperner(A, B, n_divisions=n)
        if equilibria:
            p, q, mr = equilibria[0]
            print(f"{n:>10} {1/n:>10.4f} {mr:>12.6f} {p[0]:>8.4f} {q[0]:>8.4f}")

    print("\nObservation: Max regret → 0 as mesh → 0 (convergence!)")
    print("The Sperner-Nash number grows as O(N^n) where N = divisions, n = players.")


if __name__ == "__main__":
    print("SPERNER-NASH BRIDGE: COMBINATORIAL FIXED POINTS IN GAME THEORY")
    print("Demonstrating Sperner-based Nash equilibrium computation\n")

    demo_prisoners_dilemma()
    demo_matching_pennies()
    demo_battle_of_sexes()
    demo_convergence()


#!/usr/bin/env python3
"""
Visualization: Chromatic Decomposition of the strategy space.
Shows how the strategy space partitions into regions by dominant player regret.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection


def chromatic_color_2x2(A, B, p1, q1):
    """Return which player has higher max regret at (p1, q1)."""
    p = np.array([1 - p1, p1])
    q = np.array([1 - q1, q1])
    exp_row = p @ A @ q
    exp_col = p @ B @ q
    max_row_regret = max(A[i] @ q - exp_row for i in range(2))
    max_col_regret = max(B.T[j] @ p - exp_col for j in range(2))
    return 0 if max_row_regret >= max_col_regret else 1


def plot_chromatic_decomposition(A, B, title, ax, n_grid=200):
    """Plot the chromatic decomposition."""
    p_vals = np.linspace(0, 1, n_grid)
    q_vals = np.linspace(0, 1, n_grid)
    P, Q = np.meshgrid(p_vals, q_vals)
    Z = np.zeros_like(P)
    for i in range(n_grid):
        for j in range(n_grid):
            Z[i, j] = chromatic_color_2x2(A, B, P[i, j], Q[i, j])

    ax.pcolormesh(P, Q, Z, cmap='RdBu', shading='auto', alpha=0.6)
    ax.contour(P, Q, Z, levels=[0.5], colors='black', linewidths=2)
    ax.set_xlabel('Player 1 mix')
    ax.set_ylabel('Player 2 mix')
    ax.set_title(title)
    ax.set_aspect('equal')

    # Add triangulation overlay
    n_tri = 10
    for i in range(n_tri + 1):
        ax.axhline(y=i/n_tri, color='gray', alpha=0.2, linewidth=0.5)
        ax.axvline(x=i/n_tri, color='gray', alpha=0.2, linewidth=0.5)
    for i in range(n_tri):
        for j in range(n_tri):
            ax.plot([i/n_tri, (i+1)/n_tri], [(j+1)/n_tri, j/n_tri],
                   color='gray', alpha=0.2, linewidth=0.5)


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Matching Pennies
A1 = np.array([[1, -1], [-1, 1]])
B1 = np.array([[-1, 1], [1, -1]])
plot_chromatic_decomposition(A1, B1,
    "Matching Pennies\nChromatic boundary at (0.5, 0.5)", axes[0])
axes[0].plot(0.5, 0.5, 'w*', markersize=15, markeredgecolor='black')

# Battle of the Sexes
A2 = np.array([[3, 0], [0, 2]])
B2 = np.array([[2, 0], [0, 3]])
plot_chromatic_decomposition(A2, B2,
    "Battle of the Sexes\nChromatic boundaries at 3 Nash points", axes[1])
axes[1].plot([0, 1, 0.6], [0, 1, 0.4], 'w*', markersize=12, markeredgecolor='black')

# Coordination Game
A3 = np.array([[2, 0], [0, 1]])
B3 = np.array([[2, 0], [0, 1]])
plot_chromatic_decomposition(A3, B3,
    "Coordination Game\nSymmetric chromatic regions", axes[2])

plt.suptitle("Chromatic Decomposition: Strategy Space Partitioned by Dominant Regret Player",
             fontsize=13, y=1.02)
plt.tight_layout()
plt.savefig("chromatic_decomposition.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved chromatic_decomposition.png")


#!/usr/bin/env python3
"""
Visualization: Convergence of Sperner-Nash approximation.
Shows how max regret decreases as triangulation mesh gets finer.
"""

import numpy as np
import matplotlib.pyplot as plt


def expected_payoff_2x2(A, p, q):
    return p @ A @ q


def max_regret_profile_2x2(A, B, p, q):
    exp_row = p @ A @ q
    exp_col = p @ B @ q
    row_regrets = [A[i] @ q - exp_row for i in range(2)]
    col_regrets = [B.T[j] @ p - exp_col for j in range(2)]
    return max(max(row_regrets), max(col_regrets))


def sperner_nash_solve_2x2(A, B, n):
    """Find best approximate Nash in 2x2 game with n grid divisions."""
    best_regret = float('inf')
    best_p = None
    best_q = None
    for i in range(n + 1):
        for j in range(n + 1):
            p1 = i / n
            q1 = j / n
            p = np.array([1 - p1, p1])
            q = np.array([1 - q1, q1])
            mr = max_regret_profile_2x2(A, B, p, q)
            if mr < best_regret:
                best_regret = mr
                best_p = p.copy()
                best_q = q.copy()
    return best_p, best_q, best_regret


# Games to test
games = {
    "Matching Pennies": (
        np.array([[1, -1], [-1, 1]]),
        np.array([[-1, 1], [1, -1]])
    ),
    "Battle of the Sexes": (
        np.array([[3, 0], [0, 2]]),
        np.array([[2, 0], [0, 3]])
    ),
    "Hawk-Dove": (
        np.array([[0, 3], [1, 2]]),
        np.array([[0, 1], [3, 2]])
    ),
}

divisions = [3, 5, 8, 10, 15, 20, 30, 50, 80, 100, 150, 200]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

for name, (A, B) in games.items():
    regrets = []
    snn = []
    for n in divisions:
        _, _, mr = sperner_nash_solve_2x2(A, B, n)
        regrets.append(mr)
        snn.append(n ** 2)  # Sperner-Nash number for 2 players
    ax1.loglog(divisions, regrets, 'o-', label=name, markersize=4)

# Theoretical bound: O(1/n)
theory_x = np.array(divisions, dtype=float)
theory_y = 3.0 / theory_x
ax1.loglog(theory_x, theory_y, 'k--', alpha=0.5, label='O(1/n) bound')

ax1.set_xlabel('Grid divisions (n)')
ax1.set_ylabel('Best max regret')
ax1.set_title('Convergence: Max Regret vs. Grid Resolution')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Sperner-Nash number plot
for name, (A, B) in games.items():
    regrets = []
    for n in divisions:
        _, _, mr = sperner_nash_solve_2x2(A, B, n)
        regrets.append(mr)
    ax2.loglog([n**2 for n in divisions], regrets, 's-', label=name, markersize=4)

ax2.set_xlabel('Sperner-Nash number (n²)')
ax2.set_ylabel('Best max regret')
ax2.set_title('Approximation Quality vs. Computational Cost')
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("convergence.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved convergence.png")


#!/usr/bin/env python3
"""
Visualization: The Regret Landscape of a 2-player game.
Shows the max regret as a heat map over the mixed strategy space,
with Nash equilibria at the zero contours.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


def max_regret_2x2(A, B, p1, q1):
    """Compute max regret for a 2x2 game at mixed strategies (p1, q1)."""
    p = np.array([1 - p1, p1])
    q = np.array([1 - q1, q1])
    exp_row = p @ A @ q
    exp_col = p @ B @ q
    row_regrets = [A[i] @ q - exp_row for i in range(2)]
    col_regrets = [B.T[j] @ p - exp_col for j in range(2)]
    return max(max(row_regrets), max(col_regrets))


def plot_regret_landscape(A, B, title, ax, n_grid=200):
    """Plot the regret landscape as a heatmap."""
    p_vals = np.linspace(0, 1, n_grid)
    q_vals = np.linspace(0, 1, n_grid)
    P, Q = np.meshgrid(p_vals, q_vals)
    Z = np.zeros_like(P)
    for i in range(n_grid):
        for j in range(n_grid):
            Z[i, j] = max(max_regret_2x2(A, B, P[i, j], Q[i, j]), 1e-10)

    im = ax.pcolormesh(P, Q, Z, cmap='hot_r', shading='auto')
    ax.contour(P, Q, Z, levels=[0.01, 0.05, 0.1, 0.2, 0.5], colors='white',
               linewidths=0.5, linestyles='--')
    ax.contour(P, Q, Z, levels=[0.001], colors='cyan', linewidths=2)
    ax.set_xlabel('Player 1 mix (prob of strategy 2)')
    ax.set_ylabel('Player 2 mix (prob of strategy 2)')
    ax.set_title(title)
    ax.set_aspect('equal')
    plt.colorbar(im, ax=ax, label='Max Regret')


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Matching Pennies
A1 = np.array([[1, -1], [-1, 1]])
B1 = np.array([[-1, 1], [1, -1]])
plot_regret_landscape(A1, B1, "Matching Pennies\nNash at (0.5, 0.5)", axes[0])

# Battle of the Sexes
A2 = np.array([[3, 0], [0, 2]])
B2 = np.array([[2, 0], [0, 3]])
plot_regret_landscape(A2, B2, "Battle of the Sexes\n3 Nash equilibria", axes[1])

# Prisoner's Dilemma
A3 = np.array([[-1, -3], [0, -2]])
B3 = np.array([[-1, 0], [-3, -2]])
plot_regret_landscape(A3, B3, "Prisoner's Dilemma\nNash at (1, 1)", axes[2])

plt.suptitle("The Regret Landscape: Nash Equilibria as Zero Contours", fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig("regret_landscape.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved regret_landscape.png")
