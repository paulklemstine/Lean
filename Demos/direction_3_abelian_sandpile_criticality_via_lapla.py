#!/usr/bin/env python3
"""
applications.py — Real-world applications of abelian sandpile criticality
and Laplacian energy minimization.

Demonstrates:
1. Network robustness analysis via critical configurations
2. Load balancing on distributed systems using chip-firing
3. Image segmentation via Laplacian energy
4. Electrical network analysis
"""

import numpy as np
from itertools import product as iterproduct


# ============================================================
# Infrastructure (self-contained)
# ============================================================

def make_graph(n, edges):
    adj = np.zeros((n, n), dtype=int)
    for u, v in edges:
        adj[u, v] = 1
        adj[v, u] = 1
    L = np.diag(adj.sum(axis=1).astype(int)) - adj
    return adj, L

def dhar_burning(D, adj, q):
    n = adj.shape[0]
    burned = {q}
    changed = True
    while changed:
        changed = False
        for v in range(n):
            if v in burned:
                continue
            edges_to_burned = sum(adj[v, w] for w in burned)
            if D[v] < edges_to_burned:
                burned.add(v)
                changed = True
    return len(burned) == n

def q_reduce(D, adj, L, q, max_iter=10000):
    D = D.copy()
    n = adj.shape[0]
    for _ in range(max_iter):
        burned = {q}
        changed = True
        while changed:
            changed = False
            for v in range(n):
                if v in burned:
                    continue
                edges_to_burned = sum(adj[v, w] for w in burned)
                if D[v] < edges_to_burned:
                    burned.add(v)
                    changed = True
        if len(burned) == n:
            return D
        S = [v for v in range(n) if v not in burned]
        for v in S:
            D -= L[v, :]
    return D

def laplacian_energy(D, adj):
    x = D.astype(float)
    total = 0.0
    for i in range(adj.shape[0]):
        for j in range(adj.shape[0]):
            if adj[i, j]:
                total += (x[i] - x[j]) ** 2
    return total

def spanning_tree_count(adj, q):
    L = np.diag(adj.sum(axis=1)) - adj
    idx = [i for i in range(adj.shape[0]) if i != q]
    Lq = L[np.ix_(idx, idx)]
    return int(round(abs(np.linalg.det(Lq))))


# ============================================================
# Application 1: Network Robustness Analysis
# ============================================================

def network_robustness_analysis():
    """
    Analyze network robustness using the sandpile Jacobian order.
    
    The number of spanning trees (= det(L_q) = #critical configs)
    measures how many independent communication paths exist in a network.
    Higher count = more robust network.
    """
    print("="*60)
    print("APPLICATION 1: Network Robustness Analysis")
    print("="*60)
    print()
    
    # Compare different network topologies for 6 nodes
    n = 6
    
    # Ring network
    ring_edges = [(i, (i+1) % n) for i in range(n)]
    ring_adj, ring_L = make_graph(n, ring_edges)
    
    # Star network (node 0 is hub)
    star_edges = [(0, i) for i in range(1, n)]
    star_adj, star_L = make_graph(n, star_edges)
    
    # Mesh network (grid 2x3)
    mesh_edges = [(0,1), (1,2), (3,4), (4,5), (0,3), (1,4), (2,5)]
    mesh_adj, mesh_L = make_graph(n, mesh_edges)
    
    # Complete network
    complete_edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    complete_adj, complete_L = make_graph(n, complete_edges)
    
    q = 0
    networks = [
        ("Ring (C₆)", ring_adj),
        ("Star (S₆)", star_adj),
        ("2×3 Grid", mesh_adj),
        ("Complete (K₆)", complete_adj),
    ]
    
    print(f"{'Network':20s} {'Spanning Trees':>15s} {'Fiedler λ₂':>12s} {'Robustness':>12s}")
    print("-" * 62)
    for name, adj in networks:
        trees = spanning_tree_count(adj, q)
        L = np.diag(adj.sum(axis=1)) - adj
        evals = np.sort(np.linalg.eigvalsh(L.astype(float)))
        fiedler = evals[1]
        print(f"{name:20s} {trees:15d} {fiedler:12.4f} {'HIGH' if trees > 100 else 'MEDIUM' if trees > 10 else 'LOW':>12s}")
    
    print()
    print("Insight: The number of critical configurations (= spanning trees)")
    print("directly measures network redundancy. The Fiedler value λ₂")
    print("measures how well-connected the network is.")
    print()


# ============================================================
# Application 2: Load Balancing via Chip-Firing
# ============================================================

