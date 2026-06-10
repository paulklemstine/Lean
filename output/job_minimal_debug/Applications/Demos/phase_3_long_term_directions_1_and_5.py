#!/usr/bin/env python3
"""
Tropical Matrix Algebra — Real-World Applications

Demonstrates practical applications of the tropical path algebra framework:
1. Project scheduling (Critical Path Method via tropical powers)
2. Network routing (optimal bandwidth paths)
3. Gene regulatory network analysis
4. ReLU neural network propagation
"""

import numpy as np


def tropical_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (max-plus) matrix multiplication."""
    return np.max(A[:, :, np.newaxis] + B[np.newaxis, :, :], axis=1)


def tropical_power(W: np.ndarray, m: int) -> np.ndarray:
    """Compute the m-th tropical power of W."""
    result = W.copy()
    for _ in range(m):
        result = tropical_matmul(result, W)
    return result


# ─────────────────────────────────────────────────────────────────
# Application 1: Project Scheduling (Critical Path Method)
# ─────────────────────────────────────────────────────────────────

def app_critical_path():
    """Critical Path Method via tropical matrix powers.
    
    In project scheduling, tasks have dependencies and durations.
    The critical path is the longest path through the dependency graph,
    determining the minimum project completion time.
    
    Tropical matrix power W^{⊗m} computes the maximum total duration
    of any m+1-edge chain of dependent tasks.
    """
    print("=" * 65)
    print("APPLICATION 1: Project Scheduling (Critical Path)")
    print("=" * 65)
    
    # Task dependency graph with durations (days)
    # Tasks: Design(0), Prototype(1), Test(2), Manufacture(3), Ship(4)
    NEG_INF = -np.inf
    n = 5
    tasks = ["Design", "Prototype", "Test", "Manufacture", "Ship"]
    
    # W[i][j] = duration of task j if task i must complete before task j
    W = np.full((n, n), NEG_INF)
    W[0, 1] = 5   # Design -> Prototype: 5 days
    W[0, 2] = 3   # Design -> Test: 3 days
    W[1, 2] = 4   # Prototype -> Test: 4 days
    W[1, 3] = 7   # Prototype -> Manufacture: 7 days
    W[2, 3] = 2   # Test -> Manufacture: 2 days
    W[2, 4] = 6   # Test -> Ship: 6 days
    W[3, 4] = 3   # Manufacture -> Ship: 3 days
    np.fill_diagonal(W, 0)
    
    print(f"\nTask dependency graph:")
    for i in range(n):
        for j in range(n):
            if W[i, j] > NEG_INF and i != j:
                print(f"  {tasks[i]} -> {tasks[j]}: {W[i,j]:.0f} days")
    
    print(f"\nTropical powers reveal critical path lengths:")
    for m in range(n - 1):
        T = tropical_power(W, m)
        length = m + 1
        
        # Find the maximum entry (longest chain of this length)
        max_val = np.max(T[np.isfinite(T)]) if np.any(np.isfinite(T)) else NEG_INF
        
        # Find Design -> Ship path if it exists
        ds = T[0, 4]
        ds_str = f"{ds:.0f} days" if np.isfinite(ds) else "no path"
        
        print(f"  Length-{length} chains: max duration = {max_val:.0f} days, "
              f"Design→Ship = {ds_str}")
    
    # Overall critical path
    best = W.copy()
    current = W.copy()
    for _ in range(1, n - 1):
        current = tropical_matmul(current, W)
        best = np.maximum(best, current)
    
    cp = best[0, 4]
    print(f"\n  ★ Critical path (Design → Ship): {cp:.0f} days")
    print(f"  This is the minimum possible project duration.")


# ─────────────────────────────────────────────────────────────────
# Application 2: Network Bandwidth Routing
# ─────────────────────────────────────────────────────────────────

def app_network_routing():
    """Optimal bandwidth routing via tropical (max-plus) algebra.
    
    In network routing, edge weights represent log-bandwidth.
    The maximum-weight path gives the highest-bandwidth route.
    Tropical matrix powers compute optimal multi-hop routes.
    """
    print("\n" + "=" * 65)
    print("APPLICATION 2: Network Bandwidth Routing")
    print("=" * 65)
    
    NEG_INF = -np.inf
    nodes = ["Server", "Router-A", "Router-B", "Router-C", "Client"]
    n = len(nodes)
    
    # Log-bandwidth weights (higher = more bandwidth)
    W = np.full((n, n), NEG_INF)
    W[0, 1] = 10   # Server -> Router-A: 10 Gbps (log-scale)
    W[0, 2] = 8    # Server -> Router-B
    W[1, 2] = 5    # Router-A -> Router-B
    W[1, 3] = 7    # Router-A -> Router-C
    W[2, 3] = 9    # Router-B -> Router-C
    W[2, 4] = 6    # Router-B -> Client
    W[3, 4] = 8    # Router-C -> Client
    np.fill_diagonal(W, 0)
    
    print(f"\nNetwork topology (log-bandwidth weights):")
    for i in range(n):
        for j in range(n):
            if W[i, j] > NEG_INF and i != j:
                print(f"  {nodes[i]} -> {nodes[j]}: {W[i,j]:.0f}")
    
    print(f"\nOptimal routes from Server to Client by hop count:")
    for hops in range(1, n):
        T = tropical_power(W, hops - 1)
        bw = T[0, 4]
        if np.isfinite(bw):
            print(f"  {hops} hop(s): bandwidth score = {bw:.0f}")
        else:
            print(f"  {hops} hop(s): no route exists")
    
    # Best overall route
    best = W.copy()
    current = W.copy()
    for _ in range(1, n - 1):
        current = tropical_matmul(current, W)
        best = np.maximum(best, current)
    
    print(f"\n  ★ Optimal Server→Client bandwidth score: {best[0,4]:.0f}")


# ─────────────────────────────────────────────────────────────────
# Application 3: Gene Regulatory Networks
# ─────────────────────────────────────────────────────────────────

def app_gene_regulation():
    """Gene regulatory network analysis via tropical semantics.
    
    Genes activate or inhibit each other with varying strengths.
    Tropical matrix powers reveal the strongest regulatory cascades
    of each length, identifying dominant signaling pathways.
    """
    print("\n" + "=" * 65)
    print("APPLICATION 3: Gene Regulatory Cascade Analysis")
    print("=" * 65)
    
    genes = ["TF-A", "Gene-B", "Gene-C", "Gene-D", "Output"]
    n = len(genes)
    NEG_INF = -np.inf
    
    # Regulation strengths (log fold-change)
    W = np.full((n, n), NEG_INF)
    W[0, 1] = 2.5   # TF-A activates Gene-B
    W[0, 2] = 1.8   # TF-A activates Gene-C
    W[1, 3] = 3.0   # Gene-B strongly activates Gene-D
    W[2, 3] = 1.5   # Gene-C weakly activates Gene-D
    W[2, 4] = 2.0   # Gene-C activates Output
    W[3, 4] = 2.2   # Gene-D activates Output
    np.fill_diagonal(W, 0)
    
    print(f"\nRegulatory network (activation strengths):")
    for i in range(n):
        for j in range(n):
            if W[i, j] > NEG_INF and i != j:
                print(f"  {genes[i]} → {genes[j]}: strength {W[i,j]:.1f}")
    
    print(f"\nStrongest regulatory cascades from TF-A to Output:")
    for depth in range(1, n):
        T = tropical_power(W, depth - 1)
        signal = T[0, 4]
        if np.isfinite(signal):
            print(f"  Depth {depth}: cumulative strength = {signal:.1f}")
        else:
            print(f"  Depth {depth}: no cascade exists")
    
    # Best cascade
    best = W.copy()
    current = W.copy()
    for _ in range(1, n - 1):
        current = tropical_matmul(current, W)
        best = np.maximum(best, current)
    
    print(f"\n  ★ Strongest TF-A→Output cascade: {best[0,4]:.1f}")
    print(f"  This identifies the dominant signaling pathway.")


# ─────────────────────────────────────────────────────────────────
# Application 4: ReLU Neural Network as Tropical Computation
# ─────────────────────────────────────────────────────────────────

def app_relu_tropical():
    """ReLU neural networks as tropical (max-plus) computations.
    
    A ReLU neuron computes max(0, w·x + b) = max(0, Σ w_i x_i + b).
    When inputs are log-scale activations, this becomes tropical:
    the output is the maximum over input contributions.
    
    Layer-by-layer propagation is tropical matrix multiplication.
    """
    print("\n" + "=" * 65)
    print("APPLICATION 4: ReLU Network as Tropical Computation")
    print("=" * 65)
    
    # 3-layer network: 4 inputs -> 3 hidden -> 3 hidden -> 2 outputs
    np.random.seed(123)
    
    # Weight matrices (log-scale interpretation)
    W1 = np.array([
        [2.0, 1.5, 0.5, 3.0],
        [1.0, 2.5, 1.0, 0.5],
        [0.5, 0.5, 2.0, 1.0],
    ])
    
    W2 = np.array([
        [1.5, 2.0, 0.5],
        [0.5, 1.0, 2.5],
        [2.0, 0.5, 1.0],
    ])
    
    W3 = np.array([
        [1.0, 1.5, 2.0],
        [2.0, 0.5, 1.0],
    ])
    
    # Input activations (log-scale)
    x = np.array([1.0, 2.0, 0.5, 1.5])
    
    print(f"\nInput activations: {x}")
    
    # Layer 1: tropical activation
    h1 = np.array([max(W1[j, i] + x[i] for i in range(4)) for j in range(3)])
    print(f"Hidden layer 1 (tropical): {h1}")
    
    # Layer 2
    h2 = np.array([max(W2[j, i] + h1[i] for i in range(3)) for j in range(3)])
    print(f"Hidden layer 2 (tropical): {h2}")
    
    # Layer 3 (output)
    out = np.array([max(W3[j, i] + h2[i] for i in range(3)) for j in range(2)])
    print(f"Output (tropical): {out}")
    
    print(f"\n  Each layer performs tropical matrix-vector multiplication.")
    print(f"  The full network computes the maximum-weight path")
    print(f"  from each input neuron through the network to each output.")
    print(f"  This is exactly what our tropPow theorem guarantees!")


# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    app_critical_path()
    app_network_routing()
    app_gene_regulation()
    app_relu_tropical()
    
    print("\n" + "=" * 65)
    print("All applications demonstrated successfully.")
    print("=" * 65)


#!/usr/bin/env python3
"""
Tropical Matrix Algebra and Graph Path Semantics — Interactive Demo

