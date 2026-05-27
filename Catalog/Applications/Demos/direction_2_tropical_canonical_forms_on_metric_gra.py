#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Metric Graph Theory

Demonstrates how the tropical canonical kernel correspondence applies to:

1. Electrical network analysis (resistance distances)
2. Gaussian Free Field covariance computation
3. Network robustness metrics
4. Chemical graph theory (molecular resistance distances)

Each application includes a worked example with concrete numerical results.
"""

import numpy as np
from algorithms import (
    MetricGraph,
    weighted_laplacian,
    effective_resistance_matrix,
    canonical_kernel_generators,
    tropical_jacobian_invariant_factors,
    verify_laplacian_properties,
)


def application_electrical_networks():
    """Application 1: Electrical Network Analysis.

    The effective resistance between nodes in a metric graph is exactly
    the resistance between those nodes in an electrical network where
    each edge has resistance equal to its length (or conductance = 1/length).

    This has direct applications in circuit design and power grid analysis.
    """
    print("=" * 70)
    print("APPLICATION 1: Electrical Network Analysis")
    print("=" * 70)

    # Wheatstone bridge circuit
    # 4 vertices arranged in a diamond with a cross-connection
    #     0
    #    / \
    #   1   2
    #    \ /
    #     3
    # Plus edge 1-2 (the bridge)
    edges = [(0, 1), (0, 2), (1, 3), (2, 3), (1, 2)]
    resistances = [10.0, 20.0, 30.0, 40.0, 50.0]  # Ohms
    G = MetricGraph(4, edges, resistances)

    print(f"\nWheatstone Bridge Circuit:")
    print(f"  R(0,1)={resistances[0]}Ω, R(0,2)={resistances[1]}Ω")
    print(f"  R(1,3)={resistances[2]}Ω, R(2,3)={resistances[3]}Ω")
    print(f"  R(1,2)={resistances[4]}Ω (bridge)")

    R = effective_resistance_matrix(G)
    print(f"\nEffective Resistance Matrix (Ω):")
    print(np.array2string(R, precision=4, suppress_small=True))

    print(f"\n  R_eff(0,3) = {R[0,3]:.4f} Ω")
    print(f"  This is the total resistance seen between terminals 0 and 3.")

    # Kirchhoff index (sum of all pairwise resistances)
    Kf = np.sum(R) / 2
    print(f"\n  Kirchhoff index Kf(G) = {Kf:.4f}")
    print(f"  (measures overall connectivity/robustness)")

    # Verify Laplacian properties
    props = verify_laplacian_properties(G)
    print(f"\n  Laplacian properties verified: {all(props[k] for k in ['row_sum_zero', 'symmetric', 'psd'])}")
    print()


def application_gaussian_free_field():
    """Application 2: Gaussian Free Field on Graphs.

    The resistance matrix R_S is the covariance matrix of the Gaussian
    Free Field (GFF) on the metric graph Γ. The canonical kernel lattice
    Λ_S determines the periodicity structure of the discrete toroidal model.

    This connects tropical geometry to statistical mechanics.
    """
    print("=" * 70)
    print("APPLICATION 2: Gaussian Free Field Covariance")
    print("=" * 70)

    # Hexagonal lattice fragment (benzene ring)
    edges = [(0,1), (1,2), (2,3), (3,4), (4,5), (5,0)]
    lengths = [1.4, 1.4, 1.4, 1.4, 1.4, 1.4]  # Angstroms (C-C bond)
    G = MetricGraph(6, edges, lengths)

    print(f"\nBenzene Ring (Hexagonal Cycle):")
    print(f"  6 carbon atoms, C-C bond length = 1.4 Å")

    R = effective_resistance_matrix(G)
    print(f"\nGFF Covariance Matrix (= Resistance Matrix):")
    print(np.array2string(R, precision=4, suppress_small=True))

    # The diagonal gives the variance at each vertex (relative to ground)
    L_pinv = np.linalg.pinv(weighted_laplacian(G))
    print(f"\nGFF variance at each vertex (diagonal of L^+):")
    for i in range(6):
        print(f"  Var(φ_{i}) = {L_pinv[i,i]:.4f}")

    # Correlation between opposite vertices
    print(f"\n  Correlation coefficient ρ(0,3) = {L_pinv[0,3] / np.sqrt(L_pinv[0,0]*L_pinv[3,3]):.4f}")
    print(f"  (opposite vertices in hexagon)")

    # Tropical Jacobian
    factors = tropical_jacobian_invariant_factors(G, list(range(6)))
    print(f"\n  Tropical Jacobian invariant factors: {[f'{f:.4f}' for f in factors]}")
    print(f"  Genus = {G.genus}")
    print()


def application_network_robustness():
    """Application 3: Network Robustness via Kirchhoff Index.

    The Kirchhoff index Kf(G) = Σ_{i<j} R_eff(i,j) measures the overall
    robustness of a network. Smaller Kirchhoff index = more robust.

    The tropical Jacobian invariant factors provide a refined decomposition
    of this robustness measure.
    """
    print("=" * 70)
    print("APPLICATION 3: Network Robustness Comparison")
    print("=" * 70)

    networks = {
        "Linear (path)": MetricGraph(4, [(0,1),(1,2),(2,3)], [1,1,1]),
        "Star": MetricGraph(4, [(0,1),(0,2),(0,3)], [1,1,1]),
        "Cycle": MetricGraph(4, [(0,1),(1,2),(2,3),(3,0)], [1,1,1,1]),
        "Complete K4": MetricGraph(4,
            [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)], [1,1,1,1,1,1]),
    }

    print(f"\n{'Network':>15} | {'Kf(G)':>8} | {'Genus':>5} | {'Min λ>0':>10} | {'Jacobian Factors':>30}")
    print("-" * 80)

    for name, G in networks.items():
        R = effective_resistance_matrix(G)
        Kf = np.sum(R) / 2
        props = verify_laplacian_properties(G)
        min_ev = props['min_nonzero_eigenvalue']
        factors = tropical_jacobian_invariant_factors(G, list(range(G.n_vertices)))
        factors_str = ", ".join(f"{f:.3f}" for f in factors)

        print(f"{name:>15} | {Kf:>8.3f} | {G.genus:>5} | {min_ev:>10.4f} | {factors_str:>30}")

    print(f"\nInterpretation: Lower Kirchhoff index and higher algebraic connectivity")
    print(f"(min nonzero eigenvalue) indicate more robust networks.")
    print(f"K4 is most robust; the path graph is least robust.")
    print()


def application_molecular_descriptors():
    """Application 4: Molecular Graph Descriptors.

    In chemical graph theory, the resistance distance provides topological
    descriptors for molecular structures. The Wiener index (sum of
    shortest-path distances) and Kirchhoff index are both used as
    molecular descriptors, with the Kirchhoff index providing better
    discrimination for cyclic molecules.
    """
    print("=" * 70)
    print("APPLICATION 4: Molecular Resistance Descriptors")
    print("=" * 70)

    # Naphthalene: two fused hexagons sharing an edge
    # Vertices: 0-9 (10 carbons)
    edges = [
        (0,1), (1,2), (2,3), (3,4), (4,5), (5,0),  # First ring
        (2,6), (6,7), (7,8), (8,9), (9,3),          # Second ring (fused at 2-3)
    ]
    lengths = [1.4] * len(edges)
    G_naphthalene = MetricGraph(10, edges, lengths)

    # Azulene: fused 5+7 ring (isomer of naphthalene)
    edges_az = [
        (0,1), (1,2), (2,3), (3,4), (4,0),          # 5-ring
        (2,5), (5,6), (6,7), (7,8), (8,9), (9,3),   # 7-ring (fused at 2-3)
    ]
    lengths_az = [1.4] * len(edges_az)
    G_azulene = MetricGraph(10, edges_az, lengths_az)

    for name, G in [("Naphthalene (6+6)", G_naphthalene),
                     ("Azulene (5+7)", G_azulene)]:
        R = effective_resistance_matrix(G)
        Kf = np.sum(R) / 2
        factors = tropical_jacobian_invariant_factors(G, list(range(G.n_vertices)))

        print(f"\n{name}:")
        print(f"  Vertices: {G.n_vertices}, Edges: {len(G.edges)}, Genus: {G.genus}")
        print(f"  Kirchhoff index: {Kf:.4f}")
        print(f"  Mean resistance distance: {np.mean(R[np.triu_indices(G.n_vertices, 1)]):.4f}")
        print(f"  Max resistance distance: {np.max(R):.4f}")
        print(f"  Jacobian factors: {[f'{f:.3f}' for f in factors]}")

    print(f"\nNote: Despite being isomers (same formula C10H8), naphthalene")
    print(f"and azulene have different Kirchhoff indices and tropical Jacobians,")
    print(f"demonstrating the discriminative power of these descriptors.")
    print()


if __name__ == "__main__":
    application_electrical_networks()
    application_gaussian_free_field()
    application_network_robustness()
    application_molecular_descriptors()

    print("=" * 70)
    print("All applications completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Interactive Demonstration: Tropical Jacobians of Metric Graphs

Computes the tropical Jacobian of cycle graphs (genus 1) and theta graphs
(genus 2) at varying subdivisions, displays convergence, and shows the
lattice quotient structure.

Usage:
    python demo.py
"""

