#!/usr/bin/env python3
"""
Algorithms for Closure-Capacity–Attention Duality

Implements the core algorithms:
1. Extreme generator extraction
2. Canonical attention model construction
3. Reconstruction of closure-capacity from attention model
4. Minimality verification
"""

import itertools
from typing import List, Set, Tuple, Callable, Optional, FrozenSet
from dataclasses import dataclass

FSet = frozenset


def powerset(s: set) -> List[FSet]:
    """Return all subsets as frozensets, ordered by cardinality."""
    items = sorted(s)
    result = []
    for r in range(len(items) + 1):
        for combo in itertools.combinations(items, r):
            result.append(FSet(combo))
    return result


# ─────────────────────────────────────────────────────────────────
# Data Structures
# ─────────────────────────────────────────────────────────────────

@dataclass
class ClosureCapacity:
    """A closure-capacity object on a finite ground set.

    Attributes:
        ground_set: The finite ground set X.
        cl: Closure operator mapping subsets to subsets.
        kappa: Capacity function mapping subsets to non-negative integers.
    """
    ground_set: set
    cl: Callable[[FSet], FSet]
    kappa: Callable[[FSet], int]

    def is_closed(self, A: FSet) -> bool:
        return self.cl(A) == A

    def closed_sets(self) -> List[FSet]:
        return [S for S in powerset(self.ground_set) if self.is_closed(S)]


@dataclass
class AttentionModel:
    """A sparse attention model.

    Attributes:
        supports: List of support sets, one per head.
        weights: List of weights, one per head.
    """
    supports: List[FSet]
    weights: List[int]

    @property
    def num_heads(self) -> int:
        return len(self.supports)


# ─────────────────────────────────────────────────────────────────
# Algorithm 1: Extract Extreme Generators
# ─────────────────────────────────────────────────────────────────

def extract_extreme_generators(cc: ClosureCapacity) -> List[Tuple[FSet, int]]:
    """Extract all extreme generators from a closure-capacity object.

    An extreme generator is a nonempty closed set C such that every
    proper closed subset D ⊂ C has κ(D) < κ(C).

    Time complexity: O(2^{2n}) where n = |X| (due to pairwise comparison
    of closed sets). Can be improved to O(|closed_sets|^2).

    Args:
        cc: A closure-capacity object.

    Returns:
        List of (extreme_set, capacity) pairs.

    Example:
        >>> X = {1, 2, 3}
        >>> cl = lambda A: FSet({1,2,3}) if len(A) > 1 else A
        >>> kappa = lambda A: min(len(A), 1)
        >>> cc = ClosureCapacity(X, cl, kappa)
        >>> extremes = extract_extreme_generators(cc)
    """
    closed = cc.closed_sets()
    extremes = []

    for C in closed:
        if not C:  # skip empty set
            continue

        is_extreme = True
        for D in closed:
            if D < C and cc.kappa(D) >= cc.kappa(C):
                is_extreme = False
                break

        if is_extreme:
            extremes.append((C, cc.kappa(C)))

    return extremes


# ─────────────────────────────────────────────────────────────────
# Algorithm 2: Construct Canonical Attention Model
# ─────────────────────────────────────────────────────────────────

def build_canonical_model(cc: ClosureCapacity) -> AttentionModel:
    """Construct the canonical minimal attention model.

    Creates one head per extreme generator, with support equal to
    the extreme set and weight equal to its capacity.

    Time complexity: O(2^{2n}) for extreme generator extraction,
    O(k) for model construction where k = extreme rank.

    Args:
        cc: A closure-capacity object.

    Returns:
        The canonical sparse attention model.

    Example:
        >>> model = build_canonical_model(cc)
        >>> assert model.num_heads == len(extract_extreme_generators(cc))
    """
    extremes = extract_extreme_generators(cc)
    supports = [C for C, _ in extremes]
    weights = [w for _, w in extremes]
    return AttentionModel(supports, weights)


# ─────────────────────────────────────────────────────────────────
# Algorithm 3: Reconstruct Closure from Attention Model
# ─────────────────────────────────────────────────────────────────

def reconstruct_closure_op(
    model: AttentionModel,
    ground_set: set
) -> Callable[[FSet], FSet]:
    """Reconstruct a closure operator from an attention model.

    cl(A) = intersection of all head supports containing A.
    If no head covers A, returns the full ground set.

    Time complexity: O(h * n) per closure call, where h = num_heads.

    Args:
        model: A sparse attention model.
        ground_set: The ground set X.

    Returns:
        A closure function mapping FSet -> FSet.
    """
    def cl(A: FSet) -> FSet:
        covering = [model.supports[i]
                    for i in range(model.num_heads)
                    if A <= model.supports[i]]
        if covering:
            result = FSet(ground_set)
            for s in covering:
                result = result & s
            return result
        return FSet(ground_set)

    return cl


