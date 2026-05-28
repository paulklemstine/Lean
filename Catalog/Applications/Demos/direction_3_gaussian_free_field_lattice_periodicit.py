#!/usr/bin/env python3
"""
Applications of GFF–Resistance Theory on Finite Graphs

Real-world applications demonstrating the mathematical framework:
1. Electrical network analysis via effective resistance
2. Random walk commute times from resistance
3. Graph clustering via resistance embedding
4. Sensor network placement optimization
"""

import numpy as np
from typing import List, Tuple


# ============================================================
# Core Infrastructure (self-contained)
# ============================================================

def weighted_laplacian(n: int, edges: List[Tuple[int, int, float]]) -> np.ndarray:
    L = np.zeros((n, n))
    for i, j, w in edges:
        L[i, i] += w; L[j, j] += w
        L[i, j] -= w; L[j, i] -= w
    return L

def effective_resistance_matrix(L: np.ndarray) -> np.ndarray:
    Lp = np.linalg.pinv(L)
    diag = np.diag(Lp)
    return diag[:, None] + diag[None, :] - 2 * Lp

def covariance_kernel(R: np.ndarray, base: int = 0) -> np.ndarray:
    Rb = R[:, base]
    return (Rb[:, None] + Rb[None, :] - R) / 2


# ============================================================
# Application 1: Electrical Network Analysis
# ============================================================

def analyze_electrical_network():
    """Analyze a simple resistor network using effective resistance.

    Consider a Wheatstone bridge circuit:
        0 --- 1
        |\ /|
        | X  |
        |/ \|
        2 --- 3

    All resistors have resistance 1 Ω (conductance/weight = 1).
    """
    print("=" * 60)
    print("APPLICATION 1: Electrical Network Analysis (Wheatstone Bridge)")
    print("=" * 60)

    edges = [
        (0, 1, 1.0), (0, 2, 1.0), (0, 3, 1.0),
        (1, 2, 1.0), (1, 3, 1.0), (2, 3, 1.0),
    ]
    L = weighted_laplacian(4, edges)
    R = effective_resistance_matrix(L)

    print("\n  Wheatstone bridge (K_4 with unit weights):")
    print(f"  Laplacian:\n{np.array2string(L, prefix='  ')}")
    print(f"\n  Effective resistance matrix:")
    print(f"{np.array2string(R, prefix='  ', precision=4)}")
    print(f"\n  R(0,1) = {R[0,1]:.4f} Ω (all pairs equal by symmetry)")
    print(f"  For K_n with unit weights: R_eff = 2/n for all pairs")
    print(f"  Here n=4: R_eff = 2/4 = 0.5 ✓")

    # Power grid example
    print("\n  --- Power Grid Example ---")
    # Simple 5-node power grid with varying line impedances
    grid_edges = [
        (0, 1, 2.0),   # Heavy line
        (1, 2, 1.0),
        (2, 3, 0.5),   # Weak line
        (3, 4, 1.0),
        (0, 4, 1.5),
        (1, 3, 0.8),   # Cross-connection
    ]
    L_grid = weighted_laplacian(5, grid_edges)
    R_grid = effective_resistance_matrix(L_grid)
    print(f"  5-node power grid effective resistances:")
    for i in range(5):
        for j in range(i+1, 5):
            print(f"    R({i},{j}) = {R_grid[i,j]:.4f} — "
                  f"{'weak' if R_grid[i,j] > 1.0 else 'strong'} connection")
    print()


# ============================================================
# Application 2: Random Walk Commute Times
# ============================================================

