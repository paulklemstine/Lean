#!/usr/bin/env python3
"""
Cognitive Braid Algebra — Algorithms

Type-hinted implementations of the core algorithms from the
Cognitive Braid Algebra formalization.
"""

from dataclasses import dataclass
from typing import List, Optional, Tuple


@dataclass(frozen=True)
class BraidGen:
    """A braid group generator σ_i^ε."""
    index: int
    pos: bool

    @property
    def sign(self) -> int:
        """Sign: +1 for positive, -1 for negative."""
        return 1 if self.pos else -1

    @property
    def inv(self) -> 'BraidGen':
        """Inverse generator."""
        return BraidGen(self.index, not self.pos)

    def __repr__(self) -> str:
        return f"σ{'⁺' if self.pos else '⁻'}({self.index})"


BraidWord = List[BraidGen]


def exponent_sum(word: BraidWord) -> int:
    """
    Compute the exponent sum (abelianization) of a braid word.

    This is the image under the unique homomorphism B_n → ℤ
    sending each generator σ_i to +1.

    Time: O(|word|)
    Space: O(1)
    """
    return sum(g.sign for g in word)


def pos_count(word: BraidWord) -> int:
    """Count positive generators."""
    return sum(1 for g in word if g.pos)


def neg_count(word: BraidWord) -> int:
    """Count negative generators."""
    return sum(1 for g in word if not g.pos)


@dataclass(frozen=True)
class ComplexityShadow:
    """
    The complexity shadow of a braid: (exponent, crossings).

    The exponent is the signed crossing count (braid invariant).
    The crossings is the total unsigned crossing count (word length).
    """
    exponent: int
    crossings: int

    @property
    def realizable(self) -> bool:
        """
        Check if this shadow can arise from an actual braid word.

        Theorem: (e, c) is realizable ⟺ |e| ≤ c ∧ (e + c) is even.
        """
        return abs(self.exponent) <= self.crossings and \
               (self.exponent + self.crossings) % 2 == 0

    @property
    def coherence_ratio(self) -> float:
        """
        Coherence ratio |e|/c ∈ [0, 1].

        - 1.0 = maximally coherent (all crossings same direction)
        - 0.0 = maximally incoherent (equal positive/negative)
        """
        if self.crossings == 0:
            return 0.0
        return abs(self.exponent) / self.crossings


def shadow(word: BraidWord) -> ComplexityShadow:
    """Extract the complexity shadow from a braid word."""
    return ComplexityShadow(exponent_sum(word), len(word))


def construct_word(target: ComplexityShadow) -> Optional[BraidWord]:
    """
    Construct a braid word with the given complexity shadow.

    Returns None if the shadow is not realizable.

    Algorithm: Use p = (c + e)/2 positive generators and
    n = (c - e)/2 negative generators (all on strand 0).

    Time: O(c)
    """
    if not target.realizable:
        return None
    p = (target.crossings + target.exponent) // 2
    n = target.crossings - p
    return [BraidGen(0, True)] * p + [BraidGen(0, False)] * n


def apply_cancellation(word: BraidWord) -> BraidWord:
    """
    Perform one pass of adjacent cancellation.

    Removes pairs σ_i σ_i⁻¹ and σ_i⁻¹ σ_i.
    May need multiple passes for full reduction.

    Time: O(|word|) per pass
    """
    if len(word) < 2:
        return word
    result: BraidWord = []
    i = 0
    while i < len(word):
        if i + 1 < len(word) and \
           word[i].index == word[i + 1].index and \
           word[i].pos != word[i + 1].pos:
            i += 2  # skip the cancelling pair
        else:
            result.append(word[i])
            i += 1
    return result


def free_reduce(word: BraidWord) -> BraidWord:
    """
    Fully reduce a braid word by repeated cancellation.

    Iterates apply_cancellation until no more cancellations possible.
    The result is freely reduced (no adjacent inverse pairs).

    Note: This does NOT apply Yang-Baxter or far commutativity.
    The freely reduced word may not be the shortest representative
    of its braid equivalence class.

    Time: O(|word|²) worst case
    """
    prev_len = len(word) + 1
    while len(word) < prev_len:
        prev_len = len(word)
        word = apply_cancellation(word)
    return word


def partial_exponent_sums(word: BraidWord) -> List[int]:
    """
    Compute the running exponent sum at each position.

    This is the "trajectory" of the braid through complexity space.
    The shape of this trajectory contains information about the
    internal structure of the cognitive process.

    Returns: List of length |word| + 1 (including initial 0)
    """
    sums = [0]
    for g in word:
        sums.append(sums[-1] + g.sign)
    return sums


def entanglement_depth(word: BraidWord) -> int:
    """
    Maximum absolute partial exponent sum.

    Measures the maximum "depth" of entanglement reached during
    the cognitive process. Higher values indicate more complex
    intermediate states.
    """
    return max(abs(s) for s in partial_exponent_sums(word))


def enumerate_shadows(max_crossings: int) -> List[ComplexityShadow]:
    """
    Enumerate all realizable complexity shadows up to a given crossing count.

    Returns shadows sorted by (crossings, |exponent|).
    """
    result = []
    for c in range(max_crossings + 1):
        for e in range(-c, c + 1):
            s = ComplexityShadow(e, c)
            if s.realizable:
                result.append(s)
    return result


if __name__ == "__main__":
    # Quick self-test
    print("Testing algorithms...")

    # Test shadow characterization
    for c in range(10):
        for e in range(-c, c + 1):
            s = ComplexityShadow(e, c)
            if s.realizable:
                w = construct_word(s)
                assert w is not None
                assert shadow(w) == s, f"Failed for {s}: got {shadow(w)}"

    print("  Shadow characterization: ✓")

    # Test free reduction preserves exponent sum
    import random
    random.seed(0)
    for _ in range(100):
        n = random.randint(0, 20)
        w = [BraidGen(random.randint(0, 3), random.choice([True, False]))
             for _ in range(n)]
        reduced = free_reduce(w)
        assert exponent_sum(w) == exponent_sum(reduced)
    print("  Free reduction preserves exponent sum: ✓")

    # Test parity
    for _ in range(100):
        n = random.randint(0, 20)
        w = [BraidGen(random.randint(0, 3), random.choice([True, False]))
             for _ in range(n)]
        assert (exponent_sum(w) + len(w)) % 2 == 0
    print("  Parity theorem: ✓")

    print("All tests passed!")
