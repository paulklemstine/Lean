"""
Algorithms for Closure-Extractor-Syndrome Duality

Implements:
1. Forward-chaining closure computation
2. Capacity and increment computation
3. Minimal presentation extraction
4. Syndrome class enumeration
"""

import itertools
from typing import Dict, FrozenSet, List, Optional, Set, Tuple


def forward_chaining_closure(
    rules: List[Tuple[FrozenSet[int], int]],
    seed: Set[int],
    universe: Set[int]
) -> Set[int]:
    """
    Compute cl_R(seed) by iteratively firing applicable rules.

    Time complexity: O(|rules| * |universe|) per iteration,
    at most |universe| iterations => O(|rules| * |universe|^2) total.

    Args:
        rules: List of (premises, conclusion) pairs
        seed: Initial set of known elements
        universe: Ground set

    Returns:
        The closure of seed under the rules
    """
    current = set(seed) & universe
    changed = True
    while changed:
        changed = False
        for premises, conclusion in rules:
            if conclusion in universe and premises <= current and conclusion not in current:
                current.add(conclusion)
                changed = True
    return current


def rule_count(
    rules: List[Tuple[FrozenSet[int], int]],
    A: Set[int]
) -> int:
    """
    Count rules with premises and conclusion in A.

    Time complexity: O(|rules| * max_premise_size)
    """
    return sum(1 for premises, conclusion in rules
               if premises <= A and conclusion in A)


def capacity(
    rules: List[Tuple[FrozenSet[int], int]],
    A: Set[int],
    universe: Set[int]
) -> int:
    """
    Compute cap(A) = ruleCount(cl(A)).

    Time complexity: O(closure computation + rule count)
    """
    cl_A = forward_chaining_closure(rules, A, universe)
    return rule_count(rules, cl_A)


def capacity_increment(
    rules: List[Tuple[FrozenSet[int], int]],
    A: Set[int],
    x: int,
    universe: Set[int]
) -> int:
    """
    Compute Δ_x(A) = cap(A ∪ {x}) - cap(A).

    Time complexity: O(2 * closure computation + 2 * rule count)
    """
    cap_A = capacity(rules, A, universe)
    cap_Ax = capacity(rules, A | {x}, universe)
    return cap_Ax - cap_A


def parity_check_to_rules(
    H: List[List[int]]
) -> List[Tuple[FrozenSet[int], int]]:
    """
    Convert binary parity-check matrix to implication rules.

    Each row with support S generates |S| rules:
    for each x in S, (S \\ {x}) -> x.

    Time complexity: O(m * n) where H is m×n
    """
    rules = []
    for row in H:
        support = frozenset(i for i, v in enumerate(row) if v == 1)
        for x in support:
            premises = support - {x}
            rules.append((premises, x))
    return rules


def enumerate_closed_sets(
    rules: List[Tuple[FrozenSet[int], int]],
    universe: Set[int]
) -> List[Set[int]]:
    """
    Enumerate all closed sets (fixed points of the closure operator).

    Time complexity: O(2^n * closure computation) — exponential in general.

    Returns sorted list of closed sets (by size).
    """
    closed = []
    for r in range(len(universe) + 1):
        for subset in itertools.combinations(universe, r):
            A = set(subset)
            cl_A = forward_chaining_closure(rules, A, universe)
            if cl_A == A:
                closed.append(A)
    return sorted(closed, key=len)


def minimal_presentation(
    rules: List[Tuple[FrozenSet[int], int]],
    universe: Set[int]
) -> List[Tuple[FrozenSet[int], int]]:
    """
    Greedily remove redundant rules to find a minimal presentation.

    A rule is redundant if removing it doesn't change any closure.

    Time complexity: O(|rules|^2 * 2^n * closure computation)
    — expensive but correct.
    """
    # Compute all closures with full rules
    all_subsets = []
    for r in range(len(universe) + 1):
        for subset in itertools.combinations(universe, r):
            all_subsets.append(set(subset))

    original_closures = {}
    for A in all_subsets:
        key = frozenset(A)
        original_closures[key] = frozenset(
            forward_chaining_closure(rules, A, universe))

    # Try removing each rule
    minimal = list(rules)
    for rule in rules:
        candidate = [r for r in minimal if r != rule]
        # Check if all closures are preserved
        preserved = True
        for A in all_subsets:
            key = frozenset(A)
            new_cl = frozenset(
                forward_chaining_closure(candidate, A, universe))
            if new_cl != original_closures[key]:
                preserved = False
                break
        if preserved:
            minimal = candidate

    return minimal


def syndrome_classes(
    H: List[List[int]],
    universe: Set[int]
) -> Dict[Tuple[int, ...], List[Set[int]]]:
    """
    Compute syndrome equivalence classes.

    Time complexity: O(2^n * m * n)
    """
    classes: Dict[Tuple[int, ...], List[Set[int]]] = {}
    n = len(list(universe))
    for r in range(n + 1):
        for subset in itertools.combinations(universe, r):
            A = set(subset)
            s = tuple(
                sum(1 for j in A if row[j] == 1) % 2
                for row in H
            )
            classes.setdefault(s, []).append(A)
    return classes


def check_submodularity(
    rules: List[Tuple[FrozenSet[int], int]],
    universe: Set[int]
) -> Tuple[bool, Optional[Tuple[Set[int], Set[int]]]]:
    """
    Check if cap = ruleCount ∘ cl is submodular.

    Returns (True, None) if submodular, or
    (False, (A, B)) with a counterexample.
    """
    n = len(universe)
    all_subsets = []
    for r in range(n + 1):
        for subset in itertools.combinations(universe, r):
            all_subsets.append(set(subset))

    for A in all_subsets:
        for B in all_subsets:
            cap_A = capacity(rules, A, universe)
            cap_B = capacity(rules, B, universe)
            cap_AB = capacity(rules, A | B, universe)
            cap_AnB = capacity(rules, A & B, universe)

            if cap_AB + cap_AnB > cap_A + cap_B:
                return False, (A, B)

    return True, None


if __name__ == "__main__":
    # Example usage
    universe = {0, 1, 2, 3}
    rules = [
        (frozenset({0, 1}), 2),
        (frozenset({1, 2}), 3),
        (frozenset({0}), 1),
    ]

    print("Closed sets:")
    for cs in enumerate_closed_sets(rules, universe):
        print(f"  {cs}")

    print(f"\nMinimal presentation ({len(rules)} rules → ", end="")
    minimal = minimal_presentation(rules, universe)
    print(f"{len(minimal)} rules)")
    for p, c in minimal:
        print(f"  {set(p)} → {c}")

    print("\nSubmodularity check:")
    is_sub, counter = check_submodularity(rules, universe)
    if is_sub:
        print("  ✓ Submodular")
    else:
        print(f"  ✗ Not submodular (counterexample: A={counter[0]}, B={counter[1]})")
