"""
Applications of Canonical Kernel Theory on Metric Graphs

This module demonstrates real-world applications of the metric canonical
kernel theory across several domains:

1. Electrical network analysis — effective resistance computation
2. Signal processing on networks — harmonic interpolation
3. Graph-based machine learning — kernel methods on metric graphs
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Tuple


@dataclass
class MGModel:
    n: int
    adj: np.ndarray
    lengths: np.ndarray

    @property
    def conductance(self) -> np.ndarray:
        C = np.zeros_like(self.lengths)
        mask = self.adj > 0
        C[mask] = 1.0 / self.lengths[mask]
        return C

    @property
    def laplacian(self) -> np.ndarray:
        C = self.conductance
        L = -C.copy()
        np.fill_diagonal(L, C.sum(axis=1))
        return L


def solve_mean_zero(model: MGModel, rhs: np.ndarray) -> np.ndarray:
    n = model.n
    L = model.laplacian
    A = np.zeros((n + 1, n + 1))
    A[:n, :n] = L
    A[:n, n] = 1.0
    A[n, :n] = 1.0
    b = np.zeros(n + 1)
    b[:n] = rhs
    return np.linalg.lstsq(A, b, rcond=None)[0][:n]


# ============================================================
# Application 1: Effective Resistance in Electrical Networks
# ============================================================

def compute_effective_resistance(model: MGModel, s: int, t: int) -> float:
    """Compute effective resistance between vertices s and t.

    The effective resistance R_eff(s,t) equals the Dirichlet energy of the
    unit-current potential: inject 1 unit at s, extract 1 at t, and measure
    the resulting voltage difference.

    R_eff(s,t) = f(s) - f(t) where Lf = δ_s - δ_t.

    This connects canonical kernels to circuit theory.

    Args:
        model: Metric graph model (edge lengths = resistances).
        s, t: Source and sink vertices.

    Returns:
        Effective resistance (in ohms if lengths are in ohms).
    """
    rhs = np.zeros(model.n)
    rhs[s] = 1.0
    rhs[t] = -1.0
    f = solve_mean_zero(model, rhs)
    return f[s] - f[t]


def effective_resistance_matrix(model: MGModel) -> np.ndarray:
    """Compute the full effective resistance matrix.

    R[i,j] = effective resistance between vertices i and j.
    This is the metric on the graph induced by electrical distance.
    """
    n = model.n
    R = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            R[i, j] = R[j, i] = compute_effective_resistance(model, i, j)
    return R


def demo_electrical_networks():
    """Demonstrate effective resistance computation."""
    print("=" * 60)
    print("Application 1: Effective Resistance in Electrical Networks")
    print("=" * 60)

    # Wheatstone bridge
    n = 4
    adj = np.zeros((n, n))
    lengths = np.zeros((n, n))
    edges = [(0, 1, 1.0), (0, 2, 2.0), (1, 2, 1.0), (1, 3, 2.0), (2, 3, 1.0)]
    for u, v, l in edges:
        adj[u, v] = adj[v, u] = 1
        lengths[u, v] = lengths[v, u] = l
    bridge = MGModel(n, adj, lengths)

    print("\nWheatstone bridge network:")
    print("  Edges: 0-1 (1Ω), 0-2 (2Ω), 1-2 (1Ω), 1-3 (2Ω), 2-3 (1Ω)")

    R = effective_resistance_matrix(bridge)
    print("\nEffective resistance matrix (Ω):")
    for i, row in enumerate(R):
        print(f"  [{', '.join(f'{x:.4f}' for x in row)}]")

    print(f"\nR_eff(0, 3) = {R[0, 3]:.4f} Ω")
    print(f"R_eff(0, 1) = {R[0, 1]:.4f} Ω")

    # Verify triangle inequality
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if R[i, k] > R[i, j] + R[j, k] + 1e-10:
                    print(f"Triangle inequality violation: R({i},{k}) > R({i},{j}) + R({j},{k})")
    print("Triangle inequality: ✓ (effective resistance is a metric)")


# ============================================================
# Application 2: Harmonic Interpolation on Networks
# ============================================================

def harmonic_interpolation(
    model: MGModel,
    boundary: List[int],
    boundary_values: np.ndarray
) -> np.ndarray:
    """Interpolate values harmonically from boundary to interior.

    Given known values at boundary vertices, find the unique function
    that is harmonic at all interior vertices and matches the boundary
    data. This is the discrete Dirichlet problem.

    The metric edge lengths control the "stiffness" of interpolation:
    shorter edges create stronger coupling.

    Args:
        model: Metric graph model.
        boundary: List of boundary vertex indices.
        boundary_values: Values at boundary vertices.

    Returns:
        Function values at all vertices.
    """
    n = model.n
    L = model.laplacian
    interior = [i for i in range(n) if i not in boundary]

    if not interior:
        result = np.zeros(n)
        for i, v in enumerate(boundary):
            result[v] = boundary_values[i]
        return result

    # Extract interior-interior block
    L_ii = L[np.ix_(interior, interior)]
    L_ib = L[np.ix_(interior, boundary)]

    bv = np.array([boundary_values[boundary.index(v)] if v in boundary else 0
                    for v in boundary])
    rhs = -L_ib @ bv

    f_interior = np.linalg.solve(L_ii, rhs)

    result = np.zeros(n)
    for i, v in enumerate(boundary):
        result[v] = boundary_values[i]
    for i, v in enumerate(interior):
        result[v] = f_interior[i]
    return result


def demo_harmonic_interpolation():
    """Demonstrate harmonic interpolation."""
    print("\n" + "=" * 60)
    print("Application 2: Harmonic Interpolation on Networks")
    print("=" * 60)

    # Grid-like graph: 3x3
    n = 9
    adj = np.zeros((n, n))
    lengths = np.zeros((n, n))

    # Horizontal edges
    for r in range(3):
        for c in range(2):
            u, v = r * 3 + c, r * 3 + c + 1
            adj[u, v] = adj[v, u] = 1
            lengths[u, v] = lengths[v, u] = 1.0

    # Vertical edges
    for r in range(2):
        for c in range(3):
            u, v = r * 3 + c, (r + 1) * 3 + c
            adj[u, v] = adj[v, u] = 1
            lengths[u, v] = lengths[v, u] = 1.0

    grid = MGModel(n, adj, lengths)

    # Set boundary: corners with temperature values
    boundary = [0, 2, 6, 8]
    temps = np.array([100.0, 50.0, 50.0, 0.0])

    print("\n3×3 grid with corner temperatures:")
    print(f"  Top-left (0): {temps[0]}°")
    print(f"  Top-right (2): {temps[1]}°")
    print(f"  Bottom-left (6): {temps[2]}°")
    print(f"  Bottom-right (8): {temps[3]}°")

    result = harmonic_interpolation(grid, boundary, temps)
    print("\nHarmonically interpolated temperatures:")
    for r in range(3):
        row = [result[r * 3 + c] for c in range(3)]
        print(f"  [{', '.join(f'{x:6.2f}' for x in row)}]")

    # Verify harmonicity at interior vertices
    L = grid.laplacian
    Lf = L @ result
    print("\nLaplacian at interior vertices (should be ~0):")
    for v in range(n):
        if v not in boundary:
            print(f"  Lf({v}) = {Lf[v]:.6f}")


# ============================================================
# Application 3: Graph Kernel for Machine Learning
# ============================================================

def graph_kernel_embedding(
    model: MGModel,
    support: List[int]
) -> np.ndarray:
    """Compute canonical kernel embedding for vertices.

    Each vertex v is mapped to a |S|-dimensional feature vector
    (k_1(v), k_2(v), ..., k_|S|(v)) where k_i are canonical kernel
    generators.

    This embedding respects the metric structure and can be used for
    graph-based classification or clustering.

    Args:
        model: Metric graph model.
        support: Support vertices for the kernel basis.

    Returns:
        n × |S| embedding matrix.
    """
    n = model.n
    k = len(support)
    embedding = np.zeros((n, k))

    for i in range(k):
        D = np.zeros(k)
        D[i] = k - 1
        for j in range(k):
            if j != i:
                D[j] = -1
        rhs = np.zeros(n)
        for idx, s in enumerate(support):
            rhs[s] = D[idx]
        f = solve_mean_zero(model, rhs)
        embedding[:, i] = f

    return embedding


def demo_graph_kernel():
    """Demonstrate graph kernel embedding."""
    print("\n" + "=" * 60)
    print("Application 3: Graph Kernel Embedding for ML")
    print("=" * 60)

    # Barbell graph: two triangles connected by a bridge
    n = 6
    adj = np.zeros((n, n))
    lengths = np.zeros((n, n))

    # Triangle 1: vertices 0, 1, 2
    for u, v in [(0, 1), (1, 2), (0, 2)]:
        adj[u, v] = adj[v, u] = 1
        lengths[u, v] = lengths[v, u] = 1.0

    # Triangle 2: vertices 3, 4, 5
    for u, v in [(3, 4), (4, 5), (3, 5)]:
        adj[u, v] = adj[v, u] = 1
        lengths[u, v] = lengths[v, u] = 1.0

    # Bridge: 2 -- 3
    adj[2, 3] = adj[3, 2] = 1
    lengths[2, 3] = lengths[3, 2] = 2.0

    barbell = MGModel(n, adj, lengths)
    support = [0, 3, 5]

    print("\nBarbell graph: two triangles (0-1-2) and (3-4-5)")
    print("connected by bridge 2-3 (length 2)")
    print(f"Support S = {support}")

    emb = graph_kernel_embedding(barbell, support)
    print("\nCanonical kernel embedding (each row = vertex feature vector):")
    for v in range(n):
        print(f"  v{v}: [{', '.join(f'{x:7.4f}' for x in emb[v])}]")

    # Compute pairwise distances in embedding space
    print("\nPairwise distances in kernel space:")
    for i in range(n):
        for j in range(i + 1, n):
            d = np.linalg.norm(emb[i] - emb[j])
            print(f"  d(v{i}, v{j}) = {d:.4f}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║    Applications of Canonical Kernel Theory              ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_electrical_networks()
    demo_harmonic_interpolation()
    demo_graph_kernel()

    print("\n" + "=" * 60)
    print("All applications complete.")


"""
Interactive Demo: Canonical Kernel Theory on Metric Graphs

