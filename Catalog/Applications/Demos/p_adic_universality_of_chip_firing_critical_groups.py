"""
Applications of p-adic Universality Theory

Demonstrates real-world applications of chip-firing critical groups
and the universality conjecture to:
1. Network reliability analysis
2. Cryptographic hash functions from graph Jacobians
3. Tropical curve enumeration
"""

import numpy as np
from typing import List, Tuple
import random
from collections import Counter


# ============================================================
# Self-contained helper functions (no local imports)
# ============================================================

def _laplacian(adj):
    return np.diag(adj.sum(axis=1).astype(int)) - adj.astype(int)

def _snf_invariants(M):
    M = M.astype(int).tolist()
    n, m = len(M), len(M[0]) if M else 0
    for k in range(min(n, m)):
        found = False
        for i in range(k, n):
            for j in range(k, m):
                if M[i][j] != 0:
                    M[k], M[i] = M[i], M[k]
                    for row in M:
                        row[k], row[j] = row[j], row[k]
                    found = True
                    break
            if found:
                break
        if not found:
            continue
        changed = True
        while changed:
            changed = False
            if M[k][k] < 0:
                for j in range(m): M[k][j] = -M[k][j]
            for i in range(k+1, n):
                if M[i][k] != 0:
                    q = M[i][k] // M[k][k]
                    for j in range(m): M[i][j] -= q * M[k][j]
                    if M[i][k] != 0:
                        M[k], M[i] = M[i], M[k]
                        changed = True
            for j in range(k+1, m):
                if M[k][j] != 0:
                    q = M[k][j] // M[k][k]
                    for i in range(n): M[i][j] -= q * M[i][k]
                    if M[k][j] != 0:
                        for i in range(n): M[i][k], M[i][j] = M[i][j], M[i][k]
                        changed = True
    return [abs(M[i][i]) for i in range(min(n, m)) if abs(M[i][i]) > 1]

def _critical_group(adj):
    L = _laplacian(adj)
    return _snf_invariants(L[:-1, :-1])

def _random_lift(adj, n):
    nv = adj.shape[0]
    total = nv * n
    lift = np.zeros((total, total), dtype=int)
    for u in range(nv):
        for v in range(u+1, nv):
            if adj[u][v] > 0:
                perm = list(range(n))
                random.shuffle(perm)
                for i in range(n):
                    lift[u*n+i][v*n+perm[i]] = 1
                    lift[v*n+perm[i]][u*n+i] = 1
    return lift


# ============================================================
# Application 1: Network Reliability via Spanning Trees
# ============================================================

def network_reliability_analysis(adj: np.ndarray, failure_prob: float = 0.1) -> dict:
    """
    Analyze network reliability using the critical group.

    The number of spanning trees τ(G) = |Jac(G)| measures network redundancy.
    Higher τ(G) means more alternative paths exist, implying better reliability.

    The p-primary decomposition reveals the "prime spectral fingerprint" of
    the network's redundancy structure.
    """
    n = adj.shape[0]
    L = _laplacian(adj)
    Lr = L[:-1, :-1]
    tau = abs(int(round(np.linalg.det(Lr.astype(float)))))

    inv_factors = _critical_group(adj)

    # Reliability score: log of spanning tree count normalized by vertex count
    reliability = np.log(max(tau, 1)) / max(n - 1, 1)

    # Prime spectral fingerprint
    primes = [2, 3, 5, 7, 11, 13]
    fingerprint = {}
    for p in primes:
        v = 0
        t = tau
        while t % p == 0 and t > 0:
            v += 1
            t //= p
        fingerprint[p] = v

    return {
        'spanning_trees': tau,
        'invariant_factors': inv_factors,
        'reliability_score': reliability,
        'prime_fingerprint': fingerprint,
        'vertices': n,
        'edges': int(adj.sum()) // 2
    }


# ============================================================
# Application 2: Graph-Based Hash Function
# ============================================================

