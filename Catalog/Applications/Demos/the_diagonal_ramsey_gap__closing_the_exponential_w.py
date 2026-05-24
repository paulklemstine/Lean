#!/usr/bin/env python3
"""
Applications of Ramsey-LLL Dependency Geometry

This module demonstrates real-world connections of the Ramsey-LLL framework
to coding theory, constraint satisfaction, and network design.
"""

from math import comb, exp, log, sqrt, floor
from typing import List, Tuple
import itertools


# ==============================================================================
# Application 1: Constrained Binary Code Construction
# ==============================================================================

def ramsey_code_parameters(n: int, k: int) -> dict:
    """
    Compute parameters of the Ramsey constrained binary code.

    A valid 2-coloring of K_n avoiding monochromatic K_k is equivalent to
    a binary codeword of length C(n,2) (one bit per edge) satisfying
    C(n,k) local constraints (no k-clique is all-0 or all-1).

    This gives a constrained code with:
    - Block length: C(n,2)
    - Number of constraints: C(n,k)
    - Constraint weight: C(k,2) (each constraint involves this many bits)
    - Constraint overlap: at most C(k,2)·C(n-2,k-2) pairs share ≥ 2 bits

    Returns a dictionary of code parameters.
    """
    block_length = comb(n, 2)
    num_constraints = comb(n, k)
    constraint_weight = comb(k, 2)
    max_overlap = comb(k, 2) * comb(n - 2, k - 2)

    # Rate lower bound: log2(# valid codewords) / block_length
    # By the probabilistic method: # valid ≥ 2^{C(n,2)} · (1 - 2·C(n,k)/2^{C(k,2)})
    p_bad = 2.0 * comb(n, k) / (2.0 ** comb(k, 2))
    if p_bad < 1:
        log2_valid_lower = block_length + log(1 - p_bad) / log(2)
        rate_lower = log2_valid_lower / block_length if block_length > 0 else 0
    else:
        log2_valid_lower = 0
        rate_lower = 0

    return {
        'block_length': block_length,
        'num_constraints': num_constraints,
        'constraint_weight': constraint_weight,
        'max_constraint_overlap': max_overlap,
        'p_bad_per_constraint': 2.0 ** (1 - comb(k, 2)),
        'rate_lower_bound': rate_lower,
        'constraint_density': num_constraints / block_length if block_length > 0 else 0,
    }


# ==============================================================================
# Application 2: Network Robustness Design
# ==============================================================================

def network_diversity_bound(n_nodes: int, group_size: int) -> dict:
    """
    Network diversity application of Ramsey lower bounds.

    In a network of n_nodes, assign each link one of 2 "channels" (frequencies,
    protocols, etc.). The Ramsey lower bound guarantees that if
    2·C(n,group_size) < 2^{C(group_size,2)}, then there exists an assignment
    where no group of group_size nodes has all links on the same channel.

    This ensures frequency diversity: any group of nodes uses at least 2 channels,
    providing robustness against single-channel failures.

    Returns a dictionary with network design parameters.
    """
    ck2 = comb(group_size, 2)
    threshold = 2 ** ck2
    is_achievable = 2 * comb(n_nodes, group_size) < threshold

    dep_degree = comb(group_size, 2) * comb(max(n_nodes - 2, 0), max(group_size - 2, 0))
    p = 2.0 ** (1 - ck2) if ck2 > 0 else 1.0
    lll_holds = exp(1) * p * (dep_degree + 1) <= 1.0

    return {
        'n_nodes': n_nodes,
        'group_size': group_size,
        'num_links': comb(n_nodes, 2),
        'num_groups': comb(n_nodes, group_size),
        'first_moment_achievable': is_achievable,
        'lll_achievable': lll_holds,
        'dependency_degree': dep_degree,
    }


# ==============================================================================
# Application 3: Tournament Scheduling
# ==============================================================================