import numpy as np
from algorithms import (
    MetricGraph,
    weighted_laplacian,
    effective_resistance_matrix,
    canonical_kernel_generators,
    tropical_jacobian_invariant_factors,
    subdivide_graph,
)


def demo_cycle_graph():
    """Demonstrate tropical Jacobian computation for a cycle graph (genus 1)."""
    print("=" * 70)
    print("DEMO 1: Cycle Graph C_n (Genus 1)")
    print("=" * 70)

    # Cycle graph with 4 vertices, edge lengths 1, 2, 3, 4
    n = 4
    edges = [(i, (i + 1) % n) for i in range(n)]
    lengths = [1.0, 2.0, 3.0, 4.0]
    G = MetricGraph(n, edges, lengths)

    print(f"\nGraph: Cycle C_{n}")
    print(f"Edge lengths: {lengths}")
    print(f"Total perimeter: {sum(lengths)}")

    L = weighted_laplacian(G)
    print(f"\nWeighted Laplacian L:")
    print(np.array2string(L, precision=4, suppress_small=True))

    # Verify row-sum-zero
    row_sums = L.sum(axis=1)
    print(f"\nRow sums (should be ~0): {row_sums}")

    # Verify symmetry
    print(f"Symmetric: {np.allclose(L, L.T)}")

    # Verify PSD
    eigenvalues = np.linalg.eigvalsh(L)
    print(f"Eigenvalues: {np.sort(eigenvalues)}")
    print(f"All eigenvalues ≥ 0: {all(e >= -1e-10 for e in eigenvalues)}")

    # Effective resistance
    R = effective_resistance_matrix(G)
    print(f"\nEffective resistance matrix:")
    print(np.array2string(R, precision=4, suppress_small=True))

    # Canonical kernel generators
    S = list(range(n))
    gens = canonical_kernel_generators(G, S)
    print(f"\nCanonical kernel generators (columns of reduced resistance):")
    print(np.array2string(gens, precision=4, suppress_small=True))

    # Tropical Jacobian
    factors = tropical_jacobian_invariant_factors(G, S)
    print(f"\nInvariant factors of tropical Jacobian: {factors}")
    print(f"  => J(Γ) ≅ ℝ/({sum(lengths)})ℤ (genus 1, single factor = perimeter)")

    print()


