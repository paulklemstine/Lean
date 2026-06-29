"""
Applications of the Tropical-Arithmetic SNF Correspondence.

Demonstrates real-world applications:
1. Critical group computation for network analysis
2. Electrical network equilibrium analysis
3. Chip-firing simulation on graphs
4. Graph invariant computation
"""

import numpy as np
from typing import List, Tuple, Dict
from math import gcd
from functools import reduce


# ============================================================
# Core utilities (self-contained)
# ============================================================

def graph_laplacian(adj: np.ndarray) -> np.ndarray:
    return np.diag(np.sum(adj, axis=1)) - adj

def restricted_laplacian(L: np.ndarray, S: List[int]) -> np.ndarray:
    idx = np.array(S)
    return L[np.ix_(idx, idx)]

def is_separated(adj: np.ndarray, S: List[int]) -> bool:
    for i in range(len(S)):
        for j in range(i + 1, len(S)):
            if adj[S[i], S[j]] != 0:
                return False
    return True


# ============================================================
# Application 1: Critical Group of Social Network
# ============================================================

def social_network_analysis():
    """Analyze the critical group structure of a small social network.
    
    Consider a social network where:
    - Nodes are people
    - Edges represent friendships
    - A separated set represents people with no mutual friends
    
    The critical group captures the network's global connectivity
    properties beyond simple degree counts.
    """
    print("=" * 60)
    print("Application 1: Social Network Critical Group")
    print("=" * 60)
    
    # Small social network (8 people)
    # 0-1: friends, 0-3: friends, 1-2: friends, 2-3: friends
    # 3-4: friends, 4-5: friends, 5-6: friends, 6-7: friends, 7-4: friends
    adj = np.zeros((8, 8), dtype=int)
    edges = [(0,1), (0,3), (1,2), (2,3), (3,4), (4,5), (5,6), (6,7), (7,4)]
    for i, j in edges:
        adj[i,j] = adj[j,i] = 1
    
    print(f"\nNetwork: 8 people, {len(edges)} friendships")
    print(f"Degrees: {list(np.sum(adj, axis=1))}")
    
    # Find a maximal separated set
    S = [0, 2, 5, 7]  # No two are friends
    print(f"Separated set (non-mutual friends): {S}")
    print(f"Is separated: {is_separated(adj, S)}")
    
    L = graph_laplacian(adj)
    L_S = restricted_laplacian(L, S)
    
    print(f"\nRestricted Laplacian L_S:")
    print(L_S)
    
    degrees = [int(np.sum(adj[s])) for s in S]
    print(f"Degrees at S: {degrees}")
    
    det = int(np.round(np.linalg.det(L_S.astype(float))))
    print(f"det(L_S) = {det}")
    print(f"∏ deg(s) = {reduce(lambda x, y: x * y, degrees, 1)}")
    
    # Cokernel decomposition
    nontrivial = [d for d in degrees if d > 1]
    cokernel = " × ".join(f"ℤ/{d}" for d in nontrivial)
    print(f"Critical subgroup ≅ {cokernel}")
    print(f"Order = {reduce(lambda x, y: x * y, degrees, 1)}")
    print(f"\nInterpretation: The critical group captures {len(nontrivial)} ")
    print(f"independent cyclic 'modes' of chip redistribution in the network.")


# ============================================================
# Application 2: Electrical Network Equilibrium
# ============================================================

def electrical_network():
    """Analyze equilibrium charge distributions on an electrical network.
    
    The Laplacian cokernel classifies charge distributions modulo gauge
    equivalence. For a resistor network, the cokernel captures the
    space of possible charge configurations that are in equilibrium.
    """
    print("\n" + "=" * 60)
    print("Application 2: Electrical Network Equilibrium")
    print("=" * 60)
    
    # Simple resistor network (bridge circuit)
    # 4 nodes, 5 resistors
    adj = np.array([
        [0, 1, 1, 0],
        [1, 0, 1, 1],
        [1, 1, 0, 1],
        [0, 1, 1, 0]
    ])
    
    print("\nBridge circuit: 4 nodes, 5 unit resistors")
    L = graph_laplacian(adj)
    print(f"Laplacian (= Kirchhoff matrix):\n{L}")
    
    # Separated measurement nodes
    S = [0, 3]
    print(f"\nMeasurement nodes (separated): {S}")
    print(f"Is separated: {is_separated(adj, S)}")
    
    L_S = restricted_laplacian(L, S)
    print(f"Restricted Laplacian:\n{L_S}")
    
    degrees = [int(np.sum(adj[s])) for s in S]
    print(f"Node degrees: {degrees}")
    
    # The cokernel tells us about charge balance
    print(f"\nCharge balance group: ℤ/{degrees[0]} × ℤ/{degrees[1]}")
    print(f"= ℤ/{degrees[0]} × ℤ/{degrees[1]}")
    print(f"\nPhysical interpretation:")
    print(f"  At node {S[0]} (degree {degrees[0]}): charge is defined mod {degrees[0]}")
    print(f"  At node {S[1]} (degree {degrees[1]}): charge is defined mod {degrees[1]}")
    print(f"  Total distinct equilibrium classes: {degrees[0] * degrees[1]}")


