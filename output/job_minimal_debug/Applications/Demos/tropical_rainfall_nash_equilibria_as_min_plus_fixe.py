#!/usr/bin/env python3
"""
Tropical Game Theory — Real-World Applications

Demonstrates how tropical game theory applies to:
1. Shortest-path routing in networks
2. Supply chain optimization (min-cost logistics)
3. Scheduling / critical path analysis
4. Adversarial robustness in neural networks (tropical perspective)
"""

import numpy as np
from algorithms import (
    tropical_bellman, min_plus_closure, tropical_value_iteration,
    find_saddle_points, solve_tropical_game, extract_optimal_policy
)


# ═══════════════════════════════════════════════════════════════════════
# Application 1: Network Routing as Tropical Game
# ═══════════════════════════════════════════════════════════════════════

def app_network_routing():
    """
    Model network routing as a tropical game.

    Nodes are players, edge weights are costs.
    The tropical Bellman operator computes optimal next-hop decisions.
    Fixed points give the steady-state routing table.
    """
    print("=" * 60)
    print("Application 1: Network Routing as Tropical Game")
    print("=" * 60)

    # 5-node network: cost matrix (inf = no direct edge)
    INF = 1e6
    cost = np.array([
        [0,   2,   INF, 6,   INF],
        [2,   0,   3,   8,   5  ],
        [INF, 3,   0,   INF, 7  ],
        [6,   8,   INF, 0,   9  ],
        [INF, 5,   7,   9,   0  ]
    ])

    print("\nDirect cost matrix (∞ = no edge):")
    display = cost.copy()
    display[display >= INF] = np.inf
    print(np.array2string(display, precision=0))

    # Compute shortest-path closure
    closure = min_plus_closure(cost)
    print("\nAll-pairs shortest paths (tropical closure):")
    print(np.array2string(closure, precision=1))

    # Verify idempotence of closure
    from algorithms import is_min_plus_idempotent
    print(f"\nClosure is min-plus idempotent: {is_min_plus_idempotent(closure)}")

    # Value iteration from node 0's perspective
    x0 = np.zeros(5)
    fp, iters, _ = tropical_value_iteration(closure, x0)
    print(f"\nFixed point from x0 = {x0}: {fp}")
    print(f"Converged in {iters} iteration(s)")

    # Extract routing policy
    policy = extract_optimal_policy(closure, fp)
    print(f"Optimal next-hop policy: {policy}")
    print("  (each node routes to the neighbor minimizing total cost)")


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Supply Chain Min-Cost Logistics
# ═══════════════════════════════════════════════════════════════════════

def app_supply_chain():
    """
    Model supply chain as a tropical game.

    Warehouses compete to serve demand nodes at minimum cost.
    The tropical Bellman operator propagates minimum-cost assignments.
    """
    print("\n" + "=" * 60)
    print("Application 2: Supply Chain Optimization")
    print("=" * 60)

    # Cost matrix: warehouse i → customer j
    # Rows = warehouses, Columns = customers
    cost = np.array([
        [10, 15, 20, 25],  # Warehouse A
        [12, 8,  18, 30],  # Warehouse B
        [25, 22, 5,  10],  # Warehouse C
        [20, 25, 15, 8],   # Warehouse D
    ], dtype=float)

    print("\nCost matrix (warehouse → customer):")
    labels = ['A', 'B', 'C', 'D']
    print("         Cust1  Cust2  Cust3  Cust4")
    for i, label in enumerate(labels):
        print(f"  WH {label}: {cost[i]}")

    result = solve_tropical_game(cost, compute_closure=False)
    print(f"\nLower value (max-min): {result['lower_value']}")
    print(f"Upper value (min-max): {result['upper_value']}")
    print(f"Minimax gap: {result['minimax_gap']}")

    saddles = result['saddle_points']
    if saddles:
        for i, j in saddles:
            print(f"Saddle point: WH {labels[i]} → Cust{j+1}, cost = {cost[i,j]}")
            print("This is the minimax-optimal assignment!")
    else:
        print("No pure saddle point — mixed strategies needed in classical theory")
        print("In tropical theory, the minimax gap measures the 'cost of uncertainty'")


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Critical Path / Scheduling
# ═══════════════════════════════════════════════════════════════════════

