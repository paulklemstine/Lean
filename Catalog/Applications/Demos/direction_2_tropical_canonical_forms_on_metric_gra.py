"""
Applications of Canonical Kernel Calculus on Metric Graphs

Demonstrates real-world applications:
  1. Electrical network analysis — effective resistance computation
  2. Tropical Jacobian computation — Abel-Jacobi coordinates
  3. Gaussian free field covariance — statistical mechanics
"""

import numpy as np
from algorithms import (
    MetricGraphModel, cycle_graph, theta_graph, lollipop_graph,
    solve_normalized_kernel, compute_kernel_matrix, compute_energy_pairing,
    prune_pendant_trees
)


def app_electrical_networks():
    """Application 1: Electrical Network Analysis

    The Dirichlet energy form computes effective resistances between
    terminal pairs in an electrical network. Edge conductances are
    1/ℓ(e) where ℓ(e) is the edge length (= resistance).
    """
    print("=" * 70)
    print("APPLICATION 1: Electrical Network — Effective Resistance")
    print("=" * 70)

    # Wheatstone bridge network
    # Vertices: 0 (source), 3 (sink), 1 and 2 (internal)
    edges = [
        (0, 1, 1.0),  # R = 1Ω
        (0, 2, 2.0),  # R = 2Ω
        (1, 3, 3.0),  # R = 3Ω
        (2, 3, 4.0),  # R = 4Ω
        (1, 2, 5.0),  # R = 5Ω (bridge)
    ]
    G = MetricGraphModel(4, edges)

    print(f"\nWheatstone bridge network:")
    print(f"  0 --[1Ω]-- 1 --[3Ω]-- 3")
    print(f"  |          |          |")
    print(f"  [2Ω]      [5Ω]      [4Ω]")
    print(f"  |          |          |")
    print(f"  0 --[2Ω]-- 2 --[4Ω]-- 3")

    # Compute effective resistance between 0 and 3
    S = [0, 1, 2, 3]
    D = np.zeros(4)
    D[0] = 1.0  # Current source at 0
    D[3] = -1.0  # Current sink at 3
    f = solve_normalized_kernel(G, S, D, "mean_zero")

    if f is not None:
        R_eff = G.dirichlet_energy(f)
        print(f"\n  Voltage distribution: {f}")
        print(f"  Effective resistance R(0,3) = {R_eff:.4f} Ω")

    # All pairwise effective resistances
    print(f"\n  Pairwise effective resistances:")
    for i in range(4):
        for j in range(i+1, 4):
            D = np.zeros(4)
            D[i] = 1.0
            D[j] = -1.0
            f = solve_normalized_kernel(G, S, D, "mean_zero")
            if f is not None:
                R = G.dirichlet_energy(f)
                print(f"    R({i},{j}) = {R:.4f} Ω")


def app_tropical_jacobian():
    """Application 2: Tropical Jacobian Computation

    Computes the tropical Jacobian of a metric graph via the
    canonical kernel quotient. The Jacobian is J(Γ) ≅ ℝ^g/Λ
    where g is the genus and Λ is the period lattice.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Tropical Jacobian — Abel-Jacobi Coordinates")
    print("=" * 70)

    # Genus-2 theta graph
    G = theta_graph((1.0, 2.0, 3.0))
    genus = G.first_betti_number()
    print(f"\nTheta graph with path lengths (1, 2, 3)")
    print(f"  Genus: {genus}")

    # Use all vertices as support
    S = list(range(G.n_vertices))
    K = compute_kernel_matrix(G, S)
    Q = compute_energy_pairing(G, S)

    print(f"\n  Kernel matrix (Abel-Jacobi coordinates):")
    print(f"  {np.array2string(K, precision=4)}")

    print(f"\n  Energy pairing (tropical polarization):")
    print(f"  {np.array2string(Q, precision=4)}")

    # Eigendecomposition of Q reveals the Jacobian structure
    eigenvalues, eigenvectors = np.linalg.eigh(Q)
    print(f"\n  Energy eigenvalues: {eigenvalues}")
    print(f"  Non-zero eigenvalues (genus-many): "
          f"{eigenvalues[eigenvalues > 1e-8]}")

    # The tropical Abel-Jacobi map sends a divisor D to its class in J(Γ)
    # via the canonical kernel pairing
    print(f"\n  Abel-Jacobi image of unit divisor δ₁ - δ₀:")
    D = np.zeros(G.n_vertices)
    D[1] = 1.0
    D[0] = -1.0
    f = solve_normalized_kernel(G, S, D, "mean_zero")
    if f is not None:
        print(f"    Potential: {f}")
        print(f"    Energy: {G.dirichlet_energy(f):.4f}")
        print(f"    S-values: {[f[s] for s in S]}")


def app_gaussian_free_field():
    """Application 3: Gaussian Free Field Covariance

    The canonical kernel matrix is the covariance kernel of the
    pinned Gaussian free field on the metric graph. The Dirichlet
    energy form defines the precision matrix.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Gaussian Free Field — Covariance Kernel")
    print("=" * 70)

    # Cycle graph C₆
    G = cycle_graph(6, [1.0, 1.0, 2.0, 2.0, 1.0, 1.0])
    S = list(range(6))

    print(f"\nCycle graph C₆ with edge lengths [1,1,2,2,1,1]")
    print(f"  Total length: {sum([1,1,2,2,1,1])}")

    # The Green's function G(x,y) is the canonical kernel
    K = compute_kernel_matrix(G, S)
    Q = compute_energy_pairing(G, S)

    print(f"\n  Green's function matrix (covariance kernel):")
    print(f"  {np.array2string(K, precision=4)}")

    # Sample from the Gaussian free field
    # The covariance is the pseudoinverse of the Laplacian
    L = G.laplacian
    # Remove constant mode: project onto mean-zero subspace
    n = G.n_vertices
    P = np.eye(n) - np.ones((n, n)) / n  # Projection to mean-zero
    L_proj = P @ L @ P
    # Pseudoinverse as covariance
    eigvals, eigvecs = np.linalg.eigh(L_proj)
    cov = np.zeros((n, n))
    for i in range(n):
        if eigvals[i] > 1e-10:
            cov += np.outer(eigvecs[:, i], eigvecs[:, i]) / eigvals[i]

    print(f"\n  GFF covariance matrix (pseudoinverse of L):")
    print(f"  {np.array2string(cov, precision=4)}")

    # Sample GFF configurations
    np.random.seed(42)
    n_samples = 10000
    samples = np.random.multivariate_normal(np.zeros(n), cov, size=n_samples)
    # Project to mean-zero
    samples -= samples.mean(axis=1, keepdims=True)

    empirical_cov = np.cov(samples.T)
    print(f"\n  Empirical covariance (10000 samples):")
    print(f"  {np.array2string(empirical_cov, precision=4)}")

    # Variance at each vertex
    print(f"\n  Variance at each vertex:")
    for v in range(n):
        print(f"    Var(f({v})) = {empirical_cov[v,v]:.4f} "
              f"(theory: {cov[v,v]:.4f})")


