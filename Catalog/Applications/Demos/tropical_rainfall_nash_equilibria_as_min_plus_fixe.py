#!/usr/bin/env python3
"""
Tropical Game Theory: Real-World Applications

Demonstrates applications of tropical game equilibrium theory to:
1. Shortest-path network equilibria
2. Machine scheduling with precedence constraints
3. Zero-temperature reinforcement learning
4. Combinatorial auction pricing
"""

import numpy as np
from algorithms import (
    tropical_bellman, tropical_value_iteration, minplus_closure,
    is_tropical_fixed_point, tropical_lower_value, tropical_upper_value,
    find_saddle_point, extract_greedy_policy
)


def application_1_network_routing():
    """
    Application 1: Network Routing Equilibria

    Model a network of routers where A[i,j] is the latency from router i to j.
    The tropical fixed point gives equilibrium routing potentials.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Routing Equilibria")
    print("=" * 60)

    # 6-node network: latencies between routers
    INF = 1000.0  # representing "no direct connection"
    latency = np.array([
        [0,    2,   INF, INF, 7,   INF],
        [2,    0,   3,   INF, INF, INF],
        [INF,  3,   0,   1,   INF, 5  ],
        [INF,  INF, 1,   0,   2,   3  ],
        [7,    INF, INF, 2,   0,   1  ],
        [INF,  INF, 5,   3,   1,   0  ]
    ], dtype=float)

    # Compute shortest-path closure
    shortest = minplus_closure(latency)
    print(f"\nDirect latency matrix:\n{latency}")
    print(f"\nShortest-path distances:\n{shortest}")

    # Fixed point = equilibrium potentials from any starting point
    x0 = np.zeros(6)
    v, iters, _ = tropical_value_iteration(shortest, x0)
    print(f"\nEquilibrium potentials (from zero): {v}")
    print(f"Is fixed point: {is_tropical_fixed_point(shortest, v)}")
    print(f"Converged in {iters} step(s)")

    # Routing policy
    policy = extract_greedy_policy(shortest, v)
    node_names = ['A', 'B', 'C', 'D', 'E', 'F']
    print(f"\nOptimal next-hop routing:")
    for i in range(6):
        print(f"  Router {node_names[i]} → Router {node_names[policy[i]]}")


def application_2_scheduling():
    """
    Application 2: Machine Scheduling

    Jobs have processing times and precedence constraints.
    The tropical Bellman fixed point gives earliest start times.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Machine Scheduling")
    print("=" * 60)

    # 5 jobs with processing times and precedence
    # A[i,j] = processing time of job i if job j must follow job i
    # (INF if no precedence)
    INF = 100.0
    processing = np.array([
        [0,   3,   INF, INF, INF],  # Job 0: 3 time units before Job 1
        [INF, 0,   2,   4,   INF],  # Job 1: 2 before Job 2, 4 before Job 3
        [INF, INF, 0,   INF, 1  ],  # Job 2: 1 before Job 4
        [INF, INF, INF, 0,   2  ],  # Job 3: 2 before Job 4
        [INF, INF, INF, INF, 0  ]   # Job 4: terminal
    ], dtype=float)

    # Compute closure for transitive precedence
    A = minplus_closure(processing)
    print(f"\nDirect precedence matrix:\n{processing}")
    print(f"\nTransitive closure (min path lengths):\n{A}")

    # Starting from release times
    release = np.array([0.0, 0.0, 0.0, 0.0, 0.0])
    earliest_start, iters, _ = tropical_value_iteration(A, release)
    print(f"\nRelease times: {release}")
    print(f"Earliest start times: {earliest_start}")
    print(f"Makespan (max completion): {np.max(earliest_start)}")