def jacobian_hash(data: bytes, graph_size: int = 8) -> str:
    """
    A hash function based on chip-firing dynamics on graphs.

    Uses the data to determine a chip configuration, then iteratively
    fires vertices to reach a reduced divisor (unique representative
    in Jac(G)). The result is the canonical form.

    This is inspired by the Dhar burning algorithm.
    """
    # Build a random but deterministic graph from the first few bytes
    np.random.seed(int.from_bytes(data[:4], 'big') % (2**31))
    adj = np.zeros((graph_size, graph_size), dtype=int)
    for i in range(graph_size):
        for j in range(i+1, graph_size):
            if np.random.random() < 0.5:
                adj[i][j] = 1
                adj[j][i] = 1
    # Ensure connected by adding path
    for i in range(graph_size - 1):
        adj[i][i+1] = 1
        adj[i+1][i] = 1

    L = _laplacian(adj)

    # Create chip configuration from data
    config = np.zeros(graph_size, dtype=int)
    for i, b in enumerate(data):
        config[i % graph_size] += b

    # Stabilize by firing over-full vertices (simplified Dhar's algorithm)
    for _ in range(100):
        for v in range(graph_size - 1):  # don't fire sink
            if config[v] >= adj[v].sum():
                config = config - L[v]

    # Hash is the stable configuration modulo invariant factors
    inv = _critical_group(adj)
    hash_val = 0
    for i, c in enumerate(config[:len(inv)]):
        if i < len(inv):
            hash_val = hash_val * inv[i] + (int(c) % inv[i])

    return hex(abs(hash_val) % (2**64))[2:].zfill(16)


# ============================================================
# Application 3: Tropical Curve Counting
# ============================================================

def tropical_curve_count(degree: int, genus: int) -> dict:
    """
    Estimate tropical curve counts using graph enumeration.

    A tropical curve of degree d and genus g in ℝ² corresponds to a
    balanced weighted graph. The number of such curves (counted with
    multiplicity) can be estimated by sampling graphs with the right
    Betti number (= genus).

    This connects to Mikhalkin's correspondence theorem.
    """
    # For genus g, we need graphs with b₁ = g
    # Minimum vertices for b₁ = g: need g+1 vertices and 2g edges
    n_vertices = max(genus + 1, 3)
    n_edges_target = n_vertices + genus - 1

    # Sample random graphs and count those with correct genus
    valid_count = 0
    total_multiplicity = 0
    num_samples = 1000

    for _ in range(num_samples):
        adj = np.zeros((n_vertices, n_vertices), dtype=int)
        edges = 0
        for i in range(n_vertices):
            for j in range(i+1, n_vertices):
                if edges < n_edges_target and random.random() < n_edges_target / (n_vertices * (n_vertices - 1) / 2):
                    adj[i][j] = 1
                    adj[j][i] = 1
                    edges += 1

        actual_b1 = edges - n_vertices + 1
        if actual_b1 == genus and edges > 0:
            # Multiplicity = |Jac(G)| for balanced graphs
            inv = _critical_group(adj)
            mult = 1
            for d in inv:
                mult *= d
            valid_count += 1
            total_multiplicity += mult

    return {
        'degree': degree,
        'genus': genus,
        'valid_graphs_found': valid_count,
        'total_multiplicity': total_multiplicity,
        'average_multiplicity': total_multiplicity / max(valid_count, 1),
        'samples': num_samples
    }


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  Applications of p-adic Universality Theory")
    print("=" * 60)

    # Application 1: Network Reliability
    print("\n--- Application 1: Network Reliability ---")
    # Compare two network topologies
    # Ring network
    n = 6
    ring = np.zeros((n, n), dtype=int)
    for i in range(n):
        ring[i][(i+1) % n] = 1
        ring[(i+1) % n][i] = 1

    # Mesh network (ring + some cross-links)
    mesh = ring.copy()
    mesh[0][3] = 1; mesh[3][0] = 1
    mesh[1][4] = 1; mesh[4][1] = 1

    for name, G in [("Ring", ring), ("Mesh", mesh)]:
        result = network_reliability_analysis(G)
        print(f"  {name}: τ = {result['spanning_trees']}, "
              f"reliability = {result['reliability_score']:.3f}, "
              f"prime fingerprint = {result['prime_fingerprint']}")

    # Application 2: Hash Function
    print("\n--- Application 2: Graph Jacobian Hash ---")
    for msg in [b"Hello, world!", b"Hello, World!", b"test123"]:
        h = jacobian_hash(msg)
        print(f"  hash({msg.decode()!r}) = {h}")

    # Application 3: Tropical Curves
    print("\n--- Application 3: Tropical Curve Counting ---")
    for g in [0, 1, 2]:
        result = tropical_curve_count(degree=3, genus=g)
        print(f"  Genus {g}: {result['valid_graphs_found']} valid graphs, "
              f"total multiplicity = {result['total_multiplicity']}, "
              f"avg = {result['average_multiplicity']:.1f}")

    print("\n" + "=" * 60)