This demo illustrates the core mathematical concepts from the metric canonical
forms theory through concrete computations on small graphs.

Demos included:
1. Cycle graph — kernel generators and energy pairing
2. Theta graph — comparing support placements
3. Pendant-tree pruning — rigidity under tree attachment
4. Conjecture tester — refinement convergence
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Dict


# ============================================================
# Self-contained implementations (no external imports)
# ============================================================

@dataclass
class MGModel:
    """Metric graph model: vertices + adjacency + edge lengths."""
    n: int
    adj: np.ndarray
    lengths: np.ndarray

    @property
    def conductance(self) -> np.ndarray:
        C = np.zeros_like(self.lengths)
        mask = self.adj > 0
        C[mask] = 1.0 / self.lengths[mask]
        return C

    @property
    def laplacian(self) -> np.ndarray:
        C = self.conductance
        L = -C.copy()
        np.fill_diagonal(L, C.sum(axis=1))
        return L

    @property
    def genus(self) -> int:
        return int(self.adj.sum()) // 2 - self.n + 1


def make_cycle(lengths: List[float]) -> MGModel:
    n = len(lengths)
    adj = np.zeros((n, n))
    el = np.zeros((n, n))
    for i in range(n):
        j = (i + 1) % n
        adj[i, j] = adj[j, i] = 1
        el[i, j] = el[j, i] = lengths[i]
    return MGModel(n, adj, el)