if __name__ == "__main__":
    app_electrical_networks()
    app_tropical_jacobian()
    app_gaussian_free_field()


"""
Interactive Demo: Canonical Kernel Calculus on Metric Graphs

Demonstrates the core theorems and algorithms for computing harmonic
representatives, Jacobian classes, and energy pairings on metric graph models.

Includes:
  1. Cycle graph demo — kernel generators and energy pairing
  2. Theta graph demo — comparing support placements
  3. Pendant-tree pruning demo — leaf rigidity in action
  4. Conjecture tester — resolution-stable kernel convergence
"""

import numpy as np
from algorithms import (
    MetricGraphModel, cycle_graph, theta_graph, lollipop_graph,
    solve_normalized_kernel, compute_kernel_matrix, compute_energy_pairing,
    prune_pendant_trees, subdivide_edge
)


def demo_cycle_graph():
    """Demo 1: Canonical kernels on a cycle graph.

    Illustrates:
    - Kernel generator computation
    - Energy pairing matrix (positive semidefinite)
    - Symmetry of the energy form
    - Connection to effective resistance in electrical networks
    """
    print("=" * 70)
    print("DEMO 1: Cycle Graph C₄ with edge lengths [1, 2, 1, 2]")
    print("=" * 70)

    C4 = cycle_graph(4, [1.0, 2.0, 1.0, 2.0])
    S = [0, 1, 2, 3]

    print(f"\nVertices: {C4.n_vertices}")
    print(f"Support set S = {S}")
    print(f"First Betti number (genus): {C4.first_betti_number()}")

    print("\nMetric Laplacian matrix:")
    print(np.array2string(C4.laplacian, precision=4, suppress_small=True))

    # Verify row-sum-zero (Theorem: mL_row_sum_zero)
    row_sums = C4.laplacian.sum(axis=1)
    print(f"\nRow sums (should be 0): {row_sums}")

    # Verify symmetry (Theorem: mL_symm)
    print(f"Symmetric: {np.allclose(C4.laplacian, C4.laplacian.T)}")

    # Compute kernel matrix
    K = compute_kernel_matrix(C4, S)
    print("\nCanonical kernel matrix K[i,j] = k_i(s_j):")
    print(np.array2string(K, precision=4, suppress_small=True))

    # Compute energy pairing
    Q = compute_energy_pairing(C4, S)
    print("\nEnergy pairing matrix Q (effective resistance form):")
    print(np.array2string(Q, precision=4, suppress_small=True))

    # Verify positive semidefiniteness (Theorem: energy_nonneg)
    eigenvalues = np.linalg.eigvalsh(Q)
    print(f"\nEnergy eigenvalues: {eigenvalues}")
    print(f"All non-negative: {np.all(eigenvalues >= -1e-10)}")

    # Verify symmetry (Theorem: energyForm_symm)
    print(f"Q symmetric: {np.allclose(Q, Q.T)}")

    # Compute effective resistance between vertices 0 and 2
    D = np.zeros(4)
    D[0] = 1.0
    D[2] = -1.0
    f = solve_normalized_kernel(C4, S, D, "mean_zero")
    if f is not None:
        R_eff = C4.dirichlet_energy(f)
        print(f"\nEffective resistance R(0,2) = {R_eff:.4f}")
        print(f"  (parallel combination of paths 0→1→2 and 0→3→2)")
        R_path1 = 1.0 + 2.0  # via vertex 1
        R_path2 = 2.0 + 1.0  # via vertex 3
        R_parallel = 1.0 / (1.0/R_path1 + 1.0/R_path2)
        print(f"  Expected: 1/(1/{R_path1} + 1/{R_path2}) = {R_parallel:.4f}")


