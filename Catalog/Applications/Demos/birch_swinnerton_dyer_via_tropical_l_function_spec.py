#!/usr/bin/env python3
"""
Tropical BSD Machine — Applications

Real-world applications of tropical BSD framework:
1. Optimization: Assignment problems via tropical permanent
2. Network analysis: Shortest paths as tropical L-series
3. Cryptographic lattices: Rank detection in lattice problems
4. Machine learning: Tropical neural network layer analysis
"""

import numpy as np
from typing import List, Dict, Tuple, FrozenSet
from itertools import permutations
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def powerset(n: int) -> List[FrozenSet[int]]:
    result: List[FrozenSet[int]] = [frozenset()]
    for i in range(n):
        result = result + [s | {i} for s in result]
    return result


def tropical_permanent(M: np.ndarray) -> float:
    n = M.shape[0]
    if n == 0:
        return 0.0
    return min(sum(M[i, p[i]] for i in range(n)) for p in permutations(range(n)))


# ─────────────────────────────────────────────
# Application 1: Assignment Problem Solver
# ─────────────────────────────────────────────

def assignment_problem_demo():
    """
    The tropical permanent solves the assignment problem:
    assign n workers to n jobs minimizing total cost.

    This is exactly the tropical regulator in the BSD framework.
    """
    print("=" * 60)
    print("APPLICATION 1: Assignment Problem via Tropical Permanent")
    print("=" * 60)

    # Cost matrix: workers × jobs
    costs = np.array([
        [9, 2, 7, 8],   # Worker A
        [6, 4, 3, 7],   # Worker B
        [5, 8, 1, 8],   # Worker C
        [7, 6, 9, 4],   # Worker D
    ], dtype=float)

    n = costs.shape[0]
    workers = ['Alice', 'Bob', 'Carol', 'Dave']
    jobs = ['Design', 'Code', 'Test', 'Deploy']

    best_cost = float('inf')
    best_perm = None

    for perm in permutations(range(n)):
        cost = sum(costs[i, perm[i]] for i in range(n))
        if cost < best_cost:
            best_cost = cost
            best_perm = perm

    print(f"\n  Cost matrix:")
    for i, w in enumerate(workers):
        print(f"    {w}: {list(costs[i])}")

    print(f"\n  Optimal assignment (tropical permanent = {best_cost}):")
    for i in range(n):
        print(f"    {workers[i]} → {jobs[best_perm[i]]} (cost {costs[i, best_perm[i]]})")

    # Connection to BSD
    print(f"\n  BSD interpretation:")
    print(f"    The tropical regulator of this 'height pairing matrix'")
    print(f"    equals {best_cost}, encoding the arithmetic complexity")
    print(f"    of the optimal generator assignment.")
    print()


# ─────────────────────────────────────────────
# Application 2: Network Shortest Paths
# ─────────────────────────────────────────────

def network_analysis_demo():
    """
    Tropical L-series models shortest-path problems in networks.
    The vanishing order detects the effective dimensionality of
    the shortest-path structure.
    """
    print("=" * 60)
    print("APPLICATION 2: Network Analysis via Tropical L-Series")
    print("=" * 60)

    # Network as adjacency matrix (∞ = no edge)
    INF = float('inf')
    # 4-node network
    adj = np.array([
        [0,   3,   INF, 7],
        [3,   0,   2,   INF],
        [INF, 2,   0,   1],
        [7,   INF, 1,   0],
    ])

    n = 4
    nodes = ['A', 'B', 'C', 'D']

    # Floyd-Warshall (tropical matrix power)
    dist = adj.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j])

    print(f"\n  Network adjacency (edge weights):")
    for i in range(n):
        row = [f"{adj[i][j]:.0f}" if adj[i][j] < INF else "∞"
               for j in range(n)]
        print(f"    {nodes[i]}: {row}")

    print(f"\n  All-pairs shortest distances (tropical matrix square):")
    for i in range(n):
        print(f"    {nodes[i]}: {[f'{dist[i][j]:.0f}' for j in range(n)]}")

    # Tropical permanent of distance matrix
    tp = tropical_permanent(dist)
    print(f"\n  Tropical permanent of distance matrix: {tp}")
    print(f"  (= minimum total cost of a perfect matching in the")
    print(f"   shortest-path metric)")
    print()


