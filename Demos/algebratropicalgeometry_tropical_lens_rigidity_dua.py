#!/usr/bin/env python3
"""
Applications of Tropical Lens Rigidity to Network Tomography,
Phylogenetics, and Metric Learning

Demonstrates real-world applications of the mathematical framework:
1. Network tomography: recovering hidden router topology from end-to-end measurements
2. Phylogenetic inference: reconstructing evolutionary trees from sequence distances
3. Metric learning: verifying if learned distances have tree structure
"""

from fractions import Fraction
from itertools import combinations
import random


# ============================================================================
# Application 1: Network Tomography
# ============================================================================

def network_tomography_demo():
    """Demonstrate network topology recovery from end-to-end latency.
    
    Scenario: A network has hidden internal routers. We can only measure
    round-trip times between edge servers. From these measurements, we
    reconstruct the internal topology using tropical lens rigidity.
    """
    print("=" * 70)
    print("APPLICATION 1: Network Tomography")
    print("=" * 70)
    
    # Hidden star topology: central router connected to 5 edge servers
    # Latencies (ms): edge weights represent one-way delay to central router
    edge_servers = ["NYC", "LON", "TYO", "SYD", "SFO"]
    latencies_ms = {
        "NYC": Fraction(12),
        "LON": Fraction(45),
        "TYO": Fraction(85),
        "SYD": Fraction(120),
        "SFO": Fraction(22),
    }
    
    b = len(edge_servers)
    
    # Measured round-trip times (simulated from star topology)
    print("\n  Measured round-trip latencies between edge servers (ms):")
    print(f"  {'':>6}" + "".join(f"{s:>8}" for s in edge_servers))
    D = [[Fraction(0)] * b for _ in range(b)]
    for i in range(b):
        for j in range(b):
            if i != j:
                D[i][j] = latencies_ms[edge_servers[i]] + latencies_ms[edge_servers[j]]
        row = "".join(f"{float(D[i][j]):>8.0f}" for j in range(b))
        print(f"  {edge_servers[i]:>6}{row}")
    
    # Reconstruct
    print("\n  Reconstruction using j₀=NYC, k₀=LON:")
    j0, k0 = 0, 1
    for i in range(b):
        if i not in (j0, k0):
            w = (D[i][j0] + D[i][k0] - D[j0][k0]) / 2
            true_w = latencies_ms[edge_servers[i]]
            print(f"    {edge_servers[i]}: recovered = {float(w):.0f} ms, "
                  f"true = {float(true_w):.0f} ms {'✓' if w == true_w else '✗'}")
    
    print("\n  → Central router topology successfully recovered!")
    print("    This is exactly what tropical lens rigidity guarantees:")
    print("    boundary measurements uniquely determine internal structure.")


# ============================================================================
# Application 2: Phylogenetic Inference
# ============================================================================