Demonstrates the core theorems connecting tropical (max-plus) matrix
multiplication to weighted directed graph path optimization.
"""

import numpy as np
from itertools import product as cart_product

# ─────────────────────────────────────────────────────────────────
# 1. Tropical Matrix Multiplication
# ─────────────────────────────────────────────────────────────────

def trop_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (max-plus) matrix multiplication.
    
    (A ⊗ B)_{ij} = max_k (A_{ik} + B_{kj})
    
    Replaces conventional sum with max and product with addition.
    """
    n = A.shape[0]
    C = np.full((n, n), -np.inf)
    for i in range(n):
        for j in range(n):
            C[i, j] = max(A[i, k] + B[k, j] for k in range(n))
    return C


def trop_pow(W: np.ndarray, m: int) -> np.ndarray:
    """Tropical matrix power: W^{⊗m} via iterated tropical multiplication.
    
    - trop_pow(W, 0) = W  (length-1 walks)
    - trop_pow(W, m+1) = trop_mul(trop_pow(W, m), W)
    """
    if m == 0:
        return W.copy()
    return trop_mul(trop_pow(W, m - 1), W)


# ─────────────────────────────────────────────────────────────────
# 2. Brute-force path enumeration for verification
# ─────────────────────────────────────────────────────────────────

def all_walks(n: int, length: int, start: int, end: int):
    """Enumerate all walks of a given length from start to end.
    
    A walk of length m uses m edges and visits m+1 vertices.
    Returns list of vertex tuples.
    """
    if length == 1:
        return [(start, end)]
    walks = []
    # A walk of length `length` has `length + 1` vertices
    # First vertex = start, last vertex = end
    for intermediates in cart_product(range(n), repeat=length - 1):
        path = (start,) + intermediates + (end,)
        walks.append(path)
    return walks