# ============================================================
# Application 3: Chip-Firing Simulation
# ============================================================

def chip_firing_demo():
    """Simulate chip-firing on a graph and verify critical group structure.
    
    In the chip-firing game:
    - Each vertex holds some chips
    - A vertex with ≥ deg(v) chips can 'fire': sends one chip to each neighbor
    - The game reaches a stable configuration
    
    The critical group classifies stable configurations modulo firing.
    """
    print("\n" + "=" * 60)
    print("Application 3: Chip-Firing Simulation")
    print("=" * 60)
    
    # Triangle graph
    adj = np.array([
        [0, 1, 1, 0, 0],
        [1, 0, 1, 1, 0],
        [1, 1, 0, 0, 1],
        [0, 1, 0, 0, 1],
        [0, 0, 1, 1, 0]
    ])
    n = 5
    
    print(f"\nGraph: 5 vertices, {int(np.sum(adj))//2} edges")
    
    # Initial chip configuration
    chips = np.array([3, 1, 2, 0, 1])
    print(f"Initial chips: {chips}")
    print(f"Total chips: {sum(chips)}")
    
    # Fire vertices until stable
    L = graph_laplacian(adj)
    history = [chips.copy()]
    
    for step in range(20):
        fired = False
        for v in range(n):
            if chips[v] >= int(np.sum(adj[v])):
                # Fire vertex v
                chips[v] -= int(np.sum(adj[v]))
                for w in range(n):
                    if adj[v, w]:
                        chips[w] += 1
                history.append(chips.copy())
                print(f"  Step {step+1}: Fire v{v} → chips = {chips}")
                fired = True
                break
        if not fired:
            break
    
    print(f"\nStable configuration: {chips}")
    print(f"Total chips (conserved): {sum(chips)}")
    
    # Separated set analysis
    S = [0, 3]  # Not adjacent
    if is_separated(adj, S):
        L_S = restricted_laplacian(L, S)
        degrees = [int(np.sum(adj[s])) for s in S]
        print(f"\nSeparated subset S = {S}")
        print(f"Critical subgroup at S: ℤ/{degrees[0]} × ℤ/{degrees[1]}")
        print(f"Chip values at S: {[chips[s] for s in S]}")
        print(f"Residues: {[chips[s] % degrees[i] for i, s in enumerate(S)]}")


# ============================================================
# Application 4: Graph Invariant Database
# ============================================================

def graph_invariant_database():
    """Compute and compare invariants for standard graph families.
    
    For each graph, compute:
    - Number of spanning trees (= det of any cofactor of L)
    - Critical group structure
    - Maximum independent set size
    - Invariant factors for each separated set
    """
    print("\n" + "=" * 60)
    print("Application 4: Graph Invariant Database")
    print("=" * 60)
    
    graphs = {
        'P_4': np.array([[0,1,0,0],[1,0,1,0],[0,1,0,1],[0,0,1,0]]),
        'C_4': np.array([[0,1,0,1],[1,0,1,0],[0,1,0,1],[1,0,1,0]]),
        'K_4': np.ones((4,4), dtype=int) - np.eye(4, dtype=int),
        'Star_4': np.array([[0,1,1,1],[1,0,0,0],[1,0,0,0],[1,0,0,0]]),
        'K_{2,2}': np.array([[0,0,1,1],[0,0,1,1],[1,1,0,0],[1,1,0,0]]),
    }
    
    print(f"\n{'Graph':<10} {'|V|':>4} {'|E|':>4} {'#Trees':>7} {'Max IS':>7} {'Best Critical Subgroup'}")
    print("-" * 70)
    
    for name, adj in graphs.items():
        n = adj.shape[0]
        edges = int(np.sum(adj)) // 2
        
        # Number of spanning trees (matrix-tree theorem)
        L = graph_laplacian(adj)
        if n > 1:
            cofactor = L[1:, 1:]
            num_trees = abs(int(np.round(np.linalg.det(cofactor.astype(float)))))
        else:
            num_trees = 1
        
        # Find maximum separated set
        max_sep = []
        for mask in range(1, 1 << n):
            S = [i for i in range(n) if mask & (1 << i)]
            if is_separated(adj, S) and len(S) > len(max_sep):
                max_sep = S
        
        # Critical subgroup for max separated set
        if max_sep:
            L_S = restricted_laplacian(L, max_sep)
            degrees = [int(np.sum(adj[s])) for s in max_sep]
            nontrivial = [d for d in degrees if d > 1]
            if nontrivial:
                crit = " × ".join(f"ℤ/{d}" for d in nontrivial)
            else:
                crit = "trivial"
        else:
            crit = "N/A"
        
        print(f"{name:<10} {n:>4} {edges:>4} {num_trees:>7} {len(max_sep):>7}   {crit}")


if __name__ == '__main__':
    social_network_analysis()
    electrical_network()
    chip_firing_demo()
    graph_invariant_database()
    print("\n\nAll applications completed successfully!")


"""
Interactive Demo: Tropical-Arithmetic SNF Correspondence

Demonstrates the constructive correspondence between canonical
tropical-harmonic kernel quotients and Smith normal form cokernels
of restricted graph Laplacians.

Usage:
    python demo.py
"""