def app_scheduling():
    """
    Model project scheduling as a tropical fixed-point problem.

    Tasks have dependencies with processing times.
    The tropical Bellman operator propagates earliest start times.
    Fixed points give the critical path schedule.
    """
    print("\n" + "=" * 60)
    print("Application 3: Critical Path Scheduling")
    print("=" * 60)

    # Task dependency matrix: A[i,j] = time to go from completing task i
    # to starting task j (including task j's duration)
    # Using max-plus convention here (dual to min-plus)
    INF = -1e6  # Using negative infinity for max-plus "zero"
    A = np.array([
        [0,   3,   5,   INF, INF],  # Task 0: Start
        [INF, 0,   INF, 4,   INF],  # Task 1: Foundation
        [INF, INF, 0,   2,   6],    # Task 2: Framing
        [INF, INF, INF, 0,   3],    # Task 3: Wiring
        [INF, INF, INF, INF, 0],    # Task 4: Finish
    ], dtype=float)

    # For max-plus, negate and use min-plus
    A_minplus = -A  # Convert to min-plus problem
    A_minplus[A_minplus > 1e5] = 1e6

    print("\nTask dependency times (max-plus):")
    tasks = ['Start', 'Foundation', 'Framing', 'Wiring', 'Finish']
    for i, task in enumerate(tasks):
        deps = []
        for j in range(5):
            if A[i, j] != INF and i != j:
                deps.append(f"{tasks[j]}({A[i,j]:.0f})")
        if deps:
            print(f"  {task} → {', '.join(deps)}")

    # Compute critical path via closure
    closure = min_plus_closure(A_minplus)
    # The negated closure gives max-plus shortest paths = longest paths = critical path
    crit = -closure

    print("\nCritical path lengths (earliest completion times from Start):")
    for i, task in enumerate(tasks):
        if crit[0, i] > -1e5:
            print(f"  Start → {task}: {crit[0, i]:.0f} time units")

    print(f"\nTotal project duration: {crit[0, 4]:.0f} time units")


# ═══════════════════════════════════════════════════════════════════════
# Application 4: Adversarial Robustness (Tropical Perspective)
# ═══════════════════════════════════════════════════════════════════════

def app_adversarial_robustness():
    """
    Model adversarial robustness as a tropical minimax game.

    The attacker minimizes classifier confidence (rows = attack strategies).
    The defender maximizes robustness (columns = defense strategies).
    The tropical minimax theorem gives bounds on achievable robustness.
    """
    print("\n" + "=" * 60)
    print("Application 4: Adversarial Robustness as Tropical Game")
    print("=" * 60)

    # Robustness margins for different attack/defense pairs
    # Rows = attack types, Columns = defense types
    # Higher values = more robust
    robustness = np.array([
        [0.8, 0.3, 0.6, 0.5],  # FGSM attack
        [0.4, 0.9, 0.2, 0.7],  # PGD attack
        [0.5, 0.6, 0.7, 0.4],  # C&W attack
        [0.3, 0.5, 0.4, 0.8],  # AutoAttack
    ])

    attacks = ['FGSM', 'PGD', 'C&W', 'AutoAttack']
    defenses = ['AdvTrain', 'Smoothing', 'TRADES', 'Ensemble']

    print("\nRobustness margin matrix:")
    print(f"{'':12s} {'  '.join(f'{d:>9s}' for d in defenses)}")
    for i, atk in enumerate(attacks):
        print(f"  {atk:10s} {' '.join(f'{robustness[i,j]:9.2f}' for j in range(4))}")

    # Minimax analysis (attacker minimizes, defender maximizes)
    lower = np.max(np.min(robustness, axis=1))
    upper = np.min(np.max(robustness, axis=0))

    print(f"\nWorst-case guarantee (max-min): {lower:.2f}")
    print(f"Best achievable defense (min-max): {upper:.2f}")
    print(f"Minimax gap: {upper - lower:.2f}")

    # Find saddle points
    saddles = find_saddle_points(robustness)
    if saddles:
        for i, j in saddles:
            print(f"\nSaddle point: {attacks[i]} vs {defenses[j]}")
            print(f"  Guaranteed robustness margin: {robustness[i,j]:.2f}")
    else:
        print("\nNo pure saddle point — the game requires mixed strategies")
        print("The minimax gap quantifies the 'price of determinism'")

    # Best pure strategies
    min_per_row = np.min(robustness, axis=1)
    best_defense_idx = np.argmax(min_per_row)
    print(f"\nBest pure defense: {defenses[np.argmax(np.min(robustness, axis=0))]}"
          f" (guarantees ≥ {lower:.2f} robustness)")


