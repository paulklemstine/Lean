#!/usr/bin/env python3
"""
Algorithms for Compositional Musical Specifications

Implements the core data structures and operations from the formal framework,
with efficient representations for practical use.
"""

from __future__ import annotations
from itertools import product
from typing import Callable, Iterator
from dataclasses import dataclass, field


@dataclass(frozen=True)
class MusicSpec:
    """A musical specification: a set of allowed phrases over an event alphabet.

    Phrases are represented as tuples of integers (event indices).
    The specification is stored as a frozenset for efficient subset testing.

    Attributes:
        phrases: The set of allowed phrases.
        alphabet_size: The size of the event alphabet.
    """
    phrases: frozenset[tuple[int, ...]]
    alphabet_size: int = 12

    @staticmethod
    def from_scale(scale_degrees: list[int], phrase_length: int,
                   alphabet_size: int = 12) -> MusicSpec:
        """Create a specification containing all phrases of given length
        using only the specified scale degrees.

        Args:
            scale_degrees: List of allowed pitch classes (0-indexed).
            phrase_length: Number of events per phrase.
            alphabet_size: Total number of event types.

        Returns:
            MusicSpec with all combinations of scale degrees.

        Complexity: O(|scale_degrees|^phrase_length)
        """
        phrases = frozenset(product(scale_degrees, repeat=phrase_length))
        return MusicSpec(phrases=phrases, alphabet_size=alphabet_size)

    @staticmethod
    def from_constraint(alphabet_size: int, phrase_length: int,
                        constraint: Callable[[tuple[int, ...]], bool]) -> MusicSpec:
        """Create a specification by filtering all phrases through a constraint.

        Args:
            alphabet_size: Total number of event types.
            phrase_length: Number of events per phrase.
            constraint: Predicate that returns True for allowed phrases.

        Returns:
            MusicSpec containing only phrases satisfying the constraint.

        Complexity: O(alphabet_size^phrase_length)
        """
        all_phrases = product(range(alphabet_size), repeat=phrase_length)
        phrases = frozenset(p for p in all_phrases if constraint(p))
        return MusicSpec(phrases=phrases, alphabet_size=alphabet_size)

    @staticmethod
    def empty_word(alphabet_size: int = 12) -> MusicSpec:
        """The identity specification containing only the empty phrase.

        Complexity: O(1)
        """
        return MusicSpec(phrases=frozenset({()}), alphabet_size=alphabet_size)

    @staticmethod
    def empty(alphabet_size: int = 12) -> MusicSpec:
        """The bottom specification containing no phrases.

        Complexity: O(1)
        """
        return MusicSpec(phrases=frozenset(), alphabet_size=alphabet_size)

    def refines(self, other: MusicSpec) -> bool:
        """Check if this specification refines (is more restrictive than) other.

        self.refines(other) iff self ⊆ other.

        Complexity: O(|self.phrases|)
        """
        return self.phrases.issubset(other.phrases)

    def compose(self, other: MusicSpec) -> MusicSpec:
        """Concatenative composition: {u ++ v | u ∈ self, v ∈ other}.

        Complexity: O(|self| × |other| × phrase_length)
        """
        phrases = frozenset(u + v for u in self.phrases for v in other.phrases)
        return MusicSpec(phrases=phrases, alphabet_size=max(self.alphabet_size, other.alphabet_size))

    def map_spec(self, f: Callable[[int], int], target_alphabet_size: int = 12) -> MusicSpec:
        """Style transport: relabel each event by f.

        Args:
            f: Event relabeling function.
            target_alphabet_size: Alphabet size of the target specification.

        Returns:
            Transported specification.

        Complexity: O(|self| × max_phrase_length)
        """
        phrases = frozenset(tuple(f(x) for x in p) for p in self.phrases)
        return MusicSpec(phrases=phrases, alphabet_size=target_alphabet_size)

    def intersect(self, other: MusicSpec) -> MusicSpec:
        """Intersection of specifications (meet in the refinement lattice).

        Complexity: O(min(|self|, |other|))
        """
        return MusicSpec(
            phrases=self.phrases & other.phrases,
            alphabet_size=max(self.alphabet_size, other.alphabet_size)
        )

    def union(self, other: MusicSpec) -> MusicSpec:
        """Union of specifications (join in the refinement lattice).

        Complexity: O(|self| + |other|)
        """
        return MusicSpec(
            phrases=self.phrases | other.phrases,
            alphabet_size=max(self.alphabet_size, other.alphabet_size)
        )

    def __len__(self) -> int:
        return len(self.phrases)

    def __contains__(self, phrase: tuple[int, ...]) -> bool:
        return phrase in self.phrases

    def __iter__(self) -> Iterator[tuple[int, ...]]:
        return iter(self.phrases)

    def __repr__(self) -> str:
        return f"MusicSpec({len(self.phrases)} phrases, alphabet={self.alphabet_size})"


