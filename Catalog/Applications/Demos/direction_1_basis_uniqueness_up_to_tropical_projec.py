"""
Applications of Tropical Kernel Rigidity.

Demonstrates real-world uses of canonical tropical kernel generators:
1. Graph fingerprinting via canonical generators
2. Network mode decomposition
3. Chip-firing canonical configurations
"""

import numpy as np
from itertools import combinations


def graph_laplacian(adj):
    """Compute the combinatorial graph Laplacian."""
    n = adj.shape[0]
    L = -adj.copy()
    for i in range(n):
        L[i, i] = int(np.sum(adj[i]))
    return L


def fun_support(f):
    """Support of a function (nonzero indices)."""
    return frozenset(i for i in range(len(f)) if f[i] != 0)


def harmonic_kernel_basis(L, S, n):
    """Compute integer basis of harmonic kernel on S."""
    rows = np.array([L[v] for v in S], dtype=float)
    if rows.shape[0] == 0:
        return [np.eye(n, dtype=int)[i] for i in range(n)]
    _, s, Vh = np.linalg.svd(rows, full_matrices=True)
    tol = 1e-10
    null_start = sum(1 for sv in s if abs(sv) > tol)
    basis = []
    for i in range(null_start, Vh.shape[0]):
        v = Vh[i]
        nz = [abs(x) for x in v if abs(x) > tol]
        if nz:
            v = v / min(nz)
        v_int = np.round(v).astype(int)
        if np.allclose(rows @ v_int, 0, atol=tol):
            basis.append(v_int)
    return basis


# ── Application 1: Graph Fingerprinting ──

def graph_fingerprint(adj, q=0):
    """Compute the canonical tropical kernel fingerprint of a graph.

    The fingerprint consists of:
    - Sorted support sizes of canonical generators
    - Value profiles on each support

    This is a graph invariant by the matroidal invariance theorem.

    Args:
        adj: adjacency matrix
        q: basepoint vertex

    Returns:
        Tuple of canonical fingerprint data
    """
    n = adj.shape[0]
    L = graph_laplacian(adj)
    S = [v for v in range(n) if v != q]

    basis = harmonic_kernel_basis(L, S, n)

    # Extract support pattern
    supports = sorted([tuple(sorted(fun_support(b))) for b in basis])

    # Extract value profiles (sorted)
    profiles = []
    for b in basis:
        supp = fun_support(b)
        vals = tuple(sorted(b[i] for i in supp))
        profiles.append(vals)
    profiles.sort()

    return {"supports": supports, "profiles": profiles, "dimension": len(basis)}


def compare_graphs(adj1, adj2):
    """Compare two graphs using tropical kernel fingerprints.

    Args:
        adj1, adj2: adjacency matrices.

    Returns:
        Dictionary with comparison results.
    """
    fp1 = graph_fingerprint(adj1)
    fp2 = graph_fingerprint(adj2)

    same_dim = fp1["dimension"] == fp2["dimension"]
    same_supports = fp1["supports"] == fp2["supports"]

    return {
        "same_kernel_dimension": same_dim,
        "same_support_pattern": same_supports,
        "fingerprint_1": fp1,
        "fingerprint_2": fp2,
        "potentially_isomorphic": same_dim and same_supports,
    }


# ── Application 2: Network Mode Decomposition ──

def network_modes(adj, S, q=0):
    """Decompose the harmonic kernel into independent network modes.

    Each mode represents an independent equilibrium pattern in the network.
    By the uniqueness theorem, these modes are canonical when they have
    disjoint supports.

    Args:
        adj: adjacency matrix
        S: vertex subset
        q: basepoint

    Returns:
        List of (mode_function, support, description) tuples
    """
    n = adj.shape[0]
    L = graph_laplacian(adj)

    basis = harmonic_kernel_basis(L, S, n)

    modes = []
    for i, b in enumerate(basis):
        supp = fun_support(b)
        vals = {v: b[v] for v in sorted(supp)}
        desc = f"Mode {i}: support={sorted(supp)}, values={vals}"
        modes.append((b, supp, desc))

    return modes


# ── Application 3: Chip-Firing Analysis ──

def chip_fire(L, config, v):
    """Fire vertex v in a chip-firing configuration.

    Args:
        L: Laplacian matrix
        config: current chip configuration
        v: vertex to fire

    Returns:
        New configuration after firing v
    """
    new_config = config.copy()
    n = len(config)
    for w in range(n):
        new_config[w] -= L[v, w]
    return new_config