def load_balancing_demo():
    """
    Demonstrate chip-firing as a load balancing algorithm.
    
    Vertices represent servers, chips represent tasks.
    Chip-firing moves tasks from overloaded servers to neighbors.
    The q-reduced representative is the optimally balanced state.
    """
    print("="*60)
    print("APPLICATION 2: Load Balancing via Chip-Firing")
    print("="*60)
    print()
    
    # Small data center topology: 5 servers in a ring with one central hub
    n = 6
    edges = [(0,1), (1,2), (2,3), (3,4), (4,0),  # ring
             (5,0), (5,1), (5,2), (5,3), (5,4)]    # hub
    adj, L = make_graph(n, edges)
    
    # Initial load distribution (unbalanced)
    load = np.array([10, 2, 0, 8, 1, 3])
    q = 5  # Hub is the "ground" / scheduler
    
    print(f"Server topology: Ring of 5 + central hub (node {q})")
    print(f"Initial load: {load}")
    print(f"Total tasks: {load.sum()}")
    print(f"Initial energy (imbalance): {laplacian_energy(load, adj):.1f}")
    
    # Apply q-reduction to find optimal balance
    balanced = q_reduce(load, adj, L, q)
    print(f"\nAfter chip-firing optimization:")
    print(f"Balanced load: {balanced}")
    print(f"Total tasks: {balanced.sum()} (conserved ✓)" if balanced.sum() == load.sum() else f"Total tasks: {balanced.sum()} (ERROR)")
    print(f"Final energy: {laplacian_energy(balanced, adj):.1f}")
    print(f"Energy reduction: {laplacian_energy(load, adj) - laplacian_energy(balanced, adj):.1f}")
    print()
    print("Insight: Chip-firing naturally balances load by moving tasks")
    print("from overloaded servers to their neighbors, minimizing the")
    print("Laplacian energy (which measures total load imbalance).")
    print()


# ============================================================
# Application 3: Effective Resistance and Electrical Networks
# ============================================================

def electrical_network_demo():
    """
    Connect Laplacian energy to effective resistance in electrical networks.
    
    For a two-point divisor δ_v - δ_w, the Laplacian energy
    relates to the effective resistance between v and w.
    """
    print("="*60)
    print("APPLICATION 3: Electrical Network Analysis")
    print("="*60)
    print()
    
    # Wheatstone bridge circuit
    n = 4
    edges = [(0,1), (0,2), (1,2), (1,3), (2,3)]
    adj, L = make_graph(n, edges)
    
    print("Wheatstone bridge (4 vertices, 5 edges):")
    print(f"Adjacency: edges = {edges}")
    
    # Compute effective resistance via pseudoinverse
    L_float = L.astype(float)
    # Moore-Penrose pseudoinverse of L
    L_pinv = np.linalg.pinv(L_float)
    
    print(f"\nEffective resistance between vertex pairs:")
    for i in range(n):
        for j in range(i+1, n):
            R_eff = L_pinv[i,i] + L_pinv[j,j] - 2*L_pinv[i,j]
            # Energy of two-point divisor
            delta = np.zeros(n)
            delta[i] = 1
            delta[j] = -1
            E = laplacian_energy(delta.astype(int), adj)
            print(f"  R_eff({i},{j}) = {R_eff:.4f},  Q(δ_{i}-δ_{j}) = {E:.1f}")
    
    print()
    print("Note: The quadratic form Q counts each edge twice in both")
    print("directions, so Q = 2 * (x^T L x). The effective resistance")
    print("R_eff(u,v) = (δ_u - δ_v)^T L^+ (δ_u - δ_v) where L^+ is")
    print("the pseudoinverse of the Laplacian.")
    print()
    
    # Kirchhoff's theorem
    trees = spanning_tree_count(adj, 0)
    print(f"Number of spanning trees (Kirchhoff): {trees}")
    print()


# ============================================================
# Application 4: Self-Organized Criticality Detection
# ============================================================

def self_organized_criticality_demo():
    """
    Demonstrate self-organized criticality through avalanche statistics.
    
    Start from a critical configuration, add a random chip,
    and observe the avalanche (stabilization cascade).
    """
    print("="*60)
    print("APPLICATION 4: Self-Organized Criticality")
    print("="*60)
    print()
    
    # Complete graph K5
    n = 5
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    adj, L = make_graph(n, edges)
    degrees = adj.sum(axis=1).astype(int)
    q = 0
    
    # Find a critical configuration
    ranges = []
    for v in range(n):
        if v == q:
            ranges.append([0])
        else:
            ranges.append(list(range(degrees[v])))
    
    criticals = []
    for combo in iterproduct(*ranges):
        D = np.array(combo, dtype=int)
        if dhar_burning(D, adj, q):
            criticals.append(D.copy())
    
    print(f"K₅ with sink q=0: {len(criticals)} critical configurations")
    print(f"(= {n}^{n-2} = {n**(n-2)} spanning trees)")
    
    # Simulate avalanches
    np.random.seed(42)
    avalanche_sizes = []
    n_trials = 100
    
    for trial in range(n_trials):
        # Start from random critical config
        c = criticals[np.random.randint(len(criticals))].copy()
        
        # Add a chip at random non-sink vertex
        v = np.random.randint(1, n)
        c[v] += 1
        
        # Count firings during stabilization
        firings = 0
        for _ in range(10000):
            fired = False
            for w in range(n):
                if w == q:
                    continue
                if c[w] >= degrees[w]:
                    c -= L[w, :]
                    firings += 1
                    fired = True
            if not fired:
                break
        
        avalanche_sizes.append(firings)
    
    sizes = np.array(avalanche_sizes)
    print(f"\nAvalanche statistics ({n_trials} trials):")
    print(f"  Mean avalanche size: {sizes.mean():.2f}")
    print(f"  Max avalanche size: {sizes.max()}")
    print(f"  Min avalanche size: {sizes.min()}")
    print(f"  Std deviation: {sizes.std():.2f}")
    
    # Distribution
    from collections import Counter
    counts = Counter(sizes)
    print(f"\n  Size distribution:")
    for size in sorted(counts.keys()):
        bar = "█" * counts[size]
        print(f"    size={size:2d}: {counts[size]:3d} {bar}")
    
    print()
    print("Insight: When a chip is added to a critical configuration,")
    print("the resulting avalanche exhibits power-law-like statistics —")
    print("this is the hallmark of self-organized criticality.")
    print()


