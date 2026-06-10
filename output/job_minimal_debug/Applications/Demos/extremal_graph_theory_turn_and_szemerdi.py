#!/usr/bin/env python3
"""
Extremal Graph Theory: Real-World Applications

This module demonstrates practical applications of extremal graph theory
concepts in network analysis, coding theory, and algorithm design.
"""

from algorithms import (
    SimpleGraph, turan_graph, triangle_count, degree_energy,
    greedy_triangle_removal, edge_edit_distance, lower_shadow,
    turan_edge_count
)
from itertools import combinations
import random
import math


def application_network_density_certification():
    """
    Application 1: Network Density Certification

    Given a social network, certify whether it could be free of
    tightly-knit groups (cliques) of a given size. Turán's theorem
    provides the density threshold: if the network has more edges
    than the Turán number, it MUST contain a clique.

    This is useful for:
    - Fraud detection (dense subgroups indicate collusion)
    - Community detection (clique density as a signal)
    - Network health monitoring
    """
    print("=" * 70)
    print("APPLICATION 1: Network Density Certification")
    print("=" * 70)
    print()
    print("Scenario: A compliance team monitors a financial transaction network.")
    print("They want to know if groups of k traders could be colluding")
    print("(forming complete subgraphs). Turán's theorem gives a threshold:")
    print("if #edges > ex(n, K_k), collusion groups MUST exist.")
    print()

    for n in [10, 20, 50, 100]:
        for k in [3, 4, 5]:
            threshold = turan_edge_count(n, k - 1)
            max_possible = n * (n - 1) // 2
            density_threshold = threshold / max_possible if max_possible > 0 else 0
            print(f"  n={n:3d} traders, K_{k} threshold: {threshold:6d} edges "
                  f"({density_threshold:.4f} density)")
        print()


def application_error_correcting_codes():
    """
    Application 2: Bounds on Error-Correcting Codes

    The Turán problem for hypergraphs directly connects to bounds
    on the size of error-correcting codes. For binary codes of
    length n and minimum distance d, the codewords can be viewed
    as vertices of a graph where edges connect pairs at distance < d.

    The Turán bound gives limits on how many codewords can exist
    without certain proximity patterns.
    """
    print("=" * 70)
    print("APPLICATION 2: Code Design via Extremal Bounds")
    print("=" * 70)
    print()
    print("Binary codes of length n with minimum distance d:")
    print("Codewords form a graph where edges = pairs within distance d.")
    print("Turán-type bounds limit code size given forbidden substructures.")
    print()

    for n_code in [6, 8, 10, 12]:
        print(f"Code length {n_code}:")
        for d in range(2, min(n_code, 5)):
            # Rough bound using Turán-type reasoning
            # Number of possible codewords
            total = 2 ** n_code
            # Turán bound for K_3-free (no three mutually close codewords)
            turan_bound = turan_edge_count(total, 2)
            singleton_bound = math.comb(n_code, d - 1)
            hamming_bound = 2 ** n_code // sum(math.comb(n_code, i) for i in range(d // 2 + 1))
            print(f"  d={d}: Hamming bound = {hamming_bound}, "
                  f"Singleton bound = {singleton_bound}")
        print()


def application_property_testing():
    """
    Application 3: Graph Property Testing

    The triangle removal lemma enables property testing:
    to check if a graph is ε-far from triangle-free,
    sample random triples and check for triangles.

    Our greedy removal certificate gives an explicit bound
    on how many edges to remove.
    """
    print("=" * 70)
    print("APPLICATION 3: Property Testing via Triangle Removal")
    print("=" * 70)
    print()
    print("Question: Is graph G 'close' to triangle-free?")
    print("Answer: Greedy removal tells us the edit distance.")
    print()

    for n in [8, 10, 12, 15]:
        # Generate graphs with varying triangle density
        for p_edge in [0.3, 0.5, 0.7]:
            G = SimpleGraph(n)
            for i in range(n):
                for j in range(i + 1, n):
                    if random.random() < p_edge:
                        G.add_edge(i, j)

            tc = triangle_count(G)
            edges = G.edge_count()
            H, removed = greedy_triangle_removal(G)
            max_edges = n * (n - 1) // 2

            print(f"  n={n:2d}, p={p_edge}: |E|={edges:3d}/{max_edges:3d}, "
                  f"triangles={tc:4d}, removed={removed:2d}, "
                  f"ε = {removed/max_edges:.4f}" if max_edges > 0 else "")
    print()


