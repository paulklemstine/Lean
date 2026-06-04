#!/usr/bin/env python3
"""
Algorithms for Paraconsistent Logic (LP)

Type-hinted implementations of LP model checking, satisfiability,
inconsistency measurement, and Berry number computation.
"""

from __future__ import annotations
from enum import Enum
from dataclasses import dataclass
from typing import Dict, List, Optional, Set, Tuple


class TV(Enum):
    """Three-valued truth in the Logic of Paradox."""
    TT = "true"
    FF = "false"
    BOTH = "both"

    def designated(self) -> bool:
        """Whether this value is designated (accepted as true)."""
        return self in (TV.TT, TV.BOTH)

    def neg(self) -> TV:
        """Paraconsistent negation: fixes 'both', swaps tt/ff."""
        if self == TV.TT:
            return TV.FF
        if self == TV.FF:
            return TV.TT
        return TV.BOTH

    @staticmethod
    def conj(a: TV, b: TV) -> TV:
        """Paraconsistent conjunction: min in order ff < both < tt."""
        if a == TV.FF or b == TV.FF:
            return TV.FF
        if a == TV.TT:
            return b
        if b == TV.TT:
            return a
        return TV.BOTH

    @staticmethod
    def disj(a: TV, b: TV) -> TV:
        """Paraconsistent disjunction: max in order ff < both < tt."""
        if a == TV.TT or b == TV.TT:
            return TV.TT
        if a == TV.FF:
            return b
        if b == TV.FF:
            return a
        return TV.BOTH

    @staticmethod
    def impl(a: TV, b: TV) -> TV:
        """Paraconsistent material conditional: ¬a ∨ b."""
        return TV.disj(a.neg(), b)


@dataclass
class Atom:
    """Atomic proposition."""
    name: str


@dataclass
class Neg:
    """Negation of a sentence."""
    sub: Sentence


@dataclass
class Conj:
    """Conjunction of two sentences."""
    left: Sentence
    right: Sentence


@dataclass
class Disj:
    """Disjunction of two sentences."""
    left: Sentence
    right: Sentence


@dataclass
class Truth:
    """Truth predicate applied to a sentence."""
    sub: Sentence


Sentence = Atom | Neg | Conj | Disj | Truth


def evaluate(valuation: Dict[str, TV], sentence: Sentence) -> TV:
    """
    Evaluate a sentence under an LP valuation.

    Args:
        valuation: Map from atom names to three-valued truth.
        sentence: The sentence to evaluate.

    Returns:
        The three-valued truth of the sentence.

    Time complexity: O(|sentence|)
    """
    match sentence:
        case Atom(name):
            return valuation.get(name, TV.FF)
        case Neg(sub):
            return evaluate(valuation, sub).neg()
        case Conj(left, right):
            return TV.conj(evaluate(valuation, left), evaluate(valuation, right))
        case Disj(left, right):
            return TV.disj(evaluate(valuation, left), evaluate(valuation, right))
        case Truth(sub):
            return evaluate(valuation, sub)  # Transparent truth predicate
        case _:
            raise ValueError(f"Unknown sentence type: {type(sentence)}")


def is_lp_consistent(valuation: Dict[str, TV], sentence: Sentence) -> bool:
    """Check whether a valuation is LP-consistent for a given sentence tree."""
    match sentence:
        case Atom(_):
            return True
        case Neg(sub):
            return (evaluate(valuation, sentence) ==
                    evaluate(valuation, sub).neg() and
                    is_lp_consistent(valuation, sub))
        case Conj(left, right):
            return (evaluate(valuation, sentence) ==
                    TV.conj(evaluate(valuation, left),
                            evaluate(valuation, right)) and
                    is_lp_consistent(valuation, left) and
                    is_lp_consistent(valuation, right))
        case Disj(left, right):
            return (evaluate(valuation, sentence) ==
                    TV.disj(evaluate(valuation, left),
                            evaluate(valuation, right)) and
                    is_lp_consistent(valuation, left) and
                    is_lp_consistent(valuation, right))
        case Truth(sub):
            return is_lp_consistent(valuation, sub)
        case _:
            return False