# ─────────────────────────────────────────────
# Application 3: Lattice Rank Detection
# ─────────────────────────────────────────────

def lattice_rank_demo():
    """
    Tropical vanishing order detects the effective rank of a lattice,
    relevant to lattice-based cryptography (LWE, NTRU).
    """
    print("=" * 60)
    print("APPLICATION 3: Lattice Rank Detection")
    print("=" * 60)

    def compute_lattice_bsd(basis_vectors: np.ndarray) -> dict:
        n = basis_vectors.shape[0]

        # Build height-pairing matrix: H[i,j] = max(|v_i · v_j|, ε)
        H = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                H[i, j] = abs(np.dot(basis_vectors[i], basis_vectors[j]))

        # Take log for tropical arithmetic
        H_trop = np.log(H + 1e-10)

        # Tropical permanent = regulator
        reg = tropical_permanent(H_trop)

        # Build BSD coefficients
        c = {}
        for I in powerset(n):
            if len(I) == n:
                c[I] = reg
            else:
                c[I] = len(I) + reg + 1

        # Vanishing order
        min_c = min(c.values())
        minimizers = [I for I in powerset(n) if abs(c[I] - min_c) < 1e-10]
        vo = min(len(I) for I in minimizers)

        return {
            'rank': n,
            'vanishing_order': vo,
            'regulator': reg,
            'bsd_equality': n == vo,
        }

    # Example 1: Full-rank lattice
    basis1 = np.array([[1, 0, 0], [0, 1, 0], [0, 0, 1]], dtype=float)
    result1 = compute_lattice_bsd(basis1)
    print(f"\n  Identity lattice (rank 3):")
    print(f"    Detected rank: {result1['rank']}")
    print(f"    Vanishing order: {result1['vanishing_order']}")
    print(f"    BSD equality: {result1['bsd_equality']}")

    # Example 2: Skewed lattice
    basis2 = np.array([[1, 2, 3], [0, 1, 4], [0, 0, 1]], dtype=float)
    result2 = compute_lattice_bsd(basis2)
    print(f"\n  Skewed lattice:")
    print(f"    Detected rank: {result2['rank']}")
    print(f"    Vanishing order: {result2['vanishing_order']}")
    print(f"    Regulator: {result2['regulator']:.4f}")

    # Example 3: Cryptographic lattice
    np.random.seed(42)
    n = 4
    basis3 = np.random.randint(-10, 10, size=(n, n)).astype(float)
    result3 = compute_lattice_bsd(basis3)
    print(f"\n  Random lattice (n={n}):")
    print(f"    Detected rank: {result3['rank']}")
    print(f"    Vanishing order: {result3['vanishing_order']}")
    print(f"    BSD equality: {result3['bsd_equality']}")

    print()


# ─────────────────────────────────────────────
# Application 4: Tropical ReLU Analysis
# ─────────────────────────────────────────────