def demo_theta_graph():
    """Demo 2: Canonical kernels on a theta graph.

    Illustrates:
    - Genus-2 computation
    - Effect of asymmetric edge lengths
    - Comparing different support placements
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Theta Graph (genus 2)")
    print("=" * 70)

    # Theta graph with three paths of lengths 2, 3, 5
    G = theta_graph((2.0, 3.0, 5.0))
    print(f"\nVertices: {G.n_vertices} (2 poles + 3 midpoints)")
    print(f"First Betti number: {G.first_betti_number()}")

    # Support set 1: poles only
    S1 = [0, 1]
    K1 = compute_kernel_matrix(G, S1)
    Q1 = compute_energy_pairing(G, S1)
    print(f"\nSupport S₁ = {S1} (poles)")
    print(f"Energy pairing: {Q1}")

    # Support set 2: poles + one midpoint
    S2 = [0, 1, 2]
    K2 = compute_kernel_matrix(G, S2)
    Q2 = compute_energy_pairing(G, S2)
    print(f"\nSupport S₂ = {S2} (poles + midpoint)")
    print(f"Energy pairing:\n{np.array2string(Q2, precision=4)}")
    eigs2 = np.linalg.eigvalsh(Q2)
    print(f"Eigenvalues: {eigs2}")

    # Support set 3: all vertices
    S3 = [0, 1, 2, 3, 4]
    K3 = compute_kernel_matrix(G, S3)
    Q3 = compute_energy_pairing(G, S3)
    print(f"\nSupport S₃ = {S3} (all vertices)")
    print(f"Energy pairing:\n{np.array2string(Q3, precision=4)}")
    eigs3 = np.linalg.eigvalsh(Q3)
    print(f"Eigenvalues: {eigs3}")
    print(f"Rank of Q₃: {np.linalg.matrix_rank(Q3, tol=1e-8)}")
    print(f"Expected rank (= genus): {G.first_betti_number()}")


def demo_pendant_pruning():
    """Demo 3: Pendant-tree pruning and leaf rigidity.

    Illustrates:
    - Theorem: metric_leaf_eq_neighbor
    - Harmonic functions are constant on pendant edges
    - Pruning does not change the Jacobian
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Pendant-Tree Pruning (Leaf Rigidity)")
    print("=" * 70)

    # Create a cycle with a pendant stick
    lollipop = lollipop_graph(4.0, 3.0, n_cycle=4)
    print(f"\nLollipop graph: {lollipop.n_vertices} vertices")
    print(f"  Cycle: vertices 0-3, pendant stick: vertex 4")
    print(f"  Stick length: 3.0")

    # Show that leaf vertex 4 has degree 1
    print(f"\n  Vertex 4 degree: {lollipop.degree(4)} (leaf)")
    print(f"  Vertex 4 is leaf: {lollipop.is_leaf(4)}")

    # Solve a harmonic function with source at vertex 1
    S = [1]  # Support on vertex 1
    D = np.zeros(5)
    D[1] = 0.0  # Harmonic everywhere except vertex 1

    # Use a potential that is harmonic at vertices 0, 2, 3, 4
    # with some source at vertex 1
    D_test = np.zeros(5)
    D_test[1] = 1.0
    D_test[3] = -1.0
    f = solve_normalized_kernel(lollipop, [0, 1, 2, 3, 4], D_test, "mean_zero")

    if f is not None:
        print(f"\n  Harmonic potential f (source at 1, sink at 3):")
        for v in range(5):
            label = "leaf" if lollipop.is_leaf(v) else "    "
            Lf_v = float(lollipop.apply_laplacian(f)[v])
            print(f"    f({v}) = {f[v]:+.4f}  Lf({v}) = {Lf_v:+.4f}  {label}")

        # Verify leaf rigidity: f(4) should equal f(0) since Lf(4) = 0
        print(f"\n  Leaf rigidity check:")
        print(f"    f(4) = {f[4]:.6f}")
        print(f"    f(0) = {f[0]:.6f}  (neighbor of leaf 4)")
        print(f"    |f(4) - f(0)| = {abs(f[4] - f[0]):.2e}  (should be ~0)")

    # Prune pendant trees
    core, leaf_map = prune_pendant_trees(lollipop)
    print(f"\n  Core vertices (2-core): {core}")
    print(f"  Pruned leaves: {leaf_map}")

    # Compare energy on full graph vs core-only
    print(f"\n  Attaching longer sticks doesn't change core Jacobian:")
    for stick_len in [1.0, 5.0, 10.0, 100.0]:
        G = lollipop_graph(4.0, stick_len, n_cycle=4)
        S_core = [0, 1, 2, 3]
        Q = compute_energy_pairing(G, S_core)
        eigs = sorted(np.linalg.eigvalsh(Q))
        print(f"    Stick length {stick_len:6.1f}: eigenvalues = "
              f"[{eigs[0]:.4f}, {eigs[1]:.4f}, {eigs[2]:.4f}]")


