#!/usr/bin/env python3
"""
Applications of Tropical Cycle-Mean Rigidity

Real-world applications of the theorem:
  AllCycleMeansEqual(A) ⟺ CohomologousToConst(A)

1. Manufacturing/Scheduling: Synchronization detection in production lines
2. Network Analysis: Balanced flow detection in weighted digraphs
3. Music Theory: Voice-leading analysis via tropical eigenvectors
4. Game Theory: Mean-payoff game equilibrium detection
"""

import numpy as np
from algorithms import recover_potential, max_cycle_mean_karp, gauge_transform


def application_scheduling():
    """
    APPLICATION 1: Manufacturing Synchronization
    
    A production system with n machines operating in a cyclic pipeline.
    A[i,j] = processing time when material moves from machine i to machine j.
    
    The tropical eigenvalue gives the optimal throughput (cycle time).
    If AllCycleMeansEqual, then EVERY possible routing has the same
    asymptotic throughput — the system is "perfectly synchronized."
    
    This is a key concept in discrete event systems (Baccelli et al.).
    """
    print("=" * 60)
    print("APPLICATION 1: Manufacturing Synchronization")
    print("=" * 60)
    
    # Synchronized system: A[i,j] = μ + setup[i] - setup[j]
    n = 4
    machines = ["Cutting", "Welding", "Assembly", "Painting"]
    mu = 10.0  # Base processing time
    setup = np.array([2, -1, 3, 0], dtype=float)  # Setup offsets
    
    A = np.array([[mu + setup[i] - setup[j] for j in range(n)] for i in range(n)])
    
    print(f"\nSynchronized Production Line ({n} machines)")
    print(f"Base cycle time μ = {mu}")
    print(f"Setup offsets: {dict(zip(machines, setup))}")
    print(f"\nTransfer time matrix A[i,j]:")
    for i, m in enumerate(machines):
        row = "  ".join(f"{A[i,j]:6.1f}" for j in range(n))
        print(f"  {m:10s}: {row}")
    
    is_coh, rec_mu, rec_p = recover_potential(A)
    print(f"\n✓ System is synchronized: {is_coh}")
    print(f"  Optimal throughput (cycle time) = {rec_mu}")
    print(f"  Every routing strategy achieves the same asymptotic throughput.")
    
    # Now add a bottleneck
    print(f"\n--- After adding a bottleneck (faster Cutting→Welding) ---")
    A_bottleneck = A.copy()
    A_bottleneck[0, 1] += 3  # Faster direct path
    
    is_coh2, _, _ = recover_potential(A_bottleneck)
    mcm = max_cycle_mean_karp(A_bottleneck)
    print(f"  Still synchronized? {is_coh2}")
    print(f"  Max cycle mean (best throughput): {mcm}")
    print(f"  → Some routings are now faster than others!")
    print(f"  → The system has lost perfect synchronization.")


