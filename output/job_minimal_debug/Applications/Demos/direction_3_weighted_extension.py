"""
Weighted Tropical Graph Hodge Theory — Applications

This module demonstrates real-world applications of weighted tropical
harmonicity theory to:
1. Network resilience analysis
2. Transportation route degeneracy
3. Energy landscape metastability

Each application uses the core weighted tropical balance machinery
to extract structural information from weighted networks.
"""

from itertools import combinations, product
from collections import defaultdict


# =========================================================================
# Inline core implementations
# =========================================================================

class WeightedGraph:
    def __init__(self, vertices, edges):
        self.vertices = set(vertices)
        self.adj = defaultdict(set)
        self.weights = {}
        for u, v, w in edges:
            self.adj[u].add(v)
            self.adj[v].add(u)
            self.weights[(u, v)] = w
            self.weights[(v, u)] = w

    def neighbors(self, v):
        return self.adj[v]

    def weight(self, u, v):
        return self.weights.get((u, v), 0)


def weighted_nbr_val(G, phi, i, j):
    return G.weight(i, j) + phi.get(j, 0)


def trop_balanced_at(G, phi, i):
    nbrs = G.neighbors(i)
    if len(nbrs) < 2:
        return False
    vals = [weighted_nbr_val(G, phi, i, j) for j in nbrs]
    min_val = min(vals)
    return vals.count(min_val) >= 2


def weight_degeneracy_count(G, S):
    count = 0
    for i in S:
        nbrs = list(G.neighbors(i))
        for a, b in combinations(nbrs, 2):
            if G.weight(i, a) == G.weight(i, b):
                count += 1
                break
    return count


def enumerate_kernel_normalized(G, S, v0, value_range=range(-3, 4)):
    verts = sorted(G.vertices)
    other_verts = [v for v in verts if v != v0]
    results = []
    for vals in product(value_range, repeat=len(other_verts)):
        phi = {v0: 0}
        phi.update(zip(other_verts, vals))
        if all(trop_balanced_at(G, phi, i) for i in S):
            results.append(phi)
    return results


# =========================================================================
# Application 1: Network Resilience Analysis
# =========================================================================

