#!/usr/bin/env python3
"""
algorithms.py — Certified Algorithms for Frankl's Conjecture

Implements the algorithmic components from the frequency-potential theory:
  1. Witness search by frequency maximization (argmaxElemFreq)
  2. Union-closure computation
  3. Average-threshold certification
  4. Exhaustive Frankl verification

Each algorithm has a correctness specification mirroring the Lean theorems.
"""

from typing import FrozenSet, Set, List, Tuple, Optional
from collections import defaultdict
from itertools import combinations


# ─── Type Aliases ────────────────────────────────────────────────────────

FSet = FrozenSet[int]  # A finite set of integers
Family = List[FSet]     # A family of finite sets


# ─── Algorithm 1: Frequency Maximization Witness Search ──────────────────

def elem_freq(F: Family, a: int) -> int:
    """
    Compute the element frequency of `a` in family `F`.

    elemFreq(F, a) = |{s ∈ F : a ∈ s}|

    Time: O(|F|)
    Space: O(1)
    """
    return sum(1 for s in F if a in s)


def total_weight(F: Family) -> int:
    """
    Compute the total weight of family `F`.

    totalWeight(F) = Σ_{s ∈ F} |s|

    Time: O(Σ|s|) in general, O(|F|) if set sizes are cached
    Space: O(1)
    """
    return sum(len(s) for s in F)


def support(F: Family) -> FSet:
    """
    Compute the support (ground set) of family `F`.

    support(F) = ⋃ F

    Time: O(Σ|s|)
    Space: O(|support|)
    """
    result: Set[int] = set()
    for s in F:
        result.update(s)
    return frozenset(result)


def argmax_elem_freq(F: Family) -> Tuple[Optional[int], int]:
    """
    Find the element with maximum frequency in F.

    Certified property (argmaxElemFreq_spec):
      ∀ a, elemFreq(F, a) ≤ elemFreq(F, result)

    Time: O(|support| · |F|)
    Space: O(|support|)

    Returns: (element, frequency) or (None, 0) if support is empty.
    """
    supp = support(F)
    if not supp:
        return None, 0

    best_elem = None
    best_freq = -1

    for a in supp:
        freq = elem_freq(F, a)
        if freq > best_freq:
            best_freq = freq
            best_elem = a

    return best_elem, best_freq


def is_frankl_witness(F: Family, a: int) -> bool:
    """
    Check if element `a` is a Frankl witness for family `F`.

    IsFranklWitness(F, a) ⟺ 2 · elemFreq(F, a) ≥ |F|

    Time: O(|F|)
    """
    return 2 * elem_freq(F, a) >= len(F)


def certified_witness_search(F: Family, ground_size: int) -> Tuple[bool, Optional[int], str]:
    """
    Certified witness search using the average-size criterion.

    Algorithm:
      1. Compute totalWeight(F) and check average criterion
      2. If |F| · |α| ≤ 2 · totalWeight(F), return argmax (certified)
      3. Otherwise, still check argmax but report as uncertified

    Certified property (argmax_is_witness_of_large_average):
      If the average criterion holds, argmaxElemFreq is guaranteed
      to be a Frankl witness.

    Time: O(|support| · |F|)
    Space: O(|support|)

    Returns: (has_witness, witness_element, certification_status)
    """
    if not F:
        return False, None, "empty family"

    tw = total_weight(F)
    avg_criterion = len(F) * ground_size <= 2 * tw

    best, best_freq = argmax_elem_freq(F)

    if best is not None and is_frankl_witness(F, best):
        if avg_criterion:
            return True, best, "CERTIFIED (average criterion + argmax theorem)"
        else:
            return True, best, "VERIFIED (direct check)"
    else:
        return False, best, "NO WITNESS FOUND"


# ─── Algorithm 2: Union-Closure Computation ──────────────────────────────

def union_closure(generators: List[FSet]) -> Family:
    """
    Compute the union-closure of a set of generators.

    The union-closure is the smallest family containing ∅, all generators,
    and closed under pairwise union.

    Algorithm: iterative fixpoint computation.
      Initialize F = {∅} ∪ generators
      Repeat: F = F ∪ {A ∪ B : A, B ∈ F}
      Until no new sets are added.

    Time: O(|F|² · |support|) per iteration, at most |2^support| iterations
    Space: O(|F| · |support|)

    The output is sorted by (size, lexicographic order).
    """
    F: Set[FSet] = {frozenset()}
    F.update(generators)

    changed = True
    while changed:
        changed = False
        new_sets: Set[FSet] = set()
        F_list = list(F)
        for i, A in enumerate(F_list):
            for j, B in enumerate(F_list):
                if i <= j:  # Optimization: union is commutative
                    u = A | B
                    if u not in F:
                        new_sets.add(u)
                        changed = True
        F.update(new_sets)

    return sorted(F, key=lambda s: (len(s), sorted(s)))


def is_union_closed_family(F: Family) -> bool:
    """
    Verify that F is a union-closed family (contains ∅ and closed under ∪).

    Time: O(|F|²)
    Space: O(|F|)
    """
    F_set = set(F)
    if frozenset() not in F_set:
        return False
    for A in F:
        for B in F:
            if A | B not in F_set:
                return False
    return True


# ─── Algorithm 3: Double-Counting Verification ──────────────────────────