def stepwise_constraint(phrase: tuple[int, ...], max_step: int = 2,
                        mod: int = 12) -> bool:
    """Constraint: consecutive events differ by at most max_step (mod alphabet size).

    This models stepwise melodic motion.
    """
    for i in range(len(phrase) - 1):
        diff = min((phrase[i+1] - phrase[i]) % mod,
                   (phrase[i] - phrase[i+1]) % mod)
        if diff > max_step:
            return False
    return True


def no_repeated_notes(phrase: tuple[int, ...]) -> bool:
    """Constraint: no two consecutive events are the same."""
    return all(phrase[i] != phrase[i+1] for i in range(len(phrase) - 1))


def build_refinement_lattice(specs: dict[str, MusicSpec]) -> list[tuple[str, str]]:
    """Compute the Hasse diagram of the refinement preorder.

    Returns edges (child, parent) where child refines parent and there is
    no intermediate specification.

    Complexity: O(n^3) where n = |specs|
    """
    names = list(specs.keys())
    n = len(names)
    # Compute full relation
    relation = [[False] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if i != j:
                relation[i][j] = specs[names[i]].refines(specs[names[j]])

    # Reduce to Hasse diagram (remove transitive edges)
    hasse = [[False] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if relation[i][j]:
                # Check if there's an intermediate k
                is_direct = True
                for k in range(n):
                    if k != i and k != j and relation[i][k] and relation[k][j]:
                        is_direct = False
                        break
                hasse[i][j] = is_direct

    edges = []
    for i in range(n):
        for j in range(n):
            if hasse[i][j]:
                edges.append((names[i], names[j]))
    return edges


def verify_monotonicity(specs: list[MusicSpec],
                        operation: Callable[[MusicSpec, MusicSpec], MusicSpec],
                        fixed: MusicSpec) -> bool:
    """Verify that an operation is monotone: if S ⊆ T, then op(S, fixed) ⊆ op(T, fixed).

    Complexity: O(n^2 × cost_of_operation)
    """
    for i, S in enumerate(specs):
        for j, T in enumerate(specs):
            if S.refines(T):
                result_S = operation(S, fixed)
                result_T = operation(T, fixed)
                if not result_S.refines(result_T):
                    return False
    return True


# --- Example usage ---

if __name__ == '__main__':
    # Build specifications with constraints
    print("Building musical specifications with constraints...")
    print()

    # Stepwise C major melodies (3 notes)
    stepwise_major = MusicSpec.from_constraint(
        12, 3,
        lambda p: all(x in [0,2,4,5,7,9,11] for x in p) and stepwise_constraint(p)
    )
    print(f"Stepwise C major (3-note): {len(stepwise_major)} phrases")

    # Stepwise pentatonic melodies
    stepwise_pent = MusicSpec.from_constraint(
        12, 3,
        lambda p: all(x in [0,2,4,7,9] for x in p) and stepwise_constraint(p)
    )
    print(f"Stepwise C pentatonic (3-note): {len(stepwise_pent)} phrases")

    # Unrestricted scale specs
    major_all = MusicSpec.from_scale([0,2,4,5,7,9,11], 3)
    pent_all = MusicSpec.from_scale([0,2,4,7,9], 3)

    print(f"All C major (3-note): {len(major_all)} phrases")
    print(f"All C pentatonic (3-note): {len(pent_all)} phrases")

    # Verify refinement chain
    assert stepwise_pent.refines(stepwise_major)
    assert stepwise_major.refines(major_all)
    assert stepwise_pent.refines(pent_all)
    assert pent_all.refines(major_all)
    print("\n✓ Refinement chain verified:")
    print("  stepwise_pent ⊆ stepwise_major ⊆ major_all")
    print("  stepwise_pent ⊆ pent_all ⊆ major_all")

    # Build and display Hasse diagram
    specs = {
        'stepwise_pent': stepwise_pent,
        'stepwise_major': stepwise_major,
        'pent_all': pent_all,
        'major_all': major_all,
    }
    hasse = build_refinement_lattice(specs)
    print("\nHasse diagram (child → parent):")
    for child, parent in hasse:
        print(f"  {child} → {parent}")

    # Verify monotonicity of composition
    spec_list = [stepwise_pent, stepwise_major, pent_all, major_all]
    fixed = MusicSpec.from_scale([0, 4, 7], 2)
    mono = verify_monotonicity(spec_list, lambda S, T: S.compose(T), fixed)
    print(f"\n✓ Composition monotonicity verified: {mono}")