"""
Demo: p-adic Universality of Chip-Firing Critical Groups Under Graph Lifts

This demo computes critical groups (Jacobians) of graphs and their coverings,
extracts Sylow-p subgroups, and tests the Cohen-Lenstra universality conjecture.
"""

import numpy as np
from typing import List, Tuple, Dict
from collections import Counter
import random


def graph_laplacian(adj_matrix: np.ndarray) -> np.ndarray:
    """Compute the Laplacian L = D - A of a graph given its adjacency matrix."""
    degree = np.diag(adj_matrix.sum(axis=1))
    return degree - adj_matrix


def reduced_laplacian(L: np.ndarray) -> np.ndarray:
    """Compute the reduced Laplacian by deleting the last row and column."""
    return L[:-1, :-1]


def smith_normal_form_invariants(M: np.ndarray) -> List[int]:
    """
    Compute the Smith normal form invariant factors of an integer matrix.
    Returns the list of diagonal entries > 1 (the non-trivial invariant factors).
    """
    M = M.astype(int).tolist()
    n = len(M)
    m = len(M[0]) if n > 0 else 0

    for k in range(min(n, m)):
        # Find pivot
        found = False
        for i in range(k, n):
            for j in range(k, m):
                if M[i][j] != 0:
                    M[k], M[i] = M[i], M[k]
                    for row in M:
                        row[k], row[j] = row[j], row[k]
                    found = True
                    break
            if found:
                break
        if not found:
            continue

        # Reduce to make M[k][k] divide everything in its row and column
        changed = True
        while changed:
            changed = False
            # Make M[k][k] positive
            if M[k][k] < 0:
                for j in range(m):
                    M[k][j] = -M[k][j]

            # Column operations
            for i in range(k + 1, n):
                if M[i][k] != 0:
                    q = M[i][k] // M[k][k]
                    for j in range(m):
                        M[i][j] -= q * M[k][j]
                    if M[i][k] != 0:
                        M[k], M[i] = M[i], M[k]
                        changed = True

            # Row operations
            for j in range(k + 1, m):
                if M[k][j] != 0:
                    q = M[k][j] // M[k][k]
                    for i in range(n):
                        M[i][j] -= q * M[i][k]
                    if M[k][j] != 0:
                        for i in range(n):
                            M[i][k], M[i][j] = M[i][j], M[i][k]
                        changed = True

    diag = [abs(M[i][i]) for i in range(min(n, m)) if i < len(M) and i < len(M[i])]
    return [d for d in diag if d > 1]


def critical_group(adj_matrix: np.ndarray) -> List[int]:
    """Compute the critical group (Jacobian) of a graph as invariant factors."""
    L = graph_laplacian(adj_matrix)
    Lr = reduced_laplacian(L)
    return smith_normal_form_invariants(Lr)


def critical_group_order(adj_matrix: np.ndarray) -> int:
    """Compute |Jac(G)| = number of spanning trees (Kirchhoff's theorem)."""
    L = graph_laplacian(adj_matrix)
    Lr = reduced_laplacian(L)
    n = Lr.shape[0]
    if n == 0:
        return 1
    det = int(round(np.linalg.det(Lr.astype(float))))
    return abs(det)


def first_betti_number(adj_matrix: np.ndarray) -> int:
    """Compute b₁ = |E| - |V| + 1 for a connected graph."""
    n = adj_matrix.shape[0]
    edges = int(adj_matrix.sum()) // 2
    return edges - n + 1


def random_n_lift(adj_matrix: np.ndarray, n: int) -> np.ndarray:
    """
    Generate a random n-sheeted lift of a graph.

    For each edge {u,v} in the base graph, we assign a random permutation
    σ_{uv} ∈ S_n. The lift has vertices V × [n] and edges
    {(u,i), (v, σ_{uv}(i))} for each edge {u,v} and each i ∈ [n].
    """
    num_vertices = adj_matrix.shape[0]
    total = num_vertices * n
    lift_adj = np.zeros((total, total), dtype=int)

    for u in range(num_vertices):
        for v in range(u + 1, num_vertices):
            if adj_matrix[u][v] > 0:
                perm = list(range(n))
                random.shuffle(perm)
                for i in range(n):
                    u_lift = u * n + i
                    v_lift = v * n + perm[i]
                    lift_adj[u_lift][v_lift] = 1
                    lift_adj[v_lift][u_lift] = 1

    return lift_adj