def demo_conjecture_tester():
    """Demo 4: Conjecture tester — resolution-stable kernel convergence.

    Tests Conjecture A: For any compact metric graph Γ and finite separated
    support S, the canonical kernel matrices K_n computed on uniform subdivisions
    G_n converge entrywise to a limit K_∞ independent of the subdivision scheme.

    Tests Conjecture B: If S meets every cycle of Γ, then the canonical kernel
    quotient realizes the full Jacobian J(Γ).
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Conjecture Tester — Resolution Stability")
    print("=" * 70)

    # --- Conjecture A: Kernel convergence under subdivision ---
    print("\n--- Conjecture A: Kernel Convergence ---")
    print("Testing on C₃ with edge lengths [1, √2 approx, π/2 approx]")

    base_lengths = [1.0, 1.4142, 1.5708]  # Approximations of 1, √2, π/2

    # Track kernel matrix at support vertices under successive subdivisions
    prev_K = None
    for n_subdivisions in [0, 1, 2, 3, 4]:
        # Build subdivided graph
        n = 3 * (2 ** n_subdivisions)
        lengths = []
        for i in range(3):
            sub_len = base_lengths[i] / (2 ** n_subdivisions)
            lengths.extend([sub_len] * (2 ** n_subdivisions))

        G = cycle_graph(n, lengths)

        # Support set: original 3 vertices (at positions 0, 2^n, 2*2^n)
        step = 2 ** n_subdivisions
        S = [0, step, 2 * step]

        K = compute_kernel_matrix(G, S)
        Q = compute_energy_pairing(G, S)

        if prev_K is not None:
            diff = np.max(np.abs(K - prev_K))
            print(f"  Subdivision level {n_subdivisions}: "
                  f"|K - K_prev| = {diff:.2e}, "
                  f"Q eigenvalues = {sorted(np.linalg.eigvalsh(Q))}")
        else:
            print(f"  Subdivision level {n_subdivisions}: "
                  f"K =\n{np.array2string(K, precision=6)}")

        prev_K = K.copy()

    # --- Conjecture B: Core-support sufficiency ---
    print("\n--- Conjecture B: Core-Support Sufficiency ---")
    print("Testing: does S meeting every cycle give full Jacobian rank?")

    # Test on theta graph (genus 2)
    G = theta_graph((2.0, 3.0, 5.0))
    genus = G.first_betti_number()

    # S = poles (meet all 3 cycles)
    S_poles = [0, 1]
    Q_poles = compute_energy_pairing(G, S_poles)
    rank_poles = np.linalg.matrix_rank(Q_poles, tol=1e-8)
    print(f"\n  Theta graph genus = {genus}")
    print(f"  S = poles {S_poles}: rank(Q) = {rank_poles}, expected ≥ {genus}")

    # S = all vertices
    S_all = [0, 1, 2, 3, 4]
    Q_all = compute_energy_pairing(G, S_all)
    rank_all = np.linalg.matrix_rank(Q_all, tol=1e-8)
    print(f"  S = all {S_all}: rank(Q) = {rank_all}, expected = {genus}")

    if rank_poles < genus:
        print(f"\n  ⚠ POTENTIAL COUNTEREXAMPLE: Poles alone give rank {rank_poles} < genus {genus}")
        print(f"  Conjecture B may need additional conditions.")
    else:
        print(f"\n  ✓ Conjecture B holds for this case.")


def demo_refinement_convergence():
    """Test refinement convergence on multiple graph types."""
    print("\n" + "=" * 70)
    print("DEMO 5: Refinement Convergence Across Graph Types")
    print("=" * 70)

    # Test on lollipop (genus 1 + pendant)
    print("\n--- Lollipop graph (genus 1 + pendant tree) ---")
    for n_sub in range(5):
        n = 4 * (2 ** n_sub)
        edge_len = 4.0 / n
        edges = [(i, (i + 1) % n, edge_len) for i in range(n)]
        # Add pendant at vertex 0
        edges.append((0, n, 3.0))
        G = MetricGraphModel(n + 1, edges)

        step = 2 ** n_sub
        S = [0, step, 2 * step, 3 * step]
        Q = compute_energy_pairing(G, S)
        eigs = sorted(np.linalg.eigvalsh(Q))
        print(f"  Level {n_sub} ({n+1} vertices): Q eigenvalues = "
              f"[{eigs[0]:.6f}, {eigs[1]:.6f}, {eigs[2]:.6f}]")


if __name__ == "__main__":
    demo_cycle_graph()
    demo_theta_graph()
    demo_pendant_pruning()
    demo_conjecture_tester()
    demo_refinement_convergence()


"""
Visualization: Energy Landscape and Canonical Kernels on Metric Graphs

Visualizes the Dirichlet energy landscape on a cycle graph and the
canonical kernel generators, illustrating key theorems:
  - Energy non-negativity (energy_nonneg)
  - Constants have zero energy (energy_zero_of_constant)
  - Energy pairing and effective resistance

This script is fully self-contained — all needed functions are inlined.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def build_cycle_laplacian(n, lengths):
    """Build the metric Laplacian for a cycle graph."""
    L = np.zeros((n, n))
    for i in range(n):
        j = (i + 1) % n
        cond = 1.0 / lengths[i]
        L[i, i] += cond
        L[j, j] += cond
        L[i, j] -= cond
        L[j, i] -= cond
    return L


def solve_kernel(L, D):
    """Solve Lf = D with mean-zero normalization."""
    n = L.shape[0]
    A = L.copy()
    b = D.copy()
    A[-1, :] = 1.0
    b[-1] = 0.0
    return np.linalg.solve(A, b)


# --- Setup ---
n = 5
lengths = [1.0, 1.5, 2.0, 1.5, 1.0]
L = build_cycle_laplacian(n, lengths)

