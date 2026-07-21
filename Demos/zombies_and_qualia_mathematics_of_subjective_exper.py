#!/usr/bin/env python3
"""Numerical demonstrations of functional fibres and experiential gaps.

The script uses only the Python standard library. It constructs split states,
checks unique zombie twins, computes pulled-back functional distances, tests
fibre constancy on finite models, and illustrates the label-preserving bridge
to indexed incompleteness-gap records.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import dist
from typing import Dict, Hashable, Iterable, Optional, Sequence, TypeVar

Label = tuple[float, ...]
K = TypeVar("K", bound=Hashable)


@dataclass(frozen=True)
class SplitState:
    """A behavioral profile paired with a Boolean experience coordinate."""

    behavior: Label
    aware: bool


@dataclass(frozen=True)
class ExperientialGap:
    """An aware state and its behaviorally identical void counterpart."""

    aware_state: SplitState
    void_state: SplitState


@dataclass(frozen=True)
class IndexedIncompletenessGap:
    """A label paired with a designated indexed consistency sentence."""

    behavior: Label
    theory_index: int
    sentence: str
    sentence_unprovable: bool = True
    negation_unprovable: bool = True


def qualia_flip(state: SplitState) -> SplitState:
    """Toggle awareness without changing the behavioral profile."""

    return SplitState(state.behavior, not state.aware)


def unique_zombie_twin(state: SplitState) -> SplitState:
    """Return the unique void twin of an aware state in the split model."""

    if not state.aware:
        raise ValueError("The oriented construction requires an aware input state.")
    return SplitState(state.behavior, False)


def make_experiential_gap(behavior: Label) -> ExperientialGap:
    """Construct the canonical oriented gap over a behavioral profile."""

    return ExperientialGap(
        aware_state=SplitState(behavior, True),
        void_state=SplitState(behavior, False),
    )


def functional_distance(left: SplitState, right: SplitState) -> float:
    """Euclidean distance between observed behavioral profiles only."""

    return dist(left.behavior, right.behavior)


def first_fibre_conflict(
    observations: Iterable[tuple[K, bool]],
) -> Optional[tuple[K, bool, bool]]:
    """Find a profile carrying both experience values, if one exists.

    A returned triple ``(profile, old_value, new_value)`` certifies failure of
    fibre constancy and hence failure of functional reconstruction.
    """

    values: Dict[K, bool] = {}
    for profile, experience in observations:
        if profile in values and values[profile] != experience:
            return profile, values[profile], experience
        values.setdefault(profile, experience)
    return None


def reconstruct_experience(
    observations: Iterable[tuple[K, bool]],
) -> Dict[K, bool]:
    """Build the unique observed-range reconstruction when fibres are constant."""

    reconstruction: Dict[K, bool] = {}
    for profile, experience in observations:
        previous = reconstruction.get(profile)
        if previous is not None and previous != experience:
            raise ValueError(f"Experience varies over functional profile {profile!r}.")
        reconstruction[profile] = experience
    return reconstruction


def bridge_to_incompleteness(
    gap: ExperientialGap, theory_index: int
) -> IndexedIncompletenessGap:
    """Preserve the gap label and attach the indexed consistency sentence."""

    if gap.aware_state.behavior != gap.void_state.behavior:
        raise ValueError("Endpoints are not functionally identical.")
    if not gap.aware_state.aware or gap.void_state.aware:
        raise ValueError("The gap orientation must be aware-to-void.")
    return IndexedIncompletenessGap(
        behavior=gap.aware_state.behavior,
        theory_index=theory_index,
        sentence=f"C_{theory_index}",
    )


def demonstrate_split_model(labels: Sequence[Label]) -> None:
    """Print involution, uniqueness, classification, and distance examples."""

    print("\n1. Split model, canonical twins, and zero functional distance")
    for label in labels:
        aware = SplitState(label, True)
        twin = unique_zombie_twin(aware)
        twice = qualia_flip(qualia_flip(aware))
        gap = make_experiential_gap(label)
        assert twin == qualia_flip(aware)
        assert twice == aware
        assert functional_distance(aware, twin) == 0.0
        print(
            f"  label={label}: twin={twin}, "
            f"flip² identity={twice == aware}, "
            f"functional distance={functional_distance(*[gap.aware_state, gap.void_state]):.1f}"
        )


def demonstrate_reconstruction_boundary() -> None:
    """Compare fibre-constant and fibre-varying finite models."""

    print("\n2. Fibre constancy and reconstructibility")
    constant_data = [("red", True), ("red", True), ("blue", False)]
    varying_data = [("red", True), ("blue", False), ("red", False)]
    print(f"  constant fibres: reconstruction={reconstruct_experience(constant_data)}")
    conflict = first_fibre_conflict(varying_data)
    print(f"  varying fibre: conflict certificate={conflict}")
    assert conflict == ("red", True, False)


def demonstrate_gap_bridge(labels: Sequence[Label], theory_index: int) -> None:
    """Show that experiential and indexed logical gaps share each label."""

    print("\n3. Label-preserving experiential–incompleteness bridge")
    for label in labels:
        experiential = make_experiential_gap(label)
        logical = bridge_to_incompleteness(experiential, theory_index)
        assert logical.behavior == label
        print(
            f"  {label} -> ({logical.behavior}, {logical.sentence}); "
            "both sentence polarities marked unprovable"
        )


def main() -> None:
    """Run all numerical demonstrations."""

    labels: list[Label] = [(0.0, 0.0), (1.0, -1.0), (3.0, 4.0)]
    demonstrate_split_model(labels)
    demonstrate_reconstruction_boundary()
    demonstrate_gap_bridge(labels, theory_index=7)
    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()