def network_resilience_analysis():
    """Analyze network resilience using tropical balance.

    A communication network where each node needs at least two
    equally-good routes to remain resilient. Tropical balance
    exactly captures this: a node is "resilient" (balanced) if
    the minimum-cost route is not unique.

    The weight degeneracy count serves as a resilience index.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Resilience Analysis")
    print("=" * 60)

    # Model a small data center network
    # Vertices: servers, edges: links with latency (ms)
    network = WeightedGraph(
        vertices=[0, 1, 2, 3, 4, 5],
        edges=[
            (0, 1, 2), (0, 2, 2),  # Redundant links from server 0
            (1, 3, 3), (2, 3, 3),  # Redundant paths to server 3
            (1, 4, 5), (2, 4, 5),  # Redundant paths to server 4
            (3, 5, 1), (4, 5, 1),  # Redundant paths to server 5
        ]
    )

    servers = set(network.vertices)
    phi_zero = {v: 0 for v in servers}

    print("\nData Center Network (6 servers, latency weights):")
    print("  Links: 0-1(2ms), 0-2(2ms), 1-3(3ms), 2-3(3ms),")
    print("         1-4(5ms), 2-4(5ms), 3-5(1ms), 4-5(1ms)")

    print(f"\n  Weight degeneracy count (resilience index): "
          f"{weight_degeneracy_count(network, servers)}")

    print("\n  Per-server resilience (zero potential):")
    for v in sorted(servers):
        balanced = trop_balanced_at(network, phi_zero, v)
        nbrs = sorted(network.neighbors(v))
        wts = [network.weight(v, n) for n in nbrs]
        status = "RESILIENT" if balanced else "VULNERABLE"
        print(f"    Server {v}: neighbors={nbrs}, weights={wts} -> {status}")

    # Perturb one link to break redundancy
    print("\n  After increasing link 0-2 latency to 3ms:")
    network_perturbed = WeightedGraph(
        vertices=[0, 1, 2, 3, 4, 5],
        edges=[
            (0, 1, 2), (0, 2, 3),  # Now asymmetric
            (1, 3, 3), (2, 3, 3),
            (1, 4, 5), (2, 4, 5),
            (3, 5, 1), (4, 5, 1),
        ]
    )
    new_deg = weight_degeneracy_count(network_perturbed, servers)
    print(f"  New resilience index: {new_deg} (was "
          f"{weight_degeneracy_count(network, servers)})")


# =========================================================================
# Application 2: Transportation Route Degeneracy
# =========================================================================

def transportation_route_analysis():
    """Analyze route degeneracy in a transportation network.

    When multiple shortest paths exist between origin and destination,
    the network exhibits tropical degeneracy. This is directly related
    to the weighted tropical kernel dimension.

    High kernel dimension → many alternative optimal routes → robust routing.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Transportation Route Degeneracy")
    print("=" * 60)

    # Model a small city road network
    # Vertices: intersections, edges: roads with travel time (minutes)
    city = WeightedGraph(
        vertices=[0, 1, 2, 3, 4, 5],
        edges=[
            (0, 1, 10), (0, 2, 10),  # Two equally fast exits from downtown
            (1, 3, 15), (2, 3, 15),  # Converge at highway junction
            (1, 4, 20), (2, 4, 20),  # Alternative via bypass
            (3, 5, 5),  (4, 5, 5),   # Final stretch to destination
        ]
    )

    # Check balance = route redundancy
    hub = 0
    destinations = {1, 2, 3, 4, 5}
    phi_zero = {v: 0 for v in city.vertices}

    print("\nCity Road Network (travel times in minutes):")
    print(f"  Weight degeneracy (route redundancy): "
          f"{weight_degeneracy_count(city, destinations)}")

    print("\n  Intersection analysis:")
    for v in sorted(destinations):
        balanced = trop_balanced_at(city, phi_zero, v)
        nbrs = sorted(city.neighbors(v))
        times = [(n, city.weight(v, n)) for n in nbrs]
        print(f"    Intersection {v}: routes={times}, "
              f"{'REDUNDANT' if balanced else 'UNIQUE'}")


# =========================================================================
# Application 3: Energy Landscape Metastability
# =========================================================================

def energy_landscape_analysis():
    """Analyze energy landscape metastability using tropical balance.

    In molecular/materials science, an energy landscape is a weighted
    graph where vertices are states and edge weights are transition
    barriers. A metastable state has multiple equally-likely escape
    routes — exactly the tropical balance condition.

    The tropical kernel captures the space of "balanced perturbations"
    that preserve metastability.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Energy Landscape Metastability")
    print("=" * 60)

    # Model: 5-state molecular energy landscape
    # Edge weights = activation energy barriers (kcal/mol, scaled to integers)
    landscape = WeightedGraph(
        vertices=[0, 1, 2, 3, 4],
        edges=[
            (0, 1, 5), (0, 2, 5),   # State 0: two equal barriers (metastable!)
            (1, 3, 3), (2, 3, 7),   # Asymmetric barriers to state 3
            (1, 4, 8), (2, 4, 4),   # Asymmetric barriers to state 4
            (3, 4, 2),              # Low barrier between states 3, 4
        ]
    )

    states = set(landscape.vertices)
    phi_zero = {v: 0 for v in states}

    print("\nMolecular Energy Landscape (barriers in kcal/mol):")
    print(f"  States: {sorted(states)}")
    print(f"  Metastability index (degeneracy): "
          f"{weight_degeneracy_count(landscape, states)}")

    print("\n  State analysis:")
    for v in sorted(states):
        balanced = trop_balanced_at(landscape, phi_zero, v)
        nbrs = sorted(landscape.neighbors(v))
        barriers = [(n, landscape.weight(v, n)) for n in nbrs]
        status = "METASTABLE" if balanced else "KINETICALLY DETERMINED"
        print(f"    State {v}: barriers={barriers} -> {status}")

    # Find kernel vectors = balanced perturbations preserving metastability
    print("\n  Balanced perturbation analysis:")
    kvecs = enumerate_kernel_normalized(landscape, states, 0, range(-3, 4))
    print(f"    Number of balanced perturbations (normalized): {len(kvecs)}")
    if kvecs:
        print(f"    Example: {kvecs[0]}")


if __name__ == "__main__":
    network_resilience_analysis()
    transportation_route_analysis()
    energy_landscape_analysis()

    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


"""
Weighted Tropical Graph Hodge Theory — Interactive Demonstration