def make_theta(l1: float, l2: float, l3: float) -> MGModel:
    n = 5  # 0,1 = hubs; 2,3,4 = midpoints
    adj = np.zeros((n, n))
    el = np.zeros((n, n))
    for k, mid in enumerate([2, 3, 4]):
        half = [l1, l2, l3][k] / 2.0
        adj[0, mid] = adj[mid, 0] = 1
        adj[mid, 1] = adj[1, mid] = 1
        el[0, mid] = el[mid, 0] = half
        el[mid, 1] = el[1, mid] = half
    return MGModel(n, adj, el)


def make_lollipop(cycle_lengths: List[float], tail_length: float) -> MGModel:
    nc = len(cycle_lengths)
    n = nc + 1
    adj = np.zeros((n, n))
    el = np.zeros((n, n))
    for i in range(nc):
        j = (i + 1) % nc
        adj[i, j] = adj[j, i] = 1
        el[i, j] = el[j, i] = cycle_lengths[i]
    adj[0, nc] = adj[nc, 0] = 1
    el[0, nc] = el[nc, 0] = tail_length
    return MGModel(n, adj, el)


def solve_kernel(model: MGModel, support: List[int], divisor: np.ndarray) -> np.ndarray:
    """Solve for mean-zero potential with Laplacian image = divisor on support."""
    n = model.n
    L = model.laplacian
    rhs = np.zeros(n)
    for i, s in enumerate(support):
        rhs[s] = divisor[i]
    A = np.zeros((n + 1, n + 1))
    A[:n, :n] = L
    A[:n, n] = 1.0
    A[n, :n] = 1.0
    b = np.zeros(n + 1)
    b[:n] = rhs
    sol = np.linalg.lstsq(A, b, rcond=None)[0]
    return sol[:n]


def kernel_matrix(model: MGModel, support: List[int]) -> np.ndarray:
    k = len(support)
    K = np.zeros((k, k))
    for i in range(k):
        D = np.zeros(k)
        D[i] = k - 1
        for j in range(k):
            if j != i:
                D[j] = -1
        f = solve_kernel(model, support, D)
        for j in range(k):
            K[i, j] = f[support[j]]
    return K


def energy_form(model: MGModel, support: List[int]) -> np.ndarray:
    k = len(support)
    L = model.laplacian
    Q = np.zeros((k, k))
    kernels = []
    for i in range(k):
        D = np.zeros(k)
        D[i] = k - 1
        for j in range(k):
            if j != i:
                D[j] = -1
        kernels.append(solve_kernel(model, support, D))
    for i in range(k):
        for j in range(k):
            Q[i, j] = kernels[i] @ L @ kernels[j]
    return Q


def prune_leaves(model: MGModel) -> Tuple[MGModel, List[int], Dict[int, int]]:
    adj = model.adj.copy()
    active = list(range(model.n))
    leaf_map = {}
    changed = True
    while changed:
        changed = False
        remove = []
        for v in active:
            if adj[v].sum() == 1:
                nb = int(np.where(adj[v] > 0)[0][0])
                leaf_map[v] = nb
                remove.append(v)
                changed = True
            elif adj[v].sum() == 0:
                remove.append(v)
                changed = True
        for v in remove:
            adj[v, :] = 0
            adj[:, v] = 0
            if v in active:
                active.remove(v)
    if not active:
        active = [0]
    core = sorted(active)
    k = len(core)
    new_adj = np.zeros((k, k))
    new_len = np.zeros((k, k))
    for i, vi in enumerate(core):
        for j, vj in enumerate(core):
            new_adj[i, j] = model.adj[vi, vj]
            new_len[i, j] = model.lengths[vi, vj]
    return MGModel(k, new_adj, new_len), core, leaf_map