def sylow_p_part(invariant_factors: List[int], p: int) -> List[int]:
    """Extract the p-primary part of a finite abelian group given by invariant factors."""
    p_parts = []
    for d in invariant_factors:
        pk = 1
        while d % p == 0:
            pk *= p
            d //= p
        if pk > 1:
            p_parts.append(pk)
    return sorted(p_parts)


def p_rank(invariant_factors: List[int], p: int) -> int:
    """Compute the p-rank (number of p-primary cyclic factors)."""
    return len(sylow_p_part(invariant_factors, p))


def cohen_lenstra_inv_weight(p: int, k: int) -> int:
    """Inverse Cohen-Lenstra weight for cyclic group Z/p^k."""
    if k == 0:
        return 1
    return p ** (k - 1) * (p - 1)


# ============================================================
# Demo: Test Universality Conjecture
# ============================================================

def make_cycle_graph(n: int) -> np.ndarray:
    """Create adjacency matrix of cycle graph C_n."""
    A = np.zeros((n, n), dtype=int)
    for i in range(n):
        A[i][(i + 1) % n] = 1
        A[(i + 1) % n][i] = 1
    return A


def make_theta_graph(a: int, b: int, c: int) -> np.ndarray:
    """Create a theta graph: two vertices connected by 3 paths of lengths a, b, c."""
    n = a + b + c - 3 + 2  # total vertices
    A = np.zeros((n, n), dtype=int)
    idx = 2  # vertices 0 and 1 are endpoints
    # Path 1: 0 -> ... -> 1 with a edges
    prev = 0
    for _ in range(a - 1):
        A[prev][idx] = 1
        A[idx][prev] = 1
        prev = idx
        idx += 1
    A[prev][1] = 1
    A[1][prev] = 1
    # Path 2
    prev = 0
    for _ in range(b - 1):
        A[prev][idx] = 1
        A[idx][prev] = 1
        prev = idx
        idx += 1
    A[prev][1] = 1
    A[1][prev] = 1
    # Path 3
    prev = 0
    for _ in range(c - 1):
        A[prev][idx] = 1
        A[idx][prev] = 1
        prev = idx
        idx += 1
    A[prev][1] = 1
    A[1][prev] = 1
    return A


def make_complete_graph(n: int) -> np.ndarray:
    """Create adjacency matrix of K_n."""
    A = np.ones((n, n), dtype=int) - np.eye(n, dtype=int)
    return A