if __name__ == "__main__":
    app_network_routing()
    app_supply_chain()
    app_scheduling()
    app_adversarial_robustness()

    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Rainfall: Nash Equilibria as Min-Plus Fixed Points — Demonstrations

This module demonstrates the core theorems of tropical game theory with
concrete numerical examples, showing how the tropical Bellman operator,
minimax inequality, saddle points, and idempotence work in practice.
"""

import numpy as np
from typing import Tuple, Optional

# ─── Core Definitions ───────────────────────────────────────────────────

def trop_bellman(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical Bellman operator: T_A(x)_i = min_j (A[i,j] + x[j])."""
    n = A.shape[0]
    return np.array([np.min(A[i, :] + x) for i in range(n)])


def min_plus_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Min-plus matrix multiplication: (A⊗B)[i,k] = min_j (A[i,j] + B[j,k])."""
    n = A.shape[0]
    C = np.zeros((n, n))
    for i in range(n):
        for k in range(n):
            C[i, k] = np.min(A[i, :] + B[:, k])
    return C


def is_min_plus_idempotent(A: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if A ⊗ A = A in the min-plus semiring."""
    return np.allclose(min_plus_matmul(A, A), A, atol=tol)


def row_min(A: np.ndarray) -> np.ndarray:
    """Row minima: min_j A[i,j] for each i."""
    return np.min(A, axis=1)


def col_max(A: np.ndarray) -> np.ndarray:
    """Column maxima: max_i A[i,j] for each j."""
    return np.max(A, axis=0)


def trop_lower_value(A: np.ndarray) -> float:
    """Tropical lower value: max_i min_j A[i,j]."""
    return float(np.max(row_min(A)))


def trop_upper_value(A: np.ndarray) -> float:
    """Tropical upper value: min_j max_i A[i,j]."""
    return float(np.min(col_max(A)))


def find_saddle_point(A: np.ndarray) -> Optional[Tuple[int, int]]:
    """Find a saddle point (i0, j0) if one exists."""
    n = A.shape[0]
    for i in range(n):
        for j in range(n):
            if all(A[i, j] <= A[i, jj] for jj in range(n)) and \
               all(A[ii, j] <= A[i, j] for ii in range(n)):
                return (i, j)
    return None


# ─── Demo 1: Fixed Point = Bellman Equation ─────────────────────────────

def demo_fixed_point():
    print("=" * 60)
    print("Demo 1: Tropical Fixed Point = Bellman Equation")
    print("=" * 60)

    # A shortest-path matrix (min-plus idempotent = closure of distances)
    A = np.array([
        [0.0, 2.0, 5.0],
        [2.0, 0.0, 1.0],
        [5.0, 1.0, 0.0]
    ])

    # The diagonal row of A is a fixed point of T_A
    v = np.array([0.0, 0.0, 0.0])
    Tv = trop_bellman(A, v)
    print(f"\nA = \n{A}")
    print(f"v = {v}")
    print(f"T_A(v) = {Tv}")
    print(f"Fixed point? {np.allclose(Tv, v)}")

    # Verify coordinatewise: v_i = min_j (A[i,j] + v[j])
    print("\nCoordinatewise Bellman check:")
    for i in range(3):
        val = min(A[i, j] + v[j] for j in range(3))
        print(f"  min_j(A[{i},j] + v[j]) = {val} = v[{i}] = {v[i]}")

    # Non-fixed-point example
    w = np.array([1.0, 2.0, 3.0])
    Tw = trop_bellman(A, w)
    print(f"\nw = {w}")
    print(f"T_A(w) = {Tw}")
    print(f"Fixed point? {np.allclose(Tw, w)}")


# ─── Demo 2: Monotonicity ───────────────────────────────────────────────

def demo_monotonicity():
    print("\n" + "=" * 60)
    print("Demo 2: Monotonicity of Bellman Operator")
    print("=" * 60)

    A = np.array([
        [1.0, 3.0],
        [2.0, 4.0]
    ])

    x = np.array([0.0, 0.0])
    y = np.array([1.0, 2.0])

    print(f"x = {x}, y = {y}")
    print(f"x ≤ y pointwise? {all(x[i] <= y[i] for i in range(2))}")

    Tx = trop_bellman(A, x)
    Ty = trop_bellman(A, y)
    print(f"T_A(x) = {Tx}")
    print(f"T_A(y) = {Ty}")
    print(f"T_A(x) ≤ T_A(y) pointwise? {all(Tx[i] <= Ty[i] for i in range(2))}")