This script demonstrates the core concepts of weighted tropical harmonicity:
- How edge weights affect tropical balance
- The transition between generic and degenerate weight regimes
- Computation of tropical kernel vectors
- The connection between weight degeneracy and kernel dimension

Run this script to experiment with weighted graphs and observe
when the tropical kernel dimension jumps.

Usage:
    python demo.py
"""

from itertools import combinations, product
from collections import defaultdict


# =========================================================================
# Inline implementations (self-contained — no imports from local modules)
# =========================================================================

class WeightedGraph:
    """A finite simple graph with integer edge weights."""

    def __init__(self, vertices, edges):
        self.vertices = set(vertices)
        self.adj = defaultdict(set)
        self.weights = {}
        for u, v, w in edges:
            self.adj[u].add(v)
            self.adj[v].add(u)
            self.weights[(u, v)] = w
            self.weights[(v, u)] = w

    def neighbors(self, v):
        return self.adj[v]

    def weight(self, u, v):
        return self.weights.get((u, v), 0)


def weighted_nbr_val(G, phi, i, j):
    return G.weight(i, j) + phi.get(j, 0)


def trop_balanced_at(G, phi, i):
    nbrs = G.neighbors(i)
    if len(nbrs) < 2:
        return False
    vals = [weighted_nbr_val(G, phi, i, j) for j in nbrs]
    min_val = min(vals)
    return vals.count(min_val) >= 2


def is_generic_weights(G):
    for i in G.vertices:
        nbrs = list(G.neighbors(i))
        for a, b in combinations(nbrs, 2):
            if G.weight(i, a) == G.weight(i, b):
                return False
    return True


def weight_degeneracy_count(G, S):
    count = 0
    for i in S:
        nbrs = list(G.neighbors(i))
        degenerate = False
        for a, b in combinations(nbrs, 2):
            if G.weight(i, a) == G.weight(i, b):
                degenerate = True
                break
        if degenerate:
            count += 1
    return count


def enumerate_kernel_normalized(G, S, v0, value_range=range(-3, 4)):
    """Enumerate normalized kernel vectors (phi(v0) = 0)."""
    verts = sorted(G.vertices)
    other_verts = [v for v in verts if v != v0]
    results = []
    for vals in product(value_range, repeat=len(other_verts)):
        phi = {v0: 0}
        phi.update(zip(other_verts, vals))
        if all(trop_balanced_at(G, phi, i) for i in S):
            results.append(phi)
    return results


def compute_kernel_dim(G, S, v0, value_range=range(-3, 4)):
    """Compute tropical kernel dimension by rank of normalized vectors."""
    vectors = enumerate_kernel_normalized(G, S, v0, value_range)
    if len(vectors) <= 1:
        return 0

    verts = sorted(G.vertices)
    base = [vectors[0][v] for v in verts]
    diffs = []
    for vec in vectors[1:]:
        diff = [vec[v] - b for v, b in zip(verts, base)]
        if any(x != 0 for x in diff):
            diffs.append(diff)

    if not diffs:
        return 0

    # Gaussian elimination for rank
    n = len(verts)
    matrix = [row[:] for row in diffs]
    rank = 0
    for col in range(n):
        pivot_row = None
        for row in range(rank, len(matrix)):
            if matrix[row][col] != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue
        matrix[rank], matrix[pivot_row] = matrix[pivot_row], matrix[rank]
        pv = matrix[rank][col]
        for row in range(len(matrix)):
            if row != rank and matrix[row][col] != 0:
                fn = matrix[row][col]
                for c in range(n):
                    matrix[row][c] = matrix[row][c] * pv - fn * matrix[rank][c]
        rank += 1
    return rank


# =========================================================================
# Demo scenarios
# =========================================================================

def demo_triangle():
    """Demonstrate tropical balance on weighted triangles."""
    print("=" * 60)
    print("DEMO 1: Weighted Triangle — Generic vs Degenerate")
    print("=" * 60)

    # Generic triangle: all edge weights distinct from each vertex
    G_gen = WeightedGraph([1, 2, 3], [(1, 2, 1), (1, 3, 2), (2, 3, 3)])
    phi_zero = {1: 0, 2: 0, 3: 0}

    print("\nGeneric triangle: w(1,2)=1, w(1,3)=2, w(2,3)=3")
    print(f"  Generic weights: {is_generic_weights(G_gen)}")
    for v in [1, 2, 3]:
        print(f"  Zero potential balanced at {v}: {trop_balanced_at(G_gen, phi_zero, v)}")

    # Degenerate triangle: vertex 1 sees equal weights to 2 and 3
    G_deg = WeightedGraph([1, 2, 3], [(1, 2, 1), (1, 3, 1), (2, 3, 3)])
    print("\nDegenerate triangle: w(1,2)=1, w(1,3)=1, w(2,3)=3")
    print(f"  Generic weights: {is_generic_weights(G_deg)}")
    for v in [1, 2, 3]:
        print(f"  Zero potential balanced at {v}: {trop_balanced_at(G_deg, phi_zero, v)}")

    print(f"\n  Weight degeneracy count (S={{1,2,3}}): {weight_degeneracy_count(G_deg, {1,2,3})}")


def demo_kernel_dimension():
    """Demonstrate how weight degeneracy affects kernel dimension."""
    print("\n" + "=" * 60)
    print("DEMO 2: Kernel Dimension under Weight Perturbation")
    print("=" * 60)

    S = {1, 2, 3}
    v0 = 1

    # Sweep: perturb w(1,3) from 1 to 5
    print("\nTriangle with w(1,2)=1, w(2,3)=3, varying w(1,3):")
    print(f"{'w(1,3)':<10} {'Generic':<10} {'Degeneracy':<12} {'Kernel vectors (normalized)':<30}")
    print("-" * 62)

    for w13 in range(1, 6):
        G = WeightedGraph([1, 2, 3], [(1, 2, 1), (1, 3, w13), (2, 3, 3)])
        gen = is_generic_weights(G)
        deg = weight_degeneracy_count(G, S)
        kvecs = enumerate_kernel_normalized(G, S, v0, range(-4, 5))
        print(f"{w13:<10} {str(gen):<10} {deg:<12} {len(kvecs)}")


def demo_square():
    """Demonstrate tropical balance on weighted 4-cycles."""
    print("\n" + "=" * 60)
    print("DEMO 3: Weighted Square — Cycle Compatibility")
    print("=" * 60)

    # Square with all equal weights (maximally degenerate)
    G_equal = WeightedGraph([1, 2, 3, 4],
        [(1, 2, 1), (2, 3, 1), (3, 4, 1), (1, 4, 1)])
    S = {1, 2, 3, 4}
    phi_zero = {1: 0, 2: 0, 3: 0, 4: 0}

    print("\nEqual-weight square: all weights = 1")
    print(f"  Generic: {is_generic_weights(G_equal)}")
    print(f"  Degeneracy count: {weight_degeneracy_count(G_equal, S)}")
    for v in [1, 2, 3, 4]:
        print(f"  Zero balanced at {v}: {trop_balanced_at(G_equal, phi_zero, v)}")

    # Find some kernel vectors
    print("\n  Sample kernel vectors (phi(1)=0):")
    kvecs = enumerate_kernel_normalized(G_equal, S, 1, range(-2, 3))
    for phi in kvecs[:5]:
        vals = [phi[v] for v in [1, 2, 3, 4]]
        print(f"    phi = {vals}")
    if len(kvecs) > 5:
        print(f"    ... ({len(kvecs)} total)")

    # Generic square
    G_gen = WeightedGraph([1, 2, 3, 4],
        [(1, 2, 1), (2, 3, 2), (3, 4, 3), (1, 4, 5)])
    print("\nGeneric square: w(1,2)=1, w(2,3)=2, w(3,4)=3, w(1,4)=5")
    print(f"  Generic: {is_generic_weights(G_gen)}")
    kvecs_gen = enumerate_kernel_normalized(G_gen, S, 1, range(-4, 5))
    print(f"  Kernel vectors (normalized): {len(kvecs_gen)}")


def demo_degeneracy_jump():
    """Demonstrate the dimension jump phenomenon."""
    print("\n" + "=" * 60)
    print("DEMO 4: Dimension Jump — Degeneracy Creates New Directions")
    print("=" * 60)

    # K4 with varying weights
    print("\nComplete graph K4, varying one edge weight:")
    print(f"{'w(0,1)':<10} {'Generic':<10} {'Degeneracy':<12} {'Kernel size':<15}")
    print("-" * 47)

    for w01 in range(1, 8):
        G = WeightedGraph([0, 1, 2, 3], [
            (0, 1, w01), (0, 2, 2), (0, 3, 3),
            (1, 2, 4), (1, 3, 5), (2, 3, 6)
        ])
        S = {0, 1, 2, 3}
        gen = is_generic_weights(G)
        deg = weight_degeneracy_count(G, S)
        kvecs = enumerate_kernel_normalized(G, S, 0, range(-3, 4))
        print(f"{w01:<10} {str(gen):<10} {deg:<12} {len(kvecs)}")


def demo_cross_domain():
    """Demonstrate the cross-domain connection to shortest paths."""
    print("\n" + "=" * 60)
    print("DEMO 5: Cross-Domain — Weight Degeneracy = SP Degeneracy")
    print("=" * 60)

    G = WeightedGraph([0, 1, 2, 3, 4], [
        (0, 1, 1), (0, 2, 1), (0, 3, 2),
        (1, 2, 3), (1, 3, 4), (2, 3, 5),
        (3, 4, 1), (2, 4, 1)
    ])
    S = {0, 1, 2, 3, 4}

    print("\n5-vertex graph with mixed degeneracies:")
    print(f"  Generic weights: {is_generic_weights(G)}")
    print(f"  Weight degeneracy count: {weight_degeneracy_count(G, S)}")

    print("\n  Per-vertex degeneracy analysis:")
    for v in sorted(S):
        nbrs = sorted(G.neighbors(v))
        wts = [(n, G.weight(v, n)) for n in nbrs]
        is_deg = any(G.weight(v, a) == G.weight(v, b)
                     for a, b in combinations(nbrs, 2))
        print(f"    Vertex {v}: neighbors {wts}, degenerate: {is_deg}")


def demo_translation_invariance():
    """Demonstrate that the kernel is closed under translation."""
    print("\n" + "=" * 60)
    print("DEMO 6: Translation Invariance of Tropical Kernel")
    print("=" * 60)

    G = WeightedGraph([1, 2, 3], [(1, 2, 1), (1, 3, 1), (2, 3, 2)])
    S = {1, 2, 3}

    # Find a kernel vector
    kvecs = enumerate_kernel_normalized(G, S, 1, range(-4, 5))
    if kvecs:
        phi = kvecs[0]
        print(f"\nOriginal kernel vector: {phi}")
        print(f"  In kernel: {all(trop_balanced_at(G, phi, i) for i in S)}")

        # Translate by various constants
        for c in [-2, 0, 3, 7]:
            phi_shifted = {v: phi[v] + c for v in phi}
            in_kernel = all(trop_balanced_at(G, phi_shifted, i) for i in S)
            print(f"  Shifted by {c}: {phi_shifted} -> in kernel: {in_kernel}")
    else:
        print("\nNo kernel vectors found in range.")


if __name__ == "__main__":
    demo_triangle()
    demo_kernel_dimension()
    demo_square()
    demo_degeneracy_jump()
    demo_cross_domain()
    demo_translation_invariance()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


"""
Visualization: Tropical Balance Heatmap

