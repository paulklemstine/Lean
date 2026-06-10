#!/usr/bin/env python3
"""
Applications of Tropical Cycle-Mean Rigidity

Real-world applications of the formally verified rigidity theorems:
1. Discrete Event Systems / Manufacturing Scheduling
2. Network Synchronization / Clock Distribution
3. Mean-Payoff Game Analysis
4. Graph Potential Recovery (Gauge Theory)
"""

import numpy as np
from algorithms import (
    detect_coboundary, classify_matrix, 
    tropical_mat_vec, vec_width, maximum_cycle_mean_karp,
    construct_coboundary_matrix
)


def scheduling_analysis(task_times: np.ndarray, task_names: list = None):
    """
    Discrete Event System Scheduling Analysis.
    
    In max-plus linear systems, a production system with n tasks is modeled by
    a matrix A where A[i,j] = time from completion of task j to availability of task i.
    
    The maximum cycle mean λ* gives the minimum cycle time (throughput = 1/λ*).
    If all cycle means equal λ*, the system is "perfectly balanced" — every
    production path achieves the same throughput. This is the coboundary condition.
    
    Args:
        task_times: n×n matrix of inter-task timing constraints
        task_names: optional names for tasks
    """
    n = task_times.shape[0]
    if task_names is None:
        task_names = [f"Task {i}" for i in range(n)]
    
    print("="*60)
    print("SCHEDULING ANALYSIS: Discrete Event System")
    print("="*60)
    print(f"\nTiming matrix ({n} tasks):")
    for i in range(n):
        print(f"  {task_names[i]:>12s}: {task_times[i]}")
    
    result = classify_matrix(task_times)
    mcm = result.get('max_cycle_mean', 0)
    
    print(f"\nMaximum cycle mean (min cycle time): {mcm:.4f}")
    print(f"Throughput: {1.0/mcm:.4f} units/time" if mcm > 0 else "Throughput: ∞")
    
    if result['is_cohomologous']:
        mu = result['gauge_constant']
        p = result['potential']
        print(f"\n✓ PERFECTLY BALANCED SYSTEM")
        print(f"  All production cycles have mean time = {mu:.4f}")
        print(f"  Gauge potential (optimal phase offsets):")
        for i in range(n):
            print(f"    {task_names[i]}: offset = {p[i]:.4f}")
        print(f"  Interpretation: staggering tasks by these offsets achieves")
        print(f"  uniform throughput across all paths.")
    else:
        print(f"\n✗ UNBALANCED SYSTEM")
        print(f"  Some production cycles are faster than others.")
        print(f"  Bottleneck analysis needed for optimization.")
    
    if result['has_width_zero_eigenvec']:
        print(f"\n✓ Width-zero steady state exists (synchronous operation possible)")
    else:
        print(f"\n✗ No synchronous steady state — tasks cannot be phase-aligned")
    
    return result


def network_synchronization(delays: np.ndarray, node_names: list = None):
    """
    Network Clock Synchronization Analysis.
    
    Models a communication network where delays[i,j] is the propagation
    delay from node j to node i. In the tropical (max-plus) framework,
    the system synchronizes iff the delay matrix is cohomologous to a constant.
    
    The potential p gives the optimal clock offsets: setting clock_i = p_i
    makes all effective delays equal to μ.
    """
    n = delays.shape[0]
    if node_names is None:
        node_names = [f"Node {i}" for i in range(n)]
    
    print("="*60)
    print("NETWORK SYNCHRONIZATION ANALYSIS")
    print("="*60)
    print(f"\nDelay matrix ({n} nodes):")
    for i in range(n):
        print(f"  {node_names[i]:>10s}: {delays[i]}")
    
    result = classify_matrix(delays)
    
    if result['is_cohomologous']:
        mu = result['gauge_constant']
        p = result['potential']
        print(f"\n✓ PERFECT SYNCHRONIZATION POSSIBLE")
        print(f"  Uniform effective delay: {mu:.4f}")
        print(f"  Optimal clock offsets:")
        for i in range(n):
            print(f"    {node_names[i]}: Δt = {p[i]:+.4f}")
        print(f"\n  With these offsets, every round-trip has the same")
        print(f"  average delay regardless of path. This is the discrete")
        print(f"  analogue of a flat connection in gauge theory.")
    else:
        print(f"\n✗ PERFECT SYNCHRONIZATION IMPOSSIBLE")
        print(f"  The delay structure has nonzero 'curvature' —")
        print(f"  no clock offset assignment can equalize all path delays.")
    
    return result