# ─── Demo 3: Min-Plus Idempotence → Operator Idempotence ─────────────

def demo_idempotence():
    print("\n" + "=" * 60)
    print("Demo 3: Min-Plus Idempotent Matrix → Idempotent Operator")
    print("=" * 60)

    # Shortest-path closure matrix (all-pairs shortest paths)
    A = np.array([
        [0.0, 2.0, 3.0],
        [2.0, 0.0, 1.0],
        [3.0, 1.0, 0.0]
    ])

    print(f"A = \n{A}")
    print(f"A ⊗ A = \n{min_plus_matmul(A, A)}")
    print(f"Min-plus idempotent? {is_min_plus_idempotent(A)}")

    x = np.array([10.0, -5.0, 3.0])
    Tx = trop_bellman(A, x)
    TTx = trop_bellman(A, Tx)

    print(f"\nx = {x}")
    print(f"T_A(x) = {Tx}")
    print(f"T_A(T_A(x)) = {TTx}")
    print(f"T_A idempotent on x? {np.allclose(TTx, Tx)}")

    # Verify T_A(x) is a fixed point
    print(f"T_A(x) is a fixed point? {np.allclose(trop_bellman(A, Tx), Tx)}")


# ─── Demo 4: Minimax Inequality ─────────────────────────────────────────

def demo_minimax():
    print("\n" + "=" * 60)
    print("Demo 4: Tropical Minimax Inequality")
    print("=" * 60)

    matrices = [
        ("Random 3×3", np.array([[3, 1, 4], [1, 5, 9], [2, 6, 5]], dtype=float)),
        ("Random 4×4", np.array([[1, 7, 3, 2], [5, 2, 8, 4], [6, 3, 1, 9], [4, 8, 5, 3]], dtype=float)),
        ("Saddle-point matrix", np.array([[3, 5, 7], [1, 4, 6], [2, 3, 8]], dtype=float)),
    ]

    for name, A in matrices:
        lower = trop_lower_value(A)
        upper = trop_upper_value(A)
        saddle = find_saddle_point(A)
        print(f"\n{name}:")
        print(f"  A = \n{A}")
        print(f"  Lower value (max-min) = {lower}")
        print(f"  Upper value (min-max) = {upper}")
        print(f"  lower ≤ upper? {lower <= upper + 1e-10}")
        if saddle:
            i0, j0 = saddle
            print(f"  Saddle point at ({i0}, {j0}), value = {A[i0, j0]}")
            print(f"  Equality: lower = upper = {A[i0, j0]}? {abs(lower - upper) < 1e-10}")
        else:
            print(f"  No pure saddle point")
            print(f"  Gap = {upper - lower}")


# ─── Demo 5: Value Iteration Convergence ────────────────────────────────

def demo_value_iteration():
    print("\n" + "=" * 60)
    print("Demo 5: Value Iteration Convergence")
    print("=" * 60)

    # Idempotent matrix: converges in 1 step
    A_idem = np.array([
        [0.0, 2.0, 3.0],
        [2.0, 0.0, 1.0],
        [3.0, 1.0, 0.0]
    ])

    print("Case 1: Min-plus idempotent matrix")
    print(f"A = \n{A_idem}")
    x = np.array([100.0, -50.0, 25.0])
    print(f"x_0 = {x}")
    for step in range(5):
        x_new = trop_bellman(A_idem, x)
        print(f"x_{step+1} = T_A(x_{step}) = {x_new}, change = {np.max(np.abs(x_new - x)):.6f}")
        if np.allclose(x_new, x):
            print(f"  → Converged at step {step+1}!")
            break
        x = x_new

    # Non-idempotent matrix: may take more steps
    print("\nCase 2: Non-idempotent matrix")
    A_non = np.array([
        [0.0, 1.0, 10.0],
        [10.0, 0.0, 1.0],
        [1.0, 10.0, 0.0]
    ])
    print(f"A = \n{A_non}")
    print(f"Min-plus idempotent? {is_min_plus_idempotent(A_non)}")
    x = np.array([100.0, 0.0, -50.0])
    print(f"x_0 = {x}")
    for step in range(10):
        x_new = trop_bellman(A_non, x)
        print(f"x_{step+1} = {x_new}, change = {np.max(np.abs(x_new - x)):.6f}")
        if np.allclose(x_new, x):
            print(f"  → Converged at step {step+1}!")
            break
        x = x_new