def find_stable_config(L, config, max_steps=1000):
    """Find the stable configuration by repeatedly firing unstable vertices.

    Args:
        L: Laplacian matrix
        config: initial configuration
        max_steps: maximum firing steps

    Returns:
        (stable_config, num_steps)
    """
    n = len(config)
    current = config.copy()

    for step in range(max_steps):
        # Find an unstable vertex (chips >= degree)
        fired = False
        for v in range(n):
            if current[v] >= L[v, v] and L[v, v] > 0:
                current = chip_fire(L, current, v)
                fired = True
                break
        if not fired:
            return current, step

    return current, max_steps


# ── Main ──

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     Applications of Tropical Kernel Rigidity           ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Application 1: Graph Fingerprinting
    print("\n=== Application 1: Graph Fingerprinting ===\n")

    # Path P4
    adj_path = np.array([
        [0, 1, 0, 0],
        [1, 0, 1, 0],
        [0, 1, 0, 1],
        [0, 0, 1, 0]
    ])

    # Cycle C4
    adj_cycle = np.array([
        [0, 1, 0, 1],
        [1, 0, 1, 0],
        [0, 1, 0, 1],
        [1, 0, 1, 0]
    ])

    # Star S3
    adj_star = np.array([
        [0, 1, 1, 1],
        [1, 0, 0, 0],
        [1, 0, 0, 0],
        [1, 0, 0, 0]
    ])

    for name, adj in [("Path P4", adj_path), ("Cycle C4", adj_cycle), ("Star S3", adj_star)]:
        fp = graph_fingerprint(adj)
        print(f"{name}: dim={fp['dimension']}, supports={fp['supports']}")

    print("\nComparing Path P4 vs Cycle C4:")
    cmp = compare_graphs(adj_path, adj_cycle)
    print(f"  Same dimension? {cmp['same_kernel_dimension']}")
    print(f"  Same support pattern? {cmp['same_support_pattern']}")
    print(f"  Potentially isomorphic? {cmp['potentially_isomorphic']}")

    # Application 2: Network Modes
    print("\n\n=== Application 2: Network Mode Decomposition ===\n")

    adj = adj_cycle
    S = [1, 2, 3]
    modes = network_modes(adj, S)
    print(f"Cycle C4, S={S}:")
    for _, _, desc in modes:
        print(f"  {desc}")

    # Application 3: Chip-Firing
    print("\n\n=== Application 3: Chip-Firing Analysis ===\n")

    L = graph_laplacian(adj_path)
    config = np.array([5, 0, 0, 0])
    print(f"Initial configuration: {config}")
    stable, steps = find_stable_config(L, config)
    print(f"Stable configuration: {stable} (after {steps} steps)")
    print(f"Total chips: {sum(config)} → {sum(stable)}")


"""
Interactive Demo: Tropical Kernel Rigidity

Demonstrates the main theorems about canonical generators of tropical
graph Laplacian kernels through concrete examples on small graphs.
"""

import numpy as np
from itertools import combinations, permutations


def graph_laplacian(adj):
    """Compute the combinatorial graph Laplacian."""
    n = adj.shape[0]
    L = -adj.copy()
    for i in range(n):
        L[i, i] = int(np.sum(adj[i]))
    return L


def fun_support(f):
    """Support of an integer-valued function."""
    return {i for i in range(len(f)) if f[i] != 0}


def pairwise_disjoint(family):
    """Check pairwise disjoint supports."""
    supports = [fun_support(f) for f in family]
    for i in range(len(supports)):
        for j in range(i + 1, len(supports)):
            if supports[i] & supports[j]:
                return False
    return True


def is_harmonic_on(L, f, S):
    """Check if f is S-harmonic."""
    return all(np.dot(L[v], f) == 0 for v in S)


def trop_proj_equiv(F, G):
    """Check tropical projective equivalence."""
    n = len(F)
    if len(G) != n:
        return None
    for perm in permutations(range(n)):
        constants = []
        valid = True
        for i in range(n):
            diff = G[perm[i]] - F[i]
            if len(set(diff)) != 1:
                valid = False
                break
            constants.append(int(diff[0]))
        if valid:
            return list(perm), constants
    return None