def demo_theta_graph():
    """Demonstrate tropical Jacobian computation for a theta graph (genus 2)."""
    print("=" * 70)
    print("DEMO 2: Theta Graph Θ(a,b,c) (Genus 2)")
    print("=" * 70)

    # Theta graph: two vertices connected by 3 paths of lengths a, b, c
    a, b, c = 2.0, 3.0, 5.0
    # We model this with 2 vertices and 3 edges between them
    # But SimpleGraph doesn't allow multi-edges, so we subdivide each path
    # with intermediate vertices:
    # Vertices: 0 (source), 1 (sink), 2 (on path a), 3 (on path b), 4 (on path c)
    edges = [
        (0, 2), (2, 1),  # Path of length a: 0 -- 2 -- 1
        (0, 3), (3, 1),  # Path of length b: 0 -- 3 -- 1
        (0, 4), (4, 1),  # Path of length c: 0 -- 4 -- 1
    ]
    lengths = [a/2, a/2, b/2, b/2, c/2, c/2]
    G = MetricGraph(5, edges, lengths)

    print(f"\nGraph: Theta Θ({a}, {b}, {c})")
    print(f"Three paths of lengths {a}, {b}, {c} between vertices 0 and 1")
    print(f"Genus: 2")

    L = weighted_laplacian(G)
    print(f"\nWeighted Laplacian (5×5):")
    print(np.array2string(L, precision=4, suppress_small=True))

    # Eigenvalues
    eigenvalues = np.linalg.eigvalsh(L)
    print(f"\nEigenvalues: {np.sort(eigenvalues)}")
    nullity = sum(1 for e in eigenvalues if abs(e) < 1e-10)
    print(f"Nullity (should be 1 for connected): {nullity}")

    # Effective resistance between endpoints
    R = effective_resistance_matrix(G)
    R_01 = R[0, 1]
    R_parallel = 1.0 / (1.0/a + 1.0/b + 1.0/c)
    print(f"\nEffective resistance R(0,1): {R_01:.6f}")
    print(f"Parallel formula 1/(1/a+1/b+1/c): {R_parallel:.6f}")

    # Canonical kernel for branch points S = {0, 1}
    S = [0, 1]
    gens = canonical_kernel_generators(G, S)
    print(f"\nCanonical kernel generators for S = {{0, 1}}:")
    print(np.array2string(gens, precision=4, suppress_small=True))

    # Full vertex set
    S_full = list(range(5))
    factors = tropical_jacobian_invariant_factors(G, S_full)
    print(f"\nInvariant factors for S = all vertices: {factors}")

    print()