# ─── Demo 6: Fixed-Point Set = Image ────────────────────────────────────

def demo_fixed_image():
    print("\n" + "=" * 60)
    print("Demo 6: Fixed-Point Set = Image (Idempotent Case)")
    print("=" * 60)

    A = np.array([
        [0.0, 2.0, 3.0],
        [2.0, 0.0, 1.0],
        [3.0, 1.0, 0.0]
    ])
    print(f"A (idempotent) = \n{A}")

    # Generate many images and verify they're all fixed points
    np.random.seed(42)
    print("\nSampling random inputs, computing T_A(x), checking if fixed:")
    for trial in range(5):
        x = np.random.randn(3) * 10
        Tx = trop_bellman(A, x)
        TTx = trop_bellman(A, Tx)
        print(f"  x = [{x[0]:7.2f}, {x[1]:7.2f}, {x[2]:7.2f}] "
              f"→ T(x) = [{Tx[0]:7.2f}, {Tx[1]:7.2f}, {Tx[2]:7.2f}] "
              f"→ fixed? {np.allclose(TTx, Tx)}")


if __name__ == "__main__":
    demo_fixed_point()
    demo_monotonicity()
    demo_idempotence()
    demo_minimax()
    demo_value_iteration()
    demo_fixed_image()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""
import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def img_to_base64(path):
    with open(path, 'rb') as f:
        encoded = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{encoded}"

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Catalog/Tropical/TropicalGameEquilibria.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read visualizations
viz_convergence = img_to_base64('viz_convergence.png')
viz_minimax = img_to_base64('viz_minimax.png')
viz_fixed_points = img_to_base64('viz_fixed_points.png')
viz_idempotence = img_to_base64('viz_idempotence.png')

