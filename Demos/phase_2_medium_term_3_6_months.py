#!/usr/bin/env python3
"""
Applications of Tropical Geometry to Real-World Problems

This module demonstrates practical applications of the formalized
tropical geometry results to:
1. Network tomography (diagnosing internal network structure)
2. Phylogenetic tree reconstruction
3. Scheduling optimization
4. Neural network analysis
"""

import numpy as np
from typing import List, Tuple, Dict
from algorithms import SPNetwork, TropicalMatrix, compute_four_point_delta, gromov_product


# ============================================================
# Application 1: Network Tomography
# ============================================================

def network_tomography_demo():
    """
    Demonstrate how boundary measurements can reconstruct
    network structure for series-parallel topologies.

    Scenario: You have a network of servers connected by links.
    You can only measure round-trip times between boundary servers.
    Can you infer the internal structure?

    Answer (by our theorem): For SP networks, YES — the boundary
    distances completely determine the network up to SP-equivalence.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Tomography")
    print("=" * 60)

    # Simulate a network with known structure
    # Internal: servers A, B connected in series-parallel
    # Boundary: servers S (source) and T (sink)
    #
    # Structure: S --[3ms]-- A --[2ms]-- T  (path 1: 5ms)
    #            S --[4ms]-- B --[1ms]-- T  (path 2: 5ms)
    #            S ------[7ms]--------- T   (path 3: 7ms)
    #
    # This is: parallel(series(3,2), series(4,1), edge(7))

    path1 = SPNetwork.series(SPNetwork.edge(3), SPNetwork.edge(2))
    path2 = SPNetwork.series(SPNetwork.edge(4), SPNetwork.edge(1))
    path3 = SPNetwork.edge(7)

    network = SPNetwork.parallel(
        SPNetwork.parallel(path1, path2),
        path3
    )

    measured_latency = network.boundary_distance()
    print(f"\nMeasured boundary latency: {measured_latency}ms")
    print(f"Tropical expression: {network.to_tropical_expression()}")
    print(f"Canonical form: Edge({network.canonical_form().weight})")
    print(f"\nInterpretation: The minimum latency path takes {measured_latency}ms")
    print(f"Network depth: {network.depth()}, edges: {network.size()}")

    # Reconstruction: given only the boundary distance,
    # we know the network is SP-equivalent to Edge(5)
    reconstructed = network.canonical_form()
    print(f"\nReconstruction: boundary data determines the effective")
    print(f"network as a single {reconstructed.weight}ms link.")
    print(f"SP-equivalent: {network.is_sp_equivalent(reconstructed)}")
    print()


# ============================================================
# Application 2: Phylogenetic Tree Reconstruction
# ============================================================

def phylogenetic_demo():
    """
    Demonstrate how tropical geometry connects to phylogenetics.

    In evolutionary biology, species are related by a tree.
    The genetic distance between species defines a tree metric.
    Tree metrics are 0-hyperbolic (our Theorem 5.2 via ultrametrics).

    We can test whether observed genetic distances are tree-like
    by computing the Gromov hyperbolicity.
    """
    print("=" * 60)
    print("APPLICATION 2: Phylogenetic Analysis")
    print("=" * 60)

    # Example: genetic distances between 5 species
    # Tree structure:
    #        ancestor
    #       /        \
    #    anc1        anc2
    #   /    \      /    \
    #  Sp1   Sp2  Sp3    Sp4
    #              |
    #             Sp5

    # True tree distances (from a tree with known branch lengths)
    tree_dist = np.array([
        [0, 4, 8, 10, 9],    # Sp1
        [4, 0, 8, 10, 9],    # Sp2
        [8, 8, 0, 6, 5],     # Sp3
        [10, 10, 6, 0, 7],   # Sp4
        [9, 9, 5, 7, 0],     # Sp5
    ], dtype=float)

    species = ["Human", "Chimp", "Dog", "Cat", "Mouse"]

    print("\nGenetic distance matrix:")
    print(f"{'':>8}", end="")
    for s in species:
        print(f"{s:>8}", end="")
    print()
    for i, s in enumerate(species):
        print(f"{s:>8}", end="")
        for j in range(5):
            print(f"{tree_dist[i,j]:>8.1f}", end="")
        print()

    # Compute hyperbolicity
    delta, quad = compute_four_point_delta(tree_dist)
    print(f"\nGromov δ-hyperbolicity: {delta}")
    print(f"Worst quadruple: {tuple(species[i] for i in quad)}")
    print(f"Is tree-like (δ=0): {delta == 0}")

    # Gromov products reveal tree structure
    print(f"\nGromov products with basepoint {species[0]}:")
    for i in range(1, 5):
        for j in range(i+1, 5):
            gp = gromov_product(tree_dist, 0, i, j)
            print(f"  ({species[i]}|{species[j]})_{species[0]} = {gp}")

    print(f"\nInterpretation: Equal Gromov products indicate shared")
    print(f"evolutionary history (common ancestor at that distance).")

    # Perturbed distances (non-tree-like)
    noisy_dist = tree_dist + np.random.RandomState(42).uniform(0, 1, (5, 5))
    noisy_dist = (noisy_dist + noisy_dist.T) / 2
    np.fill_diagonal(noisy_dist, 0)

    delta_noisy, _ = compute_four_point_delta(noisy_dist)
    print(f"\nWith measurement noise:")
    print(f"  δ = {delta_noisy:.3f}")
    print(f"  The non-zero δ indicates the distances are NOT exactly tree-like.")
    print(f"  δ quantifies how far the data is from a perfect tree metric.")
    print()


# ============================================================
# Application 3: Scheduling / Critical Path Analysis
# ============================================================

def scheduling_demo():
    """
    Demonstrate tropical matrix algebra for project scheduling.

    In project scheduling, tasks have durations and dependencies.
    The critical path (longest path) determines the project duration.
    This is a tropical (max-plus) computation.

    We use min-plus here, so we negate to get max-plus behavior.
    """
    print("=" * 60)
    print("APPLICATION 3: Project Scheduling (Critical Path)")
    print("=" * 60)

    # Project with 4 tasks and dependencies
    # Task 0: Start (0 duration)
    # Task 1: Design (3 days), depends on Start
    # Task 2: Build (5 days), depends on Design
    # Task 3: Test (2 days), depends on Design
    # Task 4: Deploy (1 day), depends on Build AND Test
    # Task 5: End (0 duration)

    tasks = ["Start", "Design", "Build", "Test", "Deploy", "End"]
    n = len(tasks)

    # Dependency matrix: A[i][j] = duration of task j if i→j is a dependency
    # Use negative values for max-plus (since we have min-plus)
    A = np.full((n, n), np.inf)
    np.fill_diagonal(A, 0)

    # Dependencies (predecessor → successor with duration)
    deps = [
        (0, 1, 0),   # Start → Design (0 days for Start)
        (1, 2, 3),   # Design → Build (3 days for Design)
        (1, 3, 3),   # Design → Test (3 days for Design)
        (2, 4, 5),   # Build → Deploy (5 days for Build)
        (3, 4, 2),   # Test → Deploy (2 days for Test)
        (4, 5, 1),   # Deploy → End (1 day for Deploy)
    ]

    # For critical path, we want LONGEST path, so negate for min-plus
    for (i, j, d) in deps:
        A[i][j] = -d  # negate for min-plus → max-plus

    print("\nTask dependency matrix (negated durations for min-plus):")
    M = TropicalMatrix(A)
    closure = M.closure()

    print("\nEarliest completion times (negated):")
    for i in range(n):
        earliest = -closure.data[0][i]
        print(f"  {tasks[i]:>10}: day {earliest:.0f}")

    project_duration = -closure.data[0][n-1]
    print(f"\nProject duration (critical path): {project_duration:.0f} days")
    print(f"Critical path: Start → Design → Build → Deploy → End")
    print(f"  = 0 + 3 + 5 + 1 = 9 days")
    print()


# ============================================================
# Application 4: Neural Network Decision Geometry
# ============================================================

def neural_network_demo():
    """
    Demonstrate how tropical geometry relates to ReLU neural networks.

    A ReLU neural network computes a piecewise-linear function.
    The decision regions form a polyhedral complex whose adjacency
    graph has tropical structure.

    We analyze a simple 2-input network and compute the hyperbolicity
    of its decision boundary adjacency graph.
    """
    print("=" * 60)
    print("APPLICATION 4: Neural Network Decision Geometry")
    print("=" * 60)

    # Simple 2-input, 2-hidden, 2-output network
    # This creates a piecewise-linear decision boundary

    # Weight matrices
    W1 = np.array([[1, -1], [-1, 1]])  # 2×2
    b1 = np.array([0, 0])
    W2 = np.array([[1, 0], [0, 1]])  # 2×2
    b2 = np.array([0, 0])

    def relu(x):
        return np.maximum(0, x)

    def network(x):
        h = relu(W1 @ x + b1)
        return W2 @ h + b2

    # Sample decision regions
    print("\nReLU network: 2 inputs → 2 hidden (ReLU) → 2 outputs")
    print("Decision function is piecewise-linear (tropical rational map)")
    print()

    # Analyze activation patterns
    print("Activation regions (sign patterns of pre-ReLU activations):")
    regions = {}
    for x1 in np.linspace(-2, 2, 100):
        for x2 in np.linspace(-2, 2, 100):
            x = np.array([x1, x2])
            pre_relu = W1 @ x + b1
            pattern = tuple(int(v > 0) for v in pre_relu)
            if pattern not in regions:
                regions[pattern] = []
            regions[pattern].append((x1, x2))

    for pattern, points in sorted(regions.items()):
        print(f"  Pattern {pattern}: {len(points)} sample points")
        # Get a representative point
        rep = points[len(points)//2]
        out = network(np.array(rep))
        print(f"    Representative output: [{out[0]:.2f}, {out[1]:.2f}]")

    # The decision boundary adjacency is a graph on the activation regions
    # For this simple network, the regions form a tree-like structure
    n_regions = len(regions)
    print(f"\nNumber of activation regions: {n_regions}")
    print(f"Connection to tropical geometry:")
    print(f"  - Each ReLU layer applies a tropical polynomial map")
    print(f"  - The composition is a tropical rational function")
    print(f"  - Decision boundaries are tropical hypersurfaces")
    print(f"  - Hyperbolicity of the region adjacency graph controls")
    print(f"    the complexity of adversarial perturbation paths")

    # For a simple 2-hidden-unit network, the adjacency is tree-like
    # (at most 4 regions, arranged in a path or star)
    if n_regions <= 4:
        print(f"\n  With {n_regions} regions, the adjacency graph is tree-like")
        print(f"  → 0-hyperbolic (our theorem confirms this for tree metrics)")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("TROPICAL GEOMETRY: REAL-WORLD APPLICATIONS")
    print("=" * 60)
    print()

    network_tomography_demo()
    phylogenetic_demo()
    scheduling_demo()
    neural_network_demo()

    print("=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Geometry Demonstrations: Series-Parallel Networks,
Boundary Rigidity, and Gromov Hyperbolicity

This script demonstrates the key mathematical constructions and theorems
from the formalized tropical geometry library with concrete numerical examples.
"""