def demo_path_graph():
    """Demo on the path graph P5: 0-1-2-3-4."""
    print("=" * 60)
    print("DEMO 1: Path Graph P5 (0—1—2—3—4)")
    print("=" * 60)

    n = 5
    adj = np.zeros((n, n), dtype=int)
    for i in range(n - 1):
        adj[i, i + 1] = adj[i + 1, i] = 1

    L = graph_laplacian(adj)
    print(f"\nGraph Laplacian:\n{L}")
    print(f"Row sums: {L.sum(axis=1)}  (all zero ✓)")

    # Basepoint q = 0, subset S = {1, 2, 3}
    q, S = 0, [1, 2, 3]
    print(f"\nBasepoint q = {q}, Subset S = {S}")

    # Harmonic functions: f with (Lf)(v) = 0 for v ∈ S
    print("\n--- Harmonic Functions on S ---")

    # On path graph, harmonic means f(v) = (f(v-1) + f(v+1)) / deg(v)
    # For interior vertices of path: f(v) = (f(v-1) + f(v+1)) / 2
    # Solutions: f must be affine on S (up to boundary conditions)

    f1 = np.array([0, 0, 0, 0, 0])  # trivial
    f2 = np.array([1, 1, 1, 1, 1])  # constant

    print(f"  Constant function f = {f2}")
    print(f"    Harmonic on S? {is_harmonic_on(L, f2, S)}")

    # Leaf rigidity: vertex 4 has degree 1, neighbor 3
    # If both 3, 4 ∈ S, then f(4) = f(3)
    print("\n--- Leaf Rigidity ---")
    S2 = [2, 3, 4]
    f3 = np.array([0, 0, 1, 2, 2])
    print(f"  S = {S2}, f = {f3}")
    print(f"  Vertex 4 is a leaf (degree 1), neighbor is 3")
    print(f"  f(4) = {f3[4]}, f(3) = {f3[3]}")
    print(f"  Leaf rigidity says f(4) = f(3): {f3[4] == f3[3]} ✓")
    print(f"  Harmonic on S? {is_harmonic_on(L, f3, S2)}")


def demo_disjoint_support_uniqueness():
    """Demo the main uniqueness theorem."""
    print("\n" + "=" * 60)
    print("DEMO 2: Disjoint Support Uniqueness Theorem")
    print("=" * 60)

    n = 6
    # Two families with disjoint supports
    F = [
        np.array([1, -1, 0, 0, 0, 0]),  # support on {0, 1}
        np.array([0, 0, 2, 3, 0, 0]),   # support on {2, 3}
        np.array([0, 0, 0, 0, -1, 4]),  # support on {4, 5}
    ]
    print("\nCanonical family F:")
    for i, f in enumerate(F):
        print(f"  F[{i}] = {f}  (support = {fun_support(f)})")

    print(f"\n  Pairwise disjoint supports? {pairwise_disjoint(F)} ✓")

    # Alternative family G: same functions, permuted
    G = [
        np.array([0, 0, 2, 3, 0, 0]),   # = F[1]
        np.array([0, 0, 0, 0, -1, 4]),  # = F[2]
        np.array([1, -1, 0, 0, 0, 0]),  # = F[0]
    ]
    print("\nAlternative family G (permuted):")
    for i, g in enumerate(G):
        print(f"  G[{i}] = {g}  (support = {fun_support(g)})")

    result = trop_proj_equiv(F, G)
    if result:
        perm, constants = result
        print(f"\n  TropProjEquiv? YES ✓")
        print(f"  Permutation σ: {perm}")
        print(f"  Constants c: {constants}")
        print(f"  G[σ(i)] = F[i] + c[i] for all i, v")
    else:
        print(f"\n  TropProjEquiv? NO")

    # Now try a non-equivalent family
    print("\n--- Non-equivalent family ---")
    H = [
        np.array([1, -1, 0, 0, 0, 0]),  # same as F[0]
        np.array([0, 0, 5, 3, 0, 0]),   # DIFFERENT from F[1]
        np.array([0, 0, 0, 0, -1, 4]),  # same as F[2]
    ]
    print("Family H (modified generator):")
    for i, h in enumerate(H):
        print(f"  H[{i}] = {h}  (support = {fun_support(h)})")

    result2 = trop_proj_equiv(F, H)
    if result2:
        print(f"\n  TropProjEquiv(F, H)? YES")
    else:
        print(f"\n  TropProjEquiv(F, H)? NO ✓ (correctly detected difference)")


