#!/usr/bin/env python3
"""Finite illustrations of the logic–physics consistency framework.

These examples audit finite truth tables and constraint systems. They illustrate
the dependency structure of the theorems; they do not decide consistency or
independence for unrestricted first-order theories.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Iterable, Mapping, Sequence

World = Mapping[str, bool]
Sentence = Callable[[World], bool]


@dataclass(frozen=True)
class BridgeConditions:
    """Certificates used by the two halves of the independence argument."""

    provability_conditions: bool
    ambient_consistency: bool
    reflection: bool
    contradiction_proof_soundness: bool

    def positive_half(self) -> bool:
        """Whether the data rule out a proof of Con(T)."""
        return (
            self.provability_conditions
            and self.ambient_consistency
            and self.reflection
        )

    def negative_half(self) -> bool:
        """Whether the data rule out a proof of not-Con(T)."""
        return self.provability_conditions and self.contradiction_proof_soundness

    def establishes_independence(self) -> bool:
        """Whether both halves of the independence criterion are certified."""
        return self.positive_half() and self.negative_half()


def enumerate_worlds(atoms: Sequence[str]) -> list[dict[str, bool]]:
    """Enumerate every Boolean world over the supplied atomic propositions."""
    return [dict(zip(atoms, values)) for values in product((False, True), repeat=len(atoms))]


def realizing_worlds(worlds: Iterable[World], theory: Sequence[Sentence]) -> list[World]:
    """Return worlds satisfying every sentence of a finite theory."""
    return [world for world in worlds if all(sentence(world) for sentence in theory)]


def consistency_truth(boxed_contradiction: bool) -> bool:
    """Evaluate Con(T) = (Box_T bottom -> bottom), with bottom fixed false."""
    bottom = False
    return (not boxed_contradiction) or bottom


def box_true_countermodel(theory_count: int) -> list[tuple[int, bool, bool]]:
    """Evaluate indexed consistency sentences when every boxed claim is true."""
    return [
        (index, consistency_truth(boxed_contradiction=True), True)
        for index in range(theory_count)
    ]


def demonstrate_physical_implication() -> None:
    """Find finite models and display the physical-to-mathematical implication."""
    worlds = enumerate_worlds(["energy_conserved", "stable_vacuum"])
    theory: list[Sentence] = [
        lambda w: w["energy_conserved"],
        lambda w: w["stable_vacuum"],
    ]
    models = realizing_worlds(worlds, theory)
    print("Example 1 — finite physical realization")
    print(f"  candidate worlds: {len(worlds)}")
    print(f"  realizing worlds: {len(models)}")
    print(f"  witness: {dict(models[0]) if models else None}")
    print("  Under sound inference, a witness excludes a derivation of contradiction.\n")


def demonstrate_independence_dependencies() -> None:
    """Show that dropping either bridge condition destroys the corresponding half."""
    cases = {
        "all conditions": BridgeConditions(True, True, True, True),
        "reflection missing": BridgeConditions(True, True, False, True),
        "soundness missing": BridgeConditions(True, True, True, False),
        "ambient inconsistency": BridgeConditions(True, False, True, True),
    }
    print("Example 2 — independence-condition audit")
    for name, conditions in cases.items():
        print(
            f"  {name:22s} positive={conditions.positive_half()} "
            f"negative={conditions.negative_half()} "
            f"independent={conditions.establishes_independence()}"
        )
    print()


def demonstrate_consistency_countermodel() -> None:
    """Display a consistent valuation that refutes every indexed Con(T)."""
    rows = box_true_countermodel(5)
    print("Example 3 — consistency alone does not force independence")
    print("  bottom is false, so the ambient valuation is contradiction-free.")
    for index, con_value, boxed_bottom in rows:
        print(f"  T{index}: Box_T(bottom)={boxed_bottom}, Con(T)={con_value}")
    print("  Every negated consistency sentence is therefore true.\n")


def demonstrate_consistent_but_unrealized() -> None:
    """Illustrate the existential gap using an empty admissible world class."""
    worlds: list[World] = []
    theory: list[Sentence] = [lambda _w: True]
    models = realizing_worlds(worlds, theory)
    recorded_contradiction_derivations = 0
    print("Example 4 — mathematical consistency without physical realization")
    print(f"  recorded contradiction derivations: {recorded_contradiction_derivations}")
    print(f"  admissible worlds: {len(worlds)}")
    print(f"  realizations: {len(models)}")
    print("  Non-derivability does not create a realizing world.")


def main() -> None:
    demonstrate_physical_implication()
    demonstrate_independence_dependencies()
    demonstrate_consistency_countermodel()
    demonstrate_consistent_but_unrealized()


if __name__ == "__main__":
    main()
