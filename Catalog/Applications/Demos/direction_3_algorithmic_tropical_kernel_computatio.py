"""
Applications of Algorithmic Tropical Kernel Computation.

Demonstrates real-world applications of tropical kernel theory:
1. Network resilience analysis
2. Routing redundancy verification
3. Supply chain balance checking

Application Keywords: network resilience, routing, power-grid equilibrium,
supply chain logistics, tropical convexity, min-plus algebra.
"""

from itertools import product
import numpy as np


# === Self-contained core (no local imports) ===

class WeightedGraph:
    def __init__(self, n):
        self.n = n
        self.adj = {v: set() for v in range(n)}
        self.w = {}

    def add_edge(self, u, v, weight):
        self.adj[u].add(v)
        self.adj[v].add(u)
        self.w[(u, v)] = weight
        self.w[(v, u)] = weight

    def neighbors(self, v):
        return self.adj[v]


def wnv(G, phi, i, j):
    return G.w.get((i, j), 0) + phi[j]


def is_tropically_balanced_at(G, phi, v):
    nbrs = list(G.neighbors(v))
    if len(nbrs) < 2:
        return False
    values = [(wnv(G, phi, v, j), j) for j in nbrs]
    min_val = min(val for val, _ in values)
    return sum(1 for val, _ in values if val == min_val) >= 2


def is_in_tropical_kernel(G, phi):
    return all(is_tropically_balanced_at(G, phi, v) for v in range(G.n))


def brute_force_search(G, bound=15, v0=0):
    other = [v for v in range(G.n) if v != v0]
    for combo in product(range(-bound, bound + 1), repeat=len(other)):
        phi = {v0: 0}
        for i, v in enumerate(other):
            phi[v] = combo[i]
        if is_in_tropical_kernel(G, phi):
            return phi
    return None


# === Application 1: Network Resilience Analysis ===

