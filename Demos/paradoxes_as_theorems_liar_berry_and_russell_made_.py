#!/usr/bin/env python3
"""Numerical demonstrations of a finite four-valued paraconsistent calculus."""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Dict, FrozenSet, Iterable, List, Mapping, Set, Tuple


@dataclass(frozen=True)
class Four:
    """Independent positive and negative support bits."""

    positive: bool
    negative: bool

    def negated(self) -> "Four":
        return Four(self.negative, self.positive)

    @property
    def designated(self) -> bool:
        return self.positive

    @property
    def glut(self) -> bool:
        return self.positive and self.negative

    @property
    def label(self) -> str:
        return {
            (True, False): "true only",
            (False, True): "false only",
            (True, True): "both (glut)",
            (False, False): "neither (gap)",
        }[(self.positive, self.negative)]


TRUE_ONLY = Four(True, False)
FALSE_ONLY = Four(False, True)
BOTH = Four(True, True)
NEITHER = Four(False, False)


class Sentence(str, Enum):
    LIAR = "Liar"
    RUSSELL = "Russell"
    BERRY = "Berry"
    ORDINARY_TRUTH = "Ordinary truth"
    FALSE_WITNESS = "False witness"
    GAP_WITNESS = "Gap witness"
    SOUNDNESS_CERTIFICATE = "Soundness certificate"


NEGATION: Mapping[Sentence, Sentence] = {
    Sentence.LIAR: Sentence.LIAR,
    Sentence.RUSSELL: Sentence.RUSSELL,
    Sentence.BERRY: Sentence.BERRY,
    Sentence.ORDINARY_TRUTH: Sentence.FALSE_WITNESS,
    Sentence.FALSE_WITNESS: Sentence.ORDINARY_TRUTH,
    Sentence.GAP_WITNESS: Sentence.GAP_WITNESS,
    Sentence.SOUNDNESS_CERTIFICATE: Sentence.SOUNDNESS_CERTIFICATE,
}

VALUATION: Mapping[Sentence, Four] = {
    Sentence.LIAR: BOTH,
    Sentence.RUSSELL: BOTH,
    Sentence.BERRY: BOTH,
    Sentence.ORDINARY_TRUTH: TRUE_ONLY,
    Sentence.FALSE_WITNESS: FALSE_ONLY,
    Sentence.GAP_WITNESS: NEITHER,
    Sentence.SOUNDNESS_CERTIFICATE: BOTH,
}

AXIOMS: FrozenSet[Sentence] = frozenset(
    {
        Sentence.LIAR,
        Sentence.RUSSELL,
        Sentence.BERRY,
        Sentence.ORDINARY_TRUTH,
        Sentence.SOUNDNESS_CERTIFICATE,
    }
)


def double_negation_closure(
    axioms: Iterable[Sentence], negation: Mapping[Sentence, Sentence]
) -> FrozenSet[Sentence]:
    """Compute the least set containing axioms and closed under double negation."""
    derived: Set[Sentence] = set(axioms)
    agenda: List[Sentence] = list(derived)
    while agenda:
        sentence = agenda.pop()
        conclusion = negation[negation[sentence]]
        if conclusion not in derived:
            derived.add(conclusion)
            agenda.append(conclusion)
    return frozenset(derived)


def audit_negation_coherence() -> Dict[Sentence, bool]:
    """Check v(not s) = not v(s) for every sentence."""
    return {
        sentence: VALUATION[NEGATION[sentence]] == VALUATION[sentence].negated()
        for sentence in Sentence
    }


def boolean_fixed_points() -> Tuple[bool, ...]:
    """Search the ordinary two-value set for x = not x."""
    return tuple(x for x in (False, True) if (not x) == x)


def explosion_witness(derived: FrozenSet[Sentence]) -> Tuple[Sentence, Sentence]:
    """Find a derived contradiction and an underived sentence."""
    contradictions = [s for s in derived if NEGATION[s] in derived]
    underived = [s for s in Sentence if s not in derived]
    if not contradictions or not underived:
        raise ValueError("No explicit non-explosion witness exists")
    return contradictions[0], underived[0]


def print_truth_table() -> None:
    print("FOUR-VALUED NEGATION TABLE")
    print("value          bits   negation       designated  glut")
    for value in (TRUE_ONLY, FALSE_ONLY, BOTH, NEITHER):
        bits = f"({int(value.positive)},{int(value.negative)})"
        print(
            f"{value.label:14} {bits:6} {value.negated().label:14} "
            f"{str(value.designated):10}  {value.glut}"
        )


def print_model_audit() -> None:
    derived = double_negation_closure(AXIOMS, NEGATION)
    print("\nSEVEN-SENTENCE MODEL")
    print("sentence                 value          theorem  coherent")
    coherence = audit_negation_coherence()
    for sentence in Sentence:
        value = VALUATION[sentence]
        print(
            f"{sentence.value:24} {value.label:14} "
            f"{str(sentence in derived):7}  {coherence[sentence]}"
        )

    sound = all(VALUATION[s].designated for s in derived)
    paradoxes = (Sentence.LIAR, Sentence.RUSSELL, Sentence.BERRY)
    three_gluts = all(s in derived and VALUATION[s].glut for s in paradoxes)
    contradiction, underived = explosion_witness(derived)

    print(f"\nDerived closure: {sorted(s.value for s in derived)}")
    print(f"Every theorem designated: {sound}")
    print(f"Liar, Russell, and Berry are theorem gluts: {three_gluts}")
    print(f"False witness underivable: {Sentence.FALSE_WITNESS not in derived}")
    print(
        "Failure of explosion: "
        f"{contradiction.value} and its negation are derivable, "
        f"but {underived.value} is not."
    )


def print_classical_boundary() -> None:
    fixed = boolean_fixed_points()
    four_fixed = [v.label for v in (TRUE_ONLY, FALSE_ONLY, BOTH, NEITHER) if v.negated() == v]
    print("\nFIXED-POINT COMPARISON")
    print(f"Boolean negation fixed points: {list(fixed)}")
    print(f"Four-valued negation fixed points: {four_fixed}")


def main() -> None:
    print_truth_table()
    print_model_audit()
    print_classical_boundary()


if __name__ == "__main__":
    main()