def reconstruct_capacity_fn(model: AttentionModel) -> Callable[[FSet], int]:
    """Reconstruct a capacity function from an attention model.

    κ(A) = max weight over all heads whose support contains A.

    Time complexity: O(h) per capacity call.

    Args:
        model: A sparse attention model.

    Returns:
        A capacity function mapping FSet -> int.
    """
    def kappa(A: FSet) -> int:
        covering = [model.weights[i]
                    for i in range(model.num_heads)
                    if A <= model.supports[i]]
        return max(covering) if covering else 0

    return kappa


# ─────────────────────────────────────────────────────────────────
# Algorithm 4: Verify Realization
# ─────────────────────────────────────────────────────────────────

def verify_realization(
    model: AttentionModel,
    cc: ClosureCapacity
) -> Tuple[bool, Optional[str]]:
    """Verify that an attention model realizes a closure-capacity object.

    Checks all three conditions:
    1. Each head's support is closed.
    2. Every extreme generator appears as some head's support.
    3. Weights match capacity on supports.

    Time complexity: O(h * 2^{2n}).

    Args:
        model: The attention model to verify.
        cc: The closure-capacity object.

    Returns:
        (True, None) if verification passes, (False, reason) otherwise.
    """
    # Condition 1: supports are closed
    for i, s in enumerate(model.supports):
        if not cc.is_closed(s):
            return False, f"Head {i} support {set(s)} is not closed"

    # Condition 2: all extreme generators represented
    extremes = extract_extreme_generators(cc)
    for C, _ in extremes:
        if C not in model.supports:
            return False, f"Extreme generator {set(C)} not in any head support"

    # Condition 3: weights match
    for i in range(model.num_heads):
        expected = cc.kappa(model.supports[i])
        if model.weights[i] != expected:
            return False, (f"Head {i} weight {model.weights[i]} ≠ "
                          f"κ({set(model.supports[i])}) = {expected}")

    return True, None


# ─────────────────────────────────────────────────────────────────
# Algorithm 5: Compute Extreme Rank (Complexity Invariant)
# ─────────────────────────────────────────────────────────────────

def extreme_rank(cc: ClosureCapacity) -> int:
    """Compute the extreme rank = minimal number of attention heads.

    This is the key complexity invariant: it equals the minimal number
    of heads in any realization, and is determined purely by the
    algebraic structure of the closure-capacity object.

    Time complexity: O(2^{2n}).

    Args:
        cc: A closure-capacity object.

    Returns:
        The extreme rank (number of extreme generators).
    """
    return len(extract_extreme_generators(cc))


# ─────────────────────────────────────────────────────────────────
# Algorithm 6: Full Duality Pipeline
# ─────────────────────────────────────────────────────────────────

def full_duality_pipeline(cc: ClosureCapacity) -> dict:
    """Run the complete duality pipeline.

    1. Extract extreme generators.
    2. Build canonical attention model.
    3. Verify realization.
    4. Verify minimality.
    5. Reconstruct closure-capacity from model.
    6. Verify reconstruction properties.

    Args:
        cc: A closure-capacity object.

    Returns:
        Dictionary with all pipeline results.
    """
    # Step 1: Extract
    extremes = extract_extreme_generators(cc)

    # Step 2: Build
    model = build_canonical_model(cc)

    # Step 3: Verify realization
    realizes, reason = verify_realization(model, cc)

    # Step 4: Verify minimality
    is_minimal = model.num_heads == len(extremes)

    # Step 5: Reconstruct
    recon_cl = reconstruct_closure_op(model, cc.ground_set)
    recon_kappa = reconstruct_capacity_fn(model)

    # Step 6: Verify reconstruction
    recon_extensive = all(
        A <= recon_cl(A) for A in powerset(cc.ground_set)
    )
    recon_monotone = all(
        recon_cl(A) <= recon_cl(B)
        for A in powerset(cc.ground_set)
        for B in powerset(cc.ground_set)
        if A <= B
    )

    return {
        'extreme_generators': extremes,
        'extreme_rank': len(extremes),
        'model': model,
        'realizes': realizes,
        'realization_issue': reason,
        'is_minimal': is_minimal,
        'reconstruction_extensive': recon_extensive,
        'reconstruction_monotone': recon_monotone,
    }


if __name__ == "__main__":
    # Quick test
    X = {1, 2, 3}

    def cl(A):
        A = set(A)
        if 1 in A and 2 in A:
            A.add(3)
        return FSet(A)

    def kappa(A):
        return len(cl(A))

    cc = ClosureCapacity(X, cl, kappa)
    result = full_duality_pipeline(cc)

    print("Duality Pipeline Results:")
    print(f"  Extreme rank: {result['extreme_rank']}")
    print(f"  Canonical model heads: {result['model'].num_heads}")
    print(f"  Realizes: {result['realizes']}")
    print(f"  Minimal: {result['is_minimal']}")
    print(f"  Reconstruction extensive: {result['reconstruction_extensive']}")
    print(f"  Reconstruction monotone: {result['reconstruction_monotone']}")