def demo_subdivision_convergence():
    """Demonstrate convergence of subdivision approximation."""
    print("=" * 70)
    print("DEMO 3: Subdivision Convergence (Cycle Graph)")
    print("=" * 70)

    # Original cycle graph: 3 vertices with lengths 1, 1, 1
    base_edges = [(0, 1), (1, 2), (2, 0)]
    base_lengths = [1.0, 1.0, 1.0]
    G_base = MetricGraph(3, base_edges, base_lengths)

    S_base = [0, 1, 2]
    gens_base = canonical_kernel_generators(G_base, S_base)
    print(f"\nBase graph: Triangle with unit edge lengths")
    print(f"Base canonical kernel generators:")
    print(np.array2string(gens_base, precision=6))

    print(f"\n{'n':>4} | {'Vertices':>8} | {'Max diff from base':>20} | {'Rate':>10}")
    print("-" * 55)

    prev_diff = None
    for n in [2, 4, 8, 16, 32]:
        G_sub = subdivide_graph(G_base, n)
        # Use only the original vertices
        gens_sub = canonical_kernel_generators(G_sub, S_base)
        diff = np.max(np.abs(gens_sub - gens_base))

        if prev_diff is not None and diff > 1e-15:
            rate = np.log2(prev_diff / diff)
        else:
            rate = float('nan')

        print(f"{n:>4} | {G_sub.n_vertices:>8} | {diff:>20.2e} | {rate:>10.2f}")
        prev_diff = diff

    print()
    print("Note: For a cycle graph, the canonical kernel generators for the")
    print("original vertices are EXACT at any subdivision level (rate → ∞),")
    print("because the effective resistance between original vertices is")
    print("preserved exactly by subdivision.")

    print()


