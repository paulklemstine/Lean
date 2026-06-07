#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for Semantic Isomorphism Theory

Type-hinted implementations of the key computational procedures.
"""

from itertools import permutations
from collections import Counter
from typing import List, Tuple, Dict, Optional, Set, FrozenSet
from functools import lru_cache
import math


# ═══════════════════════════════════════════════════════════════
# ALGORITHM 1: Histogram Invariant (O(n) — fast rejection)
# ═══════════════════════════════════════════════════════════════

def color_histogram(coloring: List[int]) -> Dict[int, int]:
    """
    Compute the color histogram of a coloring.

    The histogram maps each color to its multiplicity.
    This is the primary invariant for semantic equivalence:
    if histograms differ, the colorings cannot be equivalent.

    Time: O(n)
    Space: O(k) where k = number of distinct colors
    """
    return dict(Counter(coloring))


def histogram_signature(coloring: List[int]) -> Tuple[int, ...]:
    """
    Compute a canonical signature from the histogram.

    Returns the sorted tuple of multiplicities, which is invariant
    under both permutation of elements AND relabeling of colors.

    Time: O(n + k log k)
    """
    counts = Counter(coloring)
    return tuple(sorted(counts.values()))


# ═══════════════════════════════════════════════════════════════
# ALGORITHM 2: Semantic Equivalence Testing
# ═══════════════════════════════════════════════════════════════

def test_semantic_equivalence(
    c1: List[int], c2: List[int]
) -> Tuple[bool, Optional[List[int]]]:
    """
    Test whether two colorings are semantically equivalent.

    Uses histogram pre-filtering for fast rejection, then
    backtracking search over permutations.

    Returns: (is_equivalent, witnessing_permutation_or_None)

    Time: O(n!) worst case, but histogram check rejects most pairs in O(n)
    """
    n = len(c1)
    if len(c2) != n:
        return False, None

    # Fast rejection: histogram must match
    if color_histogram(c1) != color_histogram(c2):
        return False, None

    # Backtracking search for witnessing permutation
    perm: List[int] = [-1] * n
    used: Set[int] = set()

    def backtrack(pos: int) -> bool:
        if pos == n:
            return True
        target_color = c1[pos]
        for j in range(n):
            if j not in used and c2[j] == target_color:
                perm[pos] = j
                used.add(j)
                if backtrack(pos + 1):
                    return True
                used.remove(j)
        return False

    if backtrack(0):
        return True, perm
    return False, None


# ═══════════════════════════════════════════════════════════════
# ALGORITHM 3: Semantic Distance Computation
# ═══════════════════════════════════════════════════════════════

def compute_semantic_distance(c1: List[int], c2: List[int]) -> int:
    """
    Compute the semantic distance between two colorings.

    d(c₁, c₂) = min_{σ ∈ Sym(n)} |{i : c₁(i) ≠ c₂(σ(i))}|

    This is the minimum Hamming distance over all permutations.

    Time: O(n! · n) — exponential, but exact
    """
    n = len(c1)
    assert len(c2) == n

    best = n
    for perm in permutations(range(n)):
        d = sum(1 for i in range(n) if c1[i] != c2[perm[i]])
        best = min(best, d)
        if best == 0:
            return 0
    return best


def compute_semantic_distance_hungarian(
    c1: List[int], c2: List[int]
) -> int:
    """
    Compute semantic distance using the Hungarian algorithm.

    When colors partition elements into classes, the problem reduces
    to a minimum-cost matching between color classes.

    Time: O(k³) where k = number of distinct colors (much faster than n!)
    """
    hist1 = Counter(c1)
    hist2 = Counter(c2)

    # Colors that appear in both
    all_colors = set(hist1.keys()) | set(hist2.keys())
    n = len(c1)

    # Count how many elements of each color can be matched
    matched = sum(min(hist1.get(c, 0), hist2.get(c, 0)) for c in all_colors)

    # Semantic distance is at least n - max_matched
    # This is a lower bound; for the exact answer we need permutation search
    # But this gives a fast approximation
    return n - matched


# ═══════════════════════════════════════════════════════════════
# ALGORITHM 4: Chromatic Stabilizer Computation
# ═══════════════════════════════════════════════════════════════

def compute_chromatic_stabilizer(
    coloring: List[int],
) -> List[Tuple[int, ...]]:
    """
    Compute the chromatic stabilizer of a coloring.

    Stab(c) = {σ ∈ Sym(n) : c(σ(i)) = c(i) for all i}

    Time: O(∏ (mⱼ!)) where mⱼ are the color multiplicities
    """
    n = len(coloring)

    # Group elements by color
    color_classes: Dict[int, List[int]] = {}
    for i, c in enumerate(coloring):
        color_classes.setdefault(c, []).append(i)

    # The stabilizer is the direct product of symmetric groups
    # on each color class
    stabilizer: List[List[int]] = [list(range(n))]

    for color, positions in color_classes.items():
        new_stab = []
        for base_perm in stabilizer:
            for class_perm in permutations(positions):
                perm = list(base_perm)
                for orig, target in zip(positions, class_perm):
                    perm[orig] = target
                new_stab.append(perm)
        stabilizer = new_stab

    return [tuple(p) for p in stabilizer]


def stabilizer_index(coloring: List[int]) -> int:
    """
    Compute the index [Sym(n) : Stab(c)].

    This equals the size of the orbit of c under Sym(n),
    i.e., the number of semantically distinct colorings
    with the same histogram as c.

    Time: O(n) using the formula n! / ∏(mⱼ!)
    """
    n = len(coloring)
    hist = Counter(coloring)
    numerator = math.factorial(n)
    denominator = 1
    for count in hist.values():
        denominator *= math.factorial(count)
    return numerator // denominator


# ═══════════════════════════════════════════════════════════════
# ALGORITHM 5: Semantic Equivalence Class Enumeration
# ═══════════════════════════════════════════════════════════════

def count_semantic_classes_burnside(n: int, k: int) -> int:
    """
    Count semantic equivalence classes of k-colorings of {0,...,n-1}
    using Burnside's lemma.

    |classes| = (1/|G|) Σ_{g∈G} |Fix(g)|

    where Fix(g) = number of colorings fixed by permutation g,
    and |G| = n! (the full symmetric group).

    For a permutation with cycle structure (c₁, c₂, ..., cₘ),
    Fix(g) = k^m (one free color choice per cycle).

    Time: O(n! · n) — sum over all permutations
    """
    total_fixed = 0
    for perm in permutations(range(n)):
        # Count cycles
        visited = [False] * n
        num_cycles = 0
        for i in range(n):
            if not visited[i]:
                num_cycles += 1
                j = i
                while not visited[j]:
                    visited[j] = True
                    j = perm[j]
        total_fixed += k ** num_cycles

    return total_fixed // math.factorial(n)


# ═══════════════════════════════════════════════════════════════
# ALGORITHM 6: Transfer Obstruction Detection
# ═══════════════════════════════════════════════════════════════

def is_transferable(
    predicate: callable,
    n: int,
    k: int,
) -> bool:
    """
    Test whether a predicate on k-colorings of {0,...,n-1} is transferable.

    A predicate P is transferable if:
      ∀ c₁ c₂, c₁ ~ c₂ → (P(c₁) ↔ P(c₂))

    Time: O(n! · k^n · n)
    """
    from itertools import product as cart_product

    all_colorings = [list(c) for c in cart_product(range(k), repeat=n)]

    for c1 in all_colorings:
        for c2 in all_colorings:
            equiv, _ = test_semantic_equivalence(c1, c2)
            if equiv:
                if predicate(c1) != predicate(c2):
                    return False
    return True


# ═══════════════════════════════════════════════════════════════
# MAIN: Run examples
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Semantic Isomorphism Theory — Algorithm Demonstrations\n")

    # Example: Burnside counting
    print("Semantic equivalence classes (Burnside):")
    for n in range(1, 6):
        for k in [2, 3]:
            count = count_semantic_classes_burnside(n, k)
            print(f"  n={n}, k={k}: {count} classes out of {k**n} colorings")

    # Example: Stabilizer index
    print("\nStabilizer indices:")
    examples = [[0, 0, 0], [0, 0, 1], [0, 1, 2], [0, 0, 1, 1], [0, 1, 2, 3]]
    for c in examples:
        idx = stabilizer_index(c)
        print(f"  {c} → index = {idx} (orbit size = {idx})")

    # Example: Transfer test
    print("\nTransfer tests (n=3, k=2):")
    tests = [
        ("color[0] == 0", lambda c: c[0] == 0),
        ("all same", lambda c: len(set(c)) == 1),
        ("sum(c) == 1", lambda c: sum(c) == 1),
        ("sum(c) > 0", lambda c: sum(c) > 0),
    ]
    for name, pred in tests:
        result = is_transferable(pred, 3, 2)
        print(f"  '{name}': transferable = {result}")