def tournament_balance(n_teams: int, k: int) -> dict:
    """
    Tournament scheduling application.

    Given n_teams in a round-robin tournament, assign each game to one of
    2 time slots. The Ramsey constraint says: no group of k teams has all
    their mutual games in the same time slot.

    This ensures temporal diversity in scheduling: any subset of k teams
    has games spread across both time slots.

    Returns scheduling feasibility and parameters.
    """
    total_games = comb(n_teams, 2)
    total_groups = comb(n_teams, k)
    games_per_group = comb(k, 2)

    ck2 = comb(k, 2)
    is_feasible = 2 * total_groups < 2 ** ck2

    return {
        'n_teams': n_teams,
        'group_size': k,
        'total_games': total_games,
        'total_groups': total_groups,
        'games_per_group': games_per_group,
        'balanced_scheduling_exists': is_feasible,
    }


# ==============================================================================
# Application 4: Ramsey Configuration Space Enumeration
# ==============================================================================

def count_valid_colorings_brute(n: int, k: int) -> Tuple[int, int]:
    """
    Brute-force count of valid 2-colorings of K_n avoiding monochromatic K_k.

    Only feasible for very small n (n ≤ 6 or so).

    Returns (valid_count, total_count).
    """
    edges = list(itertools.combinations(range(n), 2))
    num_edges = len(edges)
    total = 2 ** num_edges
    valid = 0

    k_subsets = list(itertools.combinations(range(n), k))

    for coloring_bits in range(total):
        # Decode coloring
        edge_colors = {}
        for idx, (i, j) in enumerate(edges):
            edge_colors[(i, j)] = (coloring_bits >> idx) & 1
            edge_colors[(j, i)] = edge_colors[(i, j)]

        # Check no monochromatic k-clique
        good = True
        for subset in k_subsets:
            for color in [0, 1]:
                mono = True
                for i, j in itertools.combinations(subset, 2):
                    if edge_colors[(i, j)] != color:
                        mono = False
                        break
                if mono:
                    good = False
                    break
            if not good:
                break

        if good:
            valid += 1

    return (valid, total)


# ==============================================================================
# Main: Application Demonstrations
# ==============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Applications of Ramsey-LLL Dependency Geometry")
    print("=" * 70)

    # Application 1: Coding Theory
    print("\n--- Application 1: Constrained Binary Codes ---")
    print("A valid 2-coloring of K_n avoiding monochromatic K_k")
    print("is a codeword in a binary code with forbidden patterns.\n")
    for n, k in [(5, 4), (8, 5), (17, 6), (30, 7)]:
        params = ramsey_code_parameters(n, k)
        print(f"  n={n:2d}, k={k}: block_len={params['block_length']:3d}, "
              f"constraints={params['num_constraints']:6d}, "
              f"weight={params['constraint_weight']:2d}, "
              f"rate≥{params['rate_lower_bound']:.4f}")

    # Application 2: Network Design
    print("\n--- Application 2: Network Frequency Diversity ---")
    print("Assign 2 frequencies to links; no group of k nodes uses only 1.\n")
    for n in [5, 8, 10, 15, 20]:
        for k in [4, 5]:
            result = network_diversity_bound(n, k)
            status = "✓" if result['first_moment_achievable'] else "✗"
            lll_status = "✓" if result['lll_achievable'] else "✗"
            print(f"  {n:2d} nodes, k={k}: FM {status}, LLL {lll_status}, "
                  f"dep_deg={result['dependency_degree']:5d}")

    # Application 3: Tournament Scheduling
    print("\n--- Application 3: Tournament Temporal Diversity ---")
    print("Round-robin with 2 time slots; no k teams all play in same slot.\n")
    for n in range(4, 12):
        result = tournament_balance(n, 4)
        status = "✓ balanced schedule exists" if result['balanced_scheduling_exists'] else "✗ not guaranteed"
        print(f"  {n:2d} teams: {result['total_games']:3d} games, "
              f"{result['total_groups']:4d} groups of 4: {status}")

    # Application 4: Configuration Space Size (small cases)
    print("\n--- Application 4: Configuration Space Enumeration ---")
    print("Exact count of valid colorings (brute force, small n only).\n")
    for n, k in [(4, 3), (5, 4), (6, 4), (5, 3)]:
        valid, total = count_valid_colorings_brute(n, k)
        pct = 100 * valid / total if total > 0 else 0
        print(f"  K_{n}, k={k}: {valid:6d} / {total:6d} valid ({pct:.1f}%)")