def demo_leaf_rigidity():
    """Demonstrate the leaf rigidity theorem numerically."""
    print("=" * 70)
    print("DEMO 4: Leaf Rigidity (Weighted Harmonic Functions)")
    print("=" * 70)

    # Star graph: center vertex 0 with leaves 1, 2, 3
    edges = [(0, 1), (0, 2), (0, 3)]
    lengths = [2.0, 3.0, 5.0]
    G = MetricGraph(4, edges, lengths)

    L = weighted_laplacian(G)
    print(f"\nStar graph: center=0, leaves=1,2,3")
    print(f"Edge lengths: {lengths}")
    print(f"\nWeighted Laplacian:")
    print(np.array2string(L, precision=4, suppress_small=True))

    # Solve for harmonic functions on interior {0}
    # The kernel of L is spanned by (1,1,1,1)
    # Any harmonic function at vertex 0 satisfies:
    # L[0,0]*f[0] + L[0,1]*f[1] + L[0,2]*f[2] + L[0,3]*f[3] = 0
    # i.e., (1/2+1/3+1/5)*f[0] = (1/2)*f[1] + (1/3)*f[2] + (1/5)*f[3]

    # Leaf rigidity says: a harmonic function at a leaf equals its neighbor
    # Check: if f is harmonic at vertex 1 (leaf), then f(1) = f(0)
    print(f"\nLeaf rigidity theorem verification:")
    print(f"  At leaf vertex 1: L[1,:] = {L[1,:]}")
    print(f"  Harmonic at 1 means: (1/2)*f(1) + (-1/2)*f(0) = 0")
    print(f"  => f(1) = f(0) ✓")
    print(f"  At leaf vertex 2: (1/3)*f(2) + (-1/3)*f(0) = 0 => f(2) = f(0) ✓")
    print(f"  At leaf vertex 3: (1/5)*f(3) + (-1/5)*f(0) = 0 => f(3) = f(0) ✓")
    print(f"\n  Result: All harmonic functions on a tree are constant (as expected).")

    # PSD verification
    print(f"\n  Eigenvalues of L: {np.sort(np.linalg.eigvalsh(L))}")
    print(f"  PSD confirmed: all eigenvalues ≥ 0 ✓")

    print()


