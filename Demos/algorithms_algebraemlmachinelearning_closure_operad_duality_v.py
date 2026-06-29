#!/usr/bin/env python3
"""
Algorithms for Closure-Operad Duality

Implements the canonical reconstruction algorithm and related utilities
for closure systems and finite architectures.
"""

import itertools
from typing import Callable, Optional
from dataclasses import dataclass, field


@dataclass
class ClosureSystem:
    """A closure system on a finite set."""
    elements: frozenset
    _cl: Callable[[frozenset], frozenset]

    def cl(self, A: frozenset) -> frozenset:
        return self._cl(A)

    def is_closed(self, A: frozenset) -> bool:
        return self.cl(A) == A

    def all_subsets(self) -> list:
        result = []
        for r in range(len(self.elements) + 1):
            for s in itertools.combinations(sorted(self.elements), r):
                result.append(frozenset(s))
        return result

    def closed_sets(self) -> list:
        return sorted([A for A in self.all_subsets() if self.is_closed(A)],
                       key=lambda s: (len(s), sorted(s)))

    def join_irreducibles(self) -> list:
        """Find join-irreducible closed sets."""
        closed = self.closed_sets()
        result = []
        for X in closed:
            if not X:
                continue
            is_ji = True
            for A in closed:
                if A >= X:
                    continue
                for B in closed:
                    if B >= X:
                        continue
                    if self.cl(frozenset(A | B)) == X:
                        is_ji = False
                        break
                if not is_ji:
                    break
            if is_ji:
                result.append(X)
        return result


@dataclass
class FinArchitecture:
    """A finite architecture with nodes and feature mappings."""
    nodes: list
    input_features: dict
    output_features: dict

    def total_cl(self, seed: frozenset) -> frozenset:
        result = set(seed)
        for node in self.nodes:
            result |= self.output_features[node]
        return frozenset(result)

    def essential_nodes(self) -> list:
        """Find essential (non-redundant) nodes."""
        essential = []
        for v in self.nodes:
            others_output = set()
            for u in self.nodes:
                if u != v:
                    others_output |= self.output_features[u]
            if not self.output_features[v] <= others_output:
                essential.append(v)
        return essential

    def num_essential_nodes(self) -> int:
        return len(self.essential_nodes())


def reconstruct_architecture(cs: ClosureSystem) -> FinArchitecture:
    """
    Canonical Reconstruction Algorithm

    Given a closure system on a finite set C, construct the canonical
    architecture with one node per element.

    Time complexity: O(|C|) closure oracle calls on singleton sets.
    Space complexity: O(|C|²) for storing output features.

    Args:
        cs: A closure system on a finite set

    Returns:
        The canonical architecture whose nodes are elements of C,
        with outputFeatures(c) = cl({c}).
    """
    nodes = sorted(cs.elements)
    input_features = {c: frozenset({c}) for c in nodes}
    output_features = {c: cs.cl(frozenset({c})) for c in nodes}
    return FinArchitecture(nodes, input_features, output_features)


def verify_soundness(cs: ClosureSystem, arch: FinArchitecture) -> bool:
    """
    Verify reconstruction soundness: cl({c}) ⊆ totalCl(arch, {c}) for all c.

    Time complexity: O(|C|²) set operations.
    """
    for c in cs.elements:
        if not cs.cl(frozenset({c})) <= arch.total_cl(frozenset({c})):
            return False
    return True


def normalize_closure(cs: ClosureSystem) -> ClosureSystem:
    """
    Normalize a closure system by composing cl with itself.

    By idempotence, this produces the same closure system.
    This operation corresponds to `post_quantum_closure_hash_stable_under_idempotent_round`.
    """
    return ClosureSystem(
        elements=cs.elements,
        _cl=lambda A, cs=cs: cs.cl(cs.cl(A))
    )


def observationally_equivalent(a1: FinArchitecture, a2: FinArchitecture,
                                 elements: frozenset) -> bool:
    """Check observational equivalence on all subsets."""
    for r in range(len(elements) + 1):
        for s in itertools.combinations(sorted(elements), r):
            X = frozenset(s)
            if a1.total_cl(X) != a2.total_cl(X):
                return False
    return True


def closure_from_implications(elements: set,
                               implications: list) -> ClosureSystem:
    """
    Build a closure system from a list of implications.

    Each implication is a pair (antecedent: set, consequent: set)
    meaning: if antecedent ⊆ current_set, add consequent.

    Time complexity: O(|implications| · |elements|) per closure call.
    """
    def cl(A):
        result = set(A)
        changed = True
        while changed:
            changed = False
            for ante, cons in implications:
                if ante <= result and not cons <= result:
                    result |= cons
                    changed = True
        return frozenset(result)

    return ClosureSystem(frozenset(elements), cl)


# ─── Example usage ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Build a closure system from implications
    elements = {'a', 'b', 'c', 'd', 'e'}
    implications = [
        (frozenset({'a'}), frozenset({'b'})),        # a → b
        (frozenset({'b'}), frozenset({'c'})),        # b → c
        (frozenset({'d'}), frozenset({'e'})),        # d → e
        (frozenset({'c', 'e'}), frozenset({'a', 'd'})),  # c,e → a,d (cycle)
    ]

    cs = closure_from_implications(elements, implications)

    print("Closure system from implications:")
    print(f"  Elements: {sorted(cs.elements)}")
    print(f"  cl({{a}}) = {set(cs.cl(frozenset({'a'})))}")
    print(f"  cl({{d}}) = {set(cs.cl(frozenset({'d'})))}")
    print(f"  cl({{a,d}}) = {set(cs.cl(frozenset({'a', 'd'})))}")

    print(f"\nClosed sets: {len(cs.closed_sets())}")
    for s in cs.closed_sets():
        print(f"  {set(s)}")

    print(f"\nJoin-irreducibles:")
    for s in cs.join_irreducibles():
        print(f"  {set(s)}")

    arch = reconstruct_architecture(cs)
    print(f"\nCanonical architecture: {len(arch.nodes)} nodes")
    print(f"Essential nodes: {arch.essential_nodes()}")
    print(f"Soundness: {verify_soundness(cs, arch)}")

    # Normalization stability
    cs_norm = normalize_closure(cs)
    arch_norm = reconstruct_architecture(cs_norm)
    equiv = observationally_equivalent(arch, arch_norm, cs.elements)
    print(f"Normalization stable: {equiv}")