fig = plt.figure(figsize=(16, 12))
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

# --- Panel 1: Energy as function of perturbation ---
ax1 = fig.add_subplot(gs[0, 0])
# Start from a kernel generator and perturb
D = np.zeros(n)
D[0] = 1.0
D[2] = -1.0
f0 = solve_kernel(L, D)

# Perturb in random direction (mean-zero)
np.random.seed(42)
direction = np.random.randn(n)
direction -= direction.mean()
direction /= np.linalg.norm(direction)

ts = np.linspace(-2, 2, 200)
energies = []
for t in ts:
    f = f0 + t * direction
    E = f @ L @ f
    energies.append(E)

ax1.plot(ts, energies, 'b-', linewidth=2)
ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax1.axvline(x=0, color='r', linestyle='--', alpha=0.5, label='Canonical kernel')
E0 = f0 @ L @ f0
ax1.plot(0, E0, 'ro', markersize=10, zorder=5, label=f'E(f₀) = {E0:.3f}')
ax1.set_xlabel('Perturbation parameter t', fontsize=12)
ax1.set_ylabel('Dirichlet Energy E(f₀ + t·δ)', fontsize=12)
ax1.set_title('Energy Landscape (Convexity)', fontsize=14)
ax1.legend(fontsize=10)

# --- Panel 2: Kernel generators ---
ax2 = fig.add_subplot(gs[0, 1])
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
x_positions = np.arange(n)

for src in range(1, n):
    D = np.zeros(n)
    D[src] = 1.0
    D[0] = -1.0
    f = solve_kernel(L, D)

    ax2.plot(x_positions, f, 'o-', color=colors[src], linewidth=2,
             markersize=8, label=f'k_{src} (source at {src})')

ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax2.set_xlabel('Vertex', fontsize=12)
ax2.set_ylabel('Potential value', fontsize=12)
ax2.set_title('Canonical Kernel Generators', fontsize=14)
ax2.legend(fontsize=9)
ax2.set_xticks(range(n))

# --- Panel 3: Energy pairing matrix (heatmap) ---
ax3 = fig.add_subplot(gs[1, 0])
S = list(range(n))
k = len(S)
kernels = []
for idx in range(1, k):
    D = np.zeros(n)
    D[S[idx]] = 1.0
    D[S[0]] = -1.0
    f = solve_kernel(L, D)
    kernels.append(f)

Q = np.zeros((k-1, k-1))
for i in range(k-1):
    for j in range(k-1):
        Q[i, j] = kernels[i] @ L @ kernels[j]

im = ax3.imshow(Q, cmap='YlOrRd', aspect='equal')
plt.colorbar(im, ax=ax3)
ax3.set_xticks(range(k-1))
ax3.set_yticks(range(k-1))
ax3.set_xticklabels([f'k_{i+1}' for i in range(k-1)])
ax3.set_yticklabels([f'k_{i+1}' for i in range(k-1)])
ax3.set_title('Energy Pairing Matrix\n(Tropical Polarization)', fontsize=14)

# Annotate values
for i in range(k-1):
    for j in range(k-1):
        ax3.text(j, i, f'{Q[i,j]:.2f}', ha='center', va='center',
                 color='black' if Q[i,j] < Q.max()*0.7 else 'white', fontsize=10)

# --- Panel 4: Refinement convergence ---
ax4 = fig.add_subplot(gs[1, 1])
base_lengths = [1.0, 1.618, 2.236]  # 1, golden ratio, √5

levels = range(6)
eig_traces = [[] for _ in range(2)]

for level in levels:
    m = 3 * (2 ** level)
    sublengths = []
    for i in range(3):
        sub = base_lengths[i] / (2 ** level)
        sublengths.extend([sub] * (2 ** level))

    L_sub = build_cycle_laplacian(m, sublengths)
    step = 2 ** level
    S_sub = [0, step, 2 * step]

    # Compute kernel generators at support vertices
    ks = []
    for idx in range(1, 3):
        D = np.zeros(m)
        D[S_sub[idx]] = 1.0
        D[S_sub[0]] = -1.0
        f = solve_kernel(L_sub, D)
        ks.append(f)

    Q_sub = np.zeros((2, 2))
    for i in range(2):
        for j in range(2):
            Q_sub[i, j] = ks[i] @ L_sub @ ks[j]

    eigs = sorted(np.linalg.eigvalsh(Q_sub))
    for k_idx in range(2):
        eig_traces[k_idx].append(eigs[k_idx])

for k_idx in range(2):
    ax4.plot(list(levels), eig_traces[k_idx], 'o-', linewidth=2,
             markersize=8, label=f'λ_{k_idx+1}')

ax4.set_xlabel('Subdivision level', fontsize=12)
ax4.set_ylabel('Energy eigenvalue', fontsize=12)
ax4.set_title('Refinement Convergence\n(Subdivision Stability)', fontsize=14)
ax4.legend(fontsize=10)