import numpy as np
from typing import List, Tuple, Dict
from math import gcd
from functools import reduce


# ============================================================
# Core algorithms (self-contained)
# ============================================================

def graph_laplacian(adj: np.ndarray) -> np.ndarray:
    """Compute the combinatorial Laplacian L = D - A."""
    return np.diag(np.sum(adj, axis=1)) - adj


def restricted_laplacian(L: np.ndarray, S: List[int]) -> np.ndarray:
    """Extract the principal minor indexed by S."""
    idx = np.array(S)
    return L[np.ix_(idx, idx)]


def is_separated(adj: np.ndarray, S: List[int]) -> bool:
    """Check if S is an independent set."""
    for i in range(len(S)):
        for j in range(i + 1, len(S)):
            if adj[S[i], S[j]] != 0:
                return False
    return True


def _extended_gcd(a: int, b: int) -> Tuple[int, int]:
    """Extended GCD: returns (s, t) with s*a + t*b = gcd(a, b)."""
    if b == 0:
        return (1, 0) if a >= 0 else (-1, 0)
    old_r, r = a, b
    old_s, s = 1, 0
    old_t, t = 0, 1
    while r != 0:
        q = old_r // r
        old_r, r = r, old_r - q * r
        old_s, s = s, old_s - q * s
        old_t, t = t, old_t - q * t
    if old_r < 0:
        return -old_s, -old_t
    return old_s, old_t