def application_community_structure():
    """
    Application 4: Community Detection via Degree Energy

    The degree energy E(G) = Σ deg(v)² measures how unevenly
    edges are distributed. Graphs with community structure
    (dense subgraphs) have higher degree energy than random graphs
    of the same density.

    This provides a simple community detection statistic.
    """
    print("=" * 70)
    print("APPLICATION 4: Community Detection via Degree Energy")
    print("=" * 70)
    print()

    n = 20
    print(f"Comparing degree energy for n={n} vertex graphs:")
    print()

    # Random graph
    random_energies = []
    for _ in range(50):
        G = SimpleGraph(n)
        for i in range(n):
            for j in range(i + 1, n):
                if random.random() < 0.3:
                    G.add_edge(i, j)
        random_energies.append(degree_energy(G))
    avg_random = sum(random_energies) / len(random_energies)

    # Graph with two communities
    community_energies = []
    for _ in range(50):
        G = SimpleGraph(n)
        # Community 1: vertices 0-9 (dense)
        for i in range(10):
            for j in range(i + 1, 10):
                if random.random() < 0.7:
                    G.add_edge(i, j)
        # Community 2: vertices 10-19 (dense)
        for i in range(10, 20):
            for j in range(i + 1, 20):
                if random.random() < 0.7:
                    G.add_edge(i, j)
        # Between communities (sparse)
        for i in range(10):
            for j in range(10, 20):
                if random.random() < 0.05:
                    G.add_edge(i, j)
        community_energies.append(degree_energy(G))
    avg_community = sum(community_energies) / len(community_energies)

    # Turán graph (balanced)
    G_turan = turan_graph(n, 2)
    turan_en = degree_energy(G_turan)

    print(f"  Random G(n, 0.3):     avg energy = {avg_random:.0f}")
    print(f"  Two communities:      avg energy = {avg_community:.0f}")
    print(f"  Turán T(n, 2):        energy = {turan_en}")
    print()
    print("  Higher energy indicates more uneven degree distribution,")
    print("  which correlates with community structure.")
    print()


def application_additive_combinatorics():
    """
    Application 5: Arithmetic Progression Detection

    Using the graph-theoretic encoding, detecting 3-APs in a set
    reduces to finding triangles in an auxiliary graph. This means
    extremal graph bounds (like the removal lemma) translate to
    bounds on AP-free set sizes (Roth's theorem).
    """
    print("=" * 70)
    print("APPLICATION 5: Arithmetic Progressions via Graph Theory")
    print("=" * 70)
    print()
    print("Roth's theorem: Any subset of {1,...,N} with no 3-term AP")
    print("has size o(N). The graph-theoretic proof uses triangle removal.")
    print()
    print("Largest 3-AP-free subsets of Z/NZ found by greedy search:")
    print()

    for N in [9, 15, 21, 27, 33, 45, 63]:
        best_size = 0
        best_set = set()
        for trial in range(200):
            A = set()
            order = list(range(N))
            random.shuffle(order)
            for x in order:
                A.add(x)
                # Check if any 3-AP was created
                has_ap = False
                for a in A:
                    for b in A:
                        if a != b and a != x and b != x:
                            if (a + x) % N == (2 * b) % N:
                                has_ap = True
                                break
                            if (b + x) % N == (2 * a) % N:
                                has_ap = True
                                break
                            if (a + b) % N == (2 * x) % N:
                                has_ap = True
                                break
                    if has_ap:
                        break
                if has_ap:
                    A.remove(x)
            if len(A) > best_size:
                best_size = len(A)
                best_set = A.copy()

        density = best_size / N
        roth_bound = 1 / math.log(max(N, 2))
        print(f"  N={N:3d}: max |A|={best_size:2d}, "
              f"density={density:.4f}, "
              f"1/log(N)={roth_bound:.4f}")

    print()


def main():
    random.seed(42)
    application_network_density_certification()
    application_error_correcting_codes()
    application_property_testing()
    application_community_structure()
    application_additive_combinatorics()

    print("=" * 70)
    print("ALL APPLICATIONS DEMONSTRATED")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Extremal Graph Theory: Demonstrations and Computational Experiments