def analyze_network_resilience():
    """
    Interpret tropical kernel nonemptiness as a resilience metric.

    In a communication network, each node needs redundant cheapest
    supply routes. Tropical balance = no single point of failure
    in routing optimality.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Resilience Analysis")
    print("=" * 60)
    print()

    # Model a small data center network
    # 5 servers, edges = network links, weights = latency
    G = WeightedGraph(5)
    # Ring topology
    G.add_edge(0, 1, 2)
    G.add_edge(1, 2, 3)
    G.add_edge(2, 3, 2)
    G.add_edge(3, 4, 3)
    G.add_edge(4, 0, 2)
    # Cross links for redundancy
    G.add_edge(0, 2, 5)
    G.add_edge(1, 3, 5)

    print("Network topology: 5-node ring with 2 cross-links")
    print("Edge weights represent latency (ms)")
    print()

    result = brute_force_search(G, bound=10)
    if result:
        print(f"✓ Network IS resilient (tropical kernel nonempty)")
        print(f"  Balanced potential: {result}")
        print(f"  Interpretation: each server has ≥2 equally-optimal routes")
        print()

        # Check resilience under link failures
        print("  Link failure analysis:")
        edges = [(0,1), (1,2), (2,3), (3,4), (4,0), (0,2), (1,3)]
        for u, v in edges:
            G2 = WeightedGraph(5)
            for a, b in edges:
                if (a, b) != (u, v):
                    G2.add_edge(a, b, G.w[(a, b)])
            # Check if remaining graph still has kernel
            min_deg = min(len(G2.neighbors(w)) for w in range(5))
            if min_deg < 2:
                print(f"    Remove {u}-{v}: CRITICAL (creates degree-1 node)")
            else:
                r2 = brute_force_search(G2, bound=10)
                print(f"    Remove {u}-{v}: {'resilient' if r2 else 'vulnerable'}")
    else:
        print(f"✗ Network is NOT resilient (kernel empty)")
        print(f"  Some servers lack redundant optimal routes")

    print()


# === Application 2: Supply Chain Balance ===

def analyze_supply_chain():
    """
    Model supply chain balance using tropical kernels.

    Nodes = distribution centers, edges = transport routes,
    weights = shipping costs. Tropical balance = every center
    has multiple equally-cheap suppliers.
    """
    print("=" * 60)
    print("APPLICATION 2: Supply Chain Balance")
    print("=" * 60)
    print()

    # 4 distribution centers with transport routes
    G = WeightedGraph(4)
    G.add_edge(0, 1, 3)  # Route A-B, cost 3
    G.add_edge(1, 2, 3)  # Route B-C, cost 3
    G.add_edge(2, 3, 3)  # Route C-D, cost 3
    G.add_edge(3, 0, 3)  # Route D-A, cost 3

    print("Supply chain: 4 centers in a cycle, uniform costs")
    result = brute_force_search(G, bound=10)
    if result:
        print(f"  ✓ Balanced configuration found: {result}")
        print(f"  Every center has 2 equally-cheap supply routes")
    else:
        print(f"  ✗ No balanced configuration exists")

    print()

    # Now with unequal costs
    G2 = WeightedGraph(4)
    G2.add_edge(0, 1, 1)
    G2.add_edge(1, 2, 5)
    G2.add_edge(2, 3, 1)
    G2.add_edge(3, 0, 5)

    print("Supply chain: 4 centers, alternating costs [1, 5, 1, 5]")
    result2 = brute_force_search(G2, bound=15)
    if result2:
        print(f"  ✓ Balanced configuration found: {result2}")
        # Verify and show details
        for v in range(4):
            nbrs = list(G2.neighbors(v))
            vals = {j: wnv(G2, result2, v, j) for j in nbrs}
            print(f"    Center {v}: route costs = {vals}")
    else:
        print(f"  ✗ No balanced configuration — cost asymmetry too large")

    print()


# === Application 3: Routing Table Optimization ===

def analyze_routing():
    """
    Use tropical kernel theory for routing table analysis.

    Finding whether a set of routing metrics admits redundant
    optimal paths at every node.
    """
    print("=" * 60)
    print("APPLICATION 3: Routing Table Optimization")
    print("=" * 60)
    print()

    # Small internet-like topology
    G = WeightedGraph(6)
    # Core links (fast)
    G.add_edge(0, 1, 1)
    G.add_edge(1, 2, 1)
    G.add_edge(2, 3, 1)
    # Distribution links (medium)
    G.add_edge(0, 3, 2)
    G.add_edge(1, 4, 2)
    G.add_edge(2, 5, 2)
    # Access links (slow)
    G.add_edge(3, 4, 3)
    G.add_edge(4, 5, 3)
    G.add_edge(5, 0, 3)

    print("Topology: 6-node hierarchical network")
    print("  Core links (w=1): 0-1, 1-2, 2-3")
    print("  Distribution links (w=2): 0-3, 1-4, 2-5")
    print("  Access links (w=3): 3-4, 4-5, 5-0")
    print()

    result = brute_force_search(G, bound=10)
    if result:
        print(f"✓ Redundant routing exists!")
        print(f"  Metric assignment: {result}")
        for v in range(6):
            nbrs = sorted(G.neighbors(v))
            vals = {j: wnv(G, result, v, j) for j in nbrs}
            min_val = min(vals.values())
            opt_routes = [j for j, val in vals.items() if val == min_val]
            print(f"  Node {v}: optimal next-hops = {opt_routes} (cost = {min_val})")
    else:
        print(f"✗ No redundant routing metric exists for this topology")

    print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Kernel Applications Suite                     ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    analyze_network_resilience()
    analyze_supply_chain()
    analyze_routing()

    print("Applications demo complete.")


"""
Interactive Demo: Algorithmic Tropical Kernel Computation

This demo:
1. Constructs small weighted graphs
2. Computes the derived constraint system
3. Compares brute-force bounded search against the theorem-backed algorithm
4. Displays normalized tropical kernel candidates
5. Reports agreement or counterexamples