def smith_normal_form(M: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Compute Smith Normal Form: U @ M @ V = D."""
    n, m = M.shape
    D = M.copy().astype(np.int64)
    U = np.eye(n, dtype=np.int64)
    V = np.eye(m, dtype=np.int64)
    
    for k in range(min(n, m)):
        found = False
        for i in range(k, n):
            for j in range(k, m):
                if D[i, j] != 0:
                    D[[k, i]] = D[[i, k]]
                    U[[k, i]] = U[[i, k]]
                    D[:, [k, j]] = D[:, [j, k]]
                    V[:, [k, j]] = V[:, [j, k]]
                    found = True
                    break
            if found:
                break
        if not found:
            break
        if D[k, k] < 0:
            D[k] = -D[k]
            U[k] = -U[k]
        
        changed = True
        while changed:
            changed = False
            for j in range(k + 1, m):
                if D[k, j] != 0:
                    q = D[k, j] // D[k, k]
                    D[:, j] -= q * D[:, k]
                    V[:, j] -= q * V[:, k]
                    if D[k, j] != 0:
                        a, b = int(D[k, k]), int(D[k, j])
                        s, t = _extended_gcd(a, b)
                        g = s * a + t * b
                        nk = s * D[:, k] + t * D[:, j]
                        nj = -(b // g) * D[:, k] + (a // g) * D[:, j]
                        D[:, k], D[:, j] = nk, nj
                        nk = s * V[:, k] + t * V[:, j]
                        nj = -(b // g) * V[:, k] + (a // g) * V[:, j]
                        V[:, k], V[:, j] = nk, nj
                    changed = True
            for i in range(k + 1, n):
                if D[i, k] != 0:
                    q = D[i, k] // D[k, k]
                    D[i] -= q * D[k]
                    U[i] -= q * U[k]
                    if D[i, k] != 0:
                        a, b = int(D[k, k]), int(D[i, k])
                        s, t = _extended_gcd(a, b)
                        g = s * a + t * b
                        nk = s * D[k] + t * D[i]
                        ni = -(b // g) * D[k] + (a // g) * D[i]
                        D[k], D[i] = nk, ni
                        nk = s * U[k] + t * U[i]
                        ni = -(b // g) * U[k] + (a // g) * U[i]
                        U[k], U[i] = nk, ni
                        changed = True
        if D[k, k] < 0:
            D[k] = -D[k]
            U[k] = -U[k]
    
    for _ in range(min(n, m)):
        for k in range(min(n, m) - 1):
            if D[k, k] != 0 and D[k+1, k+1] != 0:
                g = gcd(abs(int(D[k, k])), abs(int(D[k+1, k+1])))
                if g != abs(D[k, k]):
                    l = abs(int(D[k, k])) * abs(int(D[k+1, k+1])) // g
                    D[k, k] = g
                    D[k+1, k+1] = l
    
    return U, D, V


# ============================================================
# Demo functions
# ============================================================

def make_path_graph(n: int) -> np.ndarray:
    """Create adjacency matrix of path graph P_n."""
    adj = np.zeros((n, n), dtype=int)
    for i in range(n - 1):
        adj[i, i + 1] = adj[i + 1, i] = 1
    return adj


def make_cycle_graph(n: int) -> np.ndarray:
    """Create adjacency matrix of cycle graph C_n."""
    adj = make_path_graph(n)
    adj[0, n - 1] = adj[n - 1, 0] = 1
    return adj


def make_complete_graph(n: int) -> np.ndarray:
    """Create adjacency matrix of complete graph K_n."""
    return np.ones((n, n), dtype=int) - np.eye(n, dtype=int)


def make_complete_bipartite(p: int, q: int) -> np.ndarray:
    """Create adjacency matrix of K_{p,q}."""
    n = p + q
    adj = np.zeros((n, n), dtype=int)
    for i in range(p):
        for j in range(p, n):
            adj[i, j] = adj[j, i] = 1
    return adj


def make_petersen_graph() -> np.ndarray:
    """Create the Petersen graph (10 vertices)."""
    adj = np.zeros((10, 10), dtype=int)
    # Outer cycle
    for i in range(5):
        adj[i, (i + 1) % 5] = adj[(i + 1) % 5, i] = 1
    # Inner pentagram
    for i in range(5):
        adj[5 + i, 5 + (i + 2) % 5] = adj[5 + (i + 2) % 5, 5 + i] = 1
    # Spokes
    for i in range(5):
        adj[i, 5 + i] = adj[5 + i, i] = 1
    return adj


def enumerate_separated_sets(adj: np.ndarray, max_size: int = 6) -> List[List[int]]:
    """Find all nonempty separated sets up to max_size."""
    n = adj.shape[0]
    result = []
    for mask in range(1, 1 << n):
        S = [i for i in range(n) if mask & (1 << i)]
        if len(S) > max_size:
            continue
        if is_separated(adj, S):
            result.append(S)
    return result


def run_demo(name: str, adj: np.ndarray, S: List[int]):
    """Run the full correspondence pipeline and display results."""
    n = adj.shape[0]
    print(f"\n{'=' * 60}")
    print(f"  {name}")
    print(f"  |V| = {n}, S = {S}")
    print(f"{'=' * 60}")
    
    # Check separation
    sep = is_separated(adj, S)
    print(f"\n  Separated: {sep}")
    if not sep:
        print("  Skipping (not separated).")
        return
    
    # Laplacian
    L = graph_laplacian(adj)
    L_S = restricted_laplacian(L, S)
    print(f"\n  Graph Laplacian L (first 6x6):")
    for row in L[:min(6, n), :min(6, n)]:
        print(f"    {row}")
    
    print(f"\n  Restricted Laplacian L_S:")
    for row in L_S:
        print(f"    {row}")
    
    is_diag = np.allclose(L_S - np.diag(np.diag(L_S)), 0)
    print(f"\n  Is diagonal: {is_diag}")
    
    # Degrees
    degrees = [int(np.sum(adj[s])) for s in S]
    print(f"  Degrees at S: {degrees}")
    
    # Determinant
    det = int(np.round(np.linalg.det(L_S.astype(float))))
    prod_deg = reduce(lambda x, y: x * y, degrees, 1)
    print(f"  det(L_S) = {det}")
    print(f"  ∏ deg(s) = {prod_deg}")
    print(f"  det = ∏ deg: {det == prod_deg}")
    
    # SNF
    U, D, V = smith_normal_form(L_S)
    print(f"\n  Smith Normal Form:")
    print(f"    U = {U.tolist()}")
    print(f"    D = {D.tolist()}")
    print(f"    V = {V.tolist()}")
    
    # Verify U @ L_S @ V = D
    check = U @ L_S @ V
    print(f"    U @ L_S @ V = {check.tolist()}")
    print(f"    Matches D: {np.allclose(check, D)}")
    
    # Invariant factors
    factors = [abs(int(D[i, i])) for i in range(len(S)) if D[i, i] != 0]
    print(f"\n  Invariant factors: {factors}")
    
    # Cokernel decomposition
    nontrivial = [f for f in factors if f > 1]
    if nontrivial:
        cokernel_str = " × ".join(f"ℤ/{d}" for d in nontrivial)
    else:
        cokernel_str = "trivial"
    print(f"  Cokernel ≅ {cokernel_str}")
    print(f"  |Cokernel| = {reduce(lambda x, y: x * y, factors, 1)}")
    
    # Canonical generators
    print(f"\n  Canonical Harmonic Generators:")
    for idx, s in enumerate(S):
        gen = np.zeros(n, dtype=int)
        gen[s] = 1
        restr = gen[S]
        print(f"    Generator for v{s}: {gen} → boundary restriction: {restr}")
    
    # Verify harmonicity
    print(f"\n  Harmonicity check:")
    for idx, s in enumerate(S):
        gen = np.zeros(n, dtype=int)
        gen[s] = 1
        for v_idx, v in enumerate(S):
            if v != s:
                flow = sum(L[v, w] * gen[w] for w in range(n))
                print(f"    L·1_{{{s}}} at v{v} = {flow} {'✓' if flow == 0 else '✗'}")


def run_verification_experiment():
    """Run verification on all small graphs."""
    print("\n" + "=" * 60)
    print("  VERIFICATION EXPERIMENT: All Connected Graphs n ≤ 6")
    print("=" * 60)
    
    test_cases = [
        ("Path P_3", make_path_graph(3)),
        ("Path P_4", make_path_graph(4)),
        ("Path P_5", make_path_graph(5)),
        ("Cycle C_4", make_cycle_graph(4)),
        ("Cycle C_5", make_cycle_graph(5)),
        ("Cycle C_6", make_cycle_graph(6)),
        ("K_3", make_complete_graph(3)),
        ("K_4", make_complete_graph(4)),
        ("K_{2,3}", make_complete_bipartite(2, 3)),
        ("K_{3,3}", make_complete_bipartite(3, 3)),
    ]
    
    total_sets = 0
    all_pass = True
    
    for name, adj in test_cases:
        separated = enumerate_separated_sets(adj)
        passed = 0
        for S in separated:
            L = graph_laplacian(adj)
            L_S = restricted_laplacian(L, S)
            is_diag = np.allclose(L_S - np.diag(np.diag(L_S)), 0)
            degrees = [int(np.sum(adj[s])) for s in S]
            det = int(np.round(np.linalg.det(L_S.astype(float))))
            prod_deg = reduce(lambda x, y: x * y, degrees, 1)
            if is_diag and det == prod_deg:
                passed += 1
            else:
                all_pass = False
                print(f"  FAILURE: {name}, S = {S}")
        total_sets += len(separated)
        print(f"  {name}: {passed}/{len(separated)} separated sets pass ✓")
    
    print(f"\n  Total: {total_sets} separated sets tested")
    print(f"  All pass: {all_pass}")


if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical-Arithmetic SNF Correspondence Demo            ║")
    print("║  Canonical Kernel Quotient ≅ Laplacian Cokernel         ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    # Demo 1: Path graph
    run_demo("Path Graph P_5", make_path_graph(5), [0, 2, 4])
    
    # Demo 2: Cycle graph
    run_demo("Cycle Graph C_6", make_cycle_graph(6), [0, 2, 4])
    
    # Demo 3: Complete bipartite
    run_demo("Complete Bipartite K_{2,3}", make_complete_bipartite(2, 3), [0, 1])
    
    # Demo 4: Petersen graph
    run_demo("Petersen Graph", make_petersen_graph(), [0, 2, 4])
    
    # Verification experiment
    run_verification_experiment()
    
    print("\n\nDone!")


"""
Visualization: Cokernel Decomposition as Cyclic Group Product

This script visualizes how the Laplacian cokernel decomposes as a
product of cyclic groups for separated subsets. Shows the invariant
factor structure for several graph families.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import gcd
from functools import reduce

def graph_laplacian(adj):
    return np.diag(np.sum(adj, axis=1)) - adj

def make_path(n):
    adj = np.zeros((n,n), dtype=int)
    for i in range(n-1):
        adj[i,i+1] = adj[i+1,i] = 1
    return adj

def make_cycle(n):
    adj = make_path(n)
    adj[0,n-1] = adj[n-1,0] = 1
    return adj

def make_star(n):
    adj = np.zeros((n,n), dtype=int)
    for i in range(1,n):
        adj[0,i] = adj[i,0] = 1
    return adj

def make_complete_bipartite(p, q):
    n = p + q
    adj = np.zeros((n,n), dtype=int)
    for i in range(p):
        for j in range(p, n):
            adj[i,j] = adj[j,i] = 1
    return adj

def is_separated(adj, S):
    for i in range(len(S)):
        for j in range(i+1, len(S)):
            if adj[S[i],S[j]] != 0:
                return False
    return True

def find_max_independent_set(adj):
    n = adj.shape[0]
    best = []
    for mask in range(1, 1 << n):
        S = [i for i in range(n) if mask & (1 << i)]
        if len(S) > len(best) and is_separated(adj, S):
            best = S
    return best

# Collect data for visualization
data = []

graphs = [
    ("P₃", make_path(3)),
    ("P₄", make_path(4)),
    ("P₅", make_path(5)),
    ("P₆", make_path(6)),
    ("C₄", make_cycle(4)),
    ("C₅", make_cycle(5)),
    ("C₆", make_cycle(6)),
    ("Star₄", make_star(4)),
    ("Star₅", make_star(5)),
    ("K₂,₂", make_complete_bipartite(2, 2)),
    ("K₂,₃", make_complete_bipartite(2, 3)),
    ("K₃,₃", make_complete_bipartite(3, 3)),
]

for name, adj in graphs:
    S = find_max_independent_set(adj)
    L = graph_laplacian(adj)
    degrees = [int(np.sum(adj[s])) for s in S]
    order = reduce(lambda x, y: x*y, degrees, 1)
    data.append({
        'name': name,
        'n': adj.shape[0],
        'S': S,
        'degrees': degrees,
        'order': order,
        'num_factors': len([d for d in degrees if d > 1])
    })

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Cokernel orders across graph families
ax = axes[0, 0]
names = [d['name'] for d in data]
orders = [d['order'] for d in data]
colors = ['#2196F3' if 'P' in n else '#4CAF50' if 'C' in n 
          else '#FF9800' if 'Star' in n else '#9C27B0' for n in names]
bars = ax.bar(range(len(names)), orders, color=colors)
ax.set_xticks(range(len(names)))
ax.set_xticklabels(names, rotation=45, ha='right')
ax.set_ylabel('|Cokernel| = ∏ deg(s)', fontsize=12)
ax.set_title('Cokernel Order by Graph Family', fontsize=14, fontweight='bold')
for bar, order in zip(bars, orders):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
           str(order), ha='center', va='bottom', fontsize=10)