This script demonstrates the key theorems and algorithms from our
extremal graph theory framework:

1. Turán graph construction and edge counting
2. Mantel's theorem verification
3. Degree energy and Cauchy-Schwarz bounds
4. Greedy triangle removal with certificates
5. 3-AP ↔ triangle correspondence
6. Shadow computation and Kruskal-Katona exploration
7. Empirical conjecture testing
"""

from algorithms import (
    SimpleGraph, turan_graph, turan_edge_count, triangle_count,
    degree_energy, edge_edit_distance, greedy_triangle_removal,
    three_ap_count, build_three_ap_graph, verify_mantel_bound,
    lower_shadow, compression_operator
)
from itertools import combinations
import random
import math


def demo_turan_graphs():
    """Demonstrate Turán graph construction and verify edge counts."""
    print("=" * 70)
    print("DEMO 1: Turán Graph Construction and Edge Counts")
    print("=" * 70)
    print()
    print("The Turán graph T(n, p) is the densest K_{p+1}-free graph on n vertices.")
    print("It is the complete p-partite graph with balanced part sizes.")
    print()

    for p in range(2, 6):
        print(f"--- T(n, {p}): K_{p+1}-free graphs ---")
        for n in range(p, 16):
            G = turan_graph(n, p)
            actual = G.edge_count()
            formula = turan_edge_count(n, p)
            ratio = actual / (n * n / 2) if n > 0 else 0
            asymptotic = 1 - 1/p

            # Verify no (p+1)-clique
            has_clique = False
            if n <= 12:
                for clique in combinations(range(n), p + 1):
                    if all(G.has_edge(a, b) for a, b in combinations(clique, 2)):
                        has_clique = True
                        break

            print(f"  n={n:2d}: edges={actual:3d}, formula={formula:3d}, "
                  f"density={ratio:.4f} (asymp {asymptotic:.4f})"
                  + (f", K_{p+1}-free: {not has_clique}" if n <= 12 else ""))
        print()


def demo_mantel_theorem():
    """Verify Mantel's theorem: triangle-free graphs have ≤ n²/4 edges."""
    print("=" * 70)
    print("DEMO 2: Mantel's Theorem — Triangle-Free Edge Bound")
    print("=" * 70)
    print()
    print("Mantel's theorem (1907): Every triangle-free graph on n vertices")
    print("has at most ⌊n²/4⌋ edges. The Turán graph T(n,2) achieves this bound.")
    print()

    for n in range(2, 13):
        result = verify_mantel_bound(n)
        print(f"n={n:2d}: T(n,2) edges = {result['turan_edges']:3d}, "
              f"bound n²/4 = {result['mantel_bound']:3d}, "
              f"4|E| = {4*result['turan_edges']:3d} ≤ n² = {n*n:3d}: "
              f"{'✓' if result['satisfies_bound'] else '✗'}")

    print()
    print("Testing random triangle-free graphs for n=10:")
    n = 10
    max_edges = 0
    for trial in range(100):
        G = SimpleGraph(n)
        edges = list(combinations(range(n), 2))
        random.shuffle(edges)
        for u, v in edges:
            G.add_edge(u, v)
            if triangle_count(G) > 0:
                G.remove_edge(u, v)
        max_edges = max(max_edges, G.edge_count())
    print(f"  Max edges found in 100 random triangle-free graphs: {max_edges}")
    print(f"  Mantel bound: {n*n//4}")
    print(f"  T(10,2) achieves: {turan_edge_count(10, 2)}")
    print()


def demo_degree_energy():
    """Demonstrate degree energy and Cauchy-Schwarz bounds."""
    print("=" * 70)
    print("DEMO 3: Degree Energy and Cauchy-Schwarz")
    print("=" * 70)
    print()
    print("Degree energy: E(G) = Σ deg(v)². By Cauchy-Schwarz:")
    print("  n · E(G) ≥ (Σ deg(v))² = (2|E|)²")
    print()
    print("For triangle-free graphs, E(G) ≤ n · |E| (our Theorem 8).")
    print()

    for n in range(3, 11):
        G = turan_graph(n, 2)
        E = G.edge_count()
        deg_en = degree_energy(G)
        cs_bound = (2 * E) ** 2  # Cauchy-Schwarz lower bound: n * E(G) >= this
        tf_bound = n * E  # Triangle-free upper bound: E(G) <= this

        print(f"n={n:2d}: |E|={E:2d}, E(G)={deg_en:4d}, "
              f"CS: n·E(G)={n*deg_en:5d} ≥ (2|E|)²={cs_bound:5d} {'✓' if n*deg_en >= cs_bound else '✗'}, "
              f"TF: E(G)={deg_en:4d} ≤ n·|E|={tf_bound:4d} {'✓' if deg_en <= tf_bound else '✗'}")
    print()