def phylogenetics_demo():
    """Demonstrate evolutionary tree reconstruction from sequence distances.
    
    Scenario: We measure pairwise distances between DNA sequences of
    related species. If evolution is tree-like, the four-point condition
    holds and we can reconstruct the phylogenetic tree.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Phylogenetic Tree Reconstruction")
    print("=" * 70)
    
    # Species and pairwise evolutionary distances (Jukes-Cantor corrected)
    species = ["Human", "Chimp", "Gorilla", "Orangutan", "Gibbon"]
    
    # Tree structure: ((Human, Chimp), (Gorilla, (Orangutan, Gibbon)))
    # Distances computed from tree with approximate branch lengths
    D_tree = [
        # Human  Chimp  Gorilla  Orangutan  Gibbon
        [0,      2,     4,       8,         10],    # Human
        [2,      0,     4,       8,         10],    # Chimp
        [4,      4,     0,       8,         10],    # Gorilla
        [8,      8,     8,       0,          6],    # Orangutan
        [10,     10,    10,      6,          0],    # Gibbon
    ]
    D = [[Fraction(x) for x in row] for row in D_tree]
    b = len(species)
    
    print("\n  Pairwise evolutionary distances (substitutions per 100 sites):")
    print(f"  {'':>12}" + "".join(f"{s:>12}" for s in species))
    for i in range(b):
        row = "".join(f"{D_tree[i][j]:>12}" for j in range(b))
        print(f"  {species[i]:>12}{row}")
    
    # Check four-point condition
    print("\n  Four-point condition check (tree-likeness test):")
    violations = 0
    checks = 0
    for i, j, k, l in combinations(range(b), 4):
        s1 = D[i][j] + D[k][l]
        s2 = D[i][k] + D[j][l]
        s3 = D[i][l] + D[j][k]
        sums = sorted([s1, s2, s3])
        checks += 1
        if sums[2] > sums[1]:
            # Check which formulation fails
            if s1 > max(s2, s3) or s2 > max(s1, s3) or s3 > max(s1, s2):
                violations += 1
    
    # Actually check properly
    violations = 0
    for i in range(b):
        for j in range(b):
            for k in range(b):
                for l in range(b):
                    s1 = D[i][j] + D[k][l]
                    s2 = D[i][k] + D[j][l]
                    s3 = D[i][l] + D[j][k]
                    if s1 > max(s2, s3):
                        violations += 1
    
    print(f"    Checked all quadruples: {violations} violations")
    if violations == 0:
        print("    ✓ Four-point condition satisfied → tree-like evolution!")
    else:
        print("    ✗ Non-tree-like signal detected (possible recombination)")
    
    # Identify closest pair (cherry picking for NJ-like reconstruction)
    min_dist = None
    cherry = None
    for i, j in combinations(range(b), 2):
        if min_dist is None or D[i][j] < min_dist:
            min_dist = D[i][j]
            cherry = (i, j)
    
    print(f"\n  Closest pair (cherry): {species[cherry[0]]} - {species[cherry[1]]} "
          f"(distance = {float(min_dist):.1f})")
    print(f"  → These species shared the most recent common ancestor")
    
    # Demonstrate split identification
    print("\n  Identifying tree splits from distance data:")
    splits_found = []
    for size in range(1, b // 2 + 1):
        for left in combinations(range(b), size):
            left_set = set(left)
            right_set = set(range(b)) - left_set
            if len(right_set) < len(left_set):
                continue
            
            # Check if this is a valid split via isolation index
            is_split = True
            for i in left_set:
                for j in right_set:
                    for k in left_set:
                        for l in right_set:
                            if i != k and j != l:
                                s_ij_kl = D[i][j] + D[k][l]
                                s_ik_jl = D[i][k] + D[j][l]
                                s_il_jk = D[i][l] + D[j][k]
                                # For this split, s_ij_kl should be maximal
                                if s_ik_jl > s_ij_kl or s_il_jk > s_ij_kl:
                                    is_split = False
            
            if is_split and len(left_set) > 0 and len(right_set) > 0:
                left_names = [species[i] for i in sorted(left_set)]
                right_names = [species[i] for i in sorted(right_set)]
                # Only report non-trivial splits
                if len(left_set) >= 2 and len(right_set) >= 2:
                    splits_found.append((left_names, right_names))
                    print(f"    {left_names} | {right_names}")
    
    print(f"\n  → Recovered {len(splits_found)} internal splits")
    print("    These splits uniquely determine the tree topology!")


# ============================================================================
# Application 3: Metric Learning Verification
# ============================================================================

def metric_learning_demo():
    """Verify if a learned distance function has tree structure.
    
    In machine learning, we sometimes learn distance functions from data.
    If the underlying structure is tree-like, tropical rigidity guarantees
    unique reconstruction of the latent tree.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Metric Learning — Tree Structure Verification")
    print("=" * 70)
    
    random.seed(42)
    
    # Scenario: learned embedding distances between 6 data points
    # Case A: Distances from a true tree (noisy)
    print("\n  Case A: Distances from a tree + small noise")
    
    # True tree weights (star)
    true_w = [3.0, 5.0, 2.0, 7.0, 4.0, 6.0]
    b = len(true_w)
    
    # Generate noisy measurements
    noise_level = 0.1
    D_noisy = [[0.0] * b for _ in range(b)]
    for i in range(b):
        for j in range(i + 1, b):
            true_d = true_w[i] + true_w[j]
            noisy_d = true_d + random.gauss(0, noise_level)
            D_noisy[i][j] = noisy_d
            D_noisy[j][i] = noisy_d
    
    # Check four-point deviation
    max_violation = 0.0
    for i in range(b):
        for j in range(b):
            for k in range(b):
                for l in range(b):
                    s1 = D_noisy[i][j] + D_noisy[k][l]
                    s2 = D_noisy[i][k] + D_noisy[j][l]
                    s3 = D_noisy[i][l] + D_noisy[j][k]
                    violation = s1 - max(s2, s3)
                    max_violation = max(max_violation, violation)
    
    print(f"    Max four-point violation: {max_violation:.4f}")
    print(f"    Noise level: {noise_level}")
    print(f"    → {'Approximately tree-like ✓' if max_violation < 1.0 else 'Not tree-like ✗'}")
    
    # Case B: Distances from a non-tree structure (grid)
    print("\n  Case B: Distances from a 2D grid (non-tree)")
    
    # 2x3 grid, L1 distances
    points = [(0, 0), (0, 1), (0, 2), (1, 0), (1, 1), (1, 2)]
    D_grid = [[abs(p1[0] - p2[0]) + abs(p1[1] - p2[1]) 
               for p2 in points] for p1 in points]
    
    max_violation = 0.0
    for i in range(6):
        for j in range(6):
            for k in range(6):
                for l in range(6):
                    s1 = D_grid[i][j] + D_grid[k][l]
                    s2 = D_grid[i][k] + D_grid[j][l]
                    s3 = D_grid[i][l] + D_grid[j][k]
                    violation = s1 - max(s2, s3)
                    max_violation = max(max_violation, violation)
    
    print(f"    Max four-point violation: {max_violation:.4f}")
    print(f"    → {'Approximately tree-like ✓' if max_violation < 0.01 else 'Not tree-like ✗'}")
    print("    Grid structure is fundamentally non-tree → no unique tree realization")
    
    print("\n  Summary:")
    print("    The four-point condition is a diagnostic test for tree-likeness.")
    print("    When satisfied, tropical lens rigidity guarantees that the")
    print("    underlying tree can be uniquely and certifiably reconstructed.")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   Applications of Tropical Lens Rigidity                           ║")
    print("║   Network Tomography · Phylogenetics · Metric Learning             ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    network_tomography_demo()
    phylogenetics_demo()
    metric_learning_demo()
    
    print("\n" + "=" * 70)
    print("All application demos completed!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Lens Rigidity Duality -- Interactive Demonstration

Demonstrates the main theorems:
1. Star tree weight recovery from boundary distances
2. Four-point condition verification
3. Split system distance computation
4. Certified reconstruction pipeline

Usage:
    python demo.py
"""

from itertools import combinations, permutations
from fractions import Fraction


def star_dist(weights, i, j):
    """Distance in a star tree: d(i,j) = w_i + w_j for i!=j, 0 for i=j."""
    if i == j:
        return Fraction(0)
    return weights[i] + weights[j]


def star_distance_matrix(weights):
    """Full distance matrix of a star tree."""
    b = len(weights)
    return [[star_dist(weights, i, j) for j in range(b)] for i in range(b)]


def recover_star_weights(D, j0=0, k0=1):
    """Recover star tree weights: w_i = (d(i,j0) + d(i,k0) - d(j0,k0)) / 2.
    Exact for i not in {j0, k0}."""
    b = len(D)
    return [(D[i][j0] + D[i][k0] - D[j0][k0]) / 2 for i in range(b)]


def full_star_recovery(D):
    """Recover all star tree weights using multiple reference pairs."""
    b = len(D)
    weights = [None] * b
    # Use (0,1) for i >= 2
    rec01 = recover_star_weights(D, 0, 1)
    for i in range(2, b):
        weights[i] = rec01[i]
    # Use (2,3) for i in {0,1} (needs b >= 4, else use (0,2)/(1,2))
    if b >= 4:
        rec23 = recover_star_weights(D, 2, 3)
        weights[0] = rec23[0]
        weights[1] = rec23[1]
    elif b == 3:
        rec12 = recover_star_weights(D, 1, 2)
        weights[0] = rec12[0]
        rec02 = recover_star_weights(D, 0, 2)
        weights[1] = rec02[1]
    elif b == 2:
        weights[0] = D[0][1] / 2
        weights[1] = D[0][1] / 2
    return weights


def check_four_point(D):
    """Verify the four-point condition for a distance matrix."""
    b = len(D)
    violations = []
    for i in range(b):
        for j in range(b):
            for k in range(b):
                for l in range(b):
                    s1 = D[i][j] + D[k][l]
                    s2 = D[i][k] + D[j][l]
                    s3 = D[i][l] + D[j][k]
                    if s1 > max(s2, s3):
                        violations.append((i, j, k, l, s1, s2, s3))
    return violations


class WeightedSplit:
    """A weighted bipartition of boundary vertices."""
    def __init__(self, side, weight):
        assert weight > 0
        assert any(side) and any(not s for s in side)
        self.side = side
        self.weight = Fraction(weight)

    def separates(self, i, j):
        return self.side[i] != self.side[j]

    def dist_contrib(self, i, j):
        return self.weight if self.separates(i, j) else Fraction(0)

    def __repr__(self):
        left = [i for i, s in enumerate(self.side) if s]
        right = [i for i, s in enumerate(self.side) if not s]
        return f"Split({left}|{right}, w={float(self.weight):.2f})"


def split_system_distance(splits, b):
    """Compute the distance matrix from a split system."""
    D = [[Fraction(0)] * b for _ in range(b)]
    for i in range(b):
        for j in range(b):
            for s in splits:
                D[i][j] += s.dist_contrib(i, j)
    return D


def splits_compatible(s1, s2):
    """Check if two splits are compatible."""
    b = len(s1.side)
    tt = any(s1.side[i] and s2.side[i] for i in range(b))
    tf = any(s1.side[i] and not s2.side[i] for i in range(b))
    ft = any(not s1.side[i] and s2.side[i] for i in range(b))
    ff = any(not s1.side[i] and not s2.side[i] for i in range(b))
    return not (tt and tf and ft and ff)


def print_matrix(D, label="Distance Matrix"):
    b = len(D)
    print(f"\n{label}:")
    print("     " + "  ".join(f"{j:>6}" for j in range(b)))
    for i in range(b):
        row = "  ".join(f"{float(D[i][j]):>6.2f}" for j in range(b))
        print(f"  {i}: {row}")


# ============================================================
def demo_star_tree():
    print("=" * 70)
    print("DEMO 1: Star Tree Weight Recovery")
    print("=" * 70)

    weights = [Fraction(3), Fraction(5), Fraction(2), Fraction(7), Fraction(4)]
    b = len(weights)
    print(f"\nOriginal star tree with {b} boundary leaves:")
    print(f"  Edge weights: {[float(w) for w in weights]}")

    D = star_distance_matrix(weights)
    print_matrix(D, "Boundary Distance Matrix d(i,j) = w_i + w_j")

    violations = check_four_point(D)
    print(f"\n  Four-point condition violations: {len(violations)}")
    assert len(violations) == 0

    # Weight recovery (exact for i not in {j0, k0})
    print("\n  Weight recovery formula: w(i) = (d(i,j0) + d(i,k0) - d(j0,k0)) / 2")
    print("  (Exact for i not in {j0, k0})\n")
    for j0, k0 in [(0, 1), (1, 2), (2, 3)]:
        rec = recover_star_weights(D, j0, k0)
        print(f"  Reference j0={j0}, k0={k0}:")
        for i in range(b):
            if i != j0 and i != k0:
                ok = rec[i] == weights[i]
                print(f"    w[{i}] = {float(rec[i]):.1f} "
                      f"(true: {float(weights[i]):.1f}) "
                      f"{'OK' if ok else 'FAIL'}")
        assert all(rec[i] == weights[i] for i in range(b) if i != j0 and i != k0)

    # Full recovery
    full = full_star_recovery(D)
    print("\n  Full certified reconstruction:")
    for i in range(b):
        ok = full[i] == weights[i]
        print(f"    w[{i}] = {float(full[i]):.1f} "
              f"(true: {float(weights[i]):.1f}) {'OK' if ok else 'FAIL'}")
    assert all(full[i] == weights[i] for i in range(b))
    print("  All weights recovered exactly!")


def demo_four_point():
    print("\n" + "=" * 70)
    print("DEMO 2: Four-Point Condition -- Tree vs Non-Tree Metrics")
    print("=" * 70)

    D_tree = [
        [Fraction(0), Fraction(3), Fraction(5), Fraction(10)],
        [Fraction(3), Fraction(0), Fraction(2), Fraction(7)],
        [Fraction(5), Fraction(2), Fraction(0), Fraction(5)],
        [Fraction(10), Fraction(7), Fraction(5), Fraction(0)],
    ]
    print("\nPath tree metric (0--3--1--2--2--5--3):")
    print_matrix(D_tree, "Tree Distance Matrix")
    violations = check_four_point(D_tree)
    print(f"  Four-point violations: {len(violations)}")

    print("\n  Checking all distinct quadruples:")
    for i, j, k, l in combinations(range(4), 4):
        s1 = D_tree[i][j] + D_tree[k][l]
        s2 = D_tree[i][k] + D_tree[j][l]
        s3 = D_tree[i][l] + D_tree[j][k]
        sums = sorted([s1, s2, s3])
        ok = sums[2] == sums[1]
        print(f"    ({i},{j},{k},{l}): sums={[float(s) for s in [s1,s2,s3]]}, "
              f"two largest equal? {ok}")

    D_cycle = [
        [Fraction(0), Fraction(1), Fraction(2), Fraction(1)],
        [Fraction(1), Fraction(0), Fraction(1), Fraction(2)],
        [Fraction(2), Fraction(1), Fraction(0), Fraction(1)],
        [Fraction(1), Fraction(2), Fraction(1), Fraction(0)],
    ]
    print("\nCycle metric (4-cycle):")
    print_matrix(D_cycle, "Cycle Distance Matrix")
    violations = check_four_point(D_cycle)
    print(f"  Four-point violations: {len(violations)}")
    if violations:
        v = violations[0]
        print(f"  Example violation: ({v[0]},{v[1]},{v[2]},{v[3]})")


def demo_split_system():
    print("\n" + "=" * 70)
    print("DEMO 3: Compatible Split Systems and Tree Metrics")
    print("=" * 70)

    b = 5
    s1 = WeightedSplit([True, True, False, False, False], 2)
    s2 = WeightedSplit([True, True, True, False, False], 3)
    s3 = WeightedSplit([True, False, False, False, False], 1)
    splits = [s1, s2, s3]

    print(f"\nSplit system with {len(splits)} splits on {b} boundary vertices:")
    for s in splits:
        print(f"  {s}")

    print("\nPairwise compatibility:")
    for i, j in combinations(range(len(splits)), 2):
        compat = splits_compatible(splits[i], splits[j])
        print(f"  {splits[i]} <-> {splits[j]}: "
              f"{'compatible' if compat else 'INCOMPATIBLE'}")

    D = split_system_distance(splits, b)
    print_matrix(D, "Split System Distance Matrix")

    violations = check_four_point(D)
    print(f"\n  Four-point violations: {len(violations)}")

    print("\n  Triangle inequality check:")
    tri_ok = True
    for i in range(b):
        for j in range(b):
            for k in range(b):
                if D[i][k] > D[i][j] + D[j][k]:
                    tri_ok = False
    print(f"    {'All satisfied' if tri_ok else 'VIOLATIONS FOUND'}")


def demo_rigidity():
    print("\n" + "=" * 70)
    print("DEMO 4: Tropical Lens Rigidity Duality")
    print("=" * 70)

    w1 = [Fraction(3), Fraction(5), Fraction(7)]
    w2 = [Fraction(7), Fraction(3), Fraction(5)]
    sigma = [2, 0, 1]

    print("\nStar tree T1: weights =", [float(w) for w in w1])
    print("Star tree T2: weights =", [float(w) for w in w2])
    print(f"Permutation sigma: {sigma}")
    print(f"  w1[i] = w2[sigma(i)]? "
          f"{all(w1[i] == w2[sigma[i]] for i in range(3))}")

    D1 = star_distance_matrix(w1)
    D2 = star_distance_matrix(w2)
    print_matrix(D1, "Distance matrix of T1")
    print_matrix(D2, "Distance matrix of T2")

    iso_ok = all(D1[i][j] == D2[sigma[i]][sigma[j]]
                 for i in range(3) for j in range(3))
    print(f"\n  Geodesic isomorphism d1(i,j)=d2(sigma(i),sigma(j))? {iso_ok}")

    # Non-isomorphic case
    print("\n--- Non-isomorphic star trees ---")
    w3 = [Fraction(3), Fraction(5), Fraction(7)]
    w4 = [Fraction(3), Fraction(5), Fraction(8)]
    D3 = star_distance_matrix(w3)
    D4 = star_distance_matrix(w4)
    print(f"  T3 weights: {[float(w) for w in w3]}")
    print(f"  T4 weights: {[float(w) for w in w4]}")

    found_iso = any(
        all(D3[i][j] == D4[p[i]][p[j]] for i in range(3) for j in range(3))
        for p in permutations(range(3))
    )
    found_perm = any(
        all(w3[i] == w4[p[i]] for i in range(3))
        for p in permutations(range(3))
    )
    print(f"  Geodesic isomorphism exists? {found_iso}")
    print(f"  Weight-preserving permutation exists? {found_perm}")
    print("  Rigidity confirmed: no iso <=> no weight perm")


def demo_reconstruction_pipeline():
    print("\n" + "=" * 70)
    print("DEMO 5: Certified Reconstruction Pipeline")
    print("=" * 70)

    secret_weights = [Fraction(11, 3), Fraction(7, 2), Fraction(13, 4),
                      Fraction(9, 5), Fraction(17, 6)]
    D = star_distance_matrix(secret_weights)
    b = len(D)

    print("\nGiven: boundary distance matrix (unknown tree)")
    print_matrix(D)

    print("\nStep 1: Verify four-point condition...")
    violations = check_four_point(D)
    print(f"  Violations: {len(violations)} -> "
          f"{'tree metric!' if not violations else 'NOT a tree metric'}")

    print("\nStep 2: Reconstruct weights...")
    recovered = full_star_recovery(D)
    for i in range(b):
        correct = recovered[i] == secret_weights[i]
        print(f"  w[{i}] = {float(recovered[i]):.6f} "
              f"(true: {float(secret_weights[i]):.6f}) "
              f"{'OK' if correct else 'FAIL'}")

    print("\nStep 3: Verify reconstruction...")
    D_rec = star_distance_matrix(recovered)
    match = all(D[i][j] == D_rec[i][j] for i in range(b) for j in range(b))
    print(f"  Reconstructed distance matrix matches: {match}")
    print("  Certified reconstruction complete!")


if __name__ == "__main__":
    print("=" * 70)
    print("  Tropical Lens Rigidity Duality -- Demonstration Suite")
    print("  Idempotent Geodesic Semimodules & Metric-Tree Reconstruction")
    print("=" * 70)

    demo_star_tree()
    demo_four_point()
    demo_split_system()
    demo_rigidity()
    demo_reconstruction_pipeline()

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully!")
    print("=" * 70)
