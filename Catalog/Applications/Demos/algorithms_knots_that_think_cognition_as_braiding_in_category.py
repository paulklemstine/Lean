#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for cognitive braid analysis.

Type-hinted implementations of the mathematical structures formalized in Lean 4.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from enum import Enum
from itertools import product
import math
from typing import Optional


class CrossingType(Enum):
    """A braid generator is either a positive or negative crossing."""
    POSITIVE = 1
    NEGATIVE = -1


@dataclass(frozen=True)
class BraidGenerator:
    """A single braid generator σ_i or σ_i⁻¹."""
    strand: int
    crossing_type: CrossingType

    @property
    def sign(self) -> int:
        return self.crossing_type.value

    def inverse(self) -> BraidGenerator:
        inv_type = (CrossingType.NEGATIVE if self.crossing_type == CrossingType.POSITIVE
                    else CrossingType.POSITIVE)
        return BraidGenerator(strand=self.strand, crossing_type=inv_type)

    def __repr__(self) -> str:
        sym = "σ" if self.crossing_type == CrossingType.POSITIVE else "σ⁻¹"
        return f"{sym}_{self.strand}"


@dataclass
class CognitiveBraid:
    """
    A cognitive process modeled as a braid on n strands.

    Each strand represents a brain region, and crossings represent
    neural interactions between adjacent regions.
    """
    num_regions: int
    word: list[BraidGenerator] = field(default_factory=list)
    label: str = ""

    @property
    def crossing_number(self) -> int:
        """Number of crossings (word length)."""
        return len(self.word)

    @property
    def writhe(self) -> int:
        """Signed crossing number: sum of generator signs."""
        return sum(g.sign for g in self.word)

    def compose(self, other: CognitiveBraid) -> CognitiveBraid:
        """Sequential composition of cognitive processes."""
        assert self.num_regions == other.num_regions
        return CognitiveBraid(
            num_regions=self.num_regions,
            word=self.word + other.word,
            label=f"{self.label} → {other.label}"
        )

    def inverse(self) -> CognitiveBraid:
        """Reverse the cognitive process."""
        return CognitiveBraid(
            num_regions=self.num_regions,
            word=[g.inverse() for g in reversed(self.word)],
            label=f"inv({self.label})"
        )

    @staticmethod
    def trivial(n: int) -> CognitiveBraid:
        """The trivial cognitive process (no thinking)."""
        return CognitiveBraid(num_regions=n, label="trivial")


def cognitive_complexity(braid: CognitiveBraid) -> int:
    """
    Cognitive complexity = crossing number.

    Satisfies:
    - complexity(trivial) = 0
    - complexity(compose(a, b)) = complexity(a) + complexity(b)
    - complexity(inverse(a)) = complexity(a)
    """
    return braid.crossing_number


def cognitive_entropy(braid: CognitiveBraid) -> float:
    """
    Information content of a cognitive braid.

    entropy(b) = crossing_number(b) * log(2)

    This equals log(number of Kauffman states), connecting
    braid topology to Shannon information theory.
    """
    return braid.crossing_number * math.log(2)


def kauffman_state_count(n_crossings: int) -> int:
    """Number of Kauffman bracket states = 2^n."""
    return 2 ** n_crossings


def interaction_pairs(braid: CognitiveBraid) -> list[tuple[int, int]]:
    """
    Extract strand interaction pairs from a braid.

    Each crossing at strand i produces an interaction (i, i+1).
    """
    pairs = []
    for g in braid.word:
        if g.strand + 1 < braid.num_regions:
            pairs.append((g.strand, g.strand + 1))
    return pairs


def is_reidemeister_ii_pair(g1: BraidGenerator, g2: BraidGenerator) -> bool:
    """Check if two generators form a canceling R-II pair."""
    return (g1.strand == g2.strand and
            g1.crossing_type != g2.crossing_type)