def mean_payoff_game(payoff_matrix: np.ndarray, player_names: list = None):
    """
    Mean-Payoff Game Analysis.
    
    In a mean-payoff game, two players move a token on a weighted directed graph.
    Player Max wants to maximize the long-run average weight; Player Min wants
    to minimize it. The value is the maximum cycle mean.
    
    When all cycle means are equal, the game is "trivial" — every strategy
    achieves the same payoff. This is the tropical rigidity condition.
    """
    n = payoff_matrix.shape[0]
    if player_names is None:
        player_names = [f"State {i}" for i in range(n)]
    
    print("="*60)
    print("MEAN-PAYOFF GAME ANALYSIS")
    print("="*60)
    print(f"\nPayoff matrix ({n} states):")
    for i in range(n):
        print(f"  {player_names[i]:>10s}: {payoff_matrix[i]}")
    
    result = classify_matrix(payoff_matrix)
    mcm = result.get('max_cycle_mean', 0)
    
    print(f"\nGame value (max cycle mean): {mcm:.4f}")
    
    if result['is_cohomologous']:
        mu = result['gauge_constant']
        print(f"\n✓ STRATEGY-INDIFFERENT GAME")
        print(f"  Every recurrent strategy yields payoff {mu:.4f}")
        print(f"  Neither player can gain advantage from strategy choice.")
        print(f"  This is the tropical analogue of a completely mixed equilibrium.")
    else:
        print(f"\n✗ STRATEGY-DEPENDENT GAME")
        print(f"  Different cycles yield different mean payoffs.")
        print(f"  Optimal strategy selection matters.")
    
    return result


def graph_potential_recovery(edge_weights: dict, n: int):
    """
    Graph Potential Recovery (Discrete Gauge Theory).
    
    Given edge weights w(i→j) on a complete directed graph, determine whether
    they can be decomposed as w(i→j) = μ + p(i) - p(j).
    
    This is equivalent to:
    - All cycle sums are proportional to cycle length (with ratio μ)
    - The edge-weight 1-cocycle is exact (zero curvature)
    - A discrete gauge potential exists
    
    Args:
        edge_weights: dict mapping (i,j) to weight
        n: number of vertices
    """
    print("="*60)
    print("GRAPH POTENTIAL RECOVERY (Gauge Theory)")
    print("="*60)
    
    A = np.zeros((n, n))
    for (i, j), w in edge_weights.items():
        A[i, j] = w
    
    result = detect_coboundary(A)
    
    print(f"\nEdge weights on {n}-vertex complete digraph:")
    for (i, j), w in sorted(edge_weights.items()):
        print(f"  {i} → {j}: {w:.4f}")
    
    if result is not None:
        mu, p = result
        print(f"\n✓ FLAT CONNECTION (exact cocycle)")
        print(f"  Gauge constant μ = {mu:.4f}")
        print(f"  Potential function:")
        for i in range(n):
            print(f"    p({i}) = {p[i]:.4f}")
        print(f"\n  Verification: w(i→j) = {mu:.4f} + p(i) - p(j)")
        for (i, j), w in sorted(edge_weights.items()):
            reconstructed = mu + p[i] - p[j]
            print(f"    w({i}→{j}) = {mu:.4f} + {p[i]:.4f} - {p[j]:.4f} = {reconstructed:.4f} {'✓' if abs(w - reconstructed) < 1e-10 else '✗'}")
    else:
        print(f"\n✗ NON-FLAT CONNECTION (nonzero curvature)")
        print(f"  No potential function exists.")
        print(f"  Some cycles have non-proportional weight sums.")
    
    return result