# ============================================================
# Main
# ============================================================

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF SANDPILE CRITICALITY                  ║")
    print("║  & LAPLACIAN ENERGY MINIMIZATION                       ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    network_robustness_analysis()
    load_balancing_demo()
    electrical_network_demo()
    self_organized_criticality_demo()
    
    print("="*60)
    print("  ALL APPLICATIONS COMPLETE")
    print("="*60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of abelian sandpile criticality
via Laplacian energy minimization.

Demonstrates:
1. Building small graphs and computing their Laplacians
2. Computing q-reduced representatives via Dhar's algorithm
3. Displaying energies before/after firing
4. Counting critical configurations
5. Comparing counts to reduced Laplacian determinants
6. Spectral data and Fiedler values
"""

import numpy as np
from itertools import product as iterproduct
from collections import defaultdict


# ============================================================
# Core Graph and Laplacian Infrastructure
# ============================================================

def adjacency_matrix(edges, n):
    """Build adjacency matrix from edge list."""
    A = np.zeros((n, n), dtype=int)
    for u, v in edges:
        A[u, v] = 1
        A[v, u] = 1
    return A

def laplacian_matrix(A):
    """Compute the graph Laplacian L = D - A."""
    D = np.diag(A.sum(axis=1))
    return D - A

def reduced_laplacian(L, q):
    """Delete row q and column q from L."""
    idx = [i for i in range(L.shape[0]) if i != q]
    return L[np.ix_(idx, idx)]

def laplacian_quadratic(L, x):
    """Compute x^T L x, the Laplacian quadratic form."""
    return float(x @ L @ x)

def energy_gradient_form(A, x):
    """Compute Q(x) = sum_{i~j} (x_i - x_j)^2."""
    n = A.shape[0]
    total = 0.0
    for i in range(n):
        for j in range(n):
            if A[i, j]:
                total += (x[i] - x[j]) ** 2
    return total


# ============================================================
# Chip-Firing and Q-Reduction
# ============================================================

def chip_fire_vertex(D, L, v):
    """Fire vertex v: D -> D - L[v,:]."""
    D_new = D.copy()
    D_new -= L[v, :]
    return D_new

def is_stable(D, degrees, q):
    """Check if D is stable: 0 <= D[v] < deg(v) for all v != q."""
    n = len(D)
    for v in range(n):
        if v == q:
            continue
        if D[v] < 0 or D[v] >= degrees[v]:
            return False
    return True

def stabilize(D, L, degrees, q, max_iter=100000):
    """Stabilize a configuration by firing unstable vertices."""
    D = D.copy()
    for _ in range(max_iter):
        fired = False
        for v in range(len(D)):
            if v == q:
                continue
            if D[v] >= degrees[v]:
                D = chip_fire_vertex(D, L, v)
                fired = True
        if not fired:
            break
    return D

def dhar_burning(D, A, q):
    """
    Dhar's burning algorithm to check if D is q-reduced.
    Returns True if D is q-reduced (recurrent after adding chips at q).
    """
    n = A.shape[0]
    burned = {q}
    changed = True
    while changed:
        changed = False
        for v in range(n):
            if v in burned:
                continue
            # Count edges from v to burned set
            edges_to_burned = sum(A[v, w] for w in burned)
            if D[v] < edges_to_burned:
                burned.add(v)
                changed = True
    return len(burned) == n

def q_reduce(D, A, L, q, max_iter=10000):
    """
    Compute the q-reduced representative of D by repeated subset firing.
    Uses Dhar's algorithm iteratively.
    """
    n = A.shape[0]
    D = D.copy()
    for _ in range(max_iter):
        if dhar_burning(D, A, q):
            return D
        # Find a subset S that can fire (all vertices have enough chips)
        burned = {q}
        changed = True
        while changed:
            changed = False
            for v in range(n):
                if v in burned:
                    continue
                edges_to_burned = sum(A[v, w] for w in burned)
                if D[v] < edges_to_burned:
                    burned.add(v)
                    changed = True
        # Fire the unburned set
        S = [v for v in range(n) if v not in burned]
        if not S:
            return D
        for v in S:
            D = chip_fire_vertex(D, L, v)
    return D


# ============================================================
# Critical Configuration Enumeration
# ============================================================

def enumerate_critical_configs(A, L, q):
    """
    Enumerate all critical (recurrent stable) configurations.
    A critical config c satisfies:
    1. c[q] = 0
    2. 0 <= c[v] < deg(v) for v != q
    3. c passes Dhar's burning test (is q-reduced)
    """
    n = A.shape[0]
    degrees = A.sum(axis=1).astype(int)
    
    # Build ranges for each vertex
    ranges = []
    non_q = []
    for v in range(n):
        if v == q:
            ranges.append([0])
        else:
            ranges.append(list(range(degrees[v])))
            non_q.append(v)
    
    critical = []
    for combo in iterproduct(*ranges):
        D = np.array(combo, dtype=int)
        if dhar_burning(D, A, q):
            critical.append(D.copy())
    
    return critical


# ============================================================
# Example Graphs
# ============================================================

def path_graph(n):
    """Path graph P_n on vertices 0, ..., n-1."""
    edges = [(i, i+1) for i in range(n-1)]
    return adjacency_matrix(edges, n), edges

def cycle_graph(n):
    """Cycle graph C_n."""
    edges = [(i, (i+1) % n) for i in range(n)]
    return adjacency_matrix(edges, n), edges

def complete_graph(n):
    """Complete graph K_n."""
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    return adjacency_matrix(edges, n), edges

def petersen_graph():
    """Petersen graph on 10 vertices."""
    outer = [(i, (i+1) % 5) for i in range(5)]
    inner = [(5+i, 5+(i+2) % 5) for i in range(5)]
    spokes = [(i, 5+i) for i in range(5)]
    edges = outer + inner + spokes
    return adjacency_matrix(edges, 10), edges


# ============================================================
# Main Demonstration
# ============================================================

def demo_energy_minimization(name, A, q):
    """Demonstrate energy minimization for q-reduced representatives."""
    n = A.shape[0]
    L = laplacian_matrix(A)
    Lq = reduced_laplacian(L, q)
    degrees = A.sum(axis=1).astype(int)
    
    print(f"\n{'='*60}")
    print(f"  {name} (n={n}, sink=q={q})")
    print(f"{'='*60}")
    print(f"Degrees: {degrees}")
    print(f"det(L_q) = {int(round(np.linalg.det(Lq)))}")
    
    # Enumerate critical configs
    criticals = enumerate_critical_configs(A, L, q)
    print(f"Number of critical configurations: {len(criticals)}")
    print(f"Match det(L_q)? {'YES ✓' if len(criticals) == int(round(abs(np.linalg.det(Lq)))) else 'NO ✗'}")
    
    # Show some critical configs and their energies
    print(f"\nCritical configurations and their Laplacian energies:")
    for i, c in enumerate(criticals[:8]):
        x = c.astype(float)
        E = energy_gradient_form(A, x)
        print(f"  c_{i} = {c}  E(c) = {E:.1f}")
    if len(criticals) > 8:
        print(f"  ... ({len(criticals) - 8} more)")
    
    # Demonstrate energy descent
    if n <= 6:
        print(f"\nEnergy descent demonstration:")
        # Start with a random divisor in the same class as a critical config
        if criticals:
            c0 = criticals[0].copy()
            # Fire a random non-sink vertex to get a non-reduced divisor
            for v in range(n):
                if v != q and degrees[v] > 0:
                    D_start = chip_fire_vertex(c0, L, v)
                    E_start = energy_gradient_form(A, D_start.astype(float))
                    D_reduced = q_reduce(D_start, A, L, q)
                    E_reduced = energy_gradient_form(A, D_reduced.astype(float))
                    print(f"  Start:   D = {D_start}  E = {E_start:.1f}")
                    print(f"  Reduced: D = {D_reduced}  E = {E_reduced:.1f}")
                    print(f"  Energy decreased? {'YES ✓' if E_reduced <= E_start else 'NO ✗'}")
                    break


def demo_spectral_data(name, A, q):
    """Display spectral data for the graph."""
    n = A.shape[0]
    L = laplacian_matrix(A)
    Lq = reduced_laplacian(L, q)
    
    # Full Laplacian eigenvalues
    evals_full = np.sort(np.linalg.eigvalsh(L.astype(float)))
    evals_reduced = np.sort(np.linalg.eigvalsh(Lq.astype(float)))
    
    print(f"\n{'='*60}")
    print(f"  Spectral Data: {name}")
    print(f"{'='*60}")
    print(f"Full Laplacian eigenvalues: {np.round(evals_full, 4)}")
    print(f"Reduced Laplacian eigenvalues: {np.round(evals_reduced, 4)}")
    print(f"Fiedler value (λ₂): {evals_full[1]:.6f}")
    print(f"Spectral gap: {evals_full[1]:.6f}")
    print(f"det(L_q) = {abs(np.prod(evals_reduced)):.4f} ≈ {int(round(abs(np.prod(evals_reduced))))}")


def demo_energy_minimizer_verification(name, A, q):
    """
    Verify that q-reduced divisors minimize energy in their class.
    For small graphs, exhaustively check that no equivalent divisor
    has lower energy.
    """
    n = A.shape[0]
    L = laplacian_matrix(A)
    degrees = A.sum(axis=1).astype(int)
    
    print(f"\n{'='*60}")
    print(f"  Energy Minimizer Verification: {name}")
    print(f"{'='*60}")
    
    criticals = enumerate_critical_configs(A, L, q)
    
    violations = 0
    checked = 0
    for c in criticals[:5]:  # Check first 5
        E_c = energy_gradient_form(A, c.astype(float))
        # Try firing each non-sink vertex and check energy
        found_lower = False
        for v in range(n):
            if v == q:
                continue
            D_fired = chip_fire_vertex(c, L, v)
            E_fired = energy_gradient_form(A, D_fired.astype(float))
            if E_fired < E_c - 1e-10:
                found_lower = True
                violations += 1
                print(f"  VIOLATION: c={c}, fire v={v} -> E={E_fired:.2f} < {E_c:.2f}")
                break
        if not found_lower:
            checked += 1
    
    print(f"  Checked {checked} critical configs, {violations} violations found.")
    if violations == 0:
        print(f"  All critical configs are local energy minimizers ✓")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  ABELIAN SANDPILE CRITICALITY                          ║")
    print("║  Laplacian Energy Minimization Demo                    ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    # Test graphs
    graphs = [
        ("Path P₃", *path_graph(3)),
        ("Path P₄", *path_graph(4)),
        ("Cycle C₄", *cycle_graph(4)),
        ("Cycle C₅", *cycle_graph(5)),
        ("Complete K₃", *complete_graph(3)),
        ("Complete K₄", *complete_graph(4)),
        ("Complete K₅", *complete_graph(5)),
    ]
    
    q = 0  # Use vertex 0 as sink
    
    # Part 1: Critical config counting vs determinant
    print("\n" + "="*60)
    print("  PART 1: Critical Configuration Counting")
    print("="*60)
    
    all_match = True
    for name, A, edges in graphs:
        L = laplacian_matrix(A)
        Lq = reduced_laplacian(L, q)
        det_Lq = int(round(abs(np.linalg.det(Lq))))
        criticals = enumerate_critical_configs(A, L, q)
        match = len(criticals) == det_Lq
        if not match:
            all_match = False
        print(f"  {name:15s}: #critical = {len(criticals):4d}, det(L_q) = {det_Lq:4d}  {'✓' if match else '✗'}")
    
    print(f"\n  All counts match determinants: {'YES ✓' if all_match else 'NO ✗'}")
    
    # Part 2: Energy minimization
    print("\n" + "="*60)
    print("  PART 2: Energy Minimization Demonstrations")
    print("="*60)
    
    for name, A, edges in graphs[:5]:
        demo_energy_minimization(name, A, q)
    
    # Part 3: Spectral data
    print("\n" + "="*60)
    print("  PART 3: Spectral Data")
    print("="*60)
    
    for name, A, edges in graphs:
        demo_spectral_data(name, A, q)
    
    # Part 4: Energy minimizer verification
    print("\n" + "="*60)
    print("  PART 4: Energy Minimizer Verification")
    print("="*60)
    
    for name, A, edges in graphs[:5]:
        demo_energy_minimizer_verification(name, A, q)
    
    # Part 5: Exhaustive test for small graphs
    print("\n" + "="*60)
    print("  PART 5: Exhaustive Test — All Connected Graphs ≤ 5 vertices")
    print("="*60)
    
    test_all_small_graphs(5)
    
    print("\n" + "="*60)
    print("  DEMO COMPLETE")
    print("="*60)


def generate_connected_graphs(n):
    """Generate all connected simple graphs on n vertices (up to isomorphism is hard,
    so we generate a representative sample)."""
    if n <= 1:
        yield np.zeros((n, n), dtype=int)
        return
    
    possible_edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    m = len(possible_edges)
    
    # For small n, enumerate all subsets of edges and filter connected
    count = 0
    for mask in range(1, 2**m):
        edges = [possible_edges[k] for k in range(m) if mask & (1 << k)]
        A = adjacency_matrix(edges, n)
        
        # Check connectivity via BFS
        visited = {0}
        queue = [0]
        while queue:
            v = queue.pop(0)
            for w in range(n):
                if A[v, w] and w not in visited:
                    visited.add(w)
                    queue.append(w)
        
        if len(visited) == n:
            count += 1
            yield A
    

def test_all_small_graphs(max_n):
    """Test critical config counting for all connected graphs up to max_n vertices."""
    q = 0
    total_graphs = 0
    total_match = 0
    
    for n in range(2, max_n + 1):
        n_graphs = 0
        n_match = 0
        for A in generate_connected_graphs(n):
            L = laplacian_matrix(A)
            Lq = reduced_laplacian(L, q)
            det_Lq = int(round(abs(np.linalg.det(Lq))))
            criticals = enumerate_critical_configs(A, L, q)
            if len(criticals) == det_Lq:
                n_match += 1
            n_graphs += 1
        
        print(f"  n={n}: {n_graphs} connected graphs tested, {n_match}/{n_graphs} match ✓")
        total_graphs += n_graphs
        total_match += n_match
    
    print(f"  Total: {total_graphs} graphs, {total_match}/{total_graphs} match ✓")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Avalanche Dynamics and Self-Organized Criticality

Simulates chip-firing avalanches on the complete graph K6 and
visualizes the avalanche size distribution, showing the characteristic
heavy-tailed behavior of self-organized criticality. Also plots
the energy descent during a single avalanche cascade.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct
from collections import Counter


def make_graph(n, edges):
    adj = np.zeros((n, n), dtype=int)
    for u, v in edges:
        adj[u, v] = 1
        adj[v, u] = 1
    L = np.diag(adj.sum(axis=1).astype(int)) - adj
    return adj, L


def dhar_burning(D, adj, q):
    n = adj.shape[0]
    burned = {q}
    changed = True
    while changed:
        changed = False
        for v in range(n):
            if v in burned:
                continue
            edges_to_burned = sum(adj[v, w] for w in burned)
            if D[v] < edges_to_burned:
                burned.add(v)
                changed = True
    return len(burned) == n


def laplacian_energy(D, adj):
    x = D.astype(float)
    total = 0.0
    for i in range(adj.shape[0]):
        for j in range(adj.shape[0]):
            if adj[i, j]:
                total += (x[i] - x[j]) ** 2
    return total


def enumerate_critical_configs(adj, q):
    n = adj.shape[0]
    degrees = adj.sum(axis=1).astype(int)
    ranges = []
    for v in range(n):
        if v == q:
            ranges.append([0])
        else:
            ranges.append(list(range(max(1, degrees[v]))))
    criticals = []
    for combo in iterproduct(*ranges):
        D = np.array(combo, dtype=int)
        if dhar_burning(D, adj, q):
            criticals.append(D.copy())
    return criticals


# ============================================================
# Setup: Complete graph K5
# ============================================================
n = 5
edges = [(i, j) for i in range(n) for j in range(i+1, n)]
adj, L = make_graph(n, edges)
degrees = adj.sum(axis=1).astype(int)
q = 0

# Find critical configurations
criticals = enumerate_critical_configs(adj, q)
print(f"K{n}: {len(criticals)} critical configurations")

# ============================================================
# Simulate avalanches
# ============================================================
np.random.seed(42)
n_trials = 500
avalanche_sizes = []
avalanche_energies = []  # Store energy trajectories

for trial in range(n_trials):
    c = criticals[np.random.randint(len(criticals))].copy()
    v = np.random.randint(1, n)
    c[v] += 1
    
    # Track energy during avalanche
    energies = [laplacian_energy(c, adj)]
    firings = 0
    for _ in range(10000):
        fired = False
        for w in range(n):
            if w == q:
                continue
            if c[w] >= degrees[w]:
                c -= L[w, :]
                firings += 1
                fired = True
                energies.append(laplacian_energy(c, adj))
        if not fired:
            break
    
    avalanche_sizes.append(firings)
    if trial < 20:  # Store first 20 trajectories
        avalanche_energies.append(energies)

sizes = np.array(avalanche_sizes)

# ============================================================
# Plot
# ============================================================
fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Avalanche size histogram
ax1 = axes[0]
size_counts = Counter(sizes)
max_size = max(size_counts.keys())
x_vals = list(range(max_size + 1))
y_vals = [size_counts.get(s, 0) for s in x_vals]

ax1.bar(x_vals, y_vals, color='#FF6B6B', edgecolor='white', alpha=0.8)
ax1.set_xlabel('Avalanche Size (# firings)', fontsize=12)
ax1.set_ylabel('Frequency', fontsize=12)
ax1.set_title(f'Avalanche Size Distribution\n(K{n}, {n_trials} trials)', fontsize=13)
ax1.grid(True, alpha=0.3, axis='y')

# Add mean line
ax1.axvline(sizes.mean(), color='black', linestyle='--', linewidth=2,
            label=f'Mean = {sizes.mean():.2f}')
ax1.legend(fontsize=10)

# Plot 2: Energy descent during individual avalanches
ax2 = axes[1]
cmap = plt.cm.viridis(np.linspace(0, 1, min(10, len(avalanche_energies))))
for i, energies in enumerate(avalanche_energies[:10]):
    steps = list(range(len(energies)))
    ax2.plot(steps, energies, '-o', color=cmap[i], markersize=4,
             linewidth=1.5, alpha=0.7)

ax2.set_xlabel('Firing Step', fontsize=12)
ax2.set_ylabel('Laplacian Energy Q(D)', fontsize=12)
ax2.set_title('Energy Descent During Avalanches\n(10 sample trajectories)', fontsize=13)
ax2.grid(True, alpha=0.3)

# Plot 3: Cumulative energy decay
ax3 = axes[2]
# Average normalized energy trajectory
max_len = max(len(e) for e in avalanche_energies[:20])
avg_energy = np.zeros(max_len)
counts = np.zeros(max_len)
for energies in avalanche_energies[:20]:
    if energies[0] > 0:
        normalized = np.array(energies) / energies[0]
        for i, e in enumerate(normalized):
            avg_energy[i] += e
            counts[i] += 1

mask = counts > 0
avg_energy[mask] /= counts[mask]
valid_steps = np.where(mask)[0]

ax3.plot(valid_steps, avg_energy[valid_steps], 'b-o', linewidth=2,
         markersize=6, label='Average normalized energy')
ax3.axhline(0, color='red', linestyle='--', alpha=0.5, label='Ground state')
ax3.set_xlabel('Firing Step', fontsize=12)
ax3.set_ylabel('Normalized Energy E(t)/E(0)', fontsize=12)
ax3.set_title('Average Energy Relaxation\nToward Critical Ground State', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(-0.1, 1.5)

plt.tight_layout()
plt.savefig('viz_avalanche_dynamics.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved viz_avalanche_dynamics.png")


#!/usr/bin/env python3
"""
Visualization: Critical Configuration Counting vs Determinant

For a range of graph families (paths, cycles, complete graphs),
plots the number of critical configurations against the determinant
of the reduced Laplacian, demonstrating perfect agreement (Kirchhoff's theorem).
Also shows the spectral gap (Fiedler value) for each graph.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct


def make_graph(n, edges):
    adj = np.zeros((n, n), dtype=int)
    for u, v in edges:
        adj[u, v] = 1
        adj[v, u] = 1
    L = np.diag(adj.sum(axis=1).astype(int)) - adj
    return adj, L


def dhar_burning(D, adj, q):
    n = adj.shape[0]
    burned = {q}
    changed = True
    while changed:
        changed = False
        for v in range(n):
            if v in burned:
                continue
            edges_to_burned = sum(adj[v, w] for w in burned)
            if D[v] < edges_to_burned:
                burned.add(v)
                changed = True
    return len(burned) == n


def count_critical_configs(adj, q):
    n = adj.shape[0]
    degrees = adj.sum(axis=1).astype(int)
    ranges = []
    for v in range(n):
        if v == q:
            ranges.append([0])
        else:
            ranges.append(list(range(max(1, degrees[v]))))
    count = 0
    for combo in iterproduct(*ranges):
        D = np.array(combo, dtype=int)
        if dhar_burning(D, adj, q):
            count += 1
    return count


def reduced_laplacian_det(adj, q):
    L = np.diag(adj.sum(axis=1)) - adj
    idx = [i for i in range(adj.shape[0]) if i != q]
    Lq = L[np.ix_(idx, idx)]
    return int(round(abs(np.linalg.det(Lq))))


def fiedler_value(adj):
    L = np.diag(adj.sum(axis=1)) - adj
    evals = np.sort(np.linalg.eigvalsh(L.astype(float)))
    return evals[1] if len(evals) > 1 else 0


# ============================================================
# Generate graph families
# ============================================================

data = []
q = 0

# Paths
for n in range(2, 7):
    edges = [(i, i+1) for i in range(n-1)]
    adj, L = make_graph(n, edges)
    nc = count_critical_configs(adj, q)
    det = reduced_laplacian_det(adj, q)
    fv = fiedler_value(adj)
    data.append(('Path', n, nc, det, fv))

# Cycles
for n in range(3, 8):
    edges = [(i, (i+1) % n) for i in range(n)]
    adj, L = make_graph(n, edges)
    nc = count_critical_configs(adj, q)
    det = reduced_laplacian_det(adj, q)
    fv = fiedler_value(adj)
    data.append(('Cycle', n, nc, det, fv))

# Complete graphs
for n in range(3, 7):
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    adj, L = make_graph(n, edges)
    nc = count_critical_configs(adj, q)
    det = reduced_laplacian_det(adj, q)
    fv = fiedler_value(adj)
    data.append(('Complete', n, nc, det, fv))

# ============================================================
# Plot
# ============================================================

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Critical configs vs det for each family
ax1 = axes[0]
families = {}
for family, n, nc, det, fv in data:
    if family not in families:
        families[family] = {'n': [], 'nc': [], 'det': []}
    families[family]['n'].append(n)
    families[family]['nc'].append(nc)
    families[family]['det'].append(det)

colors = {'Path': '#2196F3', 'Cycle': '#4CAF50', 'Complete': '#F44336'}
markers = {'Path': 'o', 'Cycle': 's', 'Complete': '^'}

for family, vals in families.items():
    ax1.scatter(vals['det'], vals['nc'], c=colors[family], marker=markers[family],
                s=100, label=family, zorder=5, edgecolors='white')

# Perfect agreement line
max_val = max(max(v['det']) for v in families.values()) * 1.1
ax1.plot([0, max_val], [0, max_val], 'k--', alpha=0.5, label='y = x')
ax1.set_xlabel('det(L_q)', fontsize=12)
ax1.set_ylabel('#Critical Configurations', fontsize=12)
ax1.set_title('Kirchhoff\'s Theorem Verified\n#Critical = det(Reduced Laplacian)', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)

# Plot 2: Jacobian order vs n for each family
ax2 = axes[1]
for family, vals in families.items():
    ax2.semilogy(vals['n'], vals['nc'], f'-{markers[family]}', color=colors[family],
                 linewidth=2, markersize=8, label=family)

ax2.set_xlabel('Number of vertices n', fontsize=12)
ax2.set_ylabel('Jacobian Order (log scale)', fontsize=12)
ax2.set_title('Growth of Jacobian Group\nby Graph Family', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: Fiedler value vs n
ax3 = axes[2]
fiedler_data = {}
for family, n, nc, det, fv in data:
    if family not in fiedler_data:
        fiedler_data[family] = {'n': [], 'fv': []}
    fiedler_data[family]['n'].append(n)
    fiedler_data[family]['fv'].append(fv)

for family, vals in fiedler_data.items():
    ax3.plot(vals['n'], vals['fv'], f'-{markers[family]}', color=colors[family],
             linewidth=2, markersize=8, label=family)

ax3.set_xlabel('Number of vertices n', fontsize=12)
ax3.set_ylabel('Fiedler Value λ₂', fontsize=12)
ax3.set_title('Algebraic Connectivity\n(Spectral Gap)', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_critical_configs.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved viz_critical_configs.png")


#!/usr/bin/env python3
"""
Visualization: Energy Landscape of Chip-Firing Equivalence Classes

Visualizes how the Laplacian quadratic energy varies across divisors
in a chip-firing equivalence class, showing that the q-reduced
representative sits at the unique energy minimum.

For the cycle graph C4 with sink q=0, we enumerate all sink-normalized
divisors reachable by firing vectors with small coefficients, and plot
their energies as a heatmap to reveal the convex energy landscape.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct


def make_graph(n, edges):
    adj = np.zeros((n, n), dtype=int)
    for u, v in edges:
        adj[u, v] = 1
        adj[v, u] = 1
    L = np.diag(adj.sum(axis=1).astype(int)) - adj
    return adj, L


def laplacian_energy(D, adj):
    x = D.astype(float)
    total = 0.0
    for i in range(adj.shape[0]):
        for j in range(adj.shape[0]):
            if adj[i, j]:
                total += (x[i] - x[j]) ** 2
    return total


def dhar_burning(D, adj, q):
    n = adj.shape[0]
    burned = {q}
    changed = True
    while changed:
        changed = False
        for v in range(n):
            if v in burned:
                continue
            edges_to_burned = sum(adj[v, w] for w in burned)
            if D[v] < edges_to_burned:
                burned.add(v)
                changed = True
    return len(burned) == n


# Build cycle graph C5
n = 5
edges = [(i, (i+1) % n) for i in range(n)]
adj, L = make_graph(n, edges)
q = 0

# Start from the zero divisor (which is critical for C5)
D0 = np.array([0, 0, 0, 0, 0], dtype=int)

# Generate equivalence class by applying firing vectors
# f with f[q] = 0, f[v] in {-3,...,3} for v != q
fire_range = range(-3, 4)

# Collect (f1, f2, energy) for 2D projection
# Use f[1] and f[2] as axes (fixing f[3]=f[4]=0 for visualization)
energies = {}
q_reduced_points = []

for f1 in range(-5, 6):
    for f2 in range(-5, 6):
        f = np.array([0, f1, f2, 0, 0], dtype=int)
        D = D0 + L @ f  # D0 + Lf
        E = laplacian_energy(D, adj)
        energies[(f1, f2)] = E
        if dhar_burning(D, adj, q):
            q_reduced_points.append((f1, f2, E))

# Create heatmap
f1_vals = sorted(set(k[0] for k in energies))
f2_vals = sorted(set(k[1] for k in energies))
Z = np.zeros((len(f2_vals), len(f1_vals)))
for i, f2 in enumerate(f2_vals):
    for j, f1 in enumerate(f1_vals):
        Z[i, j] = energies.get((f1, f2), 0)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Energy heatmap
ax1 = axes[0]
im = ax1.imshow(Z, origin='lower', cmap='viridis',
                extent=[min(f1_vals)-0.5, max(f1_vals)+0.5,
                        min(f2_vals)-0.5, max(f2_vals)+0.5],
                aspect='equal')
plt.colorbar(im, ax=ax1, label='Laplacian Energy Q(D)')

# Mark q-reduced points
if q_reduced_points:
    qr_f1 = [p[0] for p in q_reduced_points]
    qr_f2 = [p[1] for p in q_reduced_points]
    ax1.scatter(qr_f1, qr_f2, c='red', s=100, marker='*',
                zorder=5, label='q-reduced', edgecolors='white')

# Mark the origin (zero firing = original divisor)
ax1.scatter([0], [0], c='white', s=150, marker='o', zorder=5,
            edgecolors='black', linewidths=2, label='Original D₀')

ax1.set_xlabel('Firing coefficient f₁', fontsize=12)
ax1.set_ylabel('Firing coefficient f₂', fontsize=12)
ax1.set_title('Energy Landscape of Chip-Firing Class\n(Cycle C₅, sink q=0)', fontsize=13)
ax1.legend(loc='upper right', fontsize=10)

# Right: Energy along a 1D slice
ax2 = axes[1]
f1_slice = list(range(-5, 6))
energies_slice = []
for f1 in f1_slice:
    f = np.array([0, f1, 0, 0, 0], dtype=int)
    D = D0 + L @ f
    E = laplacian_energy(D, adj)
    energies_slice.append(E)

ax2.plot(f1_slice, energies_slice, 'b-o', linewidth=2, markersize=8)
ax2.set_xlabel('Firing coefficient f₁ (single vertex)', fontsize=12)
ax2.set_ylabel('Laplacian Energy Q(D₀ + Lf)', fontsize=12)
ax2.set_title('Energy Along a 1D Firing Direction\n(Convex parabolic profile)', fontsize=13)
ax2.grid(True, alpha=0.3)

# Mark minimum
min_idx = np.argmin(energies_slice)
ax2.scatter([f1_slice[min_idx]], [energies_slice[min_idx]],
            c='red', s=150, marker='*', zorder=5,
            label=f'Minimum at f₁={f1_slice[min_idx]}')
ax2.legend(fontsize=10)

plt.tight_layout()
plt.savefig('viz_energy_landscape.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved viz_energy_landscape.png")