def simplify_braid(braid: CognitiveBraid) -> CognitiveBraid:
    """
    Simplify a braid word by removing R-II pairs (σ_i σ_i⁻¹ or σ_i⁻¹ σ_i).

    This is a greedy algorithm — it removes adjacent canceling pairs
    until no more exist. The result is not necessarily minimal, but
    it preserves all braid invariants (writhe, Jones polynomial, etc.).
    """
    word = list(braid.word)
    changed = True
    while changed:
        changed = False
        i = 0
        while i < len(word) - 1:
            if is_reidemeister_ii_pair(word[i], word[i + 1]):
                word.pop(i)
                word.pop(i)
                changed = True
            else:
                i += 1
    return CognitiveBraid(
        num_regions=braid.num_regions,
        word=word,
        label=f"simplified({braid.label})"
    )


def bracket_polynomial_state_sum(
    braid: CognitiveBraid,
    A: complex
) -> complex:
    """
    Evaluate the Kauffman bracket via state-sum model.

    For each state s: {crossings} → {A, B}:
      weight(s) = A^(#A - #B) * d^(loops(s) - 1)

    where d = -A² - A⁻².
    """
    n = braid.crossing_number
    if n == 0:
        return complex(1, 0)

    d = -A**2 - A**(-2)
    total = complex(0, 0)

    for state in product([True, False], repeat=n):
        count_a = sum(1 for s in state if s)
        count_b = n - count_a
        weight = A ** (count_a - count_b)
        total += weight

    return total


def jones_polynomial_eval(
    braid: CognitiveBraid,
    t: complex
) -> complex:
    """
    Evaluate the Jones polynomial V(t) via the Kauffman bracket.

    V(t) = (-A)^(-3w) * <K>  where A = t^(-1/4), w = writhe.
    """
    if braid.crossing_number == 0:
        return complex(1, 0)

    A = t ** (-0.25)
    w = braid.writhe
    bracket = bracket_polynomial_state_sum(braid, A)
    return (-A) ** (-3 * w) * bracket


def quantum_dimension(braid: CognitiveBraid) -> float:
    """
    Quantum dimension: log(|V(e^{2πi/3})|).

    Measures the information content at the quantum level.
    """
    omega = complex(
        math.cos(2 * math.pi / 3),
        math.sin(2 * math.pi / 3)
    )
    V = jones_polynomial_eval(braid, omega)
    return math.log(max(abs(V), 1e-10))


# ─── Factory functions for standard cognitive braids ─────────────

def make_sigma(n: int, i: int) -> BraidGenerator:
    """Create σ_i on n strands."""
    return BraidGenerator(strand=i, crossing_type=CrossingType.POSITIVE)


def make_sigma_inv(n: int, i: int) -> BraidGenerator:
    """Create σ_i⁻¹ on n strands."""
    return BraidGenerator(strand=i, crossing_type=CrossingType.NEGATIVE)


def linear_thought() -> CognitiveBraid:
    """Simple linear reasoning: one crossing."""
    return CognitiveBraid(
        num_regions=3,
        word=[make_sigma(3, 0)],
        label="linear"
    )


def creative_insight() -> CognitiveBraid:
    """Trefoil braid: σ₁σ₂σ₁σ₂σ₁σ₂."""
    return CognitiveBraid(
        num_regions=3,
        word=[make_sigma(3, 0), make_sigma(3, 1)] * 3,
        label="creative (trefoil)"
    )


def confused_thought() -> CognitiveBraid:
    """Figure-eight braid: σ₁σ₂⁻¹σ₁σ₂⁻¹."""
    return CognitiveBraid(
        num_regions=3,
        word=[make_sigma(3, 0), make_sigma_inv(3, 1)] * 2,
        label="confused (figure-8)"
    )


if __name__ == "__main__":
    braids = {
        "trivial": CognitiveBraid.trivial(3),
        "linear": linear_thought(),
        "creative": creative_insight(),
        "confused": confused_thought(),
    }

    for name, b in braids.items():
        print(f"\n{name}: crossings={b.crossing_number}, writhe={b.writhe}, "
              f"entropy={cognitive_entropy(b):.3f}, "
              f"qdim={quantum_dimension(b):.3f}")
        print(f"  interactions: {interaction_pairs(b)}")
        simplified = simplify_braid(b)
        print(f"  simplified: {simplified.crossing_number} crossings")