if __name__ == "__main__":
    # Application 1: Manufacturing
    print("\n" + "="*60)
    print("APPLICATION 1: MANUFACTURING SCHEDULING")
    print("="*60 + "\n")
    
    # Perfectly balanced assembly line
    task_times_balanced = construct_coboundary_matrix(
        10.0, np.array([2.0, -1.0, 3.0, 0.0])
    )
    scheduling_analysis(
        task_times_balanced,
        ["Cutting", "Assembly", "Painting", "QC"]
    )
    
    print("\n")
    
    # Unbalanced system
    task_times_unbalanced = np.array([
        [5.0, 3.0, 1.0, 2.0],
        [2.0, 8.0, 4.0, 1.0],
        [6.0, 2.0, 3.0, 7.0],
        [1.0, 5.0, 2.0, 4.0]
    ])
    scheduling_analysis(
        task_times_unbalanced,
        ["Cutting", "Assembly", "Painting", "QC"]
    )
    
    # Application 2: Network Synchronization
    print("\n")
    delays_sync = construct_coboundary_matrix(
        5.0, np.array([0.5, -0.3, 1.2])
    )
    network_synchronization(
        delays_sync,
        ["Server A", "Server B", "Server C"]
    )
    
    print("\n")
    
    delays_async = np.array([
        [1.0, 3.0, 2.0],
        [4.0, 1.0, 5.0],
        [2.0, 1.0, 1.0]
    ])
    network_synchronization(
        delays_async,
        ["Server A", "Server B", "Server C"]
    )
    
    # Application 3: Mean-Payoff Game
    print("\n")
    game_trivial = construct_coboundary_matrix(
        3.0, np.array([1.0, -1.0, 0.0])
    )
    mean_payoff_game(game_trivial, ["Rock", "Paper", "Scissors"])
    
    # Application 4: Graph Potential
    print("\n")
    edges = {
        (0,0): 5.0, (0,1): 6.0, (0,2): 3.0,
        (1,0): 4.0, (1,1): 5.0, (1,2): 2.0,
        (2,0): 7.0, (2,1): 8.0, (2,2): 5.0
    }
    graph_potential_recovery(edges, 3)
    
    print("\n\nAll applications grounded in formally verified mathematics.")


#!/usr/bin/env python3
"""
Tropical Width Collapse and Cycle-Mean Rigidity: Interactive Demonstrations

Demonstrates the formally verified theorems connecting:
- Cycle-mean equality ↔ Coboundary decomposition (gauge trivialization)
- Width-zero eigenvectors ↔ Equal row maxima
- Constant matrices ↔ Both conditions together

All results have been machine-verified in Lean 4 with Mathlib.
"""

import numpy as np
from itertools import permutations

def trop_mat_vec(A, x):
    """Tropical matrix-vector product: (A ⊙ x)_i = max_j (A[i,j] + x[j])"""
    n = A.shape[0]
    result = np.zeros(n)
    for i in range(n):
        result[i] = np.max(A[i, :] + x)
    return result

def vec_width(x):
    """Width of a vector: max - min"""
    return np.max(x) - np.min(x)

def is_trop_eigenpair(A, lam, x, tol=1e-10):
    """Check if (λ, x) is a tropical eigenpair: A ⊙ x = λ + x"""
    Ax = trop_mat_vec(A, x)
    return np.allclose(Ax, lam + x, atol=tol)

def all_cycle_means(A):
    """Compute all cycle means for a matrix A (up to length n)."""
    n = A.shape[0]
    means = {}
    
    # Self-loops (length 1)
    for i in range(n):
        means[f"[{i}]"] = A[i, i]
    
    # Length 2 cycles
    for i in range(n):
        for j in range(n):
            if i != j:
                weight = A[i, j] + A[j, i]
                means[f"[{i},{j}]"] = weight / 2
    
    # Length 3 cycles
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if len({i, j, k}) == 3:
                    weight = A[i, j] + A[j, k] + A[k, i]
                    means[f"[{i},{j},{k}]"] = weight / 3
    
    return means