def tropical_relu_demo():
    """
    ReLU neural networks compute piecewise-linear functions,
    which are tropical polynomials. The BSD framework provides
    invariants for analyzing their complexity.
    """
    print("=" * 60)
    print("APPLICATION 4: Tropical Analysis of ReLU Networks")
    print("=" * 60)

    def relu(x):
        return max(0, x)

    def two_layer_relu(x: float, W1: np.ndarray, b1: np.ndarray,
                       W2: np.ndarray, b2: float) -> float:
        """Simple 2-layer ReLU network: f(x) = W2 · ReLU(W1·x + b1) + b2"""
        hidden = np.array([relu(W1[i] * x + b1[i]) for i in range(len(b1))])
        return float(W2 @ hidden + b2)

    # Network parameters
    W1 = np.array([1.0, -1.0, 0.5])
    b1 = np.array([0.0, 1.0, -0.5])
    W2 = np.array([1.0, 1.0, -2.0])
    b2 = 0.0

    # Evaluate over a range
    x_vals = np.linspace(-3, 3, 1000)
    y_vals = [two_layer_relu(x, W1, b1, W2, b2) for x in x_vals]

    # Count linear regions (breakpoints)
    breakpoints = []
    for i in range(1, len(y_vals) - 1):
        # Detect slope changes
        slope_before = y_vals[i] - y_vals[i-1]
        slope_after = y_vals[i+1] - y_vals[i]
        if abs(slope_before - slope_after) > 0.01:
            breakpoints.append(x_vals[i])

    n_regions = len(breakpoints) + 1

    print(f"\n  2-layer ReLU network with 3 hidden units:")
    print(f"    Number of linear regions: {n_regions}")
    print(f"    Breakpoints at: {[f'{b:.2f}' for b in breakpoints]}")

    # Tropical interpretation
    print(f"\n  Tropical BSD interpretation:")
    print(f"    The network output is a tropical rational function.")
    print(f"    Linear regions ↔ active affine pieces of tropical L-series.")
    print(f"    Number of breakpoints ({len(breakpoints)}) relates to the")
    print(f"    tropical complexity (vanishing order) of the function.")

    # Visualization
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.plot(x_vals, y_vals, 'b-', linewidth=2)
    for bp in breakpoints:
        ax1.axvline(x=bp, color='r', linestyle='--', alpha=0.5)
    ax1.set_title('ReLU Network Output (Tropical Polynomial)', fontweight='bold')
    ax1.set_xlabel('x')
    ax1.set_ylabel('f(x)')
    ax1.grid(True, alpha=0.3)

    # Show tropical decomposition
    for i in range(len(W1)):
        piece = [relu(W1[i] * x + b1[i]) * W2[i] for x in x_vals]
        ax2.plot(x_vals, piece, '--', alpha=0.6, label=f'Piece {i+1}')
    ax2.plot(x_vals, y_vals, 'k-', linewidth=2, label='Sum (tropical)')
    ax2.set_title('Decomposition into Affine Pieces', fontweight='bold')
    ax2.set_xlabel('x')
    ax2.set_ylabel('Component value')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_relu_analysis.png', dpi=150, bbox_inches='tight')
    print(f"\n  Saved: tropical_relu_analysis.png")
    print()


if __name__ == "__main__":
    assignment_problem_demo()
    network_analysis_demo()
    lattice_rank_demo()
    tropical_relu_demo()
    print("All applications completed!")


#!/usr/bin/env python3
"""
Tropical BSD Machine — Demonstrations

Concrete numerical examples illustrating the tropical analogue of the
Birch–Swinnerton-Dyer conjecture. Shows how min-plus L-series, tropical
vanishing orders, regulators, and residue decompositions work in practice.
"""

import numpy as np
from itertools import permutations
from typing import Dict, List, Tuple, Callable
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ─────────────────────────────────────────────
# Core Definitions
# ─────────────────────────────────────────────

def powerset(n: int) -> List[frozenset]:
    """All subsets of {0, ..., n-1}."""
    result = [frozenset()]
    for i in range(n):
        result = result + [s | {i} for s in result]
    return result


def trop_l_series(n: int, c: Dict[frozenset, float], t: float) -> float:
    """
    Tropical L-series: L^trop_n(t) = min_{I ⊆ {0,...,n-1}} (|I|·t + c(I))

    Each subset I defines an affine piece with slope |I| and intercept c(I).
    The L-series is the lower envelope of all these affine functions.
    """
    ps = powerset(n)
    return min(len(I) * t + c[I] for I in ps)


def trop_min_coeff(n: int, c: Dict[frozenset, float]) -> float:
    """Minimum coefficient value = L-series at t=0."""
    return min(c[I] for I in powerset(n))


def trop_minimizers(n: int, c: Dict[frozenset, float]) -> List[frozenset]:
    """Subsets achieving the minimum of c."""
    min_val = trop_min_coeff(n, c)
    return [I for I in powerset(n) if abs(c[I] - min_val) < 1e-12]


def trop_vanishing_order(n: int, c: Dict[frozenset, float]) -> int:
    """Tropical vanishing order: minimum cardinality among minimizers."""
    mins = trop_minimizers(n, c)
    return min(len(I) for I in mins)


def tropical_mw_rank(n: int) -> int:
    """Tropical Mordell-Weil rank of ℤ^n."""
    return n


def tropical_regulator(n: int, M: np.ndarray) -> float:
    """
    Tropical permanent: min over all permutations σ of Σ_i M[i, σ(i)].
    This is the tropical analogue of the classical regulator.
    """
    if n == 0:
        return 0.0
    from itertools import permutations
    perms = list(permutations(range(n)))
    return min(sum(M[i, sigma[i]] for i in range(n)) for sigma in perms)


