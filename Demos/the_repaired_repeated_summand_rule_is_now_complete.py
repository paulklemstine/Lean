#!/usr/bin/env python3
"""Numerical demonstrations for the distinct-index pair-sum greedy sequence."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable


def distinct_pair_sums(values: list[int]) -> set[int]:
    """Return sums values[i] + values[j] over all i < j."""
    return {
        values[i] + values[j]
        for i in range(len(values))
        for j in range(i + 1, len(values))
    }


def greedy_sequence(length: int) -> list[int]:
    """Generate the sequence directly from the greedy avoidance rule."""
    if length < 0:
        raise ValueError("length must be nonnegative")
    if length == 0:
        return []
    values = [1]
    forbidden: set[int] = set()
    while len(values) < length:
        newest = values[-1]
        if len(values) > 1:
            for previous in values[:-1]:
                forbidden.add(previous + newest)
        candidate = newest + 1
        while candidate in forbidden:
            candidate += 1
        values.append(candidate)
    return values


def closed_form_term(index: int) -> int:
    """Return the classified value at a zero-based index."""
    if index < 0:
        raise ValueError("index must be nonnegative")
    if index == 0:
        return 1
    if index == 1:
        return 2
    return 3 * index - 2


def closed_form_sequence(length: int) -> list[int]:
    """Generate a prefix using the exact formula."""
    if length < 0:
        raise ValueError("length must be nonnegative")
    return [closed_form_term(index) for index in range(length)]


def is_sequence_value(value: int) -> bool:
    """Test exact range membership: {2} union {3k+1 : k >= 0}."""
    return value >= 0 and (value == 2 or value % 3 == 1)


def sequence_index(value: int) -> int | None:
    """Return the unique index of a sequence value, or None if absent."""
    if value == 1:
        return 0
    if value == 2:
        return 1
    if value >= 4 and value % 3 == 1:
        return (value + 2) // 3
    return None


def exact_count_through(cutoff: int) -> int:
    """Count attained values in {0, ..., cutoff}."""
    if cutoff < 0:
        return 0
    residue_count = 0 if cutoff < 1 else (cutoff - 1) // 3 + 1
    return residue_count + int(cutoff >= 2)


@dataclass(frozen=True)
class StageCertificate:
    """Numerical certificate for one stable greedy transition."""

    current: int
    blocked_by_one: int
    blocked_by_two: int
    successor: int
    successor_is_forbidden: bool


def stage_certificates(values: list[int]) -> list[StageCertificate]:
    """Build local-blocking and global-admissibility diagnostics."""
    certificates: list[StageCertificate] = []
    for current_index in range(2, len(values) - 1):
        prefix = values[: current_index + 1]
        forbidden = distinct_pair_sums(prefix)
        current = values[current_index]
        successor = values[current_index + 1]
        certificates.append(
            StageCertificate(
                current=current,
                blocked_by_one=current + 1,
                blocked_by_two=current + 2,
                successor=successor,
                successor_is_forbidden=successor in forbidden,
            )
        )
    return certificates


def residue_histogram(values: Iterable[int]) -> dict[int, int]:
    """Count values in each residue class modulo three."""
    counts = {0: 0, 1: 0, 2: 0}
    for value in values:
        counts[value % 3] += 1
    return counts


def run_demo(length: int = 15, cutoffs: tuple[int, ...] = (10, 100, 1000)) -> None:
    """Print and assert the classification, certificates, and density data."""
    direct = greedy_sequence(length)
    formula = closed_form_sequence(length)
    assert direct == formula
    assert all(sequence_index(value) == index for index, value in enumerate(direct))
    assert all(is_sequence_value(value) for value in direct)

    print("Distinct-index pair-sum greedy sequence")
    print("Direct generation:", direct)
    print("Closed form:      ", formula)
    print("Residues mod 3:   ", residue_histogram(direct))
    print("\nStable-stage certificates:")
    for certificate in stage_certificates(direct[:8]):
        assert certificate.blocked_by_one in distinct_pair_sums(
            direct[: direct.index(certificate.current) + 1]
        )
        assert certificate.blocked_by_two in distinct_pair_sums(
            direct[: direct.index(certificate.current) + 1]
        )
        assert not certificate.successor_is_forbidden
        print(
            f"  after {certificate.current}: "
            f"{certificate.blocked_by_one} and {certificate.blocked_by_two} blocked; "
            f"{certificate.successor} admitted"
        )

    print("\nExact cutoff counts and empirical densities:")
    for cutoff in cutoffs:
        exact = exact_count_through(cutoff)
        enumerated = sum(is_sequence_value(value) for value in range(cutoff + 1))
        assert exact == enumerated
        print(
            f"  N={cutoff:4d}: A(N)={exact:4d}, "
            f"A(N)/(N+1)={exact / (cutoff + 1):.6f}"
        )


if __name__ == "__main__":
    run_demo()