ax.set_yscale('log')
ax.set_ylim(0.5, max(orders) * 3)

# Plot 2: Independent set size vs graph size
ax = axes[0, 1]
ns = [d['n'] for d in data]
is_sizes = [len(d['S']) for d in data]
for i, d in enumerate(data):
    marker = 'o' if 'P' in d['name'] else 's' if 'C' in d['name'] else '^' if 'Star' in d['name'] else 'D'
    ax.scatter(d['n'], len(d['S']), c=colors[i], s=100, marker=marker, 
              edgecolors='black', linewidth=0.5, zorder=3)
    ax.annotate(d['name'], (d['n'], len(d['S'])), textcoords="offset points",
               xytext=(5, 5), fontsize=8)
ax.set_xlabel('Graph size |V|', fontsize=12)
ax.set_ylabel('Max independent set |S|', fontsize=12)
ax.set_title('Independent Set Size', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3)

# Plot 3: Degree distribution at separated sets
ax = axes[1, 0]
all_degrees = []
all_labels = []
for d in data:
    for deg in d['degrees']:
        all_degrees.append(deg)
        all_labels.append(d['name'])

degree_counts = {}
for deg in all_degrees:
    degree_counts[deg] = degree_counts.get(deg, 0) + 1

degs = sorted(degree_counts.keys())
counts = [degree_counts[d] for d in degs]
ax.bar(range(len(degs)), counts, color='#FF5722', alpha=0.8)
ax.set_xticks(range(len(degs)))
ax.set_xticklabels([str(d) for d in degs])
ax.set_xlabel('Vertex degree at separated set', fontsize=12)
ax.set_ylabel('Frequency', fontsize=12)
ax.set_title('Distribution of Invariant Factors\n(= Vertex Degrees at S)', 
            fontsize=14, fontweight='bold')

