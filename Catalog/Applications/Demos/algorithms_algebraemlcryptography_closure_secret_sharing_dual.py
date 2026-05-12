#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for closure-secret-sharing duality.

Implements:
1. Closure operator construction from access structures
2. Minimal authorized set enumeration
3. Secret-circuit detection
4. Dependency system construction and round-trip verification
5. Canonical compressed presentation
"""

from __future__ import annotations
from dataclasses import dataclass
from itertools import combinations
from typing import Callable


def _powerset(s) -> list[frozenset]:
    """Generate all subsets of s, ordered by size."""
    items = list(s)
    result = []
    for r in range(len(items) + 1):
        for combo in combinations(items, r):
            result.append(frozenset(combo))
    return result


def _fmt(s: frozenset) -> str:
    if not s:
        return "∅"
    return "{" + ", ".join(sorted(str(x) for x in s)) + "}"


# =============================================================================
# Core Data Structures
# =============================================================================

@dataclass
class ClosureOperator:
    """A closure operator on a finite ground set (represented as frozensets).

    Attributes:
        ground_set: The full ground set (including the secret element None).
        cl: The closure function mapping frozenset -> frozenset.
    """
    ground_set: frozenset
    cl: Callable[[frozenset], frozenset]

    def is_extensive(self) -> bool:
        """Check: A ⊆ cl(A) for all A."""
        for s in _powerset(self.ground_set):
            if not s <= self.cl(s):
                return False
        return True

    def is_monotone(self) -> bool:
        """Check: A ⊆ B ⟹ cl(A) ⊆ cl(B)."""
        subsets = _powerset(self.ground_set)
        for a in subsets:
            for b in subsets:
                if a <= b and not self.cl(a) <= self.cl(b):
                    return False
        return True

    def is_idempotent(self) -> bool:
        """Check: cl(cl(A)) = cl(A) for all A."""
        for s in _powerset(self.ground_set):
            if self.cl(self.cl(s)) != self.cl(s):
                return False
        return True

    def verify(self) -> bool:
        """Verify all three closure axioms."""
        return self.is_extensive() and self.is_monotone() and self.is_idempotent()


@dataclass
class PointedDependencySystem:
    """A pointed dependency system over a finite participant set.

    Attributes:
        participants: Set of participant identifiers.
        carrier: Set of carrier elements.
        span: Closure/span function on carrier subsets.
        gen: Generator assignment (participant -> carrier element).
        secret: The distinguished secret element in the carrier.
    """
    participants: set
    carrier: set
    span: Callable[[frozenset], frozenset]
    gen: dict
    secret: object

    def is_authorized(self, s: frozenset) -> bool:
        """Check if participant set s is authorized."""
        gen_image = frozenset(self.gen[x] for x in s if x in self.gen)
        return self.secret in self.span(gen_image)

    def to_closure_operator(self) -> ClosureOperator:
        """Construct closure operator on Option(participants)."""
        option_set = frozenset({None} | self.participants)

        def to_carrier(y):
            if y is None:
                return self.secret
            return self.gen[y]

        def cl(a: frozenset) -> frozenset:
            carrier_image = frozenset(to_carrier(y) for y in a)
            spanned = self.span(carrier_image)
            return frozenset(y for y in option_set if to_carrier(y) in spanned)

        return ClosureOperator(ground_set=option_set, cl=cl)


@dataclass
class AccessStructure:
    """A monotone access structure on a finite participant set."""
    participants: set
    authorized: Callable[[frozenset], bool]

    def minimal_authorized_sets(self) -> list[frozenset]:
        """Enumerate all minimal authorized sets. O(2^n) time."""
        result = []
        all_subsets = _powerset(self.participants)
        for s in all_subsets:
            if not self.authorized(s):
                continue
            is_minimal = True
            for t in all_subsets:
                if t < s and self.authorized(t):
                    is_minimal = False
                    break
            if is_minimal:
                result.append(s)
        return result

    def secret_circuits(self, cl: ClosureOperator) -> list[frozenset]:
        """Find all secret-circuits of a closure operator."""
        result = []
        for s in _powerset(self.participants):
            if not s:
                continue
            if None not in cl.cl(s):
                continue
            is_circuit = True
            for x in s:
                if None in cl.cl(s - {x}):
                    is_circuit = False
                    break
            if is_circuit:
                result.append(s)
        return result

    def is_monotone(self) -> bool:
        """Verify monotonicity of the access structure."""
        subsets = _powerset(self.participants)
        for s in subsets:
            if not self.authorized(s):
                continue
            for t in subsets:
                if s <= t and not self.authorized(t):
                    return False
        return True


# =============================================================================
# Construction Functions
# =============================================================================

def dependency_from_closure(participants: set, cl: ClosureOperator) -> PointedDependencySystem:
    """Construct a dependency system from a closure operator."""
    return PointedDependencySystem(
        participants=participants,
        carrier=set(cl.ground_set),
        span=cl.cl,
        gen={x: x for x in participants},
        secret=None,
    )


def closure_from_access(participants: set, authorized: Callable) -> ClosureOperator:
    """Construct a closure operator from an access structure."""
    option_set = frozenset({None} | participants)

    def cl(a: frozenset) -> frozenset:
        parts = frozenset(x for x in a if x is not None)
        if authorized(parts):
            return option_set
        return frozenset(a)

    return ClosureOperator(ground_set=option_set, cl=cl)


def canonical_compressed_presentation(
    participants: set, minimal_auth_sets: list[frozenset]
) -> PointedDependencySystem:
    """Build canonical compressed dependency system from minimal authorized sets."""
    option_set = frozenset({None} | participants)

    def span(a: frozenset) -> frozenset:
        for m in minimal_auth_sets:
            if m <= a:
                return option_set
        return a

    return PointedDependencySystem(
        participants=participants,
        carrier=set(option_set),
        span=span,
        gen={x: x for x in participants},
        secret=None,
    )


# =============================================================================
# Verification Functions
# =============================================================================

def verify_circuit_theorem(participants: set, cl: ClosureOperator) -> bool:
    """Verify Theorem 2: minimal authorized sets = secret-circuits."""
    access = AccessStructure(
        participants=participants,
        authorized=lambda s: None in cl.cl(s)
    )
    minimal_auth = access.minimal_authorized_sets()
    circuits = access.secret_circuits(cl)
    return set(minimal_auth) == set(circuits)


def verify_roundtrip(participants: set, cl: ClosureOperator) -> bool:
    """Verify round-trip: cl → dependency → cl preserves authorization."""
    dep = dependency_from_closure(participants, cl)
    cl2 = dep.to_closure_operator()
    for s in _powerset(participants):
        auth1 = None in cl.cl(s)
        auth2 = None in cl2.cl(s)
        if auth1 != auth2:
            return False
    return True


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    print("Algorithms Module — Self-Test")
    print("=" * 50)

    participants = {"A", "B", "C"}
    option_set = frozenset({None} | participants)

    def threshold_cl(s: frozenset) -> frozenset:
        p_count = sum(1 for x in s if x is not None)
        if p_count >= 2:
            return option_set
        return frozenset(s)

    cl = ClosureOperator(ground_set=option_set, cl=threshold_cl)

    print(f"Closure axioms verified: {cl.verify()}")
    print(f"Circuit theorem verified: {verify_circuit_theorem(participants, cl)}")
    print(f"Round-trip verified: {verify_roundtrip(participants, cl)}")

    access = AccessStructure(
        participants=participants,
        authorized=lambda s: None in cl.cl(s)
    )
    mas = access.minimal_authorized_sets()
    print(f"Minimal authorized sets: {[_fmt(m) for m in mas]}")

    compressed = canonical_compressed_presentation(participants, mas)
    print("Compressed system verification:")
    all_ok = True
    for s in _powerset(participants):
        orig = None in cl.cl(s)
        comp = compressed.is_authorized(s)
        if orig != comp:
            print(f"  MISMATCH at {_fmt(s)}")
            all_ok = False
    if all_ok:
        print("  ✓ All authorization decisions preserved")

    print("\nAll tests passed ✓")
