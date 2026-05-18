"""
Frankl's Union-Closed Conjecture — Algorithms

Implements key algorithms for working with union-closed families:
1. Union closure computation
2. Frankl witness search
3. Maximal member identification
4. Dual family construction
5. Average-size criterion check
"""

from itertools import combinations
from typing import Optional


# Type aliases
Family = set[frozenset[int]]


def union_closure(generators: Family) -> Family:
    """
    Compute the union-closure of a family of sets.

    Given a set of generators, repeatedly close under pairwise union
    until no new sets are produced.

    Time complexity: O(|F|² · n) per iteration, at most O(2^n) iterations
    where n = |ground set|, |F| = final family size.
    Space complexity: O(|F| · n).

    Args:
        generators: Initial family of finite sets.

    Returns:
        The smallest union-closed family containing all generators.

    Example:
        >>> union_closure({frozenset({1}), frozenset({2})})
        {frozenset({1}), frozenset({2}), frozenset({1, 2})}
    """
    closed = set(generators)
    changed = True
    while changed:
        changed = False
        new_sets: set[frozenset[int]] = set()
        members = list(closed)
        for i in range(len(members)):
            for j in range(i, len(members)):
                union = members[i] | members[j]
                if union not in closed:
                    new_sets.add(union)
                    changed = True
        closed |= new_sets
    return closed


def ground_set(F: Family) -> frozenset[int]:
    """
    Compute the ground set (union of all members) of a family.

    Time complexity: O(|F| · n).

    Args:
        F: A family of finite sets.

    Returns:
        The union of all members.

    Example:
        >>> ground_set({frozenset({1, 2}), frozenset({2, 3})})
        frozenset({1, 2, 3})
    """
    result: set[int] = set()
    for A in F:
        result |= A
    return frozenset(result)


def element_frequency(x: int, F: Family) -> int:
    """
    Count the number of members of F containing element x.

    Time complexity: O(|F|).

    Args:
        x: Element to count.
        F: Family of finite sets.

    Returns:
        Number of sets in F containing x.

    Example:
        >>> element_frequency(1, {frozenset({1}), frozenset({2}), frozenset({1, 2})})
        2
    """
    return sum(1 for A in F if x in A)


def frequency_vector(F: Family) -> dict[int, int]:
    """
    Compute the frequency of every element in the ground set.

    Time complexity: O(|F| · n).

    Args:
        F: A family of finite sets.

    Returns:
        Dictionary mapping each element to its frequency.

    Example:
        >>> frequency_vector({frozenset({1, 2}), frozenset({2, 3})})
        {1: 1, 2: 2, 3: 1}
    """
    G = ground_set(F)
    return {x: element_frequency(x, F) for x in sorted(G)}


def find_frankl_witness(F: Family) -> Optional[int]:
    """
    Find an element appearing in at least half the members of F.

    Implements the direct search strategy: compute all frequencies
    and return the most frequent element if it meets the threshold.

    Time complexity: O(|F| · n).

    Args:
        F: A family of finite sets.

    Returns:
        An element x such that 2·freq(x) ≥ |F|, or None if no such
        element exists (which would be a Frankl counterexample!).

    Example:
        >>> find_frankl_witness({frozenset({1}), frozenset({1, 2})})
        1
    """
    G = ground_set(F)
    if not G:
        return None

    best_x = None
    best_freq = -1
    for x in G:
        freq = element_frequency(x, F)
        if freq > best_freq:
            best_freq = freq
            best_x = x

    if best_x is not None and 2 * best_freq >= len(F):
        return best_x
    return None


def maximal_members(F: Family) -> Family:
    """
    Find all inclusion-maximal members of a family.

    Time complexity: O(|F|² · n).

    Args:
        F: A family of finite sets.

    Returns:
        The set of all maximal members.

    Example:
        >>> maximal_members({frozenset({1}), frozenset({1, 2}), frozenset({3})})
        {frozenset({1, 2}), frozenset({3})}
    """
    maximals: Family = set()
    for A in F:
        if not any(A < B for B in F):
            maximals.add(A)
    return maximals


def dual_family(U: frozenset[int], F: Family) -> Family:
    """
    Compute the complement-dual of F relative to ground set U.

    Time complexity: O(|F| · n).

    Args:
        U: The ground set.
        F: A family of finite sets, all subsets of U.

    Returns:
        {U \\ A : A ∈ F}.

    Example:
        >>> dual_family(frozenset({1,2,3}), {frozenset({1}), frozenset({1,2})})
        {frozenset({2, 3}), frozenset({3})}
    """
    return {U - A for A in F}


