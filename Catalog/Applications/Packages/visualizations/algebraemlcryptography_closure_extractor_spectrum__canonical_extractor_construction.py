#!/usr/bin/env python3
"""
Algorithms for Closure–Extractor Spectrum Duality

Implements the core algorithms from the research paper:
1. Closed set enumeration
2. Extremal witness extraction
3. Canonical extractor construction
4. Closure reconstruction from extractors
5. Spectrum rank computation
"""

import itertools
from typing import Callable, Optional


def powerset(ground: frozenset) -> list[frozenset]:
    """Generate all subsets of a ground set.

    Args:
        ground: The ground set.

    Returns:
        List of all subsets as frozensets.

    Time complexity: O(2^n) where n = |ground|.
    """
    elems = list(ground)
    result = []
    for r in range(len(elems) + 1):
        for combo in itertools.combinations(elems, r):
            result.append(frozenset(combo))
    return result


def enumerate_closed_sets(
    ground: frozenset,
    cl: Callable[[frozenset], frozenset]
) -> list[frozenset]:
    """Enumerate all closed sets of a closure operator.

    Algorithm: Iterate cl over all subsets and collect fixed points.

    Args:
        ground: Finite ground set.
        cl: Closure operator (extensive, monotone, idempotent).

    Returns:
        Sorted list of closed sets.

    Time complexity: O(2^n · T_cl) where T_cl is the cost of one closure call.
    Space complexity: O(2^n).
    """
    closed = set()
    for A in powerset(ground):
        clA = cl(A)
        if clA == A:
            closed.add(A)
    return sorted(closed, key=lambda s: (len(s), sorted(s)))


def find_extremal_witnesses(
    closed_sets: list[frozenset],
    delta: Callable[[frozenset], int]
) -> list[frozenset]:
    """Find all extremal witnesses among closed sets.

    An extremal witness is a nonempty closed set C such that every
    proper closed subset D ⊊ C has δ(D) < δ(C).

    Algorithm: For each nonempty closed set, check all proper closed subsets.

    Args:
        closed_sets: List of all closed sets.
        delta: Defect function.

    Returns:
        List of extremal witnesses.

    Time complexity: O(|C|^2) where |C| = number of closed sets.
    """
    witnesses = []
    for C in closed_sets:
        if not C:  # Skip empty set
            continue
        is_extremal = True
        for D in closed_sets:
            if D < C:  # D is a proper subset of C
                if delta(D) >= delta(C):
                    is_extremal = False
                    break
        if is_extremal:
            witnesses.append(C)
    return witnesses


def compute_spectrum_rank(
    ground: frozenset,
    cl: Callable[[frozenset], frozenset],
    delta: Callable[[frozenset], int]
) -> int:
    """Compute the spectrum rank of a closure-entropy system.

    The spectrum rank equals the number of extremal witnesses,
    which equals the minimal seed complexity of any realizing extractor.

    Args:
        ground: Finite ground set.
        cl: Closure operator.
        delta: Defect function.

    Returns:
        Spectrum rank (number of extremal witnesses).
    """
    closed = enumerate_closed_sets(ground, cl)
    witnesses = find_extremal_witnesses(closed, delta)
    return len(witnesses)


def build_canonical_extractor(
    ground: frozenset,
    cl: Callable[[frozenset], frozenset],
    delta: Callable[[frozenset], int]
) -> dict:
    """Build the canonical seed-minimal extractor.

    The canonical extractor has one seed per extremal witness.
    This is provably optimal: no extractor with fewer seeds can
    realize the same closure-entropy system.

    Algorithm:
        1. Enumerate closed sets.
        2. Find extremal witnesses.
        3. Create one seed per witness with matching defect bound.

    Args:
        ground: Finite ground set.
        cl: Closure operator.
        delta: Defect function.

    Returns:
        Dictionary with keys:
        - 'num_seeds': int
        - 'witness_sets': list of frozensets
        - 'defect_bounds': list of ints
        - 'extremal_witnesses': list of frozensets

    Time complexity: O(2^n · T_cl + |C|^2).
    """
    closed = enumerate_closed_sets(ground, cl)
    witnesses = find_extremal_witnesses(closed, delta)

    return {
        'num_seeds': len(witnesses),
        'witness_sets': witnesses,
        'defect_bounds': [delta(C) for C in witnesses],
        'extremal_witnesses': witnesses,
    }


def reconstruct_closure(
    ground: frozenset,
    witness_sets: list[frozenset]
) -> Callable[[frozenset], frozenset]:
    """Reconstruct a closure operator from extractor witness sets.

    cl(A) = intersection of all witness sets containing A,
    or the full ground set if no witness set covers A.

    This is guaranteed to be extensive, monotone, and idempotent.

    Args:
        ground: Finite ground set.
        witness_sets: List of witness sets from an extractor.

    Returns:
        Closure function.
    """
    def cl(A: frozenset) -> frozenset:
        covering = [W for W in witness_sets if A <= W]
        if covering:
            result = covering[0]
            for W in covering[1:]:
                result = result & W
            return result
        return ground
    return cl


