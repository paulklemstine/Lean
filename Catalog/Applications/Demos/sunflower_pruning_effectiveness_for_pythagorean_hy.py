#!/usr/bin/env python3
"""
Applications of Sunflower Pruning to Arithmetic Hypergraphs

Demonstrates real-world applications of the sunflower pruning theory:
1. Minimum Pythagorean coloring certificates
2. SAT preprocessing via sunflower reduction
3. Kernel size analysis for FPT algorithms
4. Transfer to other arithmetic hypergraphs (sum-free sets, Schur triples)
"""

from algorithms import (
    pythagorean_edges,
    vertex_degree,
    degree_profile,
    max_degree_vertex,
    find_sunflower,
    naive_transversal_search,
    sunflower_transversal_search,
    overlap_analysis,
    pruning_gain,
)


def separator(title: str) -> None:
    print(f"\n{'=' * 70}")
    print(f"  {title}")
    print(f"{'=' * 70}\n")


# ─────────────────────────────────────────────────────────────────────
# Application 1: Minimum Coloring Certificates
# ─────────────────────────────────────────────────────────────────────

def app_coloring_certificates():
    """
    Find minimum-size sets of 'forced' vertices for Pythagorean coloring.

    A transversal of the Pythagorean hypergraph is a set T such that every
    Pythagorean triple contains at least one element of T. This is equivalent
    to: if we remove T from {1,...,n}, no Pythagorean triple remains fully
    intact — which means any 2-coloring restricted to {1,...,n} \ T trivially
    avoids monochromatic triples.
    """
    separator("APPLICATION 1: MINIMUM COLORING CERTIFICATES")
    print("  Finding minimum transversals (hitting sets) of H_n.")
    print("  These are the smallest 'blocker' sets for monochromatic triples.")
    print()

    for n in [25, 50, 75, 100]:
        edges = pythagorean_edges(n)
        if not edges:
            print(f"  n={n:>3}: no triples, trivially colorable")
            continue

        # Find minimum k
        for k in range(1, 30):
            result, calls = sunflower_transversal_search(edges, k)
            if result is not None:
                print(f"  n={n:>3}: min transversal size = {k}, "
                      f"example = {sorted(result)[:10]}{'...' if len(result) > 10 else ''}, "
                      f"search calls = {calls}")
                break
        else:
            print(f"  n={n:>3}: min transversal > 29")


# ─────────────────────────────────────────────────────────────────────
# Application 2: SAT Preprocessing via Sunflower Reduction
# ─────────────────────────────────────────────────────────────────────

def sunflower_reduction(edges: set[frozenset[int]], k: int) -> set[frozenset[int]]:
    """
    Apply sunflower reduction: replace sunflowers with > k petals by their core.
    Repeat until no more reductions possible.

    This preserves the existence of size-k hitting sets (by our verified theorem).
    """
    reduced = set(edges)
    rounds = 0

    while True:
        sf = find_sunflower(reduced, k + 1)
        if sf is None:
            break

        sf_edges, kernel = sf
        for e in sf_edges:
            reduced.discard(e)
        reduced.add(kernel)
        rounds += 1

    return reduced


def app_sat_preprocessing():
    """
    Demonstrate sunflower-based preprocessing as a SAT simplification analog.

    The monotone CNF encoding of "hit every Pythagorean triple" has one clause
    per triple. Sunflower reduction collapses groups of clauses sharing a
    common satisfying structure into a single shorter clause.
    """
    separator("APPLICATION 2: SAT PREPROCESSING VIA SUNFLOWER REDUCTION")
    print("  Modeling hitting set as monotone SAT: each triple → one clause.")
    print("  Sunflower reduction = clause simplification preserving satisfiability.")
    print()

    for n in [50, 100, 200, 500]:
        edges = pythagorean_edges(n)
        original_size = len(edges)

        for k in [3, 5, 8]:
            reduced = sunflower_reduction(edges, k)
            reduced_size = len(reduced)
            ratio = reduced_size / original_size if original_size > 0 else 1.0
            print(f"  n={n:>3}, k={k}: {original_size:>4} edges → {reduced_size:>4} "
                  f"({ratio:.1%} of original)")