def demo_greedy_removal():
    """Demonstrate greedy triangle removal algorithm."""
    print("=" * 70)
    print("DEMO 4: Greedy Triangle Removal — Certified Algorithm")
    print("=" * 70)
    print()
    print("Given graph G, greedily remove one edge per triangle.")
    print("Result H satisfies: triangle_count(H) = 0 and")
    print("  edge_edit_distance(G, H) ≤ triangle_count(G).")
    print()

    # Complete graphs
    for n in range(3, 9):
        G = SimpleGraph(n, set(combinations(range(n), 2)))
        tc = triangle_count(G)
        H, removed = greedy_triangle_removal(G)
        tc_H = triangle_count(H)
        edit_dist = G.edge_count() - H.edge_count()

        print(f"K_{n}: |E|={G.edge_count():3d}, triangles={tc:4d}, "
              f"removed={removed:3d}, edit_dist={edit_dist:3d} ≤ {tc:4d}: "
              f"{'✓' if edit_dist <= tc else '✗'}, "
              f"triangle-free: {'✓' if tc_H == 0 else '✗'}")

    print()
    print("Random dense graphs G(n, 0.5):")
    for n in [6, 8, 10, 12]:
        ratios = []
        for _ in range(20):
            G = SimpleGraph(n)
            for i in range(n):
                for j in range(i + 1, n):
                    if random.random() < 0.5:
                        G.add_edge(i, j)
            tc = triangle_count(G)
            if tc > 0:
                H, removed = greedy_triangle_removal(G)
                optimal_est = tc / 3  # rough lower bound on optimal
                ratio = removed / max(optimal_est, 1)
                ratios.append(ratio)
        if ratios:
            avg_ratio = sum(ratios) / len(ratios)
            print(f"  n={n:2d}: avg removal/estimate ratio = {avg_ratio:.3f}")
    print()


def demo_three_ap_bridge():
    """Demonstrate the 3-AP ↔ triangle correspondence."""
    print("=" * 70)
    print("DEMO 5: 3-AP ↔ Triangle Bridge — Additive Combinatorics")
    print("=" * 70)
    print()
    print("Three-term arithmetic progressions in Z/NZ can be encoded")
    print("as triangles in a tripartite graph. This bridges extremal")
    print("graph theory and additive combinatorics (Roth's theorem).")
    print()

    for N in [7, 9, 11, 13]:
        # Full set
        A_full = set(range(N))
        ap_full = three_ap_count(N, A_full)
        print(f"N={N:2d}, A=Z/{N}Z: {ap_full} ordered 3-APs")

        # Random subsets
        for density in [0.3, 0.5, 0.7]:
            aps = []
            for _ in range(50):
                A = {x for x in range(N) if random.random() < density}
                if len(A) >= 3:
                    aps.append(three_ap_count(N, A))
            if aps:
                avg_ap = sum(aps) / len(aps)
                print(f"  density={density}: avg 3-APs = {avg_ap:.1f}")
    print()

    # Specific Roth-type example
    print("Roth-type density threshold exploration:")
    for N in [9, 15, 21, 27]:
        # Find largest 3-AP-free set by greedy
        best_size = 0
        for _ in range(100):
            A = set()
            order = list(range(N))
            random.shuffle(order)
            for x in order:
                A.add(x)
                if three_ap_count(N, A) > 0:
                    A.remove(x)
            best_size = max(best_size, len(A))
        print(f"  N={N:2d}: largest 3-AP-free set found = {best_size}, "
              f"density = {best_size/N:.3f}, "
              f"1/log(N) = {1/math.log(N):.3f}")
    print()