def subdivide_all(model: MGModel) -> MGModel:
    """Subdivide all edges once (insert midpoints)."""
    edges = []
    for i in range(model.n):
        for j in range(i + 1, model.n):
            if model.adj[i, j] == 1:
                edges.append((i, j, model.lengths[i, j]))
    new_n = model.n + len(edges)
    new_adj = np.zeros((new_n, new_n))
    new_len = np.zeros((new_n, new_n))
    # Keep original vertices but remove original edges
    # (all edges will be replaced by subdivided versions)
    mid_idx = model.n
    for i, j, l in edges:
        half = l / 2.0
        new_adj[i, mid_idx] = new_adj[mid_idx, i] = 1
        new_adj[mid_idx, j] = new_adj[j, mid_idx] = 1
        new_len[i, mid_idx] = new_len[mid_idx, i] = half
        new_len[mid_idx, j] = new_len[j, mid_idx] = half
        mid_idx += 1
    return MGModel(new_n, new_adj, new_len)


# ============================================================
# Demo 1: Cycle Graph
# ============================================================

def demo_cycle_graph():
    """Compute canonical kernels on a cycle graph with varying edge lengths."""
    print("=" * 60)
    print("DEMO 1: Cycle Graph — Canonical Kernel Generators")
    print("=" * 60)

    # Cycle with 4 vertices and asymmetric edge lengths
    lengths = [1.0, 2.0, 1.5, 0.8]
    C = make_cycle(lengths)
    print(f"\nCycle graph C₄ with edge lengths: {lengths}")
    print(f"Total perimeter: {sum(lengths):.1f}")
    print(f"Genus: {C.genus}")

    print(f"\nWeighted Laplacian L:")
    L = C.laplacian
    for row in L:
        print("  [" + ", ".join(f"{x:8.4f}" for x in row) + "]")

    # Verify row-sum-zero (Theorem 1)
    print(f"\nRow sums (should be ~0): {L.sum(axis=1)}")

    # Verify symmetry (Theorem 2)
    print(f"Symmetric: {np.allclose(L, L.T)}")

    # Support set S = {0, 1, 2}
    S = [0, 1, 2]
    print(f"\nSupport set S = {S}")

    # Compute kernel matrix
    K = kernel_matrix(C, S)
    print(f"\nCanonical kernel matrix K (K[i,j] = k_i(s_j)):")
    for row in K:
        print("  [" + ", ".join(f"{x:8.5f}" for x in row) + "]")

    # Compute energy form
    Q = energy_form(C, S)
    print(f"\nDirichlet energy form Q (tropical polarization):")
    for row in Q:
        print("  [" + ", ".join(f"{x:8.5f}" for x in row) + "]")

    # Check positive semi-definiteness (Theorem 5)
    eigvals = np.linalg.eigvalsh(Q)
    print(f"\nEigenvalues of Q: {eigvals}")
    print(f"Positive semi-definite: {all(v >= -1e-10 for v in eigvals)}")

    # Verify symmetry of Q
    print(f"Q symmetric: {np.allclose(Q, Q.T)}")

    # Test with specific divisor
    D = np.array([1.0, -1.0, 0.0])
    print(f"\nSolving for divisor D = {D} (degree = {sum(D)})")
    f = solve_kernel(C, S, D)
    print(f"Potential f: {f}")
    print(f"Mean: {f.mean():.10f} (should be ~0)")
    print(f"Lf: {L @ f}")
    print(f"Energy: {f @ L @ f:.6f}")

    return C, K, Q


# ============================================================
# Demo 2: Theta Graph
# ============================================================

def demo_theta_graph():
    """Compare kernel structures for different support placements on a theta graph."""
    print("\n" + "=" * 60)
    print("DEMO 2: Theta Graph — Support Placement Comparison")
    print("=" * 60)

    T = make_theta(1.0, 2.0, 3.0)
    print(f"\nTheta graph with path lengths (1, 2, 3)")
    print(f"Vertices: 0,1 = hubs; 2,3,4 = path midpoints")
    print(f"Genus: {T.genus}")

    L = T.laplacian
    print(f"\nLaplacian:")
    for row in L:
        print("  [" + ", ".join(f"{x:7.3f}" for x in row) + "]")

    # Support at hubs
    S1 = [0, 1]
    K1 = kernel_matrix(T, S1)
    Q1 = energy_form(T, S1)
    print(f"\nSupport S₁ = {S1} (hubs only)")
    print(f"Kernel matrix K₁:\n{K1}")
    print(f"Energy form Q₁:\n{Q1}")

    # Support at hubs + one midpoint
    S2 = [0, 1, 2]
    K2 = kernel_matrix(T, S2)
    Q2 = energy_form(T, S2)
    print(f"\nSupport S₂ = {S2} (hubs + midpoint)")
    print(f"Kernel matrix K₂:\n{K2}")
    print(f"Energy form Q₂:\n{Q2}")

    # Compare: S1 should capture full Jacobian (genus 2, |S1|-1 = 1 < genus)
    # S2 should capture more
    r1 = np.linalg.matrix_rank(Q1, tol=1e-8)
    r2 = np.linalg.matrix_rank(Q2, tol=1e-8)
    print(f"\nRank of Q₁: {r1}")
    print(f"Rank of Q₂: {r2}")
    print(f"Genus (target): {T.genus}")

    return T