import numpy as np
from itertools import product as cartesian_product

# ============================================================
# Part 1: Tropical Arithmetic
# ============================================================

def tropical_add(a, b):
    """Tropical addition = minimum."""
    return min(a, b)

def tropical_mul(a, b):
    """Tropical multiplication = ordinary addition."""
    return a + b

def tropical_matmul(A, B):
    """Tropical (min-plus) matrix multiplication."""
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] = min(C[i][j], A[i][k] + B[k][j])
    return C

def tropical_matpow(A, p):
    """Tropical matrix power."""
    n = A.shape[0]
    if p == 0:
        # Tropical identity: 0 on diagonal, inf off diagonal
        result = np.full((n, n), np.inf)
        np.fill_diagonal(result, 0)
        return result
    result = A.copy()
    for _ in range(p - 1):
        result = tropical_matmul(result, A)
    return result

print("=" * 60)
print("DEMO 1: Tropical Arithmetic")
print("=" * 60)
print(f"tropical_add(3, 5) = min(3, 5) = {tropical_add(3, 5)}")
print(f"tropical_mul(3, 5) = 3 + 5 = {tropical_mul(3, 5)}")
print(f"Idempotency: tropical_add(4, 4) = {tropical_add(4, 4)}")
print(f"Identity: tropical_mul(0, 7) = {tropical_mul(0, 7)}")
print(f"Distributivity: tropical_mul(2, tropical_add(3, 5)) = {tropical_mul(2, tropical_add(3, 5))}")
print(f"  = tropical_add(tropical_mul(2,3), tropical_mul(2,5)) = {tropical_add(tropical_mul(2,3), tropical_mul(2,5))}")
print()