def walk_weight(W: np.ndarray, walk: tuple) -> float:
    """Compute the weight of a walk: sum of edge weights along the path."""
    return sum(W[walk[t], walk[t + 1]] for t in range(len(walk) - 1))


def max_walk_weight(W: np.ndarray, length: int, i: int, j: int) -> float:
    """Maximum weight over all walks of a given length from i to j."""
    n = W.shape[0]
    walks = all_walks(n, length, i, j)
    return max(walk_weight(W, w) for w in walks)


# ─────────────────────────────────────────────────────────────────
# 3. Demo: verify tropPow_eq_sup_pathWeight
# ─────────────────────────────────────────────────────────────────

def demo_path_semantics():
    """Verify that tropical matrix powers compute maximum walk weights."""
    print("=" * 65)
    print("DEMO 1: Tropical Powers = Max Walk Weights")
    print("=" * 65)
    
    # 4-vertex weighted directed graph
    W = np.array([
        [ 0,  3, -1,  2],
        [ 1,  0,  4, -2],
        [ 5, -3,  0,  1],
        [ 2,  3,  1,  0]
    ], dtype=float)
    
    print("\nWeight matrix W (4-vertex directed graph):")
    print(W)
    
    for m in range(4):  # m=0 means length-1 walks (single edges)
        length = m + 1
        T = trop_pow(W, m)
        print(f"\n--- Length-{length} walks (tropPow W {m}) ---")
        
        all_match = True
        for i in range(4):
            for j in range(4):
                brute = max_walk_weight(W, length, i, j)
                if abs(T[i, j] - brute) > 1e-12:
                    print(f"  MISMATCH at ({i},{j}): trop={T[i,j]}, brute={brute}")
                    all_match = False
        
        if all_match:
            print(f"  ✓ All entries match brute-force enumeration")
        print(f"  Tropical power matrix:\n{T}")