def check_cohomologous_to_const(A, tol=1e-10):
    """Check if A = μ + p(i) - p(j) for some μ, p. 
    If so, return (μ, p). Otherwise return None."""
    n = A.shape[0]
    # From the proof: set r = 0, μ = any cycle mean, p(i) = A(i, 0) - μ
    mu = A[0, 0]  # Self-loop at 0
    p = A[:, 0] - mu
    
    # Verify
    for i in range(n):
        for j in range(n):
            if abs(A[i, j] - (mu + p[i] - p[j])) > tol:
                return None
    return mu, p

def row_maxima(A):
    """Compute row maxima of A."""
    return np.max(A, axis=1)

def print_separator():
    print("\n" + "="*70 + "\n")

# ============================================================
# DEMO 1: The Cycle-Mean Rigidity Theorem
# ============================================================
print("DEMO 1: Cycle-Mean Rigidity Theorem")
print("AllCycleMeansEqual(A) ↔ CohomologousToConst(A)")
print_separator()

# Example 1a: A cohomologous matrix
print("Example 1a: Cohomologous to constant")
mu = 3.0
p = np.array([1.0, -2.0, 0.5])
n = len(p)
A = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        A[i, j] = mu + p[i] - p[j]

print(f"μ = {mu}, p = {p}")
print(f"A =\n{A}")
print(f"\nCycle means:")
means = all_cycle_means(A)
for cycle, mean in sorted(means.items()):
    print(f"  {cycle}: {mean:.4f}")
print(f"\nAll cycle means equal? {len(set(round(v, 10) for v in means.values())) == 1}")
result = check_cohomologous_to_const(A)
if result:
    print(f"Cohomologous to const: μ={result[0]:.4f}, p={result[1]}")

print_separator()

# Example 1b: Non-cohomologous matrix
print("Example 1b: NOT cohomologous to constant")
B = np.array([[2.0, 1.0], [1.0, 2.0]])
print(f"B =\n{B}")
print(f"\nCycle means:")
means_B = all_cycle_means(B)
for cycle, mean in sorted(means_B.items()):
    print(f"  {cycle}: {mean:.4f}")
print(f"\nAll cycle means equal? {len(set(round(v, 10) for v in means_B.values())) == 1}")
result = check_cohomologous_to_const(B)
print(f"Cohomologous to const? {result is not None}")

# ============================================================
# DEMO 2: Width-Zero Eigenvectors and Row Maxima
# ============================================================
print_separator()
print("DEMO 2: Width-Zero Eigenvectors ↔ Equal Row Maxima")
print_separator()

# Example 2a: Matrix with equal row maxima
print("Example 2a: Equal row maxima → width-zero eigenvector exists")
C = np.array([[5.0, 3.0, 1.0],
              [2.0, 5.0, 4.0],
              [1.0, 3.0, 5.0]])
rm = row_maxima(C)
print(f"C =\n{C}")
print(f"Row maxima: {rm}")
print(f"Equal row maxima? {np.allclose(rm, rm[0])}")
x_zero = np.zeros(3)
eigenval = rm[0]
print(f"x = {x_zero}, width(x) = {vec_width(x_zero)}")
print(f"Is eigenpair with λ={eigenval}? {is_trop_eigenpair(C, eigenval, x_zero)}")

print()

# Example 2b: Matrix with unequal row maxima
print("Example 2b: Unequal row maxima → NO width-zero eigenvector")
D = np.array([[0.0, 1.0], [-1.0, 0.0]])
rm_D = row_maxima(D)
print(f"D =\n{D}")
print(f"Row maxima: {rm_D}")
print(f"Equal row maxima? {np.allclose(rm_D, rm_D[0])}")
print("But all cycle means equal!")
means_D = all_cycle_means(D)
for cycle, mean in sorted(means_D.items()):
    print(f"  {cycle}: {mean:.4f}")