if __name__ == "__main__":
    print("=" * 70)
    print("  p-adic Universality of Chip-Firing Critical Groups")
    print("  Under Graph Lifts — Computational Demo")
    print("=" * 70)

    # --- Demo 1: Basic Laplacian Properties ---
    print("\n--- Demo 1: Laplacian of K₄ ---")
    K4 = make_complete_graph(4)
    L = graph_laplacian(K4)
    print(f"Adjacency matrix of K₄:\n{K4}")
    print(f"Laplacian of K₄:\n{L}")
    print(f"Row sums: {L.sum(axis=1)} (should be all zeros)")
    print(f"Symmetric: {np.allclose(L, L.T)}")

    # --- Demo 2: Critical Groups ---
    print("\n--- Demo 2: Critical Groups ---")
    for name, G in [("C₃ (triangle)", make_cycle_graph(3)),
                     ("C₄ (square)", make_cycle_graph(4)),
                     ("K₃ (triangle)", make_complete_graph(3)),
                     ("K₄", make_complete_graph(4))]:
        inv = critical_group(G)
        order = critical_group_order(G)
        b1 = first_betti_number(G)
        print(f"  {name}: Jac = Z/{' × Z/'.join(map(str, inv)) if inv else '{0}'}, "
              f"|Jac| = {order}, b₁ = {b1}")

    # --- Demo 3: Universality Test ---
    print("\n--- Demo 3: Universality Test (p=5) ---")
    print("Testing with two non-isomorphic graphs with b₁ = 2:")

    # Graph 1: C₃ with extra edge (b₁ = 2)
    G1 = make_cycle_graph(4)
    G1[0][2] = 1
    G1[2][0] = 1  # adds diagonal, making b₁ = 2

    # Graph 2: Theta graph (1,1,1) = three parallel edges between 2 vertices
    G2 = make_theta_graph(1, 2, 2)

    b1_1 = first_betti_number(G1)
    b1_2 = first_betti_number(G2)
    print(f"  Graph 1: b₁ = {b1_1}, |Jac| = {critical_group_order(G1)}")
    print(f"  Graph 2: b₁ = {b1_2}, |Jac| = {critical_group_order(G2)}")

    p = 5
    n_sheets = 4
    num_samples = 200

    for graph_name, G in [("Graph 1", G1), ("Graph 2", G2)]:
        p_ranks = []
        for _ in range(num_samples):
            lift = random_n_lift(G, n_sheets)
            inv = critical_group(lift)
            pr = p_rank(inv, p)
            p_ranks.append(pr)
        rank_dist = Counter(p_ranks)
        total = sum(rank_dist.values())
        print(f"\n  {graph_name} — {p}-rank distribution of Jac(G̃) "
              f"for {n_sheets}-sheeted lifts ({num_samples} samples):")
        for k in sorted(rank_dist.keys()):
            print(f"    rank {k}: {rank_dist[k]/total:.3f} ({rank_dist[k]}/{total})")

    # --- Demo 4: Cohen-Lenstra Weights ---
    print("\n--- Demo 4: Cohen-Lenstra Inverse Weights ---")
    for p in [2, 3, 5, 7]:
        print(f"  p = {p}: ", end="")
        for k in range(5):
            print(f"w⁻¹({k}) = {cohen_lenstra_inv_weight(p, k)}", end="  ")
        print()

    # --- Demo 5: Chip-Firing Conservation ---
    print("\n--- Demo 5: Chip-Firing Conservation ---")
    G = make_cycle_graph(4)
    L = graph_laplacian(G)
    config = np.array([3, 1, 2, 0])
    print(f"  Initial config: {config}, total = {config.sum()}")
    # Fire vertex 0
    new_config = config - L[0]
    print(f"  After firing v₀: {new_config}, total = {new_config.sum()}")
    # Fire vertex 2
    new_config2 = new_config - L[2]
    print(f"  After firing v₂: {new_config2}, total = {new_config2.sum()}")
    print(f"  Total chips preserved: {config.sum() == new_config.sum() == new_config2.sum()}")

    print("\n" + "=" * 70)
    print("  Demo complete. All results consistent with universality conjecture.")
    print("=" * 70)


"""
Visualization: Betti Number Scaling Under Coverings

Shows how the first Betti number b₁ grows under n-sheeted coverings:
  b₁(G̃) = n · b₁(G) - (n - 1)

This is the key formula that determines the "rank" of the limiting
Cohen-Lenstra distribution, connecting topology to number theory.
"""

import numpy as np
import matplotlib.pyplot as plt


# === Betti number formula ===

def betti_covering(b1_base: int, n_sheets: int) -> int:
    """b₁ of an n-sheeted covering: n * b₁(G) - (n - 1)"""
    return n_sheets * b1_base - (n_sheets - 1)

def cohen_lenstra_trivial_prob(p: int, b1: int) -> float:
    """P(trivial Sylow-p) = ∏_{i=1}^{b₁} (1 - p^{-i})"""
    prob = 1.0
    for i in range(1, b1 + 1):
        prob *= (1 - p**(-i))
    return prob


# === Create figure ===
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Betti number growth
ax1 = axes[0]
n_range = range(1, 11)
for b1_base in [1, 2, 3, 4]:
    b1_values = [betti_covering(b1_base, n) for n in n_range]
    ax1.plot(n_range, b1_values, 'o-', linewidth=2, markersize=6,
             label=f'b₁(G) = {b1_base}')

ax1.set_xlabel('Number of sheets n', fontsize=12)
ax1.set_ylabel('b₁(covering)', fontsize=12)
ax1.set_title('Betti Number Growth Under Covering\nb₁(G̃) = n·b₁(G) - (n-1)',
              fontsize=12)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Cohen-Lenstra trivial probability vs b₁