def application_network_balance():
    """
    APPLICATION 2: Balanced Network Flow
    
    In a weighted communication network, edge weights represent
    link capacities or latencies. The tropical eigenvector gives
    the "potential" of each node.
    
    AllCycleMeansEqual means the network is "perfectly balanced" —
    every cycle has the same average capacity/latency.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Balance Detection")
    print("=" * 60)
    
    # Balanced network
    n = 5
    nodes = ["Server A", "Server B", "Server C", "Router 1", "Router 2"]
    mu = 8.0  # Average latency
    potential = np.array([0, 2, -1, 3, 1], dtype=float)
    
    A_balanced = np.array([[mu + potential[i] - potential[j]
                           for j in range(n)] for i in range(n)])
    
    print(f"\nBalanced Network ({n} nodes)")
    is_coh, rec_mu, rec_p = recover_potential(A_balanced)
    print(f"  Network balanced? {is_coh}")
    print(f"  Average latency: {rec_mu}")
    print(f"  Node potentials: {dict(zip(nodes, rec_p))}")
    print(f"  Interpretation: potential differences encode relative node 'depth'")
    
    # Unbalanced network
    A_unbalanced = A_balanced.copy()
    A_unbalanced[0, 2] += 5  # One fast link
    A_unbalanced[2, 4] -= 3  # One slow link
    
    is_coh2, _, _ = recover_potential(A_unbalanced)
    print(f"\n  After modifying two links:")
    print(f"  Network balanced? {is_coh2}")
    print(f"  → Imbalance creates routing arbitrage opportunities")


def application_mean_payoff_game():
    """
    APPLICATION 3: Mean-Payoff Game Analysis
    
    In a two-player mean-payoff game on a weighted graph, the
    optimal long-run average payoff equals the max cycle mean.
    
    When AllCycleMeansEqual, EVERY strategy achieves the same
    long-run average — the game is "degenerate" and both players
    are indifferent between all strategies.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Mean-Payoff Game Equilibrium")
    print("=" * 60)
    
    # Degenerate game: all strategies give same payoff
    n = 3
    mu = 4.0
    p = np.array([1, -1, 0], dtype=float)
    A_degen = np.array([[mu + p[i] - p[j] for j in range(n)] for i in range(n)])
    
    print(f"\nDegenerate Game (payoff matrix):")
    print(A_degen)
    
    is_coh, rec_mu, _ = recover_potential(A_degen)
    print(f"\n  All strategies indifferent? {is_coh}")
    print(f"  Common long-run payoff: {rec_mu}")
    print(f"  → Both players are indifferent between ALL strategies")
    
    # Non-degenerate game
    A_nondegen = np.array([[3, 5, 1], [2, 4, 6], [7, 0, 3]], dtype=float)
    is_coh2, _, _ = recover_potential(A_nondegen)
    mcm = max_cycle_mean_karp(A_nondegen)
    
    print(f"\nNon-degenerate Game:")
    print(A_nondegen)
    print(f"  All strategies indifferent? {is_coh2}")
    print(f"  Optimal payoff (max cycle mean): {mcm:.2f}")
    print(f"  → Strategic choice MATTERS — some cycles are better than others")


def application_music_voice_leading():
    """
    APPLICATION 4: Musical Voice Leading
    
    In computational music theory, voice leading between chords
    can be modeled as tropical optimization. Each voice (soprano,
    alto, tenor, bass) moves by some interval.
    
    The transition cost A[i,j] between pitch classes i and j
    measures the "voice-leading distance." When the system is
    cohomologous, every chord progression has the same total
    "effort" per step — this corresponds to a perfectly smooth
    voice-leading scheme.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Musical Voice Leading")
    print("=" * 60)
    
    # Pitch classes (C, E, G for simplicity)
    n = 3
    notes = ["C", "E", "G"]
    
    # Smooth voice leading: transitions depend only on source and target "tension"
    mu = 2.0  # Base transition cost
    tension = np.array([0, 1.5, -0.5])  # Relative tension of each note
    
    A_smooth = np.array([[mu + tension[i] - tension[j]
                         for j in range(n)] for i in range(n)])
    
    print(f"\nSmooth Voice-Leading Matrix (transition costs):")
    print(f"{'':6s}", end="")
    for j, note in enumerate(notes):
        print(f"  → {note:3s}", end="")
    print()
    for i, note in enumerate(notes):
        print(f"  {note:3s}:", end="")
        for j in range(n):
            print(f"  {A_smooth[i,j]:5.1f}", end="")
        print()
    
    is_coh, rec_mu, rec_p = recover_potential(A_smooth)
    print(f"\n  Perfectly smooth? {is_coh}")
    print(f"  Base transition cost: {rec_mu}")
    print(f"  Note tensions: {dict(zip(notes, rec_p))}")
    print(f"  → Every chord cycle has the same average transition cost!")
    
    # Gauge transformation reveals the structure
    B = gauge_transform(A_smooth, rec_p)
    print(f"\n  Gauge-trivialized matrix (constant = {rec_mu}):")
    print(f"  {B}")


if __name__ == "__main__":
    print("APPLICATIONS OF TROPICAL CYCLE-MEAN RIGIDITY")
    print("=" * 60)
    
    application_scheduling()
    application_network_balance()
    application_mean_payoff_game()
    application_music_voice_leading()
    
    print("\n" + "=" * 60)
    print("CROSS-DOMAIN SYNTHESIS")
    print("=" * 60)
    print("""
All four applications share the same mathematical core:

  AllCycleMeansEqual(A) ⟺ CohomologousToConst(A)

In each domain, the coboundary decomposition A[i,j] = μ + p[i] - p[j]
has a concrete interpretation:

  Manufacturing: p[i] = setup time offset → perfect synchronization
  Networks:      p[i] = node potential → balanced routing
  Games:         p[i] = positional value → strategy indifference  
  Music:         p[i] = tonal tension → smooth voice leading

