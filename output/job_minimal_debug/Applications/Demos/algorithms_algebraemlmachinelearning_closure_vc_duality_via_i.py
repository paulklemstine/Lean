#!/usr/bin/env python3
"""
Algorithms for Closure-Based Learning Theory

Implements the key algorithms derived from the Closure–VC Duality theorem:
1. Closure rank computation
2. VC dimension via closure rank
3. Certified sample compression
4. Minimal closed hypothesis reconstruction
"""

import itertools
from typing import Callable, FrozenSet, List, Tuple, Optional, Set, Dict
from dataclasses import dataclass

FSet = frozenset


@dataclass
class ClosureSystem:
    """
    A finite closure system on a ground set.

    Attributes:
        ground: The finite ground set
        cl: The closure operator mapping subsets to subsets

    The closure operator must satisfy:
    - Extensivity: S ⊆ cl(S)
    - Monotonicity: S ⊆ T ⟹ cl(S) ⊆ cl(T)
    - Idempotence: cl(cl(S)) = cl(S)
    """
    ground: FSet
    cl: Callable[[FSet], FSet]

    def verify(self) -> bool:
        """Verify closure axioms. O(3^n) time."""
        for s in self._powerset():
            cs = self.cl(s)
            if not s <= cs:
                return False
            if not cs <= self.ground:
                return False
            if self.cl(cs) != cs:
                return False
        for s in self._powerset():
            for t in self._powerset():
                if s <= t and not self.cl(s) <= self.cl(t):
                    return False
        return True

    def _powerset(self) -> List[FSet]:
        elts = sorted(self.ground)
        result = []
        for r in range(len(elts) + 1):
            for c in itertools.combinations(elts, r):
                result.append(frozenset(c))
        return result


def closure_rank(cs: ClosureSystem, A: FSet) -> int:
    """
    Compute the closure rank of A in the closure system.

    The closure rank is the minimum cardinality of a subset G ⊆ A
    such that cl(G) = cl(A).

    Time complexity: O(sum_{k=0}^{|A|} C(|A|,k) · T_cl) where T_cl is
    the cost of one closure evaluation.

    Args:
        cs: The closure system
        A: A subset of the ground set

    Returns:
        The closure rank of A
    """
    target = cs.cl(A)
    elts = sorted(A)
    for r in range(len(elts) + 1):
        for G in itertools.combinations(elts, r):
            if cs.cl(frozenset(G)) == target:
                return r
    return len(A)


def min_generator(cs: ClosureSystem, A: FSet) -> FSet:
    """
    Find a minimum-cardinality generating subset G ⊆ A with cl(G) = cl(A).

    This is the "compression kernel" — the smallest set of elements needed
    to reconstruct the closure of A.

    Time complexity: O(sum_{k=0}^{rank} C(|A|,k) · T_cl)
    """
    target = cs.cl(A)
    elts = sorted(A)
    for r in range(len(elts) + 1):
        for G in itertools.combinations(elts, r):
            G = frozenset(G)
            if cs.cl(G) == target:
                return G
    return A


def is_closure_independent(cs: ClosureSystem, A: FSet) -> bool:
    """
    Check if A is closure-independent: rank(A) = |A|.

    By the duality theorem, this is equivalent to A being shattered
    by the closed concept class.

    Time complexity: O(|A| · T_cl) — only need to check removing each element.
    """
    target = cs.cl(A)
    for x in A:
        if cs.cl(A - {x}) == target:
            return False
    return True


def vc_dimension_via_rank(cs: ClosureSystem) -> int:
    """
    Compute the VC dimension of the closed concept class using the
    Closure–VC Duality: VC dim = max closure rank.

    This exploits the duality theorem to avoid enumerating all 2^|A|
    traces for shattering checks.

    Time complexity: O(2^n · n · T_cl) where n = |ground|
    """
    max_rank = 0
    for s in cs._powerset():
        r = closure_rank(cs, s)
        max_rank = max(max_rank, r)
    return max_rank


def closed_sets(cs: ClosureSystem) -> List[FSet]:
    """
    Enumerate all closed sets (fixed points of cl).

    Time complexity: O(2^n · T_cl)
    """
    return [s for s in cs._powerset() if cs.cl(s) == s]


def reconstruct(cs: ClosureSystem, positives: FSet) -> FSet:
    """
    Certified reconstruction: compute cl(positives).

    Properties (proven in the formal theorem):
    1. The result is closed (a fixed point of cl)
    2. positives ⊆ result
    3. Minimal: result ⊆ H for every closed H containing positives

    Time complexity: O(T_cl)
    """
    return cs.cl(positives)


@dataclass
class CompressionResult:
    """Result of sample compression."""
    generators: FSet          # The compressed subset G
    reconstruction: FSet      # The reconstructed hypothesis cl(G)
    original_hypothesis: FSet # The original hypothesis
    sample: FSet              # The sample points
    is_consistent: bool       # Whether reconstruction agrees with original on sample
    compression_ratio: float  # |G| / |sample|