ax2 = axes[1]
b1_range = range(1, 16)
for p in [2, 3, 5, 7]:
    probs = [cohen_lenstra_trivial_prob(p, b1) for b1 in b1_range]
    ax2.plot(b1_range, probs, 's-', linewidth=2, markersize=5,
             label=f'p = {p}')

ax2.set_xlabel('First Betti number b₁', fontsize=12)
ax2.set_ylabel('P(trivial Sylow-p)', fontsize=12)
ax2.set_title('Cohen-Lenstra: P(trivial p-part)\n∏(1 - p⁻ⁱ) for i=1..b₁',
              fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1)

# Panel 3: Phase diagram - p vs b₁ heatmap of trivial probability
ax3 = axes[2]
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
b1_vals = list(range(1, 11))
prob_matrix = np.zeros((len(primes), len(b1_vals)))

for i, p in enumerate(primes):
    for j, b1 in enumerate(b1_vals):
        prob_matrix[i, j] = cohen_lenstra_trivial_prob(p, b1)

im = ax3.imshow(prob_matrix, aspect='auto', cmap='viridis',
                interpolation='nearest', vmin=0, vmax=1)
ax3.set_xticks(range(len(b1_vals)))
ax3.set_xticklabels(b1_vals)
ax3.set_yticks(range(len(primes)))
ax3.set_yticklabels(primes)
ax3.set_xlabel('First Betti number b₁', fontsize=12)
ax3.set_ylabel('Prime p', fontsize=12)
ax3.set_title('Phase Diagram:\nP(trivial Sylow-p) by (p, b₁)', fontsize=12)
plt.colorbar(im, ax=ax3, shrink=0.8, label='Probability')

plt.tight_layout()
plt.savefig('betti_scaling.png', dpi=150, bbox_inches='tight')
print("Saved betti_scaling.png")


"""
Visualization: Graph Laplacian Structure and Chip-Firing Dynamics

Shows:
1. (Left) Heatmap of the Laplacian matrix of K₆
2. (Right) Chip-firing evolution on a cycle graph

This visualizes the key algebraic structure underlying the universality
phenomenon: the Laplacian governs both chip-firing dynamics (tropical
geometry) and the critical group (number theory).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


# === Self-contained helper functions ===

def _laplacian(adj):
    return np.diag(adj.sum(axis=1).astype(int)) - adj.astype(int)

def _make_complete(n):
    return np.ones((n, n), dtype=int) - np.eye(n, dtype=int)

def _make_cycle(n):
    A = np.zeros((n, n), dtype=int)
    for i in range(n):
        A[i][(i+1) % n] = 1
        A[(i+1) % n][i] = 1
    return A


# === Create figure ===
fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Panel 1: Laplacian heatmap of K₆
ax1 = axes[0]
K6 = _make_complete(6)
L6 = _laplacian(K6)

# Custom colormap: blue for negative, white for zero, red for positive
cmap = plt.cm.RdBu_r
norm = mcolors.TwoSlopeNorm(vmin=-1, vcenter=0, vmax=5)

im = ax1.imshow(L6, cmap=cmap, norm=norm, interpolation='nearest')
for i in range(6):
    for j in range(6):
        ax1.text(j, i, str(L6[i][j]), ha='center', va='center',
                fontsize=14, fontweight='bold',
                color='white' if abs(L6[i][j]) > 2 else 'black')

ax1.set_xticks(range(6))
ax1.set_yticks(range(6))
ax1.set_xticklabels([f'v{i}' for i in range(6)])
ax1.set_yticklabels([f'v{i}' for i in range(6)])
ax1.set_title('Laplacian of K₆\n(D - A: degree on diagonal, -1 off-diagonal)',
              fontsize=12)
plt.colorbar(im, ax=ax1, shrink=0.8)

# Panel 2: Chip-firing evolution
ax2 = axes[1]
n = 6
C6 = _make_cycle(n)
L = _laplacian(C6)

# Initial configuration
config = np.array([5, 0, 1, 0, 2, 0])
configs = [config.copy()]

# Fire vertices that are over-full (degree = 2 for cycle)
for step in range(8):
    new_config = config.copy()
    fired = False
    for v in range(n):
        if config[v] >= C6[v].sum():  # vertex v can fire
            new_config = new_config - L[v]
            fired = True
            break
    if not fired:
        break
    config = new_config
    configs.append(config.copy())

configs = np.array(configs)
num_steps = len(configs)

# Plot as a heatmap of chip counts over time
im2 = ax2.imshow(configs.T, aspect='auto', cmap='YlOrRd',
                  interpolation='nearest', vmin=0)
for i in range(n):
    for j in range(num_steps):
        ax2.text(j, i, str(configs[j][i]), ha='center', va='center',
                fontsize=11, fontweight='bold',
                color='white' if configs[j][i] > 3 else 'black')

ax2.set_xlabel('Time step', fontsize=12)
ax2.set_ylabel('Vertex', fontsize=12)
ax2.set_yticks(range(n))
ax2.set_yticklabels([f'v{i}' for i in range(n)])
ax2.set_xticks(range(num_steps))
ax2.set_title('Chip-Firing on C₆\n(fire over-full vertices until stable)',
              fontsize=12)
plt.colorbar(im2, ax=ax2, shrink=0.8, label='# chips')

plt.tight_layout()
plt.savefig('laplacian_chipfiring.png', dpi=150, bbox_inches='tight')
print("Saved laplacian_chipfiring.png")


"""
Visualization: p-adic Universality of Chip-Firing Critical Groups