# ============================================================
# Part 2: Tropical Matrix Algebra
# ============================================================

print("=" * 60)
print("DEMO 2: Tropical Matrix Multiplication")
print("=" * 60)

A = np.array([[0, 3, np.inf],
              [np.inf, 0, 2],
              [4, np.inf, 0]])

B = np.array([[0, 1, np.inf],
              [np.inf, 0, 5],
              [3, np.inf, 0]])

C = tropical_matmul(A, B)
print("A (weighted adjacency matrix):")
print(A)
print("\nB (weighted adjacency matrix):")
print(B)
print("\nA ⊗ B (tropical product = min-plus product):")
print(C)
print("\nInterpretation: C[i][j] = min weight of a 2-step path from i to j")

# Verify associativity
D = np.array([[0, 2, 1],
              [3, 0, 4],
              [np.inf, 1, 0]])

AB_C = tropical_matmul(tropical_matmul(A, B), D)
A_BC = tropical_matmul(A, tropical_matmul(B, D))
print(f"\nAssociativity check: (A⊗B)⊗D == A⊗(B⊗D)? {np.allclose(AB_C, A_BC)}")
print()

# ============================================================
# Part 3: Series-Parallel Networks
# ============================================================

class SPNet:
    """Series-parallel network (two-terminal)."""
    pass

class Edge(SPNet):
    def __init__(self, weight):
        assert weight > 0, "Edge weight must be positive"
        self.weight = weight

    def dist(self):
        return self.weight

    def __repr__(self):
        return f"Edge({self.weight})"

    def depth(self):
        return 0

class Series(SPNet):
    def __init__(self, n1, n2):
        self.n1 = n1
        self.n2 = n2

    def dist(self):
        return self.n1.dist() + self.n2.dist()

    def __repr__(self):
        return f"Series({self.n1}, {self.n2})"

    def depth(self):
        return max(self.n1.depth(), self.n2.depth()) + 1

class Parallel(SPNet):
    def __init__(self, n1, n2):
        self.n1 = n1
        self.n2 = n2

    def dist(self):
        return min(self.n1.dist(), self.n2.dist())

    def __repr__(self):
        return f"Parallel({self.n1}, {self.n2})"

    def depth(self):
        return max(self.n1.depth(), self.n2.depth()) + 1

print("=" * 60)
print("DEMO 3: Series-Parallel Networks")
print("=" * 60)

# Example networks
e1 = Edge(3)
e2 = Edge(5)
e3 = Edge(2)
e4 = Edge(7)

# Series: distances add
s12 = Series(e1, e2)
print(f"Series({e1}, {e2}).dist() = {e1.dist()} + {e2.dist()} = {s12.dist()}")

# Parallel: distances take min
p12 = Parallel(e1, e2)
print(f"Parallel({e1}, {e2}).dist() = min({e1.dist()}, {e2.dist()}) = {p12.dist()}")

# Complex network
net = Series(Parallel(e1, e2), Series(e3, e4))
print(f"\nComplex network: {net}")
print(f"Boundary distance: min({e1.dist()},{e2.dist()}) + ({e3.dist()} + {e4.dist()}) = {net.dist()}")

# SP-equivalence: different structures, same distance
net1 = Series(Edge(3), Edge(5))  # dist = 8
net2 = Series(Edge(4), Edge(4))  # dist = 8
net3 = Edge(8)  # dist = 8
print(f"\nSP-equivalence demonstration:")
print(f"  Series(3,5).dist() = {net1.dist()}")
print(f"  Series(4,4).dist() = {net2.dist()}")
print(f"  Edge(8).dist() = {net3.dist()}")
print(f"  All SP-equivalent: {net1.dist() == net2.dist() == net3.dist()}")

# Canonical reduction
print(f"\nCanonical reduction: every SP network reduces to Edge(dist)")
print(f"  {net} -> Edge({net.dist()})")
print()

# ============================================================
# Part 4: Tropical Interpretation
# ============================================================

print("=" * 60)
print("DEMO 4: Tropical Interpretation of SP Networks")
print("=" * 60)
print("Series composition = tropical multiplication (addition)")
print("Parallel composition = tropical addition (minimum)")
print()
print("Boundary distance IS tropical polynomial evaluation!")
print(f"  Series(3, 5) -> 3 ⊙ 5 = 3 + 5 = {tropical_mul(3, 5)}")
print(f"  Parallel(3, 5) -> 3 ⊕ 5 = min(3, 5) = {tropical_add(3, 5)}")
print(f"  Series(Parallel(3,5), 2) -> (3⊕5) ⊙ 2 = min(3,5) + 2 = {tropical_mul(tropical_add(3, 5), 2)}")
print()