def compress_sample(cs: ClosureSystem, sample: FSet, hypothesis: FSet) -> CompressionResult:
    """
    Compress a labeled sample using the closure-based compression scheme.

    Given a sample and a closed hypothesis consistent with it, find the
    smallest subset of positive examples whose closure reconstructs the
    hypothesis on the sample.

    By the duality theorem, the compression size is at most the VC dimension.

    Args:
        cs: The closure system
        sample: The sample points
        hypothesis: A closed hypothesis (must satisfy cl(H) = H)

    Returns:
        CompressionResult with the compressed generators and reconstruction
    """
    positives = sample & hypothesis
    G = min_generator(cs, positives)
    recon = cs.cl(G)

    is_consistent = (recon & sample) == (hypothesis & sample)
    ratio = len(G) / len(sample) if sample else 0.0

    return CompressionResult(
        generators=G,
        reconstruction=recon,
        original_hypothesis=hypothesis,
        sample=sample,
        is_consistent=is_consistent,
        compression_ratio=ratio
    )


def greedy_closure_rank(cs: ClosureSystem, A: FSet) -> Tuple[int, FSet]:
    """
    Greedy approximation to minimum generator.

    Instead of brute-force search, greedily remove elements from A that
    don't change the closure. This gives a generator (not necessarily minimal)
    but runs in O(|A| · T_cl) time.

    Returns:
        (size, generator) tuple
    """
    target = cs.cl(A)
    current = set(A)
    for x in sorted(A):
        trial = frozenset(current - {x})
        if cs.cl(trial) == target:
            current = set(trial)
    G = frozenset(current)
    return len(G), G


def all_independent_sets(cs: ClosureSystem) -> List[FSet]:
    """
    Find all closure-independent subsets.
    By the duality theorem, these are exactly the shattered sets.
    """
    result = []
    for s in cs._powerset():
        if is_closure_independent(cs, s):
            result.append(s)
    return result


def max_independent_set(cs: ClosureSystem) -> FSet:
    """
    Find a maximum-cardinality closure-independent set.
    This is a set of maximum size that is shattered by the closed concept class.
    """
    best = frozenset()
    for s in cs._powerset():
        if len(s) > len(best) and is_closure_independent(cs, s):
            best = s
    return best


# ─── Example closure operators ───────────────────────────────────────

def make_identity_closure(ground: FSet) -> ClosureSystem:
    """Identity closure: every set is closed."""
    return ClosureSystem(ground, lambda s: s)


def make_constant_closure(ground: FSet) -> ClosureSystem:
    """Constant closure: cl(∅)=∅, cl(S)=X for S≠∅."""
    return ClosureSystem(ground, lambda s: ground if s else frozenset())


def make_interval_closure(ground: FSet) -> ClosureSystem:
    """Interval hull closure on integers: cl(S) = [min S, max S] ∩ ground."""
    def cl(s):
        if not s:
            return frozenset()
        lo, hi = min(s), max(s)
        return frozenset(x for x in ground if lo <= x <= hi)
    return ClosureSystem(ground, cl)


def make_affine_closure(ground: FSet) -> ClosureSystem:
    """
    Affine closure on integers mod p (for prime |ground|):
    cl(S) = affine span of S over Z_p.
    """
    n = len(ground)
    elts = sorted(ground)

    def cl(s):
        if not s:
            return frozenset()
        if len(s) == 1:
            return s
        # Generate all affine combinations mod n
        result = set(s)
        changed = True
        while changed:
            changed = False
            rl = sorted(result)
            for a in rl:
                for b in rl:
                    if a != b:
                        for t in range(n):
                            c = (a + t * (b - a)) % n
                            if c in ground and c not in result:
                                result.add(c)
                                changed = True
        return frozenset(result)

    return ClosureSystem(ground, cl)


if __name__ == "__main__":
    print("Closure–VC Duality: Algorithm Demonstrations")
    print("=" * 50)

    # Example: interval closure on {1,...,6}
    ground = frozenset(range(1, 7))
    cs = make_interval_closure(ground)

    print(f"\nInterval closure on {set(ground)}")
    print(f"VC dimension (via rank): {vc_dimension_via_rank(cs)}")
    print(f"Number of closed sets: {len(closed_sets(cs))}")

    # Show compression on a concrete sample
    sample = frozenset({1, 2, 3, 4, 5, 6})
    for H in closed_sets(cs):
        if 2 <= len(H) <= 4:
            result = compress_sample(cs, sample, H)
            print(f"\n  H = {set(H)}")
            print(f"  Generators: {set(result.generators)} (size {len(result.generators)})")
            print(f"  Reconstruction: {set(result.reconstruction)}")
            print(f"  Consistent: {result.is_consistent}")
            print(f"  Compression ratio: {result.compression_ratio:.2f}")

    # Show the maximum independent (shattered) set
    best = max_independent_set(cs)
    print(f"\nMaximum shattered set: {set(best)} (size {len(best)} = VC dim)")