package = {
    "title": "Tropical Rainfall: Nash Equilibria as Min-Plus Fixed Points",
    "domain": "Tropical Algebra, Game Theory, Fixed-Point Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Game Theory Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Bellman Value Iteration",
            "pseudocode": "Input: Matrix A, initial vector x0, tolerance eps\n1. Set x <- x0\n2. Repeat:\n   a. For each i: x'_i <- min_j(A[i,j] + x[j])\n   b. If ||x' - x||_inf < eps: return x'\n   c. Set x <- x'\n3. Return x\n\nComplexity: O(n^2) per iteration, 1 iteration for idempotent matrices",
            "code": algorithms_code
        },
        {
            "name": "Min-Plus Closure (Floyd-Warshall)",
            "pseudocode": "Input: Matrix A\n1. R <- A; R[i,i] <- min(R[i,i], 0)\n2. For k = 1 to n:\n   For i, j: R[i,j] <- min(R[i,j], R[i,k] + R[k,j])\n3. Return R (guaranteed idempotent)\n\nComplexity: O(n^3)",
            "code": "# See algorithms.py for full implementation\nimport numpy as np\n\ndef min_plus_closure(A):\n    n = A.shape[0]\n    result = A.copy()\n    for i in range(n):\n        result[i,i] = min(result[i,i], 0.0)\n    for k in range(n):\n        for i in range(n):\n            for j in range(n):\n                result[i,j] = min(result[i,j], result[i,k] + result[k,j])\n    return result\n\n# Example\nA = np.array([[0, 1, 10], [10, 0, 1], [1, 10, 0]], dtype=float)\nprint('Original:', A)\nprint('Closure:', min_plus_closure(A))"
        },
        {
            "name": "Saddle Point Detection",
            "pseudocode": "Input: Matrix A\n1. row_min[i] = min_j A[i,j]\n2. col_max[j] = max_i A[i,j]\n3. Return {(i,j) : A[i,j] = row_min[i] and A[i,j] = col_max[j]}\n\nComplexity: O(n^2)",
            "code": "import numpy as np\n\ndef find_saddle_points(A):\n    n = A.shape[0]\n    row_mins = np.min(A, axis=1)\n    col_maxs = np.max(A, axis=0)\n    saddles = []\n    for i in range(n):\n        for j in range(n):\n            if A[i,j] == row_mins[i] and A[i,j] == col_maxs[j]:\n                saddles.append((i,j))\n    return saddles\n\n# Example with saddle point\nA = np.array([[3, 5, 7], [1, 4, 6], [2, 3, 8]], dtype=float)\nprint('Matrix:', A)\nprint('Saddle points:', find_saddle_points(A))\nprint('Lower value:', np.max(np.min(A, axis=1)))\nprint('Upper value:', np.min(np.max(A, axis=0)))"
        }
    ],
    "visualizations": [
        {"name": "Value Iteration Convergence", "data": viz_convergence},
        {"name": "Tropical Minimax Inequality", "data": viz_minimax},
        {"name": "Fixed-Point Geometry (Image = Fixed Points)", "data": viz_fixed_points},
        {"name": "Min-Plus Matrix Powers and Closure", "data": viz_idempotence}
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Tropical Game Theory — Visualizations

Generates publication-quality figures illustrating:
1. Tropical Bellman operator convergence
2. Minimax inequality and saddle points
3. Fixed-point geometry
4. Min-plus idempotence
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import cm
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def tropical_bellman(A, x):
    n = A.shape[0]
    return np.array([np.min(A[i, :] + x) for i in range(n)])


# ═══════════════════════════════════════════════════════════════════════
# Visualization 1: Value Iteration Convergence
# ═══════════════════════════════════════════════════════════════════════

def viz_convergence():
    """Show convergence of tropical value iteration for idempotent vs non-idempotent matrices."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Idempotent case
    A_idem = np.array([[0, 2, 3], [2, 0, 1], [3, 1, 0]], dtype=float)
    x = np.array([10.0, -5.0, 3.0])
    trajectory = [x.copy()]
    for _ in range(6):
        x = tropical_bellman(A_idem, x)
        trajectory.append(x.copy())
    traj = np.array(trajectory)

    ax = axes[0]
    for i in range(3):
        ax.plot(range(len(traj)), traj[:, i], 'o-', linewidth=2, markersize=6,
                label=f'$v_{i+1}$')
    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Idempotent Matrix\n(1-step convergence)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.axvline(x=1, color='red', linestyle='--', alpha=0.5, label='Convergence')

    # Non-idempotent case
    A_non = np.array([[0, 1, 10], [10, 0, 1], [1, 10, 0]], dtype=float)
    x = np.array([20.0, 0.0, -10.0])
    trajectory = [x.copy()]
    for _ in range(8):
        x = tropical_bellman(A_non, x)
        trajectory.append(x.copy())
    traj = np.array(trajectory)

    ax = axes[1]
    for i in range(3):
        ax.plot(range(len(traj)), traj[:, i], 'o-', linewidth=2, markersize=6,
                label=f'$v_{i+1}$')
    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Non-Idempotent Matrix\n(multi-step convergence)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Tropical Value Iteration Convergence', fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()

    fig.savefig('/workspace/request-project/viz_convergence.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════════════
# Visualization 2: Minimax Inequality
# ═══════════════════════════════════════════════════════════════════════

def viz_minimax():
    """Visualize the minimax inequality with heatmap and value lines."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Case 1: With saddle point (equality)
    A1 = np.array([[3, 5, 7], [1, 4, 6], [2, 3, 8]], dtype=float)
    ax = axes[0]
    im = ax.imshow(A1, cmap='YlOrRd', aspect='equal')
    for i in range(3):
        for j in range(3):
            ax.text(j, i, f'{A1[i,j]:.0f}', ha='center', va='center', fontsize=14, fontweight='bold')

    # Mark saddle point
    ax.plot(0, 0, 's', color='blue', markersize=30, fillstyle='none', linewidth=3)
    ax.set_title(f'Saddle Point Matrix\nmax-min = min-max = 3', fontsize=13, fontweight='bold')
    ax.set_xlabel('Column (j)', fontsize=11)
    ax.set_ylabel('Row (i)', fontsize=11)
    plt.colorbar(im, ax=ax, label='Payoff')

    # Case 2: No saddle point (strict inequality)
    A2 = np.array([[3, 1, 4], [1, 5, 9], [2, 6, 5]], dtype=float)
    ax = axes[1]
    im = ax.imshow(A2, cmap='YlOrRd', aspect='equal')
    for i in range(3):
        for j in range(3):
            ax.text(j, i, f'{A2[i,j]:.0f}', ha='center', va='center', fontsize=14, fontweight='bold')

    lower = np.max(np.min(A2, axis=1))
    upper = np.min(np.max(A2, axis=0))
    ax.set_title(f'No Saddle Point\nmax-min = {lower:.0f} < min-max = {upper:.0f}', fontsize=13, fontweight='bold')
    ax.set_xlabel('Column (j)', fontsize=11)
    ax.set_ylabel('Row (i)', fontsize=11)
    plt.colorbar(im, ax=ax, label='Payoff')

    fig.suptitle('Tropical Minimax Inequality: max min ≤ min max', fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()

    fig.savefig('/workspace/request-project/viz_minimax.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════════════
# Visualization 3: Fixed-Point Geometry
# ═══════════════════════════════════════════════════════════════════════

def viz_fixed_points():
    """Visualize the image = fixed-point-set theorem for idempotent operators."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 7))

    A = np.array([[0, 2, 3], [2, 0, 1], [3, 1, 0]], dtype=float)

    # Sample many random inputs and plot their images
    np.random.seed(42)
    n_samples = 200
    inputs = np.random.randn(n_samples, 3) * 10
    outputs = np.array([tropical_bellman(A, x) for x in inputs])

    # Project to 2D using first two coordinates relative to third
    def project(pts):
        return pts[:, 0] - pts[:, 2], pts[:, 1] - pts[:, 2]

    xi, yi = project(inputs)
    xo, yo = project(outputs)

    ax.scatter(xi, yi, c='lightblue', alpha=0.4, s=20, label='Input points x', zorder=1)
    ax.scatter(xo, yo, c='red', alpha=0.7, s=30, label='Image T_A(x) = fixed points', zorder=2)

    # Draw arrows for a few examples
    for k in range(0, n_samples, 20):
        ax.annotate('', xy=(xo[k], yo[k]), xytext=(xi[k], yi[k]),
                    arrowprops=dict(arrowstyle='->', color='gray', alpha=0.3, lw=0.8))

    ax.set_xlabel('$v_1 - v_3$', fontsize=12)
    ax.set_ylabel('$v_2 - v_3$', fontsize=12)
    ax.set_title('Image = Fixed Points\n(Idempotent Bellman Operator)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_fixed_points.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════════════
# Visualization 4: Idempotence Landscape
# ═══════════════════════════════════════════════════════════════════════

def viz_idempotence():
    """Show how min-plus closure makes any matrix idempotent."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 4.5))

    # Start with a non-idempotent matrix
    A = np.array([[0, 1, 10], [10, 0, 1], [1, 10, 0]], dtype=float)

    # Compute A, A², A*
    def min_plus_mul(X, Y):
        n = X.shape[0]
        C = np.zeros((n, n))
        for i in range(n):
            for k in range(n):
                C[i, k] = np.min(X[i, :] + Y[:, k])
        return C

    A2 = min_plus_mul(A, A)

    # Floyd-Warshall closure
    Astar = A.copy()
    n = A.shape[0]
    for k in range(n):
        for i in range(n):
            for j in range(n):
                Astar[i, j] = min(Astar[i, j], Astar[i, k] + Astar[k, j])

    matrices = [A, A2, Astar]
    titles = ['A (original)', 'A ⊗ A (min-plus square)', 'A* (closure, idempotent)']

    for idx, (M, title) in enumerate(zip(matrices, titles)):
        ax = axes[idx]
        im = ax.imshow(M, cmap='viridis', aspect='equal')
        for i in range(3):
            for j in range(3):
                color = 'white' if M[i,j] > (M.max() + M.min())/2 else 'black'
                ax.text(j, i, f'{M[i,j]:.0f}', ha='center', va='center',
                        fontsize=14, fontweight='bold', color=color)
        ax.set_title(title, fontsize=12, fontweight='bold')
        plt.colorbar(im, ax=ax)

    fig.suptitle('Min-Plus Matrix Powers and Closure', fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()

    fig.savefig('/workspace/request-project/viz_idempotence.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_convergence = viz_convergence()
    print(f"  Convergence: saved to viz_convergence.png ({len(b64_convergence)} chars)")
    b64_minimax = viz_minimax()
    print(f"  Minimax: saved to viz_minimax.png ({len(b64_minimax)} chars)")
    b64_fixed = viz_fixed_points()
    print(f"  Fixed points: saved to viz_fixed_points.png ({len(b64_fixed)} chars)")
    b64_idem = viz_idempotence()
    print(f"  Idempotence: saved to viz_idempotence.png ({len(b64_idem)} chars)")
    print("All visualizations generated.")