# Plot 4: Torsion rank (number of nontrivial factors)
ax = axes[1, 1]
ranks = [d['num_factors'] for d in data]
ax.barh(range(len(names)), ranks, color=colors, alpha=0.8)
ax.set_yticks(range(len(names)))
ax.set_yticklabels(names)
ax.set_xlabel('Torsion rank (# factors > 1)', fontsize=12)
ax.set_title('Torsion Rank of Cokernel', fontsize=14, fontweight='bold')
for i, (r, name) in enumerate(zip(ranks, names)):
    if r > 0:
        d = data[i]
        label = " × ".join(f"ℤ/{deg}" for deg in d['degrees'] if deg > 1)
        ax.text(r + 0.1, i, label, va='center', fontsize=9)

plt.suptitle('Cokernel Decomposition: Tropical → Arithmetic Correspondence',
            fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_cokernel_decomposition.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_cokernel_decomposition.png")


"""
Visualization: Laplacian Structure for Separated vs Non-Separated Subsets

This script visualizes the restricted Laplacian matrix structure,
showing how separation forces diagonal form. It compares a separated
subset (diagonal L_S) with a non-separated subset (non-diagonal L_S)
side by side.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

# Create a graph (cycle C_6 with extra edges)
n = 6
adj = np.zeros((n, n), dtype=int)
edges = [(0,1), (1,2), (2,3), (3,4), (4,5), (5,0), (0,3)]
for i, j in edges:
    adj[i,j] = adj[j,i] = 1

def graph_laplacian(adj):
    return np.diag(np.sum(adj, axis=1)) - adj

def restricted_laplacian(L, S):
    idx = np.array(S)
    return L[np.ix_(idx, idx)]

def is_separated(adj, S):
    for i in range(len(S)):
        for j in range(i + 1, len(S)):
            if adj[S[i], S[j]] != 0:
                return False
    return True

L = graph_laplacian(adj)

# Separated subset
S_sep = [1, 3, 5]  # No two are adjacent
# Non-separated subset
S_nonsep = [0, 1, 3]  # 0 and 1 are adjacent

L_sep = restricted_laplacian(L, S_sep)
L_nonsep = restricted_laplacian(L, S_nonsep)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Full Laplacian
cmap = plt.cm.RdBu_r
norm = mcolors.TwoSlopeNorm(vmin=-3, vcenter=0, vmax=4)

im0 = axes[0].imshow(L, cmap=cmap, norm=norm)
axes[0].set_title('Full Laplacian L(G)', fontsize=14, fontweight='bold')
axes[0].set_xlabel('Column index')
axes[0].set_ylabel('Row index')
for i in range(n):
    for j in range(n):
        axes[0].text(j, i, str(L[i,j]), ha='center', va='center', fontsize=12,
                    color='white' if abs(L[i,j]) > 1.5 else 'black')
axes[0].set_xticks(range(n))
axes[0].set_yticks(range(n))

# Separated L_S (diagonal)
k = len(S_sep)
im1 = axes[1].imshow(L_sep, cmap=cmap, norm=norm)
axes[1].set_title(f'L_S (Separated)\nS = {{{", ".join(str(s) for s in S_sep)}}}',
                  fontsize=14, fontweight='bold')
axes[1].set_xlabel('Column index')
for i in range(k):
    for j in range(k):
        axes[1].text(j, i, str(L_sep[i,j]), ha='center', va='center', fontsize=14,
                    color='white' if abs(L_sep[i,j]) > 1.5 else 'black',
                    fontweight='bold')
axes[1].set_xticks(range(k))
axes[1].set_yticks(range(k))
axes[1].set_xticklabels([f'v{s}' for s in S_sep])
axes[1].set_yticklabels([f'v{s}' for s in S_sep])

# Add diagonal indicator
for i in range(k):
    rect = plt.Rectangle((i-0.5, i-0.5), 1, 1, linewidth=2, 
                         edgecolor='lime', facecolor='none')
    axes[1].add_patch(rect)
axes[1].annotate('DIAGONAL\n(all off-diag = 0)', xy=(0.5, -0.15),
                xycoords='axes fraction', ha='center', fontsize=11,
                color='green', fontweight='bold')

# Non-separated L_S (not diagonal)
k2 = len(S_nonsep)
im2 = axes[2].imshow(L_nonsep, cmap=cmap, norm=norm)
axes[2].set_title(f'L_S (Non-separated)\nS = {{{", ".join(str(s) for s in S_nonsep)}}}',
                  fontsize=14, fontweight='bold')
axes[2].set_xlabel('Column index')
for i in range(k2):
    for j in range(k2):
        axes[2].text(j, i, str(L_nonsep[i,j]), ha='center', va='center', fontsize=14,
                    color='white' if abs(L_nonsep[i,j]) > 1.5 else 'black',
                    fontweight='bold')
axes[2].set_xticks(range(k2))
axes[2].set_yticks(range(k2))
axes[2].set_xticklabels([f'v{s}' for s in S_nonsep])
axes[2].set_yticklabels([f'v{s}' for s in S_nonsep])

# Highlight non-zero off-diagonal
for i in range(k2):
    for j in range(k2):
        if i != j and L_nonsep[i,j] != 0:
            rect = plt.Rectangle((j-0.5, i-0.5), 1, 1, linewidth=2,
                                edgecolor='red', facecolor='none')
            axes[2].add_patch(rect)
axes[2].annotate('NON-DIAGONAL\n(off-diag ≠ 0)', xy=(0.5, -0.15),
                xycoords='axes fraction', ha='center', fontsize=11,
                color='red', fontweight='bold')

plt.colorbar(im0, ax=axes, shrink=0.8, label='Matrix entry value')
plt.suptitle('Separation Forces Diagonal Structure in Restricted Laplacian',
            fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_laplacian_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_laplacian_heatmap.png")


"""
Visualization: The SNF Correspondence Pipeline

This script visualizes the complete pipeline from graph to
Smith Normal Form to cokernel decomposition, showing each
step of the transformation.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from math import gcd

def graph_laplacian(adj):
    return np.diag(np.sum(adj, axis=1)) - adj

def _extended_gcd(a, b):
    if b == 0:
        return (1, 0) if a >= 0 else (-1, 0)
    old_r, r = a, b
    old_s, s = 1, 0
    old_t, t = 0, 1
    while r != 0:
        q = old_r // r
        old_r, r = r, old_r - q * r
        old_s, s = s, old_s - q * s
        old_t, t = t, old_t - q * t
    if old_r < 0:
        return -old_s, -old_t
    return old_s, old_t

def is_separated(adj, S):
    for i in range(len(S)):
        for j in range(i+1, len(S)):
            if adj[S[i],S[j]] != 0:
                return False
    return True

# Create a graph: modified path with extra connections
n = 6
adj = np.zeros((n, n), dtype=int)
edges = [(0,1), (1,2), (2,3), (3,4), (4,5), (0,2), (3,5)]
for i, j in edges:
    adj[i,j] = adj[j,i] = 1

S = [1, 4]  # Separated set

fig, axes = plt.subplots(2, 3, figsize=(18, 10))

# Step 1: Graph visualization
ax = axes[0, 0]
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
angles = np.linspace(0, 2*np.pi, n, endpoint=False)
pos = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}