fig.suptitle('Canonical Kernel Calculus on Metric Graphs', fontsize=16, y=0.98)
plt.savefig('viz_energy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_energy_landscape.png")


"""
Visualization: Tropical Jacobian Structure and Abel-Jacobi Coordinates

Illustrates the S-supported Jacobian quotient structure on metric graphs.
Shows how the canonical kernel quotient captures the tropical Jacobian,
and how the energy pairing encodes effective resistances.

This script is fully self-contained.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def build_graph_laplacian(n, edges):
    """Build metric Laplacian from edge list."""
    L = np.zeros((n, n))
    for i, j, length in edges:
        cond = 1.0 / length
        L[i, i] += cond
        L[j, j] += cond
        L[i, j] -= cond
        L[j, i] -= cond
    return L


def solve_kernel(L, D):
    n = L.shape[0]
    A = L.copy()
    b = D.copy()
    A[-1, :] = 1.0
    b[-1] = 0.0
    return np.linalg.solve(A, b)


def theta_graph_laplacian(l1, l2, l3):
    """Theta graph: vertices 0,1 (poles), 2,3,4 (midpoints)."""
    edges = [
        (0, 2, l1/2), (2, 1, l1/2),
        (0, 3, l2/2), (3, 1, l2/2),
        (0, 4, l3/2), (4, 1, l3/2),
    ]
    return build_graph_laplacian(5, edges), 5


fig = plt.figure(figsize=(16, 12))
gs = gridspec.GridSpec(2, 2, hspace=0.4, wspace=0.3)

# --- Panel 1: Abel-Jacobi coordinates on theta graph ---
ax1 = fig.add_subplot(gs[0, 0])

L, n = theta_graph_laplacian(1.0, 2.0, 3.0)
S = list(range(n))
s0 = 0

# Compute kernel generators
kernels = []
for idx in range(1, n):
    D = np.zeros(n)
    D[idx] = 1.0
    D[s0] = -1.0
    kernels.append(solve_kernel(L, D))

# Project onto 2D via first two kernel generators
k1 = kernels[0]
k2 = kernels[1]

# Plot the Abel-Jacobi image of each vertex
aj_x = [k[1] for k in kernels]  # Value at vertex 1
aj_y = [k[2] for k in kernels]  # Value at vertex 2

colors_pts = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
for idx in range(len(kernels)):
    ax1.scatter(aj_x[idx], aj_y[idx], c=colors_pts[idx], s=200,
               edgecolors='black', linewidths=1.5, zorder=5,
               label=f'δ_{idx+1} - δ₀')

ax1.scatter(0, 0, c='gray', s=200, marker='x', linewidths=3, zorder=5,
           label='Origin (δ₀ - δ₀)')
ax1.set_xlabel('k₁ coordinate', fontsize=12)
ax1.set_ylabel('k₂ coordinate', fontsize=12)
ax1.set_title('Abel-Jacobi Coordinates\n(Theta Graph, genus 2)', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)
ax1.set_aspect('equal')

# --- Panel 2: Energy pairing vs edge lengths ---
ax2 = fig.add_subplot(gs[0, 1])

# Vary one edge length and track energy eigenvalues
l3_values = np.linspace(0.5, 10.0, 50)
eig_traces = [[], []]

for l3 in l3_values:
    L_var, n_var = theta_graph_laplacian(1.0, 2.0, l3)
    S_var = list(range(n_var))
    ks = []
    for idx in range(1, n_var):
        D = np.zeros(n_var)
        D[idx] = 1.0
        D[0] = -1.0
        ks.append(solve_kernel(L_var, D))
    Q = np.zeros((n_var-1, n_var-1))
    for i in range(n_var-1):
        for j in range(n_var-1):
            Q[i,j] = ks[i] @ L_var @ ks[j]
    eigs = sorted(np.linalg.eigvalsh(Q))
    for k_idx in range(2):
        eig_traces[k_idx].append(eigs[k_idx])

ax2.plot(l3_values, eig_traces[0], 'b-', linewidth=2, label='λ₁ (smallest)')
ax2.plot(l3_values, eig_traces[1], 'r-', linewidth=2, label='λ₂')
ax2.set_xlabel('Third path length ℓ₃', fontsize=12)
ax2.set_ylabel('Energy eigenvalue', fontsize=12)
ax2.set_title('Energy Spectrum vs Edge Length\n(Theta Graph)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# --- Panel 3: S-Jacobian rank vs support size ---
ax3 = fig.add_subplot(gs[1, 0])

# Compute Jacobian rank for different support sizes on various graphs
# Graph: complete graph K4 with varying edge lengths
K4_edges = [
    (0, 1, 1.0), (0, 2, 1.5), (0, 3, 2.0),
    (1, 2, 1.2), (1, 3, 1.8), (2, 3, 1.4)
]
L_K4 = build_graph_laplacian(4, K4_edges)

# For each support size, compute rank of energy pairing
support_sizes = []
ranks = []
for size in range(2, 5):
    # Use first 'size' vertices as support
    S = list(range(size))
    ks = []
    for idx in range(1, size):
        D = np.zeros(4)
        D[S[idx]] = 1.0
        D[S[0]] = -1.0
        ks.append(solve_kernel(L_K4, D))
    Q = np.zeros((size-1, size-1))
    for i in range(size-1):
        for j in range(size-1):
            Q[i,j] = ks[i] @ L_K4 @ ks[j]
    rank = np.linalg.matrix_rank(Q, tol=1e-8)
    support_sizes.append(size)
    ranks.append(rank)

# Also compute genus
n_edges_K4 = 6
genus_K4 = n_edges_K4 - 4 + 1
ax3.bar(support_sizes, ranks, color='steelblue', edgecolor='black', alpha=0.8)
ax3.axhline(y=genus_K4, color='red', linestyle='--', linewidth=2,
            label=f'Genus = {genus_K4}')
ax3.set_xlabel('Support size |S|', fontsize=12)
ax3.set_ylabel('Rank of Q (Jacobian dimension)', fontsize=12)
ax3.set_title('S-Jacobian Rank vs Support Size\n(K₄ graph)', fontsize=13)
ax3.legend(fontsize=10)
ax3.set_xticks(support_sizes)

# --- Panel 4: Effective resistance network visualization ---
ax4 = fig.add_subplot(gs[1, 1])

# Compute all pairwise effective resistances on K4
R_eff = np.zeros((4, 4))
for i in range(4):
    for j in range(i+1, 4):
        D = np.zeros(4)
        D[i] = 1.0
        D[j] = -1.0
        f = solve_kernel(L_K4, D)
        R_eff[i,j] = f @ L_K4 @ f
        R_eff[j,i] = R_eff[i,j]

im = ax4.imshow(R_eff, cmap='YlOrRd', aspect='equal')
plt.colorbar(im, ax=ax4, label='Effective resistance (Ω)')
ax4.set_xticks(range(4))
ax4.set_yticks(range(4))
ax4.set_xlabel('Vertex j', fontsize=12)
ax4.set_ylabel('Vertex i', fontsize=12)
ax4.set_title('Effective Resistance Matrix\n(K₄ with heterogeneous edges)', fontsize=13)

for i in range(4):
    for j in range(4):
        ax4.text(j, i, f'{R_eff[i,j]:.2f}', ha='center', va='center',
                fontsize=10, color='black' if R_eff[i,j] < R_eff.max()*0.6 else 'white')

fig.suptitle('Tropical Jacobian Structure and Energy Pairings', fontsize=15, y=0.98)
plt.savefig('viz_jacobian_structure.png', dpi=150, bbox_inches='tight')
print("Saved viz_jacobian_structure.png")


"""
Visualization: Leaf Rigidity and Pendant-Tree Pruning

Illustrates the metric leaf rigidity theorem: harmonic functions on pendant
edges must be constant. Shows how attaching longer pendant trees does not
change the canonical kernel data on the cycle core.

This script is fully self-contained.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def build_lollipop_laplacian(n_cycle, cycle_len, stick_len):
    """Build Laplacian for a lollipop graph (cycle + pendant stick)."""
    n = n_cycle + 1
    L = np.zeros((n, n))
    edge_len = cycle_len / n_cycle
    # Cycle edges
    for i in range(n_cycle):
        j = (i + 1) % n_cycle
        cond = 1.0 / edge_len
        L[i, i] += cond
        L[j, j] += cond
        L[i, j] -= cond
        L[j, i] -= cond
    # Pendant stick: vertex n_cycle attached to vertex 0
    cond_stick = 1.0 / stick_len
    L[0, 0] += cond_stick
    L[n_cycle, n_cycle] += cond_stick
    L[0, n_cycle] -= cond_stick
    L[n_cycle, 0] -= cond_stick
    return L, n


def build_tree_laplacian(n_cycle, cycle_len, tree_lengths):
    """Build Laplacian for cycle + multi-node pendant tree."""
    n_tree = len(tree_lengths)
    n = n_cycle + n_tree
    L = np.zeros((n, n))
    edge_len = cycle_len / n_cycle
    for i in range(n_cycle):
        j = (i + 1) % n_cycle
        cond = 1.0 / edge_len
        L[i, i] += cond
        L[j, j] += cond
        L[i, j] -= cond
        L[j, i] -= cond
    # Tree: chain from vertex 0 through n_cycle, n_cycle+1, ...
    prev = 0
    for k, tl in enumerate(tree_lengths):
        cur = n_cycle + k
        cond = 1.0 / tl
        L[prev, prev] += cond
        L[cur, cur] += cond
        L[prev, cur] -= cond
        L[cur, prev] -= cond
        prev = cur
    return L, n


def solve_kernel(L, D):
    n = L.shape[0]
    A = L.copy()
    b = D.copy()
    A[-1, :] = 1.0
    b[-1] = 0.0
    return np.linalg.solve(A, b)


fig = plt.figure(figsize=(16, 10))
gs = gridspec.GridSpec(2, 2, hspace=0.4, wspace=0.3)

# --- Panel 1: Harmonic function on lollipop (showing leaf constancy) ---
ax1 = fig.add_subplot(gs[0, 0])

n_cycle = 6
cycle_len = 6.0
stick_len = 3.0
L, n = build_lollipop_laplacian(n_cycle, cycle_len, stick_len)

# Source at vertex 1, sink at vertex 4
D = np.zeros(n)
D[1] = 1.0
D[4] = -1.0
f = solve_kernel(L, D)

# Plot vertex positions on a circle + stick
angles = np.linspace(0, 2*np.pi, n_cycle, endpoint=False)
x_pos = np.cos(angles)
y_pos = np.sin(angles)
# Stick extends from vertex 0
x_pos = np.append(x_pos, x_pos[0] + 0.5)
y_pos = np.append(y_pos, y_pos[0] + 0.5)

scatter = ax1.scatter(x_pos, y_pos, c=f, cmap='RdBu_r', s=200,
                       edgecolors='black', linewidths=1.5, zorder=5,
                       vmin=-max(abs(f)), vmax=max(abs(f)))
plt.colorbar(scatter, ax=ax1, label='Potential f(v)')

# Draw edges
for i in range(n_cycle):
    j = (i + 1) % n_cycle
    ax1.plot([x_pos[i], x_pos[j]], [y_pos[i], y_pos[j]], 'k-', linewidth=1)
ax1.plot([x_pos[0], x_pos[n_cycle]], [y_pos[0], y_pos[n_cycle]], 'k--', linewidth=2)

# Label vertices
for i in range(n):
    label = f'{i}' + (' (leaf)' if i == n_cycle else '')
    ax1.annotate(label, (x_pos[i], y_pos[i]), textcoords="offset points",
                xytext=(10, 5), fontsize=9)

# Highlight leaf rigidity
ax1.annotate(f'f({n_cycle}) = {f[n_cycle]:.4f}\nf(0) = {f[0]:.4f}\n→ Equal!',
            xy=(x_pos[n_cycle], y_pos[n_cycle]),
            xytext=(x_pos[n_cycle]+0.3, y_pos[n_cycle]+0.5),
            fontsize=10, color='red',
            arrowprops=dict(arrowstyle='->', color='red'))

ax1.set_title('Leaf Rigidity: f(leaf) = f(neighbor)', fontsize=13)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)