def demo_shadows():
    """Demonstrate shadow computation and Kruskal-Katona bounds."""
    print("=" * 70)
    print("DEMO 6: Lower Shadows — Kruskal-Katona Infrastructure")
    print("=" * 70)
    print()
    print("The lower shadow of a k-uniform family F is the set of all")
    print("(k-1)-element sets obtained by deleting one element from a member of F.")
    print()

    # All k-subsets of [n]
    for n in range(4, 8):
        for k in range(2, min(n, 5)):
            full_family = [frozenset(s) for s in combinations(range(n), k)]
            shadow = lower_shadow(full_family)
            expected_shadow = len(list(combinations(range(n), k - 1)))
            print(f"  [n={n}, k={k}]: |F| = {len(full_family):3d}, "
                  f"|∂F| = {len(shadow):3d}, "
                  f"C(n,k-1) = {expected_shadow:3d}")

    print()
    print("Shadow sizes for random uniform families on [8]:")
    n = 8
    k = 3
    for m in [5, 10, 15, 20, 30, 40, 56]:
        all_sets = [frozenset(s) for s in combinations(range(n), k)]
        if m > len(all_sets):
            continue
        # Try multiple random families
        shadow_sizes = []
        for _ in range(50):
            family = random.sample(all_sets, m)
            shadow = lower_shadow(family)
            shadow_sizes.append(len(shadow))
        avg_shadow = sum(shadow_sizes) / len(shadow_sizes)
        min_shadow = min(shadow_sizes)
        print(f"  m={m:2d}: avg |∂F|={avg_shadow:.1f}, min |∂F|={min_shadow}")
    print()


def demo_conjecture_testing():
    """Test conjectures from FUTURE_DIRECTIONS.md."""
    print("=" * 70)
    print("DEMO 7: Conjecture Testing")
    print("=" * 70)
    print()

    # Conjecture 1: Greedy removal ratio on G(n, 1/2)
    print("Conjecture 1: Greedy removal achieves ratio < 1.2 of optimal")
    print("(approximated by triangle_count/3 lower bound)")
    for n in [6, 8, 10, 12]:
        ratios = []
        for _ in range(50):
            G = SimpleGraph(n)
            for i in range(n):
                for j in range(i + 1, n):
                    if random.random() < 0.5:
                        G.add_edge(i, j)
            tc = triangle_count(G)
            if tc > 0:
                H, removed = greedy_triangle_removal(G)
                # Lower bound on optimal: each edge removal kills at most n-2 triangles
                optimal_lb = math.ceil(tc / (n - 2))
                if optimal_lb > 0:
                    ratios.append(removed / optimal_lb)
        if ratios:
            max_ratio = max(ratios)
            avg_ratio = sum(ratios) / len(ratios)
            print(f"  n={n:2d}: avg ratio = {avg_ratio:.3f}, max ratio = {max_ratio:.3f}")

    print()

    # Conjecture 2: Degree energy descent recovers balanced partition
    print("Conjecture 2: Degree energy minimizers among K_r-free graphs")
    print("are close to Turán graphs")
    for n in [8, 10, 12]:
        G_turan = turan_graph(n, 3)
        turan_energy = degree_energy(G_turan)
        turan_edges = G_turan.edge_count()

        # Generate random K_4-free graphs with same edge count
        energies = []
        for _ in range(100):
            G = SimpleGraph(n)
            edges = list(combinations(range(n), 2))
            random.shuffle(edges)
            for u, v in edges:
                G.add_edge(u, v)
                # Check K_4-freeness
                has_k4 = False
                for clique in combinations(range(n), 4):
                    if all(G.has_edge(a, b) for a, b in combinations(clique, 2)):
                        has_k4 = True
                        break
                if has_k4:
                    G.remove_edge(u, v)
            if G.edge_count() >= turan_edges - 2:
                energies.append(degree_energy(G))

        if energies:
            min_en = min(energies)
            print(f"  n={n:2d}: Turán energy = {turan_energy}, "
                  f"min random K4-free energy = {min_en}, "
                  f"Turán achieves min: {turan_energy <= min_en}")

    print()


def main():
    random.seed(42)
    demo_turan_graphs()
    demo_mantel_theorem()
    demo_degree_energy()
    demo_greedy_removal()
    demo_three_ap_bridge()
    demo_shadows()
    demo_conjecture_testing()

    print("=" * 70)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    main()