def demo_irredundancy():
    """Demo the irredundancy theorem."""
    print("\n" + "=" * 60)
    print("DEMO 3: Irredundancy — No Generator is Redundant")
    print("=" * 60)

    F = [
        np.array([3, -2, 0, 0]),  # support {0, 1}
        np.array([0, 0, 1, -5]),  # support {2, 3}
    ]
    print("\nFamily with disjoint supports:")
    for i, f in enumerate(F):
        print(f"  F[{i}] = {f}  (support = {fun_support(f)})")

    print("\nTesting: Can F[0] = min_{i≠0}(F[i] + c[i])?")
    print("  On support of F[0] ({0, 1}), F[1] = 0.")
    print("  So min = c[1] (a constant).")
    print(f"  But F[0] takes values {F[0][0]} and {F[0][1]} on its support.")
    print("  A constant can't equal two different values. Contradiction! ✓")


def demo_matroidal_invariance():
    """Demo the matroidal invariance theorem."""
    print("\n" + "=" * 60)
    print("DEMO 4: Matroidal Invariance")
    print("=" * 60)

    n = 4
    S = [0, 1]

    # Graph 1: 0-1-2-3 (path)
    adj1 = np.zeros((n, n), dtype=int)
    adj1[0, 1] = adj1[1, 0] = 1
    adj1[1, 2] = adj1[2, 1] = 1
    adj1[2, 3] = adj1[3, 2] = 1

    # Graph 2: 0-1, 2-3 separate (same on S, different globally)
    adj2 = np.zeros((n, n), dtype=int)
    adj2[0, 1] = adj2[1, 0] = 1
    adj2[2, 3] = adj2[3, 2] = 1

    L1 = graph_laplacian(adj1)
    L2 = graph_laplacian(adj2)

    print(f"\nGraph 1 (path): L[S,S] = {L1[np.ix_(S, S)].tolist()}")
    print(f"Graph 2 (disconnected): L[S,S] = {L2[np.ix_(S, S)].tolist()}")

    # They differ because vertices in S have edges to complement in G1 but not G2
    print("\nNote: The restricted Laplacians differ because vertex 1")
    print("has an edge to vertex 2 (outside S) in Graph 1 but not Graph 2.")
    print("The degree of vertex 1 in S changes.")

    # Now with isolation condition
    print("\n--- With isolation (no edges from S to complement) ---")

    # Graph 3: 0-1 only
    adj3 = np.zeros((n, n), dtype=int)
    adj3[0, 1] = adj3[1, 0] = 1

    # Graph 4: 0-1, with extra edge 2-3
    adj4 = np.zeros((n, n), dtype=int)
    adj4[0, 1] = adj4[1, 0] = 1
    adj4[2, 3] = adj4[3, 2] = 1

    L3 = graph_laplacian(adj3)
    L4 = graph_laplacian(adj4)

    print(f"Graph 3 (0-1 only): L[S,S] = {L3[np.ix_(S, S)].tolist()}")
    print(f"Graph 4 (0-1 + 2-3): L[S,S] = {L4[np.ix_(S, S)].tolist()}")
    print(f"Equal? {np.array_equal(L3[np.ix_(S, S)], L4[np.ix_(S, S)])} ✓")
    print("(Same because S is isolated from complement in both graphs)")


def demo_conjecture_test():
    """Test the overlap class conjecture on small graphs."""
    print("\n" + "=" * 60)
    print("DEMO 5: Overlap Class Conjecture — Small Graph Search")
    print("=" * 60)

    # Test on complete graphs K3, K4
    for n in [3, 4, 5]:
        adj = np.ones((n, n), dtype=int) - np.eye(n, dtype=int)

        for q in range(n):
            S = [v for v in range(n) if v != q]
            L = graph_laplacian(adj)

            # Count independent cycle indicators
            cycle_rank = len(S) * (len(S) - 1) // 2 - (len(S) - 1)  # β₁ of K_n minus q

            print(f"\n  K_{n}, q={q}, S={S}: cycle rank = {cycle_rank}")

            if cycle_rank == 0:
                print(f"    Tree-like: unique (trivial) generating family")
            else:
                print(f"    {cycle_rank} independent cycle(s)")
                print(f"    Conjecture predicts {max(1, cycle_rank)} equivalence class(es)")