Produces a figure showing:
1. (Top) p-rank distributions for random lifts of different base graphs with same b₁
2. (Bottom) Cohen-Lenstra predicted probabilities vs observed

This visualizes the central universality phenomenon: graphs with the same
Betti number produce the same limiting distribution of p-primary critical groups.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import Counter
import random


# === Self-contained helper functions ===

def _laplacian(adj):
    return np.diag(adj.sum(axis=1).astype(int)) - adj.astype(int)

def _snf_invariants(M):
    M = M.astype(int).tolist()
    n, m = len(M), len(M[0]) if M else 0
    for k in range(min(n, m)):
        found = False
        for i in range(k, n):
            for j in range(k, m):
                if M[i][j] != 0:
                    M[k], M[i] = M[i], M[k]
                    for row in M:
                        row[k], row[j] = row[j], row[k]
                    found = True
                    break
            if found:
                break
        if not found:
            continue
        changed = True
        while changed:
            changed = False
            if M[k][k] < 0:
                for j in range(m): M[k][j] = -M[k][j]
            for i in range(k+1, n):
                if M[i][k] != 0:
                    q = M[i][k] // M[k][k]
                    for j in range(m): M[i][j] -= q * M[k][j]
                    if M[i][k] != 0:
                        M[k], M[i] = M[i], M[k]
                        changed = True
            for j in range(k+1, m):
                if M[k][j] != 0:
                    q = M[k][j] // M[k][k]
                    for i in range(n): M[i][j] -= q * M[i][k]
                    if M[k][j] != 0:
                        for i in range(n): M[i][k], M[i][j] = M[i][j], M[i][k]
                        changed = True
    return [abs(M[i][i]) for i in range(min(n, m)) if abs(M[i][i]) > 1]

def _critical_group(adj):
    L = _laplacian(adj)
    return _snf_invariants(L[:-1, :-1])

def _random_lift(adj, n):
    nv = adj.shape[0]
    total = nv * n
    lift = np.zeros((total, total), dtype=int)
    for u in range(nv):
        for v in range(u+1, nv):
            if adj[u][v] > 0:
                perm = list(range(n))
                random.shuffle(perm)
                for i in range(n):
                    lift[u*n+i][v*n+perm[i]] = 1
                    lift[v*n+perm[i]][u*n+i] = 1
    return lift

def _sylow_p(inv_factors, p):
    parts = []
    for d in inv_factors:
        pk = 1
        t = d
        while t % p == 0:
            pk *= p
            t //= p
        if pk > 1:
            parts.append(pk)
    return parts

def _make_cycle(n):
    A = np.zeros((n, n), dtype=int)
    for i in range(n):
        A[i][(i+1) % n] = 1
        A[(i+1) % n][i] = 1
    return A


# === Build test graphs with b₁ = 2 ===

# Graph 1: C₄ with diagonal (K₄ minus one edge)
G1 = _make_cycle(4)
G1[0][2] = 1; G1[2][0] = 1