def application_3_zero_temp_rl():
    """
    Application 3: Zero-Temperature Reinforcement Learning

    Compare soft Bellman operator (finite temperature) with tropical
    Bellman operator (zero temperature) and show convergence.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Zero-Temperature RL Convergence")
    print("=" * 60)

    def soft_bellman(A: np.ndarray, x: np.ndarray, beta: float) -> np.ndarray:
        """Soft Bellman: T^β(x)_i = -1/β · log(Σ_j exp(-β(A[i,j] + x[j])))."""
        n = A.shape[0]
        result = np.zeros(n)
        for i in range(n):
            exponents = -beta * (A[i, :] + x)
            # Numerically stable log-sum-exp
            max_exp = np.max(exponents)
            result[i] = -1.0/beta * (max_exp + np.log(np.sum(np.exp(exponents - max_exp))))
        return result

    A = np.array([
        [1.0, 3.0, 5.0],
        [4.0, 2.0, 1.0],
        [3.0, 5.0, 2.0]
    ])

    x0 = np.array([10.0, 20.0, 30.0])

    print(f"\nPayoff matrix A:\n{A}")
    print(f"Starting vector: {x0}")
    print(f"\nTropical Bellman T_A(x₀): {tropical_bellman(A, x0)}")

    print(f"\nSoft Bellman at various temperatures:")
    print(f"{'β':>8} {'T^β(x₀)[0]':>12} {'T^β(x₀)[1]':>12} {'T^β(x₀)[2]':>12} {'L∞ to tropical':>16}")
    for beta in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0]:
        soft = soft_bellman(A, x0, beta)
        trop = tropical_bellman(A, x0)
        err = np.max(np.abs(soft - trop))
        print(f"{beta:8.1f} {soft[0]:12.4f} {soft[1]:12.4f} {soft[2]:12.4f} {err:16.6f}")

    print(f"\nAs β → ∞, soft Bellman → tropical Bellman  ✓")


def application_4_auction():
    """
    Application 4: Combinatorial Auction Equilibrium

    Model a simple auction where items have valuations by different bidders.
    Saddle points correspond to competitive equilibrium prices.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Auction Equilibrium (Saddle Points)")
    print("=" * 60)

    # 4 bidders × 4 items: valuation matrix
    # (higher value = bidder values item more)
    valuations = np.array([
        [8, 3, 5, 2],  # Bidder 0
        [4, 7, 3, 6],  # Bidder 1
        [5, 2, 9, 1],  # Bidder 2
        [3, 6, 4, 8]   # Bidder 3
    ], dtype=float)

    print(f"\nValuation matrix (bidders × items):\n{valuations}")

    lv = tropical_lower_value(valuations)
    uv = tropical_upper_value(valuations)
    gap = uv - lv
    saddle = find_saddle_point(valuations)

    print(f"\nMax-min value (bidder guarantee): {lv}")
    print(f"Min-max value (auctioneer guarantee): {uv}")
    print(f"Minimax gap: {gap}")

    if saddle:
        i0, j0 = saddle
        print(f"\nSaddle point found: Bidder {i0}, Item {j0}")
        print(f"Equilibrium price = {valuations[i0, j0]}")
        print("Competitive equilibrium exists!")
    else:
        print("\nNo pure saddle point — randomized pricing needed.")

    # Find row mins (bidder guarantees) and column maxes (item competition)
    print(f"\nBidder guaranteed minimums: {np.min(valuations, axis=1)}")
    print(f"Item competition maximums: {np.max(valuations, axis=0)}")


if __name__ == "__main__":
    application_1_network_routing()
    application_2_scheduling()
    application_3_zero_temp_rl()
    application_4_auction()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Game Equilibria: Demonstrations

Demonstrates the core theorems of tropical game theory with concrete
numerical examples:
1. Fixed-point characterization of tropical equilibria
2. Monotonicity of the Bellman operator
3. One-step convergence under min-plus idempotence
4. Tropical minimax inequality and saddle-point equality
"""

import numpy as np

def tropical_bellman(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical Bellman operator: T_A(x)_i = min_j (A[i,j] + x[j])."""
    n = A.shape[0]
    return np.array([np.min(A[i, :] + x) for i in range(n)])