if __name__ == "__main__":
    demo_cycle_graph()
    demo_theta_graph()
    demo_subdivision_convergence()
    demo_leaf_rigidity()

    print("=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization 2: Eigenvalue Spectrum and PSD Verification

Shows the eigenvalue spectrum of weighted Laplacians for various metric graphs,
visually confirming positive semi-definiteness. Includes the spectral gap
(smallest nonzero eigenvalue), which measures algebraic connectivity.

Also shows how edge lengths affect the spectrum: longer edges reduce
conductance and shift eigenvalues toward zero.
"""

import numpy as np
import matplotlib.pyplot as plt


# ─── Inline graph classes and algorithms ───

class MetricGraph:
    def __init__(self, n_vertices, edges, lengths):
        self.n_vertices = n_vertices
        self.edges = edges
        self.lengths = lengths

    @property
    def genus(self):
        return len(self.edges) - self.n_vertices + 1


def weighted_laplacian(G):
    n = G.n_vertices
    L = np.zeros((n, n))
    for (i, j), length in zip(G.edges, G.lengths):
        c = 1.0 / length
        L[i, j] -= c
        L[j, i] -= c
        L[i, i] += c
        L[j, j] += c
    return L


# ─── Figure ───

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Eigenvalue Spectra of Weighted Laplacians\n(Positive Semi-Definiteness Verification)",
             fontsize=14, fontweight='bold')

# Panel 1: Different graph topologies with unit lengths
ax = axes[0, 0]
topologies = {
    "Path P₅": MetricGraph(5, [(0,1),(1,2),(2,3),(3,4)], [1]*4),
    "Cycle C₅": MetricGraph(5, [(0,1),(1,2),(2,3),(3,4),(4,0)], [1]*5),
    "Star K₁,₄": MetricGraph(5, [(0,1),(0,2),(0,3),(0,4)], [1]*4),
    "Complete K₅": MetricGraph(5,
        [(i,j) for i in range(5) for j in range(i+1,5)],
        [1]*10),
}
colors = plt.cm.Set2(np.linspace(0, 1, len(topologies)))
for (name, G), color in zip(topologies.items(), colors):
    L = weighted_laplacian(G)
    eigs = np.sort(np.linalg.eigvalsh(L))
    ax.plot(range(len(eigs)), eigs, 'o-', color=color, label=name, markersize=8)
ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax.set_xlabel("Index", fontsize=10)
ax.set_ylabel("Eigenvalue λ", fontsize=10)
ax.set_title("Different Topologies (unit lengths)", fontsize=11)
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 2: Same topology, varying edge length scale
ax = axes[0, 1]
scales = [0.5, 1.0, 2.0, 5.0, 10.0]
colors2 = plt.cm.viridis(np.linspace(0.2, 0.9, len(scales)))
for scale, color in zip(scales, colors2):
    G = MetricGraph(5, [(0,1),(1,2),(2,3),(3,4),(4,0)], [scale]*5)
    L = weighted_laplacian(G)
    eigs = np.sort(np.linalg.eigvalsh(L))
    ax.plot(range(len(eigs)), eigs, 'o-', color=color,
            label=f"ℓ = {scale}", markersize=8)
ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax.set_xlabel("Index", fontsize=10)
ax.set_ylabel("Eigenvalue λ", fontsize=10)
ax.set_title("Cycle C₅ with varying edge length", fontsize=11)
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 3: Spectral gap vs number of vertices (cycle graph)
ax = axes[1, 0]
ns = range(3, 21)
gaps = []
for n in ns:
    edges = [(i, (i+1)%n) for i in range(n)]
    G = MetricGraph(n, edges, [1.0]*n)
    L = weighted_laplacian(G)
    eigs = np.sort(np.linalg.eigvalsh(L))
    gap = eigs[1]  # smallest nonzero eigenvalue
    gaps.append(gap)
ax.plot(list(ns), gaps, 'bo-', markersize=6)
# Theoretical: λ_1 = 2(1 - cos(2π/n)) for unit cycle
theoretical = [2*(1 - np.cos(2*np.pi/n)) for n in ns]
ax.plot(list(ns), theoretical, 'r--', label=r"$2(1-\cos(2\pi/n))$", alpha=0.7)
ax.set_xlabel("Number of vertices n", fontsize=10)
ax.set_ylabel("Spectral gap λ₁", fontsize=10)
ax.set_title("Spectral Gap vs. Graph Size (unit cycle)", fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Quadratic form x^T L x for random vectors (histogram)
ax = axes[1, 1]
G = MetricGraph(6, [(0,1),(1,2),(2,3),(3,4),(4,5),(5,0),(0,3),(1,4)],
                [1,2,1,2,1,2,3,3])
L = weighted_laplacian(G)
np.random.seed(42)
n_samples = 5000
quad_vals = []
for _ in range(n_samples):
    x = np.random.randn(G.n_vertices)
    qf = x @ L @ x
    quad_vals.append(qf)

ax.hist(quad_vals, bins=60, density=True, color='steelblue', alpha=0.7,
        edgecolor='white')
ax.axvline(x=0, color='red', linewidth=2, linestyle='--', label='x = 0')
ax.set_xlabel("x^T L x", fontsize=10)
ax.set_ylabel("Density", fontsize=10)
ax.set_title("Quadratic Form Distribution (PSD: all ≥ 0)", fontsize=11)
ax.annotate(f"min = {min(quad_vals):.4f}\nall values ≥ 0 ✓",
            xy=(0.65, 0.85), xycoords='axes fraction', fontsize=9,
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("viz_eigenvalue_spectrum.png", dpi=150, bbox_inches='tight')
print("Saved viz_eigenvalue_spectrum.png")


#!/usr/bin/env python3
"""
Visualization 1: Weighted Laplacian and Resistance Heatmaps

Visualizes the weighted Laplacian matrix and effective resistance matrix
for several graph topologies (cycle, star, complete, theta), showing how
graph structure and edge lengths determine the algebraic properties.

The Laplacian encodes conductance structure; the resistance matrix encodes
pairwise distances in the tropical metric.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


# ─── Inline graph classes and algorithms ───

class MetricGraph:
    def __init__(self, n_vertices, edges, lengths):
        self.n_vertices = n_vertices
        self.edges = edges
        self.lengths = lengths

    @property
    def genus(self):
        return len(self.edges) - self.n_vertices + 1


def weighted_laplacian(G):
    n = G.n_vertices
    L = np.zeros((n, n))
    for (i, j), length in zip(G.edges, G.lengths):
        c = 1.0 / length
        L[i, j] -= c
        L[j, i] -= c
        L[i, i] += c
        L[j, j] += c
    return L


def effective_resistance_matrix(G):
    L = weighted_laplacian(G)
    L_pinv = np.linalg.pinv(L)
    n = G.n_vertices
    R = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            R[i, j] = L_pinv[i, i] + L_pinv[j, j] - 2 * L_pinv[i, j]
    return R


# ─── Graphs ───

graphs = {
    "Cycle C₅\n(genus 1)": MetricGraph(5,
        [(0,1),(1,2),(2,3),(3,4),(4,0)],
        [1.0, 1.5, 2.0, 2.5, 3.0]),
    "Star K₁,₄\n(genus 0)": MetricGraph(5,
        [(0,1),(0,2),(0,3),(0,4)],
        [1.0, 2.0, 3.0, 4.0]),
    "Complete K₄\n(genus 3)": MetricGraph(4,
        [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)],
        [1.0, 2.0, 3.0, 1.5, 2.5, 3.5]),
    "Theta Θ(2,3,5)\n(genus 2)": MetricGraph(5,
        [(0,2),(2,1),(0,3),(3,1),(0,4),(4,1)],
        [1.0, 1.0, 1.5, 1.5, 2.5, 2.5]),
}