# ============================================================
# DEMO 3: Counterexamples to the False Conjecture
# ============================================================
print_separator()
print("DEMO 3: Counterexamples to 'width-zero eigenvec ↔ all cycle means equal'")
print("This conjecture is FALSE in both directions!")
print_separator()

print("Counterexample (← fails):")
print("A = [[0, 1], [-1, 0]]")
print("All cycle means = 0 (TRUE), but no width-zero eigenvector (row maxima differ)")
A_counter1 = np.array([[0.0, 1.0], [-1.0, 0.0]])
print(f"Row maxima: {row_maxima(A_counter1)}")
print(f"Cycle means: {all_cycle_means(A_counter1)}")
result = check_cohomologous_to_const(A_counter1)
print(f"Cohomologous to const? YES: μ={result[0]}, p={result[1]}")

print()

print("Counterexample (→ fails):")
print("B = [[2, 1], [1, 2]]")
print("Row maxima equal (TRUE, both 2), but cycle means differ (2 vs 1)")
B_counter2 = np.array([[2.0, 1.0], [1.0, 2.0]])
print(f"Row maxima: {row_maxima(B_counter2)}")
print(f"Cycle means: {all_cycle_means(B_counter2)}")
print(f"Cohomologous to const? {check_cohomologous_to_const(B_counter2) is not None}")

# ============================================================
# DEMO 4: Constant Matrix = Both Conditions
# ============================================================
print_separator()
print("DEMO 4: Constant Matrix ↔ Width-Zero Eigenvec + All Cycle Means Equal")
print_separator()

E = np.full((3, 3), 7.0)
print(f"E (constant matrix, all entries 7) =\n{E}")
rm_E = row_maxima(E)
print(f"Row maxima: {rm_E} (all equal)")
means_E = all_cycle_means(E)
print(f"Cycle means: all = {list(set(means_E.values()))}")
x_E = np.zeros(3)
print(f"Width-zero eigenvector: x = {x_E}, eigenvalue = 7")
print(f"Is eigenpair? {is_trop_eigenpair(E, 7.0, x_E)}")

# ============================================================
# DEMO 5: Eigenvector Uniqueness under Coboundary Form
# ============================================================
print_separator()
print("DEMO 5: Eigenvector Uniqueness (Coboundary Form)")
print("Under A(i,j) = μ + p(i) - p(j), all eigenvectors = p + const")
print_separator()

mu5 = 2.0
p5 = np.array([1.0, -1.0, 3.0, 0.0])
n5 = len(p5)
A5 = np.zeros((n5, n5))
for i in range(n5):
    for j in range(n5):
        A5[i, j] = mu5 + p5[i] - p5[j]

print(f"μ = {mu5}, p = {p5}")
print(f"A =\n{A5}")

# p itself is an eigenvector
print(f"\np is eigenvector with eigenvalue {mu5}: {is_trop_eigenpair(A5, mu5, p5)}")

# p + constant is also an eigenvector
for c in [0, 5, -3, 100]:
    x = p5 + c
    print(f"p + {c:4d} = {x}: eigenpair? {is_trop_eigenpair(A5, mu5, x)}")

# Something NOT of the form p + c is NOT an eigenvector
x_bad = np.array([0.0, 0.0, 0.0, 0.0])
print(f"\nConstant vector {x_bad}: eigenpair? {is_trop_eigenpair(A5, mu5, x_bad)}")
print("(Not an eigenvector because p is not constant!)")

print_separator()
print("All demonstrations complete. Every result verified by formal proof in Lean 4.")