This script visualizes how tropical balance depends on edge weights
by showing a heatmap of balance status across a 2-parameter family
of weighted triangles.

For a triangle with vertices {1,2,3}, we fix w(2,3)=3 and vary
w(1,2) and w(1,3) from 1 to 10. The heatmap shows the number of
tropically balanced vertices (under the zero potential) as the
weights change.

Key insight: Balance (minimum attained twice) occurs exactly along
weight-degeneracy lines where w(1,2) = w(1,3) or similar equalities.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from collections import defaultdict


class WeightedGraph:
    def __init__(self, vertices, edges):
        self.vertices = set(vertices)
        self.adj = defaultdict(set)
        self.weights = {}
        for u, v, w in edges:
            self.adj[u].add(v)
            self.adj[v].add(u)
            self.weights[(u, v)] = w
            self.weights[(v, u)] = w

    def neighbors(self, v):
        return self.adj[v]

    def weight(self, u, v):
        return self.weights.get((u, v), 0)


def trop_balanced_at(G, phi, i):
    nbrs = G.neighbors(i)
    if len(nbrs) < 2:
        return False
    vals = [G.weight(i, j) + phi.get(j, 0) for j in nbrs]
    min_val = min(vals)
    return vals.count(min_val) >= 2


# Generate heatmap data
w23 = 3
w12_range = np.arange(1, 11)
w13_range = np.arange(1, 11)

