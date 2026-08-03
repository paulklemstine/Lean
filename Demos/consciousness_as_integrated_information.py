#!/usr/bin/env python3
"""Numerical demonstrations for a finite calculus of integrated information.

A causal structure is represented by a nonempty mapping from cut names to
nonnegative losses. Integrated information is the least loss. The script
illustrates minimum-cut attainment, exact reducibility, independent parallel
composition, refinement monotonicity, exclusion, and exponential cut counts.
It uses only the Python standard library.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from math import isclose
from typing import Dict, Hashable, Mapping, Sequence, Tuple, TypeVar

Cut = TypeVar("Cut", bound=Hashable)


@dataclass(frozen=True)
class CausalStructure:
    """A named finite nonempty cut-loss landscape."""

    name: str
    losses: Mapping[str, float]

    def __post_init__(self) -> None:
        if not self.losses:
            raise ValueError("A causal structure must have at least one cut.")
        if any(value < 0 for value in self.losses.values()):
            raise ValueError("Every cut loss must be nonnegative.")


def integrated_information(structure: CausalStructure) -> Tuple[str, float]:
    """Return a minimizing cut and the integrated-information value Phi."""
    cut = min(structure.losses, key=structure.losses.__getitem__)
    return cut, structure.losses[cut]


def parallel_composite(
    left: CausalStructure, right: CausalStructure
) -> CausalStructure:
    """Build the product cut space with additive independent losses."""
    losses: Dict[str, float] = {
        f"({left_cut}, {right_cut})": left_loss + right_loss
        for (left_cut, left_loss), (right_cut, right_loss) in product(
            left.losses.items(), right.losses.items()
        )
    }
    return CausalStructure(f"{left.name} tensor {right.name}", losses)


def refinement_is_valid(
    source: CausalStructure,
    target: CausalStructure,
    target_to_source_cut: Mapping[str, str],
) -> bool:
    """Check L_source(f(c)) <= L_target(c) for every target cut c."""
    if set(target_to_source_cut) != set(target.losses):
        return False
    return all(
        source.losses[target_to_source_cut[cut]] <= target.losses[cut]
        for cut in target.losses
    )


def exclusion(
    candidates: Sequence[CausalStructure],
) -> Tuple[float, Tuple[CausalStructure, ...]]:
    """Return Big Phi and every maximizing candidate (preserving ties)."""
    if not candidates:
        raise ValueError("Exclusion requires at least one candidate.")
    scored = [(candidate, integrated_information(candidate)[1]) for candidate in candidates]
    big_phi = max(score for _, score in scored)
    winners = tuple(
        candidate for candidate, score in scored if isclose(score, big_phi)
    )
    return big_phi, winners


def represented_nontrivial_cut_count(n: int) -> int:
    """Count nonempty proper subsets: 2**n - 2 for n >= 1."""
    if n < 1:
        return 0
    return 2**n - 2


def demonstrate() -> None:
    """Run deterministic examples and assert every displayed identity."""
    sensory = CausalStructure(
        "Sensory loop", {"left/right": 2.0, "front/back": 5.0, "odd/even": 3.5}
    )
    memory = CausalStructure(
        "Memory loop", {"upper/lower": 1.0, "inner/outer": 4.0}
    )
    reducible = CausalStructure(
        "Separable relay", {"module boundary": 0.0, "cross boundary": 2.5}
    )

    print("MINIMUM-CUT PRINCIPLE")
    for system in (sensory, memory, reducible):
        cut, phi = integrated_information(system)
        print(f"  {system.name}: minimizing cut = {cut!r}, Phi = {phi:.2f}")
        assert phi >= 0
        assert all(phi <= loss for loss in system.losses.values())
    assert integrated_information(reducible)[1] == 0.0
    assert any(loss == 0.0 for loss in reducible.losses.values())

    print("\nINDEPENDENT PARALLEL COMPOSITION")
    composite = parallel_composite(sensory, memory)
    composite_cut, composite_phi = integrated_information(composite)
    sensory_phi = integrated_information(sensory)[1]
    memory_phi = integrated_information(memory)[1]
    print(f"  minimizing product cut = {composite_cut}")
    print(f"  Phi(composite) = {composite_phi:.2f}")
    print(f"  Phi(sensory) + Phi(memory) = {sensory_phi + memory_phi:.2f}")
    assert isclose(composite_phi, sensory_phi + memory_phi)

    print("\nREFINEMENT MONOTONICITY")
    coarse = CausalStructure("Coarse model", {"a": 1.0, "b": 2.0})
    refined = CausalStructure("Refined model", {"alpha": 1.5, "beta": 3.0})
    cut_translation = {"alpha": "a", "beta": "b"}
    valid = refinement_is_valid(coarse, refined, cut_translation)
    coarse_phi = integrated_information(coarse)[1]
    refined_phi = integrated_information(refined)[1]
    print(f"  refinement valid: {valid}")
    print(f"  Phi(coarse) = {coarse_phi:.2f} <= Phi(refined) = {refined_phi:.2f}")
    assert valid and coarse_phi <= refined_phi

    print("\nEXCLUSION")
    candidates = [
        CausalStructure("Local pair", {"c1": 1.1, "c2": 1.7}),
        CausalStructure("Recurrent core", {"c1": 3.1, "c2": 2.8, "c3": 4.0}),
        CausalStructure("Wide assembly", {"c1": 2.2, "c2": 2.9}),
        CausalStructure("Peripheral ring", {"c1": 1.9, "c2": 2.0}),
    ]
    big_phi, winners = exclusion(candidates)
    print(f"  Big Phi = {big_phi:.2f}")
    print("  winner(s): " + ", ".join(candidate.name for candidate in winners))
    assert len(winners) == 1 and winners[0].name == "Recurrent core"

    print("\nCOMBINATORIAL GROWTH")
    for n in range(1, 11):
        count = represented_nontrivial_cut_count(n)
        bound = 2**n
        print(f"  n={n:2d}: represented nontrivial cuts={count:4d}, bound={bound:4d}")
        assert count <= bound


if __name__ == "__main__":
    demonstrate()