def is_union_closed(F: Family) -> bool:
    """
    Check if a family is closed under pairwise union.

    Time complexity: O(|F|² · n).

    Args:
        F: A family of finite sets.

    Returns:
        True if F is union-closed.

    Example:
        >>> is_union_closed({frozenset({1}), frozenset({2}), frozenset({1, 2})})
        True
    """
    for A in F:
        for B in F:
            if A | B not in F:
                return False
    return True


def is_intersection_closed(F: Family) -> bool:
    """
    Check if a family is closed under pairwise intersection.

    Time complexity: O(|F|² · n).
    """
    for A in F:
        for B in F:
            if A & B not in F:
                return False
    return True


def check_average_size_criterion(F: Family) -> dict:
    """
    Check whether the average-size criterion (Theorem A) applies.

    Returns a dictionary with:
    - 'average_size': average |A| over A ∈ F
    - 'half_ground': |ground(F)| / 2
    - 'criterion_holds': whether average ≥ half_ground
    - 'witness': the Frankl witness (if criterion holds)

    Time complexity: O(|F| · n).
    """
    if not F:
        return {'average_size': 0, 'half_ground': 0,
                'criterion_holds': False, 'witness': None}

    G = ground_set(F)
    avg = sum(len(A) for A in F) / len(F)
    half_g = len(G) / 2

    result = {
        'average_size': avg,
        'half_ground': half_g,
        'criterion_holds': avg >= half_g,
        'sum_sizes': sum(len(A) for A in F),
        'card_times_ground': len(F) * len(G),
    }

    if result['criterion_holds']:
        result['witness'] = find_frankl_witness(F)
    else:
        result['witness'] = None

    return result


def enumerate_uc_families(n: int, max_generators: int = 4) -> list[Family]:
    """
    Enumerate union-closed families on ground set {1, ..., n} by
    generating all union-closures of small subsets of 2^[n].

    Args:
        n: Size of the ground set.
        max_generators: Maximum number of generators.

    Returns:
        List of distinct union-closed families.
    """
    elements = list(range(1, n + 1))
    all_subsets: list[frozenset[int]] = []
    for k in range(n + 1):
        for combo in combinations(elements, k):
            all_subsets.append(frozenset(combo))

    seen: set[frozenset[frozenset[int]]] = set()
    families: list[Family] = []

    for gen_size in range(1, min(max_generators + 1, len(all_subsets) + 1)):
        for gen_combo in combinations(all_subsets, gen_size):
            if not any(len(A) > 0 for A in gen_combo):
                continue
            F = union_closure(set(gen_combo))
            key = frozenset(F)
            if key not in seen:
                seen.add(key)
                families.append(F)

    return families


def verify_frankl_exhaustive(n: int) -> dict:
    """
    Exhaustively verify Frankl's conjecture for all union-closed
    families on {1, ..., n}.

    Returns verification statistics.
    """
    families = enumerate_uc_families(n)
    total = len(families)
    verified = 0
    counterexamples: list[Family] = []
    tightest_ratio = 1.0
    tightest_family = None

    for F in families:
        G = ground_set(F)
        if not G:
            continue

        best_freq = max(element_frequency(x, F) for x in G)
        ratio = best_freq / len(F)

        if 2 * best_freq >= len(F):
            verified += 1
        else:
            counterexamples.append(F)

        if ratio < tightest_ratio:
            tightest_ratio = ratio
            tightest_family = F

    return {
        'n': n,
        'total_families': total,
        'verified': verified,
        'counterexamples': len(counterexamples),
        'tightest_ratio': tightest_ratio,
        'tightest_family': tightest_family,
    }


# ─── Example usage ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Union Closure Example ===")
    gens: Family = {frozenset({1}), frozenset({2}), frozenset({3})}
    F = union_closure(gens)
    print(f"Generators: {[sorted(g) for g in gens]}")
    print(f"Union-closure: {sorted([sorted(A) for A in F])}")
    print(f"Is UC: {is_union_closed(F)}")
    print(f"Ground set: {sorted(ground_set(F))}")
    print(f"Frequencies: {frequency_vector(F)}")
    print(f"Frankl witness: {find_frankl_witness(F)}")
    print(f"Maximal members: {[sorted(M) for M in maximal_members(F)]}")
    print()

    print("=== Average-Size Criterion ===")
    result = check_average_size_criterion(F)
    for k, v in result.items():
        print(f"  {k}: {v}")
    print()

    print("=== Duality ===")
    G = ground_set(F)
    F_dual = dual_family(G, F)
    print(f"F is UC: {is_union_closed(F)}")
    print(f"F* is IC: {is_intersection_closed(F_dual)}")
    print()

    print("=== Exhaustive Verification ===")
    for n in range(1, 5):
        stats = verify_frankl_exhaustive(n)
        print(f"n={n}: {stats['total_families']} families, "
              f"{stats['verified']} verified, "
              f"{stats['counterexamples']} counterexamples, "
              f"tightest ratio={stats['tightest_ratio']:.4f}")