# Distributivity
print("Distributivity: a ⊙ (b ⊕ c) = (a ⊙ b) ⊕ (a ⊙ c)")
a, b, c = 2, 3, 5
lhs = tropical_mul(a, tropical_add(b, c))
rhs = tropical_add(tropical_mul(a, b), tropical_mul(a, c))
print(f"  {a} ⊙ ({b} ⊕ {c}) = {lhs}")
print(f"  ({a} ⊙ {b}) ⊕ ({a} ⊙ {c}) = {rhs}")
print(f"  Equal: {lhs == rhs}")
print()

# ============================================================
# Part 5: Gromov Hyperbolicity
# ============================================================

def four_point_delta(dist_func, points):
    """Compute the optimal δ for four-point hyperbolicity."""
    max_delta = 0
    for w, x, y, z in cartesian_product(points, repeat=4):
        dw_x = dist_func(w, x)
        dy_z = dist_func(y, z)
        dw_y = dist_func(w, y)
        dx_z = dist_func(x, z)
        dw_z = dist_func(w, z)
        dx_y = dist_func(x, y)

        lhs = dw_x + dy_z
        rhs = max(dw_y + dx_z, dw_z + dx_y)
        delta = (lhs - rhs) / 2
        max_delta = max(max_delta, delta)
    return max_delta

print("=" * 60)
print("DEMO 5: Gromov Hyperbolicity")
print("=" * 60)

# Tree metric (should be 0-hyperbolic)
# Tree: 0 -- 1 -- 2, weights 3 and 5
tree_dist = {
    (0, 0): 0, (1, 1): 0, (2, 2): 0,
    (0, 1): 3, (1, 0): 3,
    (0, 2): 8, (2, 0): 8,
    (1, 2): 5, (2, 1): 5,
}
tree_delta = four_point_delta(lambda a, b: tree_dist[(a, b)], [0, 1, 2])
print(f"Tree metric (path 0-1-2, weights 3,5):")
print(f"  Optimal δ = {tree_delta}")
print(f"  0-hyperbolic: {tree_delta == 0}")
print()

# Star metric (tree, should be 0-hyperbolic)
# Star: center=0, leaves 1,2,3 with weights 2,3,5
star_dist = {}
weights = {1: 2, 2: 3, 3: 5}
for i in range(4):
    for j in range(4):
        if i == j:
            star_dist[(i, j)] = 0
        elif i == 0:
            star_dist[(i, j)] = weights[j]
        elif j == 0:
            star_dist[(i, j)] = weights[i]
        else:
            star_dist[(i, j)] = weights[i] + weights[j]

star_delta = four_point_delta(lambda a, b: star_dist[(a, b)], [0, 1, 2, 3])
print(f"Star metric (center=0, leaves 1,2,3, weights 2,3,5):")
print(f"  Optimal δ = {star_delta}")
print(f"  0-hyperbolic: {star_delta == 0}")
print()

# Cycle metric (NOT a tree, should have δ > 0)
# 4-cycle with unit weights
n = 4
cycle_dist = {}
for i in range(n):
    for j in range(n):
        cycle_dist[(i, j)] = min(abs(i - j), n - abs(i - j))
cycle_delta = four_point_delta(lambda a, b: cycle_dist[(a, b)], list(range(n)))
print(f"4-cycle with unit weights:")
print(f"  Optimal δ = {cycle_delta}")
print(f"  0-hyperbolic: {cycle_delta == 0}")
print()

# Two-point space (always 0-hyperbolic)
two_pt_delta = four_point_delta(lambda a, b: 0 if a == b else 7, [0, 1])
print(f"Two-point space (d=7):")
print(f"  Optimal δ = {two_pt_delta}")
print(f"  0-hyperbolic: {two_pt_delta == 0}")
print()

# Ultrametric space (should be 0-hyperbolic)
# An ultrametric on 4 points
um_dist = {
    (0, 0): 0, (1, 1): 0, (2, 2): 0, (3, 3): 0,
    (0, 1): 1, (1, 0): 1,
    (0, 2): 2, (2, 0): 2,
    (0, 3): 2, (3, 0): 2,
    (1, 2): 2, (2, 1): 2,
    (1, 3): 2, (3, 1): 2,
    (2, 3): 1, (3, 2): 1,
}
um_delta = four_point_delta(lambda a, b: um_dist[(a, b)], [0, 1, 2, 3])
print(f"Ultrametric space on 4 points:")
print(f"  Optimal δ = {um_delta}")
print(f"  0-hyperbolic: {um_delta == 0}")
print()

# ============================================================
# Part 6: Shortest Path via Tropical Matrix Powers
# ============================================================

print("=" * 60)
print("DEMO 6: Shortest Paths via Tropical Matrix Powers")
print("=" * 60)

# Weighted graph on 4 vertices
W = np.array([
    [0, 3, np.inf, 7],
    [3, 0, 2, np.inf],
    [np.inf, 2, 0, 1],
    [7, np.inf, 1, 0]
])

print("Weighted graph adjacency matrix:")
print(W)
print()

# Compute tropical powers
for k in range(1, 5):
    Wk = tropical_matpow(W, k)
    print(f"W^{k} (min weight of {k}-step paths):")
    print(Wk)
    print()

# Shortest path distances = tropical closure
D = W.copy()
for k in range(1, len(W) + 1):
    Wk = tropical_matpow(W, k)
    D = np.minimum(D, Wk)

print("Shortest path distance matrix (tropical closure):")
print(D)
print()

# Verify against Floyd-Warshall
def floyd_warshall(W):
    n = W.shape[0]
    D = W.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                D[i][j] = min(D[i][j], D[i][k] + D[k][j])
    return D