# --- Panel 2: Potential profile showing constancy on pendant ---
ax2 = fig.add_subplot(gs[0, 1])

# Build a longer tree: cycle + chain of 5 pendant vertices
tree_lengths = [1.0, 1.0, 1.0, 1.0, 1.0]
L_tree, n_tree = build_tree_laplacian(n_cycle, cycle_len, tree_lengths)
D_tree = np.zeros(n_tree)
D_tree[1] = 1.0
D_tree[4] = -1.0
f_tree = solve_kernel(L_tree, D_tree)

# Plot the potential along the tree path
tree_path = list(range(n_cycle)) + list(range(n_cycle, n_tree))
labels = [f'cycle {i}' for i in range(n_cycle)] + [f'tree {i-n_cycle}' for i in range(n_cycle, n_tree)]

ax2.bar(range(n_tree), f_tree, color=['steelblue']*n_cycle + ['coral']*len(tree_lengths),
        edgecolor='black', linewidth=0.5)
ax2.axhline(y=f_tree[0], color='red', linestyle='--', alpha=0.7,
            label=f'f(attachment) = {f_tree[0]:.4f}')
ax2.set_xticks(range(n_tree))
ax2.set_xticklabels([str(i) for i in range(n_tree)], rotation=45)
ax2.set_xlabel('Vertex index', fontsize=12)
ax2.set_ylabel('Potential f(v)', fontsize=12)
ax2.set_title('Potential Profile: Constant on Tree', fontsize=13)
ax2.legend(fontsize=10)