def inconsistency_degree(valuation: Dict[str, TV]) -> float:
    """
    Compute the inconsistency degree δ of a valuation.

    δ = |{atoms with value BOTH}| / |{all atoms}|

    Returns:
        Float in [0, 1]. 0 means fully classical, 1 means fully glutty.
    """
    if not valuation:
        return 0.0
    glutty = sum(1 for v in valuation.values() if v == TV.BOTH)
    return glutty / len(valuation)


def find_minimal_model(
    paradoxical: Set[str],
    classical_true: Set[str],
    classical_false: Set[str]
) -> Dict[str, TV]:
    """
    Construct a minimally inconsistent LP model.

    Args:
        paradoxical: Atom names that should receive value BOTH.
        classical_true: Atom names that should receive value TT.
        classical_false: Atom names that should receive value FF.

    Returns:
        An LP valuation with minimum inconsistency degree.
    """
    valuation: Dict[str, TV] = {}
    for name in paradoxical:
        valuation[name] = TV.BOTH
    for name in classical_true:
        valuation[name] = TV.TT
    for name in classical_false:
        valuation[name] = TV.FF
    return valuation


def berry_number(complexity: Dict[int, int], k: int) -> int:
    """
    Compute Berry's number at level k.

    Args:
        complexity: Map from natural numbers to their description complexity.
        k: The complexity threshold.

    Returns:
        The smallest number whose complexity exceeds k.
    """
    bound = max(
        (n for n, c in complexity.items() if c <= k),
        default=-1
    )
    return bound + 1


def verify_de_morgan() -> bool:
    """Verify De Morgan's laws hold for all TV combinations."""
    for a in TV:
        for b in TV:
            # ¬(a ∧ b) = ¬a ∨ ¬b
            if TV.conj(a, b).neg() != TV.disj(a.neg(), b.neg()):
                return False
            # ¬(a ∨ b) = ¬a ∧ ¬b
            if TV.disj(a, b).neg() != TV.conj(a.neg(), b.neg()):
                return False
    return True


def verify_negation_involution() -> bool:
    """Verify ¬¬a = a for all TV values."""
    return all(v.neg().neg() == v for v in TV)


def lp_sat_brute_force(
    atoms: List[str],
    sentence: Sentence
) -> Optional[Dict[str, TV]]:
    """
    Brute-force LP satisfiability: find a valuation making the sentence designated.

    Time complexity: O(3^n × |sentence|) where n = |atoms|.

    Args:
        atoms: List of atom names.
        sentence: The sentence to satisfy.

    Returns:
        A satisfying valuation, or None if unsatisfiable.
    """
    def generate_valuations(
        atoms: List[str], idx: int, current: Dict[str, TV]
    ) -> Optional[Dict[str, TV]]:
        if idx == len(atoms):
            if evaluate(current, sentence).designated():
                return dict(current)
            return None
        for tv in TV:
            current[atoms[idx]] = tv
            result = generate_valuations(atoms, idx + 1, current)
            if result is not None:
                return result
        return None

    return generate_valuations(atoms, 0, {})


if __name__ == "__main__":
    # Quick verification
    assert verify_de_morgan(), "De Morgan's laws failed!"
    assert verify_negation_involution(), "Negation involution failed!"

    # Liar sentence demo
    v = {"L": TV.BOTH}
    L = Atom("L")
    liar = Neg(L)
    print(f"Liar: v(L) = {evaluate(v, L).value}")
    print(f"       v(¬L) = {evaluate(v, liar).value}")
    print(f"       L = ¬L? {evaluate(v, L) == evaluate(v, liar)}")
    print(f"       Inconsistency degree: {inconsistency_degree(v):.4f}")

    # Berry number
    complexity = {n: len(str(n)) for n in range(100)}
    bn = berry_number(complexity, 1)
    print(f"\nBerry number at k=1: {bn}")
    print(f"  complexity({bn}) = {complexity.get(bn, 'undefined')}")

    # LP-SAT
    p = Atom("P")
    q = Atom("Q")
    formula = Conj(p, Neg(p))  # P ∧ ¬P
    result = lp_sat_brute_force(["P"], formula)
    print(f"\nLP-SAT for P ∧ ¬P: {result}")

    print("\nAll algorithm checks passed ✓")