# ─────────────────────────────────────────────────────────────────
# 4. Demo: verify tropMul_assoc
# ─────────────────────────────────────────────────────────────────

def demo_associativity():
    """Verify associativity of tropical matrix multiplication."""
    print("\n" + "=" * 65)
    print("DEMO 2: Associativity of Tropical Multiplication")
    print("=" * 65)
    
    np.random.seed(42)
    n = 5
    A = np.random.randn(n, n) * 3
    B = np.random.randn(n, n) * 3
    C = np.random.randn(n, n) * 3
    
    LHS = trop_mul(trop_mul(A, B), C)
    RHS = trop_mul(A, trop_mul(B, C))
    
    diff = np.max(np.abs(LHS - RHS))
    print(f"\n  max |( A ⊗ B ) ⊗ C  -  A ⊗ ( B ⊗ C )| = {diff:.2e}")
    print(f"  ✓ Associativity verified" if diff < 1e-12 else "  ✗ FAILED")


# ─────────────────────────────────────────────────────────────────
# 5. Demo: Bellman recurrence
# ─────────────────────────────────────────────────────────────────

def demo_bellman():
    """Verify the Bellman optimality recurrence."""
    print("\n" + "=" * 65)
    print("DEMO 3: Bellman Optimality Recurrence")
    print("=" * 65)
    
    W = np.array([
        [ 0,  2,  5],
        [ 1,  0,  3],
        [ 4, -1,  0]
    ], dtype=float)
    
    print("\nWeight matrix W (3-vertex graph):")
    print(W)
    
    for m in range(1, 5):
        T_prev = trop_pow(W, m - 1)
        T_curr = trop_pow(W, m)
        
        # Bellman: T_curr[i][j] = max_k (T_prev[i][k] + W[k][j])
        bellman_ok = True
        for i in range(3):
            for j in range(3):
                bellman_val = max(T_prev[i, k] + W[k, j] for k in range(3))
                if abs(T_curr[i, j] - bellman_val) > 1e-12:
                    bellman_ok = False
        
        status = "✓" if bellman_ok else "✗"
        print(f"  {status} Bellman recurrence holds for m={m}")


# ─────────────────────────────────────────────────────────────────
# 6. Demo: Boolean reachability
# ─────────────────────────────────────────────────────────────────