balance_count = np.zeros((len(w13_range), len(w12_range)))
phi_zero = {1: 0, 2: 0, 3: 0}

for i, w13 in enumerate(w13_range):
    for j, w12 in enumerate(w12_range):
        G = WeightedGraph([1, 2, 3], [
            (1, 2, int(w12)), (1, 3, int(w13)), (2, 3, w23)
        ])
        count = sum(1 for v in [1, 2, 3] if trop_balanced_at(G, phi_zero, v))
        balance_count[i, j] = count

# Plot
fig, ax = plt.subplots(1, 1, figsize=(8, 7))

im = ax.imshow(balance_count, origin='lower', aspect='auto',
               extent=[0.5, 10.5, 0.5, 10.5],
               cmap='YlOrRd', vmin=0, vmax=3)

ax.set_xlabel('w(1,2)', fontsize=14)
ax.set_ylabel('w(1,3)', fontsize=14)
ax.set_title('Tropical Balance Count on Weighted Triangle\n'
             '(zero potential, w(2,3)=3 fixed)', fontsize=14)

cbar = plt.colorbar(im, ax=ax)
cbar.set_label('Number of balanced vertices', fontsize=12)

# Mark the degeneracy lines
ax.plot([1, 10], [1, 10], 'w--', linewidth=2, label='w(1,2) = w(1,3)')
ax.axhline(y=3, color='cyan', linestyle='--', linewidth=1.5, alpha=0.7,
           label='w(1,3) = w(2,3) = 3')