Probes the feasibility conjecture: constraint-system feasibility should
predict tropical kernel nonemptiness.
"""

from itertools import product
import numpy as np


# === Core Definitions (self-contained) ===

class WeightedGraph:
    def __init__(self, n):
        self.n = n
        self.adj = {v: set() for v in range(n)}
        self.w = {}

    def add_edge(self, u, v, weight):
        self.adj[u].add(v)
        self.adj[v].add(u)
        self.w[(u, v)] = weight
        self.w[(v, u)] = weight

    def neighbors(self, v):
        return self.adj[v]

    def edge_weight(self, u, v):
        return self.w.get((u, v), 0)


def wnv(G, phi, i, j):
    return G.edge_weight(i, j) + phi[j]


def is_tropically_balanced_at(G, phi, v):
    nbrs = list(G.neighbors(v))
    if len(nbrs) < 2:
        return False
    values = [(wnv(G, phi, v, j), j) for j in nbrs]
    min_val = min(val for val, _ in values)
    minimizers = [j for val, j in values if val == min_val]
    return len(minimizers) >= 2


def is_in_tropical_kernel(G, phi):
    return all(is_tropically_balanced_at(G, phi, v) for v in range(G.n))


def normalize(phi, v0):
    c = phi[v0]
    return {v: phi[v] - c for v in phi}


class DifferenceConstraint:
    def __init__(self, src, tgt, bound):
        self.src = src
        self.tgt = tgt
        self.bound = bound

    def is_satisfied(self, phi):
        return phi[self.tgt] - phi[self.src] <= self.bound

    def __repr__(self):
        return f"phi({self.tgt}) - phi({self.src}) <= {self.bound}"


def extract_constraints(G, u, j):
    constraints = []
    for v in G.neighbors(u):
        bound = G.edge_weight(u, v) - G.edge_weight(u, j)
        constraints.append(DifferenceConstraint(src=v, tgt=j, bound=bound))
    return constraints


def bellman_ford_feasibility(n, constraints, v0=0):
    dist = {v: 0 for v in range(n)}
    for _ in range(n - 1):
        updated = False
        for c in constraints:
            if dist[c.src] + c.bound < dist[c.tgt]:
                dist[c.tgt] = dist[c.src] + c.bound
                updated = True
        if not updated:
            break
    for c in constraints:
        if dist[c.src] + c.bound < dist[c.tgt]:
            return None
    offset = dist[v0]
    return {v: dist[v] - offset for v in range(n)}


def brute_force_search(G, bound=15, v0=0):
    other_vertices = [v for v in range(G.n) if v != v0]
    values = range(-bound, bound + 1)
    for combo in product(values, repeat=len(other_vertices)):
        phi = {v0: 0}
        for i, v in enumerate(other_vertices):
            phi[v] = combo[i]
        if is_in_tropical_kernel(G, phi):
            return phi
    return None


def constraint_based_check(G, v0=0):
    neighbor_lists = {v: list(G.neighbors(v)) for v in range(G.n)}
    for v in range(G.n):
        if len(neighbor_lists[v]) < 2:
            return False, None
    choices = [neighbor_lists[v] for v in range(G.n)]
    for assignment in product(*choices):
        constraints = []
        for u in range(G.n):
            j = assignment[u]
            constraints.extend(extract_constraints(G, u, j))
        potential = bellman_ford_feasibility(G.n, constraints, v0)
        if potential is not None:
            if is_in_tropical_kernel(G, potential):
                return True, potential
    return False, None


# === Graph Constructors ===

def complete_graph(n, weights=None):
    G = WeightedGraph(n)
    for i in range(n):
        for j in range(i + 1, n):
            w = weights.get((i, j), 0) if weights else np.random.randint(-5, 6)
            G.add_edge(i, j, w)
    return G


def cycle_graph(n, weights=None):
    G = WeightedGraph(n)
    for i in range(n):
        j = (i + 1) % n
        w = weights[i] if weights else np.random.randint(-5, 6)
        G.add_edge(i, j, w)
    return G


def path_graph(n, weights=None):
    G = WeightedGraph(n)
    for i in range(n - 1):
        w = weights[i] if weights else np.random.randint(-5, 6)
        G.add_edge(i, i + 1, w)
    return G


# === Demo Functions ===

def demo_translation_invariance():
    """Verify Theorem 1: translation invariance."""
    print("=" * 60)
    print("DEMO 1: Translation Invariance")
    print("=" * 60)

    G = cycle_graph(3, weights=[1, 1, 1])
    phi = {0: 0, 1: 0, 2: 0}
    print(f"Graph: C3 with uniform weights [1,1,1]")
    print(f"Base potential: {phi}")
    print(f"Is in kernel: {is_in_tropical_kernel(G, phi)}")

    for c in [-3, -1, 0, 1, 5, 10]:
        shifted = {v: phi[v] + c for v in phi}
        result = is_in_tropical_kernel(G, shifted)
        print(f"  Shifted by {c:+d}: {shifted} -> kernel={result}")

    print()


def demo_normalization():
    """Verify Theorem 2: normalization."""
    print("=" * 60)
    print("DEMO 2: Normalization Preserves Feasibility")
    print("=" * 60)

    G = cycle_graph(4, weights=[2, 2, 2, 2])
    phi = {0: 3, 1: 3, 2: 3, 3: 3}
    print(f"Graph: C4 with uniform weights [2,2,2,2]")
    print(f"Original potential: {phi}")
    print(f"Is in kernel: {is_in_tropical_kernel(G, phi)}")

    for v0 in range(G.n):
        normalized = normalize(phi, v0)
        result = is_in_tropical_kernel(G, normalized)
        print(f"  Normalized at v{v0}: {normalized} -> kernel={result}, phi(v{v0})={normalized[v0]}")

    print()


def demo_neighbor_domination():
    """Verify Theorem 3: neighbor domination."""
    print("=" * 60)
    print("DEMO 3: Neighbor Domination")
    print("=" * 60)

    G = complete_graph(4, weights={(0,1): 1, (0,2): 1, (0,3): 2, (1,2): 1, (1,3): 1, (2,3): 1})
    phi = {0: 0, 1: 0, 2: 0, 3: 0}
    print(f"Graph: K4 with specific weights")
    print(f"Potential: {phi}")
    print(f"Is in kernel: {is_in_tropical_kernel(G, phi)}")

    for u in range(G.n):
        if not is_tropically_balanced_at(G, phi, u):
            print(f"  Vertex {u}: NOT balanced")
            continue
        print(f"  Vertex {u}: balanced")
        for v in G.neighbors(u):
            val_v = wnv(G, phi, u, v)
            dominators = [j for j in G.neighbors(u) if j != v and wnv(G, phi, u, j) <= val_v]
            print(f"    Neighbor {v} (wnv={val_v}): dominated by {dominators}")

    print()


def demo_difference_constraints():
    """Verify Theorem 4 & 5: difference constraints and bridge."""
    print("=" * 60)
    print("DEMO 4: Difference Constraints Bridge")
    print("=" * 60)

    G = cycle_graph(3, weights=[1, 1, 1])
    phi = {0: 0, 1: 0, 2: 0}
    print(f"Graph: C3 with uniform weights [1,1,1]")
    print(f"Potential: {phi}")

    for u in range(G.n):
        nbrs = list(G.neighbors(u))
        vals = {j: wnv(G, phi, u, j) for j in nbrs}
        min_val = min(vals.values())
        minimizers = [j for j, v in vals.items() if v == min_val]
        j = minimizers[0]

        print(f"\n  Vertex {u}: minimizer = {j}")
        constraints = extract_constraints(G, u, j)
        for c in constraints:
            satisfied = c.is_satisfied(phi)
            actual = phi[c.tgt] - phi[c.src]
            print(f"    {c} | actual diff = {actual} | satisfied = {satisfied}")

    print()


def demo_brute_force_vs_constraints():
    """Compare brute-force search against constraint-based algorithm."""
    print("=" * 60)
    print("DEMO 5: Brute Force vs. Constraint-Based Algorithm")
    print("=" * 60)

    test_cases = [
        ("C3 uniform", cycle_graph(3, weights=[1, 1, 1])),
        ("C3 mixed", cycle_graph(3, weights=[1, 2, 3])),
        ("C4 uniform", cycle_graph(4, weights=[2, 2, 2, 2])),
        ("C4 mixed", cycle_graph(4, weights=[1, 2, 3, 4])),
        ("C5 uniform", cycle_graph(5, weights=[1, 1, 1, 1, 1])),
        ("P3", path_graph(3, weights=[1, 1])),
        ("P4", path_graph(4, weights=[1, 1, 1])),
        ("K3 degenerate", complete_graph(3, weights={(0,1): 1, (0,2): 1, (1,2): 1})),
        ("K4 degenerate", complete_graph(4, weights={(0,1): 1, (0,2): 1, (0,3): 1,
                                                      (1,2): 1, (1,3): 1, (2,3): 1})),
    ]

    print(f"{'Name':<20} {'BF Result':<15} {'CB Result':<15} {'Agreement':<10}")
    print("-" * 60)

    for name, G in test_cases:
        bf_result = brute_force_search(G, bound=10)
        cb_feasible, cb_potential = constraint_based_check(G)

        bf_feasible = bf_result is not None
        agree = bf_feasible == cb_feasible

        bf_str = str(bf_result) if bf_result else "None"
        cb_str = str(cb_potential) if cb_potential else "None"

        print(f"{name:<20} {'Yes' if bf_feasible else 'No':<15} {'Yes' if cb_feasible else 'No':<15} {'✓' if agree else '✗':<10}")
        if bf_result:
            print(f"  BF: {bf_str}")
        if cb_potential:
            print(f"  CB: {cb_str}")

    print()


def demo_conjecture_test():
    """Test the feasibility conjecture on random graphs."""
    print("=" * 60)
    print("DEMO 6: Feasibility Conjecture Test (Random Graphs)")
    print("=" * 60)

    np.random.seed(42)
    n_tests = 20
    agreements = 0
    total = 0

    for trial in range(n_tests):
        n = np.random.randint(3, 6)
        # Random graph: each edge exists with probability 0.6
        G = WeightedGraph(n)
        for i in range(n):
            for j in range(i + 1, n):
                if np.random.random() < 0.6:
                    w = np.random.randint(-3, 4)
                    G.add_edge(i, j, w)

        # Skip if any vertex has degree < 2 (trivially infeasible)
        min_deg = min(len(G.neighbors(v)) for v in range(n))

        bf_result = brute_force_search(G, bound=10)
        cb_feasible, cb_potential = constraint_based_check(G)
        bf_feasible = bf_result is not None

        agree = bf_feasible == cb_feasible
        if agree:
            agreements += 1
        total += 1

        status = "✓" if agree else "✗ COUNTEREXAMPLE"
        print(f"  Trial {trial+1:2d}: n={n}, min_deg={min_deg}, "
              f"BF={'Y' if bf_feasible else 'N'}, CB={'Y' if cb_feasible else 'N'} {status}")

    print(f"\nAgreement rate: {agreements}/{total} = {agreements/total:.1%}")
    if agreements == total:
        print("Conjecture SUPPORTED on all tested instances.")
    else:
        print("Conjecture VIOLATED — counterexamples found!")

    print()


def demo_constraint_system_visualization():
    """Show the full constraint system for a small graph."""
    print("=" * 60)
    print("DEMO 7: Full Constraint System Visualization")
    print("=" * 60)

    G = cycle_graph(4, weights=[1, 2, 1, 2])
    print(f"Graph: C4 with weights [1, 2, 1, 2]")
    print(f"Vertices: 0, 1, 2, 3")
    print(f"Edges: 0-1 (w=1), 1-2 (w=2), 2-3 (w=1), 3-0 (w=2)")
    print()

    # Show all possible minimizer assignments and their constraints
    neighbor_lists = {v: sorted(G.neighbors(v)) for v in range(G.n)}
    print("Minimizer assignments and constraint systems:")

    for v in range(G.n):
        print(f"\n  Vertex {v}: neighbors = {neighbor_lists[v]}")

    assignment_count = 0
    choices = [neighbor_lists[v] for v in range(G.n)]
    for assignment in product(*choices):
        assignment_count += 1
        constraints = []
        for u in range(G.n):
            j = assignment[u]
            constraints.extend(extract_constraints(G, u, j))

        potential = bellman_ford_feasibility(G.n, constraints)
        feasible = potential is not None

        if feasible and is_in_tropical_kernel(G, potential):
            print(f"\n  Assignment {assignment}: KERNEL ELEMENT FOUND")
            print(f"    Potential: {potential}")
            for c in constraints:
                print(f"    {c} | satisfied: {c.is_satisfied(potential)}")
            break
    else:
        print(f"\n  Tested {assignment_count} assignments, no kernel element found.")

    print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Algorithmic Tropical Kernel Computation — Demo Suite   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_translation_invariance()
    demo_normalization()
    demo_neighbor_domination()
    demo_difference_constraints()
    demo_brute_force_vs_constraints()
    demo_conjecture_test()
    demo_constraint_system_visualization()

    print("Demo complete.")


"""
Visualization 2: Constraint Digraph from Tropical Balance