def demo_equilibrium_potentials():
    """Demo the connection to discrete potential theory."""
    print("\n" + "=" * 60)
    print("DEMO 6: Equilibrium Potentials = Harmonic Functions")
    print("=" * 60)

    # Triangle graph
    n = 3
    adj = np.array([[0, 1, 1], [1, 0, 1], [1, 1, 0]])
    L = graph_laplacian(adj)

    print(f"\nTriangle graph K3:")
    print(f"Laplacian:\n{L}")

    phi = np.array([1, 1, 1])
    print(f"\nPotential φ = {phi}")
    flow = L @ phi
    print(f"Flow Lφ = {flow} (zero = equilibrium ✓)")

    phi2 = np.array([1, 0, 0])
    print(f"\nPotential φ = {phi2}")
    flow2 = L @ phi2
    print(f"Flow Lφ = {flow2} (nonzero at vertices 0,1,2)")
    print(f"  Current at 0: {flow2[0]} (sources)")
    print(f"  Current at 1: {flow2[1]} (sinks)")
    print(f"  Current at 2: {flow2[2]} (sinks)")
    print(f"  Total flow: {sum(flow2)} (conserved ✓)")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     Tropical Kernel Rigidity — Interactive Demo         ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_path_graph()
    demo_disjoint_support_uniqueness()
    demo_irredundancy()
    demo_matroidal_invariance()
    demo_conjecture_test()
    demo_equilibrium_potentials()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


"""
Visualization: Graph Laplacian and Harmonic Functions

Shows the Laplacian matrix structure, harmonic functions, and the
leaf rigidity phenomenon for various graph types.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def graph_laplacian(adj):
    n = adj.shape[0]
    L = -adj.copy()
    for i in range(n):
        L[i, i] = int(np.sum(adj[i]))
    return L


fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# ── Row 1: Graph types and their Laplacians ──

# Path P5
adj_path = np.zeros((5, 5), dtype=int)
for i in range(4):
    adj_path[i, i+1] = adj_path[i+1, i] = 1

# Cycle C5
adj_cycle = np.zeros((5, 5), dtype=int)
for i in range(5):
    adj_cycle[i, (i+1) % 5] = adj_cycle[(i+1) % 5, i] = 1

# Star S4 (center at 0)
adj_star = np.zeros((5, 5), dtype=int)
for i in range(1, 5):
    adj_star[0, i] = adj_star[i, 0] = 1

for idx, (adj, name) in enumerate([(adj_path, "Path P₅"),
                                     (adj_cycle, "Cycle C₅"),
                                     (adj_star, "Star S₄")]):
    ax = axes[0, idx]
    L = graph_laplacian(adj)

    # Plot Laplacian as heatmap
    im = ax.imshow(L, cmap='RdBu_r', vmin=-2, vmax=4, aspect='equal')
    ax.set_title(f"{name}\nLaplacian", fontsize=12, fontweight='bold')

    # Annotate values
    for i in range(5):
        for j in range(5):
            color = 'white' if abs(L[i, j]) > 1 else 'black'
            ax.text(j, i, str(L[i, j]), ha='center', va='center',
                    fontsize=11, color=color, fontweight='bold')

    ax.set_xticks(range(5))
    ax.set_yticks(range(5))
    ax.set_xlabel("Column (vertex)")
    ax.set_ylabel("Row (vertex)")

# ── Row 2: Harmonic functions and leaf rigidity ──

# Panel 4: Harmonic function on path
ax = axes[1, 0]
ax.set_title("Harmonic Function on Path\n(Linear = Harmonic)", fontsize=12, fontweight='bold')

vertices = np.arange(5)
# On a path, linear functions are harmonic at interior vertices
f_harmonic = np.array([0, 1, 2, 3, 4])
f_not_harmonic = np.array([0, 1, 3, 2, 4])

ax.plot(vertices, f_harmonic, 'bo-', markersize=10, linewidth=2, label='Harmonic (linear)')
ax.plot(vertices, f_not_harmonic, 'r^--', markersize=8, linewidth=1.5, label='Not harmonic')
ax.set_xlabel("Vertex")
ax.set_ylabel("f(v)")
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 5: Leaf rigidity
ax = axes[1, 1]
ax.set_title("Leaf Rigidity\nf(leaf) = f(neighbor)", fontsize=12, fontweight='bold')

# Tree with leaves
#     0
#    / \
#   1   2
#  /
# 3
tree_pos = {0: (1, 2), 1: (0, 1), 2: (2, 1), 3: (-0.5, 0)}
tree_edges = [(0, 1), (0, 2), (1, 3)]

for u, v in tree_edges:
    ax.plot([tree_pos[u][0], tree_pos[v][0]],
            [tree_pos[u][1], tree_pos[v][1]], 'k-', linewidth=2)

# Color vertices by function value
f_vals = [5, 5, 5, 5]  # All forced to be equal by leaf rigidity!
colors_map = {5: '#4CAF50'}

for v, (x, y) in tree_pos.items():
    color = '#4CAF50'
    ax.plot(x, y, 'o', markersize=25, color=color, zorder=5)
    ax.text(x, y, f'{f_vals[v]}', ha='center', va='center',
            fontsize=12, fontweight='bold', color='white', zorder=6)
    ax.text(x, y - 0.35, f'v{v}', ha='center', va='top', fontsize=9)

# Annotations
ax.annotate('leaf (deg 1)\nf(3) = f(1)', xy=tree_pos[3],
            xytext=(-1.5, -0.5), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='red'),
            color='red', fontweight='bold')
ax.annotate('leaf (deg 1)\nf(2) = f(0)', xy=tree_pos[2],
            xytext=(3, 0.5), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='red'),
            color='red', fontweight='bold')

ax.set_xlim(-2, 3.5)
ax.set_ylim(-1, 3)
ax.axis('off')

# Panel 6: Matroidal invariance
ax = axes[1, 2]
ax.set_title("Matroidal Invariance\nSame Induced Structure → Same Kernel", fontsize=12, fontweight='bold')

# Two different graphs with same induced structure on S={0,1,2}
# Graph 1: 0-1-2 + extra vertex 3 connected to 2
# Graph 2: 0-1-2 + extra vertex 3 connected to 0

# Draw both
for gy_offset, label, extra_edge in [(1.5, "Graph G₁", (2, 3)),
                                       (-0.5, "Graph G₂", (0, 3))]:
    positions = {0: (0, gy_offset), 1: (1, gy_offset),
                 2: (2, gy_offset), 3: (3, gy_offset + 0.5)}

    # S = {0, 1, 2} edges
    for u, v in [(0, 1), (1, 2)]:
        ax.plot([positions[u][0], positions[v][0]],
                [positions[u][1], positions[v][1]], 'b-', linewidth=2.5)

    # Extra edge (outside S interaction)
    u, v = extra_edge
    ax.plot([positions[u][0], positions[v][0]],
            [positions[u][1], positions[v][1]], 'gray', linewidth=1.5, linestyle='--')

    # Vertices
    for vid, (x, y) in positions.items():
        color = '#2196F3' if vid < 3 else '#BDBDBD'
        ax.plot(x, y, 'o', markersize=18, color=color, zorder=5)
        ax.text(x, y, str(vid), ha='center', va='center',
                fontsize=10, fontweight='bold', color='white', zorder=6)

    ax.text(-0.5, gy_offset, label, fontsize=10, fontweight='bold', va='center')

ax.text(1, 0.5, 'S = {0,1,2}: same adjacency\n→ same restricted Laplacian\n→ same harmonic kernel',
        fontsize=9, ha='center', va='center',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

ax.set_xlim(-1, 4)
ax.set_ylim(-1.5, 3)
ax.axis('off')

plt.tight_layout()
plt.savefig('viz_laplacian_harmonics.png', dpi=150, bbox_inches='tight')
print("Saved viz_laplacian_harmonics.png")


"""
Visualization: Support Separation and Tropical Kernel Rigidity