def analyze_commute_times():
    """Compute expected commute times from effective resistance.

    The commute time theorem states:
        E[T_{ij}] = 2 · |E| · R_eff(i,j)

    where |E| is the total weight of all edges.
    """
    print("=" * 60)
    print("APPLICATION 2: Random Walk Commute Times")
    print("=" * 60)

    # Cycle graph C_6
    n = 6
    edges = [(k, (k+1) % n, 1.0) for k in range(n)]
    L = weighted_laplacian(n, edges)
    R = effective_resistance_matrix(L)
    total_weight = sum(w for _, _, w in edges)

    print(f"\n  Cycle C_{n} (unit weights, total weight = {total_weight}):")
    print(f"  Expected commute times E[T_ij] = 2 · {total_weight:.0f} · R(i,j):")
    for d in range(1, n // 2 + 1):
        r = R[0, d]
        commute = 2 * total_weight * r
        print(f"    Distance {d}: R = {r:.4f}, E[T] = {commute:.2f} steps")

    # Star graph
    print(f"\n  Star graph S_5 (center = 0):")
    star_edges = [(0, k, 1.0) for k in range(1, 6)]
    L_star = weighted_laplacian(6, star_edges)
    R_star = effective_resistance_matrix(L_star)
    total_star = sum(w for _, _, w in star_edges)
    print(f"  R(center, leaf) = {R_star[0,1]:.4f}")
    print(f"  R(leaf, leaf) = {R_star[1,2]:.4f}")
    print(f"  E[T(center,leaf)] = {2 * total_star * R_star[0,1]:.2f} steps")
    print(f"  E[T(leaf,leaf)] = {2 * total_star * R_star[1,2]:.2f} steps")
    print()


# ============================================================
# Application 3: Graph Clustering via Resistance Embedding
# ============================================================

def resistance_clustering():
    """Use effective resistance as a distance metric for graph clustering.

    The key insight: vertices in the same cluster have low effective
    resistance between them (many redundant paths), while inter-cluster
    resistance is high.
    """
    print("=" * 60)
    print("APPLICATION 3: Graph Clustering via Resistance Distance")
    print("=" * 60)

    # Two clusters connected by a single edge
    # Cluster A: vertices 0,1,2 (complete)
    # Cluster B: vertices 3,4,5 (complete)
    # Bridge: edge (2,3) with low weight
    edges = []
    # Cluster A (strong internal connectivity)
    for i in range(3):
        for j in range(i+1, 3):
            edges.append((i, j, 5.0))
    # Cluster B
    for i in range(3, 6):
        for j in range(i+1, 6):
            edges.append((i, j, 5.0))
    # Weak bridge
    edges.append((2, 3, 0.1))

    L = weighted_laplacian(6, edges)
    R = effective_resistance_matrix(L)

    print(f"\n  Two-cluster graph (3+3 vertices, weak bridge):")
    print(f"  Intra-cluster A resistance:  R(0,1) = {R[0,1]:.4f}")
    print(f"  Intra-cluster B resistance:  R(3,4) = {R[3,4]:.4f}")
    print(f"  Inter-cluster resistance:    R(0,3) = {R[0,3]:.4f}")
    print(f"  Inter-cluster resistance:    R(1,4) = {R[1,4]:.4f}")
    print(f"\n  Ratio inter/intra: {R[0,3] / R[0,1]:.1f}x → clear cluster separation")

    # Simple k-means-like clustering on resistance distances
    threshold = (R[0, 1] + R[0, 3]) / 2
    clusters = {0: [0]}
    for v in range(1, 6):
        assigned = False
        for rep in clusters:
            if R[v, rep] < threshold:
                clusters[rep].append(v)
                assigned = True
                break
        if not assigned:
            clusters[v] = [v]
    print(f"  Threshold: {threshold:.4f}")
    print(f"  Clusters found: {list(clusters.values())}")
    print()


# ============================================================
# Application 4: Sensor Network Placement
# ============================================================

def sensor_placement():
    """Optimize sensor placement using GFF covariance structure.

    In a sensor network modeled as a graph, the covariance kernel from
    effective resistance tells us how much information one sensor provides
    about another location. Low covariance means independent information.
    """
    print("=" * 60)
    print("APPLICATION 4: Sensor Network Placement via GFF Covariance")
    print("=" * 60)

    # Grid-like sensor network (3×3)
    edges = [
        # Horizontal
        (0,1,1), (1,2,1), (3,4,1), (4,5,1), (6,7,1), (7,8,1),
        # Vertical
        (0,3,1), (1,4,1), (2,5,1), (3,6,1), (4,7,1), (5,8,1),
    ]
    L = weighted_laplacian(9, edges)
    R = effective_resistance_matrix(L)
    K = covariance_kernel(R, base=0)

    print(f"\n  3×3 grid sensor network:")
    print(f"  Layout:  0-1-2")
    print(f"           | | |")
    print(f"           3-4-5")
    print(f"           | | |")
    print(f"           6-7-8")

    print(f"\n  Effective resistance from corner (0) to each vertex:")
    for v in range(9):
        row, col = v // 3, v % 3
        print(f"    Vertex {v} ({row},{col}): R = {R[0,v]:.4f}")

    # Find most independent pair (highest resistance)
    max_r, best_pair = 0, (0, 0)
    for i in range(9):
        for j in range(i+1, 9):
            if R[i,j] > max_r:
                max_r, best_pair = R[i,j], (i, j)
    print(f"\n  Most independent pair: vertices {best_pair} "
          f"with R = {max_r:.4f}")
    print(f"  → Place first two sensors here for maximum coverage")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  GFF-RESISTANCE THEORY: REAL-WORLD APPLICATIONS")
    print("=" * 60 + "\n")

    analyze_electrical_network()
    analyze_commute_times()
    resistance_clustering()
    sensor_placement()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Gaussian Free Field on Finite Graphs — Interactive Demonstration

This demo constructs cycle graphs C_n with optional edge lengths, computes
reduced Laplacian determinants, pseudoinverse covariance / effective resistance
matrices, and compares numerical partition prefactors against the determinant formula.

It also tests the subdivision invariance conjecture on marked vertices.
"""

import numpy as np
from typing import Optional

# ============================================================
# Core Graph Constructions
# ============================================================

def cycle_laplacian(n: int, weights: Optional[np.ndarray] = None) -> np.ndarray:
    """Construct the weighted Laplacian for the cycle graph C_n.

    Args:
        n: Number of vertices (≥ 3).
        weights: Optional array of n edge weights w_0, ..., w_{n-1},
                 where w_k is the weight of edge (k, k+1 mod n).
                 Defaults to unit weights.
    Returns:
        n×n weighted Laplacian matrix.
    """
    if weights is None:
        weights = np.ones(n)
    L = np.zeros((n, n))
    for k in range(n):
        i, j = k, (k + 1) % n
        L[i, i] += weights[k]
        L[j, j] += weights[k]
        L[i, j] -= weights[k]
        L[j, i] -= weights[k]
    return L


def reduced_laplacian(L: np.ndarray, pin: int = 0) -> np.ndarray:
    """Delete row `pin` and column `pin` from L to get the reduced Laplacian."""
    idx = [i for i in range(L.shape[0]) if i != pin]
    return L[np.ix_(idx, idx)]


def pseudoinverse_laplacian(L: np.ndarray) -> np.ndarray:
    """Moore-Penrose pseudoinverse of L."""
    return np.linalg.pinv(L)


def effective_resistance_matrix(L: np.ndarray) -> np.ndarray:
    """Compute the effective resistance matrix R_{ij} = L⁺_{ii} + L⁺_{jj} - 2L⁺_{ij}."""
    Lp = pseudoinverse_laplacian(L)
    n = L.shape[0]
    R = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            R[i, j] = Lp[i, i] + Lp[j, j] - 2 * Lp[i, j]
    return R


def covariance_from_resistance(R: np.ndarray, base: int = 0) -> np.ndarray:
    """Compute covariance kernel K(i,j) = (R(i,b) + R(j,b) - R(i,j))/2."""
    n = R.shape[0]
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K[i, j] = (R[i, base] + R[j, base] - R[i, j]) / 2
    return K


def gff_partition_prefactor(n_red: int, det_red: float) -> float:
    """Compute Z = (2π)^(n_red/2) / √(det L_red)."""
    return (2 * np.pi) ** (n_red / 2) / np.sqrt(det_red)


def cyclic_distance(i: int, j: int, n: int) -> int:
    """Cyclic graph distance on C_n."""
    d = abs(i - j)
    return min(d, n - d)


def cycle_effective_resistance_formula(n: int, i: int, j: int) -> float:
    """Exact formula: R_eff(i,j) = d(i,j)*(n - d(i,j))/n on unit cycle C_n."""
    d = cyclic_distance(i, j, n)
    return d * (n - d) / n


# ============================================================
# Demonstrations
# ============================================================

def demo_cycle_determinants():
    """Demonstrate that det(L_red) = n for unit cycle graphs."""
    print("=" * 60)
    print("DEMO 1: Reduced Laplacian Determinant = n for Cycle Graphs")
    print("=" * 60)
    for n in range(3, 11):
        L = cycle_laplacian(n)
        Lr = reduced_laplacian(L)
        det = np.linalg.det(Lr)
        print(f"  C_{n}: det(L_red) = {det:.6f}  (expected {n})")
    print()


def demo_partition_prefactor():
    """Demonstrate partition function prefactor computation."""
    print("=" * 60)
    print("DEMO 2: Partition Function Prefactor")
    print("=" * 60)
    for n in range(3, 9):
        L = cycle_laplacian(n)
        Lr = reduced_laplacian(L)
        det = np.linalg.det(Lr)
        Z = gff_partition_prefactor(n - 1, det)
        print(f"  C_{n}: Z = (2π)^({n-1}/2) / √{det:.2f} = {Z:.6f}")
    print()


def demo_effective_resistance():
    """Demonstrate effective resistance matches the exact formula on cycles."""
    print("=" * 60)
    print("DEMO 3: Effective Resistance on Cycle Graphs")
    print("=" * 60)
    for n in [4, 5, 6]:
        L = cycle_laplacian(n)
        R = effective_resistance_matrix(L)
        print(f"\n  C_{n} effective resistance matrix (numerical):")
        for i in range(n):
            row = "    " + "  ".join(f"{R[i,j]:.4f}" for j in range(n))
            print(row)
        print(f"  C_{n} effective resistance matrix (formula):")
        for i in range(n):
            row = "    " + "  ".join(
                f"{cycle_effective_resistance_formula(n, i, j):.4f}" for j in range(n)
            )
            print(row)
        max_err = max(
            abs(R[i, j] - cycle_effective_resistance_formula(n, i, j))
            for i in range(n) for j in range(n)
        )
        print(f"  Max error: {max_err:.2e}")
    print()


def demo_covariance_resistance_bridge():
    """Demonstrate that Var(φ_i - φ_j) = R_eff(i,j)."""
    print("=" * 60)
    print("DEMO 4: Covariance–Resistance Bridge (Flagship Theorem)")
    print("=" * 60)
    n = 5
    L = cycle_laplacian(n)
    R = effective_resistance_matrix(L)
    K = covariance_from_resistance(R, base=0)
    print(f"\n  C_{n} covariance kernel K (base=0):")
    for i in range(n):
        row = "    " + "  ".join(f"{K[i,j]:.4f}" for j in range(n))
        print(row)
    print(f"\n  Var(φ_i - φ_j) = K(i,i) + K(j,j) - 2K(i,j)  vs  R(i,j):")
    for i in range(n):
        for j in range(i + 1, n):
            var_diff = K[i, i] + K[j, j] - 2 * K[i, j]
            print(f"    ({i},{j}): Var = {var_diff:.6f}, R = {R[i,j]:.6f}, "
                  f"diff = {abs(var_diff - R[i,j]):.2e}")
    print()


def demo_subdivision_invariance():
    """Test the subdivision invariance conjecture.

    Conjecture: Subdividing an edge of a weighted graph (replacing one edge
    of weight w with two edges of weights chosen to preserve the total
    resistance) leaves the effective resistance between original vertices
    invariant.
    """
    print("=" * 60)
    print("DEMO 5: Subdivision Invariance Conjecture Test")
    print("=" * 60)

    # Original: C_4 with unit weights
    n = 4
    L_orig = cycle_laplacian(n)
    R_orig = effective_resistance_matrix(L_orig)

    # Subdivide edge (0,1): replace with two edges via new vertex 4
    # Original edge has resistance 1 (weight 1).
    # Subdivide into resistance 0.3 and 0.7 (weights 1/0.3 and 1/0.7)
    n_sub = 5
    L_sub = np.zeros((n_sub, n_sub))
    # Edge (0,4) with weight 1/0.3
    w1 = 1 / 0.3
    L_sub[0, 0] += w1; L_sub[4, 4] += w1
    L_sub[0, 4] -= w1; L_sub[4, 0] -= w1
    # Edge (4,1) with weight 1/0.7
    w2 = 1 / 0.7
    L_sub[4, 4] += w2; L_sub[1, 1] += w2
    L_sub[4, 1] -= w2; L_sub[1, 4] -= w2
    # Edge (1,2) with weight 1
    L_sub[1, 1] += 1; L_sub[2, 2] += 1
    L_sub[1, 2] -= 1; L_sub[2, 1] -= 1
    # Edge (2,3) with weight 1
    L_sub[2, 2] += 1; L_sub[3, 3] += 1
    L_sub[2, 3] -= 1; L_sub[3, 2] -= 1
    # Edge (3,0) with weight 1
    L_sub[3, 3] += 1; L_sub[0, 0] += 1
    L_sub[3, 0] -= 1; L_sub[0, 3] -= 1

    R_sub = effective_resistance_matrix(L_sub)

    print("\n  Original C_4 resistance between vertices 0-3:")
    for i in range(4):
        for j in range(i + 1, 4):
            print(f"    R_orig({i},{j}) = {R_orig[i,j]:.6f}")

    print("\n  After subdividing edge (0,1) → (0,4,1):")
    for i in range(4):
        for j in range(i + 1, 4):
            print(f"    R_sub({i},{j})  = {R_sub[i,j]:.6f}  "
                  f"diff = {abs(R_sub[i,j] - R_orig[i,j]):.2e}")

    max_err = max(
        abs(R_sub[i, j] - R_orig[i, j])
        for i in range(4) for j in range(i + 1, 4)
    )
    print(f"\n  Max resistance change on original vertices: {max_err:.2e}")
    print(f"  Conjecture {'SUPPORTED' if max_err < 1e-10 else 'REFUTED'} "
          f"(tolerance 1e-10)")
    print()


def demo_gauge_invariance():
    """Demonstrate gauge invariance: E(x + c·1) = E(x)."""
    print("=" * 60)
    print("DEMO 6: Gauge Invariance of GFF Energy")
    print("=" * 60)
    n = 5
    L = cycle_laplacian(n)
    x = np.random.randn(n)
    for c in [0, 1.0, -3.7, 100.0]:
        xc = x + c
        E_x = x @ L @ x
        E_xc = xc @ L @ xc
        print(f"  c = {c:8.2f}: E(x) = {E_x:.8f}, E(x+c) = {E_xc:.8f}, "
              f"diff = {abs(E_x - E_xc):.2e}")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  GAUSSIAN FREE FIELD ON FINITE GRAPHS")
    print("  Cross-Domain Bridge: Statistical Mechanics ↔ Networks")
    print("=" * 60 + "\n")

    demo_cycle_determinants()
    demo_partition_prefactor()
    demo_effective_resistance()
    demo_covariance_resistance_bridge()
    demo_subdivision_invariance()
    demo_gauge_invariance()

    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: GFF Covariance Kernel and Partition Function

Top row: Covariance kernels K(i,j) for cycle graphs with different pinned vertices.
Bottom left: Partition function prefactor Z vs graph size n.
Bottom right: GFF energy landscape showing gauge invariance (energy vs shift constant).

This visualization demonstrates the statistical mechanics ↔ spectral graph theory bridge:
the covariance structure is entirely determined by the Laplacian pseudoinverse.
"""

import numpy as np
import matplotlib.pyplot as plt


def cycle_laplacian(n):
    L = np.zeros((n, n))
    for k in range(n):
        i, j = k, (k + 1) % n
        L[i, i] += 1; L[j, j] += 1
        L[i, j] -= 1; L[j, i] -= 1
    return L


def effective_resistance_matrix(L):
    Lp = np.linalg.pinv(L)
    diag = np.diag(Lp)
    return diag[:, None] + diag[None, :] - 2 * Lp


def covariance_kernel(R, base=0):
    Rb = R[:, base]
    return (Rb[:, None] + Rb[None, :] - R) / 2


def reduced_laplacian(L, pin=0):
    idx = [i for i in range(L.shape[0]) if i != pin]
    return L[np.ix_(idx, idx)]


fig = plt.figure(figsize=(14, 10))
fig.suptitle("Gaussian Free Field: Covariance Structure and Partition Function",
             fontsize=14, fontweight='bold')

# Top row: Covariance kernels for C_8 with different base vertices
n = 8
L = cycle_laplacian(n)
R = effective_resistance_matrix(L)

for idx, base in enumerate([0, 2, 4]):
    ax = fig.add_subplot(2, 3, idx + 1)
    K = covariance_kernel(R, base=base)
    im = ax.imshow(K, cmap='RdBu_r', interpolation='nearest',
                   vmin=-K.max(), vmax=K.max())
    ax.set_title(f"$C_8$ Covariance\n(base = {base})", fontsize=11)
    ax.set_xlabel("$j$")
    if idx == 0:
        ax.set_ylabel("$i$")
    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

# Bottom left: Partition function vs n
ax_z = fig.add_subplot(2, 3, 4)
ns = np.arange(3, 25)
Zs = [(2 * np.pi) ** ((n-1) / 2) / np.sqrt(n) for n in ns]
ax_z.semilogy(ns, Zs, 'b-o', markersize=4, linewidth=1.5)
ax_z.set_xlabel("Graph size $n$", fontsize=11)
ax_z.set_ylabel("Partition prefactor $Z$", fontsize=11)
ax_z.set_title("$Z(C_n) = (2\\pi)^{(n-1)/2} / \\sqrt{n}$", fontsize=11)
ax_z.grid(True, alpha=0.3)

# Bottom center: det(L_red) vs n
ax_det = fig.add_subplot(2, 3, 5)
dets = [np.linalg.det(reduced_laplacian(cycle_laplacian(n))) for n in ns]
ax_det.plot(ns, dets, 'r-s', markersize=4, linewidth=1.5, label='Numerical')
ax_det.plot(ns, ns, 'k--', linewidth=1, alpha=0.5, label='$\\det = n$ (exact)')
ax_det.set_xlabel("Graph size $n$", fontsize=11)
ax_det.set_ylabel("$\\det(L_{\\mathrm{red}})$", fontsize=11)
ax_det.set_title("Reduced Laplacian Determinant", fontsize=11)
ax_det.legend(fontsize=9)
ax_det.grid(True, alpha=0.3)

# Bottom right: Gauge invariance demonstration
ax_gauge = fig.add_subplot(2, 3, 6)
n_gauge = 6
L_gauge = cycle_laplacian(n_gauge)
np.random.seed(42)
x = np.random.randn(n_gauge)
cs = np.linspace(-5, 5, 100)
energies = [((x + c) @ L_gauge @ (x + c)) for c in cs]
ax_gauge.plot(cs, energies, 'g-', linewidth=2)
ax_gauge.axhline(y=x @ L_gauge @ x, color='k', linestyle='--', alpha=0.5,
                 label=f'$E(x) = {x @ L_gauge @ x:.3f}$')
ax_gauge.set_xlabel("Constant shift $c$", fontsize=11)
ax_gauge.set_ylabel("Energy $E(x + c \\cdot \\mathbf{1})$", fontsize=11)
ax_gauge.set_title("Gauge Invariance: $E$ constant in $c$", fontsize=11)
ax_gauge.legend(fontsize=9)
ax_gauge.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("viz_covariance_kernel.png", dpi=150, bbox_inches='tight')
print("Saved viz_covariance_kernel.png")


#!/usr/bin/env python3
"""
Visualization: Effective Resistance Heatmap on Cycle Graphs

Visualizes the effective resistance matrix R(i,j) for cycle graphs C_n
of increasing size, demonstrating the exact formula R(i,j) = d(i,j)(n-d(i,j))/n.
The heatmap reveals the beautiful circulant structure: resistance depends only
on the cyclic distance and achieves its maximum at diametrically opposite vertices.
"""

import numpy as np
import matplotlib.pyplot as plt


def cycle_laplacian(n):
    L = np.zeros((n, n))
    for k in range(n):
        i, j = k, (k + 1) % n
        L[i, i] += 1; L[j, j] += 1
        L[i, j] -= 1; L[j, i] -= 1
    return L


def effective_resistance_matrix(L):
    Lp = np.linalg.pinv(L)
    diag = np.diag(Lp)
    return diag[:, None] + diag[None, :] - 2 * Lp


fig, axes = plt.subplots(1, 4, figsize=(16, 4))
fig.suptitle("Effective Resistance on Cycle Graphs $C_n$\n"
             "$R(i,j) = d(i,j) \\cdot (n - d(i,j)) / n$",
             fontsize=14, fontweight='bold')

for idx, n in enumerate([5, 8, 12, 20]):
    ax = axes[idx]
    L = cycle_laplacian(n)
    R = effective_resistance_matrix(L)

    im = ax.imshow(R, cmap='YlOrRd', interpolation='nearest')
    ax.set_title(f"$C_{{{n}}}$", fontsize=13)
    ax.set_xlabel("Vertex $j$")
    if idx == 0:
        ax.set_ylabel("Vertex $i$")
    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

    # Mark maximum resistance
    max_r = R.max()
    ax.text(0.5, -0.15, f"max R = {max_r:.3f}",
            transform=ax.transAxes, ha='center', fontsize=9)

plt.tight_layout()
plt.savefig("viz_resistance_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_resistance_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Effective Resistance vs Cyclic Distance

Plots R_eff(0, j) as a function of cyclic distance d(0, j) for cycle graphs
of various sizes, demonstrating the exact parabolic formula:
    R(i,j) = d · (n - d) / n

This reveals that resistance is a concave function of distance on cycles,
achieving its maximum at the antipodal point — the GFF variance of the
potential difference φ_0 - φ_j is maximized when j is as far as possible
from 0, which matches the physical intuition from electrical networks.
"""

import numpy as np
import matplotlib.pyplot as plt


def cycle_laplacian(n):
    L = np.zeros((n, n))
    for k in range(n):
        i, j = k, (k + 1) % n
        L[i, i] += 1; L[j, j] += 1
        L[i, j] -= 1; L[j, i] -= 1
    return L


def effective_resistance_matrix(L):
    Lp = np.linalg.pinv(L)
    diag = np.diag(Lp)
    return diag[:, None] + diag[None, :] - 2 * Lp


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))
fig.suptitle("Effective Resistance as a Gaussian Fluctuation Observable",
             fontsize=14, fontweight='bold')

# Left panel: R vs distance for various n
colors = plt.cm.viridis(np.linspace(0.1, 0.9, 6))
for idx, n in enumerate([6, 8, 10, 15, 20, 30]):
    L = cycle_laplacian(n)
    R = effective_resistance_matrix(L)
    distances = [min(abs(j), n - abs(j)) for j in range(n)]
    # Sort by distance
    pairs = sorted(zip(distances, R[0, :]))
    ds = [p[0] for p in pairs]
    rs = [p[1] for p in pairs]
    ax1.plot(ds, rs, 'o-', color=colors[idx], markersize=3,
             linewidth=1.2, label=f'$C_{{{n}}}$')

    # Overlay exact formula
    d_cont = np.linspace(0, n // 2, 100)
    r_exact = d_cont * (n - d_cont) / n
    ax1.plot(d_cont, r_exact, '--', color=colors[idx], alpha=0.3, linewidth=1)

ax1.set_xlabel("Cyclic distance $d(0, j)$", fontsize=12)
ax1.set_ylabel("Effective resistance $R(0, j)$", fontsize=12)
ax1.set_title("$R = d(n-d)/n$: Concave in Distance", fontsize=12)
ax1.legend(fontsize=9, ncol=2)
ax1.grid(True, alpha=0.3)

# Right panel: Var(φ_0 - φ_j) = R(0,j) demonstration
n = 10
L = cycle_laplacian(n)
R = effective_resistance_matrix(L)
K = (R[:, 0][:, None] + R[:, 0][None, :] - R) / 2  # base=0

distances = [min(abs(j), n - abs(j)) for j in range(n)]
variances = [K[0,0] + K[j,j] - 2*K[0,j] for j in range(n)]
resistances = [R[0, j] for j in range(n)]

ax2.bar(range(n), resistances, alpha=0.4, color='steelblue',
        label='$R_{\\mathrm{eff}}(0,j)$')
ax2.plot(range(n), variances, 'ro-', markersize=5,
         label='$\\mathrm{Var}(\\phi_0 - \\phi_j)$')
ax2.set_xlabel("Vertex $j$", fontsize=12)
ax2.set_ylabel("Value", fontsize=12)
ax2.set_title(f"$C_{{{n}}}$: Resistance = Variance (Flagship Theorem)", fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xticks(range(n))

plt.tight_layout()
plt.savefig("viz_resistance_vs_distance.png", dpi=150, bbox_inches='tight')
print("Saved viz_resistance_vs_distance.png")