def verify_double_counting(F: Family, ground: Optional[Set[int]] = None) -> Tuple[bool, int, int]:
    """
    Verify the double-counting identity:
      totalWeight(F) = Σ_{a ∈ ground} elemFreq(F, a)

    This is Theorem `totalWeight_eq_sum_elemFreq` in our Lean formalization.

    Returns: (identity_holds, total_weight, sum_of_frequencies)
    """
    if ground is None:
        ground = set(support(F))

    tw = total_weight(F)
    freq_sum = sum(elem_freq(F, a) for a in ground)

    return tw == freq_sum, tw, freq_sum


# ─── Algorithm 4: Exhaustive Frankl Verification ────────────────────────

def exhaustive_frankl_check(n: int, verbose: bool = False) -> Tuple[bool, int, List]:
    """
    Exhaustively verify Frankl's conjecture for all union-closed families
    on ground set {0, ..., n-1}.

    For each family:
      1. Verify union-closedness
      2. Check if it has a nonempty member
      3. Find the maximum-frequency element
      4. Verify it's a Frankl witness

    Time: Exponential in n (enumerates subfamilies of 2^{0,...,n-1})
    Practical limit: n ≤ 4

    Returns: (all_pass, families_checked, counterexamples)
    """
    subsets = []
    for r in range(n + 1):
        for c in combinations(range(n), r):
            subsets.append(frozenset(c))

    all_pass = True
    families_checked = 0
    counterexamples = []

    # Enumerate all subfamilies containing ∅ and at least one nonempty set
    non_empty = [s for s in subsets if s]

    for r in range(1, len(non_empty) + 1):
        for combo in combinations(non_empty, r):
            F = list(combo) + [frozenset()]

            # Check union-closedness
            F_set = set(F)
            if not all(A | B in F_set for A in F for B in F):
                continue

            families_checked += 1

            # Find witness
            best, best_freq = argmax_elem_freq(F)
            if best is not None and is_frankl_witness(F, best):
                if verbose and families_checked % 100 == 0:
                    print(f"    Checked {families_checked} families...")
            else:
                all_pass = False
                counterexamples.append(F)
                if verbose:
                    print(f"    COUNTEREXAMPLE: {[set(s) if s else '∅' for s in F]}")

    return all_pass, families_checked, counterexamples


# ─── Algorithm 5: Frequency Spectrum Analysis ────────────────────────────

def frequency_spectrum(F: Family) -> dict:
    """
    Compute the full frequency spectrum of a family.

    Returns a dictionary with:
      - 'frequencies': {element: frequency}
      - 'total_weight': totalWeight(F)
      - 'family_size': |F|
      - 'support_size': |support(F)|
      - 'avg_set_size': totalWeight(F) / |F|
      - 'avg_frequency': Σ freq / |support|
      - 'max_frequency': max element frequency
      - 'min_frequency': min element frequency (on support)
      - 'has_witness': whether some element is a Frankl witness
      - 'witness': the Frankl witness (if exists)
      - 'avg_criterion': whether average criterion is satisfied
    """
    supp = support(F)
    freqs = {a: elem_freq(F, a) for a in supp}

    tw = total_weight(F)
    n = len(F)
    s = len(supp)

    result = {
        'frequencies': freqs,
        'total_weight': tw,
        'family_size': n,
        'support_size': s,
        'avg_set_size': tw / n if n > 0 else 0,
        'avg_frequency': sum(freqs.values()) / s if s > 0 else 0,
        'max_frequency': max(freqs.values()) if freqs else 0,
        'min_frequency': min(freqs.values()) if freqs else 0,
        'has_witness': False,
        'witness': None,
        'avg_criterion': n * s <= 2 * tw if n > 0 else True,
    }

    for a in supp:
        if is_frankl_witness(F, a):
            result['has_witness'] = True
            result['witness'] = a
            break

    return result


# ─── Main: Example Usage ────────────────────────────────────────────────

def main():
    print("Frankl Conjecture — Certified Algorithms")
    print("=" * 50)

    # Example 1: Witness search
    print("\n--- Algorithm 1: Witness Search ---")
    F = union_closure([frozenset({0, 1}), frozenset({2})])
    print(f"Family: {[set(s) if s else '∅' for s in F]}")
    has_w, w, status = certified_witness_search(F, ground_size=3)
    print(f"Result: witness={w}, status={status}")

    # Example 2: Double counting
    print("\n--- Algorithm 3: Double-Counting Verification ---")
    ok, tw, fs = verify_double_counting(F)
    print(f"totalWeight = {tw}, Σ elemFreq = {fs}, match = {ok}")

    # Example 3: Exhaustive check
    print("\n--- Algorithm 4: Exhaustive Verification ---")
    for n in range(1, 5):
        ok, count, cx = exhaustive_frankl_check(n)
        print(f"n={n}: {'PASS' if ok else 'FAIL'} ({count} families checked)")

    # Example 4: Frequency spectrum
    print("\n--- Algorithm 5: Frequency Spectrum ---")
    F2 = union_closure([frozenset({0}), frozenset({1}), frozenset({2})])
    spec = frequency_spectrum(F2)
    print(f"Family size: {spec['family_size']}")
    print(f"Support size: {spec['support_size']}")
    print(f"Average set size: {spec['avg_set_size']:.2f}")
    print(f"Max frequency: {spec['max_frequency']}")
    print(f"Has witness: {spec['has_witness']} (element {spec['witness']})")
    print(f"Average criterion: {spec['avg_criterion']}")


if __name__ == "__main__":
    main()