ax.axvline(x=3, color='lime', linestyle='--', linewidth=1.5, alpha=0.7,
           label='w(1,2) = w(2,3) = 3')

ax.legend(loc='upper left', fontsize=10, framealpha=0.9)
ax.set_xticks(range(1, 11))
ax.set_yticks(range(1, 11))

plt.tight_layout()
plt.savefig('viz_balance_heatmap.png', dpi=150)
print("Saved viz_balance_heatmap.png")


"""
Visualization: Kernel Dimension vs Weight Degeneracy

This script visualizes the relationship between weight degeneracy
and tropical kernel dimension on a family of weighted 4-cycles.

We fix three edge weights and vary the fourth, plotting:
- The weight degeneracy count
- The number of normalized kernel vectors found
- The predicted dimension from the degeneracy invariant

Key insight: The kernel dimension jumps exactly when new weight
degeneracies appear — confirming that tropical kernel growth is
controlled by weight degeneracy data.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations, product
from collections import defaultdict


class WeightedGraph:
    def __init__(self, vertices, edges):
        self.vertices = set(vertices)
        self.adj = defaultdict(set)
        self.weights = {}
        for u, v, w in edges:
            self.adj[u].add(v)
            self.adj[v].add(u)
            self.weights[(u, v)] = w
            self.weights[(v, u)] = w

    def neighbors(self, v):
        return self.adj[v]

    def weight(self, u, v):
        return self.weights.get((u, v), 0)


def trop_balanced_at(G, phi, i):
    nbrs = G.neighbors(i)
    if len(nbrs) < 2:
        return False
    vals = [G.weight(i, j) + phi.get(j, 0) for j in nbrs]
    min_val = min(vals)
    return vals.count(min_val) >= 2


def weight_degeneracy_count(G, S):
    count = 0
    for i in S:
        nbrs = list(G.neighbors(i))
        for a, b in combinations(nbrs, 2):
            if G.weight(i, a) == G.weight(i, b):
                count += 1
                break
    return count


def count_kernel_vectors(G, S, v0, vr=range(-4, 5)):
    verts = sorted(G.vertices)
    others = [v for v in verts if v != v0]
    count = 0
    for vals in product(vr, repeat=len(others)):
        phi = {v0: 0}
        phi.update(zip(others, vals))
        if all(trop_balanced_at(G, phi, i) for i in S):
            count += 1
    return count


# Parameters
w_vary = list(range(1, 12))
S = {1, 2, 3, 4}
v0 = 1

# Fixed weights
w23 = 3
w34 = 5
w14 = 7

degeneracies = []
kernel_sizes = []

for w12 in w_vary:
    G = WeightedGraph([1, 2, 3, 4], [
        (1, 2, w12), (2, 3, w23), (3, 4, w34), (1, 4, w14)
    ])
    deg = weight_degeneracy_count(G, S)
    ks = count_kernel_vectors(G, S, v0, range(-3, 4))
    degeneracies.append(deg)
    kernel_sizes.append(ks)

# Plot
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8), sharex=True)

# Top: kernel size
ax1.bar(w_vary, kernel_sizes, color='steelblue', alpha=0.8, edgecolor='navy')
ax1.set_ylabel('Normalized kernel vectors', fontsize=13)
ax1.set_title('Tropical Kernel Size vs Edge Weight\n'
              '(4-cycle, w(2,3)=3, w(3,4)=5, w(1,4)=7, varying w(1,2))',
              fontsize=13)
ax1.grid(axis='y', alpha=0.3)

# Highlight degeneracy points
for i, (w, d) in enumerate(zip(w_vary, degeneracies)):
    if d > 0:
        ax1.bar(w, kernel_sizes[i], color='crimson', alpha=0.8, edgecolor='darkred')

# Bottom: degeneracy count
colors = ['crimson' if d > 0 else 'gray' for d in degeneracies]
ax2.bar(w_vary, degeneracies, color=colors, alpha=0.8, edgecolor='black')
ax2.set_xlabel('w(1,2)', fontsize=13)
ax2.set_ylabel('Weight degeneracy count', fontsize=13)
ax2.set_title('Weight Degeneracy Count', fontsize=13)
ax2.grid(axis='y', alpha=0.3)
ax2.set_xticks(w_vary)

# Add annotations for degenerate values
for w, d, k in zip(w_vary, degeneracies, kernel_sizes):
    if d > 0:
        ax1.annotate(f'deg={d}', (w, k), textcoords="offset points",
                     xytext=(0, 5), ha='center', fontsize=9, color='red')

plt.tight_layout()
plt.savefig('viz_kernel_dimension.png', dpi=150)
print("Saved viz_kernel_dimension.png")


"""
Visualization: Network Resilience via Tropical Balance