#!/usr/bin/env python3
"""
Visualizations for Tropical Cycle-Mean Rigidity

Generates publication-quality figures showing:
1. Coboundary decomposition structure
2. Cycle-mean distribution (flat vs non-flat)
3. Width collapse phase diagram
4. Eigenvector uniqueness
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.patches as mpatches
from itertools import permutations
import base64
import io


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def compute_all_cycle_means(A):
    """Compute all simple cycle means."""
    n = A.shape[0]
    means = []
    labels = []
    
    for i in range(n):
        means.append(A[i, i])
        labels.append(f"[{i}]")
    
    for length in range(2, n + 1):
        for perm in permutations(range(n), length):
            weight = sum(A[perm[i], perm[(i+1) % length]] for i in range(length))
            means.append(weight / length)
            labels.append(str(list(perm)))
    
    return means, labels


def viz_cycle_mean_comparison():
    """
    Figure 1: Cycle-mean distribution for flat vs non-flat matrices.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Flat matrix (cohomologous to const)
    mu, p = 3.0, np.array([1.0, -2.0, 0.5])
    n = len(p)
    A_flat = np.array([[mu + p[i] - p[j] for j in range(n)] for i in range(n)])
    means_flat, labels_flat = compute_all_cycle_means(A_flat)
    
    ax = axes[0]
    ax.barh(range(len(means_flat)), means_flat, color='#2196F3', alpha=0.8, edgecolor='#1565C0')
    ax.axvline(x=mu, color='#F44336', linewidth=2, linestyle='--', label=f'μ = {mu}')
    ax.set_yticks(range(len(labels_flat)))
    ax.set_yticklabels(labels_flat, fontsize=8)
    ax.set_xlabel('Cycle Mean', fontsize=12)
    ax.set_title('Spectrally Flat Matrix\n(All Cycle Means Equal)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(axis='x', alpha=0.3)
    
    # Non-flat matrix
    B = np.array([[2.0, 1.0, 0.0],
                  [0.0, 3.0, 2.0],
                  [1.0, 0.0, 1.0]])
    means_nf, labels_nf = compute_all_cycle_means(B)
    
    ax = axes[1]
    colors = ['#FF9800' if abs(m - np.mean(means_nf)) > 0.3 else '#4CAF50' for m in means_nf]
    ax.barh(range(len(means_nf)), means_nf, color=colors, alpha=0.8, edgecolor='#333')
    ax.axvline(x=max(means_nf), color='#F44336', linewidth=2, linestyle='--', label=f'Max = {max(means_nf):.2f}')
    ax.axvline(x=min(means_nf), color='#9C27B0', linewidth=2, linestyle=':', label=f'Min = {min(means_nf):.2f}')
    ax.set_yticks(range(len(labels_nf)))
    ax.set_yticklabels(labels_nf, fontsize=8)
    ax.set_xlabel('Cycle Mean', fontsize=12)
    ax.set_title('Non-Flat Matrix\n(Cycle Means Vary)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(axis='x', alpha=0.3)
    
    plt.tight_layout()
    return fig


def viz_phase_diagram():
    """
    Figure 2: Phase diagram showing the two independent conditions.
    """
    fig, ax = plt.subplots(figsize=(10, 8))
    
    np.random.seed(42)
    n_samples = 200
    
    points = {'both': [], 'row_only': [], 'cycle_only': [], 'neither': []}
    
    for _ in range(n_samples):
        n = 3
        A = np.random.randn(n, n) * 2
        
        # Check coboundary (= all cycle means equal)
        mu = A[0, 0]
        p = A[:, 0] - mu
        is_cob = all(abs(A[i, j] - (mu + p[i] - p[j])) < 0.01 for i in range(n) for j in range(n))
        
        # Check equal row maxima
        rm = np.max(A, axis=1)
        equal_rm = np.max(rm) - np.min(rm) < 0.01
        
        # Dispersion metric (for x-axis)
        means, _ = compute_all_cycle_means(A)
        dispersion = max(means) - min(means) if means else 0
        
        # Row-max spread (for y-axis)
        rm_spread = np.max(rm) - np.min(rm)
        
        if is_cob and equal_rm:
            points['both'].append((dispersion, rm_spread))
        elif equal_rm:
            points['row_only'].append((dispersion, rm_spread))
        elif is_cob:
            points['cycle_only'].append((dispersion, rm_spread))
        else:
            points['neither'].append((dispersion, rm_spread))
    
    # Also add constructed examples
    for _ in range(30):
        mu_r = np.random.randn() * 2
        p_r = np.random.randn(3) * 1.5
        A_cob = np.array([[mu_r + p_r[i] - p_r[j] for j in range(3)] for i in range(3)])
        rm = np.max(A_cob, axis=1)
        rm_spread = np.max(rm) - np.min(rm)
        if rm_spread < 0.01:
            points['both'].append((0, rm_spread))
        else:
            points['cycle_only'].append((0, rm_spread))
    
    for _ in range(30):
        c = np.random.randn()
        noise = np.random.randn(3, 3) * 0.5
        A_eq_rm = np.array([[c + noise[i, j] for j in range(3)] for i in range(3)])
        # Force equal row maxima
        for i in range(3):
            offset = c + 2 - np.max(A_eq_rm[i])
            A_eq_rm[i, 0] += offset
        rm = np.max(A_eq_rm, axis=1)
        rm_spread = np.max(rm) - np.min(rm)
        means, _ = compute_all_cycle_means(A_eq_rm)
        disp = max(means) - min(means) if means else 0
        if disp < 0.01:
            points['both'].append((disp, rm_spread))
        else:
            points['row_only'].append((disp, rm_spread))
    
    styles = {
        'neither': ('#9E9E9E', 'o', 'Neither condition', 60),
        'row_only': ('#2196F3', 's', 'Equal row maxima only', 80),
        'cycle_only': ('#FF9800', '^', 'Equal cycle means only', 80),
        'both': ('#4CAF50', 'D', 'Both (constant matrix)', 100),
    }
    
    for key, (color, marker, label, size) in styles.items():
        if points[key]:
            xs, ys = zip(*points[key])
            ax.scatter(xs, ys, c=color, marker=marker, s=size, alpha=0.7,
                      edgecolors='black', linewidth=0.5, label=label, zorder=3)
    
    ax.set_xlabel('Cycle-Mean Dispersion (max − min cycle mean)', fontsize=13)
    ax.set_ylabel('Row-Maxima Spread (max − min row max)', fontsize=13)
    ax.set_title('Phase Diagram: Two Independent Rigidity Conditions\n'
                 'Constant matrices live at the origin', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.axvline(x=0, color='black', linewidth=0.5)
    
    # Annotate quadrants
    ax.annotate('Constant\nmatrices', xy=(0, 0), fontsize=10, color='#2E7D32',
               fontweight='bold', ha='center', va='center',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='#C8E6C9', alpha=0.8))
    
    plt.tight_layout()
    return fig


def viz_eigenvector_uniqueness():
    """
    Figure 3: Eigenvector uniqueness under coboundary form.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Coboundary matrix: unique eigenvector class
    mu, p = 2.0, np.array([1.0, -1.5, 0.5, 2.0])
    n = len(p)
    
    ax = axes[0]
    shifts = np.linspace(-3, 3, 7)
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(shifts)))
    
    for c, color in zip(shifts, colors):
        x = p + c
        ax.plot(range(n), x, 'o-', color=color, linewidth=2, markersize=8,
                label=f'p + {c:.1f}', alpha=0.8)
    
    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('x(i)', fontsize=12)
    ax.set_title('Coboundary Form: All Eigenvectors\nare Parallel Shifts of p',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=9, ncol=2)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(range(n))
    
    # Width visualization
    ax = axes[1]
    widths_cob = [vec_width(p) for _ in range(5)]  # All same width
    
    # Non-coboundary: multiple eigenvector classes possible
    B = np.array([[3, 1, 0, 2], [2, 3, 1, 0], [0, 2, 3, 1], [1, 0, 2, 3]], dtype=float)
    
    categories = ['Coboundary\n(unique class)', 'General\n(multiple possible)']
    width_vals = [vec_width(p), 1.5]  # Illustrative
    bar_colors = ['#4CAF50', '#FF9800']
    
    bars = ax.bar(categories, width_vals, color=bar_colors, alpha=0.8,
                  edgecolor='black', linewidth=1.5, width=0.5)
    ax.set_ylabel('Eigenvector Width', fontsize=12)
    ax.set_title('Eigenvector Width Comparison\n'
                 'Coboundary = Single Projective Class',
                 fontsize=13, fontweight='bold')
    ax.grid(axis='y', alpha=0.3)
    
    # Annotate
    ax.annotate(f'width(p) = {vec_width(p):.1f}', xy=(0, vec_width(p)),
               xytext=(0.3, vec_width(p) + 0.3), fontsize=11,
               arrowprops=dict(arrowstyle='->', color='#333'),
               fontweight='bold', color='#2E7D32')
    
    plt.tight_layout()
    return fig


def viz_gauge_potential():
    """
    Figure 4: Gauge potential and coboundary structure.
    """
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # The potential
    p = np.array([2.0, -1.0, 1.5, 0.0, -0.5])
    mu = 3.0
    n = len(p)
    
    ax = axes[0]
    ax.bar(range(n), p, color='#2196F3', alpha=0.8, edgecolor='#1565C0', width=0.6)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('Vertex i', fontsize=12)
    ax.set_ylabel('p(i)', fontsize=12)
    ax.set_title('Gauge Potential p', fontsize=13, fontweight='bold')
    ax.set_xticks(range(n))
    ax.grid(axis='y', alpha=0.3)
    
    # The matrix A = μ + p(i) - p(j)
    A = np.array([[mu + p[i] - p[j] for j in range(n)] for i in range(n)])
    
    ax = axes[1]
    im = ax.imshow(A, cmap='RdYlBu_r', aspect='auto')
    ax.set_xlabel('Column j', fontsize=12)
    ax.set_ylabel('Row i', fontsize=12)
    ax.set_title(f'Matrix A = {mu} + p(i) − p(j)', fontsize=13, fontweight='bold')
    plt.colorbar(im, ax=ax, shrink=0.8)
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    
    # Cycle means
    ax = axes[2]
    means, labels = compute_all_cycle_means(A)
    # Just show a selection
    selected = list(range(min(15, len(means))))
    ax.barh(range(len(selected)), [means[i] for i in selected],
            color='#4CAF50', alpha=0.8, edgecolor='#2E7D32')
    ax.axvline(x=mu, color='#F44336', linewidth=2, linestyle='--', label=f'μ = {mu}')
    ax.set_yticks(range(len(selected)))
    ax.set_yticklabels([labels[i] for i in selected], fontsize=7)
    ax.set_xlabel('Cycle Mean', fontsize=12)
    ax.set_title('All Cycle Means = μ\n(Spectral Flatness)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(axis='x', alpha=0.3)
    
    plt.tight_layout()
    return fig


def vec_width(x):
    return float(np.max(x) - np.min(x))


if __name__ == "__main__":
    print("Generating visualizations...")
    
    fig1 = viz_cycle_mean_comparison()
    fig1.savefig('viz_cycle_means.png', dpi=150, bbox_inches='tight', facecolor='white')
    print("  Saved viz_cycle_means.png")
    
    fig2 = viz_phase_diagram()
    fig2.savefig('viz_phase_diagram.png', dpi=150, bbox_inches='tight', facecolor='white')
    print("  Saved viz_phase_diagram.png")
    
    fig3 = viz_eigenvector_uniqueness()
    fig3.savefig('viz_eigenvector_uniqueness.png', dpi=150, bbox_inches='tight', facecolor='white')
    print("  Saved viz_eigenvector_uniqueness.png")
    
    fig4 = viz_gauge_potential()
    fig4.savefig('viz_gauge_potential.png', dpi=150, bbox_inches='tight', facecolor='white')
    print("  Saved viz_gauge_potential.png")
    
    print("\nAll visualizations generated.")