The theorem provides an O(n²) algorithm to detect these conditions,
replacing the exponential-time brute-force cycle enumeration.
""")


#!/usr/bin/env python3
"""
Tropical Width Collapse and Cycle-Mean Rigidity — Demonstrations

Concrete numerical examples illustrating the main theorem:
    AllCycleMeansEqual(A)  ⟺  CohomologousToConst(A)
"""

import numpy as np

def trop_mat_vec(A, x):
    """Tropical matrix-vector product: (A ⊙ x)_i = max_j (A[i,j] + x[j])."""
    n = A.shape[0]
    return np.array([np.max(A[i] + x) for i in range(n)])

def is_trop_eigenpair(A, lam, x, tol=1e-10):
    """Check if (λ, x) is a tropical eigenpair of A."""
    Ax = trop_mat_vec(A, x)
    return np.allclose(Ax, lam + x, atol=tol)

def vec_width(x):
    """Width of a vector: max - min."""
    return np.max(x) - np.min(x)

def cycle_weight(A, cycle):
    """Weight of a directed cycle given as a list of vertex indices."""
    k = len(cycle)
    return sum(A[cycle[i], cycle[(i+1) % k]] for i in range(k))

def cycle_mean(A, cycle):
    """Mean weight of a directed cycle."""
    return cycle_weight(A, cycle) / len(cycle)

def all_simple_cycles(n, max_len=None):
    """Generate all cycles (lists of vertices) up to given length.
    Includes self-loops (length 1) and cycles with repeated vertices."""
    from itertools import product
    if max_len is None:
        max_len = n + 1
    cycles = []
    for length in range(1, max_len + 1):
        for c in product(range(n), repeat=length):
            cycles.append(list(c))
    return cycles

def check_cohomologous(A, tol=1e-10):
    """Check if A is cohomologous to a constant.
    If A[i,j] = μ + p[i] - p[j], then:
      - μ = A[i,i] for all i (from diagonal)
      - p[i] = A[i,0] - μ
    """
    n = A.shape[0]
    mu = A[0, 0]
    # Check all diagonal entries equal
    for i in range(n):
        if abs(A[i, i] - mu) > tol:
            return False, None, None
    p = A[:, 0] - mu
    # Verify A[i,j] = mu + p[i] - p[j]
    for i in range(n):
        for j in range(n):
            if abs(A[i, j] - (mu + p[i] - p[j])) > tol:
                return False, None, None
    return True, mu, p

def check_all_cycle_means_equal(A, max_cycle_len=4, tol=1e-10):
    """Check if all cycle means are equal (up to given cycle length)."""
    n = A.shape[0]
    cycles = all_simple_cycles(n, max_cycle_len)
    means = [cycle_mean(A, c) for c in cycles]
    if len(means) == 0:
        return True, None
    mu = means[0]
    all_equal = all(abs(m - mu) < tol for m in means)
    return all_equal, mu


def demo_1_cohomologous_matrix():
    """Example 1: A matrix that IS cohomologous to a constant."""
    print("=" * 60)
    print("EXAMPLE 1: Cohomologous Matrix")
    print("=" * 60)
    
    n = 3
    mu = 5.0
    p = np.array([1.0, -2.0, 3.0])
    
    # Build A[i,j] = mu + p[i] - p[j]
    A = np.array([[mu + p[i] - p[j] for j in range(n)] for i in range(n)])
    
    print(f"\nPotential p = {p}")
    print(f"Eigenvalue μ = {mu}")
    print(f"\nMatrix A (where A[i,j] = {mu} + p[i] - p[j]):")
    print(A)
    
    # Check cycle means
    print("\nCycle means:")
    test_cycles = [
        [0], [1], [2],
        [0, 1], [1, 2], [0, 2],
        [0, 1, 2], [2, 1, 0],
        [0, 1, 2, 0, 1],  # longer cycle
    ]
    for c in test_cycles:
        cm = cycle_mean(A, c)
        print(f"  cycle {c}: mean = {cm:.4f}")
    
    # Check eigenpair
    print(f"\nTropical eigenpair check: (μ={mu}, x=p={p})")
    print(f"  Is eigenpair? {is_trop_eigenpair(A, mu, p)}")
    print(f"  Width of eigenvector p: {vec_width(p):.4f}")
    
    # Coboundary check
    is_coh, rec_mu, rec_p = check_cohomologous(A)
    print(f"\nCoboundary decomposition recovered: μ={rec_mu}, p={rec_p}")
    
    # All cycle means equal?
    all_eq, mean_val = check_all_cycle_means_equal(A)
    print(f"All cycle means equal? {all_eq} (μ = {mean_val})")


def demo_2_non_cohomologous_matrix():
    """Example 2: A matrix that is NOT cohomologous to a constant."""
    print("\n" + "=" * 60)
    print("EXAMPLE 2: Non-Cohomologous Matrix")
    print("=" * 60)
    
    A = np.array([
        [1.0, 0.0, 2.0],
        [3.0, 1.0, 0.0],
        [0.0, 4.0, 1.0],
    ])
    
    print(f"\nMatrix A:")
    print(A)
    
    # Check cycle means
    print("\nCycle means (selected):")
    test_cycles = [
        [0], [1], [2],
        [0, 1], [1, 2], [0, 2],
        [0, 1, 2], [2, 1, 0],
    ]
    for c in test_cycles:
        cm = cycle_mean(A, c)
        print(f"  cycle {c}: mean = {cm:.4f}")
    
    is_coh, _, _ = check_cohomologous(A)
    print(f"\nIs cohomologous to constant? {is_coh}")
    
    all_eq, _ = check_all_cycle_means_equal(A)
    print(f"All cycle means equal? {all_eq}")
    print("→ Confirms theorem: NOT cohomologous ⟺ NOT all cycle means equal")


def demo_3_width_analysis():
    """Example 3: Width analysis of eigenvectors."""
    print("\n" + "=" * 60)
    print("EXAMPLE 3: Width Analysis")
    print("=" * 60)
    
    # Case A: Constant matrix — width-0 eigenvector exists
    mu = 3.0
    n = 4
    A_const = np.full((n, n), mu)
    print(f"\nCase A: Constant matrix (all entries = {mu})")
    x_const = np.zeros(n)
    print(f"  Eigenvector: {x_const}")
    print(f"  Is eigenpair? {is_trop_eigenpair(A_const, mu, x_const)}")
    print(f"  Width: {vec_width(x_const)}")
    
    # Case B: Cohomologous but not constant — eigenvector has nonzero width
    p = np.array([0, 1, -1, 2], dtype=float)
    A_coh = np.array([[mu + p[i] - p[j] for j in range(n)] for i in range(n)])
    print(f"\nCase B: Cohomologous with potential p = {p}")
    print(f"  Eigenvector (= potential): {p}")
    print(f"  Is eigenpair? {is_trop_eigenpair(A_coh, mu, p)}")
    print(f"  Width: {vec_width(p)}")
    
    # Check row maxima
    row_max = np.array([np.max(A_coh[i]) for i in range(n)])
    print(f"  Row maxima: {row_max}")
    print(f"  Row maxima equal? {np.allclose(row_max, row_max[0])}")
    
    # Case C: Width-0 eigenvector ↔ equal row maxima
    print(f"\nCase C: Width-zero eigenvector ↔ all row maxima equal")
    A_eq_row = np.array([
        [3, 1, 2],
        [2, 3, 1],
        [1, 2, 3],
    ], dtype=float)
    row_max_c = np.array([np.max(A_eq_row[i]) for i in range(3)])
    print(f"  Matrix:\n{A_eq_row}")
    print(f"  Row maxima: {row_max_c}")
    print(f"  Equal row maxima? {np.allclose(row_max_c, row_max_c[0])}")
    x0 = np.zeros(3)
    print(f"  Constant vector is eigenpair? {is_trop_eigenpair(A_eq_row, 3.0, x0)}")
    
    all_eq, mean_val = check_all_cycle_means_equal(A_eq_row, max_cycle_len=3)
    print(f"  All cycle means equal? {all_eq}")
    print("  → Shows width-0 eigenvector and equal cycle means are DIFFERENT conditions")


def demo_4_gauge_transformation():
    """Example 4: Gauge transformation / coboundary decomposition."""
    print("\n" + "=" * 60)
    print("EXAMPLE 4: Gauge Transformation")
    print("=" * 60)
    
    n = 3
    mu = 2.0
    p = np.array([1.0, 3.0, -1.0])
    
    A = np.array([[mu + p[i] - p[j] for j in range(n)] for i in range(n)])
    
    print(f"Original matrix A (with μ={mu}, p={p}):")
    print(A)
    
    # Gauge transform: B[i,j] = A[i,j] - p[i] + p[j]
    B = np.array([[A[i][j] - p[i] + p[j] for j in range(n)] for i in range(n)])
    print(f"\nGauge-transformed matrix B[i,j] = A[i,j] - p[i] + p[j]:")
    print(B)
    print("→ B is the constant matrix with all entries = μ!")
    
    # Verify inverse
    A_recovered = np.array([[B[i][j] + p[i] - p[j] for j in range(n)] for i in range(n)])
    print(f"\nRecovered A from B + p[i] - p[j]:")
    print(A_recovered)
    print(f"Matches original? {np.allclose(A, A_recovered)}")


if __name__ == "__main__":
    print("TROPICAL WIDTH COLLAPSE AND CYCLE-MEAN RIGIDITY")
    print("Numerical Demonstrations of the Main Theorem")
    print()
    
    demo_1_cohomologous_matrix()
    demo_2_non_cohomologous_matrix()
    demo_3_width_analysis()
    demo_4_gauge_transformation()
    
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
The main theorem proved:
  AllCycleMeansEqual(A) ⟺ CohomologousToConst(A)

Key observations from demos:
1. Coboundary form A[i,j] = μ + p[i] - p[j] forces all cycle means = μ
   (telescoping cancellation).
2. Equal cycle means forces coboundary form (potential from path independence).
3. The potential p IS the tropical eigenvector (eigenvalue = μ).
4. Width-zero eigenvectors exist iff all row maxima are equal
   (separate but related condition).
5. Gauge transformation trivializes the matrix to a constant.
""")