This script visualizes a network resilience analysis using tropical
balance as a metric. Nodes are colored by their balance status
(resilient vs vulnerable) and edges are colored by weight degeneracy.

Key insight: Nodes where the minimum-weight edge is achieved by
multiple neighbors are "tropically balanced" — they have redundant
optimal routes and are thus more resilient to single-link failures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from collections import defaultdict


class WeightedGraph:
    def __init__(self, vertices, edges):
        self.vertices = set(vertices)
        self.adj = defaultdict(set)
        self.weights = {}
        self.edge_list = edges
        for u, v, w in edges:
            self.adj[u].add(v)
            self.adj[v].add(u)
            self.weights[(u, v)] = w
            self.weights[(v, u)] = w

    def neighbors(self, v):
        return self.adj[v]

    def weight(self, u, v):
        return self.weights.get((u, v), 0)


def trop_balanced_at(G, phi, i):
    nbrs = G.neighbors(i)
    if len(nbrs) < 2:
        return False
    vals = [G.weight(i, j) + phi.get(j, 0) for j in nbrs]
    min_val = min(vals)
    return vals.count(min_val) >= 2


# Create two network scenarios
def create_resilient_network():
    """Network with high redundancy (many equal-weight links)."""
    return WeightedGraph(
        vertices=list(range(8)),
        edges=[
            (0, 1, 2), (0, 2, 2), (0, 3, 2),  # Hub with redundant links
            (1, 4, 3), (2, 4, 3), (3, 5, 3),   # Symmetric mid-layer
            (1, 5, 3), (2, 5, 3),               # More redundancy
            (4, 6, 1), (5, 6, 1),               # Converge
            (4, 7, 4), (5, 7, 4), (6, 7, 2),   # Final layer
        ]
    )