# --- Panel 3: Core Jacobian invariance under tree attachment ---
ax3 = fig.add_subplot(gs[1, 0])

stick_lengths = np.linspace(0.1, 50, 100)
eig1_vals = []
eig2_vals = []

for sl in stick_lengths:
    L_lol, n_lol = build_lollipop_laplacian(4, 4.0, sl)
    # Kernel generators on core
    S = [0, 1, 2, 3]
    ks = []
    for idx in range(1, 4):
        D = np.zeros(n_lol)
        D[S[idx]] = 1.0
        D[S[0]] = -1.0
        ks.append(solve_kernel(L_lol, D))
    Q = np.zeros((3, 3))
    for i in range(3):
        for j in range(3):
            Q[i,j] = ks[i] @ L_lol @ ks[j]
    eigs = sorted(np.linalg.eigvalsh(Q))
    eig1_vals.append(eigs[0])
    eig2_vals.append(eigs[1])

ax3.plot(stick_lengths, eig1_vals, 'b-', linewidth=2, label='λ₁')
ax3.plot(stick_lengths, eig2_vals, 'r-', linewidth=2, label='λ₂')
ax3.set_xlabel('Pendant stick length', fontsize=12)
ax3.set_ylabel('Energy eigenvalue', fontsize=12)
ax3.set_title('Core Jacobian: Invariant Under\nPendant Attachment', fontsize=13)
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)

# --- Panel 4: Laplacian structure ---
ax4 = fig.add_subplot(gs[1, 1])

L_show, _ = build_lollipop_laplacian(5, 5.0, 2.0)
im = ax4.imshow(L_show, cmap='RdBu_r', aspect='equal',
                vmin=-max(abs(L_show.flatten())),
                vmax=max(abs(L_show.flatten())))
plt.colorbar(im, ax=ax4)
ax4.set_title('Metric Laplacian Matrix\n(Row-Sum-Zero, Symmetric)', fontsize=13)
ax4.set_xlabel('Column (vertex j)', fontsize=11)
ax4.set_ylabel('Row (vertex i)', fontsize=11)

for i in range(L_show.shape[0]):
    for j in range(L_show.shape[1]):
        val = L_show[i, j]
        if abs(val) > 0.01:
            ax4.text(j, i, f'{val:.1f}', ha='center', va='center',
                     fontsize=8, color='white' if abs(val) > 0.8 else 'black')

fig.suptitle('Pendant-Edge Rigidity and Metric Graph Harmonic Theory', fontsize=15, y=0.98)
plt.savefig('viz_leaf_rigidity.png', dpi=150, bbox_inches='tight')
print("Saved viz_leaf_rigidity.png")