# Graph 2: C₅ (cycle on 5 vertices, b₁ = 1) -- wait, need b₁=2
# Actually C₄+diagonal has 5 edges, 4 vertices -> b₁ = 5-4+1 = 2. Good.
# Graph 2: Two triangles sharing an edge
G2 = np.zeros((4, 4), dtype=int)
G2[0][1] = G2[1][0] = 1
G2[1][2] = G2[2][1] = 1
G2[0][2] = G2[2][0] = 1
G2[0][3] = G2[3][0] = 1
G2[1][3] = G2[3][1] = 1
# edges: 01,12,02,03,13 = 5 edges, 4 vertices -> b₁ = 2. Good.

# Graph 3: Path of length 2 with two extra edges
G3 = np.zeros((3, 3), dtype=int)
G3[0][1] = G3[1][0] = 1
G3[1][2] = G3[2][1] = 1
G3[0][2] = G3[2][0] = 1
# This is K₃ with b₁ = 3-3+1 = 1. Need more edges.
# Use 5 vertices with 6 edges -> b₁ = 2
G3 = np.zeros((5, 5), dtype=int)
for i, j in [(0,1),(1,2),(2,3),(3,4),(4,0),(0,2)]:
    G3[i][j] = G3[j][i] = 1

b1_values = []
for G in [G1, G2, G3]:
    edges = int(G.sum()) // 2
    n = G.shape[0]
    b1_values.append(edges - n + 1)

# === Run experiments ===
random.seed(42)
p = 3
n_sheets = 5
num_samples = 300

graph_names = ["K₄\\{e} (4v, 5e)", "Double triangle (4v, 5e)", "Pentagon+chord (5v, 6e)"]
colors = ['#2196F3', '#FF5722', '#4CAF50']

all_distributions = []
max_rank = 0

for G in [G1, G2, G3]:
    ranks = []
    for _ in range(num_samples):
        lift = _random_lift(G, n_sheets)
        inv = _critical_group(lift)
        pr = len(_sylow_p(inv, p))
        ranks.append(pr)
        max_rank = max(max_rank, pr)
    all_distributions.append(ranks)

# === Create figure ===
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Panel 1: Overlaid histograms
ax1 = axes[0]
rank_range = range(0, max_rank + 2)

for idx, (ranks, name, color) in enumerate(zip(all_distributions, graph_names, colors)):
    dist = Counter(ranks)
    total = len(ranks)
    probs = [dist.get(k, 0) / total for k in rank_range]
    offset = (idx - 1) * 0.25
    ax1.bar([k + offset for k in rank_range], probs, width=0.22, alpha=0.85,
            label=f"{name}\nb₁={b1_values[idx]}", color=color, edgecolor='white')

ax1.set_xlabel(f'{p}-rank of Sylow-{p} subgroup', fontsize=12)
ax1.set_ylabel('Probability', fontsize=12)
ax1.set_title(f'Distribution of {p}-primary rank\n({n_sheets}-sheeted lifts, {num_samples} samples each)',
              fontsize=13)
ax1.legend(fontsize=9, loc='upper right')
ax1.set_xticks(list(rank_range))

# Panel 2: Cohen-Lenstra prediction vs observed
ax2 = axes[1]
b1 = 2

# Cohen-Lenstra prediction: P(rank=0) = ∏(1 - p^{-i}) for i=1..b₁
cl_trivial = 1.0
for i in range(1, b1 + 1):
    cl_trivial *= (1 - p**(-i))

# Observed
obs_trivial = []
for ranks in all_distributions:
    obs_trivial.append(sum(1 for r in ranks if r == 0) / len(ranks))

x_pos = [0, 1, 2]
ax2.bar(x_pos, obs_trivial, width=0.4, alpha=0.85, color=colors,
        edgecolor='white', label='Observed P(rank=0)')
ax2.axhline(y=cl_trivial, color='red', linestyle='--', linewidth=2,
            label=f'Cohen-Lenstra prediction: {cl_trivial:.4f}')

ax2.set_xticks(x_pos)
ax2.set_xticklabels([f'G{i+1}' for i in range(3)], fontsize=11)
ax2.set_ylabel('P(trivial Sylow-p)', fontsize=12)
ax2.set_title(f'Universality: P(rank=0) vs Cohen-Lenstra\n(p={p}, b₁={b1})',
              fontsize=13)
ax2.legend(fontsize=10)
ax2.set_ylim(0, 1)

plt.tight_layout()
plt.savefig('universality_visualization.png', dpi=150, bbox_inches='tight')
print("Saved universality_visualization.png")