Visualizes the difference-constraint system derived from a tropical kernel
element on a cycle graph. Shows the original graph alongside the induced
constraint digraph, illustrating the bridge from tropical harmonicity to
classical shortest-path optimization (Theorem 5).

Each arrow in the constraint digraph represents a difference inequality
φ(tgt) - φ(src) ≤ bound, derived from the minimizer at each vertex.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from itertools import product as iproduct


def wnv(w_dict, phi, i, j):
    return w_dict.get((i, j), 0) + phi[j]


def is_balanced_at(adj, w_dict, phi, v):
    nbrs = adj[v]
    if len(nbrs) < 2:
        return False
    values = [(wnv(w_dict, phi, v, j), j) for j in nbrs]
    min_val = min(val for val, _ in values)
    return sum(1 for val, _ in values if val == min_val) >= 2


def get_minimizer(adj, w_dict, phi, u):
    nbrs = adj[u]
    return min(nbrs, key=lambda j: wnv(w_dict, phi, u, j))


# Build C5 with specific weights
n = 5
adj = {i: [(i - 1) % n, (i + 1) % n] for i in range(n)}
weights = [2, 2, 2, 2, 2]
w_dict = {}
for i in range(n):
    j = (i + 1) % n
    w_dict[(i, j)] = w_dict[(j, i)] = weights[i]