def create_vulnerable_network():
    """Network with unique optimal routes (all distinct weights)."""
    return WeightedGraph(
        vertices=list(range(8)),
        edges=[
            (0, 1, 1), (0, 2, 2), (0, 3, 4),
            (1, 4, 3), (2, 4, 5), (3, 5, 7),
            (1, 5, 6), (2, 5, 8),
            (4, 6, 9), (5, 6, 10),
            (4, 7, 11), (5, 7, 12), (6, 7, 13),
        ]
    )


def plot_network(G, ax, title, positions):
    """Plot a weighted graph with tropical balance coloring."""
    phi_zero = {v: 0 for v in G.vertices}

    # Draw edges
    for u, v, w in G.edge_list:
        x = [positions[u][0], positions[v][0]]
        y = [positions[u][1], positions[v][1]]
        # Check if this edge contributes to degeneracy at either endpoint
        degenerate = False
        for endpoint in [u, v]:
            nbrs = list(G.neighbors(endpoint))
            for a, b in combinations(nbrs, 2):
                if G.weight(endpoint, a) == G.weight(endpoint, b):
                    if a in (u, v) and b in (u, v):
                        degenerate = True
                    elif endpoint in (u, v):
                        other = u if endpoint == v else v
                        if other in (a, b):
                            nbr2 = b if a == other else a
                            if G.weight(endpoint, other) == G.weight(endpoint, nbr2):
                                degenerate = True

        color = '#e74c3c' if degenerate else '#bdc3c7'
        width = 3 if degenerate else 1.5
        ax.plot(x, y, color=color, linewidth=width, zorder=1)

        # Edge weight label
        mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
        ax.annotate(str(w), (mx, my), fontsize=8, ha='center', va='center',
                    bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8))

    # Draw vertices
    for v in G.vertices:
        balanced = trop_balanced_at(G, phi_zero, v)
        color = '#2ecc71' if balanced else '#e74c3c'
        marker_size = 400
        ax.scatter(positions[v][0], positions[v][1], c=color, s=marker_size,
                   zorder=2, edgecolors='black', linewidths=2)
        ax.annotate(str(v), positions[v], fontsize=12, ha='center', va='center',
                    fontweight='bold', zorder=3)

    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')


# Positions for the 8-node network
positions = {
    0: (0, 1.5),
    1: (1, 2.5), 2: (1, 1.5), 3: (1, 0.5),
    4: (2.5, 2), 5: (2.5, 1),
    6: (3.5, 2), 7: (3.5, 1),
}

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

G_resilient = create_resilient_network()
G_vulnerable = create_vulnerable_network()

plot_network(G_resilient, ax1, 'Resilient Network\n(many equal-weight links)', positions)
plot_network(G_vulnerable, ax2, 'Vulnerable Network\n(all distinct weights)', positions)

# Legend
from matplotlib.patches import Patch
from matplotlib.lines import Line2D
legend_elements = [
    Patch(facecolor='#2ecc71', edgecolor='black', label='Balanced (resilient)'),
    Patch(facecolor='#e74c3c', edgecolor='black', label='Unbalanced (vulnerable)'),
    Line2D([0], [0], color='#e74c3c', linewidth=3, label='Degenerate edge'),
    Line2D([0], [0], color='#bdc3c7', linewidth=1.5, label='Non-degenerate edge'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=4, fontsize=11,
           bbox_to_anchor=(0.5, -0.02))

plt.suptitle('Network Resilience Analysis via Tropical Balance', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('viz_network_resilience.png', dpi=150, bbox_inches='tight')
print("Saved viz_network_resilience.png")