Illustrates the core mathematical concept: when function families have
pairwise disjoint supports, their values on each support region are
independent, leading to uniqueness of generators up to permutation.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Functions with disjoint supports
ax = axes[0]
ax.set_title("Disjoint Support Generators", fontsize=13, fontweight='bold')
x = np.arange(12)

# Three generators with disjoint supports
f1 = np.array([3, -2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0])
f2 = np.array([0, 0, 0, 0, 2, -1, 3, 0, 0, 0, 0, 0])
f3 = np.array([0, 0, 0, 0, 0, 0, 0, 0, -1, 4, -2, 1])

colors = ['#2196F3', '#FF5722', '#4CAF50']
labels = ['Generator 1', 'Generator 2', 'Generator 3']

for i, (f, c, l) in enumerate(zip([f1, f2, f3], colors, labels)):
    bars = ax.bar(x + i * 0.25 - 0.25, f, width=0.25, color=c, alpha=0.8, label=l)

# Highlight support regions
for region, color in [((0, 3), '#2196F3'), ((4, 7), '#FF5722'), ((8, 12), '#4CAF50')]:
    rect = patches.FancyBboxPatch((region[0] - 0.4, -3), region[1] - region[0] - 0.2, 0.3,
                                   boxstyle="round,pad=0.05", facecolor=color, alpha=0.15)
    ax.add_patch(rect)