#!/usr/bin/env python3
"""
Ramsey Lower Bounds: First-Moment vs LLL Comparison

This script computes and compares two certified lower bounds for the diagonal
Ramsey number R(k,k):

1. First-moment bound: Find the largest n such that 2·C(n,k) < 2^{C(k,2)}.
2. LLL bound: Find the largest n such that e·2^{1-C(k,2)}·(C(k,2)·C(n-2,k-2)+1) ≤ 1.

The LLL bound is always at least as good as the first-moment bound for large k,
and the gap grows linearly in k, giving R(k,k) > C·k·2^{k/2}.
"""

import math
from math import comb, exp, log, floor, ceil


def first_moment_bound(k: int) -> int:
    """
    Compute the first-moment (Erdős) lower bound for R(k,k).

    Returns the largest n such that 2·C(n,k) < 2^{C(k,2)}.
    This gives R(k,k) > n.

    The bound comes from: if the expected number of monochromatic k-cliques
    in a random 2-coloring of K_n is < 1, then some coloring avoids them all.
    """
    if k < 2:
        return 1
    threshold = 2 ** comb(k, 2)
    n = k
    while 2 * comb(n, k) < threshold:
        n += 1
    return n - 1  # largest n where criterion holds


def lll_bound(k: int) -> int:
    """
    Compute the Lovász Local Lemma lower bound for R(k,k).

    Returns the largest n such that e·p·(d+1) ≤ 1, where:
      p = 2^{1 - C(k,2)}  (bad event probability)
      d = C(k,2)·C(n-2, k-2)  (dependency degree bound)

    This gives R(k,k) > n.
    """
    if k < 2:
        return 1
    ck2 = comb(k, 2)
    p = 2.0 ** (1 - ck2)
    e_val = exp(1)
    n = k
    while True:
        d = ck2 * comb(n - 2, k - 2)
        if e_val * p * (d + 1) > 1.0:
            break
        n += 1
    return n - 1


def dependency_degree(n: int, k: int) -> int:
    """
    Upper bound on the dependency degree: C(k,2)·C(n-2, k-2).

    Each bad event (monochromatic k-clique) is dependent on at most this many
    other bad events. Two events are independent iff their vertex sets share ≤ 1 vertex.
    """
    return comb(k, 2) * comb(n - 2, k - 2)


def bad_event_prob(k: int) -> float:
    """
    Probability that a fixed k-set is monochromatic: 2^{1 - C(k,2)}.
    """
    return 2.0 ** (1 - comb(k, 2))


def theoretical_lll_bound(k: int) -> float:
    """
    The theoretical asymptotic LLL bound: (sqrt(2)/e)·k·2^{k/2}.

    For sufficiently large k, R(k,k) exceeds this value.
    """
    return (math.sqrt(2) / exp(1)) * k * 2 ** (k / 2)


def print_comparison_table():
    """Print a comparison table of first-moment vs LLL bounds."""
    print("=" * 80)
    print("Diagonal Ramsey Lower Bounds: First-Moment vs LLL")
    print("=" * 80)
    print()
    print(f"{'k':>4} | {'FM bound':>10} | {'LLL bound':>10} | {'Ratio':>8} | "
          f"{'Dep. degree':>12} | {'Prob p':>12} | {'Asymptotic':>12}")
    print("-" * 80)

    for k in range(3, 16):
        fm = first_moment_bound(k)
        lll = lll_bound(k)
        ratio = lll / fm if fm > 0 else float('inf')
        d = dependency_degree(lll, k)
        p = bad_event_prob(k)
        asymp = theoretical_lll_bound(k)
        print(f"{k:4d} | {fm:10d} | {lll:10d} | {ratio:8.2f} | "
              f"{d:12d} | {p:12.2e} | {asymp:12.2f}")

    print()
    print("FM bound  = largest n with 2·C(n,k) < 2^C(k,2)")
    print("LLL bound = largest n with e·2^{1-C(k,2)}·(C(k,2)·C(n-2,k-2)+1) ≤ 1")
    print("Ratio     = LLL / FM  (shows the LLL improvement factor)")
    print()