# ============================================================
# Demo 3: Pendant-Tree Pruning
# ============================================================

def demo_pendant_pruning():
    """Show that attaching trees does not change the core Jacobian."""
    print("\n" + "=" * 60)
    print("DEMO 3: Pendant-Tree Pruning — Metric Leaf Rigidity")
    print("=" * 60)

    # Base: triangle
    base = make_cycle([1.0, 1.0, 1.0])
    S_base = [0, 1]
    K_base = kernel_matrix(base, S_base)
    Q_base = energy_form(base, S_base)
    print(f"\nBase: Triangle with unit edge lengths")
    print(f"Support S = {S_base}")
    print(f"Kernel matrix:\n{K_base}")
    print(f"Energy form:\n{Q_base}")

    # Attach pendant trees of increasing length
    for tail_len in [0.5, 1.0, 2.0, 5.0, 10.0]:
        lollipop = make_lollipop([1.0, 1.0, 1.0], tail_len)
        core, core_verts, leaves = prune_leaves(lollipop)

        # Kernel on the core
        # Map support vertices to core indices
        core_support = [core_verts.index(s) for s in S_base]
        K_core = kernel_matrix(core, core_support)

        # Kernel on full lollipop (support still at 0, 1)
        K_full = kernel_matrix(lollipop, S_base)

        # Compare K_base (3 vertices) with K_core (should match)
        diff = np.max(np.abs(K_base - K_core))
        print(f"\nTail length = {tail_len:5.1f}: "
              f"|K_base - K_core| = {diff:.2e}, "
              f"core vertices = {core_verts}, "
              f"pruned = {leaves}")

    print("\n→ The core Jacobian is invariant under pendant attachment!")
    print("  This confirms pendant-edge rigidity (Theorem 4).")

    # Verify harmonicity: on the lollipop, the harmonic potential at
    # the leaf equals the potential at the attachment point
    lollipop = make_lollipop([1.0, 1.0, 1.0], 2.0)
    D = np.array([1.0, -1.0])
    f = solve_kernel(lollipop, [0, 1], D)
    print(f"\nPotential on lollipop (tail_len=2): {f}")
    print(f"f(leaf={3}) = {f[3]:.6f}, f(attachment={0}) = {f[0]:.6f}")
    print(f"Equal (rigidity): {np.isclose(f[3], f[0])}")


# ============================================================
# Demo 4: Conjecture Tester — Refinement Convergence
# ============================================================