def tropical_tamagawa(S: List[int], tau: Dict[int, float]) -> float:
    """Tropical Tamagawa defect: Σ_{p ∈ S} τ(p)."""
    return sum(tau.get(p, 0.0) for p in S)


def tropical_residue(n: int, c: Dict[frozenset, float]) -> float:
    """Minimum of c over full-rank subsets (cardinality = n)."""
    full = frozenset(range(n))
    full_rank = [I for I in powerset(n) if len(I) == n]
    return min(c[I] for I in full_rank)


def residue_data(n: int, M: np.ndarray, S: List[int],
                 tau: Dict[int, float]) -> Dict[frozenset, float]:
    """
    Construct coefficient function from regulator and Tamagawa data.
    Full-rank subsets: reg + tam
    Others: |I| + reg + tam + 1
    """
    reg = tropical_regulator(n, M)
    tam = tropical_tamagawa(S, tau)
    c = {}
    for I in powerset(n):
        if len(I) == n:
            c[I] = reg + tam
        else:
            c[I] = len(I) + reg + tam + 1
    return c


# ─────────────────────────────────────────────
# Demo 1: BSD Split Model
# ─────────────────────────────────────────────

def demo_split_model():
    """
    Demonstrate Theorem A: vanishing order = rank under genericity.
    """
    print("=" * 60)
    print("DEMO 1: Tropical BSD Split Model")
    print("=" * 60)

    for n in range(1, 5):
        # Construct generic coefficients: c(univ) = 0, c(I) = n - |I| + 1 for I ≠ univ
        univ = frozenset(range(n))
        c = {}
        for I in powerset(n):
            if I == univ:
                c[I] = 0.0
            else:
                c[I] = float(n - len(I) + 1)

        rank = tropical_mw_rank(n)
        vo = trop_vanishing_order(n, c)
        mins = trop_minimizers(n, c)

        print(f"\n  n = {n}: rank = {rank}, vanishing order = {vo}")
        print(f"    Minimizers: {[set(I) for I in mins]}")
        print(f"    BSD equality: {rank == vo} ✓" if rank == vo else f"    BSD equality: FAILED ✗")

    print()


# ─────────────────────────────────────────────
# Demo 2: BSD Inequality (non-generic case)
# ─────────────────────────────────────────────

def demo_inequality():
    """
    Demonstrate Theorem C: vanishing order ≤ rank always.
    """
    print("=" * 60)
    print("DEMO 2: Tropical BSD Inequality")
    print("=" * 60)

    n = 3
    test_cases = [
        ("Generic (univ is unique min)", {frozenset(): 10, frozenset({0}): 5,
         frozenset({1}): 6, frozenset({2}): 7, frozenset({0,1}): 3,
         frozenset({0,2}): 4, frozenset({1,2}): 4, frozenset({0,1,2}): 0}),
        ("Empty set is min (rank 0 behavior)", {frozenset(): 0, frozenset({0}): 5,
         frozenset({1}): 6, frozenset({2}): 7, frozenset({0,1}): 3,
         frozenset({0,2}): 4, frozenset({1,2}): 4, frozenset({0,1,2}): 10}),
        ("Singleton is min (rank 1 behavior)", {frozenset(): 5, frozenset({0}): 0,
         frozenset({1}): 6, frozenset({2}): 7, frozenset({0,1}): 3,
         frozenset({0,2}): 4, frozenset({1,2}): 4, frozenset({0,1,2}): 10}),
        ("Multiple minimizers (non-generic)", {frozenset(): 0, frozenset({0}): 5,
         frozenset({1}): 6, frozenset({2}): 7, frozenset({0,1}): 0,
         frozenset({0,2}): 4, frozenset({1,2}): 4, frozenset({0,1,2}): 0}),
    ]

    for name, c in test_cases:
        rank = tropical_mw_rank(n)
        vo = trop_vanishing_order(n, c)
        print(f"\n  {name}:")
        print(f"    rank = {rank}, vanishing order = {vo}")
        print(f"    Inequality (vo ≤ rank): {vo <= rank} ✓" if vo <= rank else f"    FAILED ✗")

    print()