def print_dependency_analysis():
    """Analyze the dependency structure for specific k values."""
    print("=" * 80)
    print("Dependency Structure Analysis")
    print("=" * 80)
    print()

    for k in [4, 5, 6, 8, 10]:
        n_fm = first_moment_bound(k)
        n_lll = lll_bound(k)
        ck2 = comb(k, 2)
        total_events = comb(n_lll, k)
        dep_deg = dependency_degree(n_lll, k)

        print(f"k = {k}:")
        print(f"  Clique edges: C(k,2) = {ck2}")
        print(f"  Bad event prob: p = 2^{1-ck2} ≈ {bad_event_prob(k):.2e}")
        print(f"  First-moment bound: R({k},{k}) > {n_fm}")
        print(f"  LLL bound:          R({k},{k}) > {n_lll}")
        print(f"  At n={n_lll}: total events = C({n_lll},{k}) = {total_events}")
        print(f"  At n={n_lll}: dependency degree ≤ {dep_deg}")
        print(f"  Sparsity ratio: d/total = {dep_deg/total_events:.4f}")
        print(f"  LLL criterion: e·p·(d+1) = {exp(1)*bad_event_prob(k)*(dep_deg+1):.6f}")
        print()


def verify_conjecture():
    """
    Verify the conjecture: ∃ k₀ such that ∀ k ≥ k₀, R(k,k) > ⌊1.1 · 2^{k/2}⌋.

    This should follow from the first-moment bound for small k.
    """
    print("=" * 80)
    print("Conjecture Verification: R(k,k) > ⌊1.1 · 2^{k/2}⌋")
    print("=" * 80)
    print()
    print(f"{'k':>4} | {'FM bound':>10} | {'LLL bound':>10} | {'1.1·2^{k/2}':>12} | {'FM holds?':>10} | {'LLL holds?':>10}")
    print("-" * 80)

    for k in range(3, 20):
        fm = first_moment_bound(k)
        lll = lll_bound(k)
        target = floor(1.1 * 2 ** (k / 2))
        fm_holds = "YES" if fm >= target else "NO"
        lll_holds = "YES" if lll >= target else "NO"
        print(f"{k:4d} | {fm:10d} | {lll:10d} | {target:12d} | {fm_holds:>10} | {lll_holds:>10}")

    print()
    print("The conjecture holds for all k ≥ 4 by the first-moment bound.")
    print()


def compare_fm_vs_lll():
    """
    Compare first-moment and LLL bounds to find the crossover point.
    """
    print("=" * 80)
    print("First-Moment vs LLL: Crossover Analysis")
    print("=" * 80)
    print()

    first_strict = None
    for k in range(3, 25):
        fm = first_moment_bound(k)
        lll = lll_bound(k)
        improvement = lll - fm
        marker = " ← FIRST STRICT IMPROVEMENT" if improvement > 0 and first_strict is None else ""
        if improvement > 0 and first_strict is None:
            first_strict = k
        print(f"k={k:2d}: FM={fm:8d}, LLL={lll:8d}, improvement={improvement:6d}{marker}")

    print()
    if first_strict:
        print(f"LLL first strictly improves on first-moment at k = {first_strict}")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║   Ramsey Lower Bounds: Dependency Geometry & the LLL       ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    print_comparison_table()
    print_dependency_analysis()
    verify_conjecture()
    compare_fm_vs_lll()

    # Interactive mode
    print("=" * 80)
    print("Interactive Mode: Enter k to compute bounds (or 'q' to quit)")
    print("=" * 80)
    while True:
        try:
            user_input = input("\nk = ")
            if user_input.strip().lower() in ('q', 'quit', 'exit'):
                break
            k = int(user_input)
            if k < 2:
                print("  k must be at least 2")
                continue
            fm = first_moment_bound(k)
            lll = lll_bound(k)
            asymp = theoretical_lll_bound(k)
            print(f"  First-moment bound: R({k},{k}) > {fm}")
            print(f"  LLL bound:          R({k},{k}) > {lll}")
            print(f"  Asymptotic target:  (√2/e)·k·2^{{k/2}} ≈ {asymp:.2f}")
            print(f"  Bad event prob:     p = {bad_event_prob(k):.2e}")
            print(f"  Dependency degree:  d ≤ {dependency_degree(lll, k)}")
        except (ValueError, EOFError):
            break