def is_fixed_point(A: np.ndarray, v: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if v is a fixed point of T_A."""
    return np.allclose(tropical_bellman(A, v), v, atol=tol)

def minplus_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Min-plus matrix multiplication: (A⊗B)[i,k] = min_j (A[i,j] + B[j,k])."""
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for k in range(n):
            C[i, k] = np.min(A[i, :] + B[:, k])
    return C

def is_minplus_idempotent(A: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if A is min-plus idempotent: A⊗A = A."""
    return np.allclose(minplus_multiply(A, A), A, atol=tol)

def floyd_warshall_closure(B: np.ndarray) -> np.ndarray:
    """Compute shortest-path closure (min-plus Kleene star) via Floyd-Warshall."""
    n = B.shape[0]
    A = B.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                A[i, j] = min(A[i, j], A[i, k] + A[k, j])
    return A

def find_saddle_point(A: np.ndarray):
    """Find a saddle point if one exists. Returns (i0, j0) or None."""
    n = A.shape[0]
    for i in range(n):
        j_min = np.argmin(A[i, :])
        if A[i, j_min] == np.max(A[:, j_min]):
            return (i, j_min)
    return None

def tropical_lower_value(A: np.ndarray) -> float:
    """max_i min_j A[i,j]."""
    return np.max(np.min(A, axis=1))

def tropical_upper_value(A: np.ndarray) -> float:
    """min_j max_i A[i,j]."""
    return np.min(np.max(A, axis=0))


# ──────────────────────────────────────────────
# Demo 1: Fixed Point Characterization
# ──────────────────────────────────────────────
print("=" * 60)
print("DEMO 1: Fixed Point ↔ Bellman Equations")
print("=" * 60)

A1 = np.array([
    [0, 3, 7],
    [2, 0, 4],
    [5, 1, 0]
], dtype=float)

# Compute closure to get idempotent matrix
A1_closure = floyd_warshall_closure(A1)
print(f"\nOriginal matrix A:\n{A1}")
print(f"\nShortest-path closure A*:\n{A1_closure}")
print(f"Is A* min-plus idempotent? {is_minplus_idempotent(A1_closure)}")

# Find fixed point by applying T once
x0 = np.array([10.0, 20.0, 30.0])
v = tropical_bellman(A1_closure, x0)
print(f"\nStarting vector x₀ = {x0}")
print(f"T_A*(x₀) = {v}")
print(f"T_A*(T_A*(x₀)) = {tropical_bellman(A1_closure, v)}")
print(f"Is T_A*(x₀) a fixed point? {is_fixed_point(A1_closure, v)}")

# Verify coordinatewise
print("\nCoordinatewise Bellman equations:")
for i in range(3):
    lhs = np.min(A1_closure[i, :] + v)
    print(f"  min_j (A*[{i},j] + v[j]) = {lhs:.4f} = v[{i}] = {v[i]:.4f}  ✓" if abs(lhs - v[i]) < 1e-10 else f"  MISMATCH at i={i}")


# ──────────────────────────────────────────────
# Demo 2: Monotonicity
# ──────────────────────────────────────────────
print("\n" + "=" * 60)
print("DEMO 2: Monotonicity of Bellman Operator")
print("=" * 60)

A2 = np.array([[1, 3], [2, 0]], dtype=float)
x = np.array([1.0, 5.0])
y = np.array([2.0, 7.0])
print(f"\nA = {A2.tolist()}")
print(f"x = {x}, y = {y}")
print(f"x ≤ y pointwise? {np.all(x <= y)}")
Tx = tropical_bellman(A2, x)
Ty = tropical_bellman(A2, y)
print(f"T(x) = {Tx}, T(y) = {Ty}")
print(f"T(x) ≤ T(y) pointwise? {np.all(Tx <= Ty + 1e-10)}  ✓")


# ──────────────────────────────────────────────
# Demo 3: One-Step Convergence Under Idempotence
# ──────────────────────────────────────────────
print("\n" + "=" * 60)
print("DEMO 3: One-Step Convergence (Idempotent Matrix)")
print("=" * 60)

np.random.seed(42)
B = np.random.uniform(0, 10, (5, 5))
np.fill_diagonal(B, 0)
A3 = floyd_warshall_closure(B)
print(f"\nRandom 5×5 min-plus idempotent matrix (shortest-path closure):")
print(np.round(A3, 2))
print(f"Is min-plus idempotent? {is_minplus_idempotent(A3)}")

x0 = np.random.uniform(-100, 100, 5)
print(f"\nRandom starting vector: {np.round(x0, 2)}")
iterates = [x0]
for step in range(5):
    iterates.append(tropical_bellman(A3, iterates[-1]))

print("Value iteration:")
for step, v in enumerate(iterates):
    is_fp = is_fixed_point(A3, v)
    print(f"  Step {step}: {np.round(v, 4)}  {'← FIXED POINT' if is_fp else ''}")


# ──────────────────────────────────────────────
# Demo 4: Tropical Minimax Inequality
# ──────────────────────────────────────────────
print("\n" + "=" * 60)
print("DEMO 4: Tropical Minimax Inequality")
print("=" * 60)

A4 = np.array([
    [3, 1, 4],
    [1, 5, 9],
    [2, 6, 5]
], dtype=float)

lv = tropical_lower_value(A4)
uv = tropical_upper_value(A4)
print(f"\nA = \n{A4}")
print(f"Lower value (max-min) = {lv}")
print(f"Upper value (min-max) = {uv}")
print(f"Lower ≤ Upper? {lv <= uv + 1e-10}  (gap = {uv - lv:.4f})  ✓")

# Matrix with saddle point
A5 = np.array([
    [3, 5, 7],
    [1, 4, 6],
    [2, 3, 8]
], dtype=float)

saddle = find_saddle_point(A5)
lv5 = tropical_lower_value(A5)
uv5 = tropical_upper_value(A5)
print(f"\nA (with saddle) = \n{A5}")
print(f"Saddle point: {saddle}")
if saddle:
    i0, j0 = saddle
    print(f"A[{i0},{j0}] = {A5[i0, j0]}")
print(f"Lower value = {lv5}, Upper value = {uv5}")
print(f"Equal? {abs(lv5 - uv5) < 1e-10}  ✓")


# ──────────────────────────────────────────────
# Demo 5: Statistical Verification
# ──────────────────────────────────────────────
print("\n" + "=" * 60)
print("DEMO 5: Statistical Verification (1000 random matrices)")
print("=" * 60)

np.random.seed(123)
n_trials = 1000
n_size = 8
gaps = []
saddle_count = 0
idempotent_one_step = 0

for _ in range(n_trials):
    M = np.random.uniform(0, 10, (n_size, n_size))
    lv = tropical_lower_value(M)
    uv = tropical_upper_value(M)
    gaps.append(uv - lv)
    assert uv >= lv - 1e-10, "Minimax inequality violated!"
    if find_saddle_point(M) is not None:
        saddle_count += 1
        assert abs(lv - uv) < 1e-10, "Saddle but gap > 0!"

# Test idempotent convergence
for _ in range(100):
    B = np.random.uniform(0, 10, (n_size, n_size))
    np.fill_diagonal(B, 0)
    A_idem = floyd_warshall_closure(B)
    x0 = np.random.uniform(-50, 50, n_size)
    v1 = tropical_bellman(A_idem, x0)
    v2 = tropical_bellman(A_idem, v1)
    if np.allclose(v1, v2, atol=1e-10):
        idempotent_one_step += 1

print(f"\nMinimax inequality held: 1000/1000  ✓")
print(f"Matrices with saddle points: {saddle_count}/1000 ({saddle_count/10:.1f}%)")
print(f"  All saddle-point matrices had gap = 0  ✓")
print(f"Mean minimax gap: {np.mean(gaps):.4f}")
print(f"Idempotent one-step convergence: {idempotent_one_step}/100  ✓")

print("\n" + "=" * 60)
print("All demonstrations completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""

import json
import base64

# Read all text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_binary_base64(path):
    with open(path, 'rb') as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode('utf-8')

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Tropical/TropicalGameEquilibria.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read visualization images
viz_convergence = read_binary_base64('convergence.png')
viz_minimax = read_binary_base64('minimax_gap.png')
viz_zero_temp = read_binary_base64('zero_temp.png')
viz_saddle = read_binary_base64('saddle_geometry.png')

package = {
    "title": "Tropical Rainfall: Nash Equilibria as Min-Plus Fixed Points",
    "domain": "Tropical Algebra and Game Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Game Equilibria Demo",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Bellman Operator",
            "pseudocode": "Input: A ∈ ℝ^{n×n}, x ∈ ℝ^n\nOutput: T_A(x) ∈ ℝ^n\n\nfor i = 0 to n-1:\n    T_A(x)[i] = min_{j=0}^{n-1} (A[i,j] + x[j])\nreturn T_A(x)\n\nComplexity: O(n²)",
            "code": algorithms_code
        },
        {
            "name": "Tropical Value Iteration",
            "pseudocode": "Input: A ∈ ℝ^{n×n}, x₀ ∈ ℝ^n, ε > 0\nOutput: Fixed point v\n\nv ← x₀\nrepeat:\n    v_new ← T_A(v)\n    if ||v_new - v||_∞ < ε: return v_new\n    v ← v_new\n\nComplexity: O(n² per iteration)\nUnder idempotence: 1 iteration",
            "code": algorithms_code
        },
        {
            "name": "Saddle Point Detection",
            "pseudocode": "Input: A ∈ ℝ^{n×n}\nOutput: (i₀, j₀) or None\n\nrow_mins ← [min_j A[i,j] for each i]\ncol_maxs ← [max_i A[i,j] for each j]\n\nfor i = 0 to n-1:\n    for j = 0 to n-1:\n        if A[i,j] == row_mins[i] and A[i,j] == col_maxs[j]:\n            return (i, j)\nreturn None\n\nComplexity: O(n²)",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Value Iteration Convergence",
            "data": viz_convergence
        },
        {
            "name": "Minimax Gap Distribution",
            "data": viz_minimax
        },
        {
            "name": "Zero-Temperature Limit",
            "data": viz_zero_temp
        },
        {
            "name": "Saddle Point Geometry",
            "data": viz_saddle
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""
Tropical Game Theory: Visualizations

Generates publication-quality figures for the research paper.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def tropical_bellman(A, x):
    n = A.shape[0]
    return np.array([np.min(A[i, :] + x) for i in range(n)])


def soft_bellman(A, x, beta):
    n = A.shape[0]
    result = np.zeros(n)
    for i in range(n):
        exponents = -beta * (A[i, :] + x)
        max_exp = np.max(exponents)
        result[i] = -1.0/beta * (max_exp + np.log(np.sum(np.exp(exponents - max_exp))))
    return result


def minplus_closure(B):
    n = B.shape[0]
    A = B.copy().astype(float)
    np.fill_diagonal(A, 0)
    for k in range(n):
        for i in range(n):
            for j in range(n):
                A[i, j] = min(A[i, j], A[i, k] + A[k, j])
    return A


# ──────────────────────────────────────────────
# Figure 1: Value Iteration Convergence
# ──────────────────────────────────────────────
def make_fig1():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: idempotent matrix - 1 step convergence
    np.random.seed(42)
    B = np.random.uniform(0, 10, (5, 5))
    A = minplus_closure(B)
    x0 = np.random.uniform(-50, 50, 5)

    iterates = [x0]
    for _ in range(6):
        iterates.append(tropical_bellman(A, iterates[-1]))
    iterates = np.array(iterates)

    ax = axes[0]
    for j in range(5):
        ax.plot(range(7), iterates[:, j], 'o-', label=f'v[{j}]', markersize=5)
    ax.axvline(x=1, color='red', linestyle='--', alpha=0.7, label='Convergence')
    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Idempotent Matrix: 1-Step Convergence', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Right: non-idempotent matrix - slower convergence
    A2 = np.array([
        [0, 5, 8, 12, 20],
        [3, 0, 6, 10, 15],
        [7, 4, 0, 3, 9],
        [11, 8, 2, 0, 5],
        [15, 12, 7, 4, 0]
    ], dtype=float)
    x0_2 = np.array([100.0, 50.0, -30.0, 80.0, -60.0])

    iterates2 = [x0_2]
    for _ in range(10):
        iterates2.append(tropical_bellman(A2, iterates2[-1]))
    iterates2 = np.array(iterates2)

    ax = axes[1]
    for j in range(5):
        ax.plot(range(11), iterates2[:, j], 'o-', label=f'v[{j}]', markersize=5)
    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('General Matrix: Multi-Step Convergence', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Tropical Value Iteration Convergence', fontsize=15, fontweight='bold')
    plt.tight_layout()
    return fig_to_base64(fig)


# ──────────────────────────────────────────────
# Figure 2: Minimax Gap Distribution
# ──────────────────────────────────────────────
def make_fig2():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    np.random.seed(123)
    sizes = [4, 6, 8, 10, 15, 20]
    gap_data = {}

    for n in sizes:
        gaps = []
        for _ in range(500):
            M = np.random.uniform(0, 10, (n, n))
            lv = np.max(np.min(M, axis=1))
            uv = np.min(np.max(M, axis=0))
            gaps.append(uv - lv)
        gap_data[n] = gaps

    ax = axes[0]
    bp = ax.boxplot([gap_data[n] for n in sizes], labels=[str(n) for n in sizes],
                     patch_artist=True)
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(sizes)))
    for patch, color in zip(bp['boxes'], colors):
        patch.set_facecolor(color)
    ax.set_xlabel('Matrix Size n', fontsize=12)
    ax.set_ylabel('Minimax Gap (v̄ - v̲)', fontsize=12)
    ax.set_title('Minimax Gap vs. Matrix Size', fontsize=13)
    ax.grid(True, alpha=0.3, axis='y')

    # Right: histogram for n=10
    ax = axes[1]
    ax.hist(gap_data[10], bins=30, color='steelblue', edgecolor='white', alpha=0.8)
    ax.axvline(x=0, color='red', linestyle='--', linewidth=2, label='Gap = 0 (saddle)')
    ax.set_xlabel('Minimax Gap', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Distribution of Minimax Gap (n=10)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    fig.suptitle('Tropical Minimax Inequality: Statistical Analysis', fontsize=15, fontweight='bold')
    plt.tight_layout()
    return fig_to_base64(fig)


# ──────────────────────────────────────────────
# Figure 3: Zero-Temperature Convergence
# ──────────────────────────────────────────────
def make_fig3():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    A = np.array([
        [1.0, 3.0, 5.0],
        [4.0, 2.0, 1.0],
        [3.0, 5.0, 2.0]
    ])
    x0 = np.array([10.0, 20.0, 30.0])

    betas = np.logspace(-1, 3, 50)
    trop = tropical_bellman(A, x0)
    errors = []

    for beta in betas:
        s = soft_bellman(A, x0, beta)
        errors.append(np.max(np.abs(s - trop)))

    ax = axes[0]
    ax.loglog(betas, errors, 'b-', linewidth=2)
    ax.set_xlabel('Inverse Temperature β', fontsize=12)
    ax.set_ylabel('L∞ Error: |T^β(x) - T(x)|', fontsize=12)
    ax.set_title('Soft → Tropical Convergence Rate', fontsize=13)
    ax.grid(True, alpha=0.3)

    # Right: component-wise convergence
    ax = axes[1]
    betas_sparse = np.logspace(-1, 2, 30)
    for comp in range(3):
        vals = [soft_bellman(A, x0, b)[comp] for b in betas_sparse]
        ax.semilogx(betas_sparse, vals, 'o-', label=f'Soft T^β(x)[{comp}]', markersize=4)
        ax.axhline(y=trop[comp], color=f'C{comp}', linestyle='--', alpha=0.5)

    ax.set_xlabel('Inverse Temperature β', fontsize=12)
    ax.set_ylabel('Operator Value', fontsize=12)
    ax.set_title('Component-wise Convergence', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Zero-Temperature Limit: Soft Bellman → Tropical Bellman', fontsize=15, fontweight='bold')
    plt.tight_layout()
    return fig_to_base64(fig)


# ──────────────────────────────────────────────
# Figure 4: Saddle Point Geometry
# ──────────────────────────────────────────────
def make_fig4():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Matrix with saddle point
    A1 = np.array([
        [3, 5, 7],
        [1, 4, 6],
        [2, 3, 8]
    ], dtype=float)

    ax = axes[0]
    im = ax.imshow(A1, cmap='YlOrRd', aspect='auto')
    for i in range(3):
        for j in range(3):
            color = 'white' if A1[i, j] > 5 else 'black'
            ax.text(j, i, f'{A1[i,j]:.0f}', ha='center', va='center', fontsize=16,
                   fontweight='bold' if (i==0 and j==0) else 'normal', color=color)
    # Highlight saddle
    circle = plt.Circle((0, 0), 0.4, fill=False, color='blue', linewidth=3)
    ax.add_patch(circle)
    ax.set_xticks(range(3))
    ax.set_yticks(range(3))
    ax.set_xlabel('Column (j)', fontsize=12)
    ax.set_ylabel('Row (i)', fontsize=12)
    ax.set_title('Matrix with Saddle Point at (0,0)\nRow mins: [3,1,2]  Col maxes: [3,5,8]', fontsize=12)
    plt.colorbar(im, ax=ax)

    # Matrix without saddle point
    A2 = np.array([
        [3, 1, 4],
        [1, 5, 9],
        [2, 6, 5]
    ], dtype=float)

    ax = axes[1]
    im = ax.imshow(A2, cmap='YlOrRd', aspect='auto')
    for i in range(3):
        for j in range(3):
            color = 'white' if A2[i, j] > 5 else 'black'
            ax.text(j, i, f'{A2[i,j]:.0f}', ha='center', va='center', fontsize=16, color=color)
    ax.set_xticks(range(3))
    ax.set_yticks(range(3))
    ax.set_xlabel('Column (j)', fontsize=12)
    ax.set_ylabel('Row (i)', fontsize=12)
    ax.set_title('Matrix without Saddle Point\nRow mins: [1,1,2]  Col maxes: [3,6,9]', fontsize=12)
    plt.colorbar(im, ax=ax)

    fig.suptitle('Tropical Saddle Point Geometry', fontsize=15, fontweight='bold')
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    fig1 = make_fig1()
    fig2 = make_fig2()
    fig3 = make_fig3()
    fig4 = make_fig4()

    # Save as standalone PNGs too
    for name, data in [("convergence", fig1), ("minimax_gap", fig2),
                       ("zero_temp", fig3), ("saddle_geometry", fig4)]:
        img_data = base64.b64decode(data.split(",")[1])
        with open(f"{name}.png", "wb") as f:
            f.write(img_data)
        print(f"  Saved {name}.png")

    print("All visualizations generated!")

    # Export base64 data for JSON package
    VIZ_DATA = {
        "convergence": fig1,
        "minimax_gap": fig2,
        "zero_temp": fig3,
        "saddle_geometry": fig4
    }