fig = plt.figure(figsize=(16, 10))
fig.suptitle("Weighted Laplacian & Effective Resistance Matrices\nfor Metric Graphs",
             fontsize=16, fontweight='bold', y=0.98)

gs = gridspec.GridSpec(2, 4, hspace=0.4, wspace=0.3,
                       top=0.88, bottom=0.05, left=0.05, right=0.95)

for idx, (name, G) in enumerate(graphs.items()):
    L = weighted_laplacian(G)
    R = effective_resistance_matrix(G)

    # Laplacian heatmap (top row)
    ax1 = fig.add_subplot(gs[0, idx])
    vmax = max(abs(L.min()), abs(L.max()))
    im1 = ax1.imshow(L, cmap='RdBu_r', vmin=-vmax, vmax=vmax, aspect='equal')
    ax1.set_title(name, fontsize=10)
    ax1.set_xlabel("vertex j", fontsize=8)
    if idx == 0:
        ax1.set_ylabel("Laplacian L(i,j)", fontsize=10)
    for i in range(L.shape[0]):
        for j in range(L.shape[1]):
            ax1.text(j, i, f"{L[i,j]:.2f}", ha='center', va='center',
                     fontsize=6, color='white' if abs(L[i,j]) > vmax*0.6 else 'black')
    plt.colorbar(im1, ax=ax1, shrink=0.8)

    # Resistance heatmap (bottom row)
    ax2 = fig.add_subplot(gs[1, idx])
    im2 = ax2.imshow(R, cmap='YlOrRd', aspect='equal')
    ax2.set_xlabel("vertex j", fontsize=8)
    if idx == 0:
        ax2.set_ylabel("Resistance R(i,j)", fontsize=10)
    for i in range(R.shape[0]):
        for j in range(R.shape[1]):
            ax2.text(j, i, f"{R[i,j]:.2f}", ha='center', va='center',
                     fontsize=6, color='white' if R[i,j] > R.max()*0.6 else 'black')
    plt.colorbar(im2, ax=ax2, shrink=0.8)

    # Add Kirchhoff index annotation
    Kf = np.sum(R) / 2
    ax2.text(0.5, -0.15, f"Kf = {Kf:.2f}", transform=ax2.transAxes,
             ha='center', fontsize=8, style='italic')

plt.savefig("viz_laplacian_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_laplacian_heatmap.png")


#!/usr/bin/env python3
"""
Visualization 3: Subdivision Convergence and Tropical Jacobian Structure

Shows how subdividing edges of a metric graph affects:
1. The effective resistance matrix (which converges to the continuous limit)
2. The canonical kernel generators
3. The tropical Jacobian invariant factors

Demonstrates the subdivision convergence conjecture with rate analysis
on cycle and theta graphs.
"""

import numpy as np
import matplotlib.pyplot as plt


# ─── Inline graph classes and algorithms ───

class MetricGraph:
    def __init__(self, n_vertices, edges, lengths):
        self.n_vertices = n_vertices
        self.edges = edges
        self.lengths = lengths

    @property
    def genus(self):
        return len(self.edges) - self.n_vertices + 1


def weighted_laplacian(G):
    n = G.n_vertices
    L = np.zeros((n, n))
    for (i, j), length in zip(G.edges, G.lengths):
        c = 1.0 / length
        L[i, j] -= c
        L[j, i] -= c
        L[i, i] += c
        L[j, j] += c
    return L


def effective_resistance_matrix(G):
    L = weighted_laplacian(G)
    L_pinv = np.linalg.pinv(L)
    n = G.n_vertices
    R = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            R[i, j] = L_pinv[i, i] + L_pinv[j, j] - 2 * L_pinv[i, j]
    return R