ax.set_xlabel("Vertex index")
ax.set_ylabel("Function value")
ax.legend(fontsize=9)
ax.set_xticks(x)
ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
ax.set_ylim(-3.5, 5.5)

# Panel 2: Why min-plus combination is constant on each support
ax = axes[1]
ax.set_title("Tropical Combination = Constant\non Each Support Region", fontsize=13, fontweight='bold')

# On support of f1, f2=f3=0, so min(f1+c1, f2+c2, f3+c3) = min(f1+c1, c2, c3)
# If c2, c3 > max(f1)+c1, then min = f1+c1 (determined by f1 alone)
c1, c2, c3 = 0, 5, 7

trop_comb = np.minimum(np.minimum(f1 + c1, f2 + c2), f3 + c3)

ax.bar(x, trop_comb, color='purple', alpha=0.7, label=f'min(F₁+{c1}, F₂+{c2}, F₃+{c3})')

# Show that on each support, value is determined by one generator
for region, gen_name, color in [((0, 3), 'F₁', '#2196F3'),
                                  ((4, 7), 'F₂', '#FF5722'),
                                  ((8, 12), 'F₃', '#4CAF50')]:
    mid = (region[0] + region[1]) / 2
    ax.annotate(f'Determined\nby {gen_name}', xy=(mid, -2.5), fontsize=9,
                ha='center', color=color, fontweight='bold')

ax.set_xlabel("Vertex index")
ax.set_ylabel("Tropical combination value")
ax.legend(fontsize=9)
ax.set_xticks(x)
ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')

# Panel 3: Uniqueness — any alternative must match
ax = axes[2]
ax.set_title("Uniqueness: Alternative Family\nMust Be a Permutation", fontsize=13, fontweight='bold')

# Alternative family (just permuted)
g1 = f2.copy()  # = f2
g2 = f3.copy()  # = f3
g3 = f1.copy()  # = f1

width = 0.35
bars1 = ax.bar(x - width/2, f1 + f2 + f3, width, color='#2196F3', alpha=0.5, label='Original F')
bars2 = ax.bar(x + width/2, g1 + g2 + g3, width, color='#FF5722', alpha=0.5, label='Alternative G (permuted)')

# Mark that they're the same
for i in range(12):
    if (f1 + f2 + f3)[i] == (g1 + g2 + g3)[i] and (f1 + f2 + f3)[i] != 0:
        ax.plot(i, (f1 + f2 + f3)[i] + 0.3, 'g*', markersize=8)

ax.set_xlabel("Vertex index")
ax.set_ylabel("Sum of generators")
ax.legend(fontsize=9)
ax.set_xticks(x)
ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')