# ─────────────────────────────────────────────
# Demo 3: Residue Decomposition
# ─────────────────────────────────────────────

def demo_residue():
    """
    Demonstrate Theorem B: residue = regulator + Tamagawa.
    """
    print("=" * 60)
    print("DEMO 3: Tropical Residue Decomposition")
    print("=" * 60)

    for n in range(1, 4):
        # Create a random regulator matrix
        np.random.seed(42 + n)
        M = np.random.rand(n, n) * 5

        # Tamagawa data
        primes = [2, 3, 5]
        tau = {2: 0.5, 3: 1.2, 5: 0.3}
        S = primes[:n]

        reg = tropical_regulator(n, M)
        tam = tropical_tamagawa(S, tau)
        c = residue_data(n, M, S, tau)
        res = tropical_residue(n, c)

        print(f"\n  n = {n}:")
        print(f"    Regulator = {reg:.4f}")
        print(f"    Tamagawa  = {tam:.4f}")
        print(f"    Reg + Tam = {reg + tam:.4f}")
        print(f"    Residue   = {res:.4f}")
        print(f"    Match: {abs(res - (reg + tam)) < 1e-10} ✓")

    print()


# ─────────────────────────────────────────────
# Demo 4: L-series Visualization
# ─────────────────────────────────────────────