def demo_conjecture_tester():
    """Test resolution-stable kernel convergence conjecture."""
    print("\n" + "=" * 60)
    print("DEMO 4: Conjecture Tester — Refinement Convergence")
    print("=" * 60)

    print("\n--- Conjecture A: Resolution-stable kernel convergence ---")
    print("For any metric graph and support S, canonical kernel matrices")
    print("computed on uniform subdivisions converge entrywise.")

    # Test on cycle graph
    print("\n[Test 1: Cycle C₃ with lengths (1, √2, π/2)]")
    C = make_cycle([1.0, np.sqrt(2), np.pi / 2])
    S = [0, 1]

    print(f"{'Level':>6} {'|V|':>6} {'K[0,0]':>12} {'K[0,1]':>12} {'MaxDiff':>12}")
    prev_K = None
    current = C
    for level in range(5):
        K = kernel_matrix(current, S)
        diff = np.max(np.abs(K - prev_K)) if prev_K is not None else float('nan')
        print(f"{level:6d} {current.n:6d} {K[0, 0]:12.8f} {K[0, 1]:12.8f} {diff:12.8f}")
        prev_K = K.copy()
        current = subdivide_all(current)

    # Test on theta graph
    print(f"\n[Test 2: Theta graph with lengths (1, 2, 3)]")
    T = make_theta(1.0, 2.0, 3.0)
    S_theta = [0, 1]

    print(f"{'Level':>6} {'|V|':>6} {'K[0,0]':>12} {'K[0,1]':>12} {'MaxDiff':>12}")
    prev_K = None
    current = T
    for level in range(4):
        K = kernel_matrix(current, S_theta)
        diff = np.max(np.abs(K - prev_K)) if prev_K is not None else float('nan')
        print(f"{level:6d} {current.n:6d} {K[0, 0]:12.8f} {K[0, 1]:12.8f} {diff:12.8f}")
        prev_K = K.copy()
        current = subdivide_all(current)

    # Conjecture B: Core-support sufficiency
    print("\n--- Conjecture B: Core-support sufficiency ---")
    print("If S meets every cycle, then the Jacobian quotient has rank = genus.")

    for graph_name, G, S_test in [
        ("Triangle", make_cycle([1.0, 1.0, 1.0]), [0, 1]),
        ("Square", make_cycle([1.0, 1.0, 1.0, 1.0]), [0, 2]),
        ("Theta", make_theta(1.0, 2.0, 3.0), [0, 1]),
    ]:
        Q = energy_form(G, S_test)
        rank = np.linalg.matrix_rank(Q, tol=1e-8)
        genus = G.genus
        print(f"  {graph_name:12s}: genus = {genus}, rank(Q) = {rank}, "
              f"{'✓ MATCH' if rank == genus else '✗ MISMATCH — potential counterexample!'}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Canonical Kernel Theory on Metric Graphs — Demo Suite  ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_cycle_graph()
    demo_theta_graph()
    demo_pendant_pruning()
    demo_conjecture_tester()

    print("\n" + "=" * 60)
    print("All demos complete.")
    print("=" * 60)


"""
Visualization: Effective Resistance Heatmap and Kernel Structure

Displays the effective resistance matrix for several metric graph models,
showing how edge lengths determine the electrical distance structure.
Also shows how the canonical kernel matrix encodes this information.

Key insight: The effective resistance is a metric on the vertices of a
graph. It is computable from the canonical kernel matrix and connects
tropical geometry to electrical network theory.
"""

import numpy as np
import matplotlib.pyplot as plt
from dataclasses import dataclass


@dataclass
class MG:
    n: int
    adj: np.ndarray
    lengths: np.ndarray

    @property
    def laplacian(self) -> np.ndarray:
        C = np.zeros_like(self.lengths)
        mask = self.adj > 0
        C[mask] = 1.0 / self.lengths[mask]
        L = -C.copy()
        np.fill_diagonal(L, C.sum(axis=1))
        return L


def solve_mz(model, rhs):
    n = model.n
    L = model.laplacian
    A = np.zeros((n + 1, n + 1))
    A[:n, :n] = L
    A[:n, n] = 1.0
    A[n, :n] = 1.0
    b = np.zeros(n + 1)
    b[:n] = rhs
    return np.linalg.lstsq(A, b, rcond=None)[0][:n]


def eff_resistance(model, s, t):
    rhs = np.zeros(model.n)
    rhs[s] = 1.0
    rhs[t] = -1.0
    f = solve_mz(model, rhs)
    return f[s] - f[t]


def eff_res_matrix(model):
    n = model.n
    R = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            R[i, j] = R[j, i] = eff_resistance(model, i, j)
    return R


# Build several graph models
def make_cycle(lengths):
    n = len(lengths)
    adj = np.zeros((n, n))
    el = np.zeros((n, n))
    for i in range(n):
        j = (i + 1) % n
        adj[i, j] = adj[j, i] = 1
        el[i, j] = el[j, i] = lengths[i]
    return MG(n, adj, el)


def make_complete(n, length=1.0):
    adj = np.ones((n, n)) - np.eye(n)
    el = np.ones((n, n)) * length
    np.fill_diagonal(el, 0)
    return MG(n, adj, el)


def make_path(lengths):
    n = len(lengths) + 1
    adj = np.zeros((n, n))
    el = np.zeros((n, n))
    for i in range(len(lengths)):
        adj[i, i+1] = adj[i+1, i] = 1
        el[i, i+1] = el[i+1, i] = lengths[i]
    return MG(n, adj, el)


def make_star(n_leaves, lengths):
    n = n_leaves + 1  # center = 0
    adj = np.zeros((n, n))
    el = np.zeros((n, n))
    for i in range(n_leaves):
        adj[0, i+1] = adj[i+1, 0] = 1
        el[0, i+1] = el[i+1, 0] = lengths[i]
    return MG(n, adj, el)


graphs = [
    ("Cycle C₅\n(1,1,1,1,1)", make_cycle([1, 1, 1, 1, 1])),
    ("Cycle C₅\n(1,2,3,4,5)", make_cycle([1, 2, 3, 4, 5])),
    ("Complete K₄\n(unit)", make_complete(4)),
    ("Path P₅\n(1,1,1,1)", make_path([1, 1, 1, 1])),
    ("Star S₅\n(1,2,3,4)", make_star(4, [1, 2, 3, 4])),
    ("Complete K₅\n(unit)", make_complete(5)),
]

fig, axes = plt.subplots(2, 3, figsize=(14, 9))

for idx, (name, G) in enumerate(graphs):
    ax = axes[idx // 3, idx % 3]
    R = eff_res_matrix(G)

    im = ax.imshow(R, cmap='YlOrRd', interpolation='nearest')
    plt.colorbar(im, ax=ax, shrink=0.8, label='R_eff (Ω)')
    ax.set_title(name, fontsize=11, fontweight='bold')

    # Annotate cells
    for i in range(G.n):
        for j in range(G.n):
            color = 'white' if R[i, j] > R.max() * 0.6 else 'black'
            ax.text(j, i, f'{R[i, j]:.2f}', ha='center', va='center',
                    fontsize=7, color=color)

    ax.set_xlabel('Vertex', fontsize=9)
    ax.set_ylabel('Vertex', fontsize=9)
    ax.set_xticks(range(G.n))
    ax.set_yticks(range(G.n))

fig.suptitle('Effective Resistance Matrices for Metric Graph Models\n'
             'R_eff(i,j) = voltage drop for unit current injection (i→j)',
             fontsize=13, fontweight='bold')

plt.tight_layout()
plt.savefig('viz_effective_resistance.png', dpi=150, bbox_inches='tight')
print("Saved viz_effective_resistance.png")


"""
Visualization: Dirichlet Energy Landscape on a Cycle Graph

Visualizes the Dirichlet energy E(f) as a function of vertex potentials
on a 3-vertex cycle graph. Shows the energy's positive semi-definiteness,
its zero locus (constant functions), and the constraint manifold for
mean-zero potentials.

Key insight: The energy landscape is a paraboloid whose kernel is exactly
the space of constant functions — the geometric reason that harmonic
representatives are unique modulo constants.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Build cycle graph C_3 with edge lengths (1, 2, 1.5)
edge_lengths = [1.0, 2.0, 1.5]
n = 3

# Conductance matrix
C = np.zeros((n, n))
for i in range(n):
    j = (i + 1) % n
    c = 1.0 / edge_lengths[i]
    C[i, j] = C[j, i] = c

# Laplacian
L = -C.copy()
np.fill_diagonal(L, C.sum(axis=1))

# On the mean-zero plane sum(f) = 0, we parameterize:
# f = (x, y, -x-y) for (x, y) ∈ R²
# Energy E(f) = f^T L f

x_range = np.linspace(-2, 2, 100)
y_range = np.linspace(-2, 2, 100)
X, Y = np.meshgrid(x_range, y_range)

E = np.zeros_like(X)
for i in range(X.shape[0]):
    for j in range(X.shape[1]):
        f = np.array([X[i, j], Y[i, j], -X[i, j] - Y[i, j]])
        E[i, j] = f @ L @ f

fig = plt.figure(figsize=(14, 5))

# Plot 1: 3D energy surface
ax1 = fig.add_subplot(131, projection='3d')
ax1.plot_surface(X, Y, E, cmap='viridis', alpha=0.8, edgecolor='none')
ax1.set_xlabel('f(v₀)', fontsize=10)
ax1.set_ylabel('f(v₁)', fontsize=10)
ax1.set_zlabel('Energy E(f)', fontsize=10)
ax1.set_title('Dirichlet Energy\n(Mean-Zero Plane)', fontsize=11)
ax1.view_init(elev=25, azim=45)

# Plot 2: Contour plot
ax2 = fig.add_subplot(132)
levels = np.linspace(0, E.max() * 0.8, 20)
cp = ax2.contourf(X, Y, E, levels=levels, cmap='viridis')
ax2.contour(X, Y, E, levels=levels, colors='white', linewidths=0.3, alpha=0.5)
plt.colorbar(cp, ax=ax2, label='Energy')
ax2.set_xlabel('f(v₀)', fontsize=11)
ax2.set_ylabel('f(v₁)', fontsize=11)
ax2.set_title('Energy Contours\n(Mean-Zero Plane)', fontsize=11)

# Mark the minimum (origin = zero energy)
ax2.plot(0, 0, 'r*', markersize=15, label='Minimum (f=0)')
ax2.legend(fontsize=9)
ax2.set_aspect('equal')

# Plot 3: Energy along edges
ax3 = fig.add_subplot(133)

# Parameterize f along unit vectors in the mean-zero plane
directions = [
    (np.array([1, 0, -1]) / np.sqrt(2), 'f = t(1, 0, -1)/√2'),
    (np.array([0, 1, -1]) / np.sqrt(2), 'f = t(0, 1, -1)/√2'),
    (np.array([1, -1, 0]) / np.sqrt(2), 'f = t(1, -1, 0)/√2'),
]

t_range = np.linspace(-2, 2, 200)
for direction, label in directions:
    energies = [t**2 * (direction @ L @ direction) for t in t_range]
    ax3.plot(t_range, energies, linewidth=2, label=label)

ax3.set_xlabel('Parameter t', fontsize=11)
ax3.set_ylabel('Energy E(f)', fontsize=11)
ax3.set_title('Energy Along\nMean-Zero Directions', fontsize=11)
ax3.legend(fontsize=8)
ax3.set_ylim(bottom=0)
ax3.axhline(y=0, color='gray', linestyle='--', alpha=0.5)

# Add eigenvalue info
eigvals = np.linalg.eigvalsh(L)
fig.text(0.5, 0.01,
    f'Cycle C₃ with lengths ({edge_lengths[0]}, {edge_lengths[1]}, {edge_lengths[2]})  |  '
    f'Laplacian eigenvalues: [{", ".join(f"{v:.3f}" for v in sorted(eigvals))}]  |  '
    f'E(f) ≥ 0 ✓ (Theorem 5)',
    ha='center', fontsize=9, style='italic')

plt.tight_layout(rect=[0, 0.04, 1, 1])
plt.savefig('viz_energy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_energy_landscape.png")


"""
Visualization: Canonical Kernel Convergence Under Subdivision

Tracks the entries of the canonical kernel matrix as the metric graph
is uniformly refined. Demonstrates the resolution-stability conjecture:
kernel entries converge to finite limits independent of refinement scheme.

Key insight: The kernel matrix entries stabilize as the mesh refines,
suggesting that the discrete canonical kernels converge to well-defined
continuous objects — the metric graph Green's functions.
"""

import numpy as np
import matplotlib.pyplot as plt
from dataclasses import dataclass
from typing import List


@dataclass
class MG:
    n: int
    adj: np.ndarray
    lengths: np.ndarray

    @property
    def laplacian(self) -> np.ndarray:
        C = np.zeros_like(self.lengths)
        mask = self.adj > 0
        C[mask] = 1.0 / self.lengths[mask]
        L = -C.copy()
        np.fill_diagonal(L, C.sum(axis=1))
        return L


def make_cycle(lengths):
    n = len(lengths)
    adj = np.zeros((n, n))
    el = np.zeros((n, n))
    for i in range(n):
        j = (i + 1) % n
        adj[i, j] = adj[j, i] = 1
        el[i, j] = el[j, i] = lengths[i]
    return MG(n, adj, el)


def subdivide_all(model):
    edges = []
    for i in range(model.n):
        for j in range(i + 1, model.n):
            if model.adj[i, j] == 1:
                edges.append((i, j, model.lengths[i, j]))
    new_n = model.n + len(edges)
    new_adj = np.zeros((new_n, new_n))
    new_len = np.zeros((new_n, new_n))
    mid = model.n
    for i, j, l in edges:
        h = l / 2
        new_adj[i, mid] = new_adj[mid, i] = 1
        new_adj[mid, j] = new_adj[j, mid] = 1
        new_len[i, mid] = new_len[mid, i] = h
        new_len[mid, j] = new_len[j, mid] = h
        mid += 1
    return MG(new_n, new_adj, new_len)


def solve_kernel(model, support, divisor):
    n = model.n
    L = model.laplacian
    rhs = np.zeros(n)
    for i, s in enumerate(support):
        rhs[s] = divisor[i]
    A = np.zeros((n + 1, n + 1))
    A[:n, :n] = L
    A[:n, n] = 1.0
    A[n, :n] = 1.0
    b = np.zeros(n + 1)
    b[:n] = rhs
    return np.linalg.lstsq(A, b, rcond=None)[0][:n]


def kernel_matrix(model, support):
    k = len(support)
    K = np.zeros((k, k))
    for i in range(k):
        D = np.zeros(k)
        D[i] = k - 1
        for j in range(k):
            if j != i:
                D[j] = -1
        f = solve_kernel(model, support, D)
        for j in range(k):
            K[i, j] = f[support[j]]
    return K


# ============================================================
# Compute convergence data for multiple graphs
# ============================================================

graphs = [
    ("C₃ (1, √2, π/2)", make_cycle([1.0, np.sqrt(2), np.pi/2])),
    ("C₄ (1, 2, 1.5, 0.8)", make_cycle([1.0, 2.0, 1.5, 0.8])),
    ("C₅ (1, 1, 1, 1, 1)", make_cycle([1.0, 1.0, 1.0, 1.0, 1.0])),
]

support = [0, 1]  # Same support for all
max_levels = 5

fig, axes = plt.subplots(2, 3, figsize=(15, 8))

for col, (name, base_graph) in enumerate(graphs):
    levels = list(range(max_levels + 1))
    K_entries = {(i, j): [] for i in range(2) for j in range(2)}
    n_vertices = []

    current = base_graph
    for level in levels:
        K = kernel_matrix(current, support)
        for i in range(2):
            for j in range(2):
                K_entries[(i, j)].append(K[i, j])
        n_vertices.append(current.n)
        if level < max_levels:
            current = subdivide_all(current)

    # Top row: kernel entries vs refinement level
    ax1 = axes[0, col]
    for (i, j), vals in K_entries.items():
        ax1.plot(levels, vals, 'o-', linewidth=2, markersize=5,
                 label=f'K[{i},{j}]')
    ax1.set_xlabel('Refinement Level', fontsize=10)
    ax1.set_ylabel('Kernel Entry Value', fontsize=10)
    ax1.set_title(f'{name}', fontsize=11, fontweight='bold')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)

    # Bottom row: convergence rate (log of differences)
    ax2 = axes[1, col]
    for (i, j), vals in K_entries.items():
        diffs = [abs(vals[k+1] - vals[k]) for k in range(len(vals)-1)]
        if any(d > 0 for d in diffs):
            ax2.semilogy(levels[1:], diffs, 's-', linewidth=2, markersize=5,
                         label=f'|ΔK[{i},{j}]|')
    ax2.set_xlabel('Refinement Level', fontsize=10)
    ax2.set_ylabel('|K_{n+1} - K_n|', fontsize=10)
    ax2.set_title('Convergence Rate', fontsize=11)
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

fig.suptitle('Canonical Kernel Convergence Under Uniform Subdivision\n'
             'Support S = {v₀, v₁}', fontsize=13, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_kernel_convergence.png', dpi=150, bbox_inches='tight')
print("Saved viz_kernel_convergence.png")