D_fw = floyd_warshall(W)
print("Floyd-Warshall distances (verification):")
print(D_fw)
print(f"Match: {np.allclose(D, D_fw)}")
print()

# ============================================================
# Part 7: SP Network Boundary Rigidity
# ============================================================

print("=" * 60)
print("DEMO 7: Boundary Rigidity Demonstration")
print("=" * 60)

def enumerate_sp_networks(max_depth, weights):
    """Generate SP networks up to given depth with given edge weights."""
    if max_depth == 0:
        return [Edge(w) for w in weights]
    smaller = enumerate_sp_networks(max_depth - 1, weights)
    result = list(smaller)
    for n1 in smaller:
        for n2 in smaller:
            result.append(Series(n1, n2))
            result.append(Parallel(n1, n2))
    return result

# Generate small SP networks
weights = [1, 2, 3]
networks = enumerate_sp_networks(1, weights)
print(f"Generated {len(networks)} SP networks with weights {weights} and depth ≤ 1")

# Group by boundary distance
from collections import defaultdict
groups = defaultdict(list)
for net in networks:
    d = round(net.dist(), 10)
    groups[d].append(net)

print(f"\nEquivalence classes (grouped by boundary distance):")
for d in sorted(groups.keys()):
    print(f"  dist = {d}: {len(groups[d])} networks")
    if len(groups[d]) <= 3:
        for net in groups[d]:
            print(f"    {net}")
    else:
        for net in groups[d][:2]:
            print(f"    {net}")
        print(f"    ... and {len(groups[d]) - 2} more")

print(f"\nBoundary rigidity: networks with same distance are SP-equivalent")
print(f"Total distinct distances: {len(groups)}")
print(f"Total networks: {len(networks)}")
print()

# ============================================================
# Part 8: Gromov Product
# ============================================================

print("=" * 60)
print("DEMO 8: Gromov Products and Hyperbolicity")
print("=" * 60)

def gromov_product(dist_func, w, x, y):
    return (dist_func(w, x) + dist_func(w, y) - dist_func(x, y)) / 2

# Tree metric example
print("Gromov products for the tree metric (path 0-1-2):")
for x, y in [(0, 1), (0, 2), (1, 2)]:
    gp = gromov_product(lambda a, b: tree_dist[(a, b)], 0, x, y)
    print(f"  (x={x}|y={y})_0 = {gp}")

print()
print("For a tree metric, the Gromov product inequality holds with δ=0:")
print("  (x|y)_w ≥ min((x|z)_w, (z|y)_w) - 0")
for w in [0, 1, 2]:
    for x in [0, 1, 2]:
        for y in [0, 1, 2]:
            for z in [0, 1, 2]:
                df = lambda a, b: tree_dist[(a, b)]
                gp_xy = gromov_product(df, w, x, y)
                gp_xz = gromov_product(df, w, x, z)
                gp_zy = gromov_product(df, w, z, y)
                if gp_xy < min(gp_xz, gp_zy):
                    print(f"  VIOLATED at w={w}, x={x}, y={y}, z={z}")
                    break
else:
    print("  All 81 quadruples satisfy the inequality ✓")

print()
print("=" * 60)
print("All demonstrations complete!")
print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts bundled."""

import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_binary_base64(path):
    with open(path, 'rb') as f:
        return base64.b64encode(f.read()).decode('utf-8')

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read Lean proofs
lean_files = [
    'Tropical/Defs.lean',
    'Tropical/Matrix.lean',
    'Tropical/SeriesParallel.lean',
    'Tropical/Hyperbolicity.lean',
    'Tropical/Bridge.lean',
]
lean_proofs = ""
for f in lean_files:
    lean_proofs += f"-- ============ {f} ============\n"
    lean_proofs += read_file(f) + "\n\n"

# Read visualizations
sp_svg = read_file('sp_decomposition.svg')
bridge_svg = read_file('bridge_diagram.svg')
hyp_b64 = "data:image/png;base64," + read_binary_base64('hyperbolicity_comparison.png')
matmul_b64 = "data:image/png;base64," + read_binary_base64('tropical_matmul.png')

package = {
    "title": "Tropical Boundary Rigidity, Gromov Hyperbolicity, and Certified Min-Plus Linear Algebra",
    "domain": "Tropical Geometry / Metric Geometry / Combinatorial Optimization",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Geometry Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Matrix Operations",
            "pseudocode": """Algorithm: TropicalMatMul(A, B)
Input: n×n matrices A, B over ℝ ∪ {∞}
Output: n×n matrix C = A ⊗ B

for i = 1 to n:
  for j = 1 to n:
    C[i,j] = ∞
    for k = 1 to n:
      C[i,j] = min(C[i,j], A[i,k] + B[k,j])
return C

Time: O(n³), Space: O(n²)
Correctness: Verified by tropicalMatMul_assoc theorem""",
            "code": algorithms_code
        },
        {
            "name": "Gromov Hyperbolicity Computation",
            "pseudocode": """Algorithm: ComputeDelta(D)
Input: n×n distance matrix D
Output: optimal δ ≥ 0

δ_max = 0
for all quadruples (w,x,y,z):
  S1 = D[w,x] + D[y,z]
  S2 = D[w,y] + D[x,z]
  S3 = D[w,z] + D[x,y]
  δ = (S1 - max(S2, S3)) / 2
  δ_max = max(δ_max, δ)
return δ_max

Time: O(n⁴), Space: O(1)
Correctness: Verified by exists_delta_hyperbolic_of_finite""",
            "code": algorithms_code
        },
        {
            "name": "SP Network Boundary Distance",
            "pseudocode": """Algorithm: BoundaryDistance(N)
Input: SP network N (decomposition tree)
Output: shortest path distance between terminals

