#!/usr/bin/env python3
"""Finite truth-table demonstrations of consequence-guided reasoning."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Iterable, Sequence

TruthVector = tuple[bool, ...]


@dataclass(frozen=True)
class Audit:
    """Logical properties of a candidate and a family of consequences."""

    forward: bool
    jointly_verified: bool
    coherent: bool
    backward_certificate: bool
    counterexample_worlds: tuple[int, ...]


def implies(left: TruthVector, right: TruthVector) -> bool:
    """Return whether pointwise implication holds in every finite world."""
    if len(left) != len(right):
        raise ValueError("Truth vectors must have equal lengths")
    return all((not p) or q for p, q in zip(left, right))


def conjunction(vectors: Sequence[TruthVector], worlds: int) -> TruthVector:
    """Compute a pointwise conjunction; the empty conjunction is true."""
    if any(len(vector) != worlds for vector in vectors):
        raise ValueError("Every truth vector must have the stated world count")
    return tuple(all(vector[w] for vector in vectors) for w in range(worlds))


def audit_candidate(
    candidate: TruthVector,
    consequences: Sequence[TruthVector],
    observed_world: int,
) -> Audit:
    """Audit forward consequencehood, observation, coherence, and recovery."""
    worlds = len(candidate)
    if not 0 <= observed_world < worlds:
        raise ValueError("Observed world is out of range")
    joint = conjunction(consequences, worlds)
    forward = all(implies(candidate, consequence) for consequence in consequences)
    jointly_verified = all(consequence[observed_world] for consequence in consequences)
    coherent = any(joint)
    backward = implies(joint, candidate)
    bad = tuple(w for w in range(worlds) if joint[w] and not candidate[w])
    return Audit(forward, jointly_verified, coherent, backward, bad)


def enumerate_uniform_boundary(worlds: int) -> tuple[int, int]:
    """Count candidates satisfying uniform confirmation and candidates true everywhere."""
    vectors = [tuple(bits) for bits in product((False, True), repeat=worlds)]
    uniform_count = 0
    true_count = 0
    for candidate in vectors:
        is_uniform = all(
            not (implies(candidate, consequence) and any(consequence))
            or all(candidate)
            for consequence in vectors
        )
        uniform_count += int(is_uniform)
        true_count += int(all(candidate))
    return uniform_count, true_count


def minimal_complete_subfamilies(
    candidate: TruthVector, consequences: Sequence[TruthVector]
) -> list[tuple[int, ...]]:
    """Find inclusion-minimal subfamilies whose conjunction implies the candidate."""
    worlds = len(candidate)
    complete: list[tuple[int, ...]] = []
    for mask in range(1 << len(consequences)):
        indices = tuple(i for i in range(len(consequences)) if mask & (1 << i))
        if any(set(previous).issubset(indices) for previous in complete):
            continue
        joint = conjunction([consequences[i] for i in indices], worlds)
        if implies(joint, candidate):
            complete.append(indices)
    return complete


def print_audit(name: str, audit: Audit) -> None:
    print(f"\n{name}")
    print("-" * len(name))
    print(f"forward consequences:  {audit.forward}")
    print(f"jointly verified:      {audit.jointly_verified}")
    print(f"coherent:               {audit.coherent}")
    print(f"backward certificate:   {audit.backward_certificate}")
    print(f"counterexample worlds:  {audit.counterexample_worlds}")


def main() -> None:
    # Demo 1: the always-true consequence passes forward checks for a false candidate.
    false_candidate = (False, False, False, False)
    always_true = (True, True, True, True)
    print_audit(
        "Always-true control for a false candidate",
        audit_candidate(false_candidate, [always_true], observed_world=0),
    )

    # Demo 2: finite exhaustive confirmation of the uniform boundary pattern.
    for worlds in range(1, 5):
        uniform, true_everywhere = enumerate_uniform_boundary(worlds)
        print(
            f"{worlds} world(s): uniform candidates={uniform}, "
            f"universally true candidates={true_everywhere}"
        )

    # Demo 3: two coarse consequences jointly reconstruct the candidate.
    candidate = (True, False, False, False)
    first_half = (True, True, False, False)
    alternating = (True, False, True, False)
    print_audit(
        "Joint backward certificate",
        audit_candidate(candidate, [first_half, alternating], observed_world=0),
    )
    print(
        "Minimal complete subfamilies:",
        minimal_complete_subfamilies(candidate, [first_half, alternating, always_true]),
    )


if __name__ == "__main__":
    main()