def demo_boolean_reachability():
    """Demonstrate Boolean reachability as a special case of tropical semantics."""
    print("\n" + "=" * 65)
    print("DEMO 4: Boolean Reachability via Tropical Semantics")
    print("=" * 65)
    
    # Adjacency matrix (Boolean graph)
    G = np.array([
        [False, True,  False, False],
        [False, False, True,  False],
        [False, False, False, True ],
        [True,  False, False, False],
    ])
    
    print("\nAdjacency matrix G (4-vertex directed cycle):")
    print(G.astype(int))
    
    # Encode: True -> 0, False -> -inf
    NEG_INF = -1e18
    W = np.where(G, 0.0, NEG_INF)
    
    for m in range(1, 6):
        T = trop_pow(W, m - 1)  # length-m walks
        print(f"\n  Length-{m} reachability (finite = reachable):")
        reach = T > NEG_INF / 2
        for i in range(4):
            row = [("1" if reach[i, j] else "0") for j in range(4)]
            print(f"    {i} -> {' '.join(row)}")


# ─────────────────────────────────────────────────────────────────
# 7. Demo: tropical idempotence
# ─────────────────────────────────────────────────────────────────

def demo_idempotence():
    """Demonstrate tropical idempotence: max(a, a) = a."""
    print("\n" + "=" * 65)
    print("DEMO 5: Tropical Idempotence (max a a = a)")
    print("=" * 65)
    
    test_vals = [-3.14, 0, 1, 42, -1e10, 1e10]
    all_ok = True
    for a in test_vals:
        result = max(a, a)
        ok = (result == a)
        if not ok:
            all_ok = False
        print(f"  max({a}, {a}) = {result}  {'✓' if ok else '✗'}")
    
    print(f"\n  {'✓ All passed' if all_ok else '✗ FAILED'}")
    print("  This is the idempotence axiom of tropical semirings.")
    print("  It means: taking the max of a value with itself changes nothing.")
    print("  In graph terms: duplicate paths don't improve the optimal score.")


# ─────────────────────────────────────────────────────────────────
# Run all demos
# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_path_semantics()
    demo_associativity()
    demo_bellman()
    demo_boolean_reachability()
    demo_idempotence()
    
    print("\n" + "=" * 65)
    print("All demos completed successfully.")
    print("=" * 65)