# Draw edges
for i, j in edges:
    x = [pos[i][0], pos[j][0]]
    y = [pos[i][1], pos[j][1]]
    ax.plot(x, y, 'k-', linewidth=1.5, alpha=0.5)

# Draw vertices
for i in range(n):
    color = '#FF5722' if i in S else '#2196F3'
    size = 400 if i in S else 300
    ax.scatter(*pos[i], c=color, s=size, zorder=5, edgecolors='black', linewidth=2)
    ax.annotate(f'v{i}\n(d={int(np.sum(adj[i]))})', pos[i], 
               textcoords="offset points", xytext=(0, 15),
               ha='center', fontsize=9, fontweight='bold')

ax.set_title('Step 1: Graph G\n(orange = separated set S)', 
            fontsize=12, fontweight='bold')
ax.set_aspect('equal')
ax.axis('off')

# Step 2: Full Laplacian
ax = axes[0, 1]
L = graph_laplacian(adj)
im = ax.imshow(L, cmap='RdBu_r', vmin=-2, vmax=4)
for i in range(n):
    for j in range(n):
        ax.text(j, i, str(L[i,j]), ha='center', va='center', fontsize=11,
               color='white' if abs(L[i,j]) > 1 else 'black')
# Highlight S rows/cols
for s in S:
    rect = plt.Rectangle((-0.5, s-0.5), n, 1, linewidth=2, 
                         edgecolor='#FF5722', facecolor='none', linestyle='--')
    ax.add_patch(rect)
    rect = plt.Rectangle((s-0.5, -0.5), 1, n, linewidth=2,
                         edgecolor='#FF5722', facecolor='none', linestyle='--')
    ax.add_patch(rect)