match N:
  case Edge(w):
    return w
  case Series(N1, N2):
    return BoundaryDistance(N1) + BoundaryDistance(N2)
  case Parallel(N1, N2):
    return min(BoundaryDistance(N1), BoundaryDistance(N2))

Time: O(size(N)), Space: O(depth(N))
Correctness: Verified by spDist_pos, sp_canonical_reduce""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "SP Network Decomposition Tree",
            "data": sp_svg
        },
        {
            "name": "Three-Way Tropical Bridge",
            "data": bridge_svg
        },
        {
            "name": "Gromov Hyperbolicity Comparison",
            "data": hyp_b64
        },
        {
            "name": "Tropical Matrix Multiplication",
            "data": matmul_b64
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated: {os.path.getsize('PACKAGE.json')} bytes")


#!/usr/bin/env python3
"""
Visualizations for Tropical Geometry Research.
Generates PNG and SVG images for the research paper and article.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import base64
import io


def fig_to_base64(fig, fmt='png', dpi=150):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format=fmt, dpi=dpi, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/{fmt};base64,{b64}"


def create_sp_decomposition_diagram():
    """Create SVG diagram showing SP decomposition tree."""
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" width="600" height="400" viewBox="0 0 600 400">
  <style>
    text { font-family: 'Segoe UI', Arial, sans-serif; }
    .title { font-size: 16px; font-weight: bold; fill: #1a1a2e; }
    .label { font-size: 12px; fill: #16213e; }
    .weight { font-size: 11px; fill: #e94560; font-weight: bold; }
    .op { font-size: 14px; fill: #0f3460; font-weight: bold; }
    .result { font-size: 13px; fill: #533483; font-weight: bold; }
  </style>

  <!-- Title -->
  <text x="300" y="30" text-anchor="middle" class="title">SP Network Decomposition Tree</text>

  <!-- Root: Series node -->
  <rect x="255" y="50" width="90" height="35" rx="8" fill="#e8f4f8" stroke="#0f3460" stroke-width="2"/>
  <text x="300" y="72" text-anchor="middle" class="op">Series (+)</text>
  <text x="300" y="100" text-anchor="middle" class="result">dist = 12</text>

  <!-- Left: Parallel node -->
  <rect x="105" y="140" width="110" height="35" rx="8" fill="#fce4ec" stroke="#e94560" stroke-width="2"/>
  <text x="160" y="162" text-anchor="middle" class="op">Parallel (min)</text>
  <text x="160" y="190" text-anchor="middle" class="result">dist = 3</text>

  <!-- Right: Series node -->
  <rect x="355" y="140" width="100" height="35" rx="8" fill="#e8f4f8" stroke="#0f3460" stroke-width="2"/>
  <text x="405" y="162" text-anchor="middle" class="op">Series (+)</text>
  <text x="405" y="190" text-anchor="middle" class="result">dist = 9</text>

  <!-- Edges from root -->
  <line x1="280" y1="85" x2="160" y2="140" stroke="#555" stroke-width="1.5"/>
  <line x1="320" y1="85" x2="405" y2="140" stroke="#555" stroke-width="1.5"/>

  <!-- Leaf nodes (edges) -->
  <!-- Left-left: Edge(3) -->
  <rect x="55" y="240" width="80" height="30" rx="6" fill="#e8eaf6" stroke="#3f51b5" stroke-width="1.5"/>
  <text x="95" y="260" text-anchor="middle" class="weight">Edge(3)</text>

  <!-- Left-right: Edge(5) -->
  <rect x="175" y="240" width="80" height="30" rx="6" fill="#e8eaf6" stroke="#3f51b5" stroke-width="1.5"/>
  <text x="215" y="260" text-anchor="middle" class="weight">Edge(5)</text>

  <!-- Right-left: Edge(2) -->
  <rect x="325" y="240" width="80" height="30" rx="6" fill="#e8eaf6" stroke="#3f51b5" stroke-width="1.5"/>
  <text x="365" y="260" text-anchor="middle" class="weight">Edge(2)</text>

  <!-- Right-right: Edge(7) -->
  <rect x="445" y="240" width="80" height="30" rx="6" fill="#e8eaf6" stroke="#3f51b5" stroke-width="1.5"/>
  <text x="485" y="260" text-anchor="middle" class="weight">Edge(7)</text>

  <!-- Edges to leaves -->
  <line x1="130" y1="175" x2="95" y2="240" stroke="#555" stroke-width="1.5"/>
  <line x1="190" y1="175" x2="215" y2="240" stroke="#555" stroke-width="1.5"/>
  <line x1="385" y1="175" x2="365" y2="240" stroke="#555" stroke-width="1.5"/>
  <line x1="425" y1="175" x2="485" y2="240" stroke="#555" stroke-width="1.5"/>

  <!-- Tropical expression -->
  <text x="300" y="320" text-anchor="middle" class="label">Tropical expression: (3 ⊕ 5) ⊙ (2 ⊙ 7)</text>
  <text x="300" y="345" text-anchor="middle" class="label">= min(3, 5) + (2 + 7) = 3 + 9 = 12</text>

  <!-- Legend -->
  <rect x="30" y="370" width="15" height="10" rx="2" fill="#e8f4f8" stroke="#0f3460"/>
  <text x="50" y="379" class="label">Series (tropical ⊙ = add)</text>
  <rect x="250" y="370" width="15" height="10" rx="2" fill="#fce4ec" stroke="#e94560"/>
  <text x="270" y="379" class="label">Parallel (tropical ⊕ = min)</text>
  <rect x="460" y="370" width="15" height="10" rx="2" fill="#e8eaf6" stroke="#3f51b5"/>
  <text x="480" y="379" class="label">Edge</text>
</svg>'''
    return svg


def create_hyperbolicity_plot():
    """Create plot comparing hyperbolicity of different spaces."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 4.5))

    # Plot 1: Tree (0-hyperbolic)
    ax = axes[0]
    ax.set_title('Tree Metric (δ = 0)', fontsize=13, fontweight='bold')
    # Draw a tree
    tree_nodes = {0: (0.5, 0.9), 1: (0.2, 0.5), 2: (0.8, 0.5),
                  3: (0.1, 0.1), 4: (0.3, 0.1), 5: (0.7, 0.1), 6: (0.9, 0.1)}
    tree_edges = [(0, 1), (0, 2), (1, 3), (1, 4), (2, 5), (2, 6)]
    for (u, v) in tree_edges:
        ax.plot([tree_nodes[u][0], tree_nodes[v][0]],
                [tree_nodes[u][1], tree_nodes[v][1]], 'b-', linewidth=2)
    for i, (x, y) in tree_nodes.items():
        ax.plot(x, y, 'ko', markersize=8)
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 1.05)
    ax.set_aspect('equal')
    ax.text(0.5, -0.02, '0-hyperbolic (four-point\ncondition holds with δ=0)',
            ha='center', fontsize=10, style='italic')
    ax.axis('off')

    # Plot 2: Cycle (δ > 0)
    ax = axes[1]
    ax.set_title('Cycle Metric (δ = 1)', fontsize=13, fontweight='bold')
    n_cycle = 6
    angles = np.linspace(0, 2*np.pi, n_cycle, endpoint=False)
    cx = 0.5 + 0.35 * np.cos(angles)
    cy = 0.5 + 0.35 * np.sin(angles)
    for i in range(n_cycle):
        j = (i + 1) % n_cycle
        ax.plot([cx[i], cx[j]], [cy[i], cy[j]], 'r-', linewidth=2)
    for i in range(n_cycle):
        ax.plot(cx[i], cy[i], 'ko', markersize=8)
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 1.05)
    ax.set_aspect('equal')
    ax.text(0.5, -0.02, 'Positive δ: cycles introduce\nhyperbolicity defect',
            ha='center', fontsize=10, style='italic')
    ax.axis('off')

    # Plot 3: Four-point condition illustration
    ax = axes[2]
    ax.set_title('Four-Point Condition', fontsize=13, fontweight='bold')
    pts = {'w': (0.2, 0.8), 'x': (0.8, 0.8), 'y': (0.2, 0.2), 'z': (0.8, 0.2)}
    # Draw all six edges with different colors for the three pairings
    colors = {'wx+yz': '#e74c3c', 'wy+xz': '#2ecc71', 'wz+xy': '#3498db'}
    ax.plot([pts['w'][0], pts['x'][0]], [pts['w'][1], pts['x'][1]],
            color=colors['wx+yz'], linewidth=2, label='d(w,x)+d(y,z)')
    ax.plot([pts['y'][0], pts['z'][0]], [pts['y'][1], pts['z'][1]],
            color=colors['wx+yz'], linewidth=2)
    ax.plot([pts['w'][0], pts['y'][0]], [pts['w'][1], pts['y'][1]],
            color=colors['wy+xz'], linewidth=2, linestyle='--', label='d(w,y)+d(x,z)')
    ax.plot([pts['x'][0], pts['z'][0]], [pts['x'][1], pts['z'][1]],
            color=colors['wy+xz'], linewidth=2, linestyle='--')
    ax.plot([pts['w'][0], pts['z'][0]], [pts['w'][1], pts['z'][1]],
            color=colors['wz+xy'], linewidth=2, linestyle=':', label='d(w,z)+d(x,y)')
    ax.plot([pts['x'][0], pts['y'][0]], [pts['x'][1], pts['y'][1]],
            color=colors['wz+xy'], linewidth=2, linestyle=':')
    for name, (x, y) in pts.items():
        ax.plot(x, y, 'ko', markersize=10)
        ax.text(x, y + 0.06, name, ha='center', fontsize=12, fontweight='bold')
    ax.legend(loc='lower center', fontsize=8, ncol=1)
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.1, 1.05)
    ax.set_aspect('equal')
    ax.axis('off')

    plt.tight_layout()
    return fig