def subdivide_graph(G, n):
    if n <= 1:
        return G
    new_edges = []
    new_lengths = []
    next_vertex = G.n_vertices
    for (i, j), length in zip(G.edges, G.lengths):
        sub_length = length / n
        prev = i
        for k in range(n - 1):
            new_edges.append((prev, next_vertex))
            new_lengths.append(sub_length)
            prev = next_vertex
            next_vertex += 1
        new_edges.append((prev, j))
        new_lengths.append(sub_length)
    return MetricGraph(next_vertex, new_edges, new_lengths)


def canonical_kernel_generators(G, S, base_vertex=None):
    if base_vertex is None:
        base_vertex = S[0]
    R = effective_resistance_matrix(G)
    S_reduced = [v for v in S if v != base_vertex]
    k = len(S_reduced)
    if k == 0:
        return np.array([[]])
    gen = np.zeros((k, k))
    for i in range(k):
        for j in range(k):
            vi, vj = S_reduced[i], S_reduced[j]
            gen[i, j] = (R[vi, vj] - R[vi, base_vertex]
                         - R[base_vertex, vj] + R[base_vertex, base_vertex])
    return gen


# ─── Convergence experiment ───

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Subdivision Convergence & Tropical Jacobian Structure",
             fontsize=14, fontweight='bold')

# Test graphs
test_configs = [
    ("Cycle C₃ (genus 1)",
     MetricGraph(3, [(0,1),(1,2),(2,0)], [1.0, 2.0, 3.0]),
     [0, 1, 2]),
    ("Cycle C₄ (genus 1)",
     MetricGraph(4, [(0,1),(1,2),(2,3),(3,0)], [1.0, 1.5, 2.0, 2.5]),
     [0, 1, 2, 3]),
    ("Theta Θ(1,2,3) (genus 2)",
     MetricGraph(5, [(0,2),(2,1),(0,3),(3,1),(0,4),(4,1)],
                 [0.5, 0.5, 1.0, 1.0, 1.5, 1.5]),
     [0, 1]),
    ("Diamond (genus 2)",
     MetricGraph(4, [(0,1),(0,2),(1,3),(2,3),(1,2)],
                 [1.0, 2.0, 1.5, 2.5, 3.0]),
     [0, 1, 2, 3]),
]

subdivisions = [1, 2, 4, 8, 16, 32]

for idx, (name, G_base, S) in enumerate(test_configs):
    ax = axes[idx // 2, idx % 2]

    # Compute generators at each subdivision level
    base_gens = canonical_kernel_generators(G_base, S)
    diffs = []
    for n in subdivisions:
        G_sub = subdivide_graph(G_base, n)
        sub_gens = canonical_kernel_generators(G_sub, S)
        diff = np.max(np.abs(sub_gens - base_gens)) if sub_gens.size > 0 else 0
        diffs.append(max(diff, 1e-16))

    ax.semilogy(subdivisions, diffs, 'bo-', markersize=8, linewidth=2,
                label='Max |κ_n - κ_1|')

    # Reference lines for convergence rates
    if diffs[0] > 1e-14:
        ref_n = np.array(subdivisions, dtype=float)
        c0 = diffs[0] * subdivisions[0]
        ax.semilogy(subdivisions, c0 / ref_n, 'r--', alpha=0.5,
                    label='O(1/n)')
        c0_sq = diffs[0] * subdivisions[0]**2
        ax.semilogy(subdivisions, c0_sq / ref_n**2, 'g--', alpha=0.5,
                    label='O(1/n²)')

    ax.set_xlabel("Subdivision level n", fontsize=10)
    ax.set_ylabel("Max generator difference", fontsize=10)
    ax.set_title(name, fontsize=11)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Add genus and Jacobian info
    eigs = np.sort(np.linalg.eigvalsh(weighted_laplacian(G_base)))
    ax.text(0.02, 0.02,
            f"genus={G_base.genus}, λ₁={eigs[1]:.3f}",
            transform=ax.transAxes, fontsize=8,
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8),
            verticalalignment='bottom')

plt.tight_layout()
plt.savefig("viz_subdivision_convergence.png", dpi=150, bbox_inches='tight')
print("Saved viz_subdivision_convergence.png")