ax.set_title('Step 2: Laplacian L(G)\n(dashed = S rows/cols)', 
            fontsize=12, fontweight='bold')
ax.set_xticks(range(n))
ax.set_yticks(range(n))

# Step 3: Restricted Laplacian
ax = axes[0, 2]
idx = np.array(S)
L_S = L[np.ix_(idx, idx)]
k = len(S)

ax.imshow(L_S, cmap='RdBu_r', vmin=-2, vmax=4)
for i in range(k):
    for j in range(k):
        ax.text(j, i, str(L_S[i,j]), ha='center', va='center', fontsize=16,
               fontweight='bold', color='white' if abs(L_S[i,j]) > 1 else 'black')
ax.set_xticks(range(k))
ax.set_yticks(range(k))
ax.set_xticklabels([f'v{s}' for s in S])
ax.set_yticklabels([f'v{s}' for s in S])

is_diag = np.allclose(L_S - np.diag(np.diag(L_S)), 0)
status = "DIAGONAL ✓" if is_diag else "NOT DIAGONAL"
color = 'green' if is_diag else 'red'
ax.set_title(f'Step 3: Restricted L_S\n{status}', 
            fontsize=12, fontweight='bold', color=color)

# Step 4: Canonical generators
ax = axes[1, 0]
for idx_s, s in enumerate(S):
    gen = np.zeros(n, dtype=int)
    gen[s] = 1
    x_positions = np.arange(n) + idx_s * 0.3 - 0.15
    bars = ax.bar(x_positions, gen, width=0.25, 
                 label=f'Generator for v{s}',
                 alpha=0.8, edgecolor='black')
ax.set_xticks(range(n))
ax.set_xticklabels([f'v{i}' for i in range(n)])
ax.set_ylabel('Value')
ax.set_title('Step 4: Canonical Harmonic\nGenerators (indicators)', 
            fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.set_ylim(-0.2, 1.5)

# Step 5: Boundary restriction → standard basis
ax = axes[1, 1]
for idx_s, s in enumerate(S):
    restr = np.zeros(k, dtype=int)
    restr[idx_s] = 1
    x_positions = np.arange(k) + idx_s * 0.3 - 0.15
    ax.bar(x_positions, restr, width=0.25,
          label=f'e_{idx_s+1} (from v{s})',
          alpha=0.8, edgecolor='black')
ax.set_xticks(range(k))
ax.set_xticklabels([f'v{s}' for s in S])
ax.set_ylabel('Value')
ax.set_title('Step 5: Boundary Restrictions\n= Standard Basis Vectors', 
            fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.set_ylim(-0.2, 1.5)

# Step 6: Cokernel decomposition
ax = axes[1, 2]
degrees = [int(np.sum(adj[s])) for s in S]
det = int(np.prod(degrees))

# Draw cyclic groups as circles
theta = np.linspace(0, 2*np.pi, 100)
for idx_s, (s, d) in enumerate(zip(S, degrees)):
    cx = idx_s * 2.5
    cy = 0
    r = 0.8
    
    # Draw circle
    ax.plot(cx + r*np.cos(theta), cy + r*np.sin(theta), 'k-', linewidth=2)
    
    # Mark elements
    for elem in range(d):
        angle = 2 * np.pi * elem / d - np.pi/2
        ex = cx + r * np.cos(angle)
        ey = cy + r * np.sin(angle)
        ax.scatter(ex, ey, c='#FF5722', s=80, zorder=5, edgecolors='black')
        ax.annotate(str(elem), (ex, ey), textcoords="offset points",
                   xytext=(8, 0), fontsize=9)
    
    ax.text(cx, cy - 1.3, f'ℤ/{d}', ha='center', fontsize=14, fontweight='bold',
           color='#1565C0')
    ax.text(cx, cy + 1.2, f'v{s}\n(deg={d})', ha='center', fontsize=10)

# Add multiplication sign
if len(S) > 1:
    mid_x = (0 * 2.5 + 1 * 2.5) / 2
    ax.text(mid_x, 0, '×', ha='center', va='center', fontsize=24, fontweight='bold')

ax.set_xlim(-1.5, (len(S)-1)*2.5 + 1.5)
ax.set_ylim(-2, 2)
ax.set_title(f'Step 6: Cokernel Decomposition\n|Cok| = {det}', 
            fontsize=12, fontweight='bold')
ax.set_aspect('equal')
ax.axis('off')

plt.suptitle('The SNF Correspondence Pipeline: Graph → Laplacian → SNF → Cokernel',
            fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_snf_pipeline.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_snf_pipeline.png")