def reconstruct_defect(
    witness_sets: list[frozenset],
    defect_bounds: list[int]
) -> Callable[[frozenset], int]:
    """Reconstruct a defect profile from extractor data.

    δ(A) = max defect bound over all seeds whose witness set contains A.

    Args:
        witness_sets: List of witness sets.
        defect_bounds: List of defect bounds.

    Returns:
        Defect function.
    """
    def delta(A: frozenset) -> int:
        bounds = [defect_bounds[i] for i, W in enumerate(witness_sets) if A <= W]
        return max(bounds) if bounds else 0
    return delta


def verify_submodularity(
    closed_sets: list[frozenset],
    delta: Callable[[frozenset], int]
) -> tuple[bool, Optional[tuple]]:
    """Verify submodularity of defect on closed sets.

    Checks: δ(A) + δ(B) ≥ δ(A ∩ B) + δ(A ∪ B) for all closed A, B.

    Args:
        closed_sets: List of closed sets.
        delta: Defect function.

    Returns:
        (True, None) if submodular, (False, (A, B, lhs, rhs)) if violated.
    """
    for A in closed_sets:
        for B in closed_sets:
            lhs = delta(A) + delta(B)
            rhs = delta(A & B) + delta(A | B)
            if lhs < rhs:
                return False, (A, B, lhs, rhs)
    return True, None


def verify_closure_invariance(
    ground: frozenset,
    cl: Callable[[frozenset], frozenset],
    delta: Callable[[frozenset], int]
) -> tuple[bool, Optional[frozenset]]:
    """Verify closure invariance: δ(A) = δ(cl(A)) for all A.

    Args:
        ground: Finite ground set.
        cl: Closure operator.
        delta: Defect function.

    Returns:
        (True, None) if invariant, (False, A) for violating A.
    """
    for A in powerset(ground):
        if delta(A) != delta(cl(A)):
            return False, A
    return True, None


# ── Pseudocode for the main algorithms ──────────────────────────────

CANONICAL_EXTRACTOR_PSEUDOCODE = """
ALGORITHM: CanonicalExtractor(ι, cl, δ)
INPUT: Ground set ι, closure operator cl, defect function δ
OUTPUT: Seed-minimal extractor (W, d)

1. C ← {A ⊆ ι : cl(A) = A}          // Enumerate closed sets
2. E ← ∅                              // Initialize extremal witnesses
3. FOR EACH C ∈ C \\ {∅}:
4.   IF ∀D ∈ C, D ⊊ C ⟹ δ(D) < δ(C):
5.     E ← E ∪ {C}                    // C is an extremal witness
6. n ← |E|                            // Spectrum rank
7. W ← enumerate(E)                   // Witness sets = extremal witnesses
8. d ← [δ(C) for C in E]             // Defect bounds
9. RETURN (n, W, d)

COMPLEXITY: O(2^|ι| · T_cl + |C|²)
CORRECTNESS: Theorem 3.2 + Theorem 4.2
"""

RECONSTRUCTION_PSEUDOCODE = """
ALGORITHM: ReconstructClosure(ι, W)
INPUT: Ground set ι, witness sets W = [W₁, ..., Wₙ]
OUTPUT: Closure operator cl

1. DEFINE cl(A):
2.   cover ← {Wᵢ : A ⊆ Wᵢ}
3.   IF cover ≠ ∅:
4.     RETURN ⋂ cover
5.   ELSE:
6.     RETURN ι

COMPLEXITY: O(n · |ι|) per closure call
CORRECTNESS: Theorem 5.2
"""


if __name__ == "__main__":
    # Example usage
    ground = frozenset({0, 1, 2, 3})
    blocks = [frozenset({0, 1}), frozenset({2, 3})]

    def cl(A):
        result = frozenset()
        for block in blocks:
            if A & block:
                result = result | block
        return result if A else frozenset()

    def delta(A):
        clA = cl(A)
        if not clA:
            return 0
        return sum(1 for b in blocks if clA & b)

    print("Closed sets:", [set(C) for C in enumerate_closed_sets(ground, cl)])

    ext = build_canonical_extractor(ground, cl, delta)
    print(f"Spectrum rank: {ext['num_seeds']}")
    print(f"Extremal witnesses: {[set(C) for C in ext['extremal_witnesses']]}")

    # Verify submodularity
    closed = enumerate_closed_sets(ground, cl)
    ok, violation = verify_submodularity(closed, delta)
    print(f"Submodularity verified: {ok}")

    # Verify closure invariance
    ok, violation = verify_closure_invariance(ground, cl, delta)
    print(f"Closure invariance verified: {ok}")

    # Reconstruction round-trip
    rec_cl = reconstruct_closure(ground, ext['witness_sets'])
    print("\nReconstruction test:")
    for A in powerset(ground):
        orig = cl(A)
        recon = rec_cl(A)
        print(f"  cl({set(A)}) = {set(orig)}, rec({set(A)}) = {set(recon)}, match={orig==recon}")