#!/usr/bin/env python3
"""
Visualizations for Tropical Cycle-Mean Rigidity

Generates publication-quality figures illustrating the main theorem.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap
import base64
from io import BytesIO


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', 
                facecolor='white', edgecolor='none')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


def viz_1_coboundary_decomposition():
    """Visualize the coboundary decomposition A[i,j] = μ + p[i] - p[j]."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    n = 4
    mu = 3.0
    p = np.array([1.0, -2.0, 0.5, 3.0])
    
    A = np.array([[mu + p[i] - p[j] for j in range(n)] for i in range(n)])
    B = np.full((n, n), mu)
    
    # Original matrix
    im1 = axes[0].imshow(A, cmap='RdYlBu_r', aspect='equal')
    axes[0].set_title('Original Matrix A', fontsize=14, fontweight='bold')
    axes[0].set_xlabel('Column j')
    axes[0].set_ylabel('Row i')
    for i in range(n):
        for j in range(n):
            axes[0].text(j, i, f'{A[i,j]:.1f}', ha='center', va='center', fontsize=11)
    plt.colorbar(im1, ax=axes[0], shrink=0.8)
    
    # Potential
    axes[1].bar(range(n), p, color=['#e74c3c', '#3498db', '#2ecc71', '#f39c12'],
               edgecolor='black', linewidth=1.5)
    axes[1].set_title('Potential p(i)', fontsize=14, fontweight='bold')
    axes[1].set_xlabel('Vertex i')
    axes[1].set_ylabel('p(i)')
    axes[1].axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    axes[1].set_xticks(range(n))
    for i, v in enumerate(p):
        axes[1].text(i, v + 0.15 * np.sign(v), f'{v:.1f}', ha='center', fontsize=11)
    
    # Gauge-transformed (constant)
    im3 = axes[2].imshow(B, cmap='RdYlBu_r', aspect='equal',
                         vmin=A.min(), vmax=A.max())
    axes[2].set_title(f'Gauge Transform\nB = A − p⊗1 + 1⊗p = {mu}', fontsize=14, fontweight='bold')
    axes[2].set_xlabel('Column j')
    axes[2].set_ylabel('Row i')
    for i in range(n):
        for j in range(n):
            axes[2].text(j, i, f'{B[i,j]:.1f}', ha='center', va='center', fontsize=11)
    plt.colorbar(im3, ax=axes[2], shrink=0.8)
    
    fig.suptitle('Coboundary Decomposition: A[i,j] = μ + p(i) − p(j)', 
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    
    data_uri = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_coboundary.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return data_uri


def viz_2_cycle_means():
    """Compare cycle means for cohomologous vs non-cohomologous matrices."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Cohomologous matrix
    n = 3
    mu = 2.0
    p = np.array([1, -1, 0.5])
    A_coh = np.array([[mu + p[i] - p[j] for j in range(n)] for i in range(n)])
    
    # Non-cohomologous
    A_non = np.array([[1.0, 0.0, 2.0],
                      [3.0, 1.0, 0.0],
                      [0.0, 4.0, 1.0]])
    
    def compute_cycle_means(A, max_len=4):
        from itertools import product
        n = A.shape[0]
        means = []
        labels = []
        for length in range(1, max_len + 1):
            for c in product(range(n), repeat=length):
                w = sum(A[c[i]][c[(i+1) % length]] for i in range(length))
                means.append(w / length)
                labels.append(str(list(c)))
        return means, labels
    
    # Plot cohomologous
    means_coh, labels_coh = compute_cycle_means(A_coh, 3)
    colors_coh = ['#2ecc71' if abs(m - mu) < 1e-10 else '#e74c3c' for m in means_coh]
    axes[0].barh(range(len(means_coh)), means_coh, color=colors_coh, edgecolor='black', linewidth=0.5)
    axes[0].axvline(x=mu, color='red', linestyle='--', linewidth=2, label=f'μ = {mu}')
    axes[0].set_yticks(range(len(means_coh)))
    axes[0].set_yticklabels(labels_coh, fontsize=7)
    axes[0].set_xlabel('Cycle Mean', fontsize=12)
    axes[0].set_title('Cohomologous Matrix\n(All cycle means = μ)', fontsize=14, fontweight='bold')
    axes[0].legend(fontsize=11)
    
    # Plot non-cohomologous
    means_non, labels_non = compute_cycle_means(A_non, 3)
    mean_range = max(means_non) - min(means_non)
    norm_means = [(m - min(means_non)) / mean_range if mean_range > 0 else 0.5 for m in means_non]
    cmap = plt.cm.RdYlBu_r
    colors_non = [cmap(nm) for nm in norm_means]
    axes[1].barh(range(len(means_non)), means_non, color=colors_non, edgecolor='black', linewidth=0.5)
    axes[1].set_yticks(range(len(means_non)))
    axes[1].set_yticklabels(labels_non, fontsize=7)
    axes[1].set_xlabel('Cycle Mean', fontsize=12)
    axes[1].set_title('Non-Cohomologous Matrix\n(Cycle means vary)', fontsize=14, fontweight='bold')
    
    fig.suptitle('Cycle-Mean Rigidity: Equal Means ⟺ Coboundary Form',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    
    data_uri = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_cycle_means.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return data_uri


def viz_3_theorem_diagram():
    """Create a conceptual diagram of the three-way equivalence."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Three boxes
    box_props = dict(boxstyle='round,pad=0.3', facecolor='#ecf0f1', edgecolor='#2c3e50', linewidth=2)
    
    # Top: AllCycleMeansEqual
    ax.text(0, 1.1, 'All Cycle Means\nEqual to μ', fontsize=14, fontweight='bold',
            ha='center', va='center', bbox=dict(boxstyle='round,pad=0.4', 
            facecolor='#3498db', edgecolor='#2c3e50', linewidth=2, alpha=0.8),
            color='white')
    
    # Bottom left: CohomologousToConst
    ax.text(-0.9, -0.5, 'Coboundary Form\nA(i,j) = μ + p(i) − p(j)', fontsize=13, fontweight='bold',
            ha='center', va='center', bbox=dict(boxstyle='round,pad=0.4',
            facecolor='#e74c3c', edgecolor='#2c3e50', linewidth=2, alpha=0.8),
            color='white')
    
    # Bottom right: Eigenvector
    ax.text(0.9, -0.5, 'Tropical Eigenpair\n(μ, p) exists', fontsize=13, fontweight='bold',
            ha='center', va='center', bbox=dict(boxstyle='round,pad=0.4',
            facecolor='#2ecc71', edgecolor='#2c3e50', linewidth=2, alpha=0.8),
            color='white')
    
    # Arrows with labels
    # Top ↔ Bottom-left
    ax.annotate('', xy=(-0.55, -0.15), xytext=(-0.2, 0.75),
                arrowprops=dict(arrowstyle='->', color='#2c3e50', lw=2.5))
    ax.annotate('', xy=(-0.15, 0.8), xytext=(-0.5, -0.1),
                arrowprops=dict(arrowstyle='->', color='#2c3e50', lw=2.5))
    ax.text(-0.65, 0.35, '⟺', fontsize=20, fontweight='bold', color='#2c3e50',
            ha='center', va='center', rotation=55)
    ax.text(-0.15, 0.35, 'Main\nTheorem', fontsize=10, color='#7f8c8d',
            ha='center', va='center', style='italic')
    
    # Bottom-left → Bottom-right
    ax.annotate('', xy=(0.35, -0.5), xytext=(-0.35, -0.5),
                arrowprops=dict(arrowstyle='->', color='#2c3e50', lw=2.5))
    ax.text(0, -0.35, 'implies', fontsize=10, color='#7f8c8d',
            ha='center', va='center', style='italic')
    
    # Title
    ax.text(0, 1.45, 'Tropical Cycle-Mean Rigidity', fontsize=18, fontweight='bold',
            ha='center', va='center', color='#2c3e50')
    
    # Key insight box
    ax.text(0, -1.2, 'Key Insight: Cycle geometry determines algebraic structure.\n'
            'The potential p is both a gauge function AND a tropical eigenvector.',
            fontsize=11, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#ffeaa7', edgecolor='#fdcb6e', linewidth=1.5),
            style='italic')
    
    data_uri = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_theorem_diagram.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return data_uri


def viz_4_width_landscape():
    """Visualize the eigenvector width as a function of matrix perturbation."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    n = 3
    mu = 2.0
    p0 = np.array([1, -1, 0.5])
    A0 = np.array([[mu + p0[i] - p0[j] for j in range(n)] for i in range(n)])
    
    # Perturb A[0,1] by epsilon and measure properties
    epsilons = np.linspace(-3, 3, 200)
    widths = []
    dispersions = []
    
    for eps in epsilons:
        A = A0.copy()
        A[0, 1] += eps
        
        # Try to find potential
        is_coh, rec_mu, rec_p = False, None, None
        mu_test = A[0, 0]
        p_test = A[:, 0] - mu_test
        residual = max(abs(A[i][j] - (mu_test + p_test[i] - p_test[j]))
                      for i in range(n) for j in range(n))
        
        # Width of best eigenvector approximation
        widths.append(residual)
        
        # Cycle mean dispersion (using length 1-3 cycles)
        from itertools import product
        means = []
        for length in range(1, 4):
            for c in product(range(n), repeat=length):
                w = sum(A[c[i]][c[(i+1) % length]] for i in range(length))
                means.append(w / length)
        dispersions.append(max(means) - min(means))
    
    ax.plot(epsilons, widths, color='#e74c3c', linewidth=2.5, label='Coboundary residual')
    ax.plot(epsilons, dispersions, color='#3498db', linewidth=2.5, linestyle='--',
            label='Cycle-mean dispersion')
    ax.axvline(x=0, color='gray', linestyle=':', alpha=0.5)
    ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
    
    ax.fill_between(epsilons, 0, widths, alpha=0.1, color='#e74c3c')
    
    ax.set_xlabel('Perturbation ε (added to A[0,1])', fontsize=13)
    ax.set_ylabel('Deviation from Rigidity', fontsize=13)
    ax.set_title('Phase Transition at Cycle-Mean Rigidity\n'
                 'Perturbation breaks the coboundary structure at ε = 0',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=12, loc='upper left')
    ax.annotate('Rigid point\n(ε = 0)', xy=(0, 0), xytext=(0.8, 1.5),
                fontsize=11, ha='center',
                arrowprops=dict(arrowstyle='->', color='#2c3e50', lw=1.5),
                bbox=dict(boxstyle='round', facecolor='#ffeaa7', alpha=0.8))
    
    ax.set_ylim(bottom=-0.2)
    plt.tight_layout()
    
    data_uri = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_width_landscape.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return data_uri


if __name__ == "__main__":
    print("Generating visualizations...")
    
    uri1 = viz_1_coboundary_decomposition()
    print(f"  ✓ Coboundary decomposition ({len(uri1)} chars)")
    
    uri2 = viz_2_cycle_means()
    print(f"  ✓ Cycle means comparison ({len(uri2)} chars)")
    
    uri3 = viz_3_theorem_diagram()
    print(f"  ✓ Theorem diagram ({len(uri3)} chars)")
    
    uri4 = viz_4_width_landscape()
    print(f"  ✓ Width landscape ({len(uri4)} chars)")
    
    print("\nAll visualizations generated successfully!")
    print("PNG files saved to project root.")