# ─────────────────────────────────────────────────────────────────────
# Application 3: FPT Kernel Size Analysis
# ─────────────────────────────────────────────────────────────────────

def app_kernel_analysis():
    """
    Analyze the kernel size after sunflower reduction.

    In FPT theory, the sunflower lemma guarantees that after exhaustive
    reduction, the remaining instance has bounded size (as a function of k only).
    We measure how quickly this bound kicks in for the Pythagorean hypergraph.
    """
    separator("APPLICATION 3: FPT KERNEL SIZE ANALYSIS")
    print("  After exhaustive sunflower reduction with parameter k,")
    print("  how many edges remain? (FPT theory: at most O(k^r · r!) for r-uniform)")
    print()

    for n in [100, 200, 500]:
        edges = pythagorean_edges(n)
        print(f"  n={n}, |E|={len(edges)}:")
        for k in [2, 3, 5, 8, 10]:
            reduced = sunflower_reduction(edges, k)
            # Count vertices in reduced instance
            vertices = set()
            for e in reduced:
                vertices |= e
            bound_3unif = k ** 3 * 6  # k^3 · 3! upper bound from sunflower lemma
            print(f"    k={k:>2}: {len(reduced):>4} edges, "
                  f"{len(vertices):>4} vertices "
                  f"(FPT bound: {bound_3unif})")
        print()


# ─────────────────────────────────────────────────────────────────────
# Application 4: Transfer to Other Arithmetic Hypergraphs
# ─────────────────────────────────────────────────────────────────────

def schur_triples(n: int) -> set[frozenset[int]]:
    """Schur triples: {a, b, c} with a + b = c, a ≤ b < c ≤ n."""
    edges: set[frozenset[int]] = set()
    for a in range(1, n + 1):
        for b in range(a, n + 1):
            c = a + b
            if c <= n:
                edges.add(frozenset({a, b, c}))
    return edges


def app_transfer():
    """
    Test sunflower pruning on Schur triple hypergraphs.

    Schur triples {a, b, a+b} form another arithmetic 3-uniform hypergraph.
    Do sunflower methods work equally well here?
    """
    separator("APPLICATION 4: TRANSFER TO SCHUR TRIPLE HYPERGRAPHS")
    print("  Schur triples: {a, b, c} with a + b = c")
    print("  Testing same sunflower analysis on a different arithmetic family.")
    print()

    for n in [50, 100, 200]:
        edges = schur_triples(n)
        analysis = overlap_analysis(edges, n)
        v = analysis["max_vertex"]
        print(f"  Schur H_{n}: {len(edges)} edges, "
              f"max degree = {analysis['max_degree']} (vertex {v})")

        # Sunflower detection
        sf = find_sunflower(edges, 5)
        if sf:
            _, kernel = sf
            print(f"    Sunflower found: kernel = {set(kernel)}")
        else:
            print(f"    No sunflower with ≥5 petals found")

        # Compare search
        k = 3
        _, naive_calls = naive_transversal_search(edges, k)
        _, sf_calls = sunflower_transversal_search(edges, k)
        gain = pruning_gain(naive_calls, sf_calls)
        print(f"    Search (k={k}): naive={naive_calls}, sf={sf_calls}, gain={gain:.1%}")
        print()