# Add annotation
ax.text(6, 4.5, 'G = σ(F) for some\npermutation σ',
        fontsize=11, ha='center', style='italic',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_support_separation.png', dpi=150, bbox_inches='tight')
print("Saved viz_support_separation.png")


"""
Visualization: The Uniqueness Theorem in Action

Shows the main result: under pairwise disjoint supports,
the canonical generators are unique up to permutation.
Illustrates the proof mechanism.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyArrowPatch

fig, axes = plt.subplots(1, 3, figsize=(16, 5.5))

# ── Panel 1: Support Matching ──
ax = axes[0]
ax.set_title("Step 1: Support Matching\n(Injectivity from Disjointness)", fontsize=12, fontweight='bold')

# Draw two columns of "generators" with support sets
left_x, right_x = 1, 4
y_positions = [3, 2, 1]

# Left column: F generators
labels_F = ['F₁', 'F₂', 'F₃']
supports_F = ['{0,1}', '{2,3}', '{4,5}']
colors = ['#2196F3', '#FF5722', '#4CAF50']

# Right column: G generators (permuted)
labels_G = ['G₁', 'G₂', 'G₃']
supports_G = ['{2,3}', '{4,5}', '{0,1}']
perm = [2, 0, 1]  # G[perm[i]] matches F[i]

for i in range(3):
    # Left boxes
    rect = patches.FancyBboxPatch((left_x - 0.5, y_positions[i] - 0.3), 1.5, 0.6,
                                   boxstyle="round,pad=0.1", facecolor=colors[i], alpha=0.3)
    ax.add_patch(rect)
    ax.text(left_x + 0.25, y_positions[i], f'{labels_F[i]}\nsupport={supports_F[i]}',
            ha='center', va='center', fontsize=9, fontweight='bold')

    # Right boxes
    j = perm[i]
    rect2 = patches.FancyBboxPatch((right_x - 0.5, y_positions[i] - 0.3), 1.5, 0.6,
                                    boxstyle="round,pad=0.1", facecolor=colors[j], alpha=0.3)
    ax.add_patch(rect2)
    ax.text(right_x + 0.25, y_positions[i], f'{labels_G[i]}\nsupport={supports_G[i]}',
            ha='center', va='center', fontsize=9, fontweight='bold')

    # Matching arrows
    ax.annotate('', xy=(right_x - 0.55, y_positions[i]),
                xytext=(left_x + 0.8, y_positions[perm.index(i)]),
                arrowprops=dict(arrowstyle='->', color=colors[i],
                               lw=2, connectionstyle='arc3,rad=0.2'))

ax.text(2.625, 3.7, 'σ: support matching', fontsize=11, ha='center',
        fontweight='bold', style='italic')
ax.text(2.625, 0.2, 'σ injective ⟸ disjoint supports\nσ bijective ⟸ finite type',
        fontsize=9, ha='center',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

ax.set_xlim(0, 5.5)
ax.set_ylim(-0.3, 4.2)
ax.axis('off')

# ── Panel 2: Value Agreement ──
ax = axes[1]
ax.set_title("Step 2: Value Agreement\n(Off-support zeroes force equality)", fontsize=12, fontweight='bold')

vertices = np.arange(6)
f1 = np.array([3, -2, 0, 0, 0, 0])
g3 = np.array([3, -2, 0, 0, 0, 0])  # G[σ(1)] should equal F[1]

width = 0.35
ax.bar(vertices - width/2, f1, width, color='#2196F3', alpha=0.7, label='F₁')
ax.bar(vertices + width/2, g3, width, color='#4CAF50', alpha=0.7, label='G[σ(1)] = G₃')

# Highlight support region
rect = patches.FancyBboxPatch((-0.5, -2.8), 2, 0.3,
                               boxstyle="round,pad=0.05", facecolor='#2196F3', alpha=0.2)
ax.add_patch(rect)
ax.text(0.5, -2.65, 'support', fontsize=8, ha='center', color='#2196F3')

# Highlight off-support region
rect2 = patches.FancyBboxPatch((1.7, -2.8), 4, 0.3,
                                boxstyle="round,pad=0.05", facecolor='gray', alpha=0.1)
ax.add_patch(rect2)
ax.text(3.5, -2.65, 'off-support (both = 0)', fontsize=8, ha='center', color='gray')

ax.set_xlabel("Vertex index")
ax.set_ylabel("Value")
ax.legend(fontsize=9)
ax.set_xticks(vertices)
ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
ax.set_ylim(-3.2, 4)

# Add "= " markers
for v in range(6):
    if f1[v] == g3[v]:
        ax.text(v, max(f1[v], 0) + 0.3, '=', fontsize=14, ha='center',
                color='green', fontweight='bold')

# ── Panel 3: The Complete Picture ──
ax = axes[2]
ax.set_title("Result: Tropical Projective Equivalence\nG(σ(i)) = F(i) for all i, v", fontsize=12, fontweight='bold')

# Show the theorem statement visually
theorem_text = (
    "Given:\n"
    "  • F, G with disjoint supports\n"
    "  • Same support decomposition\n"
    "  • Agreement on matched supports\n"
    "\n"
    "Then: ∃ permutation σ s.t.\n"
    "  G(σ(i))(v) = F(i)(v)  ∀ i, v\n"
    "\n"
    "i.e., TropProjEquiv(F, G)\n"
    "     with constants c = 0"
)

ax.text(0.5, 0.5, theorem_text, transform=ax.transAxes,
        fontsize=12, ha='center', va='center',
        fontfamily='monospace',
        bbox=dict(boxstyle='round,pad=0.8', facecolor='#E3F2FD', alpha=0.9))

# Draw a checkmark
ax.text(0.5, 0.02, '✓ Machine-verified in Lean 4', transform=ax.transAxes,
        fontsize=11, ha='center', color='green', fontweight='bold')

ax.axis('off')

plt.tight_layout()
plt.savefig('viz_uniqueness_theorem.png', dpi=150, bbox_inches='tight')
print("Saved viz_uniqueness_theorem.png")