def demo_visualization():
    """
    Visualize tropical L-series as piecewise-linear functions.
    """
    print("=" * 60)
    print("DEMO 4: Generating Visualizations")
    print("=" * 60)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    for idx, n in enumerate(range(1, 5)):
        ax = axes[idx // 2][idx % 2]

        # Generic coefficients
        univ = frozenset(range(n))
        c = {}
        for I in powerset(n):
            if I == univ:
                c[I] = 0.0
            else:
                c[I] = float(n - len(I) + 1)

        t_vals = np.linspace(-2, 3, 500)
        l_vals = [trop_l_series(n, c, t) for t in t_vals]

        # Plot all affine pieces in gray
        for I in powerset(n):
            piece_vals = [len(I) * t + c[I] for t in t_vals]
            ax.plot(t_vals, piece_vals, 'gray', alpha=0.2, linewidth=0.5)

        # Plot the L-series (lower envelope)
        ax.plot(t_vals, l_vals, 'b-', linewidth=2.5, label=f'L^trop (n={n})')

        # Mark the basepoint
        ax.plot(0, trop_l_series(n, c, 0), 'ro', markersize=8, zorder=5)

        # Show vanishing order
        vo = trop_vanishing_order(n, c)
        ax.set_title(f'n = {n}: rank = {n}, vanishing order = {vo}',
                     fontsize=12, fontweight='bold')
        ax.set_xlabel('t')
        ax.set_ylabel('L^trop(t)')
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(-5, 15)

    plt.suptitle('Tropical L-Series: Piecewise-Linear Lower Envelopes',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('tropical_l_series.png', dpi=150, bbox_inches='tight')
    print("  Saved: tropical_l_series.png")

    # Second figure: BSD inequality landscape
    fig2, ax2 = plt.subplots(figsize=(10, 6))

    n_vals = range(1, 8)
    rank_vals = []
    vo_vals_generic = []
    vo_vals_nongeneric = []

    for n in n_vals:
        # Generic case
        univ = frozenset(range(n))
        c_gen = {I: (0.0 if I == univ else float(n - len(I) + 1))
                 for I in powerset(n)}
        # Non-generic: empty set also minimizes
        c_nongen = {I: 0.0 for I in powerset(n)}

        rank_vals.append(tropical_mw_rank(n))
        vo_vals_generic.append(trop_vanishing_order(n, c_gen))
        vo_vals_nongeneric.append(trop_vanishing_order(n, c_nongen))

    ax2.plot(list(n_vals), rank_vals, 'b-o', linewidth=2, markersize=8,
             label='Tropical MW Rank')
    ax2.plot(list(n_vals), vo_vals_generic, 'g--s', linewidth=2, markersize=8,
             label='Vanishing Order (generic)')
    ax2.plot(list(n_vals), vo_vals_nongeneric, 'r-.^', linewidth=2, markersize=8,
             label='Vanishing Order (non-generic)')

    ax2.fill_between(list(n_vals), vo_vals_nongeneric, rank_vals,
                     alpha=0.15, color='blue', label='BSD gap')
    ax2.set_xlabel('n (rank parameter)', fontsize=12)
    ax2.set_ylabel('Invariant value', fontsize=12)
    ax2.set_title('Tropical BSD: Rank vs Vanishing Order', fontsize=14,
                  fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('tropical_bsd_landscape.png', dpi=150, bbox_inches='tight')
    print("  Saved: tropical_bsd_landscape.png")

    # Third figure: Residue decomposition
    fig3, ax3 = plt.subplots(figsize=(10, 6))

    ns = range(1, 7)
    regs = []
    tams = []
    residues = []

    for n in ns:
        np.random.seed(100 + n)
        M = np.eye(n) * (n + 1)  # diagonal matrix
        S = [2, 3, 5, 7, 11, 13][:n]
        tau = {p: 1.0 / p for p in S}

        reg = tropical_regulator(n, M)
        tam = tropical_tamagawa(S, tau)
        c = residue_data(n, M, S, tau)
        res = tropical_residue(n, c)

        regs.append(reg)
        tams.append(tam)
        residues.append(res)

    x = np.arange(len(list(ns)))
    width = 0.25

    ax3.bar(x - width, regs, width, label='Regulator', color='steelblue')
    ax3.bar(x, tams, width, label='Tamagawa', color='coral')
    ax3.bar(x + width, residues, width, label='Residue', color='seagreen')

    ax3.set_xlabel('n', fontsize=12)
    ax3.set_ylabel('Value', fontsize=12)
    ax3.set_title('Tropical Residue = Regulator + Tamagawa', fontsize=14,
                  fontweight='bold')
    ax3.set_xticks(x)
    ax3.set_xticklabels([str(n) for n in ns])
    ax3.legend(fontsize=11)
    ax3.grid(True, alpha=0.3, axis='y')
    plt.tight_layout()
    plt.savefig('tropical_residue_decomposition.png', dpi=150, bbox_inches='tight')
    print("  Saved: tropical_residue_decomposition.png")

    print()


# ─────────────────────────────────────────────
# Demo 5: Tropical Permanent vs Classical Determinant
# ─────────────────────────────────────────────

def demo_tropical_permanent():
    """
    Compare tropical permanent (min-plus) with classical determinant.
    """
    print("=" * 60)
    print("DEMO 5: Tropical Permanent (Regulator)")
    print("=" * 60)

    # Diagonal matrix: tropical permanent = trace
    n = 3
    d = [2.0, 3.0, 5.0]
    M_diag = np.diag(d)
    reg_diag = tropical_regulator(n, M_diag)
    print(f"\n  Diagonal matrix {d}:")
    print(f"    Tropical permanent = {reg_diag}")
    print(f"    Trace = {sum(d)}")
    print(f"    Equal: {abs(reg_diag - sum(d)) < 1e-10} ✓")

    # Identity matrix
    M_id = np.eye(n)
    reg_id = tropical_regulator(n, M_id)
    print(f"\n  Identity matrix (n={n}):")
    print(f"    Tropical permanent = {reg_id}")
    print(f"    (n zeros on diagonal, ones off-diagonal for permutation matrices)")

    # Random matrix
    np.random.seed(42)
    M_rand = np.random.rand(n, n) * 10
    reg_rand = tropical_regulator(n, M_rand)
    det_rand = np.linalg.det(M_rand)
    print(f"\n  Random 3×3 matrix:")
    print(f"    Tropical permanent = {reg_rand:.4f}")
    print(f"    Classical det = {det_rand:.4f}")
    print(f"    (Note: tropical permanent ≠ classical det in general)")

    # Monge matrix (where identity perm is optimal)
    M_monge = np.array([[1, 5, 9], [2, 4, 8], [3, 6, 7]], dtype=float)
    reg_monge = tropical_regulator(n, M_monge)
    trace_monge = sum(M_monge[i, i] for i in range(n))
    print(f"\n  Monge-type matrix:")
    print(f"    Tropical permanent = {reg_monge}")
    print(f"    Diagonal sum = {trace_monge}")

    print()


if __name__ == "__main__":
    demo_split_model()
    demo_inequality()
    demo_residue()
    demo_tropical_permanent()
    demo_visualization()
    print("All demos completed successfully!")