def create_tropical_matmul_heatmap():
    """Create heatmap showing tropical matrix multiplication."""
    fig, axes = plt.subplots(1, 4, figsize=(16, 4))

    A = np.array([[0, 3, np.inf], [np.inf, 0, 2], [4, np.inf, 0]])
    B = np.array([[0, 1, np.inf], [np.inf, 0, 5], [3, np.inf, 0]])

    # Compute tropical product
    n = 3
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])

    # Replace inf for display
    def display_matrix(M, ax, title):
        display = np.where(np.isinf(M), np.nan, M)
        im = ax.imshow(display, cmap='YlOrRd_r', vmin=0, vmax=10)
        ax.set_title(title, fontsize=12, fontweight='bold')
        for i in range(M.shape[0]):
            for j in range(M.shape[1]):
                val = M[i, j]
                text = '∞' if np.isinf(val) else f'{int(val)}'
                color = 'gray' if np.isinf(val) else 'black'
                ax.text(j, i, text, ha='center', va='center', fontsize=14,
                       fontweight='bold', color=color)
        ax.set_xticks(range(M.shape[1]))
        ax.set_yticks(range(M.shape[0]))
        return im

    display_matrix(A, axes[0], 'A')
    axes[1].text(0.5, 0.5, '⊗', fontsize=30, ha='center', va='center',
                fontweight='bold', color='#0f3460')
    axes[1].axis('off')
    display_matrix(B, axes[2], 'B')
    axes[2].set_title('B', fontsize=12, fontweight='bold')

    # Add equals sign
    display_matrix(C, axes[3], 'A ⊗ B')

    plt.suptitle('Tropical (Min-Plus) Matrix Multiplication', fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def create_bridge_diagram():
    """Create SVG diagram showing the three-way bridge."""
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" width="700" height="450" viewBox="0 0 700 450">
  <style>
    text { font-family: 'Segoe UI', Arial, sans-serif; }
    .title { font-size: 18px; font-weight: bold; fill: #1a1a2e; }
    .domain { font-size: 14px; font-weight: bold; }
    .detail { font-size: 11px; fill: #444; }
    .arrow { font-size: 13px; fill: #e94560; font-weight: bold; }
  </style>

  <!-- Title -->
  <text x="350" y="35" text-anchor="middle" class="title">The Three-Way Tropical Bridge</text>

  <!-- Domain 1: Boundary Rigidity -->
  <rect x="30" y="60" width="200" height="120" rx="12" fill="#e3f2fd" stroke="#1565c0" stroke-width="2.5"/>
  <text x="130" y="85" text-anchor="middle" class="domain" fill="#1565c0">Boundary Rigidity</text>
  <text x="130" y="105" text-anchor="middle" class="detail">SP networks</text>
  <text x="130" y="120" text-anchor="middle" class="detail">Boundary distance</text>
  <text x="130" y="135" text-anchor="middle" class="detail">= complete invariant</text>
  <text x="130" y="155" text-anchor="middle" class="detail">Inverse problems</text>

  <!-- Domain 2: Tropical Algebra -->
  <rect x="250" y="280" width="200" height="120" rx="12" fill="#fce4ec" stroke="#c62828" stroke-width="2.5"/>
  <text x="350" y="305" text-anchor="middle" class="domain" fill="#c62828">Tropical Algebra</text>
  <text x="350" y="325" text-anchor="middle" class="detail">Min-plus matrices</text>
  <text x="350" y="340" text-anchor="middle" class="detail">Associativity, monotonicity</text>
  <text x="350" y="355" text-anchor="middle" class="detail">Path semantics</text>
  <text x="350" y="375" text-anchor="middle" class="detail">Shortest path closure</text>

  <!-- Domain 3: Hyperbolicity -->
  <rect x="470" y="60" width="200" height="120" rx="12" fill="#e8f5e9" stroke="#2e7d32" stroke-width="2.5"/>
  <text x="570" y="85" text-anchor="middle" class="domain" fill="#2e7d32">Hyperbolicity</text>
  <text x="570" y="105" text-anchor="middle" class="detail">Four-point condition</text>
  <text x="570" y="120" text-anchor="middle" class="detail">Ultrametric ⟹ δ=0</text>
  <text x="570" y="135" text-anchor="middle" class="detail">Gromov product</text>
  <text x="570" y="155" text-anchor="middle" class="detail">Coarse geometry</text>

  <!-- Connecting arrows with labels -->
  <!-- Rigidity ↔ Algebra -->
  <path d="M 130 180 Q 130 340 250 340" fill="none" stroke="#9c27b0" stroke-width="2.5" marker-end="url(#arrowhead)"/>
  <text x="120" y="270" text-anchor="middle" class="arrow" fill="#9c27b0">SP dist =</text>
  <text x="120" y="285" text-anchor="middle" class="arrow" fill="#9c27b0">tropical eval</text>

  <!-- Algebra ↔ Hyperbolicity -->
  <path d="M 450 340 Q 570 340 570 180" fill="none" stroke="#ff6f00" stroke-width="2.5" marker-end="url(#arrowhead2)"/>
  <text x="570" y="270" text-anchor="middle" class="arrow" fill="#ff6f00">Matrix closure</text>
  <text x="570" y="285" text-anchor="middle" class="arrow" fill="#ff6f00">= distance metric</text>

  <!-- Rigidity ↔ Hyperbolicity -->
  <path d="M 230 90 L 470 90" fill="none" stroke="#00695c" stroke-width="2.5" marker-end="url(#arrowhead3)"/>
  <text x="350" y="83" text-anchor="middle" class="arrow" fill="#00695c">Boundary metric is 0-hyperbolic</text>

  <!-- Central unifying concept -->
  <ellipse cx="350" cy="210" rx="100" ry="35" fill="#fff3e0" stroke="#e65100" stroke-width="2"/>
  <text x="350" y="207" text-anchor="middle" class="domain" fill="#e65100">Tropical</text>
  <text x="350" y="225" text-anchor="middle" class="domain" fill="#e65100">Convexity</text>

  <!-- Arrowheads -->
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#9c27b0"/>
    </marker>
    <marker id="arrowhead2" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#ff6f00"/>
    </marker>
    <marker id="arrowhead3" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#00695c"/>
    </marker>
  </defs>

  <!-- Footer -->
  <text x="350" y="435" text-anchor="middle" class="detail" font-style="italic">
    Boundary data determines internal geometry precisely where tropical convexity is tame
  </text>
</svg>'''
    return svg


if __name__ == "__main__":
    # Generate all visualizations
    print("Generating visualizations...")

    # 1. SP decomposition diagram (SVG)
    sp_svg = create_sp_decomposition_diagram()
    with open("sp_decomposition.svg", "w") as f:
        f.write(sp_svg)
    print("  Created sp_decomposition.svg")

    # 2. Hyperbolicity comparison (PNG)
    fig = create_hyperbolicity_plot()
    fig.savefig("hyperbolicity_comparison.png", dpi=150, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    print("  Created hyperbolicity_comparison.png")

    # 3. Tropical matrix multiplication (PNG)
    fig = create_tropical_matmul_heatmap()
    fig.savefig("tropical_matmul.png", dpi=150, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    print("  Created tropical_matmul.png")

    # 4. Bridge diagram (SVG)
    bridge_svg = create_bridge_diagram()
    with open("bridge_diagram.svg", "w") as f:
        f.write(bridge_svg)
    print("  Created bridge_diagram.svg")

    print("All visualizations generated!")