#!/usr/bin/env python3
"""
Tropical Matrix Algebra — Visualizations

Generates figures illustrating key concepts of tropical path algebra.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import base64
from io import BytesIO


def tropical_matmul(A, B):
    return np.max(A[:, :, np.newaxis] + B[np.newaxis, :, :], axis=1)


def tropical_power(W, m):
    result = W.copy()
    for _ in range(m):
        result = tropical_matmul(result, W)
    return result


def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


# ─────────────────────────────────────────────────────────────────
# Figure 1: Tropical Power Heatmaps
# ─────────────────────────────────────────────────────────────────

def viz_tropical_powers():
    W = np.array([
        [ 0,  3, -1,  2],
        [ 1,  0,  4, -2],
        [ 5, -3,  0,  1],
        [ 2,  3,  1,  0]
    ], dtype=float)
    
    fig, axes = plt.subplots(1, 4, figsize=(16, 4))
    
    for m, ax in enumerate(axes):
        T = tropical_power(W, m)
        im = ax.imshow(T, cmap='YlOrRd', aspect='equal')
        ax.set_title(f'W$^{{⊗{m}}}$ (length-{m+1} walks)', fontsize=11)
        ax.set_xlabel('Target vertex j')
        ax.set_ylabel('Source vertex i')
        ax.set_xticks(range(4))
        ax.set_yticks(range(4))
        
        for i in range(4):
            for j in range(4):
                ax.text(j, i, f'{T[i,j]:.0f}', ha='center', va='center',
                       fontsize=10, fontweight='bold',
                       color='white' if T[i,j] > np.median(T) else 'black')
        
        plt.colorbar(im, ax=ax, shrink=0.8)
    
    fig.suptitle('Tropical Matrix Powers: Maximum Walk Weights', fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/tropical_powers.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


# ─────────────────────────────────────────────────────────────────
# Figure 2: Boolean Reachability Evolution
# ─────────────────────────────────────────────────────────────────

def viz_boolean_reachability():
    G = np.array([
        [False, True,  False, False, True],
        [False, False, True,  False, False],
        [True,  False, False, True,  False],
        [False, False, False, False, True],
        [False, False, False, False, False],
    ])
    
    NEG_INF = -np.inf
    W = np.where(G, 0.0, NEG_INF)
    
    fig, axes = plt.subplots(1, 5, figsize=(18, 3.5))
    
    for m, ax in enumerate(axes):
        T = tropical_power(W, m)
        R = np.isfinite(T).astype(float)
        
        ax.imshow(R, cmap='Greens', vmin=0, vmax=1, aspect='equal')
        ax.set_title(f'Length {m+1}', fontsize=11)
        ax.set_xlabel('j')
        if m == 0:
            ax.set_ylabel('i')
        ax.set_xticks(range(5))
        ax.set_yticks(range(5))
        
        for i in range(5):
            for j in range(5):
                ax.text(j, i, '✓' if R[i,j] > 0.5 else '✗',
                       ha='center', va='center', fontsize=12,
                       color='white' if R[i,j] > 0.5 else 'lightgray')
    
    fig.suptitle('Boolean Reachability via Tropical Encoding', fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/reachability.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


# ─────────────────────────────────────────────────────────────────
# Figure 3: Bellman Convergence
# ─────────────────────────────────────────────────────────────────

def viz_bellman_convergence():
    W = np.array([
        [ 0,  3, -1,  2],
        [ 1,  0,  4, -2],
        [ 5, -3,  0,  1],
        [ 2,  3,  1,  0]
    ], dtype=float)
    
    n = 4
    source = 0
    iterations = 8
    
    # Track Bellman values over iterations
    history = np.zeros((iterations, n))
    d = W[source].copy()
    history[0] = d
    
    for it in range(1, iterations):
        d_new = np.full(n, -np.inf)
        for j in range(n):
            d_new[j] = max(d[k] + W[k, j] for k in range(n))
        d = d_new
        history[it] = d
    
    fig, ax = plt.subplots(figsize=(10, 6))
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
    
    for j in range(n):
        ax.plot(range(1, iterations + 1), history[:, j],
                'o-', color=colors[j], linewidth=2, markersize=6,
                label=f'Vertex {j}')
    
    ax.set_xlabel('Iteration (walk length)', fontsize=12)
    ax.set_ylabel('Maximum walk weight from source 0', fontsize=12)
    ax.set_title('Bellman Iteration: Convergence of Tropical Powers', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(range(1, iterations + 1))
    
    plt.tight_layout()
    fig.savefig('/workspace/request-project/bellman_convergence.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


# ─────────────────────────────────────────────────────────────────
# Figure 4: Associativity Verification
# ─────────────────────────────────────────────────────────────────

def viz_associativity():
    np.random.seed(42)
    sizes = list(range(2, 12))
    max_diffs = []
    
    for n in sizes:
        A = np.random.randn(n, n) * 5
        B = np.random.randn(n, n) * 5
        C = np.random.randn(n, n) * 5
        
        LHS = tropical_matmul(tropical_matmul(A, B), C)
        RHS = tropical_matmul(A, tropical_matmul(B, C))
        
        max_diffs.append(np.max(np.abs(LHS - RHS)))
    
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.bar(sizes, max_diffs, color='steelblue', alpha=0.8)
    ax.set_xlabel('Matrix size n', fontsize=12)
    ax.set_ylabel('max |(A⊗B)⊗C - A⊗(B⊗C)|', fontsize=12)
    ax.set_title('Tropical Associativity: Numerical Verification', fontsize=14, fontweight='bold')
    ax.set_xticks(sizes)
    ax.set_ylim(-1e-16, 1e-14)
    ax.axhline(y=0, color='red', linestyle='--', alpha=0.5, label='Exact zero')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    fig.savefig('/workspace/request-project/associativity.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_powers = viz_tropical_powers()
    print(f"  ✓ Tropical powers heatmap ({len(b64_powers)} chars)")
    
    b64_reach = viz_boolean_reachability()
    print(f"  ✓ Boolean reachability ({len(b64_reach)} chars)")
    
    b64_bellman = viz_bellman_convergence()
    print(f"  ✓ Bellman convergence ({len(b64_bellman)} chars)")
    
    b64_assoc = viz_associativity()
    print(f"  ✓ Associativity verification ({len(b64_assoc)} chars)")
    
    print("\nAll visualizations saved as PNG files and base64 encoded.")
    
    # Save base64 data for use in PACKAGE.json
    import json
    viz_data = {
        "tropical_powers": b64_powers,
        "boolean_reachability": b64_reach,
        "bellman_convergence": b64_bellman,
        "associativity": b64_assoc,
    }
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Base64 data saved to viz_data.json")