phi = {v: 0 for v in range(n)}

# Vertex positions (regular pentagon)
angles = [np.pi / 2 + 2 * np.pi * k / n for k in range(n)]
pos = {v: (np.cos(angles[v]), np.sin(angles[v])) for v in range(n)}

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Original graph
ax1 = axes[0]
ax1.set_xlim(-1.5, 1.5)
ax1.set_ylim(-1.5, 1.5)
ax1.set_aspect('equal')
ax1.set_title('Original Weighted Graph (C₅)', fontsize=14)

for i in range(n):
    j = (i + 1) % n
    x = [pos[i][0], pos[j][0]]
    y = [pos[i][1], pos[j][1]]
    ax1.plot(x, y, 'b-', linewidth=2)
    mx, my = (x[0] + x[1]) / 2, (y[0] + y[1]) / 2
    # Offset label slightly outward
    cx, cy = np.mean([p[0] for p in pos.values()]), np.mean([p[1] for p in pos.values()])
    dx, dy = mx - cx, my - cy
    norm = np.sqrt(dx**2 + dy**2) + 1e-9
    ax1.text(mx + 0.15 * dx / norm, my + 0.15 * dy / norm,
             str(weights[i]), fontsize=12, ha='center', va='center',
             bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow'))

for v in range(n):
    balanced = is_balanced_at(adj, w_dict, phi, v)
    color = 'green' if balanced else 'red'
    ax1.plot(*pos[v], 'o', markersize=25, color=color, zorder=5)
    ax1.text(*pos[v], str(v), fontsize=14, ha='center', va='center',
             color='white', fontweight='bold', zorder=6)
    ax1.text(pos[v][0], pos[v][1] - 0.25, f'φ={phi[v]}',
             fontsize=10, ha='center', va='top')

ax1.axis('off')

# Right: Constraint digraph
ax2 = axes[1]
ax2.set_xlim(-1.8, 1.8)
ax2.set_ylim(-1.5, 1.5)
ax2.set_aspect('equal')
ax2.set_title('Induced Constraint Digraph', fontsize=14)

# Draw constraints as directed edges
constraint_edges = []
for u in range(n):
    j = get_minimizer(adj, w_dict, phi, u)
    for v in adj[u]:
        bound = w_dict[(u, v)] - w_dict[(u, j)]
        constraint_edges.append((v, j, bound, u))

# Draw nodes
for v in range(n):
    ax2.plot(*pos[v], 'o', markersize=25, color='steelblue', zorder=5)
    ax2.text(*pos[v], str(v), fontsize=14, ha='center', va='center',
             color='white', fontweight='bold', zorder=6)

# Draw constraint arrows
colors = plt.cm.Set1(np.linspace(0, 1, n))
drawn = set()
for src, tgt, bound, origin in constraint_edges:
    if src == tgt:
        continue
    key = (src, tgt)
    if key in drawn:
        continue
    drawn.add(key)

    x1, y1 = pos[src]
    x2, y2 = pos[tgt]

    # Shorten arrows to not overlap nodes
    dx, dy = x2 - x1, y2 - y1
    length = np.sqrt(dx**2 + dy**2)
    shrink = 0.18
    sx, sy = x1 + shrink * dx / length, y1 + shrink * dy / length
    ex, ey = x2 - shrink * dx / length, y2 - shrink * dy / length

    ax2.annotate('', xy=(ex, ey), xytext=(sx, sy),
                 arrowprops=dict(arrowstyle='->', color=colors[origin],
                                linewidth=1.5, shrinkA=0, shrinkB=0))

    mx, my = (sx + ex) / 2, (sy + ey) / 2
    # Perpendicular offset
    px, py = -dy / length * 0.12, dx / length * 0.12
    ax2.text(mx + px, my + py, f'≤{bound}',
             fontsize=9, ha='center', va='center',
             bbox=dict(boxstyle='round,pad=0.15', facecolor='lightyellow', alpha=0.9))

ax2.axis('off')

plt.suptitle('Tropical Balance → Difference Constraints (Theorem 5)',
             fontsize=15, fontweight='bold', y=0.98)
plt.tight_layout()
plt.savefig('constraint_digraph.png', dpi=150)
print("Saved: constraint_digraph.png")


"""
Visualization 1: Tropical Kernel Feasibility Heatmap

Visualizes the feasibility of the tropical kernel for cycle graphs C4
as a function of two edge weight parameters. Shows how weight symmetry
(degeneracy) creates regions where balanced potentials exist.

The heatmap reveals the piecewise-linear geometry of the tropical
feasibility boundary — a direct visual manifestation of the
difference-constraint structure.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iproduct


def wnv(w_dict, phi, i, j):
    return w_dict.get((i, j), 0) + phi[j]


def is_balanced_at(n, adj, w_dict, phi, v):
    nbrs = adj[v]
    if len(nbrs) < 2:
        return False
    values = [wnv(w_dict, phi, v, j) for j in nbrs]
    min_val = min(values)
    return sum(1 for val in values if val == min_val) >= 2


def is_in_kernel(n, adj, w_dict, phi):
    return all(is_balanced_at(n, adj, w_dict, phi, v) for v in range(n))


def brute_search(n, adj, w_dict, bound=8):
    others = list(range(1, n))
    for combo in iproduct(range(-bound, bound + 1), repeat=len(others)):
        phi = {0: 0}
        for i, v in enumerate(others):
            phi[v] = combo[i]
        if is_in_kernel(n, adj, w_dict, phi):
            return phi
    return None


# Build C4 adjacency
n = 4
adj = {0: [1, 3], 1: [0, 2], 2: [1, 3], 3: [2, 0]}

# Scan over w01 and w12, with w23=1, w30=1 fixed
w_range = np.arange(-5, 6, 1)
feasibility = np.zeros((len(w_range), len(w_range)))

for i, w01 in enumerate(w_range):
    for j, w12 in enumerate(w_range):
        w_dict = {}
        w_dict[(0, 1)] = w_dict[(1, 0)] = int(w01)
        w_dict[(1, 2)] = w_dict[(2, 1)] = int(w12)
        w_dict[(2, 3)] = w_dict[(3, 2)] = 1
        w_dict[(3, 0)] = w_dict[(0, 3)] = 1

        result = brute_search(n, adj, w_dict, bound=8)
        feasibility[j, i] = 1 if result is not None else 0

fig, ax = plt.subplots(1, 1, figsize=(8, 7))
im = ax.imshow(feasibility, extent=[w_range[0]-0.5, w_range[-1]+0.5,
               w_range[0]-0.5, w_range[-1]+0.5],
               origin='lower', cmap='RdYlGn', aspect='equal',
               interpolation='nearest')
ax.set_xlabel('Edge weight w(0,1)', fontsize=13)
ax.set_ylabel('Edge weight w(1,2)', fontsize=13)
ax.set_title('Tropical Kernel Feasibility on C₄\n(w(2,3)=1, w(3,0)=1 fixed)',
             fontsize=14)
cbar = plt.colorbar(im, ax=ax, ticks=[0, 1])
cbar.set_ticklabels(['Infeasible', 'Feasible'])

# Mark the diagonal (symmetric weights)
ax.plot(w_range, w_range, 'b--', alpha=0.5, linewidth=1.5, label='w₀₁ = w₁₂')
ax.legend(fontsize=11)
ax.set_xticks(w_range[::2])
ax.set_yticks(w_range[::2])

plt.tight_layout()
plt.savefig('tropical_kernel_heatmap.png', dpi=150)
print("Saved: tropical_kernel_heatmap.png")


"""
Visualization 3: Phase Transition in Tropical Kernel Feasibility

Shows how the probability of tropical kernel nonemptiness varies with
graph density and weight range. For random graphs with integer weights
in [-W, W], larger W increases the chance of weight degeneracy (two
neighbors achieving equal minimum values), making kernel feasibility
more likely. This illustrates the conjectured phase transition.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iproduct


def wnv_val(w_dict, phi, i, j):
    return w_dict.get((i, j), 0) + phi[j]


def is_balanced(adj, w_dict, phi, v):
    nbrs = adj.get(v, [])
    if len(nbrs) < 2:
        return False
    values = [wnv_val(w_dict, phi, v, j) for j in nbrs]
    min_val = min(values)
    return sum(1 for val in values if val == min_val) >= 2


def kernel_check(n, adj, w_dict, phi):
    return all(is_balanced(adj, w_dict, phi, v) for v in range(n))


def brute_search_small(n, adj, w_dict, bound=6):
    others = list(range(1, n))
    for combo in iproduct(range(-bound, bound + 1), repeat=len(others)):
        phi = {0: 0}
        for i, v in enumerate(others):
            phi[v] = combo[i]
        if kernel_check(n, adj, w_dict, phi):
            return True
    return False


np.random.seed(123)

n = 4  # Fixed graph size
edge_probs = [0.5, 0.7, 0.9, 1.0]
weight_ranges = list(range(1, 8))
n_trials = 30

fig, ax = plt.subplots(figsize=(9, 6))

for p in edge_probs:
    feasibility_rates = []
    for W in weight_ranges:
        feasible_count = 0
        valid_count = 0
        for _ in range(n_trials):
            adj = {v: [] for v in range(n)}
            w_dict = {}
            for i in range(n):
                for j in range(i + 1, n):
                    if np.random.random() < p:
                        weight = np.random.randint(-W, W + 1)
                        adj[i].append(j)
                        adj[j].append(i)
                        w_dict[(i, j)] = weight
                        w_dict[(j, i)] = weight

            # Check min degree >= 2
            min_deg = min(len(adj[v]) for v in range(n))
            if min_deg < 2:
                continue
            valid_count += 1

            if brute_search_small(n, adj, w_dict, bound=6):
                feasible_count += 1

        rate = feasible_count / max(valid_count, 1)
        feasibility_rates.append(rate)

    ax.plot(weight_ranges, feasibility_rates, 'o-', linewidth=2,
            markersize=7, label=f'Edge prob. p={p}')

ax.set_xlabel('Weight range W (weights in [-W, W])', fontsize=13)
ax.set_ylabel('Fraction with nonempty tropical kernel', fontsize=13)
ax.set_title(f'Tropical Kernel Feasibility vs. Weight Range (n={n})',
             fontsize=14)
ax.legend(fontsize=11)
ax.set_ylim(-0.05, 1.05)
ax.grid(True, alpha=0.3)

# Add annotation
ax.annotate('Higher density → more\nredundant routes → more balance',
            xy=(5, 0.9), fontsize=10, style='italic',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150)
print("Saved: phase_transition.png")