def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║   APPLICATIONS OF SUNFLOWER PRUNING THEORY                 ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    app_coloring_certificates()
    app_sat_preprocessing()
    app_kernel_analysis()
    app_transfer()

    separator("CONCLUSION")
    print("  Sunflower pruning is a versatile tool for arithmetic hypergraphs:")
    print("  • Pythagorean triples: natural overlap from shared legs/hypotenuses")
    print("  • Schur triples: natural overlap from shared addends/sums")
    print("  • SAT preprocessing: sunflower reduction = verified clause collapse")
    print("  • FPT kernelization: bounded residual instance after reduction")
    print()
    print("  The key insight: arithmetic structure creates exploitable regularity")
    print("  in hypergraph overlap patterns.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Sunflower Pruning Effectiveness for Pythagorean Hypergraphs — Interactive Demo

Demonstrates:
1. Construction of the Pythagorean triple hypergraph H_n for various n
2. Structural analysis: degree profiles, overlap patterns, sunflower detection
3. Comparison of naive vs. sunflower-pruned transversal search
4. Verification of the double-counting identity (incidence sum = 3 * |E|)
5. Pruning gain measurements

Usage:
    python demo.py
"""

from algorithms import (
    pythagorean_edges,
    vertex_degree,
    degree_profile,
    max_degree_vertex,
    find_sunflower,
    naive_transversal_search,
    sunflower_transversal_search,
    overlap_analysis,
    pruning_gain,
    recursive_calls_naive,
    recursive_calls_sunflower,
)


def separator(title: str) -> None:
    print(f"\n{'=' * 70}")
    print(f"  {title}")
    print(f"{'=' * 70}\n")


def demo_hypergraph_construction():
    """Demonstrate Pythagorean hypergraph construction and basic properties."""
    separator("1. PYTHAGOREAN HYPERGRAPH CONSTRUCTION")

    for n in [13, 25, 50, 100, 200]:
        edges = pythagorean_edges(n)
        print(f"  H_{n:>3}: {len(edges):>5} edges")
        if n <= 25:
            for e in sorted(sorted(e) for e in edges):
                print(f"    {e}")

    print("\n  Growth rate: edges grow roughly as Θ(n² / log n)")


def demo_double_counting():
    """Verify the incidence double-counting identity: ∑ deg(v) = 3·|E|."""
    separator("2. INCIDENCE DOUBLE-COUNTING IDENTITY")
    print("  Theorem: For any 3-uniform hypergraph H on vertex set V,")
    print("           ∑_{v ∈ V} deg(v) = 3 · |E|")
    print()

    for n in [50, 100, 200]:
        edges = pythagorean_edges(n)
        profile = degree_profile(edges, n)
        incidence_sum = sum(profile.values())
        three_E = 3 * len(edges)
        match = "✓" if incidence_sum == three_E else "✗"
        print(f"  n={n:>3}: ∑ deg(v) = {incidence_sum:>5},  3·|E| = {three_E:>5}  [{match}]")


def demo_large_degree_vertex():
    """Demonstrate the averaging argument: existence of high-degree vertices."""
    separator("3. HIGH-DEGREE VERTEX EXISTENCE (AVERAGING)")
    print("  Theorem: ∃ v ∈ {1,...,n} with deg(v) ≥ 3·|E|/n")
    print()

    for n in [50, 100, 200]:
        edges = pythagorean_edges(n)
        v, d = max_degree_vertex(edges, n)
        avg_bound = 3 * len(edges) / n
        print(f"  n={n:>3}: max deg = {d:>3} (vertex {v:>3}),  "
              f"avg bound = {avg_bound:.1f},  ratio = {d / avg_bound:.2f}x")


def demo_sunflower_detection():
    """Detect sunflowers in the Pythagorean hypergraph."""
    separator("4. SUNFLOWER DETECTION")
    print("  Looking for sunflowers (Δ-systems) with singleton cores...")
    print()

    for n in [50, 100, 200]:
        edges = pythagorean_edges(n)

        for min_petals in [3, 5, 8]:
            sf = find_sunflower(edges, min_petals)
            if sf is not None:
                sf_edges, kernel = sf
                print(f"  n={n:>3}, petals≥{min_petals}: FOUND "
                      f"(kernel={set(kernel)}, {len(sf_edges)} petals)")
                if n <= 100 and min_petals <= 3:
                    for e in sf_edges[:5]:
                        print(f"    edge: {sorted(e)}")
            else:
                print(f"  n={n:>3}, petals≥{min_petals}: not found")


def demo_overlap_analysis():
    """Analyze overlap structure around high-degree vertices."""
    separator("5. OVERLAP STRUCTURE ANALYSIS")

    for n in [50, 100, 200]:
        edges = pythagorean_edges(n)
        analysis = overlap_analysis(edges, n)
        v = analysis["max_vertex"]
        print(f"  n={n}: vertex {v}, degree {analysis['max_degree']}")
        print(f"    Pairwise intersection sizes among incident edges:")
        for sz, count in sorted(analysis["pairwise_intersection_sizes"].items()):
            print(f"      |e₁ ∩ e₂| = {sz}: {count} pairs")
        print()


def demo_transversal_search():
    """Compare naive vs. sunflower-pruned transversal search."""
    separator("6. TRANSVERSAL SEARCH: NAIVE vs. SUNFLOWER-PRUNED")

    results = []

    for n in [25, 50, 100]:
        edges = pythagorean_edges(n)
        # Find a reasonable k by binary search
        k = 1
        while True:
            result, _ = naive_transversal_search(edges, k)
            if result is not None:
                break
            k += 1
            if k > 12:
                break

        if k > 12:
            print(f"  n={n}: minimum transversal too large, skipping")
            continue

        # Run both searches at budget k and k+1 for comparison
        for budget in [k, k + 1]:
            naive_result, naive_calls = naive_transversal_search(edges, budget)
            sf_result, sf_calls = sunflower_transversal_search(edges, budget)
            gain = pruning_gain(naive_calls, sf_calls)
            results.append((n, budget, naive_calls, sf_calls, gain))
            print(f"  n={n:>3}, k={budget}: "
                  f"naive={naive_calls:>8} calls, "
                  f"sunflower={sf_calls:>8} calls, "
                  f"gain={gain:>6.1%}")

    return results


def demo_theoretical_bounds():
    """Show theoretical recursive call bounds."""
    separator("7. THEORETICAL RECURSIVE CALL BOUNDS")
    print("  Naive (r=3): r^k = 3^k")
    print("  Sunflower with singleton core (s=1): s^k = 1^k = 1")
    print("  Sunflower with pair core (s=2): s^k = 2^k")
    print()

    for k in range(1, 11):
        naive = recursive_calls_naive(3, k)
        sf1 = recursive_calls_sunflower(1, k)
        sf2 = recursive_calls_sunflower(2, k)
        print(f"  k={k:>2}: naive=3^k={naive:>8},  "
              f"sf(s=1)=1^k={sf1:>1},  "
              f"sf(s=2)=2^k={sf2:>6},  "
              f"gain(s=1)={1 - sf1 / naive:.1%},  "
              f"gain(s=2)={1 - sf2 / naive:.1%}")


def demo_conjecture_test():
    """Test the 90% pruning conjecture."""
    separator("8. CONJECTURE TEST: 90% PRUNING GAIN")
    print("  Conjecture: For n ≥ 50, sunflower pruning cuts calls by ≥ 90%")
    print("  Test: 10 * sunflower_calls ≤ naive_calls")
    print()

    for n in [25, 50, 100]:
        edges = pythagorean_edges(n)
        # Find minimum transversal size
        k = 1
        while True:
            result, _ = naive_transversal_search(edges, k)
            if result is not None:
                break
            k += 1
            if k > 10:
                break

        if k > 10:
            continue

        budget = k + 2  # Give some slack
        _, naive_calls = naive_transversal_search(edges, budget)
        _, sf_calls = sunflower_transversal_search(edges, budget)
        passes = 10 * sf_calls <= naive_calls
        gain = pruning_gain(naive_calls, sf_calls)
        status = "PASS ✓" if passes else "FAIL ✗"
        print(f"  n={n:>3}: naive={naive_calls:>8}, sf={sf_calls:>8}, "
              f"gain={gain:.1%}, [{status}]")


def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║   SUNFLOWER PRUNING FOR PYTHAGOREAN HYPERGRAPHS — DEMO     ║")
    print("╠══════════════════════════════════════════════════════════════╣")
    print("║  Exploring how ancient number patterns tame modern          ║")
    print("║  combinatorial explosion through sunflower compression.     ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    demo_hypergraph_construction()
    demo_double_counting()
    demo_large_degree_vertex()
    demo_sunflower_detection()
    demo_overlap_analysis()
    demo_transversal_search()
    demo_theoretical_bounds()
    demo_conjecture_test()

    separator("SUMMARY")
    print("  The Pythagorean hypergraph exhibits rich overlap structure:")
    print("  • High-degree vertices exist (by the averaging principle)")
    print("  • Sunflowers with singleton cores appear naturally")
    print("  • Sunflower branching provably dominates naive branching")
    print("  • The arithmetic structure creates forced transversal coordinates")
    print()
    print("  All structural theorems verified in the Lean 4 formalization.")


if __name__ == "__main__":
    main()
